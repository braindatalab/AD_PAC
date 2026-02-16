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


**Key Features**:
- Regularized covariance inversion for numerical stability
- Handles rank-deficient covariance matrices
- Supports fixed or free dipole orientation
- Efficient vectorized computation

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


### Data Format

**source_roi_data**: 
- Dimensions: (n_rois × n_pcs × n_timepoints)
- n_rois: Number of cortical and subcortical ROIs
- n_pcs: Principal components per ROI (typically 3)
- n_timepoints: Time samples at 600 Hz sampling rate

**labels**: Cell array of ROI names (e.g., 'L_hippocampus', 'R_superiorfrontal')


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
