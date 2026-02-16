# Phase-Amplitude Coupling (PAC) Analysis

This directory contains scripts for computing phase-amplitude coupling between hippocampal and cortical regions.

## Overview

The PAC analysis pipeline investigates cross-frequency coupling between the phase of low-frequency oscillations (theta/alpha, 4-12 Hz) in the hippocampus and the amplitude of high-frequency oscillations (low-gamma, 30-55 Hz) in cortical regions.

## Main Script

### seedRoitoCortex.m

**Purpose**: Computes phase-amplitude coupling between hippocampal seed regions and cortical ROIs.

**Input**:
- Source-reconstructed data from `Results/source/[SubjectID]/source_rec_results.mat`
- Each subject's data contains:
  - `source_roi_data`: Time series for ROIs (ROIs × PCs × time)
  - `labels`: ROI names
  - `regions_cortex`: Cortical region definitions

**Output**:
- PAC values saved in `Results/SeedtoCortex/[SubjectID]/`
- Dimensions: (L/R hippocampus × ipsi/contra × 34 cortical ROIs × phase/amplitude × freq × pcs)

**Processing Steps**:

1. **Load source data**: Read source time series for each subject
2. **Select seed ROIs**: Extract left and right hippocampus activity
3. **Define frequency bands**:
   - Phase frequency: 4-12 Hz (theta/alpha)
   - Amplitude frequency: 30-55 Hz (low-gamma)
4. **Compute PAC**: For each hippocampus-cortex pair
5. **Save results**: Store PAC matrices for statistical analysis

**Usage**:
```matlab
seedRoitoCortex;
```

## Core PAC Functions

### er_pac.m

**Purpose**: Computes phase-amplitude coupling using bispectral analysis (Event-Related PAC).

**Method**: Bispectrum-based PAC estimation

**Theory**: 
Phase-amplitude coupling can be detected through the bispectrum, which measures nonlinear interactions between frequency components. If the phase of frequency f1 modulates the amplitude of frequency f2, a peak appears in the bispectrum at (f1, f2).

**Algorithm**:
```
1. Compute cross-spectrum between two signals X and Y:
   CS(f) = FFT(X) * conj(FFT(Y))

2. Compute triple product (bispectrum):
   B(f1, f2) = <CS(f1) * CS(f2) * conj(CS(f1+f2))>
   where <> denotes averaging across trials/segments

3. Normalize by power spectra to get bicoherence:
   b(f1, f2) = |B(f1, f2)| / sqrt(<|CS(f1)|²> * <|CS(f2)|²>)

4. Extract PAC strength at frequencies of interest
```

**Input**:
- `data`: Time series data (channels × time × trials)
- `segleng`: Segment length for FFT
- `segshift`: Shift between segments (for overlap)
- `epleng`: Total epoch length
- `freqpairs`: Frequency pairs to analyze

**Output**:
- `erpac`: PAC values (frequency × frequency × channels)
- `freq`: Frequency vector
- Statistical significance (optional)

**Parameters**:
```matlab
fs = 600;              % Sampling frequency
segleng = 600;         % 1-second segments
segshift = 120;        % 0.2-second shift (80% overlap)
freq_phase = 4:12;     % Phase frequencies (Hz)
freq_amp = 30:55;      % Amplitude frequencies (Hz)
```

### er_pac_3.m

**Purpose**: Extended version of er_pac with additional features.

**Enhancements**:
- Three-way interactions
- Multiple segment lengths
- Advanced normalization options
- Significance testing

**Usage**: Similar to er_pac.m but with extended capabilities

### test_pac.m

**Purpose**: Test and validation script for PAC computation.

**Functions**:
- Validate PAC methods on synthetic data
- Test parameter sensitivity
- Compare different PAC metrics
- Quality control checks

**Usage**: For development and validation purposes

```matlab
% Generate synthetic PAC data
[data_pac, true_coupling] = generate_synthetic_pac();

% Test PAC detection
detected_pac = test_pac(data_pac);

% Compare with ground truth
correlation = corr(true_coupling(:), detected_pac(:));
```

## PAC Analysis Details

### Hippocampus-to-Cortex Coupling

The analysis examines several coupling patterns:

1. **Left hippocampus phase → Left cortex amplitude** (ipsilateral)
2. **Left hippocampus phase → Right cortex amplitude** (contralateral)
3. **Right hippocampus phase → Right cortex amplitude** (ipsilateral)
4. **Right hippocampus phase → Left cortex amplitude** (contralateral)

5. **Left cortex phase → Left hippocampus amplitude** (reverse coupling)
6. **Right cortex phase → Right hippocampus amplitude** (reverse coupling)

### Frequency Bands

**Phase Frequencies (4-12 Hz)**:
- Theta: 4-8 Hz
- Alpha: 8-12 Hz
- Combined theta/alpha: 4-12 Hz

**Amplitude Frequencies (30-55 Hz)**:
- Low-gamma: 30-55 Hz
- Analysis at 1 Hz resolution

### Cortical ROIs

34 cortical regions per hemisphere (Desikan-Killiany parcellation):

**Frontal**: 
- Superior frontal, middle frontal, inferior frontal
- Precentral, postcentral, paracentral

**Temporal**:
- Superior temporal, middle temporal, inferior temporal
- Fusiform, entorhinal, parahippocampal

**Parietal**:
- Superior parietal, inferior parietal
- Precuneus, supramarginal

**Occipital**:
- Lateral occipital, lingual, cuneus, pericalcarine

**Other**:
- Cingulate regions, insula, etc.

## Output Format

### PAC Matrix Structure

```matlab
% Dimensions: hcpac(L/R, ipsi/contra, cortical_ROI, phase/amp, freq_phase, freq_amp, pcs)
hcpac = zeros(2, 2, 34, 2, 9, 26, 9);

% Indices:
% dim1: 1=Left hippocampus, 2=Right hippocampus
% dim2: 1=Ipsilateral cortex, 2=Contralateral cortex  
% dim3: 1-34 = Cortical ROI index
% dim4: 1=Hippocampus phase, 2=Hippocampus amplitude
% dim5: Phase frequency index (4-12 Hz, 9 points)
% dim6: Amplitude frequency index (30-55 Hz, 26 points)
% dim7: Principal component index (1-9)
```

### Saved Files

```
Results/
└── SeedtoCortex/
    └── [SubjectID]/
        ├── hcpac_results.mat         # Full PAC matrix
        ├── pac_summary.mat           # Averaged PAC values
        └── quality_metrics.mat       # QC measures
```

## Expected Runtime

PAC computation is computationally intensive:

- **Data loading**: ~30 seconds per subject
- **PAC computation**: ~20-60 minutes per subject
  - Depends on: number of segments, frequency resolution, number of ROI pairs
- **Saving results**: ~1 minute per subject

Total: ~30-90 minutes per subject

## Configuration

Key parameters in `seedRoitoCortex.m`:

```matlab
% Frequency bands
theta_alpha = 4:12;      % Phase frequencies (Hz)
low_gamma = 30:55;       % Amplitude frequencies (Hz)

% Segmentation
fs = 600;                % Sampling frequency (Hz)
segleng = 600;           % Segment length (samples) = 1 second
segshift = 120;          % Segment shift (samples) = 0.2 second
                         % (80% overlap for smooth estimates)

% Hippocampus ROI indices
LH_id = 10;             % Left hippocampus index in ROI list
RH_id = 11;             % Right hippocampus index

% Number of cortical ROIs
n_cortical_roi = 34;    % Per hemisphere (Desikan-Killiany)
```

## Quality Control

### Verification Steps

1. **Check PAC values**: Should be in reasonable range (0 to ~0.1 for bicoherence)
2. **Frequency specificity**: PAC should show clear peaks at expected frequencies
3. **Spatial patterns**: Examine consistency across similar cortical regions
4. **Subject variability**: Compare PAC distributions across subjects

### Validation Code

```matlab
% Load PAC results
load('Results/SeedtoCortex/SubjectID/hcpac_results.mat');

% Check value ranges
min_pac = min(hcpac(:));
max_pac = max(hcpac(:));
mean_pac = mean(hcpac(:));

fprintf('PAC range: [%.4f, %.4f], mean: %.4f\n', min_pac, max_pac, mean_pac);

% Plot frequency-specific PAC
figure;
imagesc(squeeze(mean(hcpac(1, 1, :, 1, :, :), [1,3,7])));
xlabel('Amplitude Frequency (Hz)');
ylabel('Phase Frequency (Hz)');
title('Average Left Hippocampus PAC');
colorbar;
```

## Troubleshooting

### Common Issues

1. **NaN values in PAC**:
   - Check for zero-variance segments
   - Verify sufficient data length
   - Ensure proper normalization

2. **Extremely low PAC values**:
   - May indicate genuine lack of coupling
   - Check source reconstruction quality
   - Verify frequency bands are appropriate

3. **Memory errors**:
   - Process subjects individually
   - Reduce frequency resolution
   - Use fewer segments with longer averaging

4. **Very long computation time**:
   - Reduce segment overlap (increase segshift)
   - Parallelize across subjects
   - Optimize FFT computation

### Optimization Tips

```matlab
% Reduce frequency resolution
theta_alpha = 4:2:12;    % Every 2 Hz instead of 1 Hz
low_gamma = 30:2:55;     % Every 2 Hz

% Reduce overlap
segshift = 300;          % 50% overlap instead of 80%

% Process specific ROIs only
roi_subset = [1, 5, 10]; % Subset of cortical ROIs
```

## Statistical Considerations

### Multiple Comparisons

PAC analysis involves many comparisons:
- 2 hippocampi × 2 hemispheres × 34 ROIs × 9 phase freq × 26 amp freq
- ≈ 32,000+ tests per subject

**Correction methods** (applied in Stat/ pipeline):
- Cluster-based permutation testing
- False Discovery Rate (FDR)
- Bonferroni correction (conservative)

### Effect Size

Raw PAC values can be small; consider:
- Normalizing by baseline or control condition
- Computing z-scores across subjects
- Using percent change from mean

## Advanced Usage

### Custom Frequency Bands

```matlab
% Define custom frequency pairs
freq_pairs = [4 30;   % Theta-low gamma
              6 40;   % Theta-gamma
              10 45;  % Alpha-gamma
              8 60];  % Alpha-high gamma

% Compute PAC for specific pairs
for pair = 1:size(freq_pairs, 1)
    f_phase = freq_pairs(pair, 1);
    f_amp = freq_pairs(pair, 2);
    pac(pair) = compute_pac_pair(data, f_phase, f_amp);
end
```

### Directionality Analysis

Test causal direction of PAC:

```matlab
% Compare hippocampus→cortex vs cortex→hippocampus
pac_hc_to_ctx = hcpac(:, :, :, 1, :, :, :);  % HC phase
pac_ctx_to_hc = hcpac(:, :, :, 2, :, :, :);  % HC amplitude

% Statistical test for asymmetry
[h, p] = ttest(pac_hc_to_ctx(:), pac_ctx_to_hc(:));
```

## References

### PAC Methods

This implementation is based on:

Pellegrini, F., Delgado Saa, J., & Haufe, S. (2023). Identifying good practices for detecting inter-frequency coupling in resting-state EEG: A simulation study. *NeuroImage*, 277, 120233.

Original code: [https://github.com/fpellegrini/PAC](https://github.com/fpellegrini/PAC)

### Theoretical Background

- Tort, A. B., et al. (2010). Measuring phase-amplitude coupling between neuronal oscillations of different frequencies. *Journal of Neurophysiology*, 104(2), 1195-1210.
- Canolty, R. T., & Knight, R. T. (2010). The functional role of cross-frequency coupling. *Trends in Cognitive Sciences*, 14(11), 506-515.

## Notes

- PAC analysis is sensitive to signal quality and SNR
- Results should be interpreted in context of specific hypothesis
- Consider running validation analysis on known PAC patterns
- Save intermediate results for debugging and quality control
