# Personal Book Archive App

## 1. Vision
Creare un archivio digitale personale dei libri posseduti, con foto, informazioni automatiche (ISBN, titolo, autore), edizione e numero di stampa, categorie personalizzate, filtri avanzati e note personali. L’app deve essere disponibile come **web app** e come **app Android**, con possibilità futura di sincronizzazione multi-device e integrazione con il database di audiobook.

---

## 2. Obiettivi principali
- Catalogare i libri con foto già scattate dal telefono  
- Riconoscimento automatico libro tramite ISBN/barcode/OCR  
- Estrazione automatica dall’interno del libro di: edizione e numero di stampa/seriale  
- Creazione di categorie personalizzate e filtri avanzati  
- Aggiunta di note e recensioni personali  
- Visualizzazione statistiche base (numero libri, generi, autori)  

### Obiettivi futuri / low priority
- Multi-utente (possibilità di gestire librerie separate)  
- Sincronizzazione cloud e multi-device  
- Integrazione con database di audiobook  
- Miglioramenti automatici alle foto (ritaglio, correzione prospettiva e luminosità)

---

## 3. Funzionalità principali

### 3.1 Inserimento libro
- Caricamento foto esistente dal telefono o PC  
- Analisi foto: OCR, riconoscimento ISBN/barcode  
- Precompilazione automatica dei campi: titolo, autore, anno, casa editrice, lingua  
- Analisi foto interna per estrazione **edizione** e **numero di stampa/seriale**  
- Possibilità di aggiungere note personali  

### 3.2 Organizzazione libreria
- Creazione di categorie personalizzate  
- Filtri per genere, autore, anno, lingua, stato (letto/non letto)  
- Ordinamento alfabetico o per data di inserimento  

### 3.3 Visualizzazione libreria
- Lista libri con miniature delle foto  
- Dettaglio libro con informazioni complete e note  
- Statistiche base: numero totale libri, distribuzione per genere/autore  

### 3.4 Funzionalità future
- Backup/manual sync tra dispositivi  
- Multi-utente  
- Integrazione con audiobook (collegamento tra libro cartaceo e audio)  
- Miglioramento foto automatico (ritaglio, correzione prospettiva e luminosità)

---

## 4. User Stories

### 4.1 Inserimento libro
- **Come utente**, voglio caricare una foto di un libro già scattata, **perché** voglio catalogarlo senza riscrivere tutte le informazioni.  
- **Come utente**, voglio che l’app riconosca automaticamente titolo, autore e ISBN, **perché** risparmio tempo.  
- **Come utente**, voglio che l’app estragga automaticamente l’edizione e il numero di stampa dalla pagina interna, **perché** voglio registrare dettagli precisi dell’edizione posseduta.  

### 4.2 Organizzazione libreria
- **Come utente**, voglio creare categorie personalizzate, **perché** voglio raggruppare i libri in collezioni logiche.  
- **Come utente**, voglio filtrare i libri per autore, genere o anno, **perché** voglio trovare velocemente un libro specifico.  

### 4.3 Visualizzazione libreria
- **Come utente**, voglio vedere una lista con miniature dei libri, **perché** voglio riconoscere i libri visivamente.  
- **Come utente**, voglio visualizzare statistiche sui libri, **perché** voglio conoscere la mia distribuzione per genere e autore.  

---

## 5. Flusso utente e schermate principali
1. **Home** – Lista dei libri con miniature, filtri e ricerca  
2. **Dettaglio libro** – Foto, informazioni riconosciute, edizione/seriale, note personali  
3. **Aggiungi libro** – Caricamento foto, analisi automatica, campi modificabili  
4. **Categorie/Collezioni** – Creazione e gestione categorie personalizzate  
5. **Statistiche** – Grafici e numeri base sulla libreria  

---

## 6. Stack tecnologico consigliato
- **Backend**: Node.js + Express o FastAPI (Python)  
- **Database**: PostgreSQL o MongoDB  
- **Frontend Web**: React + Material UI / Tailwind  
- **App Android**: Flutter (cross-platform, permette futura conversione iOS)  
- **Analisi immagini**: OpenCV + Tesseract OCR + Google Books API per riconoscimento ISBN; OCR mirato per edizione e numero di stampa dalla pagina interna  
- **Hosting / Cloud**: AWS / Firebase (per storage foto e backup futuro)  

---

## 7. Requisiti tecnici e vincoli
- Supporto per caricamento di foto già esistenti, non in live camera  
- Analisi automatica foto con correzione prospettiva e luminosità  
- Estrazione automatica edizione e numero di stampa/seriale dalla pagina interna  
- Funzionamento offline con sincronizzazione manuale futura  
- Architettura scalabile per futuro multi-utente e integrazione audiobook  
- UI/UX semplice, responsive e moderna  

---

## 8. Priorità funzionalità
| Funzionalità                     | Priorità |
|---------------------------------|----------|
| Caricamento foto esistente       | Alta     |
| Riconoscimento automatico libro  | Alta     |
| Estrazione edizione e numero di stampa | Alta |
| Categorie personalizzate         | Alta     |
| Filtri e ricerca avanzata        | Alta     |
| Note personali                   | Media    |
| Statistiche base                 | Media    |
| Multi-utente                     | Bassa    |
| Backup/manual sync               | Bassa    |
| Integrazione audiobook           | Bassa    |
| Miglioramento foto automatico    | Bassa    |
