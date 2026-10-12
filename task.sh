#!/bin/bash

# Перевірка наявності необхідних змінних оточення
if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    echo "Помилка: Змінні оточення DB_USER або DB_PASSWORD не встановлені!"
    exit 1
fi

# Етап 1: Повний бекап ShopDB та повне відновлення у ShopDBReserve
# Використовуємо --single-transaction для уникнення блокування продакшн-таблиць
mysqldump -u "$DB_USER" -p"$DB_PASSWORD" --single-transaction ShopDB > full_backup.sql

# Відновлюємо всю базу (структуру та дані) в резервну копію
mysql -u "$DB_USER" -p"$DB_PASSWORD" ShopDBReserve < full_backup.sql


# Етап 2: Бекап ТІЛЬКИ ДАНИХ з ShopDB та відновлення у ShopDBDevelopment
# Прапорець --no-create-info (-t) виключає інструкції CREATE TABLE з дампу
mysqldump -u "$DB_USER" -p"$DB_PASSWORD" --single-transaction --no-create-info ShopDB > data_only_backup.sql

# Накатуємо чисті дані в базу розробки (де структура вже має бути створена)
mysql -u "$DB_USER" -p"$DB_PASSWORD" ShopDBDevelopment < data_only_backup.sql


# Очищення тимчасових файлів бекапу на диску
rm full_backup.sql data_only_backup.sql

echo "Процедуру нічного бекапу та синхронізації успішно завершено!"
