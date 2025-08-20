# Libriary Complete Monorepo Setup Script for Windows
# Run this in PowerShell as Administrator

param(
    [switch]$SkipDependencyCheck,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

function Write-Status($Message, $Color = "Blue") {
    Write-Host "🚀 $Message" -ForegroundColor $Color
}

function Write-Success($Message) {
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning($Message) {
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Error($Message) {
    Write-Host "❌ $Message" -ForegroundColor Red
}

Write-Status "Setting up Libriary monorepo for Windows..."

# Check prerequisites
if (-not $SkipDependencyCheck) {
    Write-Status "Checking prerequisites..."
    
    # Check for pnpm
    try {
        $pnpmVersion = pnpm --version
        Write-Success "pnpm found: v$pnpmVersion"
    } catch {
        Write-Error "pnpm not found. Please install it first: npm install -g pnpm"
        exit 1
    }
    
    # Check for Node.js
    try {
        $nodeVersion = node --version
        Write-Success "Node.js found: $nodeVersion"
    } catch {
        Write-Error "Node.js not found. Please install Node.js 18+ first"
        exit 1
    }
    
    # Check for Docker (optional)
    try {
        docker --version | Out-Null
        Write-Success "Docker found"
    } catch {
        Write-Warning "Docker not found. You can still run the project but will need external PostgreSQL/Redis"
    }
}

# Create root directory and navigate
Write-Status "Creating project structure..."
New-Item -ItemType Directory -Path "libriary" -Force | Out-Null
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
    "db:generate": "cd packages/database && npx prisma generate",
    "db:migrate": "cd packages/database && npx prisma migrate dev",
    "db:studio": "cd packages/database && npx prisma studio",
    "db:seed": "cd packages/database && npx prisma db seed",
    "db:reset": "cd packages/database && npx prisma migrate reset",
    "setup": "pnpm install && pnpm run db:generate && pnpm run db:migrate && pnpm run db:seed",
    "setup:dev": "pnpm install && pnpm run docker:up && timeout 10 && pnpm run db:generate && pnpm run db:migrate && pnpm run db:seed",
    "clean": "powershell -Command \"Remove-Item -Recurse -Force node_modules, packages/*/node_modules, packages/*/build, packages/*/dist -ErrorAction SilentlyContinue\"",
    "typecheck": "pnpm run typecheck:server && pnpm run typecheck:web",
    "typecheck:server": "cd packages/server && tsc --noEmit",
    "typecheck:web": "cd packages/web && tsc --noEmit"
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

# Coverage directory
coverage/
*.lcov

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Cache directories
.cache
.parcel-cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Temporary folders
tmp/
temp/

# Database
*.db
*.sqlite
*.sqlite3

# Uploads directory (development)
uploads/

# Mobile
.expo/
expo-env.d.ts
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
"@
$gitignore | Out-File -FilePath ".gitignore" -Encoding UTF8

# Create environment files
$envExample = @"
# Database
DATABASE_URL=postgresql://libriary:libriary@localhost:5432/libriary

# JWT Authentication
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d

# Server
PORT=3001
NODE_ENV=development

# Redis (for queues)
REDIS_URL=redis://localhost:6379

# File uploads
UPLOADS_DIR=uploads
MAX_FILE_SIZE=10485760

# OCR Service (optional)
GOOGLE_VISION_API_KEY=your-google-vision-api-key

# MinIO/S3 (optional)
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
"@
$envExample | Out-File -FilePath ".env.example" -Encoding UTF8

# Create packages directory structure
Write-Status "Creating package directories..."
$packages = @("shared", "database", "server", "web", "mobile")
foreach ($pkg in $packages) {
    New-Item -ItemType Directory -Path "packages\$pkg" -Force | Out-Null
}
New-Item -ItemType Directory -Path "scripts" -Force | Out-Null

Write-Success "Package directories created"

# ==================== SHARED PACKAGE ====================
Write-Status "Setting up shared package..."
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

New-Item -ItemType Directory -Path "src\types" -Force | Out-Null
New-Item -ItemType Directory -Path "src\utils" -Force | Out-Null

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
  photos?: Photo[];
}

export interface Photo {
  id: string;
  filename: string;
  path: string;
  type: PhotoType;
  size?: number;
  mimeType?: string;
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
  genre?: string;
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
  meta?: {
    total?: number;
    page?: number;
    limit?: number;
  };
}

export interface PaginationParams {
  page?: number;
  limit?: number;
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

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  name: string;
  password: string;
}

export interface AuthResponse {
  success: boolean;
  token: string;
  data: User;
}

export interface CreateBookRequest {
  title: string;
  author?: string;
  isbn?: string;
  edition?: string;
  printSerial?: string;
  publisher?: string;
  publicationYear?: number;
  genre?: string;
  notes?: string;
  tags?: string[];
}

export interface UpdateBookRequest extends Partial<CreateBookRequest> {}
"@
$sharedTypes | Out-File -FilePath "src\types\index.ts" -Encoding UTF8

$sharedUtils = @"
export const formatDate = (date: Date | string): string => {
  const d = typeof date === 'string' ? new Date(date) : date;
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  }).format(d);
};

export const formatDateTime = (date: Date | string): string => {
  const d = typeof date === 'string' ? new Date(date) : date;
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(d);
};

export const generateId = (): string => {
  return Math.random().toString(36).substring(2) + Date.now().toString(36);
};

export const validateISBN = (isbn: string): boolean => {
  const cleaned = isbn.replace(/[-\s]/g, '');
  return /^(97[89])?\d{10}$/.test(cleaned);
};

export const cleanISBN = (isbn: string): string => {
  return isbn.replace(/[-\s]/g, '');
};

export const formatISBN = (isbn: string): string => {
  const cleaned = cleanISBN(isbn);
  if (cleaned.length === 13) {
    return `${cleaned.slice(0, 3)}-${cleaned.slice(3, 4)}-${cleaned.slice(4, 6)}-${cleaned.slice(6, 12)}-${cleaned.slice(12)}`;
  } else if (cleaned.length === 10) {
    return `${cleaned.slice(0, 1)}-${cleaned.slice(1, 4)}-${cleaned.slice(4, 9)}-${cleaned.slice(9)}`;
  }
  return cleaned;
};

export const extractISBN = (text: string): string | null => {
  const isbnRegex = /(?:ISBN(?:-1[03])?:?\s*)?(?=[-0-9\s]{10,}|[-0-9X\s]{10,}|[0-9X]{10,13})(?:97[89][-\s]?)?[0-9][-\s]?[0-9][-\s]?[0-9][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X]?/gi;
  const matches = text.match(isbnRegex);
  return matches ? cleanISBN(matches[0]) : null;
};

export const capitalizeWords = (str: string): string => {
  return str.replace(/\w\S*/g, (txt) => 
    txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
  );
};

export const cleanText = (text: string): string => {
  return text.replace(/\s+/g, ' ').trim();
};

export const truncateText = (text: string, maxLength: number): string => {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength).trim() + '...';
};

export const slugify = (text: string): string => {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');
};

export const debounce = <T extends (...args: any[]) => any>(
  func: T,
  wait: number
): ((...args: Parameters<T>) => void) => {
  let timeout: NodeJS.Timeout | null = null;
  
  return (...args: Parameters<T>) => {
    if (timeout) clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), wait);
  };
};

export const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

export const isValidUrl = (url: string): boolean => {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
};

export const getFileExtension = (filename: string): string => {
  return filename.slice((filename.lastIndexOf(".") - 1 >>> 0) + 2);
};

export const isImageFile = (filename: string): boolean => {
  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'];
  return imageExtensions.includes(getFileExtension(filename).toLowerCase());
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

# ==================== DATABASE PACKAGE ====================
Write-Status "Setting up database package..."
Set-Location "..\database"

$databasePackageJson = @"
{
  "name": "@libriary/database",
  "version": "1.0.0",
  "description": "Database schema and migrations for Libriary",
  "scripts": {
    "generate": "prisma generate",
    "migrate": "prisma migrate dev",
    "studio": "prisma studio",
    "seed": "tsx seed/index.ts",
    "reset": "prisma migrate reset",
    "deploy": "prisma migrate deploy",
    "push": "prisma db push",
    "postinstall": "prisma generate"
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

New-Item -ItemType Directory -Path "prisma" -Force | Out-Null
New-Item -ItemType Directory -Path "seed" -Force | Out-Null

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
  ocrJobs         OCRJob[]

  @@index([userId])
  @@index([title])
  @@index([author])
  @@index([genre])
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

  @@index([bookId])
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
  bookId    String
  photoPath String?
  status    JobStatus @default(PENDING)
  result    Json?
  error     String?
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
  book      Book      @relation(fields: [bookId], references: [id], onDelete: Cascade)

  @@index([bookId])
  @@index([status])
  @@map("ocr_jobs")
}

enum JobStatus {
  PENDING
  PROCESSING
  COMPLETED
  FAILED
}

model UserSession {
  id        String   @id @default(cuid())
  userId    String
  token     String   @unique
  expiresAt DateTime
  createdAt DateTime @default(now())

  @@index([userId])
  @@index([token])
  @@map("user_sessions")
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
      notes: 'A masterpiece of American literature exploring themes of wealth, love, and the American Dream.',
    },
    {
      title: '1984',
      author: 'George Orwell',
      isbn: '9780451524935',
      publisher: 'Signet Classics',
      publicationYear: 1949,
      genre: 'Dystopian Fiction',
      tags: ['dystopian', 'political', 'classic'],
      notes: 'A chilling portrayal of totalitarian society and government surveillance.',
    },
    {
      title: 'To Kill a Mockingbird',
      author: 'Harper Lee',
      isbn: '9780446310789',
      publisher: 'Grand Central Publishing',
      publicationYear: 1960,
      genre: 'Literary Fiction',
      tags: ['social issues', 'american literature', 'classic'],
      notes: 'A powerful exploration of racial injustice and moral courage in the American South.',
    },
    {
      title: 'Dune',
      author: 'Frank Herbert',
      isbn: '9780441013593',
      publisher: 'Ace Books',
      publicationYear: 1965,
      genre: 'Science Fiction',
      tags: ['sci-fi', 'epic', 'space opera'],
      notes: 'An epic science fiction novel set in a distant future amidst a feudal interstellar society.',
    },
    {
      title: 'The Catcher in the Rye',
      author: 'J.D. Salinger',
      isbn: '9780316769174',
      publisher: 'Little, Brown and Company',
      publicationYear: 1951,
      genre: 'Literary Fiction',
      tags: ['coming of age', 'classic', 'american literature'],
      notes: 'A controversial but influential novel about teenage alienation and rebellion.',
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
  console.log('\n📋 Demo credentials:');
  console.log('   Email: demo@libriary.com');
  console.log('   Password: demo123');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error('⚠️ Seed error:', e);
    await prisma.$disconnect();
    process.exit(1);
  });
"@
$seedScript | Out-File -FilePath "seed\index.ts" -Encoding UTF8

# ==================== SERVER PACKAGE ====================
Write-Status "Setting up server package..."
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
    "clean": "powershell -Command \"Remove-Item -Recurse -Force dist -ErrorAction SilentlyContinue\"",
    "typecheck": "tsc --noEmit"
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
    "redis": "^4.6.10",
    "express-rate-limit": "^7.1.3",
    "compression": "^1.7.4"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.14",
    "@types/morgan": "^1.9.5",
    "@types/multer": "^1.4.8",
    "@types/jsonwebtoken": "^9.0.3",
    "@types/bcryptjs": "^2.4.4",
    "@types/node": "^20.6.3",
    "@types/compression": "^1.7.3",
    "typescript": "^5.2.2",
    "tsx": "^3.13.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.5",
    "nodemon": "^3.0.1"
  }
}
"@
$serverPackageJson | Out-File -FilePath "package.json" -Encoding UTF8

# Create server directory structure
$serverDirs = @("controllers", "middleware", "routes", "services", "utils", "config", "types")
foreach ($dir in $serverDirs) {
    New-Item -ItemType Directory -Path "src\$dir" -Force | Out-Null
}
New-Item -ItemType Directory -Path "uploads" -Force | Out-Null

# Server environment file
$serverEnv = @"
# Server
PORT=3001
NODE_ENV=development

# JWT
JWT_SECRET=super-secret-dev-token-change-in-production
JWT_EXPIRES_IN=7d

# Database
DATABASE_URL=postgresql://libriary:libriary@localhost:5432/libriary?schema=public

# Redis
REDIS_URL=redis://localhost:6379

# Files
UPLOADS_DIR=uploads
MAX_FILE_SIZE=10485760

# Rate limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
"@
$serverEnv | Out-File -FilePath ".env.example" -Encoding UTF8

# Server configuration
$serverConfig = @"
import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '3001', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  jwt: {
    secret: process.env.JWT_SECRET || 'change-me-in-production',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  uploads: {
    dir: process.env.UPLOADS_DIR || 'uploads',
    maxSize: parseInt(process.env.MAX_FILE_SIZE || '10485760', 10),
  },
  redis: {
    url: process.env.REDIS_URL || 'redis://localhost:6379',
  },
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  },
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    credentials: true,
  },
};
"@
$serverConfig | Out-File -FilePath "src\config\index.ts" -Encoding UTF8

# JWT utilities
$jwtUtil = @"
import jwt from 'jsonwebtoken';
import { config } from '../config';

export interface JwtPayload {
  sub: string; // user id
  email: string;
  iat?: number;
  exp?: number;
}

export const signToken = (payload: Omit<JwtPayload, 'iat' | 'exp'>): string => {
  return jwt.sign(payload, config.jwt.secret, { 
    expiresIn: config.jwt.expiresIn 
  });
};

export const verifyToken = (token: string): JwtPayload => {
  return jwt.verify(token, config.jwt.secret) as JwtPayload;
};

export const decodeToken = (token: string): JwtPayload | null => {
  try {
    return jwt.decode(token) as JwtPayload;
  } catch {
    return null;
  }
};
"@
$jwtUtil | Out-File -FilePath "src\utils\jwt.ts" -Encoding UTF8

# Auth middleware
$authMiddleware = @"
import type { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../utils/jwt';

export interface AuthedRequest extends Request {
  user?: { id: string; email: string };
}

export const requireAuth = (req: AuthedRequest, res: Response, next: NextFunction): void => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  
  if (!token) {
    res.status(401).json({ success: false, error: 'Missing authorization token' });
    return;
  }

  try {
    const payload = verifyToken(token);
    req.user = { id: payload.sub, email: payload.email };
    next();
  } catch (error) {
    res.status(401).json({ success: false, error: 'Invalid or expired token' });
    return;
  }
};

export const optionalAuth = (req: AuthedRequest, res: Response, next: NextFunction): void => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  
  if (token) {
    try {
      const payload = verifyToken(token);
      req.user = { id: payload.sub, email: payload.email };
    } catch {
      // Invalid token, but continue without user
    }
  }
  
  next();
};
"@
$authMiddleware | Out-File -FilePath "src\middleware\auth.ts" -Encoding UTF8

# Error handling middleware
$errorMiddleware = @"
import type { Request, Response, NextFunction } from 'express';
import { config } from '../config';

export interface AppError extends Error {
  statusCode?: number;
  status?: string;
  isOperational?: boolean;
}

export class ValidationError extends Error {
  statusCode = 400;
  status = 'fail';
  isOperational = true;

  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

export class AuthenticationError extends Error {
  statusCode = 401;
  status = 'fail';
  isOperational = true;

  constructor(message: string = 'Authentication required') {
    super(message);
    this.name = 'AuthenticationError';
  }
}

export class NotFoundError extends Error {
  statusCode = 404;
  status = 'fail';
  isOperational = true;

  constructor(message: string = 'Resource not found') {
    super(message);
    this.name = 'NotFoundError';
  }
}

export const errorHandler = (err: AppError, req: Request, res: Response, next: NextFunction): void => {
  let { statusCode = 500, message } = err;

  if (config.nodeEnv === 'development') {
    console.error('Error:', err);
  }

  // Prisma errors
  if (err.name === 'PrismaClientKnownRequestError') {
    statusCode = 400;
    message = 'Database operation failed';
  }

  // Validation errors
  if (err.name === 'ValidationError') {
    statusCode = 400;
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid token';
  }

  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token expired';
  }

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(config.nodeEnv === 'development' && { stack: err.stack }),
  });
};

export const notFound = (req: Request, res: Response): void => {
  res.status(404).json({
    success: false,
    error: `Route ${req.originalUrl} not found`,
  });
};
"@
$errorMiddleware | Out-File -FilePath "src\middleware\error.ts" -Encoding UTF8

# Photo service
$photoService = @"
import fs from 'fs/promises';
import path from 'path';
import sharp from 'sharp';
import { config } from '../config';

export interface ProcessedPhoto {
  path: string;
  size: number;
  width: number;
  height: number;
}

export async function processAndSavePhoto(
  filePath: string,
  type: 'COVER' | 'SPINE' | 'BACK' | 'INTERNAL'
): Promise<ProcessedPhoto> {
  try {
    const buffer = await fs.readFile(filePath);
    let pipeline = sharp(buffer).rotate(); // Auto-rotate based on EXIF

    // Apply different processing based on photo type
    switch (type) {
      case 'BACK':
      case 'INTERNAL':
        // Enhance text readability for OCR
        pipeline = pipeline
          .normalize()
          .sharpen({ sigma: 1, flat: 1, jagged: 2 })
          .threshold(128, { grayscale: false });
        break;
      case 'COVER':
      case 'SPINE':
        // Preserve colors and details for covers
        pipeline = pipeline.sharpen();
        break;
    }

    // Resize to max 1920px on longest side
    pipeline = pipeline.resize(1920, 1920, {
      fit: 'inside',
      withoutEnlargement: true,
    });

    // Convert to JPEG with good quality
    const processed = await pipeline.jpeg({ quality: 85 }).toBuffer();
    
    // Get metadata
    const metadata = await sharp(processed).metadata();
    
    // Save processed image
    await fs.writeFile(filePath, processed);

    // Return relative path from project root
    const relativePath = path.relative(process.cwd(), filePath).replace(/\\\\/g, '/');

    return {
      path: relativePath,
      size: processed.length,
      width: metadata.width || 0,
      height: metadata.height || 0,
    };
  } catch (error) {
    console.error('Error processing photo:', error);
    throw new Error('Failed to process photo');
  }
}

export async function deletePhoto(photoPath: string): Promise<void> {
  try {
    const fullPath = path.resolve(process.cwd(), photoPath);
    await fs.unlink(fullPath);
  } catch (error) {
    console.warn('Failed to delete photo:', photoPath, error);
  }
}

export function getPhotoUrl(photoPath: string, baseUrl: string): string {
  return `${baseUrl}/${photoPath}`;
}
"@
$photoService | Out-File -FilePath "src\services\photoService.ts" -Encoding UTF8

# Auth controller
$authController = @"
import type { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import Joi from 'joi';
import { signToken } from '../utils/jwt';
import type { AuthedRequest } from '../middleware/auth';
import { ValidationError, AuthenticationError } from '../middleware/error';

const prisma = new PrismaClient();

const registerSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Please provide a valid email address',
    'any.required': 'Email is required',
  }),
  name: Joi.string().min(2).max(80).required().messages({
    'string.min': 'Name must be at least 2 characters long',
    'string.max': 'Name cannot exceed 80 characters',
    'any.required': 'Name is required',
  }),
  password: Joi.string().min(6).max(128).required().messages({
    'string.min': 'Password must be at least 6 characters long',
    'string.max': 'Password cannot exceed 128 characters',
    'any.required': 'Password is required',
  }),
});

const loginSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Please provide a valid email address',
    'any.required': 'Email is required',
  }),
  password: Joi.string().min(6).max(128).required().messages({
    'string.min': 'Password must be at least 6 characters long',
    'any.required': 'Password is required',
  }),
});

export async function register(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      throw new ValidationError(error.details[0].message);
    }

    const { email, name, password } = value;

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({ 
      where: { email: email.toLowerCase() } 
    });
    
    if (existingUser) {
      res.status(409).json({ 
        success: false, 
        error: 'An account with this email already exists' 
      });
      return;
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const user = await prisma.user.create({
      data: { 
        email: email.toLowerCase(), 
        name: name.trim(), 
        password: hashedPassword 
      },
      select: { 
        id: true, 
        email: true, 
        name: true, 
        createdAt: true, 
        updatedAt: true 
      },
    });

    // Generate token
    const token = signToken({ sub: user.id, email: user.email });

    res.status(201).json({
      success: true,
      message: 'Account created successfully',
      data: user,
      token,
    });
  } catch (error) {
    next(error);
  }
}

export async function login(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      throw new ValidationError(error.details[0].message);
    }

    const { email, password } = value;

    // Find user
    const user = await prisma.user.findUnique({ 
      where: { email: email.toLowerCase() } 
    });
    
    if (!user) {
      throw new AuthenticationError('Invalid email or password');
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      throw new AuthenticationError('Invalid email or password');
    }

    // Generate token
    const token = signToken({ sub: user.id, email: user.email });

    res.json({
      success: true,
      message: 'Logged in successfully',
      token,
      data: {
        id: user.id,
        email: user.email,
        name: user.name,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
    });
  } catch (error) {
    next(error);
  }
}

export async function getProfile(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const userId = req.user!.id;
    
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
        updatedAt: true,
        _count: {
          select: {
            books: true,
          },
        },
      },
    });

    if (!user) {
      throw new AuthenticationError('User not found');
    }

    res.json({
      success: true,
      data: {
        ...user,
        booksCount: user._count.books,
      },
    });
  } catch (error) {
    next(error);
  }
}

export async function updateProfile(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const updateSchema = Joi.object({
      name: Joi.string().min(2).max(80).optional(),
      email: Joi.string().email().optional(),
    });

    const { error, value } = updateSchema.validate(req.body);
    if (error) {
      throw new ValidationError(error.details[0].message);
    }

    const userId = req.user!.id;
    const updateData: any = {};

    if (value.name) {
      updateData.name = value.name.trim();
    }

    if (value.email) {
      updateData.email = value.email.toLowerCase();
      
      // Check if email is already taken by another user
      const existingUser = await prisma.user.findFirst({
        where: {
          email: updateData.email,
          NOT: { id: userId },
        },
      });

      if (existingUser) {
        res.status(409).json({
          success: false,
          error: 'This email is already in use by another account',
        });
        return;
      }
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: updatedUser,
    });
  } catch (error) {
    next(error);
  }
}
"@
$authController | Out-File -FilePath "src\controllers\authController.ts" -Encoding UTF8

# Books controller
$booksController = @"
import type { Response, NextFunction } from 'express';
import { PrismaClient, PhotoType } from '@prisma/client';
import Joi from 'joi';
import type { AuthedRequest } from '../middleware/auth';
import { processAndSavePhoto, deletePhoto } from '../services/photoService';
import { ValidationError, NotFoundError } from '../middleware/error';

const prisma = new PrismaClient();

const createBookSchema = Joi.object({
  title: Joi.string().min(1).max(500).required().messages({
    'string.min': 'Title is required',
    'string.max': 'Title cannot exceed 500 characters',
    'any.required': 'Title is required',
  }),
  author: Joi.string().max(200).optional().allow('', null),
  isbn: Joi.string().max(20).optional().allow('', null),
  edition: Joi.string().max(100).optional().allow('', null),
  printSerial: Joi.string().max(100).optional().allow('', null),
  publisher: Joi.string().max(200).optional().allow('', null),
  publicationYear: Joi.number().integer().min(0).max(3000).optional().allow(null),
  genre: Joi.string().max(100).optional().allow('', null),
  notes: Joi.string().max(2000).optional().allow('', null),
  tags: Joi.array().items(Joi.string().max(50)).max(20).default([]),
});

const updateBookSchema = createBookSchema.fork(['title'], (schema) => schema.optional());

export async function listBooks(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const {
      page = '1',
      limit = '20',
      query,
      author,
      genre,
      tags,
      yearFrom,
      yearTo,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = req.query as Record<string, string>;

    const userId = req.user!.id;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    const take = Math.min(parseInt(limit), 100); // Max 100 items per page

    // Build where clause
    const where: any = { userId };

    if (query) {
      where.OR = [
        { title: { contains: query, mode: 'insensitive' } },
        { author: { contains: query, mode: 'insensitive' } },
        { isbn: { contains: query, mode: 'insensitive' } },
        { publisher: { contains: query, mode: 'insensitive' } },
        { genre: { contains: query, mode: 'insensitive' } },
        { notes: { contains: query, mode: 'insensitive' } },
      ];
    }

    if (author) {
      where.author = { contains: author, mode: 'insensitive' };
    }

    if (genre) {
      where.genre = { contains: genre, mode: 'insensitive' };
    }

    if (tags) {
      const tagArray = tags.split(',').map(tag => tag.trim());
      where.tags = { hasSome: tagArray };
    }

    if (yearFrom || yearTo) {
      where.publicationYear = {};
      if (yearFrom) where.publicationYear.gte = parseInt(yearFrom);
      if (yearTo) where.publicationYear.lte = parseInt(yearTo);
    }

    // Build order by
    const validSortFields = ['title', 'author', 'createdAt', 'updatedAt', 'publicationYear'];
    const orderBy: any = {};
    
    if (validSortFields.includes(sortBy)) {
      orderBy[sortBy] = sortOrder === 'asc' ? 'asc' : 'desc';
    } else {
      orderBy.createdAt = 'desc';
    }

    // Execute queries
    const [books, total] = await Promise.all([
      prisma.book.findMany({
        where,
        skip,
        take,
        orderBy,
        include: {
          photos: {
            select: {
              id: true,
              filename: true,
              path: true,
              type: true,
              size: true,
              mimeType: true,
              createdAt: true,
            },
          },
          _count: {
            select: {
              photos: true,
            },
          },
        },
      }),
      prisma.book.count({ where }),
    ]);

    res.json({
      success: true,
      data: books,
      meta: {
        total,
        page: parseInt(page),
        limit: take,
        pages: Math.ceil(total / take),
        hasNext: skip + take < total,
        hasPrev: parseInt(page) > 1,
      },
    });
  } catch (error) {
    next(error);
  }
}

export async function getBook(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const book = await prisma.book.findFirst({
      where: { id, userId },
      include: {
        photos: {
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    if (!book) {
      throw new NotFoundError('Book not found');
    }

    res.json({
      success: true,
      data: book,
    });
  } catch (error) {
    next(error);
  }
}

export async function createBook(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { error, value } = createBookSchema.validate(req.body);
    if (error) {
      throw new ValidationError(error.details[0].message);
    }

    const userId = req.user!.id;
    
    // Clean up the data
    const bookData = {
      ...value,
      title: value.title.trim(),
      author: value.author?.trim() || null,
      isbn: value.isbn?.trim() || null,
      publisher: value.publisher?.trim() || null,
      genre: value.genre?.trim() || null,
      notes: value.notes?.trim() || null,
      tags: value.tags?.map((tag: string) => tag.trim()).filter((tag: string) => tag.length > 0) || [],
      userId,
    };

    const book = await prisma.book.create({
      data: bookData,
      include: {
        photos: true,
      },
    });

    res.status(201).json({
      success: true,
      message: 'Book created successfully',
      data: book,
    });
  } catch (error) {
    next(error);
  }
}

export async function updateBook(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { error, value } = updateBookSchema.validate(req.body);
    if (error) {
      throw new ValidationError(error.details[0].message);
    }

    const userId = req.user!.id;
    const { id } = req.params;

    // Check ownership
    const existingBook = await prisma.book.findFirst({
      where: { id, userId },
    });

    if (!existingBook) {
      throw new NotFoundError('Book not found');
    }

    // Clean up the data
    const updateData: any = {};
    
    if (value.title !== undefined) updateData.title = value.title.trim();
    if (value.author !== undefined) updateData.author = value.author?.trim() || null;
    if (value.isbn !== undefined) updateData.isbn = value.isbn?.trim() || null;
    if (value.publisher !== undefined) updateData.publisher = value.publisher?.trim() || null;
    if (value.genre !== undefined) updateData.genre = value.genre?.trim() || null;
    if (value.notes !== undefined) updateData.notes = value.notes?.trim() || null;
    if (value.tags !== undefined) {
      updateData.tags = value.tags?.map((tag: string) => tag.trim()).filter((tag: string) => tag.length > 0) || [];
    }
    if (value.publicationYear !== undefined) updateData.publicationYear = value.publicationYear;
    if (value.edition !== undefined) updateData.edition = value.edition?.trim() || null;
    if (value.printSerial !== undefined) updateData.printSerial = value.printSerial?.trim() || null;

    const updatedBook = await prisma.book.update({
      where: { id },
      data: updateData,
      include: {
        photos: true,
      },
    });

    res.json({
      success: true,
      message: 'Book updated successfully',
      data: updatedBook,
    });
  } catch (error) {
    next(error);
  }
}

export async function deleteBook(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    // Check ownership and get photos for cleanup
    const book = await prisma.book.findFirst({
      where: { id, userId },
      include: {
        photos: true,
      },
    });

    if (!book) {
      throw new NotFoundError('Book not found');
    }

    // Delete associated photos from filesystem
    for (const photo of book.photos) {
      await deletePhoto(photo.path);
    }

    // Delete book (cascade will handle photos in DB)
    await prisma.book.delete({
      where: { id },
    });

    res.json({
      success: true,
      message: 'Book deleted successfully',
    });
  } catch (error) {
    next(error);
  }
}

export async function addPhotos(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    // Check if book exists and user owns it
    const book = await prisma.book.findFirst({
      where: { id, userId },
    });

    if (!book) {
      throw new NotFoundError('Book not found');
    }

    const files = (req.files as Express.Multer.File[]) || [];
    if (!files.length) {
      throw new ValidationError('No files uploaded');
    }

    const typeMap: Record<string, PhotoType> = {
      cover: 'COVER',
      spine: 'SPINE',
      back: 'BACK',
      internal: 'INTERNAL',
    };

    const photosToCreate = [];
    
    for (const file of files) {
      const fieldName = (file.fieldname || '').toLowerCase();
      const photoType = typeMap[fieldName] || 'INTERNAL';
      
      try {
        const processed = await processAndSavePhoto(file.path, photoType);
        
        photosToCreate.push({
          filename: file.filename,
          path: processed.path,
          type: photoType,
          bookId: book.id,
          size: processed.size,
          mimeType: file.mimetype,
        });
      } catch (error) {
        console.error(`Failed to process photo ${file.filename}:`, error);
        // Continue with other photos
      }
    }

    if (photosToCreate.length === 0) {
      throw new ValidationError('No photos could be processed');
    }

    // Create photo records
    await prisma.photo.createMany({
      data: photosToCreate,
    });

    // Return updated book with photos
    const updatedBook = await prisma.book.findUnique({
      where: { id: book.id },
      include: {
        photos: {
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    res.status(201).json({
      success: true,
      message: `${photosToCreate.length} photo(s) uploaded successfully`,
      data: updatedBook,
    });
  } catch (error) {
    next(error);
  }
}

export async function deletePhoto(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const userId = req.user!.id;
    const { id: bookId, photoId } = req.params;

    // Check if book exists and user owns it
    const book = await prisma.book.findFirst({
      where: { id: bookId, userId },
    });

    if (!book) {
      throw new NotFoundError('Book not found');
    }

    // Find and delete photo
    const photo = await prisma.photo.findFirst({
      where: { id: photoId, bookId },
    });

    if (!photo) {
      throw new NotFoundError('Photo not found');
    }

    // Delete from filesystem
    await deletePhoto(photo.path);

    // Delete from database
    await prisma.photo.delete({
      where: { id: photoId },
    });

    res.json({
      success: true,
      message: 'Photo deleted successfully',
    });
  } catch (error) {
    next(error);
  }
}
"@
$booksController | Out-File -FilePath "src\controllers\booksController.ts" -Encoding UTF8

# Routes
$authRoutes = @"
import { Router } from 'express';
import { register, login, getProfile, updateProfile } from '../controllers/authController';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.get('/profile', requireAuth, getProfile);
router.put('/profile', requireAuth, updateProfile);

export default router;
"@
$authRoutes | Out-File -FilePath "src\routes\auth.ts" -Encoding UTF8

$bookRoutes = @"
import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { requireAuth } from '../middleware/auth';
import {
  listBooks,
  getBook,
  createBook,
  updateBook,
  deleteBook,
  addPhotos,
  deletePhoto,
} from '../controllers/booksController';
import { config } from '../config';

const router = Router();

// Ensure upload directory exists
const uploadDir = path.resolve(process.cwd(), config.uploads.dir);
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadDir);
  },
  filename: (_req, file, cb) => {
    const timestamp = Date.now();
    const safeName = file.originalname.replace(/[^a-zA-Z0-9_.-]/g, '_');
    cb(null, `${timestamp}_${safeName}`);
  },
});

const fileFilter = (req: any, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  // Accept only images
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Only image files are allowed'));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: config.uploads.maxSize,
    files: 10, // Max 10 files per request
  },
});

// Book routes
router.get('/', requireAuth, listBooks);
router.get('/:id', requireAuth, getBook);
router.post('/', requireAuth, createBook);
router.put('/:id', requireAuth, updateBook);
router.delete('/:id', requireAuth, deleteBook);

// Photo routes
router.post('/:id/photos', requireAuth, upload.any(), addPhotos);
router.delete('/:id/photos/:photoId', requireAuth, deletePhoto);

export default router;
"@ 

# ==================== MOBILE PACKAGE ====================
Write-Status "Setting up mobile package..."
Set-Location "..\mobile"

$mobilePackageJson = @"
{
  "name": "@libriary/mobile",
  "version": "1.0.0",
  "private": true,
  "main": "node_modules/expo/AppEntry.js",
  "scripts": {
    "start": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios",
    "web": "expo start --web",
    "build": "expo build",
    "lint": "eslint src/**/*.{ts,tsx}",
    "lint:fix": "eslint src/**/*.{ts,tsx} --fix",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@libriary/shared": "workspace:*",
    "expo": "~49.0.0",
    "expo-status-bar": "~1.6.0",
    "expo-camera": "~13.4.0",
    "expo-media-library": "~15.4.0",
    "expo-file-system": "~15.4.0",
    "expo-image-picker": "~14.3.2",
    "expo-linking": "~5.0.2",
    "react": "18.2.0",
    "react-native": "0.72.6",
    "@react-navigation/native": "^6.1.7",
    "@react-navigation/native-stack": "^6.9.13",
    "@react-navigation/bottom-tabs": "^6.5.8",
    "react-native-screens": "~3.22.0",
    "react-native-safe-area-context": "4.6.3",
    "axios": "^1.5.0",
    "react-query": "^3.39.3",
    "react-hook-form": "^7.46.1",
    "expo-secure-store": "~12.3.1",
    "react-native-toast-message": "^2.1.6"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0",
    "@types/react": "~18.2.14",
    "@types/react-native": "~0.72.2",
    "typescript": "^5.1.3",
    "eslint": "^8.51.0",
    "@typescript-eslint/eslint-plugin": "^6.7.4",
    "@typescript-eslint/parser": "^6.7.4"
  }
}
"@
$mobilePackageJson | Out-File -FilePath "package.json" -Encoding UTF8

# Create mobile directory structure
$mobileDirs = @("src\components", "src\screens", "src\navigation", "src\services", "src\hooks", "src\utils", "src\context", "src\types", "assets")
foreach ($dir in $mobileDirs) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# Expo app config
$appConfig = @"
import { ExpoConfig, ConfigContext } from 'expo/config';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'Libriary',
  slug: 'libriary',
  version: '1.0.0',
  orientation: 'portrait',
  icon: './assets/icon.png',
  userInterfaceStyle: 'light',
  splash: {
    image: './assets/splash.png',
    resizeMode: 'contain',
    backgroundColor: '#ffffff'
  },
  assetBundlePatterns: [
    '**/*'
  ],
  ios: {
    supportsTablet: true,
    bundleIdentifier: 'com.libriary.app',
  },
  android: {
    adaptiveIcon: {
      foregroundImage: './assets/adaptive-icon.png',
      backgroundColor: '#FFFFFF'
    },
    package: 'com.libriary.app',
    permissions: [
      'CAMERA',
      'WRITE_EXTERNAL_STORAGE',
      'READ_EXTERNAL_STORAGE'
    ]
  },
  web: {
    favicon: './assets/favicon.png'
  },
  plugins: [
    'expo-camera',
    'expo-media-library',
    'expo-image-picker'
  ]
});
"@
$appConfig | Out-File -FilePath "app.config.ts" -Encoding UTF8

# Basic mobile App component
$mobileApp = @"
import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { QueryClient, QueryClientProvider } from 'react-query';
import { NavigationContainer } from '@react-navigation/native';
import { AuthProvider } from './src/context/AuthContext';
import AppNavigator from './src/navigation/AppNavigator';
import Toast from 'react-native-toast-message';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <NavigationContainer>
        <AuthProvider>
          <StatusBar style="auto" />
          <AppNavigator />
          <Toast />
        </AuthProvider>
      </NavigationContainer>
    </QueryClientProvider>
  );
}
"@
$mobileApp | Out-File -FilePath "App.tsx" -Encoding UTF8

# Basic mobile navigation
$appNavigator = @"
import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../context/AuthContext';

// Auth screens
import LoginScreen from '../screens/LoginScreen';
import RegisterScreen from '../screens/RegisterScreen';

// Main screens
import HomeScreen from '../screens/HomeScreen';
import BooksScreen from '../screens/BooksScreen';
import BookDetailScreen from '../screens/BookDetailScreen';
import AddBookScreen from '../screens/AddBookScreen';
import CameraScreen from '../screens/CameraScreen';
import ProfileScreen from '../screens/ProfileScreen';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

function AuthStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="Register" component={RegisterScreen} />
    </Stack.Navigator>
  );
}

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: keyof typeof Ionicons.glyphMap;

          if (route.name === 'Home') {
            iconName = focused ? 'home' : 'home-outline';
          } else if (route.name === 'Books') {
            iconName = focused ? 'library' : 'library-outline';
          } else if (route.name === 'Camera') {
            iconName = focused ? 'camera' : 'camera-outline';
          } else if (route.name === 'Profile') {
            iconName = focused ? 'person' : 'person-outline';
          } else {
            iconName = 'help-outline';
          }

          return <Ionicons name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#3B82F6',
        tabBarInactiveTintColor: 'gray',
        headerStyle: {
          backgroundColor: '#3B82F6',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} options={{ title: '📚 Libriary' }} />
      <Tab.Screen name="Books" component={BooksScreen} />
      <Tab.Screen name="Camera" component={CameraScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}

function MainStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen 
        name="MainTabs" 
        component={MainTabs} 
        options={{ headerShown: false }}
      />
      <Stack.Screen name="BookDetail" component={BookDetailScreen} />
      <Stack.Screen name="AddBook" component={AddBookScreen} />
    </Stack.Navigator>
  );
}

export default function AppNavigator() {
  const { user, loading } = useAuth();

  if (loading) {
    return null; // You could show a loading screen here
  }

  return user ? <MainStack /> : <AuthStack />;
}
"@
$appNavigator | Out-File -FilePath "src\navigation\AppNavigator.tsx" -Encoding UTF8

# Mobile auth context
$mobileAuthContext = @"
import React, { createContext, useContext, useState, useEffect } from 'react';
import * as SecureStore from 'expo-secure-store';
import { User } from '@libriary/shared';
import { authService } from '../services/authService';

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, name: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadUser();
  }, []);

  const loadUser = async () => {
    try {
      const token = await SecureStore.getItemAsync('token');
      if (token) {
        const userData = await authService.getProfile();
        setUser(userData);
      }
    } catch (error) {
      await SecureStore.deleteItemAsync('token');
    } finally {
      setLoading(false);
    }
  };

  const login = async (email: string, password: string) => {
    const { user: userData, token } = await authService.login(email, password);
    await SecureStore.setItemAsync('token', token);
    setUser(userData);
  };

  const register = async (email: string, name: string, password: string) => {
    const { user: userData, token } = await authService.register(email, name, password);
    await SecureStore.setItemAsync('token', token);
    setUser(userData);
  };

  const logout = async () => {
    await SecureStore.deleteItemAsync('token');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, register, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
"@
$mobileAuthContext | Out-File -FilePath "src\context\AuthContext.tsx" -Encoding UTF8

# Basic mobile screens (placeholders)
$mobileScreens = @{
  "LoginScreen.tsx" = @"
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  Alert,
} from 'react-native';
import { useAuth } from '../context/AuthContext';
import Toast from 'react-native-toast-message';

export default function LoginScreen({ navigation }: any) {
  const { login } = useAuth();
  const [email, setEmail] = useState('demo@libriary.com');
  const [password, setPassword] = useState('demo123');
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      await login(email, password);
      Toast.show({
        type: 'success',
        text1: 'Welcome back!',
      });
    } catch (error: any) {
      Toast.show({
        type: 'error',
        text1: 'Login Failed',
        text2: error.response?.data?.error || 'Please try again',
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView 
      style={styles.container} 
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <View style={styles.content}>
        <Text style={styles.title}>📚 Libriary</Text>
        <Text style={styles.subtitle}>Sign in to your account</Text>
        
        <View style={styles.form}>
          <TextInput
            style={styles.input}
            placeholder="Email"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
          />
          
          <TextInput
            style={styles.input}
            placeholder="Password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
          />
          
          <TouchableOpacity 
            style={[styles.button, loading && styles.buttonDisabled]}
            onPress={handleLogin}
            disabled={loading}
          >
            <Text style={styles.buttonText}>
              {loading ? 'Signing in...' : 'Sign In'}
            </Text>
          </TouchableOpacity>
          
          <TouchableOpacity 
            onPress={() => navigation.navigate('Register')}
            style={styles.linkButton}
          >
            <Text style={styles.linkText}>Don't have an account? Sign up</Text>
          </TouchableOpacity>
        </View>
        
        <View style={styles.demoInfo}>
          <Text style={styles.demoText}>Demo Account Loaded</Text>
          <Text style={styles.demoSubtext}>Email: demo@libriary.com</Text>
          <Text style={styles.demoSubtext}>Password: demo123</Text>
        </View>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F9FAFB',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
    color: '#1F2937',
  },
  subtitle: {
    fontSize: 16,
    textAlign: 'center',
    color: '#6B7280',
    marginBottom: 32,
  },
  form: {
    marginBottom: 32,
  },
  input: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    marginBottom: 16,
  },
  button: {
    backgroundColor: '#3B82F6',
    borderRadius: 8,
    paddingVertical: 16,
    alignItems: 'center',
    marginBottom: 16,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  linkButton: {
    alignItems: 'center',
  },
  linkText: {
    color: '#3B82F6',
    fontSize: 14,
  },
  demoInfo: {
    backgroundColor: '#EFF6FF',
    padding: 16,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#DBEAFE',
  },
  demoText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1D4ED8',
    marginBottom: 4,
  },
  demoSubtext: {
    fontSize: 12,
    color: '#1E40AF',
  },
});
"@
  
  "HomeScreen.tsx" = @"
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../context/AuthContext';

export default function HomeScreen({ navigation }: any) {
  const { user } = useAuth();

  const quickActions = [
    {
      title: 'View Books',
      subtitle: 'Browse your collection',
      icon: 'library-outline',
      color: '#3B82F6',
      onPress: () => navigation.navigate('Books'),
    },
    {
      title: 'Add Book',
      subtitle: 'Scan or enter manually',
      icon: 'add-circle-outline',
      color: '#10B981',
      onPress: () => navigation.navigate('AddBook'),
    },
    {
      title: 'Take Photo',
      subtitle: 'Scan book cover',
      icon: 'camera-outline',
      color: '#8B5CF6',
      onPress: () => navigation.navigate('Camera'),
    },
  ];

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.greeting}>
          Welcome back, {user?.name}! 👋
        </Text>
        <Text style={styles.subgreeting}>
          Ready to manage your book collection?
        </Text>
      </View>

      <View style={styles.actionsContainer}>
        <Text style={styles.sectionTitle}>Quick Actions</Text>
        {quickActions.map((action, index) => (
          <TouchableOpacity 
            key={index}
            style={[styles.actionCard, { borderLeftColor: action.color }]}
            onPress={action.onPress}
          >
            <View style={styles.actionContent}>
              <View style={[styles.iconContainer, { backgroundColor: action.color + '20' }]}>
                <Ionicons name={action.icon as any} size={24} color={action.color} />
              </View>
              <View style={styles.actionText}>
                <Text style={styles.actionTitle}>{action.title}</Text>
                <Text style={styles.actionSubtitle}>{action.subtitle}</Text>
              </View>
              <Ionicons name="chevron-forward" size={20} color="#9CA3AF" />
            </View>
          </TouchableOpacity>
        ))}
      </View>

      <View style={styles.statsContainer}>
        <Text style={styles.sectionTitle}>Your Library</Text>
        <View style={styles.statsGrid}>
          <View style={styles.statCard}>
            <Text style={styles.statNumber}>-</Text>
            <Text style={styles.statLabel}>Books</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={styles.statNumber}>-</Text>
            <Text style={styles.statLabel}>Authors</Text>
          </View>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F9FAFB',
  },
  header: {
    padding: 20,
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  greeting: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1F2937',
    marginBottom: 4,
  },
  subgreeting: {
    fontSize: 16,
    color: '#6B7280',
  },
  actionsContainer: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1F2937',
    marginBottom: 16,
  },
  actionCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    borderLeftWidth: 4,
    marginBottom: 12,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
  },
  actionContent: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
  },
  iconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  actionText: {
    flex: 1,
  },
  actionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1F2937',
    marginBottom: 2,
  },
  actionSubtitle: {
    fontSize: 14,
    color: '#6B7280',
  },
  statsContainer: {
    padding: 20,
  },
  statsGrid: {
    flexDirection: 'row',
    gap: 12,
  },
  statCard: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    padding: 20,
    borderRadius: 12,
    alignItems: 'center',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
  },
  statNumber: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#3B82F6',
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 14,
    color: '#6B7280',
    fontWeight: '500',
  },
});
"@

  "BooksScreen.tsx" = @"
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function BooksScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Books</Text>
      <Text style={styles.subtitle}>Your book collection will appear here</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F9FAFB',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1F2937',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#6B7280',
    textAlign: 'center',
  },
});
"@
}

# Create basic placeholder screens
foreach ($screenName in $mobileScreens.Keys) {
  $content = $mobileScreens[$screenName]
  $content | Out-File -FilePath "src\screens\$screenName" -Encoding UTF8
}

# Create additional placeholder screens
$additionalScreens = @("RegisterScreen.tsx", "BookDetailScreen.tsx", "AddBookScreen.tsx", "CameraScreen.tsx", "ProfileScreen.tsx")
foreach ($screen in $additionalScreens) {
  $screenBaseName = $screen.Replace("Screen.tsx", "")
  $placeholder = @"
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function $($screen.Replace('.tsx', ''))() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>$screenBaseName</Text>
      <Text style={styles.subtitle}>This screen is under construction</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F9FAFB',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1F2937',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#6B7280',
    textAlign: 'center',
  },
});
"@
  $placeholder | Out-File -FilePath "src\screens\$screen" -Encoding UTF8
}

# Mobile auth service
$mobileAuthService = @"
import axios from 'axios';
import * as SecureStore from 'expo-secure-store';
import { User, LoginRequest, RegisterRequest, AuthResponse, APIResponse } from '@libriary/shared';

const API_URL = 'http://localhost:3001/api'; // Change this to your server URL

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
api.interceptors.request.use(async (config) => {
  const token = await SecureStore.getItemAsync('token');
  if (token) {
    config.headers.Authorization = \`Bearer \${token}\`;
  }
  return config;
});

export const authService = {
  async login(email: string, password: string): Promise<AuthResponse> {
    const { data } = await api.post<AuthResponse>('/auth/login', { email, password });
    return data;
  },

  async register(email: string, name: string, password: string): Promise<AuthResponse> {
    const { data } = await api.post<AuthResponse>('/auth/register', { email, name, password });
    return data;
  },

  async getProfile(): Promise<User> {
    const { data } = await api.get<APIResponse<User>>('/auth/profile');
    return data.data!;
  },
};
"@
$mobileAuthService | Out-File -FilePath "src\services\authService.ts" -Encoding UTF8

# Mobile TypeScript config
$mobileTsConfig = @"
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "skipLibCheck": true,
    "resolveJsonModule": true
  },
  "include": [
    "**/*.ts",
    "**/*.tsx",
    ".expo/types/**/*.ts",
    "expo-env.d.ts"
  ]
}
"@
$mobileTsConfig | Out-File -FilePath "tsconfig.json" -Encoding UTF8

# ==================== ROOT LEVEL FILES ====================
Write-Status "Creating root level configuration files..."
Set-Location "..\.."

# Docker Compose
$dockerCompose = @"
version: '3.8'

services:
  postgres:
    image: postgres:15
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: libriary
      POSTGRES_USER: libriary
      POSTGRES_PASSWORD: libriary
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U libriary"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

  minio:
    image: minio/minio:latest
    restart: unless-stopped
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    command: server /data --console-address ":9001"
    volumes:
      - minio_data:/data

volumes:
  postgres_data:
  redis_data:
  minio_data:
"@
$dockerCompose | Out-File -FilePath "docker-compose.yml" -Encoding UTF8

# CI/CD workflow
mkdir -p .github/workflows -Force | Out-Null
$ciWorkflow = @"
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: libriary
          POSTGRES_USER: libriary
          POSTGRES_DB: libriary
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Install dependencies
        run: pnpm install

      - name: Generate Prisma client
        run: pnpm run db:generate

      - name: Run migrations
        run: pnpm run db:migrate
        env:
          DATABASE_URL: postgresql://libriary:libriary@localhost:5432/libriary

      - name: Type check
        run: pnpm run typecheck

      - name: Lint
        run: pnpm run lint

      - name: Test
        run: pnpm run test
        env:
          DATABASE_URL: postgresql://libriary:libriary@localhost:5432/libriary

      - name: Build
        run: pnpm run build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Deploy to production
        run: echo "Deploy to production server"
        # Add your deployment steps here
"@
$ciWorkflow | Out-File -FilePath ".github\workflows\ci.yml" -Encoding UTF8

# Scripts directory
New-Item -ItemType Directory -Path "scripts" -Force | Out-Null

# Database initialization script
$initDbScript = @"
-- Initialize database with extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create indexes for full-text search (will be added by Prisma migrations)
-- This file can be extended with additional setup scripts
"@
$initDbScript | Out-File -FilePath "scripts\init-db.sql" -Encoding UTF8

# Development setup script
$devSetupScript = @"
#!/usr/bin/env bash# Main server index
$serverIndex = @"
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import path from 'path';
import { PrismaClient } from '@prisma/client';
import { config } from './config';
import authRoutes from './routes/auth';
import bookRoutes from './routes/books';
import { errorHandler, notFound } from './middleware/error';

const app = express();
const prisma = new PrismaClient();

// Trust proxy (for rate limiting behind reverse proxy)
app.set('trust proxy', 1);

// Security middleware
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' }
}));

// CORS
app.use(cors(config.cors));

// Rate limiting
const limiter = rateLimit({
  windowMs: config.rateLimit.windowMs,
  max: config.rateLimit.max,
  message: {
    success: false,
    error: 'Too many requests, please try again later',
  },
});
app.use('/api/', limiter);

// Compression
app.use(compression());

// Logging
app.use(morgan(config.nodeEnv === 'development' ? 'dev' : 'combined'));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Static files - serve uploaded images
app.use('/uploads', express.static(path.resolve(process.cwd(), config.uploads.dir), {
  maxAge: '1d',
  etag: true,
}));

// Health check
app.get('/health', async (_req, res) => {
  try {
    await prisma.$queryRaw\`SELECT 1\`;
    res.json({
      status: 'OK',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: 'connected',
    });
  } catch (error) {
    res.status(503).json({
      status: 'ERROR',
      timestamp: new Date().toISOString(),
      database: 'disconnected',
    });
  }
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/books', bookRoutes);

// 404 handler
app.use('*', notFound);

// Global error handler
app.use(errorHandler);

// Graceful shutdown
async function gracefulShutdown(signal: string) {
  console.log(\`📧 Received \${signal}, shutting down gracefully...\`);
  
  try {
    await prisma.$disconnect();
    console.log('✅ Database disconnected');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during shutdown:', error);
    process.exit(1);
  }
}

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Start server
app.listen(config.port, () => {
  console.log(\`🚀 Server running on http://localhost:\${config.port}\`);
  console.log(\`📚 Libriary API ready in \${config.nodeEnv} mode\`);
  console.log(\`📁 Serving uploads from: \${config.uploads.dir}\`);
});
"@
$serverIndex | Out-File -FilePath "src\index.ts" -Encoding UTF8

# Server TypeScript config
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
    "emitDecoratorMetadata": true,
    "declaration": false,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts", "**/*.spec.ts"]
}
"@
$serverTsConfig | Out-File -FilePath "tsconfig.json" -Encoding UTF8

# ==================== WEB PACKAGE ====================
Write-Status "Setting up web package..."
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
    "react-query": "^3.39.3",
    "react-hook-form": "^7.46.1",
    "@hookform/resolvers": "^3.3.1",
    "yup": "^1.3.2",
    "react-dropzone": "^14.2.3",
    "@headlessui/react": "^1.7.17",
    "@heroicons/react": "^2.0.18",
    "clsx": "^2.0.0",
    "date-fns": "^2.30.0",
    "react-hot-toast": "^2.4.1",
    "tailwindcss": "^3.3.3",
    "autoprefixer": "^10.4.15",
    "postcss": "^8.4.29",
    "@tailwindcss/forms": "^0.5.6",
    "@tailwindcss/aspect-ratio": "^0.4.2"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "lint": "eslint src/**/*.{ts,tsx}",
    "lint:fix": "eslint src/**/*.{ts,tsx} --fix",
    "typecheck": "tsc --noEmit"
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

# Create web directory structure
$webDirs = @("components", "pages", "services", "hooks", "utils", "context", "types")
foreach ($dir in $webDirs) {
    New-Item -ItemType Directory -Path "src\$dir" -Force | Out-Null
}
New-Item -ItemType Directory -Path "public" -Force | Out-Null

# Web environment
$webEnv = @"
REACT_APP_API_URL=http://localhost:3001/api
REACT_APP_UPLOADS_URL=http://localhost:3001/uploads
GENERATE_SOURCEMAP=true
"@
$webEnv | Out-File -FilePath ".env.example" -Encoding UTF8

# Tailwind config
$tailwindConfig = @"
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
  ],
}
"@
$tailwindConfig | Out-File -FilePath "tailwind.config.js" -Encoding UTF8

# PostCSS config
$postCSSConfig = @"
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
"@
$postCSSConfig | Out-File -FilePath "postcss.config.js" -Encoding UTF8

# Web app files
$webIndex = @"
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import { QueryClient, QueryClientProvider } from 'react-query';
import { BrowserRouter } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { Toaster } from 'react-hot-toast';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);

root.render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <AuthProvider>
          <App />
          <Toaster position="top-right" />
        </AuthProvider>
      </BrowserRouter>
    </QueryClientProvider>
  </React.StrictMode>
);
"@
$webIndex | Out-File -FilePath "src\index.tsx" -Encoding UTF8

# Basic web App component
$webApp = @"
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import Layout from './components/Layout';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import HomePage from './pages/HomePage';
import BooksPage from './pages/BooksPage';
import BookDetailPage from './pages/BookDetailPage';
import ProfilePage from './pages/ProfilePage';
import LoadingSpinner from './components/LoadingSpinner';

function App() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!user) {
    return (
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    );
  }

  return (
    <Layout>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/books" element={<BooksPage />} />
        <Route path="/books/:id" element={<BookDetailPage />} />
        <Route path="/profile" element={<ProfilePage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Layout>
  );
}

export default App;
"@
$webApp | Out-File -FilePath "src\App.tsx" -Encoding UTF8

# Web CSS
$webCSS = @"
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-gray-50 text-gray-900;
  }
}

@layer components {
  .btn {
    @apply inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2;
  }

  .btn-primary {
    @apply btn bg-primary-600 text-white hover:bg-primary-700 focus:ring-primary-500;
  }

  .btn-secondary {
    @apply btn bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500;
  }

  .btn-danger {
    @apply btn bg-red-600 text-white hover:bg-red-700 focus:ring-red-500;
  }

  .input {
    @apply block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500;
  }

  .card {
    @apply bg-white overflow-hidden shadow rounded-lg;
  }
}
"@
$webCSS | Out-File -FilePath "src\index.css" -Encoding UTF8

# Basic auth context (placeholder)
$authContext = @"
import React, { createContext, useContext, useState, useEffect } from 'react';
import { User } from '@libriary/shared';
import { authService } from '../services/authService';

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, name: string, password: string) => Promise<void>;
  logout: () => void;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      authService.getProfile()
        .then(setUser)
        .catch(() => {
          localStorage.removeItem('token');
        })
        .finally(() => setLoading(false));
    } else {
      setLoading(false);
    }
  }, []);

  const login = async (email: string, password: string) => {
    const { user: userData, token } = await authService.login(email, password);
    localStorage.setItem('token', token);
    setUser(userData);
  };

  const register = async (email: string, name: string, password: string) => {
    const { user: userData, token } = await authService.register(email, name, password);
    localStorage.setItem('token', token);
    setUser(userData);
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, register, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
"@
$null = New-Item -ItemType Directory -Path "src\context" -Force
$authContext | Out-File -FilePath "src\context\AuthContext.tsx" -Encoding UTF8

# Auth service
$authServiceWeb = @"
import axios from 'axios';
import { User, LoginRequest, RegisterRequest, AuthResponse, APIResponse } from '@libriary/shared';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = \`Bearer \${token}\`;
  }
  return config;
});

export const authService = {
  async login(email: string, password: string): Promise<AuthResponse> {
    const { data } = await api.post<AuthResponse>('/auth/login', { email, password });
    return data;
  },

  async register(email: string, name: string, password: string): Promise<AuthResponse> {
    const { data } = await api.post<AuthResponse>('/auth/register', { email, name, password });
    return data;
  },

  async getProfile(): Promise<User> {
    const { data } = await api.get<APIResponse<User>>('/auth/profile');
    return data.data!;
  },

  async updateProfile(updates: Partial<Pick<User, 'name' | 'email'>>): Promise<User> {
    const { data } = await api.put<APIResponse<User>>('/auth/profile', updates);
    return data.data!;
  },
};
"@
$authServiceWeb | Out-File -FilePath "src\services\authService.ts" -Encoding UTF8

# Basic components placeholders
$loadingSpinner = @"
import React from 'react';
import clsx from 'clsx';

interface LoadingSpinnerProps {
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export default function LoadingSpinner({ size = 'md', className }: LoadingSpinnerProps) {
  const sizeClasses = {
    sm: 'w-4 h-4',
    md: 'w-6 h-6',
    lg: 'w-8 h-8',
  };

  return (
    <div className={clsx('animate-spin rounded-full border-b-2 border-primary-600', sizeClasses[size], className)} />
  );
}
"@
$loadingSpinner | Out-File -FilePath "src\components\LoadingSpinner.tsx" -Encoding UTF8

# Basic layout component
$layoutComponent = @"
import React from 'react';
import { useAuth } from '../context/AuthContext';
import { Link, useLocation } from 'react-router-dom';
import { HomeIcon, BookOpenIcon, UserIcon, ArrowLeftOnRectangleIcon } from '@heroicons/react/24/outline';
import clsx from 'clsx';

interface LayoutProps {
  children: React.ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  const { user, logout } = useAuth();
  const location = useLocation();

  const navigation = [
    { name: 'Home', href: '/', icon: HomeIcon },
    { name: 'Books', href: '/books', icon: BookOpenIcon },
    { name: 'Profile', href: '/profile', icon: UserIcon },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex">
              <Link to="/" className="flex items-center">
                <span className="text-xl font-bold text-primary-600">📚 Libriary</span>
              </Link>
              <div className="ml-6 flex space-x-8">
                {navigation.map((item) => {
                  const Icon = item.icon;
                  const isActive = location.pathname === item.href;
                  return (
                    <Link
                      key={item.name}
                      to={item.href}
                      className={clsx(
                        'inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium',
                        isActive
                          ? 'border-primary-500 text-gray-900'
                          : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                      )}
                    >
                      <Icon className="w-4 h-4 mr-2" />
                      {item.name}
                    </Link>
                  );
                })}
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-700">Welcome, {user?.name}</span>
              <button
                onClick={logout}
                className="inline-flex items-center text-gray-500 hover:text-gray-700"
              >
                <ArrowLeftOnRectangleIcon className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        {children}
      </main>
    </div>
  );
}
"@
$layoutComponent | Out-File -FilePath "src\components\Layout.tsx" -Encoding UTF8

# Basic pages placeholders
$loginPage = @"
import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import toast from 'react-hot-toast';
import LoadingSpinner from '../components/LoadingSpinner';

export default function LoginPage() {
  const { login } = useAuth();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({ email: '', password: '' });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      await login(formData.email, formData.password);
      toast.success('Welcome back!');
    } catch (error: any) {
      toast.error(error.response?.data?.error || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            📚 Welcome to Libriary
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Sign in to your account
          </p>
        </div>
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div>
            <label htmlFor="email" className="sr-only">Email address</label>
            <input
              id="email"
              name="email"
              type="email"
              required
              className="input"
              placeholder="Email address"
              value={formData.email}
              onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
            />
          </div>
          <div>
            <label htmlFor="password" className="sr-only">Password</label>
            <input
              id="password"
              name="password"
              type="password"
              required
              className="input"
              placeholder="Password"
              value={formData.password}
              onChange={(e) => setFormData(prev => ({ ...prev, password: e.target.value }))}
            />
          </div>
          <div>
            <button type="submit" className="btn-primary w-full" disabled={loading}>
              {loading ? <LoadingSpinner size="sm" /> : 'Sign in'}
            </button>
          </div>
          <div className="text-center">
            <Link to="/register" className="text-primary-600 hover:text-primary-500">
              Don't have an account? Sign up
            </Link>
          </div>
        </form>
        <div className="mt-4 p-4 bg-blue-50 rounded-md">
          <p className="text-sm text-blue-700">
            <strong>Demo Account:</strong><br />
            Email: demo@libriary.com<br />
            Password: demo123
          </p>
        </div>
      </div>
    </div>
  );
}
"@
$loginPage | Out-File -FilePath "src\pages\LoginPage.tsx" -Encoding UTF8

$homePage = @"
import React from 'react';
import { useAuth } from '../context/AuthContext';
import { Link } from 'react-router-dom';
import { BookOpenIcon, PlusIcon } from '@heroicons/react/24/outline';

export default function HomePage() {
  const { user } = useAuth();

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">
          Welcome back, {user?.name}! 📚
        </h1>
        <p className="mt-2 text-gray-600">
          Manage your personal book collection
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <Link
          to="/books"
          className="card p-6 hover:shadow-lg transition-shadow cursor-pointer"
        >
          <div className="flex items-center">
            <BookOpenIcon className="w-8 h-8 text-primary-600 mr-3" />
            <div>
              <h3 className="text-lg font-medium text-gray-900">View Books</h3>
              <p className="text-gray-500">Browse your collection</p>
            </div>
          </div>
        </Link>

        <Link
          to="/books?action=add"
          className="card p-6 hover:shadow-lg transition-shadow cursor-pointer"
        >
          <div className="flex items-center">
            <PlusIcon className="w-8 h-8 text-green-600 mr-3" />
            <div>
              <h3 className="text-lg font-medium text-gray-900">Add Book</h3>
              <p className="text-gray-500">Add a new book to your library</p>
            </div>
          </div>
        </Link>
      </div>
    </div>
  );
}
"@
$homePage | Out-File -FilePath "src\pages\HomePage.tsx" -Encoding UTF8

# Create placeholder pages
$placeholderPages = @(
  "RegisterPage.tsx",
  "BooksPage.tsx", 
  "BookDetailPage.tsx",
  "ProfilePage.tsx"
)

foreach ($page in $placeholderPages) {
  $pageName = $page.Replace(".tsx", "")
  $placeholder = @"
import React from 'react';

export default function $pageName() {
  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900">$pageName</h1>
      <p className="text-gray-600">This page is under construction.</p>
    </div>
  );
}
"@
  $placeholder | Out-File -FilePath "src\pages\$page" -Encoding UTF8
}

# Web TypeScript config
$webTsConfig = @"
{
  "compilerOptions": {
    "target": "es5",
    "lib": [
      "dom",
      "dom.iterable",
      "esnext"
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

# Public HTML
$publicHTML = @"
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="Personal book archiving application" />
    <title>Libriary - Personal Book Archive</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
"@
$publicHTML | Out-File -FilePath "public\index.html" -Encoding UTF8

# ==================== MOBILE PACKAGE ====================
Write-Status "Setting up mobile package..."
Set-Location "..\mobile"

$# Libriary Complete Monorepo Setup Script for Windows
# Run this in PowerShell as Administrator

param(
    [switch]$SkipDependencyCheck,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

function Write-Status($Message, $Color = "Blue") {
    Write-Host "🚀 $Message" -ForegroundColor $Color
}

function Write-Success($Message) {
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning($Message) {
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Error($Message) {
    Write-Host "❌ $Message" -ForegroundColor Red
}

Write-Status "Setting up Libriary monorepo for Windows..."

# Check prerequisites
if (-not $SkipDependencyCheck) {
    Write-Status "Checking prerequisites..."
    
    # Check for pnpm
    try {
        $pnpmVersion = pnpm --version
        Write-Success "pnpm found: v$pnpmVersion"
    } catch {
        Write-Error "pnpm not found. Please install it first: npm install -g pnpm"
        exit 1
    }
    
    # Check for Node.js
    try {
        $nodeVersion = node --version
        Write-Success "Node.js found: $nodeVersion"
    } catch {
        Write-Error "Node.js not found. Please install Node.js 18+ first"
        exit 1
    }
    
    # Check for Docker (optional)
    try {
        docker --version | Out-Null
        Write-Success "Docker found"
    } catch {
        Write-Warning "Docker not found. You can still run the project but will need external PostgreSQL/Redis"
    }
}

# Create root directory and navigate
Write-Status "Creating project structure..."
New-Item -ItemType Directory -Path "libriary" -Force | Out-Null
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
    "db:generate": "cd packages/database && npx prisma generate",
    "db:migrate": "cd packages/database && npx prisma migrate dev",
    "db:studio": "cd packages/database && npx prisma studio",
    "db:seed": "cd packages/database && npx prisma db seed",
    "db:reset": "cd packages/database && npx prisma migrate reset",
    "setup": "pnpm install && pnpm run db:generate && pnpm run db:migrate && pnpm run db:seed",
    "setup:dev": "pnpm install && pnpm run docker:up && timeout 10 && pnpm run db:generate && pnpm run db:migrate && pnpm run db:seed",
    "clean": "powershell -Command \"Remove-Item -Recurse -Force node_modules, packages/*/node_modules, packages/*/build, packages/*/dist -ErrorAction SilentlyContinue\"",
    "typecheck": "pnpm run typecheck:server && pnpm run typecheck:web",
    "typecheck:server": "cd packages/server && tsc --noEmit",
    "typecheck:web": "cd packages/web && tsc --noEmit"
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

# Coverage directory
coverage/
*.lcov

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Cache directories
.cache
.parcel-cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Temporary folders
tmp/
temp/

# Database
*.db
*.sqlite
*.sqlite3

# Uploads directory (development)
uploads/

# Mobile
.expo/
expo-env.d.ts
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
"@
$gitignore | Out-File -FilePath ".gitignore" -Encoding UTF8

# Create environment files
$envExample = @"
# Database
DATABASE_URL=postgresql://libriary:libriary@localhost:5432/libriary

# JWT Authentication
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d

# Server
PORT=3001
NODE_ENV=development

# Redis (for queues)
REDIS_URL=redis://localhost:6379

# File uploads
UPLOADS_DIR=uploads
MAX_FILE_SIZE=10485760

# OCR Service (optional)
GOOGLE_VISION_API_KEY=your-google-vision-api-key

# MinIO/S3 (optional)
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
"@
$envExample | Out-File -FilePath ".env.example" -Encoding UTF8

# Create packages directory structure
Write-Status "Creating package directories..."
$packages = @("shared", "database", "server", "web", "mobile")
foreach ($pkg in $packages) {
    New-Item -ItemType Directory -Path "packages\$pkg" -Force | Out-Null
}
New-Item -ItemType Directory -Path "scripts" -Force | Out-Null

Write-Success "Package directories created"

# ==================== SHARED PACKAGE ====================
Write-Status "Setting up shared package..."
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

New-Item -ItemType Directory -Path "src\types" -Force | Out-Null
New-Item -ItemType Directory -Path "src\utils" -Force | Out-Null

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
  photos?: Photo[];
}

export interface Photo {
  id: string;
  filename: string;
  path: string;
  type: PhotoType;
  size?: number;
  mimeType?: string;
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
  genre?: string;
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
  meta?: {
    total?: number;
    page?: number;
    limit?: number;
  };
}

export interface PaginationParams {
  page?: number;
  limit?: number;
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

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  name: string;
  password: string;
}

export interface AuthResponse {
  success: boolean;
  token: string;
  data: User;
}

export interface CreateBookRequest {
  title: string;
  author?: string;
  isbn?: string;
  edition?: string;
  printSerial?: string;
  publisher?: string;
  publicationYear?: number;
  genre?: string;
  notes?: string;
  tags?: string[];
}

export interface UpdateBookRequest extends Partial<CreateBookRequest> {}
"@
$sharedTypes | Out-File -FilePath "src\types\index.ts" -Encoding UTF8

$sharedUtils = @"
export const formatDate = (date: Date | string): string => {
  const d = typeof date === 'string' ? new Date(date) : date;
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  }).format(d);
};

export const formatDateTime = (date: Date | string): string => {
  const d = typeof date === 'string' ? new Date(date) : date;
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(d);
};

export const generateId = (): string => {
  return Math.random().toString(36).substring(2) + Date.now().toString(36);
};

export const validateISBN = (isbn: string): boolean => {
  const cleaned = isbn.replace(/[-\s]/g, '');
  return /^(97[89])?\d{10}$/.test(cleaned);
};

export const cleanISBN = (isbn: string): string => {
  return isbn.replace(/[-\s]/g, '');
};

export const formatISBN = (isbn: string): string => {
  const cleaned = cleanISBN(isbn);
  if (cleaned.length === 13) {
    return `${cleaned.slice(0, 3)}-${cleaned.slice(3, 4)}-${cleaned.slice(4, 6)}-${cleaned.slice(6, 12)}-${cleaned.slice(12)}`;
  } else if (cleaned.length === 10) {
    return `${cleaned.slice(0, 1)}-${cleaned.slice(1, 4)}-${cleaned.slice(4, 9)}-${cleaned.slice(9)}`;
  }
  return cleaned;
};

export const extractISBN = (text: string): string | null => {
  const isbnRegex = /(?:ISBN(?:-1[03])?:?\s*)?(?=[-0-9\s]{10,}|[-0-9X\s]{10,}|[0-9X]{10,13})(?:97[89][-\s]?)?[0-9][-\s]?[0-9][-\s]?[0-9][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X][-\s]?[0-9X]?/gi;
  const matches = text.match(isbnRegex);
  return matches ? cleanISBN(matches[0]) : null;
};

export const capitalizeWords = (str: string): string => {
  return str.replace(/\w\S*/g, (txt) => 
    txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
  );
};

export const cleanText = (text: string): string => {
  return text.replace(/\s+/g, ' ').trim();
};

export const truncateText = (text: string, maxLength: number): string => {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength).trim() + '...';
};

export const slugify = (text: string): string => {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');
};

export const debounce = <T extends (...args: any[]) => any>(
  func: T,
  wait: number
): ((...args: Parameters<T>) => void) => {
  let timeout: NodeJS.Timeout | null = null;
  
  return (...args: Parameters<T>) => {
    if (timeout) clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), wait);
  };
};

export const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

export const isValidUrl = (url: string): boolean => {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
};

export const getFileExtension = (filename: string): string => {
  return filename.slice((filename.lastIndexOf(".") - 1 >>> 0) + 2);
};

export const isImageFile = (filename: string): boolean => {
  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'];
  return imageExtensions.includes(getFileExtension(filename).toLowerCase());
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

# ==================== DATABASE PACKAGE ====================
Write-Status "Setting up database package..."
Set-Location "..\database"

$databasePackageJson = @"
{
  "name": "@libriary/database",
  "version": "1.0.0",
  "description": "Database schema and migrations for Libriary",
  "scripts": {
    "generate": "prisma generate",
    "migrate": "prisma migrate dev",
    "studio": "prisma studio",
    "seed": "tsx seed/index.ts",
    "reset": "prisma migrate reset",
    "deploy": "prisma migrate deploy",
    "push": "prisma db push",
    "postinstall": "prisma generate"
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

New-Item -ItemType Directory -Path "prisma" -Force | Out-Null
New-Item -ItemType Directory -Path "seed" -Force | Out-Null

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
  ocrJobs         OCRJob[]

  @@index([userId])
  @@index([title])
  @@index([author])
  @@index([genre])
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

  @@index([bookId])
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
  bookId    String
  photoPath String?
  status    JobStatus @default(PENDING)
  result    Json?
  error     String?
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
  book      Book      @relation(fields: [bookId], references: [id], onDelete: Cascade)

  @@index([bookId])
  @@index([status])
  @@map("ocr_jobs")
}

enum JobStatus {
  PENDING
  PROCESSING
  COMPLETED
  FAILED
}

model UserSession {
  id        String   @id @default(cuid())
  userId    String
  token     String   @unique
  expiresAt DateTime
  createdAt DateTime @default(now())

  @@index([userId])
  @@index([token])
  @@map("user_sessions")
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
      notes: 'A masterpiece of American literature exploring themes of wealth, love, and the American Dream.',
    },
    {
      title: '1984',
      author: 'George Orwell',
      isbn: '9780451524935',
      publisher: 'Signet Classics',
      publicationYear: 1949,
      genre: 'Dystopian Fiction',
      tags: ['dystopian', 'political', 'classic'],
      notes: 'A chilling portrayal of totalitarian society and government surveillance.',
    },
    {
      title: 'To Kill a Mockingbird',
      author: 'Harper Lee',
      isbn: '9780446310789',
      publisher: 'Grand Central Publishing',
      publicationYear: 1960,
      genre: 'Literary Fiction',
      tags: ['social issues', 'american literature', 'classic'],
      notes: 'A powerful exploration of racial injustice and moral courage in the American South.',
    },
    {
      title: 'Dune',
      author: 'Frank Herbert',
      isbn: '9780441013593',
      publisher: 'Ace Books',
      publicationYear: 1965,
      genre: 'Science Fiction',
      tags: ['sci-fi', 'epic', 'space opera'],
      notes: 'An epic science fiction novel set in a distant future amidst a feudal interstellar society.',
    },
    {
      title: 'The Catcher in the Rye',
      author: 'J.D. Salinger',
      isbn: '9780316769174',
      publisher: 'Little, Brown and Company',
      publicationYear: 1951,
      genre: 'Literary Fiction',
      tags: ['coming of age', 'classic', 'american literature'],
      notes: 'A controversial but influential novel about teenage alienation and rebellion.',
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
  console.log('\n📋 Demo credentials:');
  console.log('   Email: demo@libriary.com');
  console.log('   Password: demo123');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error('⚠️ Seed error:', e);
    await prisma.$disconnect();
    process.exit(1);
  });
"@
$seedScript | Out-File -FilePath "seed\index.ts" -Encoding UTF8

# ==================== SERVER PACKAGE ====================
Write-Status "Setting up server package..."
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
    "clean": "powershell -Command \"Remove-Item -Recurse -Force dist -ErrorAction SilentlyContinue\"",
    "typecheck": "tsc --noEmit"
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
    "redis": "^4.6.10",
    "express-rate-limit": "^7.1.3",
    "compression": "^1.7.4"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.14",
    "@types/morgan": "^1.9.5",
    "@types/multer": "^1.4.8",
    "@types/jsonwebtoken": "^9.0.3",
    "@types/bcryptjs": "^2.4.4",
    "@types/node": "^20.6.3",
    "@types/compression": "^1.7.3",
    "typescript": "^5.2.2",
    "tsx": "^3.13.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.5",
    "nodemon": "^3.0.1"
  }
}
"@
$serverPackageJson | Out-File -FilePath "package.json" -Encoding UTF8

# Create server directory structure
$serverDirs = @("controllers", "middleware", "routes", "services", "utils", "config", "types")
foreach ($dir in $serverDirs) {
    New-Item -ItemType Directory -Path "src\$dir" -Force | Out-Null
}
New-Item -ItemType Directory -Path "uploads" -Force | Out-Null

# Server environment file
$serverEnv = @"
# Server
PORT=3001
NODE_ENV=development

# JWT
JWT_SECRET=super-secret-dev-token-change-in-production
JWT_EXPIRES_IN=7d

# Database
DATABASE_URL=postgresql://libriary:libriary@localhost:5432/libriary?schema=public

# Redis
REDIS_URL=redis://localhost:6379

# Files
UPLOADS_DIR=uploads
MAX_FILE_SIZE=10485760

# Rate limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
"@
$serverEnv | Out-File -FilePath ".env.example" -Encoding UTF8

# Server configuration
$serverConfig = @"
import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '3001', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  jwt: {
    secret: process.env.JWT_SECRET || 'change-me-in-production',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  uploads: {
    dir: process.env.UPLOADS_DIR || 'uploads',
    maxSize: parseInt(process.env.MAX_FILE_SIZE || '10485760', 10),
  },
  redis: {
    url: process.env.REDIS_URL || 'redis://localhost:6379',
  },
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  },
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    credentials: true,
  },
};
"@
$serverConfig | Out-File -FilePath "src\config\index.ts" -Encoding UTF8

# JWT utilities
$jwtUtil = @"
import jwt from 'jsonwebtoken';
import { config } from '../config';

export interface JwtPayload {
  sub: string; // user id
  email: string;
  iat?: number;
  exp?: number;
}

export const signToken = (payload: Omit<JwtPayload, 'iat' | 'exp'>): string => {
  return jwt.sign(payload, config.jwt.secret, { 
    expiresIn: config.jwt.expiresIn 
  });
};

export const verifyToken = (token: string): JwtPayload => {
  return jwt.verify(token, config.jwt.secret) as JwtPayload;
};

export const decodeToken = (token: string): JwtPayload | null => {
  try {
    return jwt.decode(token) as JwtPayload;
  } catch {
    return null;
  }
};
"@
$jwtUtil | Out-File -FilePath "src\utils\jwt.ts" -Encoding UTF8

# Auth middleware
$authMiddleware = @"
import type { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../utils/jwt';

export interface AuthedRequest extends Request {
  user?: { id: string; email: string };
}

export const requireAuth = (req: AuthedRequest, res: Response, next: NextFunction): void => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  
  if (!token) {
    res.status(401).json({ success: false, error: 'Missing authorization token' });
    return;
  }

  try {
    const payload = verifyToken(token);
    req.user = { id: payload.sub, email: payload.email };
    next();
  } catch (error) {
    res.status(401).json({ success: false, error: 'Invalid or expired token' });
    return;
  }
};

export const optionalAuth = (req: AuthedRequest, res: Response, next: NextFunction): void => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  
  if (token) {
    try {
      const payload = verifyToken(token);
      req.user = { id: payload.sub, email: payload.email };
    } catch {
      // Invalid token, but continue without user
    }
  }
  
  next();
};
"@
$authMiddleware | Out-File -FilePath "src\middleware\auth.ts" -Encoding UTF8

# Error handling middleware
$errorMiddleware = @"
import type { Request, Response, NextFunction } from 'express';
import { config } from '../config';

export interface AppError extends Error {
  statusCode?: number;
  status?: string;
  isOperational?: boolean;
}

export class ValidationError extends Error {
  statusCode = 400;
  status = 'fail';
  isOperational = true;

  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

export class AuthenticationError extends Error {
  statusCode = 401;
  status = 'fail';
  isOperational = true;

  constructor(message: string = 'Authentication required') {
    super(message);
    this.name = 'AuthenticationError';
  }
}

export class NotFoundError extends Error {
  statusCode = 404;
  status = 'fail';
  isOperational = true;

  constructor(message: string = 'Resource not found') {
    super(message);
    this.name = 'NotFoundError';
  }
}

export const errorHandler = (err: AppError, req: Request, res: Response, next: NextFunction): void => {
  let { statusCode = 500, message } = err;

  if (config.nodeEnv === 'development') {
    console.error('Error:', err);
  }

  // Prisma errors
  if (err.name === 'PrismaClientKnownRequestError') {
    statusCode = 400;
    message = 'Database operation failed';
  }

  // Validation errors
  if (err.name === 'ValidationError') {
    statusCode = 400;
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid token';
  }

  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token expired';
  }

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(config.nodeEnv === 'development' && { stack: err.stack }),
  });
};

export const notFound = (req: Request, res: Response): void => {
  res.status(404).json({
    success: false,
    error: `Route ${req.originalUrl} not found`,
  });
};
"@
$errorMiddleware | Out-File -FilePath "src\middleware\error.ts" -Encoding UTF8

# Photo service
$photoService = @"
import fs from 'fs/promises';
import path from 'path';
import sharp from 'sharp';
import { config } from '../config';

export interface ProcessedPhoto {
  path: string;
  size: number;
  width: number;
  height: number;
}

export async function processAndSavePhoto(
  filePath: string,
  type: 'COVER' | 'SPINE' | 'BACK' | 'INTERNAL'
): Promise<ProcessedPhoto> {
  try {
    const buffer = await fs.readFile(filePath);
    let pipeline = sharp(buffer).rotate(); // Auto-rotate based on EXIF

    // Apply different processing based on photo type
    switch (type) {
      case 'BACK':
      case 'INTERNAL':
        // Enhance text readability for OCR
        pipeline = pipeline
          .normalize()
          .sharpen({ sigma: 1, flat: 1, jagged: 2 })
          .threshold(128, { grayscale: false });
        break;
      case 'COVER':
      case 'SPINE':
        // Preserve colors and details for covers
        pipeline = pipeline.sharpen();
        break;
    }

    // Resize to max 1920px on longest side
    pipeline = pipeline.resize(1920, 1920, {
      fit: 'inside',
      withoutEnlargement: true,
    });

    // Convert to JPEG with good quality
    const processed = await pipeline.jpeg({ quality: 85 }).toBuffer();
    
    // Get metadata
    const metadata = await sharp(processed).metadata();
    
    // Save processed image
    await fs.writeFile(filePath, processed);

    // Return relative path from project root
    const relativePath = path.relative(process.cwd(), filePath).replace(/\\\\/g, '/');

    return {
      path: relativePath,
      size: processed.length,
      width: metadata.width || 0,
      height: metadata.height || 0,
    };
  } catch (error) {
    console.error('Error processing photo:', error);
    throw new Error('Failed to process photo');
  }
}

export async function deletePhoto(photoPath: string): Promise<void> {
  try {
    const fullPath = path.resolve(process.cwd(), photoPath);
    await fs.unlink(fullPath);
  } catch (error) {
    console.warn('Failed to delete photo:', photoPath, error);
  }
}

export function getPhotoUrl(photoPath: string, baseUrl: string): string {
  return `${baseUrl}/${photoPath}`;
}
"@
$photoService | Out-File -FilePath "src\services\photoService.ts" -Encoding UTF8

# Auth controller
$authController = @"
import type { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import Joi from 'joi';
import { signToken } from '../utils/jwt';
import type { AuthedRequest } from '../middleware/auth';
import { ValidationError, AuthenticationError } from '../middleware/error';

const prisma = new PrismaClient();

const registerSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Please provide a valid email address',
    'any.required': 'Email is required',
  }),
  name: Joi.string().min(2).max(80).required().messages({
    'string.min': 'Name must be at least 2 characters long',
    'string.max': 'Name cannot exceed 80 characters',
    'any.required': 'Name is required',
  }),
  password: Joi.string().min(6).max(128).required().messages({
    'string.min': 'Password must be at least 6 characters long',
    'string.max': 'Password cannot exceed 128 characters',
    'any.required': 'Password is required',
  }),
});

const loginSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Please provide a valid email address',
    'any.required': 'Email is required',
  }),
  password: Joi.string().min(6).max(128).required().messages({
    'string.min': 'Password must be at least 6 characters long',
    'any.required': 'Password is required',
  }),
});

export async function register(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      throw new ValidationError(error.details[0].message);
    }

    const { email, name, password } = value;

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({ 
      where: { email: email.toLowerCase() } 
    });
    
    if (existingUser) {
      res.status(409).json({ 
        success: false, 
        error: 'An account with this email already exists' 
      });
      return;
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const user = await prisma.user.create({
      data: { 
        email: email.toLowerCase(), 
        name: name.trim(), 
        password: hashedPassword 
      },
      select: { 
        id: true, 
        email: true, 
        name: true, 
        createdAt: true, 
        updatedAt: true 
      },
    });

    // Generate token
    const token = signToken({ sub: user.id, email: user.email });

    res.status(201).json({
      success: true,
      message: 'Account created successfully',
      data: user,
      token,
    });
  } catch (error) {
    next(error);
  }
}

export async function login(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      throw new ValidationError(error.details[0].message);
    }

    const { email, password } = value;

    // Find user
    const user = await prisma.user.findUnique({ 
      where: { email: email.toLowerCase() } 
    });
    
    if (!user) {
      throw new AuthenticationError('Invalid email or password');
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      throw new AuthenticationError('Invalid email or password');
    }

    // Generate token
    const token = signToken({ sub: user.id, email: user.email });

    res.json({
      success: true,
      message: 'Logged in successfully',
      token,
      data: {
        id: user.id,
        email: user.email,
        name: user.name,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
    });
  } catch (error) {
    next(error);
  }
}

export async function getProfile(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const userId = req.user!.id;
    
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
        updatedAt: true,
        _count: {
          select: {
            books: true,
          },
        },
      },
    });

    if (!user) {
      throw new AuthenticationError('User not found');
    }

    res.json({
      success: true,
      data: {
        ...user,
        booksCount: user._count.books,
      },
    });
  } catch (error) {
    next(error);
  }
}

export async function updateProfile(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const updateSchema = Joi.object({
      name: Joi.string().min(2).max(80).optional(),
      email: Joi.string().email().optional(),
    });

    const { error, value } = updateSchema.validate(req.body);
    if (error) {
      throw new ValidationError(error.details[0].message);
    }

    const userId = req.user!.id;
    const updateData: any = {};

    if (value.name) {
      updateData.name = value.name.trim();
    }

    if (value.email) {
      updateData.email = value.email.toLowerCase();
      
      // Check if email is already taken by another user
      const existingUser = await prisma.user.findFirst({
        where: {
          email: updateData.email,
          NOT: { id: userId },
        },
      });

      if (existingUser) {
        res.status(409).json({
          success: false,
          error: 'This email is already in use by another account',
        });
        return;
      }
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: updatedUser,
    });
  } catch (error) {
    next(error);
  }
}
"@
$authController | Out-File -FilePath "src\controllers\authController.ts" -Encoding UTF8

# Books controller
$booksController = @"
import type { Response, NextFunction } from 'express';
import { PrismaClient, PhotoType } from '@prisma/client';
import Joi from 'joi';
import type { AuthedRequest } from '../middleware/auth';
import { processAndSavePhoto, deletePhoto } from '../services/photoService';
import { ValidationError, NotFoundError } from '../middleware/error';

const prisma = new PrismaClient();

const createBookSchema = Joi.object({
  title: Joi.string().min(1).max(500).required().messages({
    'string.min': 'Title is required',
    'string.max': 'Title cannot exceed 500 characters',
    'any.required': 'Title is required',
  }),
  author: Joi.string().max(200).optional().allow('', null),
  isbn: Joi.string().max(20).optional().allow('', null),
  edition: Joi.string().max(100).optional().allow('', null),
  printSerial: Joi.string().max(100).optional().allow('', null),
  publisher: Joi.string().max(200).optional().allow('', null),
  publicationYear: Joi.number().integer().min(0).max(3000).optional().allow(null),
  genre: Joi.string().max(100).optional().allow('', null),
  notes: Joi.string().max(2000).optional().allow('', null),
  tags: Joi.array().items(Joi.string().max(50)).max(20).default([]),
});

const updateBookSchema = createBookSchema.fork(['title'], (schema) => schema.optional());

export async function listBooks(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const {
      page = '1',
      limit = '20',
      query,
      author,
      genre,
      tags,
      yearFrom,
      yearTo,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = req.query as Record<string, string>;

    const userId = req.user!.id;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    const take = Math.min(parseInt(limit), 100); // Max 100 items per page

    // Build where clause
    const where: any = { userId };

    if (query) {
      where.OR = [
        { title: { contains: query, mode: 'insensitive' } },
        { author: { contains: query, mode: 'insensitive' } },
        { isbn: { contains: query, mode: 'insensitive' } },
        { publisher: { contains: query, mode: 'insensitive' } },
        { genre: { contains: query, mode: 'insensitive' } },
        { notes: { contains: query, mode: 'insensitive' } },
      ];
    }

    if (author) {
      where.author = { contains: author, mode: 'insensitive' };
    }

    if (genre) {
      where.genre = { contains: genre, mode: 'insensitive' };
    }

    if (tags) {
      const tagArray = tags.split(',').map(tag => tag.trim());
      where.tags = { hasSome: tagArray };
    }

    if (yearFrom || yearTo) {
      where.publicationYear = {};
      if (yearFrom) where.publicationYear.gte = parseInt(yearFrom);
      if (yearTo) where.publicationYear.lte = parseInt(yearTo);
    }

    // Build order by
    const validSortFields = ['title', 'author', 'createdAt', 'updatedAt', 'publicationYear'];
    const orderBy: any = {};
    
    if (validSortFields.includes(sortBy)) {
      orderBy[sortBy] = sortOrder === 'asc' ? 'asc' : 'desc';
    } else {
      orderBy.createdAt = 'desc';
    }

    // Execute queries
    const [books, total] = await Promise.all([
      prisma.book.findMany({
        where,
        skip,
        take,
        orderBy,
        include: {
          photos: {
            select: {
              id: true,
              filename: true,
              path: true,
              type: true,
              size: true,
              mimeType: true,
              createdAt: true,
            },
          },
          _count: {
            select: {
              photos: true,
            },
          },
        },
      }),
      prisma.book.count({ where }),
    ]);

    res.json({
      success: true,
      data: books,
      meta: {
        total,
        page: parseInt(page),
        limit: take,
        pages: Math.ceil(total / take),
        hasNext: skip + take < total,
        hasPrev: parseInt(page) > 1,
      },
    });
  } catch (error) {
    next(error);
  }
}

export async function getBook(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    const book = await prisma.book.findFirst({
      where: { id, userId },
      include: {
        photos: {
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    if (!book) {
      throw new NotFoundError('Book not found');
    }

    res.json({
      success: true,
      data: book,
    });
  } catch (error) {
    next(error);
  }
}

export async function createBook(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { error, value } = createBookSchema.validate(req.body);
    if (error) {
      throw new ValidationError(error.details[0].message);
    }

    const userId = req.user!.id;
    
    // Clean up the data
    const bookData = {
      ...value,
      title: value.title.trim(),
      author: value.author?.trim() || null,
      isbn: value.isbn?.trim() || null,
      publisher: value.publisher?.trim() || null,
      genre: value.genre?.trim() || null,
      notes: value.notes?.trim() || null,
      tags: value.tags?.map((tag: string) => tag.trim()).filter((tag: string) => tag.length > 0) || [],
      userId,
    };

    const book = await prisma.book.create({
      data: bookData,
      include: {
        photos: true,
      },
    });

    res.status(201).json({
      success: true,
      message: 'Book created successfully',
      data: book,
    });
  } catch (error) {
    next(error);
  }
}

export async function updateBook(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const { error, value } = updateBookSchema.validate(req.body);
    if (error) {
      throw new ValidationError(error.details[0].message);
    }

    const userId = req.user!.id;
    const { id } = req.params;

    // Check ownership
    const existingBook = await prisma.book.findFirst({
      where: { id, userId },
    });

    if (!existingBook) {
      throw new NotFoundError('Book not found');
    }

    // Clean up the data
    const updateData: any = {};
    
    if (value.title !== undefined) updateData.title = value.title.trim();
    if (value.author !== undefined) updateData.author = value.author?.trim() || null;
    if (value.isbn !== undefined) updateData.isbn = value.isbn?.trim() || null;
    if (value.publisher !== undefined) updateData.publisher = value.publisher?.trim() || null;
    if (value.genre !== undefined) updateData.genre = value.genre?.trim() || null;
    if (value.notes !== undefined) updateData.notes = value.notes?.trim() || null;
    if (value.tags !== undefined) {
      updateData.tags = value.tags?.map((tag: string) => tag.trim()).filter((tag: string) => tag.length > 0) || [];
    }
    if (value.publicationYear !== undefined) updateData.publicationYear = value.publicationYear;
    if (value.edition !== undefined) updateData.edition = value.edition?.trim() || null;
    if (value.printSerial !== undefined) updateData.printSerial = value.printSerial?.trim() || null;

    const updatedBook = await prisma.book.update({
      where: { id },
      data: updateData,
      include: {
        photos: true,
      },
    });

    res.json({
      success: true,
      message: 'Book updated successfully',
      data: updatedBook,
    });
  } catch (error) {
    next(error);
  }
}

export async function deleteBook(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    // Check ownership and get photos for cleanup
    const book = await prisma.book.findFirst({
      where: { id, userId },
      include: {
        photos: true,
      },
    });

    if (!book) {
      throw new NotFoundError('Book not found');
    }

    // Delete associated photos from filesystem
    for (const photo of book.photos) {
      await deletePhoto(photo.path);
    }

    // Delete book (cascade will handle photos in DB)
    await prisma.book.delete({
      where: { id },
    });

    res.json({
      success: true,
      message: 'Book deleted successfully',
    });
  } catch (error) {
    next(error);
  }
}

export async function addPhotos(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const userId = req.user!.id;
    const { id } = req.params;

    // Check if book exists and user owns it
    const book = await prisma.book.findFirst({
      where: { id, userId },
    });

    if (!book) {
      throw new NotFoundError('Book not found');
    }

    const files = (req.files as Express.Multer.File[]) || [];
    if (!files.length) {
      throw new ValidationError('No files uploaded');
    }

    const typeMap: Record<string, PhotoType> = {
      cover: 'COVER',
      spine: 'SPINE',
      back: 'BACK',
      internal: 'INTERNAL',
    };

    const photosToCreate = [];
    
    for (const file of files) {
      const fieldName = (file.fieldname || '').toLowerCase();
      const photoType = typeMap[fieldName] || 'INTERNAL';
      
      try {
        const processed = await processAndSavePhoto(file.path, photoType);
        
        photosToCreate.push({
          filename: file.filename,
          path: processed.path,
          type: photoType,
          bookId: book.id,
          size: processed.size,
          mimeType: file.mimetype,
        });
      } catch (error) {
        console.error(`Failed to process photo ${file.filename}:`, error);
        // Continue with other photos
      }
    }

    if (photosToCreate.length === 0) {
      throw new ValidationError('No photos could be processed');
    }

    // Create photo records
    await prisma.photo.createMany({
      data: photosToCreate,
    });

    // Return updated book with photos
    const updatedBook = await prisma.book.findUnique({
      where: { id: book.id },
      include: {
        photos: {
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    res.status(201).json({
      success: true,
      message: `${photosToCreate.length} photo(s) uploaded successfully`,
      data: updatedBook,
    });
  } catch (error) {
    next(error);
  }
}

export async function deletePhoto(req: AuthedRequest, res: Response, next: NextFunction): Promise<void> {
  try {
    const userId = req.user!.id;
    const { id: bookId, photoId } = req.params;

    // Check if book exists and user owns it
    const book = await prisma.book.findFirst({
      where: { id: bookId, userId },
    });

    if (!book) {
      throw new NotFoundError('Book not found');
    }

    // Find and delete photo
    const photo = await prisma.photo.findFirst({
      where: { id: photoId, bookId },
    });

    if (!photo) {
      throw new NotFoundError('Photo not found');
    }

    // Delete from filesystem
    await deletePhoto(photo.path);

    // Delete from database
    await prisma.photo.delete({
      where: { id: photoId },
    });

    res.json({
      success: true,
      message: 'Photo deleted successfully',
    });
  } catch (error) {
    next(error);
  }
}
"@
$booksController | Out-File -FilePath "src\controllers\booksController.ts" -Encoding UTF8

# Routes
$authRoutes = @"
import { Router } from 'express';
import { register, login, getProfile, updateProfile } from '../controllers/authController';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.get('/profile', requireAuth, getProfile);
router.put('/profile', requireAuth, updateProfile);

export default router;
"@
$authRoutes | Out-File -FilePath "src\routes\auth.ts" -Encoding UTF8

$bookRoutes = @"
import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { requireAuth } from '../middleware/auth';
import {
  listBooks,
  getBook,
  createBook,
  updateBook,
  deleteBook,
  addPhotos,
  deletePhoto,
} from '../controllers/booksController';
import { config } from '../config';

const router = Router();

// Ensure upload directory exists
const uploadDir = path.resolve(process.cwd(), config.uploads.dir);
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadDir);
  },
  filename: (_req, file, cb) => {
    const timestamp = Date.now();
    const safeName = file.originalname.replace(/[^a-zA-Z0-9_.-]/g, '_');
    cb(null, `${timestamp}_${safeName}`);
  },
});

const fileFilter = (req: any, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  // Accept only images
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Only image files are allowed'));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: config.uploads.maxSize,
    files: 10, // Max 10 files per request
  },
});

// Book routes
router.get('/', requireAuth, listBooks);
router.get('/:id', requireAuth, getBook);
router.post('/', requireAuth, createBook);
router.put('/:id', requireAuth, updateBook);
router.delete('/:id', requireAuth, deleteBook);

// Photo routes
router.post('/:id/photos', requireAuth, upload.any(), addPhotos);
router.delete('/:id/photos/:photoId', requireAuth, deletePhoto);

export default router;
"@

