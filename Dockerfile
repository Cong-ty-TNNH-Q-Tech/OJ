FROM python:3.11-slim-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git gcc g++ make pkg-config \
    libxml2-dev libxslt1-dev zlib1g-dev gettext curl \
    mariadb-client libmysqlclient-dev default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Install python dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir mysqlclient gunicorn

# Install node dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy project source code
COPY . .

# Collect static files and compile messages
# (We need a mock local_settings.py or dummy db settings to run manage.py without db connection during build)
# Instead, we will do this at entrypoint or handle gracefully. 
# However, make_style.sh and npm run build can be done now.
RUN ./make_style.sh

# Entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "dmoj.wsgi:application"]
