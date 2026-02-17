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
        
```
