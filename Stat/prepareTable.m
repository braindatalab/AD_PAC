%reading the clinical and demographic data as well as the PAC values and preparing the table for statistical analysis

clinical = readtable(fullfile(main_path, '/Dataset/eLife91044_processeddata_scalarmetrics.xlsx'));

clinical.diagnosis = categorical(clinical.diagnosis);
clinical.ID   = categorical(clinical.ID);
 

clinical = table(clinical.ID,clinical.diagnosis, ...
    clinical.CDR,clinical.MMSE,clinical.ZPHG,clinical.age ...
    ,'VariableNames',{'ID','diagnosis','CDR','MMSE','ZPHG','age'});

%remove the subjects (069),072,096
clinical(69,:)=[];
clinical(72,:)=[];
clinical(96,:)=[];

%reading the computed hippocampal-cortical pac values 
resultsDir = [main_path 'SeedtoCortex/'];

% Get a list of all subjects in the directory
subjectFiles = dir(fullfile(resultsDir));
% Remove the '.' and '..' entries and files
subjectFiles = subjectFiles(~ismember({subjectFiles.name}, {'.', '..'}));

nSubjects=length(subjectFiles);

dataset_hcpac=[];

for sbj=1:nSubjects

    subjectFilePath = fullfile(resultsDir, subjectFiles(sbj).name, 'Hipop_cortex_ASB_norm.mat');

    hcpac=load(subjectFilePath,"hcpac");
    hcpac=hcpac.hcpac;
 
    hcpac(hcpac == 0) = NaN;
   
    dataset_hcpac=cat(8,dataset_hcpac, hcpac);
end

%get the mean along the freq and max over pc values 
% dataset_hcpac=squeeze(mean(dataset_hcpac,[5,6], "omitmissing"));
% dataset_hcpac =squeeze (max(dataset_hcpac,[],5));

%get the mean along the freq pc values 
% dataset_hcpac_1pc = zeros(2,2,34,2,9,26,1,nSubjects);
% dataset_hcpac= dataset_hcpac(:,:,:,:,:,:,1,:);
% dataset_hcpac=squeeze(mean(dataset_hcpac_1pc,[5,6,7], "omitmissing"));

rows = nSubjects*2*2*34*2;

subjectIDs = repelem (clinical.ID,2*2*34*2);
group = repelem (clinical.diagnosis,2*2*34*2);
CDR = repelem(clinical.CDR,2*2*34*2);
MMSE = repelem(clinical.MMSE,2*2*34*2);
ZPHG = repelem(clinical.ZPHG,2*2*34*2);
age = repelem(clinical.age,2*2*34*2);

[seedSide, cortexSide, roi, phaseAmplitude] = ndgrid(0:1 , 0:1, 1:34, 0:1);

seedSide = categorical(repmat(seedSide(:), nSubjects, 1));
cortexSide = categorical(repmat(cortexSide(:), nSubjects, 1));
roi = categorical(repmat(roi(:), nSubjects, 1));
phaseAmplitude = categorical(repmat(phaseAmplitude(:), nSubjects, 1));

% Reshape asb_norm_pac to ensure each row contains a 9x26 matrix
asb_norm_pac = cell(rows, 1);
%L/R Hippo * ipsi/contra Cortex * 34 ROI * PHASE/AMP Hipp *
    %[4:12;30*55] Hz * 9 pCS
index = 1;
for sbj = 1:nSubjects
    for ss = 1:2
        for cs = 1:2
            for r = 1:34
                for pa = 1:2
                    asb_norm_pac{index} = squeeze(dataset_hcpac(ss, cs, r, pa,:,:,:, sbj));
                    index = index + 1;
                end
            end
        end
    end
end

lmedata= table(subjectIDs,group,CDR,MMSE,ZPHG,seedSide, ...
    cortexSide,roi,phaseAmplitude,asb_norm_pac,age, ...
    'VariableNames',{'SubjectID', 'Group', 'CDR', ...
                      'MMSE', 'ZPHG','seedSide', ...
                      'CortexSide', 'ROI', ...
                      'PhaseAmplitude', 'asb_norm_pac','age'});

save("Hippo_data_ASB_norm","lmedata")
