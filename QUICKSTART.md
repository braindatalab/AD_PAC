# Quick Start Guide

This guide will help you get started with the AD_PAC pipeline quickly.

## Prerequisites

Before starting, ensure you have:
- ✅ MATLAB (R2018b or later) with required toolboxes
- ✅ FieldTrip, Brainstorm, and FreeSurfer installed
- ✅ MEG and MRI data downloaded from [OSF](https://osf.io/pd4h9/overview)
- ✅ FreeSurfer preprocessing completed for MRI data

See [REQUIREMENTS.md](REQUIREMENTS.md) for detailed installation instructions.

## Step 1: Clone the Repository

```bash
git clone https://github.com/braindatalab/AD_PAC.git
cd AD_PAC
```

## Step 2: Set Up Data

1. Create a `Dataset` folder in the repository:
   ```bash
   mkdir -p Dataset
   ```

2. Place your data files in the Dataset folder:
   ```
   Dataset/
   ├── Sub001_meg_rest_60sec.mat
   ├── Sub002_meg_rest_60sec.mat
   ├── ...
   ├── Sub001_mri.nii
   ├── Sub002_mri.nii
   └── ...
   ```

## Step 3: Configure Paths

1. Open MATLAB
2. Navigate to the AD_PAC directory
3. Edit `main.m` to set the main path:
   ```matlab
   main_path = '/full/path/to/AD_PAC/';
   ```

4. Add required toolboxes to MATLAB path:
   ```matlab
   % Add FieldTrip
   addpath('/path/to/fieldtrip/');
   ft_defaults;
   
   % Add Brainstorm
   addpath('/path/to/brainstorm3/');
   
   % Add AD_PAC and subdirectories
   addpath(genpath(main_path));
   ```

## Step 4: Run FreeSurfer (if not already done)

FreeSurfer must be run **before** the MATLAB pipeline:

```bash
# Set up FreeSurfer environment
export FREESURFER_HOME=/path/to/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# Process each subject's MRI (takes 6-24 hours per subject)
recon-all -s Sub001 -i Dataset/Sub001_mri.nii -all
recon-all -s Sub002 -i Dataset/Sub002_mri.nii -all
# ... repeat for all subjects
```

## Step 5: Run the Pipeline

### Option A: Run the Complete Pipeline

In MATLAB, run the entire pipeline:

```matlab
% Open main.m and run the entire script
main
```

This will execute all pipeline stages sequentially.

### Option B: Run Individual Stages

For more control, run each stage separately:

#### 1. Head Modeling (do this first)

```matlab
% Correct MRI transformations
anatomyTransform;

% Remove electrode fields
removeElec;

% Build head models (takes ~1-2 hours per subject)
buildHeadModels;

% Process Brainstorm files
processBSFiles;
```

#### 2. Preprocessing (~5-10 minutes per subject)

```matlab
preprocessing;
```

Check the quality control plots in `Results/Preprocessing/[SubjectID]/`

#### 3. Source Reconstruction (~15-40 minutes per subject)

```matlab
sourceReconstruction_p;
```

#### 4. PAC Analysis (~30-90 minutes per subject)

```matlab
seedRoitoCortex;
```

#### 5. Statistical Analysis

```matlab
% Prepare data table
prepareTable;

% Analyze power spectra
powerAnalysis;

% Cluster-based permutation testing
clusterBasedModel;

% Linear mixed-effects modeling
linearMixedEffectsModel;
```

## Step 6: View Results

Results are saved in the `Results/` directory:

```
Results/
├── Preprocessing/     # QC plots for each subject
├── source/           # Source reconstruction results
├── SeedtoCortex/    # PAC analysis results
└── Stat/            # Statistical analysis outputs
    ├── ClusterTest/ # Cluster-based permutation results
    ├── LME/        # Mixed-effects model results
    └── Power/      # Power analysis results
```

## Expected Timeline

For a typical dataset (20-30 subjects):

| Stage | Time per Subject | Total Time (25 subjects) |
|-------|-----------------|--------------------------|
| FreeSurfer | 6-24 hours | 150-600 hours (run in parallel) |
| Head Modeling | 1-2 hours | 25-50 hours |
| Preprocessing | 5-10 minutes | 2-4 hours |
| Source Reconstruction | 15-40 minutes | 6-17 hours |
| PAC Analysis | 30-90 minutes | 12-38 hours |
| Statistical Analysis | 1-3 hours | 1-3 hours (group-level) |

**Total**: ~1-2 weeks of computation time (can be parallelized)

## Tips for Faster Processing

1. **Parallel FreeSurfer**: Run multiple subjects simultaneously
   ```bash
   # Example: Process 4 subjects in parallel
   for subj in Sub001 Sub002 Sub003 Sub004; do
       recon-all -s $subj -i Dataset/${subj}_mri.nii -all &
   done
   wait
   ```

2. **MATLAB Parallel Processing**: Use parallel computing for preprocessing
   ```matlab
   parpool('local', 8);  % Use 8 cores
   parfor i = 1:length(subjects)
       % Process subject i
   end
   ```

3. **Process in Batches**: Don't wait for all subjects; process in batches
   - Process first batch through entire pipeline
   - Start next batch while analyzing first batch

## Common Issues and Solutions

### Issue 1: FieldTrip Function Not Found
```
Error: Undefined function 'ft_preprocessing'
```
**Solution**: Add FieldTrip to path and run `ft_defaults`

### Issue 2: Out of Memory Error
```
Error: Out of memory
```
**Solution**: 
- Close other applications
- Process fewer subjects simultaneously
- Increase MATLAB Java heap size

### Issue 3: Brainstorm Database Not Found
```
Error: Cannot find Brainstorm database
```
**Solution**: 
- Check that `buildHeadModels.m` completed successfully
- Verify Brainstorm configuration

### Issue 4: FreeSurfer Outputs Not Found
```
Error: Cannot find FreeSurfer recon-all output
```
**Solution**: 
- Ensure FreeSurfer preprocessing completed without errors
- Check FreeSurfer SUBJECTS_DIR environment variable
- Verify subject directories exist

## Verifying Results

### After Preprocessing:
```matlab
% Load preprocessed data
load('Dataset/Preprocessed/Sub001/preprocessed_data.mat');

% Check dimensions
disp(size(data_preprocessed.trial{1}));  % Should be [channels x time]

% Visual inspection
plot(data_preprocessed.time{1}, data_preprocessed.trial{1}(1,:));
xlabel('Time (s)'); ylabel('Amplitude (T)'); title('Channel 1');
```

### After Source Reconstruction:
```matlab
% Load source results
load('Results/source/Sub001/source_rec_results.mat');

% Check ROI data
disp(size(source_roi_data));  % [n_rois x n_pcs x n_timepoints]
disp(labels);  % ROI labels

% Plot first ROI
figure; plot(squeeze(source_roi_data(1,1,:)));
title(['ROI: ' labels{1}]);
```

### After PAC Analysis:
```matlab
% Load PAC results
load('Results/SeedtoCortex/Sub001/hcpac_results.mat');

% Check PAC matrix
disp(size(hcpac));  % [2, 2, 34, 2, 9, 26, 9]

% Plot average PAC for left hippocampus
pac_avg = squeeze(mean(hcpac(1,1,:,1,:,:,:), [3,7]));
imagesc(pac_avg);
xlabel('Amplitude Frequency (Hz)');
ylabel('Phase Frequency (Hz)');
title('Left Hippocampus PAC');
colorbar;
```

## Next Steps

After running the pipeline:

1. **Review Quality Control**: Check all QC plots in `Results/Preprocessing/`
2. **Examine Statistical Results**: Review significant clusters and effects
3. **Visualize Findings**: Use plotting scripts to create publication figures
4. **Validate Results**: Compare with literature and expectations
5. **Customize Analysis**: Modify parameters for your specific research questions

## Getting Help

- **Documentation**: See README.md files in each subdirectory
- **Issues**: Open an issue on [GitHub](https://github.com/braindatalab/AD_PAC/issues)
- **Citation**: See [CITATION.md](CITATION.md) for references

## Example: Minimal Working Example

Here's a minimal example to process a single subject:

```matlab
%% Setup
main_path = '/path/to/AD_PAC/';
addpath(genpath(main_path));
addpath('/path/to/fieldtrip/'); ft_defaults;
addpath('/path/to/brainstorm3/');

%% Process one subject
subject_id = 'Sub001';

% 1. Head model (assumes FreeSurfer completed)
% Run buildHeadModels.m for this subject

% 2. Preprocessing
% Run preprocessing.m for this subject

% 3. Source reconstruction
% Run sourceReconstruction_p.m for this subject

% 4. PAC analysis
% Run seedRoitoCortex.m for this subject

%% Check results
load(['Results/SeedtoCortex/' subject_id '/hcpac_results.mat']);
fprintf('PAC analysis complete for %s\n', subject_id);
fprintf('PAC values range: [%.4f, %.4f]\n', min(hcpac(:)), max(hcpac(:)));
```

---

For detailed documentation, see:
- [README.md](README.md) - Full documentation
- [REQUIREMENTS.md](REQUIREMENTS.md) - Detailed installation guide
- Module-specific READMEs in each subdirectory
