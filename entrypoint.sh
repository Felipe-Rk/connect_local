#!/bin/bash
set -e

echo "🔄 Aguardando banco de dados em $DB_HOST..."

until pg_isready -h "$DB_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  >&2 echo "🚫 Banco ainda não está pronto - aguardando..."
  sleep 2
done

echo "✅ Banco disponível, rodando migrations..."
bundle exec rails db:migrate

echo "🚀 Iniciando servidor Puma..."
exec bundle exec puma -C config/puma.rb
