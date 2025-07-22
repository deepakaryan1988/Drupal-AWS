#!/bin/bash
set -e

echo "✅ Container booted!"

# Debug: show contents of Drupal directory
echo "📂 Listing /var/www/html/web/"
ls -lah /var/www/html/web || echo "❌ /var/www/html/web not found"

SETTINGS_DIR="/var/www/html/web/sites/default"
SETTINGS_FILE="$SETTINGS_DIR/settings.php"

# Create settings.php BEFORE EFS mounts anything
echo "📄 Ensuring settings.php exists BEFORE EFS mount..."
mkdir -p "$SETTINGS_DIR"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "⚠️ settings.php missing! Creating an empty file."
  touch "$SETTINGS_FILE"
fi

echo "🔒 Fixing ownership and permissions for settings.php"
chown www-data:www-data "$SETTINGS_FILE"
chmod 664 "$SETTINGS_FILE"

# Now fix files/ directory (EFS mount)
echo "🔒 Fixing permissions on files/"
if [ -d "$SETTINGS_DIR/files" ]; then
  chown -R www-data:www-data "$SETTINGS_DIR/files"
  chmod -R 775 "$SETTINGS_DIR/files"
else
  echo "⚠️ files/ directory not found!"
fi

echo "🚀 Starting Apache..."
exec "$@"
