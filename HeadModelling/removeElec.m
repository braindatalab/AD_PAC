% This script removes the 'elec' field from the MEG files 
meg_files = dir([main_path 'Dataset/*_meg_rest_60sec.mat']);

for i=69%1:length(meg_files)   
    meg = load([meg_files(i).folder '/' meg_files(i).name]);
    if isfield(meg,'elec')
        disp(['removing the elec filed from the meg file ' meg_files(i).name])
        meg = rmfield(meg,'elec');
        meg.hdr = rmfield(meg.hdr, 'elec');
        save([main_path 'Dataset/' meg_files(i).name], 'meg')
    end
end