#!/usr/bin/env bash
set -e

echo "🚀 Setting up Libriary monorepo..."

# Ensure pnpm is available
if ! command -v pnpm &> /dev/null
then
    echo "pnpm could not be found. Please install it first (npm install -g pnpm)."
    exit 1
fi

# Root folder
mkdir -p libriary
cd libriary

# Root package.json
cat > package.json << 'EOF'
{
  "name": "libriary-monorepo",
  "version": "1.0.0",
  "description": "Personal book archiving application",
  "private": true,
  "workspaces": [
    "packages/*"
  ],
  "scripts": {
    "dev": "concurrently \"pnpm run dev:server\" \"pnpm run dev:web\"",
    "dev:server": "cd packages/server && pnpm run dev",
    "dev:web": "cd packages/web && pnpm run start",
    "dev:mobile": "cd packages/mobile && expo start",
    "build": "pnpm run build:server && pnpm run build:web && pnpm run build:mobile",
    "build:server": "cd packages/server && pnpm run build",
    "build:web": "cd packages/web && pnpm run build",
    "build:mobile": "cd packages/mobile && expo build",
    "test": "pnpm run test:server && pnpm run test:web && pnpm run test:mobile",
    "test:server": "cd packages/server && pnpm run test",
    "test:web": "cd packages/web && pnpm run test",
    "test:mobile": "cd packages/mobile && pnpm run test",
    "lint": "pnpm run lint:server && pnpm run lint:web && pnpm run lint:mobile",
    "lint:server": "cd packages/server && pnpm run lint",
    "lint:web": "cd packages/web && pnpm run lint",
    "lint:mobile": "cd packages/mobile && pnpm run lint",
    "docker:up": "docker-compose up -d",
    "docker:down": "docker-compose down",
    "docker:reset": "docker-compose down -v && docker-compose up -d",
    "db:migrate": "cd packages/database && npx prisma migrate dev",
    "db:studio": "cd packages/database && npx prisma studio",
    "db:seed": "cd packages/database && npx prisma db seed",
    "db:reset": "cd packages/database && npx prisma migrate reset",
    "setup": "pnpm install && pnpm run db:migrate && pnpm run db:seed",
    "clean": "rm -rf node_modules packages/*/node_modules packages/*/dist packages/*/build",
    "setup:dev": "bash scripts/setup-dev.sh"
  },
  "devDependencies": {
    "concurrently": "^8.2.2",
    "@typescript-eslint/eslint-plugin": "^6.7.4",
    "@typescript-eslint/parser": "^6.7.4",
    "eslint": "^8.51.0",
    "eslint-config-prettier": "^9.0.0",
    "eslint-plugin-prettier": "^5.0.0",
    "prettier": "^3.0.3",
    "typescript": "^5.2.2"
  },
  "engines": {
    "node": ">=18.0.0",
    "pnpm": ">=8.0.0"
  },
  "packageManager": "pnpm@8.0.0"
}
EOF

# Root .gitignore
cat > .gitignore << 'EOF'
node_modules/
.pnpm-store/
build/
dist/
.next/
*.tsbuildinfo
.env*
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db
desktop.ini
*.log
coverage/
tmp/
temp/
uploads/
web-build/
EOF

# Root env example
cat > .env.example << 'EOF'
DATABASE_URL=postgresql://libriary:libriary@localhost:5432/libriary
JWT_SECRET=changeme
REDIS_URL=redis://localhost:6379
PORT=3001
EOF

# Directories
mkdir -p packages/web packages/mobile packages/server packages/shared packages/database scripts

# Docker compose
cat > docker-compose.yml << 'EOF'
version: '3.9'
services:
  db:
    image: postgres:15
    restart: always
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: libriary
      POSTGRES_PASSWORD: libriary
      POSTGRES_DB: libriary
    volumes:
      - db-data:/var/lib/postgresql/data
  redis:
    image: redis:7
    restart: always
    ports:
      - "6379:6379"
volumes:
  db-data:
EOF

# GitHub Actions workflow
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << 'EOF'
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
        with:
          version: 8
      - run: pnpm install
      - run: pnpm run lint
      - run: pnpm run test
      - run: pnpm run build
EOF

# Install all dependencies once
pnpm install

echo "✅ Libriary monorepo setup complete!"
