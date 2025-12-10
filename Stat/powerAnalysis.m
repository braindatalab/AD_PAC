% Prepare power data for statistical analysis and plotting the results including cortical and hippocampal PSD,  
% and cortical region-wise Power differences between AD and control groups.

resultsDir = [main_path 'Results/source/'];

% Get a list of all subjects in the directory0
subjectFiles = dir(fullfile(resultsDir));
% Remove the '.' and '..' entries and files
subjectFiles = subjectFiles(~ismember({subjectFiles.name}, {'.', '..'}));

freqBands = [2 7; 8 12; 15 29; 30 55];
freqBands = 2* freqBands + 1;
bandNames = {'Delta-Theta', 'Alpha', 'Beta', 'Low-Gamma'};

source_roi_power_total_norm_grandAvg =zeros(length(subjectFiles),601,83);
source_roi_power_norm_grandAvg = zeros(1,83);

% Loop through each subject and load the source_rec_results

for sbj = 1:69%length(subjectFiles)

    % Construct the full path to the subject's results file
    subjectFilePath = fullfile(resultsDir, subjectFiles(sbj).name, 'source_rec_results.mat');

    load(subjectFilePath, 'source_roi_power_total_norm','labels','regions_cortex');

    source_roi_power_total_norm_grandAvg(sbj,:,:)= source_roi_power_total_norm;

end

source_roi_power_total_norm_grandAvg_control = squeeze(mean(source_roi_power_total_norm_grandAvg(1:69,1:101,:),1));


% Loop through each subject and load the source_rec_results
for sbj =70:length(subjectFiles)

    % Construct the full path to the subject's results file
    subjectFilePath = fullfile(resultsDir, subjectFiles(sbj).name, 'source_rec_results.mat');

    load(subjectFilePath, 'source_roi_power_total_norm','source_roi_power_norm', 'labels','regions_cortex');

    source_roi_power_total_norm_grandAvg(sbj,:,:) = source_roi_power_total_norm;

end

source_roi_power_total_norm_grandAvg_AD = squeeze(mean(source_roi_power_total_norm_grandAvg(70:end,1:101,:),1));

load bs_results.mat
load cm17.mat
size(source_roi_power_total_norm_grandAvg)
% save("power_data.mat",source_roi_power_total_norm_grandAvg);
%plot the mean and 95 ci psd 
NC =  mean(source_roi_power_total_norm_grandAvg(1:69,1:111,16:83),[2,3]); %Normalization Control group
NA = mean(source_roi_power_total_norm_grandAvg(70:end,1:111,16:83),[2,3]); %Normalization AD

dataC = mean(source_roi_power_total_norm_grandAvg(1:69,1:111,16:83),3)./NC; %averaged over roi and normalized
dataA =  mean(source_roi_power_total_norm_grandAvg(70:end,1:111,16:83),3)./NA;

mean_psd_C = mean(dataC,1); % averaged over subjects
mean_psd_A = mean(dataA,1);

ci_C = tinv([0.025 0.975], 69-1);
ci_A = tinv([0.025 0.975], 76-1);

ci_psd_C = ci_C(2)* std(dataC,0,1)/ sqrt(69);
ci_psd_A = ci_A(2) * std(dataA,0,1)/ sqrt(76);

frequency = 0:110;

% Plot the shaded CI
fill([frequency, fliplr(frequency)], ...
     [mean_psd_C+ ci_psd_C, fliplr(mean_psd_C - ci_psd_C)], ...
     [0.2 0.6 1], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); % Blue shade
hold on 
 
% Plot the mean line
plot(frequency, mean_psd_C, 'Color', [0.2 0.6 1], 'LineWidth', 2); % Blue line

% Plot the shaded CI
fill([frequency, fliplr(frequency)], ...
     [mean_psd_A+ ci_psd_A, fliplr(mean_psd_A - ci_psd_A)], ...
     [1 0 0], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); % Red shade
hold on 

% Plot the mean line
plot(frequency, mean_psd_A, 'Color', [1 0 0], 'LineWidth', 2); % Red line

yLimits = ylim;
for i = 1:size(freqBands, 1)
    x_band = [freqBands(i,1) freqBands(i,2) freqBands(i,2) freqBands(i,1)];
    y_band = [yLimits(1) yLimits(1) yLimits(2) yLimits(2)]; % Fill full y-range
    fill(x_band, y_band, [0.3 0.3 0.3], 'FaceAlpha', 0.2, 'EdgeColor', 'none'); % Green shade
    text(mean(freqBands(i, :))+1, yLimits(2)*0.05, bandNames{i}, 'HorizontalAlignment', 'center', 'FontSize', 6);
end

% Customize plot
xlabel('Frequency (Hz)');
ylabel('Cortical normalized PSD (a.u.)');
xticks(1:10:111)
xticklabels(0:5:56)
xlim([3 110])

legend({'95% CI', 'Control-Mean PSD','95% CI', 'AD-Mean PSD'}, 'Location', 'northeast');
grid on;
hold off;
export_fig('./Power/cortiacl_psd.png', ['-r' '300'], '-transparent');

close all

NC =  mean(source_roi_power_total_norm_grandAvg(1:69,1:111,10:11),[2,3]); %Normalization Control group
NA = mean(source_roi_power_total_norm_grandAvg(70:end,1:111,10:11),[2,3]); %Normalization AD

dataC = mean(source_roi_power_total_norm_grandAvg(1:69,1:111,10:11),3)./NC; %averaged over hippocampus
dataA =  mean(source_roi_power_total_norm_grandAvg(70:end,1:111,10:11),3)./NA;

mean_psd_C= mean(dataC,1); % averaged over subjects
mean_psd_A =mean(dataA,1);

ci_C = tinv([0.025 0.975], 69-1);
ci_A = tinv([0.025 0.975], 76-1);
ci_psd_C = ci_C(2) * std(dataC,0,1)/ sqrt(69);
ci_psd_A = ci_A(2) * std(dataA,0,1)/ sqrt(76);

frequency = 0:110;


% Plot the shaded CI
fill([frequency, fliplr(frequency)], ...
     [mean_psd_C+ ci_psd_C, fliplr(mean_psd_C - ci_psd_C)], ...
     [0.2 0.6 1], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); % Blue shade
hold on 

% Plot the mean line
plot(frequency, mean_psd_C, 'Color', [0.2 0.6 1], 'LineWidth', 2); % Blue line

% Plot the shaded CI
fill([frequency, fliplr(frequency)], ...
     [mean_psd_A+ ci_psd_A, fliplr(mean_psd_A - ci_psd_A)], ...
     [1 0 0], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); % Red shade


% Plot the mean line
plot(frequency, mean_psd_A, 'Color', [1 0 0], 'LineWidth', 2); % Red line

yLimits = ylim;
for i = 1:size(freqBands, 1)
    x_band = [freqBands(i,1) freqBands(i,2) freqBands(i,2) freqBands(i,1)];
    y_band = [yLimits(1) yLimits(1) yLimits(2) yLimits(2)]; % Fill full y-range
    fill(x_band, y_band, [0.3 0.3 0.3], 'FaceAlpha', 0.2, 'EdgeColor', 'none'); % Green shade
    text(mean(freqBands(i, :))+1, yLimits(2)*0.05, bandNames{i}, 'HorizontalAlignment', 'center', 'FontSize', 6);
end

% Customize plot
xlabel('Frequency (Hz)');
ylabel('Hippocampi normalized PSD (a.u.)');
xticks(1:10:111)
xticklabels(0:5:56)
xlim([3 110])
ylim([0 6])
legend({'95% CI', 'Control-Mean PSD','95% CI', 'AD-Mean PSD'}, 'Location', 'northeast');
grid on;
hold off;


export_fig('./Power/hippo_psd_norm.png', ['-r' '300'], '-transparent');
clinical=readtable([main_path 'Dataset/eLife91044_processeddata_scalarmetrics.xlsx']);

clinical(69,:)=[];
clinical(72,:)=[];
clinical(96,:)=[];

age_all=clinical.age;

for bands = 1:size(freqBands, 1)-1
    % Initialize data storage for Control and AD groups
    dataC_all = []; % Control data (subjects x regions)
    dataA_all = []; % AD data (subjects x regions)
    

    % Loop through Control group subjects
    for sbj = 1:69 % Adjust this based on the control group size
        subjectFilePath = fullfile(resultsDir, subjectFiles(sbj).name, 'source_rec_results.mat');
        load(subjectFilePath, 'source_roi_power_total_norm');

        dataCS = source_roi_power_total_norm(freqBands(bands, 1):freqBands(bands, 2), 16:83);
        dataCS = mean(dataCS, 1) ./ mean(source_roi_power_total_norm(1:101, 16:83), 1);
        dataC_all = [dataC_all; dataCS];
    end

    % Loop through AD group subjects
    for sbj = 70:length(subjectFiles) % Adjust this based on the AD group start index
        subjectFilePath = fullfile(resultsDir, subjectFiles(sbj).name, 'source_rec_results.mat');
        load(subjectFilePath, 'source_roi_power_total_norm');

        dataAS = source_roi_power_total_norm(freqBands(bands, 1):freqBands(bands, 2), 16:83);
        dataAS = mean(dataAS, 1) ./ mean(source_roi_power_total_norm(1:101, 16:83), 1);
        dataA_all = [dataA_all; dataAS];
       
    end

    % Combine data and age information
    data_all = [dataC_all; dataA_all]; % Combine Control and AD data
   
    group = [zeros(size(dataC_all, 1), 1); ones(size(dataA_all, 1), 1)]; % 0 = Control, 1 = AD

    % Initialize T-statistics map
    tStats = zeros(1, size(data_all, 2));
    pValues = zeros(1, size(data_all, 2)); % Initialize p-values

    % Perform regression and T-tests for each region
    for roi = 1:size(data_all, 2)
        % Extract data for this region
        roiData = data_all(:, roi);
        dataTable = table(age_all, group, roiData, 'VariableNames', {'Age', 'Group', 'ROIData'});

        % Fit a linear model: ROIData ~ Age + Group
        mdl = fitlm(dataTable, 'ROIData ~ Age + Group');
       
        % Extract T-statistic for the group effect
        tStats(roi) = mdl.Coefficients{'Group', 'tStat'}; % T-statistic for group (AD vs. Control)
        pValues(roi) = mdl.Coefficients{'Group', 'pValue'}; % p-value for group effect
    end

    [h, crit_p, ~, adj_p] = fdr_bh(pValues, 0.01, 'pdep', 'no'); % Use q = 0.01 threshold

    % h: Binary vector indicating significant regions (1 = significant, 0 = not significant)
    % crit_p: Critical p-value threshold after FDR correction
    % adj_p: Adjusted p-values for each region

    significantRegions = h == 1;



    % Overlay significant regions
    significantTStats = -sign(tStats) .* log10(adj_p);

    
    significantTStats(~significantRegions) = 0; % Mask non-significant regions

    lim = max(abs(significantTStats), [], 'all')

    title= ['./Power/' bandNames{bands} '_band' ];
    allplots_cortex_BS_5_view(cortex, significantTStats, [-20 20], cm17, '-sign(T)*log10(p)', 0.1,title);
    % sgtitle(['Significant t-statistic (q < 0.01, FDR-corrected) in ' bandNames{bands} ' band ' ]);
  
    % export_fig(title, ['-r' '300'], '-transparent');
end
% 