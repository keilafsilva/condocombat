from app.config.settings import Settings


def test_settings_builds_database_url_from_component_env(monkeypatch):
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.setenv("DB_HOST", "localhost")
    monkeypatch.setenv("DB_PORT", "5433")
    monkeypatch.setenv("DB_NAME", "condocombat_test")
    monkeypatch.setenv("DB_USER", "test_user")
    monkeypatch.setenv("DB_PASSWORD", "test_pass")

    settings = Settings(_env_file=None)

    assert settings.DATABASE_URL == (
        "postgresql+asyncpg://test_user:test_pass@localhost:5433/condocombat_test"
    )


def test_settings_normalizes_render_and_supabase_database_urls(monkeypatch):
    monkeypatch.setenv(
        "DATABASE_URL",
        "postgresql://postgres:secret@db.example.supabase.co:5432/postgres?sslmode=require",
    )

    settings = Settings(_env_file=None)

    assert settings.DATABASE_URL == (
        "postgresql+asyncpg://postgres:secret@db.example.supabase.co:5432/postgres?sslmode=require"
    )
