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
PAC ~ Group + Age + Sex + MMSE + (1 | Subject) + (1 | ROI)

Fixed Effects:
- Group: AD vs Control
- Age: Continuous
- Sex: Binary
- MMSE: Cognitive function

Random Effects:
- Subject: Random intercept per subject
- ROI: Random intercept per cortical region
```

**Analyses**:

1. **Main Effects**:
   - Group effect on PAC
   - Covariate effects
   - Interaction terms if specified

2. **Model Comparison**:
   - Likelihood ratio tests
   - AIC/BIC criteria
   - R² (variance explained)

3. **Post-hoc Tests**:
   - Pairwise comparisons
   - Simple effects analysis

**Input**:
- Data table from `prepareTable.m`
- Model specification (formula)

**Output**:
- Model fit statistics
- Fixed effect estimates with confidence intervals
- Random effect variances
- Diagnostic plots (residuals, Q-Q plots)
- Saved in `Stat/LME/`

**Usage**:
```matlab
linearMixedEffectsModel;
```

## Helper Scripts

### cluster_based_perm.py

**Purpose**: Python implementation of cluster-based permutation testing (alternative to MATLAB).

**Dependencies**:
- NumPy, SciPy
- MNE-Python (optional, for visualization)

**Usage**:
```python
python cluster_based_perm.py --input pac_data.csv --output results/
```

### Fig_creator.py

**Purpose**: Creates publication-quality figures from statistical results.

**Features**:
- Cortical surface plots with significant ROIs
- Frequency-by-frequency heatmaps
- Scatter plots with regression lines
- Customizable color schemes and layouts

**Usage**:
```python
python Fig_creator.py --results cluster_results.mat --output figures/
```

## Supporting Data Files

### roi_name.mat

**Content**: ROI names and labels for cortical regions.

**Structure**:
```matlab
roi_names = {
    'Left-Hippocampus',
    'Right-Hippocampus',
    'Left-Superior-Frontal',
    'Right-Superior-Frontal',
    ...
};
```

### dk_labels.mat

**Content**: Desikan-Killiany atlas label information.

**Structure**:
- Label IDs
- ROI names
- Anatomical groupings
- MNI coordinates

### cm17.mat

**Content**: 17-color colormap for cortical parcellations.

**Usage**: Visualization of ROI-specific results on brain surface.

### mask.mat

**Content**: Binary masks for including/excluding ROIs or frequency bins.

**Usage**: Apply specific inclusion criteria in statistical tests.

## Subdirectories

### ClusterTest/

Contains results from cluster-based permutation testing:
- `significant_clusters.mat`: Cluster statistics
- `cluster_plots/`: Visualization of significant effects
- `permutation_distribution.mat`: Null distribution data

### LME/

Contains results from linear mixed-effects modeling:
- `model_fits.mat`: Model parameters and statistics
- `diagnostic_plots/`: Residual and Q-Q plots
- `fixed_effects.csv`: Effect estimates with CI

### Power/

Contains power analysis results:
- `power_spectra.mat`: PSD per subject and ROI
- `group_differences.mat`: Statistical test results
- `power_plots/`: Topographic and spectral plots

## Expected Runtime

Statistical analyses are generally fast:
- **prepareTable**: ~5-10 minutes (depending on number of subjects)
- **powerAnalysis**: ~10-20 minutes
- **clusterBasedModel**: ~30-120 minutes (depends on number of permutations)
- **linearMixedEffectsModel**: ~10-30 minutes (depends on model complexity)

## Configuration

### Cluster-Based Permutation

```matlab
% Number of permutations
n_permutations = 5000;  % More = better p-value resolution

% Cluster-forming threshold
cluster_threshold = 0.05;  % Initial p-value for cluster formation

% Cluster statistic
cluster_stat = 'maxsum';  % 'maxsum', 'maxsize', or 'tfce'

% Multiple comparison correction
correction_method = 'cluster';  % 'cluster', 'fdr', or 'bonferroni'
```

### Linear Mixed-Effects

```matlab
% Model formula
formula = 'PAC ~ Group + Age + Sex + MMSE + (1|Subject) + (1|ROI)';

% Fitting method
fitmethod = 'REML';  % 'REML' or 'ML'

% Optimizer
optimizer = 'fminunc';  % MATLAB optimization function
```

## Statistical Considerations

### Multiple Comparisons

**Problem**: Testing many hypotheses increases false positive rate.

**Solutions Implemented**:

1. **Cluster-based permutation**: Controls FWER while preserving sensitivity
2. **FDR correction**: Controls false discovery rate (less conservative)
3. **Bonferroni**: Most conservative, suitable for few planned comparisons

### Effect Size

Report effect sizes along with p-values:

```matlab
% Cohen's d for group differences
cohens_d = (mean_AD - mean_Control) / pooled_std;

% Interpretation:
% Small: d = 0.2
% Medium: d = 0.5
% Large: d = 0.8
```

### Power Analysis

Ensure sufficient sample size:

```matlab
% Required sample size for 80% power, α=0.05, d=0.5
n_required = sampsizepwr('t', [0, 1], 0.5, 0.8, [], 'Alpha', 0.05);
```

## Troubleshooting

### Common Issues

1. **Convergence failures in LME**:
   - Simplify random effects structure
   - Center and scale continuous predictors
   - Check for multicollinearity

2. **No significant clusters**:
   - May indicate genuine null results
   - Check effect sizes (may be small but real)
   - Ensure sufficient power

3. **Memory errors in permutation testing**:
   - Reduce number of permutations
   - Process frequency bands separately
   - Use cluster computing if available

4. **Unbalanced groups**:
   - Use robust statistics
   - Consider weighting or matching
   - Report group sizes clearly

## Validation

### Sanity Checks

```matlab
% Check data distribution
figure; histogram(pac_values);
title('PAC Distribution');

% Check for outliers
outliers = isoutlier(pac_values, 'median');
fprintf('Detected %d outliers (%.1f%%)\n', sum(outliers), ...
    100*sum(outliers)/length(pac_values));

% Check group balance
group_counts = groupcounts(data.Group);
disp(group_counts);

% Check for missing data
missing_data = sum(isnan(data_table), 2);
fprintf('Subjects with missing data: %d\n', sum(missing_data > 0));
```

## Visualization Best Practices

1. **Use consistent color schemes**: AD=red, Control=blue
2. **Include error bars**: SEM or 95% CI
3. **Report statistics on plots**: p-values, effect sizes
4. **Use appropriate scales**: Consider log scale for power
5. **Add legends and labels**: Clear axis labels and units

## Output for Publication

### Tables

- Table 1: Demographics and clinical characteristics
- Table 2: PAC group differences (mean ± SD, statistics)
- Table 3: Significant clusters (location, frequency, statistics)
- Table 4: LME model results (fixed effects estimates)

### Figures

- Figure 1: Power spectra by group and ROI
- Figure 2: Significant PAC differences on brain surface
- Figure 3: Frequency-specific PAC clusters
- Figure 4: PAC vs MMSE correlations
- Figure 5: Effect sizes across ROIs

## Advanced Usage

### Custom Contrasts

Test specific hypotheses:

```matlab
% Test specific contrast
contrast = [1 -1 0 0];  % AD - Control, ignore covariates
[F, p] = coefTest(lme, contrast);
```

### Interaction Effects

Include interactions in model:

```matlab
% Group × MMSE interaction
formula = 'PAC ~ Group * MMSE + Age + Sex + (1|Subject)';
lme = fitlme(data_table, formula);

% Test interaction
[p, F] = coefTest(lme, [0 0 0 0 1]);  % Interaction term
```

### Sensitivity Analysis

Test robustness of results:

```matlab
% Without outliers
data_clean = data_table(~outliers, :);
lme_clean = fitlme(data_clean, formula);

% With different covariates
formula_alt = 'PAC ~ Group + Age + (1|Subject)';
lme_alt = fitlme(data_table, formula_alt);

% Compare results
compare(lme, lme_alt);
```

## Notes

- Always visualize data before statistical testing
- Report effect sizes, not just p-values
- Consider biological significance, not just statistical significance
- Document all analysis choices for reproducibility
- Use consistent statistical thresholds across analyses
