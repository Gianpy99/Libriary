# Libriary Monorepo Setup Script for Windows
# Run this in PowerShell as Administrator

Write-Host "🚀 Setting up Libriary monorepo for Windows..." -ForegroundColor Blue

# Create root directory and navigate
New-Item -ItemType Directory -Path "libriary" -Force
Set-Location "libriary"

# Create root package.json
$packageJson = @"
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
    "clean": "powershell -Command \"Remove-Item -Recurse -Force node_modules, packages/*/node_modules, packages/*/build, packages/*/dist -ErrorAction SilentlyContinue\"",
    "setup:dev": "powershell -ExecutionPolicy Bypass -File scripts/setup-dev.ps1"
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
"@
$packageJson | Out-File -FilePath "package.json" -Encoding UTF8

# Create .gitignore
$gitignore = @"
# Dependencies
node_modules/
.pnpm-store/

# Build outputs
build/
dist/
.next/
*.tsbuildinfo

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
desktop.ini

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# Next.js build output
.next
out/

# Nuxt.js build / generate output
.nuxt

# Storybook build outputs
.out
.storybook-out

# Temporary folders
tmp/
temp/

# Database
*.db
*.sqlite
*.sqlite3

# Expo
.expo/
expo-env.d.ts

# React Native
*.jks
*.p8
*.p12
*.key
*.mobileprovision
*.orig.*
web-build/

# Windows specific
*.exe
*.msi
*.cab
*.msm
*.msp

# Docker
.dockerignore

# Uploads directory (development)
uploads/
"@
$gitignore | Out-File -FilePath ".gitignore" -Encoding UTF8

# Create packages directory structure
New-Item -ItemType Directory -Path "packages\web" -Force
New-Item -ItemType Directory -Path "packages\mobile" -Force
New-Item -ItemType Directory -Path "packages\server" -Force
New-Item -ItemType Directory -Path "packages\shared" -Force
New-Item -ItemType Directory -Path "packages\database" -Force
New-Item -ItemType Directory -Path "scripts" -Force

Write-Host "📁 Created package directories" -ForegroundColor Green

# Create shared package
Set-Location "packages\shared"
$sharedPackageJson = @"
{
  "name": "@libriary/shared",
  "version": "1.0.0",
  "description": "Shared types and utilities for Libriary",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "clean": "powershell -Command \"Remove-Item -Recurse -Force dist -ErrorAction SilentlyContinue\""
  },
  "devDependencies": {
    "typescript": "^5.2.2"
  }
}
"@
$sharedPackageJson | Out-File -FilePath "package.json" -Encoding UTF8

New-Item -ItemType Directory -Path "src\types" -Force
New-Item -ItemType Directory -Path "src\utils" -Force

$sharedTypes = @"
export interface User {
  id: string;
  email: string;
  name: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Book {
  id: string;
  title: string;
  author?: string;
  isbn?: string;
  edition?: string;
  printSerial?: string;
  publisher?: string;
  publicationYear?: number;
  genre?: string;
  notes?: string;
  tags: string[];
  createdAt: Date;
  updatedAt: Date;
  userId: string;
  photos: Photo[];
}

export interface Photo {
  id: string;
  filename: string;
  path: string;
  type: PhotoType;
  bookId: string;
  createdAt: Date;
}

export enum PhotoType {
  COVER = 'COVER',
  SPINE = 'SPINE',
  BACK = 'BACK',
  INTERNAL = 'INTERNAL'
}

export interface BookMetadata {
  title?: string;
  author?: string;
  isbn?: string;
  edition?: string;
  publisher?: string;
  publicationYear?: number;
}

export interface OCRResult {
  text: string;
  confidence: number;
  metadata?: BookMetadata;
}

export interface APIResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginationParams {
  page: number;
  limit: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface SearchParams extends PaginationParams {
  query?: string;
  author?: string;
  genre?: string;
  tags?: string[];
  yearFrom?: number;
  yearTo?: number;
}
"@
$sharedTypes | Out-File -FilePath "src\types\index.ts" -Encoding UTF8

$sharedUtils = @"
export const formatDate = (date: Date): string => {
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  }).format(date);
};

export const generateId = (): string => {
  return Math.random().toString(36).substring(2) + Date.now().toString(36);
};

export const validateISBN = (isbn: string): boolean => {
  const cleaned = isbn.replace(/[-\s]/g, '');
  return /^(97[89])?\d{10}$/.test(cleaned);
};

export const extractISBN = (text: string): string | null => {
  const isbnRegex = /(?:ISBN(?:-1[03])?:?\s*)?(?=[-0-9\s]{10,}|[-0-9X\s]{10,}|[0-9X]{10,13})(?:97[89][-\s]?)?[0-9][-\s]?[0-9][-\s]?[0-9][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X]?/gi;
  const matches = text.match(isbnRegex);
  return matches ? matches[0].replace(/[-\s]/g, '') : null;
};

export const capitalizeWords = (str: string): string => {
  return str.replace(/\w\S*/g, (txt) => 
    txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
  );
};

export const cleanText = (text: string): string => {
  return text.replace(/\s+/g, ' ').trim();
};
"@
$sharedUtils | Out-File -FilePath "src\utils\index.ts" -Encoding UTF8

$sharedIndex = @"
export * from './types';
export * from './utils';
"@
$sharedIndex | Out-File -FilePath "src\index.ts" -Encoding UTF8

$sharedTsConfig = @"
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
"@
$sharedTsConfig | Out-File -FilePath "tsconfig.json" -Encoding UTF8

# Navigate back to packages for database setup
Set-Location "..\database"

$databasePackageJson = @"
{
  "name": "@libriary/database",
  "version": "1.0.0",
  "description": "Database schema and migrations for Libriary",
  "scripts": {
    "migrate": "prisma migrate dev",
    "studio": "prisma studio",
    "seed": "tsx seed/index.ts",
    "reset": "prisma migrate reset",
    "generate": "prisma generate",
    "deploy": "prisma migrate deploy"
  },
  "dependencies": {
    "@prisma/client": "^5.4.2",
    "bcryptjs": "^2.4.3"
  },
  "devDependencies": {
    "prisma": "^5.4.2",
    "tsx": "^3.13.0",
    "@types/bcryptjs": "^2.4.4"
  },
  "prisma": {
    "seed": "tsx seed/index.ts"
  }
}
"@
$databasePackageJson | Out-File -FilePath "package.json" -Encoding UTF8

New-Item -ItemType Directory -Path "prisma" -Force
New-Item -ItemType Directory -Path "seed" -Force

$prismaSchema = @"
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  password  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  books     Book[]

  @@map("users")
}

model Book {
  id              String    @id @default(cuid())
  title           String
  author          String?
  isbn            String?   @unique
  edition         String?
  printSerial     String?
  publisher       String?
  publicationYear Int?
  genre           String?
  notes           String?
  tags            String[]
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  userId          String
  user            User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  photos          Photo[]

  @@map("books")
}

model Photo {
  id        String    @id @default(cuid())
  filename  String
  path      String
  type      PhotoType
  size      Int?
  mimeType  String?
  bookId    String
  book      Book      @relation(fields: [bookId], references: [id], onDelete: Cascade)
  createdAt DateTime  @default(now())

  @@map("photos")
}

enum PhotoType {
  COVER
  SPINE
  BACK
  INTERNAL
}

model OCRJob {
  id        String    @id @default(cuid())
  photoId   String
  status    JobStatus @default(PENDING)
  result    Json?
  error     String?
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt

  @@map("ocr_jobs")
}

enum JobStatus {
  PENDING
  PROCESSING
  COMPLETED
  FAILED
}
"@
$prismaSchema | Out-File -FilePath "prisma\schema.prisma" -Encoding UTF8

$seedScript = @"
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // Create demo user
  const hashedPassword = await bcrypt.hash('demo123', 12);
  
  const demoUser = await prisma.user.upsert({
    where: { email: 'demo@libriary.com' },
    update: {},
    create: {
      email: 'demo@libriary.com',
      name: 'Demo User',
      password: hashedPassword,
    },
  });

  console.log('👤 Created demo user:', demoUser.email);

  // Create sample books
  const sampleBooks = [
    {
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      isbn: '9780743273565',
      publisher: 'Scribner',
      publicationYear: 1925,
      genre: 'Classic Fiction',
      tags: ['american literature', 'classic', '1920s'],
    },
    {
      title: '1984',
      author: 'George Orwell',
      isbn: '9780451524935',
      publisher: 'Signet Classics',
      publicationYear: 1949,
      genre: 'Dystopian Fiction',
      tags: ['dystopian', 'political', 'classic'],
    },
    {
      title: 'To Kill a Mockingbird',
      author: 'Harper Lee',
      isbn: '9780446310789',
      publisher: 'Grand Central Publishing',
      publicationYear: 1960,
      genre: 'Literary Fiction',
      tags: ['social issues', 'american literature', 'classic'],
    }
  ];

  for (const bookData of sampleBooks) {
    const book = await prisma.book.upsert({
      where: { isbn: bookData.isbn },
      update: {},
      create: {
        ...bookData,
        userId: demoUser.id,
      },
    });
    console.log('📚 Created sample book:', book.title);
  }

  console.log('✅ Database seed completed!');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error('❌ Seed error:', e);
    await prisma.$disconnect();
    process.exit(1);
  });
"@
$seedScript | Out-File -FilePath "seed\index.ts" -Encoding UTF8

# Navigate back to packages for server setup
Set-Location "..\server"

$serverPackageJson = @"
{
  "name": "@libriary/server",
  "version": "1.0.0",
  "description": "Libriary backend API server",
  "main": "dist/index.js",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "clean": "powershell -Command \"Remove-Item -Recurse -Force dist -ErrorAction SilentlyContinue\""
  },
  "dependencies": {
    "@libriary/shared": "workspace:*",
    "@libriary/database": "workspace:*",
    "@prisma/client": "^5.4.2",
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "multer": "^1.4.5-lts.1",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "joi": "^17.10.2",
    "dotenv": "^16.3.1",
    "sharp": "^0.32.6",
    "tesseract.js": "^5.0.2",
    "bull": "^4.11.4",
    "redis": "^4.6.10"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.14",
    "@types/morgan": "^1.9.5",
    "@types/multer": "^1.4.8",
    "@types/jsonwebtoken": "^9.0.3",
    "@types/bcryptjs": "^2.4.4",
    "@types/node": "^20.6.3",
    "typescript": "^5.2.2",
    "tsx": "^3.13.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.5"
  }
}
"@
$serverPackageJson | Out-File -FilePath "package.json" -Encoding UTF8

New-Item -ItemType Directory -Path "src\controllers" -Force
New-Item -ItemType Directory -Path "src\middleware" -Force
New-Item -ItemType Directory -Path "src\routes" -Force
New-Item -ItemType Directory -Path "src\services" -Force
New-Item -ItemType Directory -Path "src\utils" -Force
New-Item -ItemType Directory -Path "src\config" -Force

$serverIndex = @"
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';

dotenv.config();

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.get('/api/test', (req, res) => {
  res.json({ message: 'Libriary API is running!' });
});

// Error handling middleware
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully');
  await prisma.$disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received, shutting down gracefully');
  await prisma.$disconnect();
  process.exit(0);
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📚 Libriary API ready!`);
});
"@
$serverIndex | Out-File -FilePath "src\index.ts" -Encoding UTF8

$serverTsConfig = @"
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
"@
$serverTsConfig | Out-File -FilePath "tsconfig.json" -Encoding UTF8

# Navigate back to packages for web setup
Set-Location "..\web"

$webPackageJson = @"
{
  "name": "@libriary/web",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@libriary/shared": "workspace:*",
    "@testing-library/jest-dom": "^5.17.0",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^14.4.3",
    "@types/jest": "^27.5.2",
    "@types/node": "^16.18.50",
    "@types/react": "^18.2.21",
    "@types/react-dom": "^18.2.7",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "typescript": "^4.9.5",
    "web-vitals": "^2.1.4",
    "react-router-dom": "^6.15.0",
    "axios": "^1.5.0",
    "tesseract.js": "^5.0.2",
    "react-dropzone": "^14.2.3",
    "@headlessui/react": "^1.7.17",
    "@heroicons/react": "^2.0.18",
    "tailwindcss": "^3.3.3",
    "autoprefixer": "^10.4.15",
    "postcss": "^8.4.29"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "lint": "eslint src/**/*.{ts,tsx}",
    "lint:fix": "eslint src/**/*.{ts,tsx} --fix"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  },
  "proxy": "http://localhost:3001"
}
"@
$webPackageJson | Out-File -FilePath "package.json" -Encoding UTF8

New-Item -ItemType Directory -Path "src\components" -Force
New-Item -ItemType Directory -Path "src\pages" -Force
New-Item -ItemType Directory -Path "src\services" -Force
New-Item -ItemType Directory -Path "src\hooks" -Force
New-Item -ItemType Directory -Path "src\utils" -Force
New-Item -ItemType Directory -Path "public" -Force

$webIndex = @"
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
"@
$webIndex | Out-File -FilePath "src\index.tsx" -Encoding UTF8

$webApp = @"
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import './App.css';

function App() {
  return (
    <Router>
      <div className="App">
        <header className="App-header">
          <h1>📚 Libriary</h1>
          <p>Personal Book Archive</p>
        </header>
        <main>
          <Routes>
            <Route path="/" element={<div>Welcome to Libriary!</div>} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;
"@
$webApp | Out-File -FilePath "src\App.tsx" -Encoding UTF8

$webCSS = @"
.App {
  text-align: center;
}

.App-header {
  background-color: #282c34;
  padding: 20px;
  color: white;
}

.App-header h1 {
  margin: 0 0 10px 0;
  font-size: 2.5rem;
}

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}
"@
$webCSS | Out-File -FilePath "src\App.css" -Encoding UTF8

$webIndexCSS = @"
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}
"@
$webIndexCSS | Out-File -FilePath "src\index.css" -Encoding UTF8

$webTsConfig = @"
{
  "compilerOptions": {
    "target": "es5",
    "lib": [
      "dom",
      "dom.iterable",
      "es6"
    ],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": [
    "src"
  ]
}
"@
$webTsConfig | Out-File -FilePath "tsconfig.json" -Encoding UTF8

$publicIndex = @"
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <title>Libriary</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
"@
$publicIndex | Out-File -FilePath "public\index.html" -Encoding UTF8

# Navigate back to packages for mobile setup
Set-Location "..\mobile"

$mobilePackageJson = @"
{
  "name": "@libriary/mobile",
  "version": "1.0.0",
  "private": true,
  "main": "index.js",
  "scripts": {
    "start": "expo start",
    "android": "expo run:android",
    "ios": "expo run:ios",
    "web": "expo start --web",
    "lint": "eslint src/**/*.{ts,tsx}",
    "lint:fix": "eslint src/**/*.{ts,tsx} --fix"
  },
  "dependencies": {
    "@libriary/shared": "workspace:*",
    "expo": "^50.0.0",
    "expo-camera": "~14.0.0",
    "expo-status-bar": "~2.0.0",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "react-native": "0.73.0",
    "react-native-web": "~0.19.6",
    "react-navigation": "^4.4.4",
    "react-router-native": "^6.15.0",
    "axios": "^1.5.0"
  },
  "devDependencies": {
    "typescript": "^5.2.2",
    "@types/react": "^18.2.21",
    "@types/react-native": "^0.72.0",
    "eslint": "^8.51.0"
  }
}
"@
$mobilePackageJson | Out-File -FilePath "package.json" -Encoding UTF8

New-Item -ItemType Directory -Path "src\components" -Force
New-Item -ItemType Directory -Path "src\screens" -Force
New-Item -ItemType Directory -Path "src\navigation" -Force
New-Item -ItemType Directory -Path "assets" -Force

$mobileApp = @"
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { View, Text } from 'react-native';

const Stack = createNativeStackNavigator();

function HomeScreen() {
  return (
    <View style={{flex:1,justifyContent:'center',alignItems:'center'}}>
      <Text>📚 Libriary Mobile</Text>
    </View>
  );
}

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
"@
$mobileApp | Out-File -FilePath "App.tsx" -Encoding UTF8

Write-Host "📱 Mobile package created" -ForegroundColor Green

# Navigate back to root to create docker-compose.yml
Set-Location "../.."

$dockerCompose = @"
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: libriary
      POSTGRES_USER: libriary
      POSTGRES_PASSWORD: dev_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7
    ports:
      - "6379:6379"

  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data

volumes:
  postgres_data:
  minio_data:
"@
$dockerCompose | Out-File -FilePath "docker-compose.yml" -Encoding UTF8

# Create README.md
$readme = @"
# Libriary Monorepo

📚 **Libriary** is a personal book archiving application with web, mobile, and backend services in a monorepo.

## Tech Stack
- React 18 + TypeScript (Web)
- React Native + Expo (Mobile)
- Node.js + Express + TypeScript (Backend)
- PostgreSQL + Prisma ORM (Database)
- Redis (Queue), MinIO (S3-compatible storage)
- OCR: Tesseract.js (client) + Google Vision API (server)

## Structure
\`\`\`
libriary/
├── packages/
│   ├── web/        # React web app
│   ├── mobile/     # React Native app
│   ├── server/     # Node.js backend
│   ├── shared/     # Shared types and utils
│   └── database/   # Prisma schema and seeds
├── docker-compose.yml
└── package.json
\`\`\`

## Setup
\`\`\`bash
pnpm install
pnpm run docker:up
pnpm run db:migrate
pnpm run dev
\`\`\`

See [libriary_dev_plan.md](./libriary_dev_plan.md) for detailed architecture.
"@
$readme | Out-File -FilePath "README.md" -Encoding UTF8

Write-Host "✅ Monorepo setup completed!" -ForegroundColor Green



# ===============================
# CONTINUE: add API (auth + books)
# ===============================

Write-Host "🧩 Adding API (auth + books) to @libriary/server..." -ForegroundColor Blue
Set-Location "packages\server"

# ---- env example & uploads folder
$serverEnv = @"
# Server
PORT=3001
NODE_ENV=development
# JWT
JWT_SECRET=super-secret-dev-token
JWT_EXPIRES_IN=7d
# Database (used by packages/database Prisma; server reads via @prisma/client)
DATABASE_URL=postgresql://libriary:dev_password@localhost:5432/libriary?schema=public
# Files
UPLOADS_DIR=uploads
"@
$serverEnv | Out-File -FilePath ".env.example" -Encoding UTF8
New-Item -ItemType Directory -Path "uploads" -Force | Out-Null

# ---- utils/jwt.ts
$jwtUtil = @"
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'change-me';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

export interface JwtPayload {
  sub: string; // user id
  email: string;
}

export const signToken = (payload: JwtPayload) =>
  jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

export const verifyToken = (token: string) =>
  jwt.verify(token, JWT_SECRET) as JwtPayload;
"@
$null = New-Item -ItemType Directory -Path "src\utils" -Force
$jwtUtil | Out-File -FilePath "src\utils\jwt.ts" -Encoding UTF8

# ---- middleware/auth.ts
$authMw = @"
import type { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../utils/jwt';

export interface AuthedRequest extends Request {
  user?: { id: string; email: string };
}

export const requireAuth = (req: AuthedRequest, res: Response, next: NextFunction) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Missing token' });

  try {
    const payload = verifyToken(token);
    req.user = { id: payload.sub, email: payload.email };
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid/expired token' });
  }
};
"@
$null = New-Item -ItemType Directory -Path "src\middleware" -Force
$authMw | Out-File -FilePath "src\middleware\auth.ts" -Encoding UTF8

# ---- config/index.ts
$configTs = @"
export const config = {
  port: parseInt(process.env.PORT || '3001', 10),
  uploadsDir: process.env.UPLOADS_DIR || 'uploads',
};
"@
$null = New-Item -ItemType Directory -Path "src\config" -Force
$configTs | Out-File -FilePath "src\config\index.ts" -Encoding UTF8

# ---- services/photoService.ts (sharp pipeline)
$photoSvc = @"
import fs from 'fs';
import path from 'path';
import sharp from 'sharp';
import { config } from '../config';

export async function processAndSavePhoto(
  filePath: string,
  kind: 'COVER'|'SPINE'|'BACK'|'INTERNAL'
) {
  const buf = await fs.promises.readFile(filePath);
  let img = sharp(buf).rotate();

  if (kind === 'BACK' || kind === 'INTERNAL') {
    img = img.normalize().sharpen({ sigma: 1, flat: 1, jagged: 2 }).threshold(128);
  }

  const out = await img.resize(1920, 1920, { fit: 'inside', withoutEnlargement: true })
                      .jpeg({ quality: 85 })
                      .toBuffer();

  await fs.promises.writeFile(filePath, out);

  const rel = path.relative(process.cwd(), filePath).replace(/\\\\/g, '/');
  return { path: rel };
}
"@
$null = New-Item -ItemType Directory -Path "src\services" -Force
$photoSvc | Out-File -FilePath "src\services\photoService.ts" -Encoding UTF8

# ---- controllers/authController.ts
$authCtl = @"
import type { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import Joi from 'joi';
import { signToken } from '../utils/jwt';
import type { AuthedRequest } from '../middleware/auth';

const prisma = new PrismaClient();

const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  name: Joi.string().min(2).max(80).required(),
  password: Joi.string().min(6).max(128).required(),
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).max(128).required(),
});

export async function register(req: Request, res: Response) {
  const { error, value } = registerSchema.validate(req.body);
  if (error) return res.status(400).json({ error: error.message });

  const { email, name, password } = value;

  const exists = await prisma.user.findUnique({ where: { email } });
  if (exists) return res.status(409).json({ error: 'User already exists' });

  const hashed = await bcrypt.hash(password, 12);
  const user = await prisma.user.create({
    data: { email, name, password: hashed },
    select: { id: true, email: true, name: true, createdAt: true, updatedAt: true },
  });

  const token = signToken({ sub: user.id, email: user.email });
  return res.status(201).json({ success: true, data: user, token });
}

export async function login(req: Request, res: Response) {
  const { error, value } = loginSchema.validate(req.body);
  if (error) return res.status(400).json({ error: error.message });

  const { email, password } = value;
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) return res.status(401).json({ error: 'Invalid credentials' });

  const ok = await bcrypt.compare(password, user.password);
  if (!ok) return res.status(401).json({ error: 'Invalid credentials' });

  const token = signToken({ sub: user.id, email: user.email });

  return res.json({
    success: true,
    token,
    data: { id: user.id, email: user.email, name: user.name, createdAt: user.createdAt, updatedAt: user.updatedAt }
  });
}

export async function profile(req: AuthedRequest, res: Response) {
  const id = req.user!.id;
  const user = await prisma.user.findUnique({
    where: { id },
    select: { id: true, email: true, name: true, createdAt: true, updatedAt: true },
  });
  return res.json({ success: true, data: user });
}
"@
$null = New-Item -ItemType Directory -Path "src\controllers" -Force
$authCtl | Out-File -FilePath "src\controllers\authController.ts" -Encoding UTF8

# ---- controllers/booksController.ts
$booksCtl = @"
import type { Response } from 'express';
import { PrismaClient, PhotoType } from '@prisma/client';
import Joi from 'joi';
import type { AuthedRequest } from '../middleware/auth';
import { processAndSavePhoto } from '../services/photoService';

const prisma = new PrismaClient();

const createSchema = Joi.object({
  title: Joi.string().min(1).required(),
  author: Joi.string().allow('', null),
  isbn: Joi.string().allow('', null),
  edition: Joi.string().allow('', null),
  printSerial: Joi.string().allow('', null),
  publisher: Joi.string().allow('', null),
  publicationYear: Joi.number().integer().min(0).max(3000).allow(null),
  genre: Joi.string().allow('', null),
  notes: Joi.string().allow('', null),
  tags: Joi.array().items(Joi.string()).default([]),
});

const updateSchema = createSchema.fork(['title'], (s) => s.optional());

export async function listBooks(req: AuthedRequest, res: Response) {
  const { page = '1', limit = '20', query } = req.query as Record<string, string>;
  const userId = req.user!.id;

  const where: any = { userId };
  if (query) {
    where.OR = [
      { title: { contains: query, mode: 'insensitive' } },
      { author: { contains: query, mode: 'insensitive' } },
      { isbn: { contains: query, mode: 'insensitive' } },
      { tags: { has: query } }
    ];
  }

  const skip = (parseInt(page) - 1) * parseInt(limit);
  const take = parseInt(limit);

  const [items, total] = await Promise.all([
    prisma.book.findMany({ where, skip, take, orderBy: { createdAt: 'desc' }, include: { photos: true } }),
    prisma.book.count({ where }),
  ]);

  return res.json({ success: true, data: items, meta: { total, page: parseInt(page), limit: take } });
}

export async function getBook(req: AuthedRequest, res: Response) {
  const userId = req.user!.id;
  const { id } = req.params;
  const book = await prisma.book.findFirst({ where: { id, userId }, include: { photos: true } });
  if (!book) return res.status(404).json({ error: 'Not found' });
  return res.json({ success: true, data: book });
}

export async function createBook(req: AuthedRequest, res: Response) {
  const { error, value } = createSchema.validate(req.body);
  if (error) return res.status(400).json({ error: error.message });

  const userId = req.user!.id;
  const book = await prisma.book.create({ data: { ...value, userId } });
  return res.status(201).json({ success: true, data: book });
}

export async function updateBook(req: AuthedRequest, res: Response) {
  const { error, value } = updateSchema.validate(req.body);
  if (error) return res.status(400).json({ error: error.message });

  const userId = req.user!.id;
  const { id } = req.params;

  // Ensure ownership
  const exists = await prisma.book.findFirst({ where: { id, userId } });
  if (!exists) return res.status(404).json({ error: 'Not found' });

  const updated = await prisma.book.update({ where: { id }, data: value });
  return res.json({ success: true, data: updated });
}

export async function deleteBook(req: AuthedRequest, res: Response) {
  const userId = req.user!.id;
  const { id } = req.params;

  const exists = await prisma.book.findFirst({ where: { id, userId } });
  if (!exists) return res.status(404).json({ error: 'Not found' });

  await prisma.book.delete({ where: { id } });
  return res.json({ success: true, message: 'Deleted' });
}

export async function addPhotos(req: AuthedRequest, res: Response) {
  const userId = req.user!.id;
  const { id } = req.params;

  const book = await prisma.book.findFirst({ where: { id, userId } });
  if (!book) return res.status(404).json({ error: 'Book not found' });

  const files = (req.files as Express.Multer.File[]) || [];
  if (!files.length) return res.status(400).json({ error: 'No files uploaded' });

  const typeMap: Record<string, PhotoType> = {
    cover: 'COVER',
    spine: 'SPINE',
    back: 'BACK',
    internal: 'INTERNAL',
  };

  const photosToCreate = [];
  for (const f of files) {
    const kindKey = (f.fieldname || '').toLowerCase();
    const kind = typeMap[kindKey] || 'INTERNAL';
    await processAndSavePhoto(f.path, kind);
    photosToCreate.push({
      filename: f.filename,
      path: f.path.replace(/\\\\/g, '/'),
      type: kind,
      bookId: book.id,
      size: f.size,
      mimeType: f.mimetype,
    });
  }

  const created = await prisma.photo.createMany({ data: photosToCreate });
  const withPhotos = await prisma.book.findUnique({ where: { id: book.id }, include: { photos: true } });

  return res.status(201).json({ success: true, count: created.count, data: withPhotos });
}
"@
$booksCtl | Out-File -FilePath "src\controllers\booksController.ts" -Encoding UTF8

# ---- routes/auth.ts
$authRoute = @"
import { Router } from 'express';
import { register, login, profile } from '../controllers/authController';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.get('/profile', requireAuth, profile);

export default router;
"@
$null = New-Item -ItemType Directory -Path "src\routes" -Force
$authRoute | Out-File -FilePath "src\routes\auth.ts" -Encoding UTF8

# ---- routes/books.ts (multer + endpoints)
$booksRoute = @"
import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { requireAuth } from '../middleware/auth';
import { listBooks, getBook, createBook, updateBook, deleteBook, addPhotos } from '../controllers/booksController';
import { config } from '../config';

const router = Router();

// Ensure upload dir exists
const dest = path.resolve(process.cwd(), config.uploadsDir);
fs.mkdirSync(dest, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, dest),
  filename: (_req, file, cb) => {
    const ts = Date.now();
    const safe = file.originalname.replace(/[^a-zA-Z0-9_.-]/g, '_');
    cb(null, ts + '_' + safe);
  },
});
const upload = multer({ storage });

router.get('/', requireAuth, listBooks);
router.get('/:id', requireAuth, getBook);
router.post('/', requireAuth, createBook);
router.put('/:id', requireAuth, updateBook);
router.delete('/:id', requireAuth, deleteBook);

// Expect fields: cover, spine, back, internal (any subset), multiple allowed
router.post('/:id/photos', requireAuth, upload.any(), addPhotos);

export default router;
"@
$booksRoute | Out-File -FilePath "src\routes\books.ts" -Encoding UTF8

# ---- patch index.ts to mount routes
$serverIndexPatched = @"
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import path from 'path';
import { PrismaClient } from '@prisma/client';
import authRoutes from './routes/auth';
import bookRoutes from './routes/books';
import { config } from './config';

dotenv.config();

const app = express();
const prisma = new PrismaClient();

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Static: serve uploaded images
app.use('/uploads', express.static(path.resolve(process.cwd(), config.uploadsDir)));

// Health
app.get('/health', (_req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// API
app.use('/api/auth', authRoutes);
app.use('/api/books', bookRoutes);

// 404
app.use('*', (_req, res) => res.status(404).json({ error: 'Route not found' }));

// Error middleware
// eslint-disable-next-line @typescript-eslint/no-unused-vars
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(err);
  res.status(500).json({ error: 'Internal error' });
});

// Graceful shutdown
process.on('SIGTERM', async () => { await prisma.$disconnect(); process.exit(0); });
process.on('SIGINT', async () => { await prisma.$disconnect(); process.exit(0); });

app.listen(config.port, () => {
  console.log(`🚀 Server http://localhost:${config.port}`);
  console.log(`📚 Libriary API ready`);
});
"@
$serverIndexPatched | Out-File -FilePath "src\index.ts" -Encoding UTF8

Write-Host "✅ Auth + Books routes added." -ForegroundColor Green

# ---- OPTIONAL: minimal API smoke tests (super-basic REST client hints)
$apiNotes = @"
# Quick API Smoke Test (after pnpm -w setup and docker up)

# 1) Seeded demo user from packages/database/seed:
#    email: demo@libriary.com, password: demo123

# 2) Start services:
#    pnpm run docker:up
#    pnpm --filter @libriary/database run generate
#    pnpm --filter @libriary/database run migrate
#    pnpm --filter @libriary/database run seed
#    pnpm --filter @libriary/server run dev

# 3) Login
#    POST http://localhost:3001/api/auth/login
#    { "email": "demo@libriary.com", "password": "demo123" }

#    -> copy 'token' from response

# 4) Create a book
#    POST http://localhost:3001/api/books
#    Authorization: Bearer <token>
#    { "title":"Snow Crash", "author":"Neal Stephenson", "tags":["cyberpunk"] }

# 5) List books
#    GET http://localhost:3001/api/books
#    Authorization: Bearer <token>

# 6) Upload photos (cover/back/internal fields are accepted)
#    POST http://localhost:3001/api/books/:id/photos
#    Authorization: Bearer <token>
#    multipart/form-data: cover=@C:\path\to\cover.jpg
"@
$apiNotes | Out-File -FilePath "_API_SMOKETEST.txt" -Encoding UTF8

Set-Location "..\.."
Write-Host "🎯 API wiring complete. Next: pnpm install, docker up, prisma generate/migrate/seed, run server." -ForegroundColor Green

