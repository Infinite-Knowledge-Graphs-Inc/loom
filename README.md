# Loom

Read sources and connect passages into concepts.

## Run

1. `docker compose up -d`
2. Create a [GitHub OAuth App](https://github.com/settings/developers). Homepage `http://localhost:3000`, callback `http://localhost:3000/api/auth/callback/github`.
3. Copy `.env.example` to `.env.local`. Set `AUTH_GITHUB_ID`, `AUTH_GITHUB_SECRET`, and `AUTH_SECRET` (`openssl rand -base64 32`).
4. `pnpm dev`
