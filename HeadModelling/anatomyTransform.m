%%
% Load the MRI data, correct the transformation matrix, and save as NIfTI files
%%  

addpath '/fieldtrip-20240110/'  %add fieldtrip to the MATLAB path
ft_defaults
mri_files = dir([main_path '/Dataset/*mri_anon.mat']);

subids={};

for j=1:148
    subids{j} = sprintf('RSID%04d',j);
end

for k = 1:length(mri_files)
mri = load([ mri_files(k).folder  '/'  mri_files(k).name]);
disp('Original Transformation Matrix:');
disp(mri.transform);

mri.transform = [0 -1 0  128.5; 1 0 0 -98.5;0 0 1 -88.5;0 0 0 1];
mri.unit = 'mm';

disp('Corrected Transformation Matrix:');
disp(mri.transform);

save_name=[main_path '/Dataset/' subids{k} '_mri_anon.nii'];
ft_write_mri(save_name, mri.anatomy,'transform',mri.transform,'unit','mm','dataformat','nifti');
end