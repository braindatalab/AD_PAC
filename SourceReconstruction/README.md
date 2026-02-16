# Source Reconstruction Pipeline

This directory contains scripts for reconstructing neural sources from sensor-level MEG data using beamforming techniques.

## Overview

The source reconstruction pipeline transforms preprocessed MEG sensor data into estimated neural activity on the cortical surface using the Linearly Constrained Minimum Variance (LCMV) beamformer.

## Main Script

### sourceReconstruction_p.m

**Purpose**: Orchestrates the complete source reconstruction pipeline for all subjects.

**Input**:
- Preprocessed MEG data from `Dataset/Preprocessed/`
- Head models and leadfields from `HeadModelling/` pipeline
- ROI definitions and cortical parcellations

**Output**:
- Source-space time series for cortical ROIs
- Saved in `Results/source/[SubjectID]/source_rec_results.mat`

**Processing Steps**:
1. Load preprocessed data and head model
2. Compute data covariance matrix
3. Calculate LCMV beamformer spatial filters
4. Project sensor data to source space
5. Extract time series for predefined ROIs
6. Save results for subsequent PAC analysis

**Usage**:
```matlab
sourceReconstruction_p;
```

## Core Functions

### lcmv_meg.m

**Purpose**: Implements the LCMV beamformer algorithm for MEG source reconstruction.

**Method**: Linearly Constrained Minimum Variance (LCMV) beamformer

**Algorithm**:
```
For each source location:
1. Extract leadfield vector L for that location
2. Compute spatial filter: W = (L' * C^-1 * L)^-1 * L' * C^-1
   where C is the data covariance matrix
3. Apply filter to sensor data: S = W * M
   where M is the sensor data, S is the source activity
```

**Input**:
- Leadfield matrix (n_sources × n_sensors)
- MEG sensor data (n_sensors × n_timepoints)
- Data covariance matrix (n_sensors × n_sensors)

**Output**:
- Source time series (n_sources × n_timepoints)
- Spatial filter weights (n_sources × n_sensors)

**Parameters**:
```matlab
cfg.lambda = 0.05;          % Regularization parameter (5%)
cfg.fixedori = 'yes';       % Use fixed dipole orientation
cfg.normalize = 'yes';      % Normalize spatial filters
```

**Key Features**:
- Regularized covariance inversion for numerical stability
- Handles rank-deficient covariance matrices
- Supports fixed or free dipole orientation
- Efficient vectorized computation

### shrinkage.m

**Purpose**: Performs covariance shrinkage regularization to stabilize matrix inversion.

**Method**: Ledoit-Wolf shrinkage estimator

**Why**: MEG covariance matrices are often ill-conditioned due to:
- Limited number of trials
- Correlated sensor signals
- Noise and artifacts

**Algorithm**:
```
C_shrunk = (1 - λ) * C_sample + λ * C_prior

where:
- C_sample: Sample covariance matrix
- C_prior: Prior covariance (often diagonal)
- λ: Shrinkage parameter (automatically estimated)
```

**Input**:
- Sample covariance matrix
- Optional: Prior covariance structure

**Output**:
- Regularized covariance matrix
- Optimal shrinkage parameter

### fp_get_lf.m

**Purpose**: Loads and prepares leadfield matrices for source reconstruction.

**Input**:
- Subject ID
- Path to leadfield files

**Output**:
- Leadfield matrix in appropriate format
- Source locations and orientations
- ROI definitions

**Processing**:
1. Load leadfield from head model
2. Select channels matching MEG data
3. Apply any necessary transformations
4. Return in format compatible with beamformer

### data2cs_event.m

**Purpose**: Converts MEG trial data to cross-spectral density matrices.

**Input**:
- Epoched MEG data (trials × channels × time)

**Output**:
- Cross-spectral density matrix (channels × channels × frequency)

**Method**:
- Fourier transform each trial
- Compute cross-spectrum: CS(f) = X(f) * X(f)'
- Average across trials

**Usage**: For frequency-specific source reconstruction

### data2spwctrgc.m

**Purpose**: Computes spectral connectivity measures in source space.

**Input**:
- Source time series
- Frequency bands of interest

**Output**:
- Spectral power
- Coherence matrices
- Granger causality (optional)

**Applications**:
- Frequency-specific source analysis
- Connectivity analysis between ROIs

### cs2psd.m

**Purpose**: Converts cross-spectral density to power spectral density.

**Input**:
- Cross-spectral density matrix

**Output**:
- Power spectral density for each channel/source

**Method**: Extract diagonal elements (auto-spectra) from cross-spectral matrix

## Helper Functions

### colormap_interpol.m

**Purpose**: Creates custom colormaps for visualization.

**Usage**: Generates smooth color gradients for plotting brain activity

## Dependencies

### External Software

1. **FieldTrip Toolbox**: [https://www.fieldtriptoolbox.org/](https://www.fieldtriptoolbox.org/)
   - Source reconstruction functions
   - Covariance estimation

### MATLAB Toolboxes

- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox

## Configuration

Key parameters in `sourceReconstruction_p.m`:

```matlab
% Beamformer settings
cfg.method = 'lcmv';
cfg.lambda = 0.05;              % Regularization (5%)
cfg.fixedori = 'yes';           % Fixed dipole orientation

% Frequency bands
freq_bands = [1 4;              % Delta
              4 8;              % Theta
              8 12;             % Alpha
              13 30;            % Beta
              30 55];           % Low-Gamma

% ROI selection
roi_atlas = 'Desikan-Killiany'; % Cortical parcellation
include_hippocampus = true;     % Include subcortical ROIs
```

## Expected Runtime

Source reconstruction is moderately intensive:
- **Load data and head model**: ~1 minute per subject
- **Compute covariance**: ~2-5 minutes per subject
- **Beamformer computation**: ~10-30 minutes per subject (depends on source space resolution)
- **ROI extraction**: ~1-2 minutes per subject

Total: ~15-40 minutes per subject

## Output Structure

```
Results/
└── source/
    └── [SubjectID]/
        └── source_rec_results.mat
            ├── source_roi_data      # Time series for each ROI (ROIs × PCs × time)
            ├── labels               # ROI labels
            ├── regions_cortex       # Cortical region definitions
            ├── spatial_filters      # Beamformer weights
            └── source_locations     # 3D coordinates of sources
```

### Data Format

**source_roi_data**: 
- Dimensions: (n_rois × n_pcs × n_timepoints)
- n_rois: Number of cortical and subcortical ROIs
- n_pcs: Principal components per ROI (typically 3)
- n_timepoints: Time samples at 600 Hz sampling rate

**labels**: Cell array of ROI names (e.g., 'L_hippocampus', 'R_superiorfrontal')

**regions_cortex**: Structure with cortical parcellation information

## ROI Extraction

The pipeline extracts source activity for predefined regions:

### Cortical ROIs (Desikan-Killiany Atlas)
34 regions per hemisphere, including:
- Frontal: Superior frontal, middle frontal, precentral, etc.
- Temporal: Superior temporal, middle temporal, fusiform, etc.
- Parietal: Superior parietal, inferior parietal, precuneus, etc.
- Occipital: Lateral occipital, cuneus, lingual, etc.

### Subcortical ROIs
- Left hippocampus
- Right hippocampus

### Dimensionality Reduction

For each ROI:
1. Extract all source locations within the ROI
2. Compute principal component analysis (PCA)
3. Keep top 3 principal components (captures most variance)
4. Save PC time series for further analysis

## Quality Control

### Visual Inspection

Check source reconstruction quality:

```matlab
% Load results
load('Results/source/SubjectID/source_rec_results.mat');

% Plot source activity
figure;
for roi = 1:size(source_roi_data, 1)
    subplot(7, 5, roi);
    plot(squeeze(source_roi_data(roi, 1, :)));  % First PC
    title(labels{roi});
end
```

### Validation Metrics

1. **Spatial filter quality**: Check for dipolar patterns
2. **SNR**: Signal-to-noise ratio in source space
3. **Localization error**: Validate on known sources (if available)
4. **ROI coverage**: Ensure all ROIs have valid source estimates

## Troubleshooting

### Common Issues

1. **Singular covariance matrix**:
   - Increase regularization parameter (lambda)
   - Use more trials for covariance estimation
   - Apply covariance shrinkage

2. **Memory errors**:
   - Reduce source space resolution
   - Process in batches
   - Use sparse matrices where applicable

3. **Poor localization**:
   - Check head model alignment
   - Verify leadfield quality
   - Ensure sufficient SNR in data

4. **Missing ROIs**:
   - Verify parcellation atlas
   - Check surface mesh quality
   - Ensure FreeSurfer processing completed

### Optimization

For faster processing:

```matlab
% Reduce source space (in head model creation)
cfg.grid.resolution = 10;  % mm (larger = faster, less accurate)

% Fewer PCs per ROI
n_components = 2;  % Instead of 3

% Parallel processing
parfor sbj = 1:n_subjects
    % Process subject
end
```

## Advanced Usage

### Custom ROIs

Define custom regions of interest:

```matlab
% Load source space
source_space = load('HeadModel/SubjectID/source_space.mat');

% Define ROI by MNI coordinates
roi_center = [20, -30, 50];  % MNI coordinates
roi_radius = 15;  % mm

% Find sources within radius
distances = vecnorm(source_space.pos - roi_center, 2, 2);
roi_sources = find(distances < roi_radius);

% Extract ROI time series
roi_data = source_timeseries(roi_sources, :);
```

### Alternative Source Methods

The pipeline can be adapted for other source reconstruction methods:

**Minimum Norm Estimate (MNE)**:
```matlab
cfg.method = 'mne';
cfg.lambda = 1e-3;
source = ft_sourceanalysis(cfg, data);
```

**Dynamic Imaging of Coherent Sources (DICS)**:
```matlab
cfg.method = 'dics';
cfg.frequency = 10;  % Hz
source = ft_sourceanalysis(cfg, freq);
```

## Notes

- LCMV beamformer is optimal for sources with distinct spatial patterns
- Requires good head model and sufficient SNR
- Results are sensitive to regularization parameter
- Multiple active sources can cause cancellation artifacts
- Consider source reconstruction validation before further analysis
