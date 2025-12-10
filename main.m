
main_path = './';

% MEG and MRI mat files can be downloaded from:
% https://osf.io/pd4h9/overview
% should be placed in the 'Dataset' folder under main_path

% Required Toolboxes to run the code:

%fieldtrip toolbox is required for anatomy transformation and preprocessing steps
% https://www.fieldtriptoolbox.org/

%brainstorm toolbox is required for head model construction 
% https://neuroimage.usc.edu/brainstorm/

%FREESURFER is required for cortical surface extraction and should be runned for MRI files
%  before running the head model pipeline
% https://surfer.nmr.mgh.harvard.edu/

% PAC estimation code is based on the code by Franziska Pellegrini and Stefan Haufe available at:
% https://github.com/fpellegrini/PAC

% add mentioned required toolboxes to MATLAB path

addpath(genpath(main_path));

%HEADM MODELING PIPELINE

anatomyTransform; % correct MRI transformation matrices and save as NIfTI files

removeElec; % remove 'elec' field from MEG files to avoid issues in brainstorm

buildHeadModels; % build head models and leadfields for all subjects using brainstorm and openmeeg 

processBSFiles; % process brainstorm files to convert to MNI, extrapolate to high-res cortex, and save leadfields

%PREPROCESSING PIPELINE
preprocessing; % preprocess MEG data: resampling, bad channel interpolation, trial segmentation, bad trial rejection

%SOURCE RECONSTRUCTION PIPELINE

sourceReconstruction_p; % source reconstruction of preprocessed MEG data using LCMV beamformer

%PAC ESTIMATION PIPELINE

seedRoitoCortex; % compute Across-site PAC between hippocampous and cortical ROIs in theta/alpha 
% and low-gamma bands for hippocampal L/R as phase/amplitude sources

%STATISTICAL ANALYSIS PIPELINE

prepareTable; % prepare the table including clinical/demographic data and PAC values for statistical analysis

powerAnalysis; % prepare power data for statistical analysis and plotting the results including 
% cortical and hippocampal PSD, and cortical region-wise Power differences between AD and control groups.

clusterBasedModel; % perform cluster-based statistical analysis on PAC values differences between AD and control groups
% and plot the significant ROI on cortex, plot frequency by frequency cluster of PAC differences 
% as well as the PAC and MMSE correlation plots for significant ROIs.

linearMixedEffectsModel; % perform linear mixed-effects modeling of PAC values differences between AD and control groups


