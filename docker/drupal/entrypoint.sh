#!/bin/bash
set -e

echo "✅ Container booted!"

# Debug: show contents of Drupal directory
echo "📂 Listing /var/www/html/web/"
ls -lah /var/www/html/web || echo "❌ /var/www/html/web not found"

# Debug: check settings.php
if [ -f /var/www/html/web/sites/default/settings.php ]; then
  echo "✅ settings.php found!"
else
  echo "❌ settings.php is missing!"
fi

# Fix EFS permissions
echo "🔒 Fixing permissions on files/"
if [ -d /var/www/html/web/sites/default/files ]; then
  chown -R www-data:www-data /var/www/html/web/sites/default/files
else
  echo "⚠️ files/ directory not found!"
fi

echo "🚀 Starting Apache..."
exec "$@"
