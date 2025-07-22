#!/bin/bash
set -e

echo "✅ Container booted!"

# Debug: show contents of Drupal directory
echo "📂 Listing /var/www/html/web/"
ls -lah /var/www/html/web || echo "❌ /var/www/html/web not found"

# Ensure settings.php exists and is writable
SETTINGS_FILE="/var/www/html/web/sites/default/settings.php"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "⚠️ settings.php missing! Creating an empty file."
  touch "$SETTINGS_FILE"
fi

echo "🔒 Fixing ownership and permissions for settings.php"
chown www-data:www-data "$SETTINGS_FILE"
chmod 664 "$SETTINGS_FILE"

# Fix files/ directory
echo "🔒 Fixing permissions on files/"
if [ -d /var/www/html/web/sites/default/files ]; then
  chown -R www-data:www-data /var/www/html/web/sites/default/files
  chmod -R 775 /var/www/html/web/sites/default/files
else
  echo "⚠️ files/ directory not found!"
fi

echo "🚀 Starting Apache..."
exec "$@"
