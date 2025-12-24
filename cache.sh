
# Создаем временный файл с командами для telnet
cat > /tmp/memcached_commands.txt << 'EOF'
set temp_key1 0 5 11
hello_world1
set temp_key2 0 5 11
hello_world2
set temp_key3 0 5 11
hello_world3
get temp_key1
get temp_key2
get temp_key3
EOF

echo "=== Шаг 1: Записываем ключи с TTL 5 секунд ==="
echo "Выполняем команды записи..."
cat /tmp/memcached_commands.txt

echo ""
echo "=== Шаг 2: Проверяем ключи сразу после записи ==="
{
  # Записываем ключи
  echo "set temp_key1 0 5 12"
  echo "hello_world1"
  echo "set temp_key2 0 5 12"
  echo "hello_world2"
  echo "set temp_key3 0 5 12"
  echo "hello_world3"
  
  # Проверяем сразу
  sleep 1
  echo "get temp_key1"
  echo "get temp_key2"
  echo "get temp_key3"
} | telnet 127.0.0.1 11211 2>&1 | grep -A 20 "Connected"

echo ""
echo "=== Шаг 3: Ждем 5 секунд... ==="
for i in {5..1}; do
  echo -ne "Осталось: ${i} секунд\r"
  sleep 1
done
echo ""

echo "=== Шаг 4: Проверяем ключи через 5 секунд ==="
{
  echo "get temp_key1"
  echo "get temp_key2"
  echo "get temp_key3"
} | telnet 127.0.0.1 11211 2>&1 | grep -A 20 "Connected"

# Удаляем временный файл
rm -f /tmp/memcached_commands.txt

echo ""
echo "=== Тест завершен ==="
echo "Если в Шаге 4 вы не видите значений ключей, значит TTL сработал корректно."