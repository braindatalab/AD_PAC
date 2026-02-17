# Head Modelling Pipeline

This directory contains scripts for constructing head models and leadfield matrices required for MEG source reconstruction.

## Overview

The head modeling pipeline processes anatomical MRI data and MEG sensor information to create forward models that describe how neural sources project to MEG sensors. These models are essential for accurate source localization.

## Pipeline Steps

### 1. anatomyTransform.m

**Purpose**: Corrects MRI transformation matrices and converts MRI data to NIfTI format.

**Input**: 
- Raw MRI data in MAT format from the Dataset folder

**Output**:
- NIfTI files with corrected transformation matrices
- Prepared for FreeSurfer processing

**Usage**:
```matlab
anatomyTransform;
```

**Note**: This step must be run before FreeSurfer processing.

### 2. removeElec.m

**Purpose**: Removes the 'elec' field from MEG files to avoid conflicts in Brainstorm.

**Input**:
- MEG data files from the Dataset folder

**Output**:
- Cleaned MEG files compatible with Brainstorm

**Usage**:
```matlab
removeElec;
```

**Why**: Some MEG files may contain electrode information that conflicts with Brainstorm's processing. This step ensures compatibility.

### 3. buildHeadModels.m

**Purpose**: Constructs realistic head models and computes leadfield matrices using Brainstorm and OpenMEEG.

**Requirements**:
- Brainstorm must be installed and in the MATLAB path
- FreeSurfer must have been run on the MRI data
- OpenMEEG must be properly configured in Brainstorm

**Input**:
- Processed MRI data (from FreeSurfer)
- MEG sensor information

**Output**:
- Head models (skull, brain surfaces)
- Leadfield matrices for each subject
- Saved in Brainstorm database format

**Usage**:
```matlab
buildHeadModels;
```

**Process**:
1. Imports MRI and MEG data into Brainstorm
2. Generates cortical surface from FreeSurfer output
3. Creates boundary element model (BEM) surfaces
4. Computes forward model using OpenMEEG
5. Generates leadfield matrices

### 4. processBSFiles.m

**Purpose**: Post-processes Brainstorm outputs for use in source reconstruction.

**Input**:
- Brainstorm database with computed head models and leadfields

**Output**:
- Leadfield matrices in MNI space
- High-resolution cortical surface extrapolation
- Saved in MAT format for easy loading

**Usage**:
```matlab
processBSFiles;
```

**Process**:
1. Loads Brainstorm results
2. Transforms leadfields to MNI standard space
3. Extrapolates to high-resolution cortical mesh
4. Saves leadfields and related metadata

## Helper Functions

### eucl.m

**Purpose**: Computes Euclidean distances between points.

**Usage**: Called internally by other scripts for spatial calculations.

## Dependencies

### External Software

1. **Brainstorm**: [https://neuroimage.usc.edu/brainstorm/](https://neuroimage.usc.edu/brainstorm/)
   - Used for head model construction
   - Provides OpenMEEG integration

2. **FreeSurfer**: [https://surfer.nmr.mgh.harvard.edu/](https://surfer.nmr.mgh.harvard.edu/)
   - Must be run independently on MRI data before this pipeline
   - Generates cortical surfaces and parcellations

3. **OpenMEEG**: Integrated within Brainstorm
   - Boundary element method for forward modeling
   - Provides accurate electromagnetic field computations



