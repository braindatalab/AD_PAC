# Requirements and Dependencies

This document details the software requirements and dependencies needed to run the AD_PAC pipeline.

## System Requirements

### Hardware Requirements

**Minimum**:
- CPU: Multi-core processor (4+ cores recommended)
- RAM: 16 GB
- Storage: 50 GB free space (for data and results)

**Recommended**:
- CPU: 8+ cores for parallel processing
- RAM: 32 GB or more
- Storage: 100+ GB SSD for faster I/O
- GPU: Optional, for accelerated computations in some toolboxes

### Operating System

The pipeline has been tested on:
- **Linux**: Ubuntu 18.04+, CentOS 7+, or similar
- **macOS**: 10.14 (Mojave) or later
- **Windows**: Windows 10 or later (with some limitations for FreeSurfer)

Note: FreeSurfer runs natively on Linux and macOS. Windows users may need to use WSL (Windows Subsystem for Linux) or a virtual machine.

## Software Dependencies

### 1. MATLAB

**Version**: R2018b or later (R2020a+ recommended)

**Required Toolboxes**:
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox
- Image Processing Toolbox (for NIfTI handling)
- Parallel Computing Toolbox (optional, for speedup)

**Installation**:
- Download from [MathWorks](https://www.mathworks.com/products/matlab.html)
- Academic licenses typically include required toolboxes
- Verify installation: `ver` command in MATLAB

### 2. FieldTrip Toolbox

**Version**: Latest stable release (tested with 20240110 and later)

**Purpose**: 
- MEG/EEG preprocessing
- Data visualization
- Channel repair and artifact rejection

**Installation**:
1. Download from [FieldTrip website](https://www.fieldtriptoolbox.org/download/)
   ```bash
   git clone https://github.com/fieldtrip/fieldtrip.git
   ```

2. Add to MATLAB path in your script:
   ```matlab
   addpath('/path/to/fieldtrip/');
   ft_defaults;
   ```

**Configuration**:
- No special configuration required
- Ensure all subdirectories are in the path
- Run `ft_defaults` once per MATLAB session

**Documentation**: [https://www.fieldtriptoolbox.org/](https://www.fieldtriptoolbox.org/)

### 3. Brainstorm Toolbox

**Version**: Latest stable release (tested with version 3.230101 and later)

**Purpose**:
- Head model construction
- Forward modeling with OpenMEEG
- MEG/MRI coregistration

**Installation**:
1. Download from [Brainstorm website](https://neuroimage.usc.edu/brainstorm/Installation)
   ```bash
   # Or download directly in MATLAB
   ```

2. Add to MATLAB path:
   ```matlab
   addpath('/path/to/brainstorm3/');
   ```

3. Start Brainstorm GUI once to complete setup:
   ```matlab
   brainstorm;
   ```

**Configuration**:
- Set up OpenMEEG during first launch
- Configure paths in Brainstorm preferences
- Test with sample dataset

**OpenMEEG**:
- Integrated within Brainstorm
- No separate installation needed
- Used for boundary element method (BEM) forward modeling

**Documentation**: [https://neuroimage.usc.edu/brainstorm/](https://neuroimage.usc.edu/brainstorm/)

### 4. FreeSurfer

**Version**: 6.0 or later (7.0+ recommended)

**Purpose**:
- Cortical surface extraction
- Brain segmentation
- Surface parcellation (Desikan-Killiany atlas)

**Installation**:

**Linux/macOS**:
1. Download from [FreeSurfer website](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall)
2. Extract and set environment variables:
   ```bash
   export FREESURFER_HOME=/path/to/freesurfer
   source $FREESURFER_HOME/SetUpFreeSurfer.sh
   ```
3. Add to your `.bashrc` or `.bash_profile` for persistent setup

**Windows**:
- Use WSL (Windows Subsystem for Linux)
- Or use a Linux virtual machine
- Native Windows version has limitations

**License**:
- Free for academic use
- Register for license at FreeSurfer website
- Place license.txt in $FREESURFER_HOME

**Usage**:
FreeSurfer processing is a prerequisite, run before the MATLAB pipeline:
```bash
# Process anatomical MRI
recon-all -s SubjectID -i /path/to/MRI.nii -all

# Typical processing time: 6-24 hours per subject
```

**Documentation**: [https://surfer.nmr.mgh.harvard.edu/](https://surfer.nmr.mgh.harvard.edu/)

## Data Requirements

### Input Data Format

**MEG Data**:
- Format: MAT files (MATLAB)
- Structure: Should contain MEG data in FieldTrip-compatible format
- Naming: `[SubjectID]_meg_rest_60sec.mat`
- Channels: CTF MEG system (275 channels)
- Sampling rate: 600 Hz or similar

**MRI Data**:
- Format: NIfTI (.nii, .nii.gz) or DICOM
- Type: T1-weighted anatomical MRI
- Resolution: 1mm isotropic (typical)
- Must be processed with FreeSurfer before pipeline

**Clinical Data**:
- Format: CSV or Excel
- Required fields:
  - Subject ID
  - Group (AD / Control)
  - Age
  - Sex
  - MMSE score (or other cognitive measures)
- Optional: Education, disease duration, medications, etc.

### Data Organization

```
AD_PAC/
├── Dataset/
│   ├── Sub001_meg_rest_60sec.mat
│   ├── Sub002_meg_rest_60sec.mat
│   ├── ...
│   ├── Sub001_mri.nii
│   ├── Sub002_mri.nii
│   ├── ...
│   └── clinical_data.csv
```

### Data Availability

Sample data can be downloaded from:
- **OSF Repository**: [https://osf.io/pd4h9/overview](https://osf.io/pd4h9/overview)

## Installation Checklist

- [ ] Install MATLAB (R2018b+)
  - [ ] Verify required toolboxes: `ver`
- [ ] Install FieldTrip
  - [ ] Add to MATLAB path
  - [ ] Test: `ft_defaults`
- [ ] Install Brainstorm
  - [ ] Add to MATLAB path
  - [ ] Configure OpenMEEG
  - [ ] Test with sample data
- [ ] Install FreeSurfer
  - [ ] Set environment variables
  - [ ] Obtain and install license
  - [ ] Test: `recon-all -version`
- [ ] Download MEG/MRI data
  - [ ] Place in `Dataset/` folder
  - [ ] Verify file formats and naming
- [ ] Clone AD_PAC repository
  - [ ] Set `main_path` in `main.m`
  - [ ] Add repository to MATLAB path

## Verification

### Test MATLAB Installation

```matlab
% Check MATLAB version
version

% Check installed toolboxes
ver

% Test basic operations
x = randn(100, 100);
y = fft2(x);
disp('MATLAB working correctly');
```

### Test FieldTrip

```matlab
% Add FieldTrip to path
addpath('/path/to/fieldtrip/');
ft_defaults;

% Check version
ft_version

% Should display version info without errors
```

### Test Brainstorm

```matlab
% Add Brainstorm to path
addpath('/path/to/brainstorm3/');

% Start Brainstorm (GUI will open)
brainstorm;

% Should open without errors
```

### Test FreeSurfer

```bash
# Check version
recon-all -version

# Check license
cat $FREESURFER_HOME/license.txt

# Test on sample data (optional)
recon-all -s bert -all
```

## Troubleshooting

### Common Issues

**MATLAB Toolbox Missing**:
```
Error: Undefined function 'fft' for input arguments of type 'double'.
Solution: Install Signal Processing Toolbox
```

**FieldTrip Not Found**:
```
Error: Undefined function 'ft_preprocessing'.
Solution: 
1. Add FieldTrip to path: addpath('/path/to/fieldtrip/')
2. Run: ft_defaults
```

**Brainstorm OpenMEEG Error**:
```
Error: OpenMEEG not configured
Solution: 
1. Open Brainstorm GUI
2. Go to File > Edit preferences
3. Configure OpenMEEG path
```

**FreeSurfer License Missing**:
```
Error: No valid license found
Solution:
1. Register at FreeSurfer website
2. Download license.txt
3. Place in $FREESURFER_HOME/
```

### Getting Help

- **MATLAB**: [MathWorks Support](https://www.mathworks.com/support.html)
- **FieldTrip**: [Discussion List](https://mailman.science.ru.nl/mailman/listinfo/fieldtrip)
- **Brainstorm**: [Forum](https://neuroimage.usc.edu/forums/)
- **FreeSurfer**: [Mailing List](https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferSupport)

## Version Compatibility

| Software | Minimum Version | Recommended | Tested With |
|----------|----------------|-------------|-------------|
| MATLAB | R2018b | R2020a+ | R2020b, R2021a, R2022b |
| FieldTrip | 20200101 | Latest | 20240110 |
| Brainstorm | 3.200101 | Latest | 3.230101 |
| FreeSurfer | 6.0 | 7.0+ | 7.1, 7.2 |

## Performance Optimization

### MATLAB Optimization

```matlab
% Use parallel processing
parpool('local', 8);  % Use 8 cores

% Increase Java heap size
java.lang.Runtime.getRuntime.maxMemory / 1024^3  % Check current
% Edit matlab.prf to increase if needed
```

### System Optimization

- **Storage**: Use SSD for data and results
- **Memory**: Close unnecessary applications
- **CPU**: Disable power saving, enable high-performance mode

## Updates and Maintenance

### Keeping Software Updated

**MATLAB**: 
- Update through MATLAB interface or website
- Check for updates: Help > Check for Updates

**FieldTrip**:
```bash
cd /path/to/fieldtrip/
git pull origin master
```

**Brainstorm**:
- Update through Brainstorm GUI: Help > Update Brainstorm

**FreeSurfer**:
- Download new version and reinstall
- Or use package manager if available

### Checking for Breaking Changes

Before updating:
1. Review release notes
2. Test with sample data
3. Keep backup of working versions

## Additional Resources

- [MATLAB Documentation](https://www.mathworks.com/help/matlab/)
- [FieldTrip Tutorial](https://www.fieldtriptoolbox.org/tutorial/)
- [Brainstorm Tutorials](https://neuroimage.usc.edu/brainstorm/Tutorials)
- [FreeSurfer Tutorial](https://surfer.nmr.mgh.harvard.edu/fswiki/Tutorials)
- [MEG Analysis Best Practices](https://www.sciencedirect.com/science/article/pii/S1053811918306827)

## Contact

For issues specific to this pipeline, please open an issue on the [GitHub repository](https://github.com/braindatalab/AD_PAC/issues).
