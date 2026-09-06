import os

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

DEBUG = True

ALLOWED_HOSTS = ['*']

# Database configuration from environment variables
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('DB_NAME', 'dmoj'),
        'USER': os.environ.get('DB_USER', 'dmoj'),
        'PASSWORD': os.environ.get('DB_PASSWORD', 'dmoj_password'),
        'HOST': os.environ.get('DB_HOST', '127.0.0.1'),
        'PORT': os.environ.get('DB_PORT', '3306'),
        'OPTIONS': {
            'charset': 'utf8mb4',
            'sql_mode': 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION',
        }
    }
}

# Redis configuration from environment variables
REDIS_HOST = os.environ.get('REDIS_HOST', '127.0.0.1')
REDIS_PORT = os.environ.get('REDIS_PORT', '6379')

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': f'redis://{REDIS_HOST}:{REDIS_PORT}/0',
    }
}

# Celery configuration
CELERY_BROKER_URL = f'redis://{REDIS_HOST}:{REDIS_PORT}/1'
CELERY_RESULT_BACKEND = f'redis://{REDIS_HOST}:{REDIS_PORT}/2'

# Static files
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATIC_URL = '/static/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Add required bridging settings (if any needed for celery/judge)
# DMOJ_JUDGE_AUTH_KEY = 'secret'

# Email configuration
EMAIL_BACKEND = os.environ.get('EMAIL_BACKEND', 'django.core.mail.backends.console.EmailBackend')
EMAIL_HOST = os.environ.get('EMAIL_HOST', 'localhost')
_ep = os.environ.get('EMAIL_PORT', '')
EMAIL_PORT = int(_ep) if _ep else 25
EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', '')
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', '')
EMAIL_USE_TLS = os.environ.get('EMAIL_USE_TLS', 'False') == 'True'
DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL', 'webmaster@localhost')

# Site info
SITE_NAME = os.environ.get('SITE_NAME', 'ICTU JUDGE')
SITE_LONG_NAME = os.environ.get('SITE_LONG_NAME', 'ICTU JUDGE')



DMOJ_CANONICAL = os.environ.get('DMOJ_CANONICAL', 'localhost:5000')
SITE_FULL_URL = ('https://' if 'https' in os.environ.get('CSRF_TRUSTED_ORIGINS', '') else 'http://') + DMOJ_CANONICAL

csrf_trusted = os.environ.get('CSRF_TRUSTED_ORIGINS', '')
if csrf_trusted:
    CSRF_TRUSTED_ORIGINS = csrf_trusted.split(',')
else:
    CSRF_TRUSTED_ORIGINS = [f'https://{DMOJ_CANONICAL}', f'http://{DMOJ_CANONICAL}']

# Problem data mapping
DMOJ_PROBLEM_DATA_ROOT = '/problems'

# Bridge config
BRIDGED_JUDGE_ADDRESS = [('0.0.0.0', 9999)]
BRIDGED_DJANGO_CONNECT = ('bridge', 9998)

BRIDGED_DJANGO_ADDRESS = [('0.0.0.0', 9998)]
