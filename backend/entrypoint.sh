#!/bin/bash
set -e

# Valida SECRET_KEY obrigatória
if [ -z "$SECRET_KEY" ]; then
    echo "❌ ERRO: SECRET_KEY não está definida!"
    echo "   Gere uma com: python -c 'import secrets; print(secrets.token_urlsafe(32))'"
    exit 1
fi

echo "🔧 Rodando migrations do Alembic..."

max_attempts=12
attempt=1
sleep_seconds=5

while true; do
    if alembic upgrade head; then
        break
    fi

    if [ "$attempt" -ge "$max_attempts" ]; then
        echo "❌ ERRO: Alembic não conseguiu conectar ao banco após ${max_attempts} tentativas."
        exit 1
    fi

    echo "⚠️  Banco ainda indisponível. Aguardando ${sleep_seconds}s antes da próxima tentativa (${attempt}/${max_attempts})..."
    sleep "$sleep_seconds"
    attempt=$((attempt + 1))

    if [ "$sleep_seconds" -lt 30 ]; then
        sleep_seconds=$((sleep_seconds * 2))
        if [ "$sleep_seconds" -gt 30 ]; then
            sleep_seconds=30
        fi
    fi
done

echo "🚀 Iniciando servidor FastAPI..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
