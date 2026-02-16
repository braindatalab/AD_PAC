# Preprocessing Pipeline

This directory contains scripts for preprocessing raw MEG data, including resampling, artifact rejection, and quality control.

## Overview

The preprocessing pipeline prepares raw MEG data for source reconstruction by removing artifacts, interpolating bad channels, and segmenting the continuous recordings into trials.

## Main Script

### preprocessing.m

**Purpose**: Main preprocessing pipeline that coordinates all preprocessing steps.

**Input**:
- Raw MEG data files (MAT format) from the Dataset folder
- Files should be named: `[SubjectID]_meg_rest_60sec.mat`

**Output**:
- Preprocessed MEG data saved in `Dataset/Preprocessed/`
- Quality control plots in `Results/Preprocessing/[SubjectID]/`

**Processing Steps**:
1. Load raw MEG data
2. Resample to 200 Hz
3. Detect and interpolate bad channels
4. Segment into 2-second trials
5. Detect and reject bad trials
6. Save preprocessed data

**Configuration**:
```matlab
resamplefs = 200;           % Target sampling frequency (Hz)
trial_length = 2;           % Trial duration (seconds)
amplitude_threshold = 3e-12; % Artifact detection threshold (Tesla)
```

**Usage**:
```matlab
preprocessing;
```

## Helper Functions

### interpolate_bad_channels.m

**Purpose**: Detects and interpolates bad MEG channels using spatial interpolation.

**Method**:
- Identifies channels with excessive variance or flat signals
- Uses neighboring channels for interpolation
- Based on FieldTrip's channel repair functions

**Input**:
- FieldTrip data structure with MEG channels

**Output**:
- Data with bad channels interpolated
- List of interpolated channel labels

**Algorithm**:
```matlab
% Detect bad channels based on variance
variance_threshold = 3 * std(channel_variances);
bad_channels = channels exceeding threshold

% Interpolate using neighbors
cfg = [];
cfg.method = 'weighted';
cfg.badchannel = bad_channel_labels;
cfg.layout = 'CTF275_helmet.mat';
data_interp = ft_channelrepair(cfg, data);
```

### detect_bad_trials.m

**Purpose**: Identifies and marks trials containing artifacts.

**Method**:
- Computes peak-to-peak amplitude for each trial and channel
- Flags trials exceeding amplitude threshold
- Uses robust statistical measures to avoid false positives

**Input**:
- Segmented trial data (FieldTrip structure)
- Amplitude threshold (default: 3e-12 Tesla)

**Output**:
- Vector of bad trial indices
- Quality metrics (percentage rejected, etc.)

**Algorithm**:
```matlab
% For each trial
for trial = 1:ntrials
    % Compute peak-to-peak amplitude across channels
    ptp = max(data{trial}, [], 2) - min(data{trial}, [], 2);
    
    % Flag if any channel exceeds threshold
    if any(ptp > threshold)
        bad_trials(trial) = true;
    end
end

% Additional checks for gradient artifacts
% (sudden jumps between consecutive samples)
```

### plot_data.m

**Purpose**: Creates quality control visualizations of MEG data.

**Plots Generated**:
1. **Topographic maps**: Spatial distribution of signal power
2. **Time series**: Channel-wise or averaged signals over time
3. **Power spectrum**: Frequency content of the data
4. **Trial variance**: Distribution of signal variance across trials

**Input**:
- FieldTrip data structure
- Layout information for sensor positions
- Output directory for saving figures

**Output**:
- PNG/PDF files with visualizations
- Saved in subject-specific report directories

**Usage**:
```matlab
plot_data(report_dir, data, layout, channel_names, plot_name);
```

## Dependencies

### External Software

1. **FieldTrip Toolbox**: [https://www.fieldtriptoolbox.org/](https://www.fieldtriptoolbox.org/)
   - Core preprocessing functions (ft_preprocessing, ft_resampledata, etc.)
   - Channel repair and artifact rejection
   - Visualization tools

### MATLAB Toolboxes

- Signal Processing Toolbox (for filtering and resampling)
- Statistics and Machine Learning Toolbox (for outlier detection)

## Configuration

Edit `preprocessing.m` to adjust parameters:

```matlab
% Resampling
resamplefs = 200;  % Target frequency (Hz)

% Bad channel detection
variance_multiplier = 3;  % Standard deviations from mean

% Trial segmentation
trial_length = 2;  % Trial duration (seconds)
trial_overlap = 0; % Overlap between trials (seconds)

% Artifact rejection
amplitude_threshold = 3e-12;  % Peak-to-peak threshold (Tesla)
gradient_threshold = 1e-13;   % Maximum allowed gradient
```

## Expected Runtime

Preprocessing is relatively fast:
- **Load data**: <1 minute per subject
- **Resampling**: ~1-2 minutes per subject
- **Bad channel detection**: ~30 seconds per subject
- **Trial segmentation**: ~30 seconds per subject
- **Bad trial detection**: ~1-2 minutes per subject
- **Plotting**: ~1-3 minutes per subject

Total: ~5-10 minutes per subject (60-second recordings)

## Output Structure

```
Dataset/
└── Preprocessed/
    └── [SubjectID]/
        └── preprocessed_data.mat    # Cleaned, resampled, segmented data

Results/
└── Preprocessing/
    └── [SubjectID]/
        ├── raw_after_import_Grad.png      # Raw data visualization
        ├── after_resampling_Grad.png      # After resampling
        ├── after_interpolation_Grad.png   # After bad channel repair
        ├── after_segmentation_Grad.png    # After trial segmentation
        └── after_rejection_Grad.png       # After artifact rejection
```

## Quality Control

### Visual Inspection

Review the generated plots for each subject:

1. **Raw data**: Check for obvious artifacts, sensor malfunction
2. **After resampling**: Verify no aliasing artifacts introduced
3. **After interpolation**: Ensure bad channels properly recovered
4. **After segmentation**: Check trial length and overlap
5. **After rejection**: Verify artifact removal without excessive data loss

### Metrics to Check

```matlab
% Load preprocessed data
load('Dataset/Preprocessed/SubjectID/preprocessed_data.mat');

% Check data quality
nchannels_interpolated = length(bad_channels);
ntrials_rejected = length(bad_trials);
rejection_rate = ntrials_rejected / total_trials * 100;

% Acceptable ranges:
% - Interpolated channels: 0-10% of total
% - Trial rejection: 5-30% typical
% - If >50% rejected: investigate data quality
```

## Troubleshooting

### Common Issues

1. **FieldTrip not in path**: Add FieldTrip to MATLAB path and run `ft_defaults`
2. **Layout file not found**: Download CTF275_helmet.mat or specify correct layout
3. **Too many trials rejected**: Lower amplitude threshold or check for systematic artifacts
4. **Memory errors**: Process subjects individually rather than in batch
5. **Resampling errors**: Check original sampling rate and ensure valid target rate

### Data Quality Issues

**High rejection rate (>50%)**:
- Check electrode impedances
- Review raw data for systematic artifacts
- Consider manual artifact removal before automated pipeline

**Poor channel interpolation**:
- May indicate sensor malfunction
- Consider excluding channels if interpolation unsuccessful
- Verify sensor positions in layout file

**Unexpected frequency content**:
- Check for line noise (50/60 Hz and harmonics)
- Apply notch filter if necessary
- Verify proper shielding during recording

## Advanced Usage

### Custom Filtering

Add bandpass filtering to preprocessing.m:

```matlab
% After resampling
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [1 95];  % Bandpass 1-95 Hz
cfg.bpfiltord = 4;
data_filtered = ft_preprocessing(cfg, data_resampled);
```

### Alternative Artifact Rejection

For more sophisticated artifact removal:

```matlab
% Use ICA for artifact removal
cfg = [];
cfg.method = 'runica';
comp = ft_componentanalysis(cfg, data);

% Visualize components
ft_databrowser(cfg, comp);

% Remove artifact components
cfg = [];
cfg.component = [1 3 7];  % Components to remove
data_clean = ft_rejectcomponent(cfg, comp, data);
```

## Notes

- Preprocessing parameters may need adjustment for different datasets
- Visual inspection of quality control plots is essential
- Save preprocessing parameters for reproducibility
- Consider batch processing for large datasets
- The pipeline assumes CTF MEG system; adapt for other systems as needed
