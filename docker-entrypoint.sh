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
        echo "Creating superuser and judge if they don't exist..."
        cat <<EOF | python manage.py shell
from django.contrib.auth import get_user_model
from judge.models import Judge
User = get_user_model()
if not User.objects.filter(username='$ADMIN_USERNAME').exists():
    User.objects.create_superuser('$ADMIN_USERNAME', '$ADMIN_EMAIL', '$ADMIN_PASSWORD')
    print('Superuser created successfully.')

if not Judge.objects.filter(name='judge1').exists():
    import os
    Judge.objects.create(name='judge1', auth_key=os.environ.get('JUDGE_KEY', 'secret_judge_key_123'), is_blocked=False, is_disabled=False, ping=0, load=0)
    print('Judge judge1 created successfully.')
EOF
    fi
fi

echo "Starting command: $@"
exec "$@"
