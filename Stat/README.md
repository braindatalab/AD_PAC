# Statistical Analysis Pipeline

This directory contains scripts for group-level statistical analysis of PAC and power data, comparing Alzheimer's Disease patients with healthy controls.

## Overview

The statistical pipeline performs group-level comparisons, correlations with clinical measures, and visualization of results. It includes both frequentist and mixed-effects modeling approaches.

## Main Scripts

### prepareTable.m

**Purpose**: Prepares a comprehensive data table combining PAC values, power measures, and clinical/demographic information.

**Input**:
- PAC results from `Results/SeedtoCortex/[SubjectID]/`
- Source power data from `Results/source/[SubjectID]/`
- Clinical data (demographics, MMSE scores, diagnosis)

**Output**:
- Structured table with all variables for statistical analysis
- Saved as MAT file and CSV for use in MATLAB and external software (R, Python)

**Data Table Structure**:
```matlab
% Columns:
% - Subject ID
% - Group (AD vs Control)
% - Age, Sex, Education
% - MMSE score (cognitive function)
% - PAC values (per ROI, frequency, condition)
% - Power values (per ROI, frequency band)
% - Derived metrics (asymmetry, ratios)
```

**Usage**:
```matlab
prepareTable;
```

### powerAnalysis.m

**Purpose**: Analyzes power spectral density (PSD) in cortical and hippocampal regions.

**Analyses Performed**:

1. **PSD Computation**:
   - Calculate power in standard frequency bands
   - Cortical ROIs and hippocampus
   - Delta (1-4 Hz), Theta (4-8 Hz), Alpha (8-12 Hz), Beta (13-30 Hz), Gamma (30-55 Hz)

2. **Group Comparisons**:
   - AD vs Control power differences
   - Region-wise statistical tests
   - Multiple comparison correction

3. **Visualization**:
   - Topographic maps of power differences
   - Power spectrum plots per ROI
   - Effect size distributions

**Output**:
- Power values per subject, ROI, and frequency band
- Statistical test results (t-tests, effect sizes)
- Publication-quality figures

**Usage**:
```matlab
powerAnalysis;
```

### clusterBasedModel.m

**Purpose**: Performs cluster-based permutation testing on PAC differences between AD and control groups.

**Method**: Cluster-based permutation test (non-parametric)

**Why**: Controls family-wise error rate (FWER) in the presence of multiple comparisons while maintaining sensitivity to spatially/spectrally contiguous effects.

**Algorithm**:
```
1. Compute observed statistic (t-statistic) for each ROI and frequency
2. Identify clusters of contiguous significant effects
3. Permutation testing:
   a. Randomly shuffle group labels
   b. Recompute statistics
   c. Find maximum cluster statistic
   d. Repeat 1000+ times
4. Compare observed clusters to null distribution
5. Report significant clusters (p < 0.05)
```

**Analyses**:

1. **PAC Group Differences**:
   - AD vs Control PAC values
   - Across cortical ROIs and frequencies
   - Both hippocampi analyzed separately

2. **Correlation with MMSE**:
   - PAC vs cognitive function
   - Within AD group
   - Identifies regions related to cognitive decline

3. **Visualization**:
   - Significant ROIs plotted on cortical surface
   - Frequency-by-frequency cluster maps
   - Scatter plots for correlations

**Input**:
- Data table from `prepareTable.m`
- PAC values per subject, ROI, frequency
- Group labels and MMSE scores

**Output**:
- Significant clusters (ROIs, frequency bands)
- Permutation test statistics
- Plots of results
- Saved in `Stat/ClusterTest/`

**Usage**:
```matlab
clusterBasedModel;
```

### linearMixedEffectsModel.m

**Purpose**: Fits linear mixed-effects (LME) models to account for repeated measures and covariates.

**Method**: Linear Mixed-Effects Modeling

**Why**: 
- Accounts for within-subject correlation (repeated measures across ROIs, frequencies)
- Includes random effects for subject-specific variability
- Can include covariates (age, sex, education)
- Provides estimates of fixed effects (group differences) and random effects

**Model Structure**:
```
PAC ~ Group + Age + Sex  + (1 | Subject) + (1 | f*f)

Fixed Effects:
- Group: AD vs Control
- Age: Continuous
- Sex: Binary

Random Effects:
- Subject: Random intercept per subject
- f*f: frequency of intrests tile
```
