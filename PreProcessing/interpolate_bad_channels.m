function [data_out, bad_channels] = interpolate_bad_channels(rdir, channels, data, channel_layout, channel_name)

% add missing channel to the bad channel list

% channel_layout.label = channel_layout.label(1:275);
% [notmissing, dummy] = match_str(channel_layout.label, data.label);
% newtrial = cell(size(data.trial));
% for k = 1:numel(data.trial)
%     newtrial{k} = zeros(numel(channel_layout.label), size(data.trial{k},2));
%     newtrial{k}(notmissing,:) = data.trial{k};
% end
% goodchans   = false(numel(channel_layout.label),1);
% goodchans(notmissing) = true;
% badchanindx = find(goodchans==0);
% 
% % data.trial = newtrial; clear newtrial;
% % data.label = channel_layout.label;
% 
cfg = [];
cfg.channel = channel_layout.label;
cfg.layout = channel_layout;
cfg.method = 'template';
cfg.template= 'CTF275_neighb.mat';
neighbours = ft_prepare_neighbours(cfg);

% cfg = [];
% cfg.method = 'average';
% cfg.neighbours = neighbours;
% cfg.neighbourdist = 4;
% cfg.missingchannel   = channel_layout.label(badchanindx);
% data = ft_channelrepair(cfg, data);

% get variance of channels
var_chans = var(data.trial{1,1}(:,:),0,2);
outliers = isoutlier(var_chans); %three scaled median absolute deviations
channels = 1:length(channel_layout.label);
channels = channels';

if any(outliers)
    bad_channels = channels(outliers);

    cfg = [];
    cfg.method = 'average';
    % FT bug - badchannel needs to have a name since it's compared to
    % data.label and not just an index
    badchan_cell = data.label(bad_channels);
    cfg.badchannel = badchan_cell;
    cfg.neighbours = neighbours;
    [data_clean] = ft_channelrepair(cfg, data);
    % get cleaned data for particular channel type bad channels lie
    % next to each other. In that case the bad channels will be removed from the
    % neighbours and not considered for interpolation.
    data_out = data_clean; %.trial{1,1}(channels,:)
else
    data_clean = data;
    data_out = data_clean;
    bad_channels = [];
end
bad_channels_fig = figure('visible','off');
%subplot(1,2,1)
hold on
plot(1:length(var_chans),var_chans,'o')
plot(find(outliers),var_chans(outliers),'or')
xlabel('Channels')
ylabel('Variance')
title('Variance of channels')
%subplot(1,2,2)
%ts = reshape(data.trial{1,1},length(data.label),[],100);
%mean_ts = mean(ts,3);
%plot(mean_ts(channels,:)','k')
%plot(mean_ts(bad_channels,:)','r')
%title('Mean of time series')
disp('bad channels:');
fprintf(1, '%s \n', data.label{bad_channels});
saveas(bad_channels_fig,[rdir '/bad_channels.jpg'])
clearvars varchans nbad
