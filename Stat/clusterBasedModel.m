load bs_results.mat %for plotting cortex
load cm17.mat % colormap
load dk_labels.mat %DK atlas labels
%dataset to use
load Hippo_data_ASB_norm.mat % data table with clinical/demographic and PAC data

save_dir = './Cluster_test_results/Hippocampus/';
if ~exist(save_dir, 'dir')
   mkdir(save_dir);
end

pa=["Amplitude", "Phase"];
sides=["L", "R","L+R"];

regions=zeros(1,68);

for PhaseAmplitude=["1","0"]

    dataPA = lmedata(lmedata.PhaseAmplitude == PhaseAmplitude,:);

    for SeedSide = ["0","1"] 
        if SeedSide == "2"
            dataSS = dataPA;
        else
            dataSS = dataPA(dataPA.seedSide == SeedSide,:);
        end
      
        pac = zeros(145,68,9,26);

        for  ROI = 1:34 

            dataR = dataSS(dataSS.ROI == num2str(ROI),:);

            for CortexSide = ["0","1"] 

                data=dataR(dataR.CortexSide == CortexSide,:);

                nSubjects=height(data);

                if SeedSide == "2"
                    nSubjects=nSubjects/2;
                end

                for i=1:nSubjects
                    for lf=1:9
                        for hf=1:26
                           if SeedSide == "2"
                            pac(i,2*ROI + str2double(CortexSide)-1,lf,hf) = (data.asb_norm_pac{2*i-1}(lf,hf,1)+ ...
                               data.asb_norm_pac{2*i}(lf,hf,1)/2);
                            else
                            pac(i,2*ROI + str2double(CortexSide)-1,lf,hf) =  data.asb_norm_pac{i}(lf,hf,1); 
                            end  
                        end
                    end
                end
            end
        end

        
        clinical_data = table(data.SubjectID,data.Group, ...
        data.CDR,data.MMSE,data.ZPHG,data.age ...
        ,'VariableNames',{'SubjectID','Group','CDR','MMSE','ZPHG','age'});
        
        if SeedSide == "2"
            clinical_data(2:2:end, :) = [];
        end
   
        pac_AD=pac(70:145,:,:,:);
        pac_Control=pac(1:69,:,:,:);

        % pac_AD=pac(data.CDR>0.5,:,:,:);
        % pac_Control=pac(data.CDR==0.5,:,:,:);

        save("pac.mat","pac_AD","pac_Control");

        pyrunfile("cluster_based_perm.py");

        load res.mat


        res=regions;


        [unique_R, idy, idx_map] = unique(sig_region);   
        P_min = accumarray(idx_map, sig_P_val.', [], @min);
       
        num_unique = numel(unique_R);
        sig_cluster_summed = zeros(num_unique, 9, 26);
        
      
        for i = 1:numel(sig_region)
            sig_cluster_summed(idx_map(i), :, :) = sig_cluster_summed(idx_map(i), :, :) + double(sig_cluster(i, :, :));
        end
        
        for r=1:num_unique
        %     % 
            t=squeeze(sig_T(idy(r),:,:));
            c=squeeze(sig_cluster_summed(r,:,:));
            cluster=c.*t;

            c = reshape(c, [1, 1, 9, 26]);        
            c = repmat(c, [145, 1, 1, 1]);  % 145x1x9x26
            
            %% Pac~MMSE correlation figure
            clinical_data.mean_sig_PAC(:,:) = mean(pac(:,unique_R(r)+1,:,:).*c,[3,4],"omitmissing");
            % Extract AD data
            ad_data = clinical_data(clinical_data.Group == "AD", :);
            mmse_vals = ad_data.MMSE;
            pac_vals = ad_data.mean_sig_PAC;

            % Normalize MMSE scores to [0,1] for colormap indexing
            mmse_norm = (mmse_vals - min(mmse_vals)) / (max(mmse_vals) - min(mmse_vals));
            cm_idx = round(1 + (size(cm17,1)-1) * mmse_norm);  % Colormap indices

            % Plot linear model (fit line and CI only, without markers)
            lm = fitlm(ad_data, 'mean_sig_PAC ~ MMSE');
            [r_1, p_1] = corr(mmse_vals, pac_vals, 'Rows', 'complete');
            if lm.Coefficients.pValue(2) < 0.05

            char(strjoin(['Pac and MMSE has the r'  sides(str2double(SeedSide)+1) pa(str2double(PhaseAmplitude)+1) dk_labels(unique_R(r)+1) ], '_'))
            r_1
            % Create figure
            f = figure('Color', 'w', 'Units', 'centimeters', 'Position', [5, 5, 20, 20]);
            h = plot(lm, 'LineWidth', 2);
            set(h(1), 'Visible', 'off');  % Hide original markers
            set(h(2), 'Color', [0.1 0.1 0.1], 'LineStyle', '-', 'LineWidth', 2.5); % Fit line
            set(h(3), 'Color', [0.4 0.4 0.4], 'LineStyle', '--', 'LineWidth', 1.5); % CI
            hold on;
            % grid on;
            % box on;
            % axis square;

            scatter(mmse_vals, pac_vals, 36,'k', ...
                    'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5,'MarkerFaceAlpha',0.5);
            ax = gca;
            ax.YAxis.Exponent = -3;
            ytickformat('%04.1f')           
            
            axis square;  
            grid on; box on;
            % Labels and axes
            xlabel('MMSE', 'FontWeight', 'bold', 'FontSize', 14);
            ylabel('Mean Theta/Alpha-Gamma PAC', 'FontWeight', 'bold', 'FontSize', 14);
            set(gca, 'FontSize', 12, 'LineWidth', 1.2);

            % Title with p-value
            title(sprintf('%s (r = %.3f, p_{value} = %.3f)', dk_labels{unique_R(r)+1}, r_1,p_1), ...
                  'FontSize', 12, 'Interpreter', 'tex');

            % Legend (only one entry for clarity)
            legend({'','Linear Fit', '95% CI','AD patients'}, 'FontSize', 10, 'Location', 'northeast', 'Box', 'on');
            % Optional: add colorbar to reflect MMSE scale
            % colormap(cm17);
            % caxis([min(mmse_vals), max(mmse_vals)]); % Set color axis to actual MMSE range
            % cb = colorbar;
            % cb.Label.String = 'AD patients MMSE';
            % cb.Label.FontSize = 12;
            % cb.TickDirection = 'out';
            % cb.Box = 'off';

            clustertitle= strjoin([save_dir sides(str2double(SeedSide)+1) pa(str2double(PhaseAmplitude)+1) dk_labels(unique_R(r)+1) '.png'], '_');
            clustertitle=char(clustertitle);
            export_fig(clustertitle, ['-r' '300']);
            close(f)
            end
            res(unique_R(r)+1)= -log10(P_min(r))*sign(mean(cluster,'all',"omitmissing"));
            %% f*f T map and cluster
            f=figure('Position',[10 10 500 500]);
            alphaData = ~isnan(cluster);
            alphaData = double(alphaData);
            alphaData(cluster==0)=0.3;
            imagesc(t,"AlphaData", alphaData);
            set(gca,'YDir','normal');
            colormap(cm17);
            % lim = max(abs(t),[],"all")
            clim([-4.7 4.7])
            % max(abs(cluster),[],"all")
            axis equal; 
            axis tight;   
            xticks(1:5:26)
            xticklabels(30:5:56)
            yticks(1:9)
            yticklabels(4:12)
            title(strjoin([dk_labels(unique_R(r)+1) '   p_{value}=' num2str(P_min(r),'%.3f')],''), 'Interpreter', 'tex','FontSize',12 )
            clustertitle= strjoin([save_dir sides(str2double(SeedSide)+1) pa(str2double(PhaseAmplitude)+1) dk_labels(unique_R(r)+1) r '.png'], '_');
            % final/first_pc/p01/p01
            clustertitle=char(clustertitle);
            exportgraphics(f,clustertitle,"BackgroundColor","none",Resolution=300)
            close(f);

        end         
        %% Brain Plot
            lim=max(abs(res),[],"all");
            % % 
            plottitle=strjoin([save_dir sides(str2double(SeedSide)+1) pa(str2double(PhaseAmplitude)+1)],'_');
            plottitle=char(plottitle)
            lim
            allplots_cortex_BS_5_view(cortex,res , [-3.1 3.1], cm17, '-sign(cluster T)*log10(p)',0.1,plottitle);
            close all
    end 
end 



