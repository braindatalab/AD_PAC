load bs_results.mat
load Hippo_data_ASB_norm.mat
load cm17.mat
load dk_labels.mat
load power_data.mat
% lmedata = removevars(lmedata, {'age','CDR','MMSE','ZPHG'});

pa=["Amplitude", "Phase"];
sides=["L", "R", "L+R"];

for PhaseAmplitude=["0","1"]

    dataPA = lmedata(lmedata.PhaseAmplitude == PhaseAmplitude,:);

    for SeedSide =["0","1"] 
        % SeedSide = "0";
        dataSS = dataPA(dataPA.seedSide == SeedSide,:);
        % dataSS = dataPA(:,:);

        tStats = zeros(1, 68);
        pValues = zeros(1, 68); % Initialize p-values

        for  ROI = 1:34

            dataR = dataSS(dataSS.ROI == num2str(ROI),:);

            for CortexSide = ["0","1"]

                data=dataR(dataR.CortexSide == CortexSide,:);


                % Expand the table to create one row for each matrix element
                % data.asb_norm_pac=cellfun(@(X) mean(X(:,:,1),"all","omitmissing"),data.asb_norm_pac);

                nSubjects = height(data);
                expandedTableCells = cell(nSubjects, 1);

                for i = 1:nSubjects
                    [rows, cols,pcs] = size(data.asb_norm_pac{i}(:,:,1));
                    [rowIdx, colIdx,pcsIdx] = ndgrid(1:rows, 1:cols, 1:pcs);
                    tempTable = table();

                    tempTable.SubjectID = repmat(data.SubjectID(i), rows*cols*pcs, 1);
                    tempTable.Group = repmat(data.Group(i), rows*cols*pcs, 1);

                    tempTable.asb_norm_pac = reshape(data.asb_norm_pac{i}(:,:,1) ,  [], 1); %

                    tempTable.freqId = categorical(cellstr([num2str(rowIdx(:)) num2str(colIdx(:)) ]));
                    tempTable.pcId = categorical(cellstr([num2str(pcsIdx(:))]));

                    expandedTableCells{i} = tempTable;
                end

                expandedTable = vertcat(expandedTableCells{:});
                % Identify rows where asb_norm_pac contains NaN values
                rowsWithNaN = isnan(expandedTable.asb_norm_pac(:));

                % Remove those rows from the table
                expandedTable(rowsWithNaN,:) = [];

                % Fit a linear model: ROIData ~+ Group
                lm = fitlme(expandedTable, 'asb_norm_pac ~ Group + (1|SubjectID) + (1|freqId)');
                tStats(2*ROI + str2double(CortexSide)-1) = lm.Coefficients.tStat(2); % T-statistic for group (AD vs. Control)
                pValues(2*ROI + str2double(CortexSide)-1) = lm.Coefficients.pValue(2); % p-value for group effect
                
            end
        end

        
        [h, crit_p, ~, adj_p] = fdr_bh(pValues, 0.05, 'pdep', 'no'); % Use q = 0.01 threshold

        % h: Binary vector indicating significant regions (1 = significant, 0 = not significant)
        % crit_p: Critical p-value threshold after FDR correction
        % adj_p: Adjusted p-values for each region

        significantRegions = h == 1;


        dk_labels{h}
        % Overlay significant regions
        % significantTStats = -tStats;
        significantTStats = sign(tStats).*log10(adj_p);
        significantTStats(~significantRegions) = 0; % Mask non-significant regions
        % 
        % lim = max(abs(significantTStats), [], 'all')+0.01;
        plottitle=strjoin(["./ROI_model/first_pc/" sides(str2double(SeedSide)+1)  pa(str2double(PhaseAmplitude)+1)],'_');
        plottitle=char(plottitle);
        save([plottitle '.mat'], 'h')
        allplots_cortex_BS_5_view(cortex, significantTStats, [-3.1 3.1], cm17, '-sign(T)*log10(p)',0.1,plottitle);
    end
end
