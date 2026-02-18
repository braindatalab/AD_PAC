# AD_PAC: Phase-Amplitude Coupling Analysis in Alzheimer's Disease

This repository contains MATLAB code for analyzing phase-amplitude coupling (PAC) in MEG data from patients with Alzheimer's Disease (AD) and healthy controls.

## Citation

If you use this code in your research, please cite our preprint:

**Preprint:** [https://www.medrxiv.org/content/10.64898/2026.02.06.26345635v1](https://www.medrxiv.org/content/10.64898/2026.02.06.26345635v1)

## Overview

This pipeline processes MEG (Magnetoencephalography) data to investigate phase-amplitude coupling between hippocampal and cortical regions in Alzheimer's Disease. The analysis focuses on theta/alpha phase coupling with low-gamma amplitude, examining differences between AD patients and healthy controls.

## Key Features

- **Head Modeling**: Automated head model construction using Brainstorm and OpenMEEG
- **MEG Preprocessing**: Bad channel interpolation, resampling, and trial rejection
- **Source Reconstruction**: LCMV beamformer-based source localization
- **PAC Analysis**: Cross-frequency coupling between hippocampus and cortical ROIs
- **Statistical Analysis**: Cluster-based permutation tests and linear mixed-effects models

## Requirements

### Software Dependencies

1. **MATLAB** (tested with recent versions)
2. **FieldTrip Toolbox** - For anatomy transformation and preprocessing
   - Download: [https://www.fieldtriptoolbox.org/](https://www.fieldtriptoolbox.org/)
3. **Brainstorm Toolbox** - For head model construction
   - Download: [https://neuroimage.usc.edu/brainstorm/](https://neuroimage.usc.edu/brainstorm/)
4. **FreeSurfer** - For cortical surface extraction (must be run on MRI files before the pipeline)
   - Download: [https://surfer.nmr.mgh.harvard.edu/](https://surfer.nmr.mgh.harvard.edu/)

### Data

MEG and MRI data can be downloaded from:
- **OSF Repository**: [https://osf.io/pd4h9/overview](https://osf.io/pd4h9/overview)

Data should be placed in a `Dataset` folder under the main project path.

### PAC Code Attribution

The PAC estimation code is based on the implementation by Franziska Pellegrini and Stefan Haufe:
- **GitHub**: [https://github.com/fpellegrini/PAC](https://github.com/fpellegrini/PAC)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/braindatalab/AD_PAC.git
   cd AD_PAC
   ```

2. Download and install required toolboxes (FieldTrip, Brainstorm, FreeSurfer)

3. Download the MEG and MRI data from OSF and place in `Dataset/` folder

4. Add required toolboxes to your MATLAB path in the `main.m` script

## Usage

The complete analysis pipeline is orchestrated through the `main.m` script. The pipeline consists of five main stages:

### 1. Head Modeling Pipeline

```matlab
anatomyTransform;      % Correct MRI transformation matrices and save as NIfTI files
removeElec;            % Remove 'elec' field from MEG files
buildHeadModels;       % Build head models and leadfields using Brainstorm and OpenMEEG
processBSFiles;        % Convert to MNI, extrapolate to high-res cortex, save leadfields
```

### 2. Preprocessing Pipeline

```matlab
preprocessing;         % Resample, interpolate bad channels, segment trials, reject bad trials
```

### 3. Source Reconstruction Pipeline

```matlab
sourceReconstruction_p; % LCMV beamformer source reconstruction
```

### 4. PAC Estimation Pipeline

```matlab
seedRoitoCortex;       % Compute cross-site PAC between hippocampus and cortical ROIs
                       % (theta/alpha - low-gamma coupling)
```

### 5. Statistical Analysis Pipeline

```matlab
prepareTable;          % Prepare table with clinical/demographic data and PAC values
powerAnalysis;         % Analyze PSD and region-wise power differences
clusterBasedModel;     % Cluster-based statistical analysis on PAC differences
linearMixedEffectsModel; % Linear mixed-effects modeling
```

### Running the Complete Pipeline

To run the full analysis:

1. Open MATLAB and navigate to the repository directory
2. Edit `main.m` to set your `main_path` variable
3. Ensure all required toolboxes are in your MATLAB path
4. Run individual sections or the complete pipeline:

```matlab
% Set the main path
main_path = './';

% Add all subdirectories to path
addpath(genpath(main_path));

% Run individual pipeline stages as needed
% (See main.m for complete pipeline)
```

## Directory Structure

```
AD_PAC/
├── main.m                    # Main pipeline orchestration script
├── Dataset/                  # Data directory (not included, download from OSF)
├── HeadModelling/           # Head model construction scripts
│   ├── anatomyTransform.m
│   ├── buildHeadModels.m
│   ├── processBSFiles.m
│   └── removeElec.m
├── PreProcessing/           # MEG data preprocessing scripts
│   ├── preprocessing.m
│   ├── interpolate_bad_channels.m
│   ├── detect_bad_trials.m
│   └── plot_data.m
├── SourceReconstruction/    # Source localization scripts
│   ├── sourceReconstruction_p.m
│   ├── lcmv_meg.m
│   └── ...
├── Pac/                     # Phase-amplitude coupling analysis
│   ├── seedRoitoCortex.m
│   ├── er_pac.m
│   └── ...
└── Stat/                    # Statistical analysis scripts
    ├── prepareTable.m
    ├── powerAnalysis.m
    ├── clusterBasedModel.m
    └── linearMixedEffectsModel.m
```

## Pipeline Details

### Head Modeling

The head modeling pipeline creates forward models for MEG source localization:
- Transforms anatomical MRI data to standard space
- Constructs realistic head models using OpenMEEG
- Generates leadfield matrices for source reconstruction
- Outputs are saved for each subject and used in subsequent analysis

### Preprocessing

MEG data preprocessing includes:
- Resampling to 200 Hz (configurable)
- Bad channel detection and interpolation
- Trial segmentation (2-second trials)
- Artifact rejection based on amplitude thresholds
- Quality control plots are generated for each step

### Source Reconstruction

Source-level analysis using LCMV beamformer:
- Computes spatial filters for each cortical location
- Projects sensor-level MEG data to source space
- Focuses on regions of interest (ROIs) including hippocampus and cortical areas
- Produces time series for each ROI

### PAC Analysis

Phase-amplitude coupling estimation:
- Computes coupling between hippocampal theta/alpha phase (4-12 Hz)
- And cortical low-gamma amplitude (30-55 Hz)
- Analyzes left/right hippocampus to ipsilateral/contralateral cortex
- Uses bispectral analysis methods (Antisymmetrized bicoherence)
- Results saved per subject for statistical analysis

### Statistical Analysis

Group-level statistics:
- Prepares data tables with demographics and PAC metrics
- Power spectral density analysis
- Cluster-based permutation testing for PAC differences
- Linear mixed-effects models accounting for repeated measures
- Visualization of significant results and correlations

## Output

Results are organized in the `Results/` directory:
- `Results/Preprocessing/`: Preprocessing quality control plots
- `Results/source/`: Source reconstruction results per subject
- `Results/SeedtoCortex/`: PAC analysis results per subject
- Statistical analysis outputs including plots and model results

## Troubleshooting

### Common Issues

1. **Missing toolboxes**: Ensure FieldTrip, Brainstorm, and FreeSurfer are properly installed and in your MATLAB path
2. **Data not found**: Verify that the Dataset folder exists and contains the downloaded MEG/MRI data
3. **Memory issues**: Large datasets may require substantial RAM; consider processing subjects in batches
4. **FreeSurfer preprocessing**: MRI files must be processed with FreeSurfer before running the head model pipeline

## Support

For questions or issues, please open an issue on the GitHub repository.

## License

See [LICENSE](LICENSE) file for details.

## Acknowledgments

- PAC analysis code adapted from Franziska Pellegrini and Stefan Haufe
- FieldTrip, Brainstorm, and FreeSurfer development teams
- Data contributors and participants
