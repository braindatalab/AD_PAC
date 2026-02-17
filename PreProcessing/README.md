# Preprocessing Pipeline

This directory contains scripts for preprocessing raw MEG data, including resampling, artifact rejection, and quality control.

## Overview

The preprocessing pipeline prepares raw MEG data for source reconstruction by removing artifacts, interpolating bad channels, and segmenting the continuous recordings into trials.

## Main Script

### preprocessing.m

**Purpose**: Main preprocessing pipeline that coordinates all preprocessing steps.

**Input**:
- MEG data files (MAT format) from the Dataset folder
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


## Dependencies

### External Software

1. **FieldTrip Toolbox**: [https://www.fieldtriptoolbox.org/](https://www.fieldtriptoolbox.org/)
   - Core preprocessing functions (ft_preprocessing, ft_resampledata, etc.)
   - Channel repair and artifact rejection
   - Visualization tools

### MATLAB Toolboxes

- Signal Processing Toolbox (for filtering and resampling)
