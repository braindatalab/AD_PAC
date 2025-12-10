% Seed ROI to Cortex PAC Analysis
% This script computes phase-amplitude coupling (PAC) between a seed region of interest (ROI)
% and multiple cortical ROIs using bispectral analysis.
% The results are saved for each subject in a specified directory.

resultsDir = [main_path 'Results/source/']; % Directory containing source reconstruction results
save_dir_main = [main_path 'Results/SeedtoCortex/'] ; % Directory to save PAC results

% Get a list of all subjects in the directory
subjectFiles = dir(fullfile(resultsDir));
% Remove the '.' and '..' entries and files
subjectFiles = subjectFiles(~ismember({subjectFiles.name}, {'.', '..'}));

% freqBands = [1 4;4 8; 8 12; 13 30; 30 55];
% bandNames = {'Delta','Theta', 'Alpha', 'Beta', 'Low-Gamma'};

theta_alpha = 4:12;
low_gamma = 30:55;

% Loop through each subject and load the source_rec_results
for sbj = 1:length(subjectFiles)

    %L/R Hippo * ipsi/contra Cortex * 34 ROI * PHASE/AMP Hipp *
    %[4:12;30*55] Hz * 9 pCS

    hcpac = zeros(2,2,34,2,9, 26,9);

    % Construct the full path to the subject's results file
    subjectFilePath = fullfile(resultsDir, subjectFiles(sbj).name, 'source_rec_results.mat');

    load(subjectFilePath, 'source_roi_data', 'labels','regions_cortex');

    save_dir = [save_dir_main subjectFiles(sbj).name '/'];

    if ~isfolder(save_dir)
        mkdir(save_dir)
    end
    
    fs = 600;
    epleng =  size(source_roi_data,3)*2*fs; % epl=datal
    segleng = fs ; %1 sec
    segshift = fs/5; %0.2 sec

    desired_f = 56;
    df = 1 / (segleng / fs);

    LH_id = 10; % Hippocampus L
    % LH_id_pcs = 3*LH_id-2:3*LH_id;

    RH_id = 11; % Hippocampus R
    % RH_id_pcs = 3*RH_id-2:3*RH_id;

    L_cortex_id = 16:2:83;
    R_cortex_id = 17:2:83;
    cortex_id = {L_cortex_id,R_cortex_id};


    for c_id=[1,2]
        % Pre-slice the data for each cortex_id before entering the parfor loop
        for ids_idx = 1:34
            ids = cortex_id{1,c_id}(ids_idx);
            
            % Extract the relevant slice of source_roi_data for froi_id and this cortex id
            data_slices{1,c_id,ids_idx} = source_roi_data([3*LH_id-2:3*LH_id, 3*ids-2:3*ids],:,:);
            data_slices{2,c_id,ids_idx} = source_roi_data([3*RH_id-2:3*RH_id, 3*ids-2:3*ids],:,:);
        end
    end

    for H=[1,2]
        for c_id=[1,2]
            % Parallel for loop for cortex_id
            parfor ids_idx = 1:34
                ids =cortex_id{1,c_id}(ids_idx);
                disp(ids);
                tic;

                % Load the data for froi_id and the current cortex id
                data = data_slices{H,c_id,ids_idx};

                % Temporary variable to store the results for each `ids_idx`
                temp_big = zeros(2,9, 26,9); %alph-theta*low-gamma 

                % Parallelize the frequency computations
                for low_freqs_id = 1:9
                    for high_freqs_id= 1:26

                        low_freqs = theta_alpha (low_freqs_id);
                        high_freqs = low_gamma (high_freqs_id);

                        if low_freqs + high_freqs - 1 < 55
                            filt = struct();
                            filt.low = low_freqs;
                            filt.high = high_freqs;
                            
                            [~, ~,  ~, b_anti_norm] = er_pac_3(data,fs,segleng,segshift,epleng,filt);

                            % Update the 'big' matrix with the computed values
                            temp_big( 1,low_freqs_id, high_freqs_id,:) = reshape(b_anti_norm(1:3, 4:6),1,1,1,9); %H as amp signal
                            temp_big( 2,low_freqs_id, high_freqs_id,:) = reshape(b_anti_norm(4:6, 1:3),1,1,1,9); % H as phase signal
                        % else
                            % temp_big( :,low_freqs_id, high_freqs_id,:) = NaN; 
                        end
                    end
                end

                % Update the 'big' matrix after the loop
                % hcpac = zeros(2,2,34,2,9, 26, 9);
                %L/R Hippo * ipsi/contra Cortex * 34 ROI * PHASE/AMP Hippo
                %[4:12;30*55] Hz *9pcs 
                hcpac(H,c_id,ids_idx,:, :, :,:) = temp_big;

                toc;
            end
            
            save([save_dir 'Hipop_cortex_ASB_norm.mat'],"hcpac")  

        end
    end
end
