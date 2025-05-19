#!/usr/bin/env bash

set -e  # Прерывать при ошибках
shopt -s dotglob
shopt -s nullglob

ODOO_REPO="https://github.com/odoo/odoo.git"
ODOO_VERSION="16.0"
SOURCE_DIR="./odoo_source"
DEST_DIR="./odoo"

# Очистим старые исходники
rm -rf "$SOURCE_DIR"
mkdir -p "$SOURCE_DIR"

# Клонируем нужную версию Odoo
echo "Cloning Odoo $ODOO_VERSION from $ODOO_REPO..."
git clone --depth 1 --branch "$ODOO_VERSION" "$ODOO_REPO" "$SOURCE_DIR/odoo"

# Копируем core файлы, исключая папку addons
source_core="$SOURCE_DIR/odoo/odoo/"
dest_core="$DEST_DIR"
rsync -arv --progress "$source_core" "$dest_core" --exclude addons

# Копируем addons из ./addons (в корне репозитория)
source_addons_1="$SOURCE_DIR/odoo/addons/*"
dest_addons_1="$DEST_DIR/addons/"
addons_1=($source_addons_1)
for dir_1 in "${addons_1[@]}"; do
  echo "$dir_1"
  echo "++++++++++++++++++"
  rsync -arv --progress "$dir_1" "$dest_addons_1"
done

# Копируем встроенные addons из ./odoo/addons
source_addons_2="$SOURCE_DIR/odoo/odoo/addons/*"
dest_addons_2="$DEST_DIR/addons/"
addons_2=($source_addons_2)
for dir_2 in "${addons_2[@]}"; do
  echo "$dir_2"
  echo "------------------"
  rsync -arv --progress "$dir_2" "$dest_addons_2"
done
