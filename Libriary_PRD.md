
# Libriary — Product Requirements Document (PRD)

## 1. Overview

**Libriary** is a personal book archiving application that allows users to catalog their physical books with photos of the exact copies they own.  
The app will analyze photos to extract metadata (title, author, ISBN, edition, print serial), organize the collection, and make it accessible via both a **web app** and a future **native Android app**.

Initially designed for personal use, Libriary will be **multi-user ready** for future expansion.  
The application will store and analyze already-taken photos (not live camera feed), enabling users to batch import images for processing.

---

## 2. Objectives

- Provide a **modern, scalable, and intuitive** tool for cataloging books.
- Enable **automatic metadata extraction** from cover and internal pages.
- Support **manual metadata entry and editing**.
- Offer **cross-platform** access via web and Android app.
- Prepare the architecture for **future integration** with external databases, including audiobook collections.

---

## 3. Core Features

### 3.1 Photo Import & Processing
- Import multiple images at once from phone or desktop.
- Supported formats: JPG, PNG, HEIC.
- Automatic orientation correction and cropping.
- Image enhancement for readability (brightness, contrast, skew correction).
- **Automatic OCR** from:
  - Cover page (title, author, ISBN).
  - Internal page (edition, print serial).
- Optional manual data entry when OCR fails.

### 3.2 Book Metadata
- **Auto-detected fields**:
  - Title
  - Author
  - ISBN
  - Edition
  - Print serial number
  - Publisher
  - Publication year (if available)
- **User-entered fields**:
  - Genre
  - Personal notes
  - Tags

### 3.3 Organization & Search
- View library in **grid** or **list** mode.
- Filters: author, genre, year, tags.
- Full-text search.

### 3.4 Multi-User Ready Architecture
- Single-user mode at launch.
- Prepared backend structure for multiple users with separate libraries.

### 3.5 Data Management
- Local storage for personal mode.
- Cloud sync (future feature) with account login.
- Manual export/import in CSV or JSON.

### 3.6 Future Integration
- API endpoints for linking with external audiobook databases.
- Optional NFC tagging for quick book identification.

---

## 4. Photo Workflow Recommendations

For best results, each book should have:

1. **Front cover photo** — well-lit, straight angle.
2. **Spine photo** — straight angle, capturing full text.
3. **Back cover photo** — straight angle, readable text.
4. **Internal info page photo** — flat, front-facing shot of the colophon/credits page showing edition and serial.

File naming suggestion during capture:
```
B001_cover.jpg
B001_spine.jpg
B001_back.jpg
B001_internal.jpg
```

---

## 5. Technical Specifications

### 5.1 Platform
- Web App: React + Node.js backend
- Android App: Flutter or React Native
- Backend: Node.js or Python (FastAPI) + PostgreSQL
- OCR: Tesseract OCR (on-device or server-side)

### 5.2 Scalability
- Modular architecture
- Cloud-ready backend (AWS/GCP/Azure)
- Prepared for multi-tenant database design

### 5.3 Security
- HTTPS encryption for all communications
- User authentication (JWT tokens)
- Prepared for future OAuth integration

---

## 6. UI/UX Guidelines
- Modern and minimal design aligned with other personal apps.
- Light and dark mode.
- Intuitive upload flow with drag & drop.
- Inline editing of book details.

---

## 7. Roadmap

### Phase 1 — MVP (Personal Archive)
- Web app
- Local storage
- Photo import and processing
- Automatic OCR for metadata
- Basic search and filtering

### Phase 2 — Android App
- Sync with web version
- Offline mode
- Push notifications for batch processing completion

### Phase 3 — Multi-User Support
- Account system
- Cloud sync
- Role-based access

### Phase 4 — Integrations & Automation
- Audiobook database sync
- NFC tagging
- Advanced analytics

---

## 8. Success Metrics
- **Import accuracy**: >90% correct OCR recognition for clean, well-lit images.
- **User satisfaction**: >80% in feedback surveys.
- **Performance**: Batch process 50 books in under 2 minutes (server mode).

---

## 9. Constraints & Assumptions
- Initial version will **not** include live camera capture.
- User will prepare and upload photos in correct angles.
- Cloud sync and multi-user will be developed later.

---

## 10. Appendices

### 10.1 Future Enhancements
- Barcode scanning for ISBN via camera.
- AI-based genre classification.
- Automatic duplicate detection.

---

**Document version:** 1.0  
**Date:** 2025-08-15  
**Project Name:** Libriary
