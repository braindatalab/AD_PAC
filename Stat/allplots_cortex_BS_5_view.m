function allplots_cortex_BS_5_view(cortex, data_in, colorlimits, cm, unit, smooth, printfolder, varargin)
% (C) 2018 Stefan Haufe
%
% If you use this code in a publication, please cite
%
% Haufe, S., & Ewald, A. (2016). A simulation framework for benchmarking
% EEG-based brain connectivity estimation methodologies. Brain topography, 1-18.

if nargin < 7
    printfolder = '';
end

if length(data_in) == size(cortex.Vertices, 1)
    data = data_in;
else
    % find Atlas with the same number of ROIs
    for iatl = 1:length(cortex.Atlas)
        if length(data_in) == length(cortex.Atlas(iatl).Scouts)
            data = nan * ones(size(cortex.Vertices, 1), 1);
            for iroi = 1:length(cortex.Atlas(iatl).Scouts)
                data(cortex.Atlas(iatl).Scouts(iroi).Vertices) = data_in(iroi);
            end
            break;
        end
    end
end

% Identify 'Structures' Atlas
for iatl = 1:length(cortex.Atlas)
    if isequal(cortex.Atlas(iatl).Name, 'Structures')
        break;
    end
end

% Left and Right Faces
cortex.Faces_left = cortex.Faces;
cortex.Faces_left(min(ismember(cortex.Faces_left, cortex.Atlas(iatl).Scouts(1).Vertices), [], 2) == 0, :) = [];

cortex.Faces_right = cortex.Faces;
cortex.Faces_right(min(ismember(cortex.Faces_right, cortex.Atlas(iatl).Scouts(2).Vertices), [], 2) == 0, :) = [];

set(0, 'DefaultFigureColor', [1 1 1])
res = '400';

% Smoothing
if smooth
    SurfSmoothIterations = ceil(300 * smooth * length(cortex.Vertices) / 100000);
    vc = tess_smooth(cortex.Vertices, 1, SurfSmoothIterations, tess_vertconn(cortex.Vertices, cortex.Faces), 1);
    sm = '_smooth';
else
    vc = cortex.Vertices;
    sm = '';
end

% Surface Parameters
surface_pars = struct('alpha_const', 1, 'colormap', cm, 'colorlimits', colorlimits, ...
    'showdirections', 0, 'colorbars', 0, 'dipnames', [], 'mymarkersize', 15, 'directions', [0 0 1 1 1 1], ...
    'printcbar', 0, 'userticks', []);

% Optional user overrides
if length(varargin) > 0
    varargin1 = varargin{1};
else
    varargin1 = {};
end
if length(varargin) > 1
    input_pars = varargin{2};
    finames = fieldnames(input_pars);
    for ifi = 1:length(finames)
        surface_pars.(finames{ifi}) = input_pars.(finames{ifi});
    end
end

% Define views and faces
views = {
    [-1 0 0], cortex.Faces_left;     % Left lateral
    [1 0 0],  cortex.Faces_right;    % Right lateral
    [1 0 0],  cortex.Faces_left;     % Left lateral again
    [-1 0 0], cortex.Faces_right;    % Right lateral again
    [0 1e-1 -1], cortex.Faces;       % Top angled
    [0 -1e-1 1], cortex.Faces        % Bottom angled
};

% Plot each view and save separately
for i = 1:length(views)-1
    fig = figure('Visible', 'off', 'Position', [10 10 900 900]);
    surface_pars.myviewdir = views{i, 1};
    current_faces = views{i, 2};

    if i <= 4
        showsurface3(vc, current_faces, surface_pars, data, varargin1{:});
    else
        showsurface3t(vc, current_faces, surface_pars, data, varargin1{:});
    end

    export_fig([printfolder '_' num2str(i) '.png'], ['-r' res], '-transparent');
    close(fig);
end

% Save colorbar separately
fig_cb = figure('Visible', 'off', 'Position', [10 10 800 800]);
h = axes;
hf = imagesc(randn(5)); 
colormap(cm);
set(h, 'clim', colorlimits, 'visible', 'off');
set(hf, 'visible', 'off');
cb = colorbar('southoutside');
set(cb, 'fontsize', 30)
if ~isempty(surface_pars.userticks)
    set(cb, 'xtick', sort([colorlimits, surface_pars.userticks]))
end
ylabel(cb, unit,"FontSize",30)
export_fig([printfolder '_colorbar.png'], ['-r' res], '-transparent');
close(fig_cb);

end