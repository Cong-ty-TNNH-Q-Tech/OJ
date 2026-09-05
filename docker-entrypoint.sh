#!/bin/bash
set -e

echo "Running collectstatic..."
python manage.py collectstatic --noinput

echo "Compiling messages..."
python manage.py compilemessages
python manage.py compilejsi18n

echo "Applying database migrations..."
python manage.py migrate --noinput

if [ -n "$ADMIN_USERNAME" ] && [ -n "$ADMIN_PASSWORD" ]; then
    echo "Creating superuser if it doesn't exist..."
    cat <<EOF | python manage.py shell
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='$ADMIN_USERNAME').exists():
    User.objects.create_superuser('$ADMIN_USERNAME', '$ADMIN_EMAIL', '$ADMIN_PASSWORD')
    print('Superuser created successfully.')
else:
    print('Superuser already exists.')
EOF
fi

echo "Starting command: $@"
exec "$@"
