# 🎉 npnameyrapp v1.1‑master — Enhanced Camera Trap Workflow (Master Branch Snapshot)

## 📖 Summary
This release expands the modular Shiny application for wildlife monitoring workflows (App1 & App2).  
It introduces auto‑folder creation, hybrid image+video integration, species input auto‑fill, activity overlap plots, and improved onboarding with automatic package checks.

**Rilis ini memperluas aplikasi Shiny modular untuk workflow monitoring satwa liar (App1 & App2).  
Menambahkan fitur auto‑folder, integrasi gambar+video, auto‑fill input spesies, plot overlap aktivitas, serta peningkatan pengalaman startup dengan pengecekan paket otomatis.**

---

## 🚀 Key New Features

### App1 – Camera Trap Data Processing
- Auto‑folder creation for input/output paths  
- Hybrid **image + video integration** when building camera trap tables  

### App2 – Species Analysis & Reports
- Auto‑folder creation for App2 outputs  
- Data preview (100–1000 rows) from App1 results  
- Species‑input auto‑fill using tag list → smoother GBIF validation  
- Activity overlap plots for **two species**  
- Overlap coefficient estimation with confidence intervals  
- Bootstrap customization (1000–10000 runs) with summary tables  

### General Improvements
- **Automatic package check at startup**  
  - ✔ Packages loaded successfully → app launches  
  - ❌ Missing packages → clear install instructions in console  
- Improved onboarding experience for beginners  
- Console messages guide users step‑by‑step until:  
  *“All packages are ready. You can now launch the app.”*

---

## 📂 Included in This Release
- Updated source code for App1 & App2  
- New launch script: `RUN_appv1.1.R`  
- New folders: `script/launch-v1-1/`, `KEY_APP2/`  
- Updated documentation: `README.md`, `CHANGELOG.md`, `CITATION.cff`, `RELEASES.md`  
- `.Rprofile` for startup environment  
- Updated species tag list and images  

---

## 🔧 Requirements
- R 4.3.3  
- RStudio Desktop 2025  
- digiKam 8.3.0  
- RTools 4.3  
- ExifTool (for image/video metadata)  
- Packages: `camtrapR`, `overlap`, `RPresence`, `shiny`, `janitor`, `magick`, etc.  

---

## 📌 Notes
- Published from **master branch** for reproducibility and DOI minting via Zenodo.  
- Use the **Zenodo DOI snapshot** for citation.  
- Use the **GitHub release ZIP** for stable deployment.  
- Use the **master branch ZIP** for latest development fixes (kernel plot axis, clock labels, daylight shading).  

---

## 📥 Download
- [Zenodo DOI Snapshot](https://doi.org/10.5281/zenodo.[new_DOI])  
- [GitHub Release ZIP](https://github.com/ariefalpinus/npnameyrapp/archive/refs/tags/v1.1-master.zip)  
- [Master Branch ZIP](https://github.com/ariefalpinus/npnameyrapp/archive/refs/heads/master.zip)  

---

## 🔑 Keywords
Auto‑folder creation · Hybrid CT data (image+video) · Data preview · Species auto‑fill · GBIF validation · Activity overlap plots · Overlap coefficient estimation · Bootstrap customization · Confidence intervals · Automatic package check · User‑friendly onboarding