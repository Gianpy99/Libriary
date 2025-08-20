#!/usr/bin/env bash
set -e

echo "🚀 Setting up Libriary monorepo..."

# Root folder
mkdir -p libriary
cd libriary

# Root package.json
cat <<'EOF' > package.json
{
  "name": "libriary-monorepo",
  "version": "1.0.0",
  "description": "Personal book archiving application",
  "private": true,
  "workspaces": ["packages/*"],
  "scripts": {
    "dev": "concurrently \"pnpm run dev:server\" \"pnpm run dev:web\"",
    "dev:server": "cd packages/server && pnpm run dev",
    "dev:web": "cd packages/web && pnpm run start",
    "dev:mobile": "cd packages/mobile && expo start",
    "build": "pnpm run build:server && pnpm run build:web",
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

# .gitignore
cat <<'EOF' > .gitignore
node_modules/
.pnpm-store/
build/
dist/
.next/
*.tsbuildinfo
.env*
.vscode/
.idea/
*.log
coverage/
.cache
.parcel-cache
tmp/
temp/
*.db
*.sqlite*
uploads/
.DS_Store
Thumbs.db
desktop.ini
EOF

# .env.example
cat <<'EOF' > .env.example
DATABASE_URL=postgresql://libriary:libriary@localhost:5432/libriary
JWT_SECRET=changeme
REDIS_URL=redis://localhost:6379
EOF

# Docker Compose
cat <<'EOF' > docker-compose.yml
version: '3.9'
services:
  db:
    image: postgres:15
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
    ports:
      - "6379:6379"
volumes:
  db-data:
EOF

# CI Workflow
mkdir -p .github/workflows
cat <<'EOF' > .github/workflows/ci.yml
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

# Packages
mkdir -p packages/{shared,database,server,web,mobile} scripts

# Shared package
cat <<'EOF' > packages/shared/package.json
{
  "name": "@libriary/shared",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "clean": "rm -rf dist"
  },
  "devDependencies": { "typescript": "^5.2.2" }
}
EOF

mkdir -p packages/shared/src/{types,utils}
echo "export interface User { id: string; email: string; }" > packages/shared/src/types/index.ts
echo "export const generateId = () => Date.now().toString();" > packages/shared/src/utils/index.ts
echo "export * from './types'; export * from './utils';" > packages/shared/src/index.ts

cat <<'EOF' > packages/shared/tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# Database package
cat <<'EOF' > packages/database/package.json
{
  "name": "@libriary/database",
  "version": "1.0.0",
  "scripts": {
    "migrate": "prisma migrate dev",
    "studio": "prisma studio",
    "seed": "tsx seed/index.ts",
    "reset": "prisma migrate reset",
    "generate": "prisma generate",
    "deploy": "prisma migrate deploy",
    "postinstall": "prisma generate"
  },
  "dependencies": { "@prisma/client": "^5.4.2" },
  "devDependencies": { "prisma": "^5.4.2", "tsx": "^3.13.0" }
}
EOF

mkdir -p packages/database/{prisma,seed}
echo "datasource db { provider = \"postgresql\" url = env(\"DATABASE_URL\") }" > packages/database/prisma/schema.prisma
echo "console.log('🌱 seeding...');" > packages/database/seed/index.ts

# Server package
cat <<'EOF' > packages/server/package.json
{
  "name": "@libriary/server",
  "version": "1.0.0",
  "main": "dist/index.js",
  "scripts": {
    "dev": "nodemon --watch src --exec tsx src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "lint": "eslint src/**/*.ts"
  },
  "dependencies": {
    "@libriary/shared": "workspace:*",
    "@libriary/database": "workspace:*",
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "typescript": "^5.2.2",
    "tsx": "^3.13.0",
    "jest": "^29.7.0",
    "@types/express": "^4.17.17"
  }
}
EOF

mkdir -p packages/server/src
cat <<'EOF' > packages/server/src/index.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

const app = express();
const PORT = process.env.PORT || 3001;

app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

app.get('/health', (_, res) => res.json({ status: 'ok' }));

app.listen(PORT, () => console.log(`🚀 Server running on http://localhost:${PORT}`));
EOF

cat <<'EOF' > packages/server/tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
EOF

# Web package
cat <<'EOF' > packages/web/package.json
{
  "name": "@libriary/web",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@libriary/shared": "workspace:*",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "typescript": "^4.9.5",
    "tailwindcss": "^3.3.3",
    "autoprefixer": "^10.4.15",
    "postcss": "^8.4.29"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "lint": "eslint src/**/*.{ts,tsx}"
  }
}
EOF

mkdir -p packages/web/src
cat <<'EOF' > packages/web/src/index.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);
root.render(<App />);
EOF

cat <<'EOF' > packages/web/src/App.tsx
import React from 'react';

function App() {
  return <h1>📚 Libriary Web</h1>;
}
export default App;
EOF

echo "body { font-family: sans-serif; }" > packages/web/src/index.css

cat <<'EOF' > packages/web/tsconfig.json
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "strict": true,
    "module": "esnext",
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
EOF

# Mobile package
cat <<'EOF' > packages/mobile/package.json
{
  "name": "@libriary/mobile",
  "version": "1.0.0",
  "private": true,
  "main": "index.js",
  "dependencies": {
    "expo": "^49.0.0",
    "react": "18.2.0",
    "react-native": "0.72.0"
  },
  "scripts": {
    "start": "expo start",
    "android": "expo run:android",
    "ios": "expo run:ios",
    "web": "expo start --web"
  }
}
EOF

cat <<'EOF' > packages/mobile/App.tsx
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View } from 'react-native';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>📚 Libriary Mobile</Text>
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
EOF

echo "✅ Libriary monorepo setup complete! Run 'pnpm install' to bootstrap."
