#!/bin/bash

# Wait for the database to be ready
until mysql -h db -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES"; do
  echo "Waiting for database..."
  sleep 5
done

# Check if CRM is already installed
if [ ! -f /var/www/html/storage/crm_installed ]; then
    echo "CRM not installed. Running installation commands..."
    php artisan key:generate
    php artisan storage:link
    php artisan migrate --force
    php artisan laravelcrm:install
    touch /var/www/html/storage/crm_installed  # Create a flag file to avoid reinstallation
else
    echo "CRM already installed. Skipping installation."
fi

# Start Apache in the foreground
apache2-foreground