%% Preprocessing script for AD_UCSF MEG data
% This script performs the following preprocessing steps:
% 1. Load raw MEG data
% 2. Resample data to 200 Hz
% 3. Detect and interpolate bad channels
% 4. Segment data into 2-second trials
% 5. Reject bad trials based on amplitude thresholding
% 6. Save the preprocessed data for further analysis    

AD_dir=main_path;
addpath '/fieldtrip-20240110/'  %add fieldtrip to the MATLAB path
ft_defaults

data_folder = [AD_dir 'Dataset/'];
subjs=dir([data_folder '*sec.mat']);
preprocessed_dir = [AD_dir 'Dataset/Preprocessed/']; 
resamplefs = 200;
%% Read and plot raw data 
for i=1:length(subjs)

data_file = [subjs(i).folder '/' subjs(i).name];
data=load(data_file);

if isfield(data,'meg')
data=data.meg;
end

cfg=[];
raw_data=ft_preprocessing(cfg,data);

sbj = strrep(subjs(i).name, '_meg_rest_60sec.mat','');

report_dir = [AD_dir '/Results/Preprocessing/' sbj '/']; mkdir(report_dir)

nchans = length(raw_data.label);

names = 'Grad';

channel_names=raw_data.label;

cfg=[];
cfg.layout='CTF275_helmet.mat';
layout=ft_prepare_layout(cfg);

plot_data(report_dir, raw_data, layout, channel_names, ['raw_after_import_' names]);

cfg = [];
cfg.resamplefs = resamplefs;
cfg.method = 'downsample';
data_resampled=ft_resampledata(cfg,raw_data);

plot_data(report_dir,data_resampled,layout,channel_names,['resampled_' names])

channel_types = find(~cellfun(@isempty,regexp(data_resampled.label,'^M')));

chanlist = 1:length(data_resampled.label);

all_bad_channels = [];

[data_cleaned, bc] = interpolate_bad_channels(report_dir, channel_types, data_resampled, layout, channel_names);

% put into FieldTrip struct
% data_cleaned.trial{1,1} = data_interpolated;
% data_cleaned.label = layout.label (1:275);
all_bad_channels = [all_bad_channels;bc];

    %% segment the data into 2s
cfg = [];
cfg.length = 2;
cfg.overlap = 0;
data_seg = ft_redefinetrial(cfg,data_cleaned);

%% reject outlier trials
all_bad_trials = [];

bt = detect_bad_trials(report_dir,1:length(data_seg.label) , data_seg);
all_bad_trials = [all_bad_trials;bt];
all_bad_tri = unique(all_bad_trials);
disp('bad trials:');
fprintf(1, '%d \n', all_bad_trials);

% reject trials here and select only meg channels for saving
cfg = [];
cfg.trials = 1:length(data_seg.trial);
cfg.trials(all_bad_tri) = [];
% cfg.channel = 'meg';
data_seg = ft_selectdata(cfg,data_seg);

%% plot again for report
    plot_data(report_dir, data_seg, layout, channel_names, ['after_rej_' names]);
%% save

disp(['This data is saved in ' [preprocessed_dir sbj] ' under the name ' sbj]);
ft_write_data([preprocessed_dir sbj], data_seg, 'dataformat', 'matlab');

end