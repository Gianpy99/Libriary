# Libriary Development Setup & Architecture Plan

## Architecture Overview

### Technology Stack
- **Frontend Web**: React 18+ with TypeScript
- **Frontend Mobile**: React Native with Expo (cross-platform for iOS/Android)
- **Backend**: Node.js with Express + TypeScript
- **Database**: PostgreSQL with Prisma ORM
- **File Storage**: AWS S3 or local filesystem (development)
- **OCR Processing**: Tesseract.js (client-side) + Google Vision API (server-side)
- **Image Processing**: Sharp (Node.js) + React Native Image libraries

### Project Structure
```
libriary/
├── packages/
│   ├── web/                    # React web app
│   ├── mobile/                 # React Native app
│   ├── server/                 # Node.js backend API
│   ├── shared/                 # Shared types and utilities
│   └── database/               # Database schemas and migrations
├── docker-compose.yml
├── package.json               # Root package.json for monorepo
└── README.md
```

## Development Environment Setup

### Prerequisites
```bash
# Node.js (v18+)
curl -fsSL https://fnm.vercel.app/install | bash
fnm install 18
fnm use 18

# Package manager
npm install -g pnpm

# Mobile development
npm install -g @expo/cli
npm install -g react-native-cli

# Database
# PostgreSQL via Docker (recommended)
# or local installation
```

### Initial Setup Commands
```bash
# 1. Initialize monorepo
mkdir libriary && cd libriary
pnpm init

# 2. Setup workspace structure
mkdir -p packages/{web,mobile,server,shared,database}

# 3. Initialize each package
cd packages/web && npx create-react-app . --template typescript
cd ../mobile && npx create-expo-app . --template blank-typescript
cd ../server && pnpm init && mkdir src
cd ../shared && pnpm init
cd ../database && pnpm init

# 4. Setup Docker for development
# (Docker Compose file provided below)
```

## Backend API Architecture

### Core Endpoints
```typescript
// Authentication
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout
GET    /api/auth/profile

// Books
GET    /api/books              # List all books with filters
POST   /api/books              # Create new book
GET    /api/books/:id          # Get book details
PUT    /api/books/:id          # Update book
DELETE /api/books/:id          # Delete book

// Photos
POST   /api/books/:id/photos   # Upload photos for a book
GET    /api/books/:id/photos   # Get book photos
DELETE /api/photos/:id         # Delete specific photo

// OCR Processing
POST   /api/ocr/process        # Process image for metadata
GET    /api/ocr/status/:jobId  # Check processing status

// Search & Filters
GET    /api/search             # Full-text search
GET    /api/filters            # Get available filter options
```

### Database Schema (Prisma)
```prisma
// schema.prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  books     Book[]
}

model Book {
  id              String    @id @default(cuid())
  title           String
  author          String?
  isbn            String?
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
  user            User      @relation(fields: [userId], references: [id])
  photos          Photo[]
}

model Photo {
  id       String    @id @default(cuid())
  filename String
  path     String
  type     PhotoType
  bookId   String
  book     Book      @relation(fields: [bookId], references: [id])
  createdAt DateTime @default(now())
}

enum PhotoType {
  COVER
  SPINE
  BACK
  INTERNAL
}
```

## Camera Integration

### Web Application (React)
```typescript
// Camera component for web
import { useCallback, useRef, useState } from 'react';

export const CameraCapture = () => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [stream, setStream] = useState<MediaStream | null>(null);
  
  const startCamera = useCallback(async () => {
    try {
      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: { 
          facingMode: 'environment', // Use back camera
          width: { ideal: 1920 },
          height: { ideal: 1080 }
        }
      });
      setStream(mediaStream);
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
      }
    } catch (error) {
      console.error('Camera access denied:', error);
    }
  }, []);

  const capturePhoto = useCallback(() => {
    if (videoRef.current && canvasRef.current) {
      const context = canvasRef.current.getContext('2d');
      context?.drawImage(videoRef.current, 0, 0);
      
      return canvasRef.current.toBlob((blob) => {
        if (blob) {
          // Process the captured image
          processImage(blob);
        }
      }, 'image/jpeg', 0.8);
    }
  }, []);

  return (
    <div className="camera-container">
      <video ref={videoRef} autoPlay playsInline />
      <canvas ref={canvasRef} style={{ display: 'none' }} />
      <button onClick={startCamera}>Start Camera</button>
      <button onClick={capturePhoto}>Capture</button>
    </div>
  );
};
```

### Mobile Application (React Native)
```typescript
// Camera component for React Native
import { Camera, CameraType } from 'expo-camera';
import { useState, useRef } from 'react';
import { View, TouchableOpacity, Text } from 'react-native';

export const MobileCameraCapture = () => {
  const [type, setType] = useState(CameraType.back);
  const [permission, requestPermission] = Camera.useCameraPermissions();
  const cameraRef = useRef<Camera>(null);

  if (!permission) {
    return <View />;
  }

  if (!permission.granted) {
    return (
      <View>
        <Text>We need your permission to show the camera</Text>
        <TouchableOpacity onPress={requestPermission}>
          <Text>Grant Permission</Text>
        </TouchableOpacity>
      </View>
    );
  }

  const takePicture = async () => {
    if (cameraRef.current) {
      const photo = await cameraRef.current.takePictureAsync({
        quality: 0.8,
        base64: false,
        skipProcessing: false,
      });
      
      // Process the captured image
      await processImage(photo.uri);
    }
  };

  return (
    <View style={{ flex: 1 }}>
      <Camera style={{ flex: 1 }} type={type} ref={cameraRef}>
        <View style={{
          flex: 1,
          backgroundColor: 'transparent',
          flexDirection: 'row',
          justifyContent: 'center',
          alignItems: 'flex-end',
          paddingBottom: 20
        }}>
          <TouchableOpacity onPress={takePicture}>
            <Text style={{ fontSize: 18, color: 'white' }}>Capture</Text>
          </TouchableOpacity>
        </View>
      </Camera>
    </View>
  );
};
```

## OCR Integration

### Client-Side OCR (Tesseract.js)
```typescript
// OCR processing utility
import Tesseract from 'tesseract.js';

export const extractTextFromImage = async (
  imageFile: File | string,
  options: { 
    lang?: string;
    psm?: number;
  } = {}
): Promise<{ text: string; confidence: number }> => {
  const { lang = 'eng', psm = 6 } = options;
  
  const { data } = await Tesseract.recognize(
    imageFile,
    lang,
    {
      logger: m => console.log(m),
      tessedit_pageseg_mode: psm,
      tessedit_char_whitelist: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-.,: '
    }
  );

  return {
    text: data.text,
    confidence: data.confidence
  };
};

// Metadata extraction
export const extractBookMetadata = async (images: {
  cover?: File;
  spine?: File;
  back?: File;
  internal?: File;
}) => {
  const metadata: Partial<BookMetadata> = {};
  
  if (images.cover) {
    const coverText = await extractTextFromImage(images.cover);
    metadata.title = extractTitle(coverText.text);
    metadata.author = extractAuthor(coverText.text);
  }
  
  if (images.internal) {
    const internalText = await extractTextFromImage(images.internal);
    metadata.isbn = extractISBN(internalText.text);
    metadata.edition = extractEdition(internalText.text);
    metadata.publisher = extractPublisher(internalText.text);
  }
  
  return metadata;
};
```

## Development Workflow

### Package.json Scripts
```json
{
  "name": "libriary-monorepo",
  "scripts": {
    "dev": "concurrently \"pnpm run dev:server\" \"pnpm run dev:web\"",
    "dev:server": "cd packages/server && pnpm run dev",
    "dev:web": "cd packages/web && pnpm run start",
    "dev:mobile": "cd packages/mobile && expo start",
    "build": "pnpm run build:server && pnpm run build:web",
    "build:server": "cd packages/server && pnpm run build",
    "build:web": "cd packages/web && pnpm run build",
    "test": "pnpm run test:server && pnpm run test:web",
    "docker:up": "docker-compose up -d",
    "docker:down": "docker-compose down",
    "db:migrate": "cd packages/database && npx prisma migrate dev",
    "db:studio": "cd packages/database && npx prisma studio"
  },
  "workspaces": [
    "packages/*"
  ]
}
```

### Docker Compose Setup
```yaml
# docker-compose.yml
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
```

## Photo Processing Pipeline

### Image Enhancement
```typescript
// Image processing utility (server-side)
import sharp from 'sharp';

export const processBookPhoto = async (
  inputBuffer: Buffer,
  type: 'cover' | 'spine' | 'back' | 'internal'
): Promise<Buffer> => {
  let processing = sharp(inputBuffer);
  
  // Auto-rotate based on EXIF
  processing = processing.rotate();
  
  // Enhance for OCR readability
  if (type === 'internal' || type === 'back') {
    processing = processing
      .normalize() // Auto levels
      .sharpen({ sigma: 1, flat: 1, jagged: 2 }) // Text sharpening
      .threshold(128) // High contrast for text
      .negate({ alpha: false }); // Invert if needed
  }
  
  // Resize to manageable size
  processing = processing.resize(1920, 1080, {
    fit: 'inside',
    withoutEnlargement: true
  });
  
  return processing.jpeg({ quality: 85 }).toBuffer();
};
```

## Getting Started Checklist

### Phase 1: Environment Setup
- [ ] Install Node.js 18+, pnpm, Expo CLI
- [ ] Initialize monorepo structure
- [ ] Setup Docker containers (PostgreSQL, Redis, MinIO)
- [ ] Configure Prisma and run initial migration
- [ ] Setup basic Express server with TypeScript

### Phase 2: Core Backend
- [ ] Implement authentication endpoints
- [ ] Create book CRUD operations
- [ ] Setup file upload handling
- [ ] Integrate OCR processing queue
- [ ] Add search and filtering

### Phase 3: Web Frontend
- [ ] Setup React app with TypeScript
- [ ] Implement camera capture functionality
- [ ] Create book management interface
- [ ] Add photo upload and processing
- [ ] Integrate OCR results display

### Phase 4: Mobile App
- [ ] Setup React Native with Expo
- [ ] Implement camera functionality
- [ ] Create mobile-optimized UI
- [ ] Add offline capabilities
- [ ] Setup push notifications

### Phase 5: Integration & Testing
- [ ] End-to-end testing
- [ ] Performance optimization
- [ ] Security audit
- [ ] Deployment preparation

## Development Timeline

- **Week 1-2**: Environment setup and backend foundation
- **Week 3-4**: Core API development and database design
- **Week 5-6**: Web frontend with camera integration
- **Week 7-8**: Mobile app development
- **Week 9-10**: OCR integration and optimization
- **Week 11-12**: Testing, deployment, and documentation

This setup provides a solid foundation for building the Libriary app with both web and mobile camera capabilities while maintaining scalability for future enhancements.