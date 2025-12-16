# Changelog
All notable changes to **npnameyrapp** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),  
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [1.0.1] - 2025-12-16
### Changed
- Refactored `makeKernelPlot()` to unify axis scaling and labeling logic across single- and multi-species modes.
- Improved visual consistency of single-species kernel plots with controlled axis limits and readable clock-style labels.

### Fixed
- Resolved misalignment issue in single-species kernel plots caused by implicit axis scaling in `densityPlot()`.
- Restored daylight shading blocks and reference lines for single-species plots centered at midnight or noon.

---

## [Unreleased]
- Planned improvements and upcoming features will be listed here.
- Roadmap: v1.1 → v2.0 → National Deployment

---

## [1.0-master] - 2025-11-26
### Added
- Re‑published **npnameyrapp v1.0** from the master branch
- DOI minted via Zenodo: [10.5281/zenodo.17725255](https://doi.org/10.5281/zenodo.17725255)
- Updated `README.md` with DOI badge and download links
- Revised `CITATION.cff` to include DOI and correct version metadata

### Changed
- Documentation alignment for reproducibility (README, CITATION, badges)

### Fixed
- Clarified release notes to distinguish between `v1.0.0` (main branch) and `v1.0-master` (master branch)

---

## [1.0.0] - 2025-11-20
### Added
- Initial release of **npnameyrapp v1.0**
- App1 workflow:
  - Record Table
  - Camera Operation Matrix
  - Survey Report
  - `App1_output.RData`
- App2 workflow:
  - GBIF validation table
  - RAI table
  - Kernel Density Plot (PNG, 600 dpi)
  - Static Occupancy Table
- Documentation files:
  - `README.md`
  - `LICENSE.md`
  - `CITATION.cff`
  - `CONTRIBUTING.md`
  - `FAQ.md`

### Changed
- N/A (first release)

### Fixed
- N/A (first release)

---

## [0.1.0] - 2025-10-15 (Pre-release)
### Added
- Prototype Shiny app structure
- Basic folder layout (`data/`, `workdir/`, `script/`)
- Draft onboarding documentation

---

## How to Update This File
- Add a new section for each release (e.g., `## [1.1.0] - YYYY-MM-DD`).  
- Use **Added**, **Changed**, **Fixed**, and **Removed** subsections.  
- Keep entries concise but informative for staff and collaborators.  