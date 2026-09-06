#!/bin/bash
set -e

if [ "$ROLE" = "web" ]; then
    echo "Updating submodules..."
    git config --global --add safe.directory /app || true
    git submodule update --init --recursive || true

    echo "Building styles..."
    sed -i 's/\r$//' make_style.sh
    chmod +x make_style.sh
    ./make_style.sh

    echo "Running collectstatic..."
    python manage.py collectstatic --noinput

    echo "Compiling messages..."
    python manage.py compilemessages
    python manage.py compilejsi18n

    echo "Applying database migrations..."
    python manage.py migrate --noinput

    echo "Loading initial data..."
    python manage.py loaddata language_small demo navbar || true

    if [ -n "$ADMIN_USERNAME" ] && [ -n "$ADMIN_PASSWORD" ]; then
        echo "Creating/updating superuser and judge from env variables..."
        cat <<EOF | python manage.py shell
from django.contrib.auth import get_user_model
from judge.models import Judge
import os
User = get_user_model()
user, created = User.objects.get_or_create(username='$ADMIN_USERNAME', defaults={'email': '$ADMIN_EMAIL'})
user.set_password('$ADMIN_PASSWORD')
user.is_superuser = True
user.is_staff = True
user.save()
print('Superuser created/updated successfully.')

judge, created = Judge.objects.get_or_create(name='judge1')
judge.auth_key = os.environ.get('JUDGE_KEY', 'secret_judge_key_123')
judge.is_blocked = False
judge.is_disabled = False
judge.save()
print('Judge judge1 created/updated successfully.')

judge_small, created = Judge.objects.get_or_create(name='judge-small')
judge_small.auth_key = os.environ.get('JUDGE_SMALL_KEY', 'secret_judge_key_123')
judge_small.is_blocked = False
judge_small.is_disabled = False
judge_small.save()
print('Judge judge-small created/updated successfully.')
EOF
    fi

    echo "Updating Site domain..."
    cat <<EOF | python manage.py shell
from django.contrib.sites.models import Site
import os
try:
    s, created = Site.objects.get_or_create(id=1)
    canonical = os.environ.get('DMOJ_CANONICAL', 'localhost:5000')
    site_name = os.environ.get('SITE_NAME', 'ICTU JUDGE')
    if s.domain != canonical or s.name != site_name:
        s.domain = canonical
        s.name = site_name
        s.save()
        print(f"Site domain updated to {canonical}")
except Exception as e:
    print(f"Failed to update Site domain: {e}")
EOF
fi

echo "Starting command: $@"
exec "$@"
