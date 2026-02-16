# Changelog

All notable changes to the AD_PAC project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation suite
  - Main README.md with project overview
  - CITATION.md with preprint reference
  - REQUIREMENTS.md with detailed dependency information
  - QUICKSTART.md for rapid onboarding
  - CONTRIBUTING.md with contribution guidelines
  - Module-specific READMEs for each pipeline stage
- LICENSE file (MIT License)
- .gitignore for keeping repository clean
- CHANGELOG.md for tracking changes

### Changed
- Initial documentation release

### Deprecated
- None

### Removed
- None

### Fixed
- None

### Security
- None

## [1.0.0] - 2026-02-16

### Added
- Initial release of AD_PAC pipeline
- Head modeling pipeline (anatomyTransform, buildHeadModels, processBSFiles, removeElec)
- Preprocessing pipeline (preprocessing, interpolate_bad_channels, detect_bad_trials, plot_data)
- Source reconstruction pipeline (sourceReconstruction_p, lcmv_meg, and helper functions)
- PAC analysis pipeline (seedRoitoCortex, er_pac, er_pac_3, test_pac)
- Statistical analysis pipeline (prepareTable, powerAnalysis, clusterBasedModel, linearMixedEffectsModel)
- Python scripts for visualization (Fig_creator.py, cluster_based_perm.py)
- Supporting data files (roi_name.mat, dk_labels.mat, cm17.mat, mask.mat)

## Release Notes

### Version 1.0.0 (2026-02-16)

First public release of the AD_PAC pipeline. This version includes:

**Features:**
- Complete pipeline from raw MEG data to statistical analysis
- Support for CTF MEG systems (275 channels)
- Integration with FieldTrip, Brainstorm, and FreeSurfer
- Cluster-based permutation testing
- Linear mixed-effects modeling
- Comprehensive documentation

**Data:**
- Compatible with data from OSF repository: https://osf.io/pd4h9/overview
- Supports Desikan-Killiany cortical parcellation
- Analyzes theta/alpha - low-gamma PAC

**Requirements:**
- MATLAB R2018b or later
- FieldTrip toolbox
- Brainstorm toolbox
- FreeSurfer 6.0 or later

**Known Limitations:**
- Currently optimized for CTF MEG systems
- Requires substantial computational resources
- FreeSurfer preprocessing can take 6-24 hours per subject

**Citation:**
If you use this release, please cite:
- Preprint: https://www.medrxiv.org/content/10.64898/2026.02.06.26345635v1

---

## Future Plans

### Planned for Version 1.1.0
- [ ] Support for additional MEG systems (Neuromag, KIT)
- [ ] GPU acceleration for PAC computation
- [ ] Additional PAC metrics (MI, MVL, GLM)
- [ ] Automated quality control metrics
- [ ] Example dataset for testing

### Planned for Version 1.2.0
- [ ] Web-based visualization interface
- [ ] Batch processing utilities
- [ ] Docker container for easier deployment
- [ ] Integration with BIDS standard

### Long-term Goals
- [ ] Real-time PAC analysis capabilities
- [ ] Machine learning classification features
- [ ] Support for combined MEG/EEG analysis
- [ ] Cloud computing integration

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.

## Versioning

We use [Semantic Versioning](https://semver.org/):
- MAJOR version for incompatible API changes
- MINOR version for new functionality in a backwards compatible manner
- PATCH version for backwards compatible bug fixes

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.
