# Libriary — Product Requirements Document (PRD) v1.1

## 1. Overview
**Libriary** è un’app per archiviare e organizzare una collezione personale di **libri, DVD, Blu-ray e CD audio**.  
Gli utenti possono caricare foto (scattate in precedenza) e l’app tenterà di riconoscere automaticamente il contenuto tramite **OCR, AI e web search (es. database pubblici come ISBN/UPC/Discogs/OMDb)**.  
Se l’identificazione non è univoca, l’utente potrà inserire manualmente i metadati, che verranno memorizzati e mantenuti insieme al resto dell’archivio.

---

## 2. Objectives
- Unificare in un’unica app la gestione di **libri, musica e film** fisici.  
- Offrire un processo semplice: **foto → riconoscimento → catalogazione**.  
- Supportare sia **riconoscimento automatico**, sia **inserimento manuale** quando necessario.  
- Mantenere una struttura dati scalabile e multi-user ready.  

---

## 3. Core Features (Updated)

### 3.1 Photo Import & Recognition
- Importazione batch di immagini già scattate (no live camera all’inizio).  
- OCR per testi rilevanti (titoli, autori, codici ISBN/UPC).  
- Web lookup in database esterni:
  - **Libri** → ISBN, Google Books API, OpenLibrary.  
  - **DVD/Blu-ray** → UPC, OMDb, TMDb.  
  - **CD audio** → UPC, Discogs API, MusicBrainz.  
- Matching fuzzy con AI: se più risultati possibili, proporre suggerimenti.  
- **Manual override**: se non trovato o ambiguo, l’utente inserisce i dati.  

### 3.2 Metadata per Media Type

#### Libri
- Titolo  
- Autore  
- ISBN  
- Edizione  
- Serial number di stampa  
- Editore / Anno  
- Tags / Note personali  

#### DVD / Blu-ray
- Titolo  
- Regista  
- Attori principali  
- Anno di uscita  
- Codice UPC / EAN  
- Lingue e sottotitoli (se rilevabili o inseriti manualmente)  
- Tags / Note personali  

#### CD Audio
- Titolo album  
- Artista / Gruppo  
- Anno  
- Codice UPC / EAN  
- Tracklist (se disponibile da API o manualmente inserita)  
- Tags / Note personali  

### 3.3 Unified Library
- Visualizzazione per **categoria** (Libri, DVD, Blu-ray, CD) o vista unificata.  
- Filtri: autore/artista, genere, anno, formato.  
- Ricerca full-text.  

### 3.4 Manual Input Storage
- Ogni campo inserito manualmente dall’utente viene **marcato come “user entered”** e salvato nel database.  
- In futuro, possibilità di contribuire questi dati per arricchire un archivio condiviso.  

---

## 4. Photo Workflow Recommendations
- **Libri** → 4 foto: cover, dorso, retro, pagina interna con edizione.  
- **DVD/Blu-ray/CD** → 3 foto: cover frontale, retro, disco (facoltativo).  

Naming suggestion:  
```
M001_cover.jpg
M001_back.jpg
M001_disc.jpg
```

---

## 5. Technical Specifications (Updated)

- OCR: Tesseract OCR.  
- AI/Web APIs:  
  - Google Books API / OpenLibrary.  
  - OMDb / TMDb per film.  
  - Discogs / MusicBrainz per musica.  
- Database: PostgreSQL con schema multi-entità (Books, Movies, Music).  
- UI: Vista unificata + tab per tipo media.  

---

## 6. Roadmap (Updated)

**Phase 1** — MVP (Books + manual entry for other media)  
**Phase 2** — Extend recognition to DVD/Blu-ray/CD with API integration  
**Phase 3** — Android app + sync  
**Phase 4** — Multi-user & cloud sync  
**Phase 5** — NFC tagging & audiobook integration  
