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

### MATLAB Toolboxes

- Image Processing Toolbox (for NIfTI handling)
- Signal Processing Toolbox

## Expected Runtime

The head modeling pipeline is computationally intensive:
- **anatomyTransform**: ~1-5 minutes per subject
- **removeElec**: <1 minute
- **buildHeadModels**: ~30-120 minutes per subject (depends on mesh resolution)
- **processBSFiles**: ~5-15 minutes per subject

Total: ~1-2 hours per subject

## Outputs Structure

```
Results/
└── HeadModel/
    └── [SubjectID]/
        ├── leadfield_mni.mat       # Leadfield in MNI space
        ├── cortex_highres.mat      # High-resolution cortical surface
        └── head_model_info.mat     # Metadata and transformation matrices
```

## Troubleshooting

### Common Issues

1. **FreeSurfer not run**: Ensure FreeSurfer's recon-all has completed successfully
2. **Brainstorm not found**: Add Brainstorm to MATLAB path before running
3. **OpenMEEG errors**: Check Brainstorm's OpenMEEG configuration
4. **Memory issues**: Head model computation requires significant RAM (16GB+ recommended)
5. **Transformation errors**: Verify MRI coordinate system and orientation

### Quality Check

After running the pipeline:
1. Visually inspect head models in Brainstorm
2. Verify sensor alignment with head surface
3. Check leadfield matrix dimensions
4. Ensure all subjects have complete outputs

## Notes

- This pipeline must be run before the source reconstruction steps
- Results are cached and don't need to be recomputed unless MRI/MEG data changes
- Different mesh resolutions can be configured in buildHeadModels.m
- The pipeline assumes CTF MEG system (275 channels); adapt for other systems if needed
