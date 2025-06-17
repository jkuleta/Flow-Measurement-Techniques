clear; close all; clc;

% Load data
[AoA0, AoA5, AoA15, calibration, correlation] = load_HWA();
[PPAoA5, PPAoA15] = load_Pressure();

%% Mean plots


% Common PIV settings
type = 'Avg'; % Options: 'live', 'Avg', 'Stdev'
windowsize = 32;
overlap = 50;
multipass = true;
dt6 = false; % only available for alpha = 15
measurements = 100; % can only be set to 10 for alpha =15
plotinfunction = false;
PIV_xposition = 120;

% AoA = 0
alpha = 0;
[Xgrid0, Ygrid0, Vx_grid0, Vy_grid0, Vmag_grid0] = PIV_postprocessing(windowsize, overlap, alpha, type, multipass, dt6, measurements, plotinfunction);
[x_index0, velocity_profile0] = PIV_vel_profile_u(Xgrid0, Ygrid0, Vx_grid0, Vy_grid0, Vmag_grid0, PIV_xposition);

% AoA = 5
alpha = 5;
[Xgrid5, Ygrid5, Vx_grid5, Vy_grid5, Vmag_grid5] = PIV_postprocessing(windowsize, overlap, alpha, type, multipass, dt6, measurements, plotinfunction);
[x_index5, velocity_profile5] = PIV_vel_profile_u(Xgrid5, Ygrid5, Vx_grid5, Vy_grid5, Vmag_grid5, PIV_xposition);

% AoA = 15
alpha = 15;
[Xgrid15, Ygrid15, Vx_grid15, Vy_grid15, Vmag_grid15] = PIV_postprocessing(windowsize, overlap, alpha, type, multipass, dt6, measurements, plotinfunction);
[x_index15, velocity_profile15] = PIV_vel_profile_u(Xgrid15, Ygrid15, Vx_grid15, Vy_grid15, Vmag_grid15, PIV_xposition);

% Create figure with wider size for square-like subplots
figure('Position', [100, 100, 1200, 500]); % [left, bottom, width, height]
t = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% AoA = 0 plot
nexttile
h1 = plot(flipud(velocity_profile0), Ygrid0(:, x_index0)-52, 'x-', 'LineWidth', 1.5); hold on;
h2 = plot(AoA0.Vmean, AoA0.y_locations, 'x-', 'LineWidth', 1.5);
h3 = plot(NaN, NaN, 'x-', 'LineWidth', 1.5); % Dummy for PP
title('\textbf{$\alpha = 0^\circ$}', 'Interpreter', 'latex');
xlabel('Velocity [m/s]');
ylabel('y [mm]');
grid on;
ylim([-60 60]);
axis square;

% AoA = 5 plot
nexttile
h4 = plot(flipud(velocity_profile5), Ygrid5(:, x_index5)-52, 'x-', 'LineWidth', 1.5); hold on;
h5 = plot(AoA5.Vmean, AoA5.y_locations, 'x-', 'LineWidth', 1.5);
if exist('PPAoA5', 'var')
    h6 = plot(PPAoA5.V_mean, PPAoA5.y_locations_mean, 'x-', 'LineWidth', 1.5);
else
    h6 = plot(NaN, NaN, 'x-', 'LineWidth', 1.5); % Dummy for PP
end
title('\textbf{$\alpha = 5^\circ$}', 'Interpreter', 'latex');
xlabel('Velocity [m/s]');
grid on;
ylim([-60 60]);
axis square;

% AoA = 15 plot
nexttile
h7 = plot(flipud(velocity_profile15), Ygrid15(:, x_index15)-52, 'x-', 'LineWidth', 1.5); hold on;
h8 = plot(AoA15.Vmean, AoA15.y_locations, 'x-', 'LineWidth', 1.5);
if exist('PPAoA15', 'var')
    h9 = plot(PPAoA15.V_mean, PPAoA15.y_locations_mean, 'x-', 'LineWidth', 1.5);
else
    h9 = plot(NaN, NaN, 'x-', 'LineWidth', 1.5); % Dummy for PP
end
title('$\alpha = 15^\circ$', 'Interpreter', 'latex');
xlabel('Velocity [m/s]');
grid on;
ylim([-60 60]);
axis square;

% Add common legend below all tiles
if exist('PPAoA5', 'var')
    legendHandles = [h4, h5, h6];
else
    legendHandles = [h4, h5];
end

lgd = legend(legendHandles, ...
       {'Particle Image Velocimetry (PIV)', 'Hot Wire Anemometry', 'Pressure Probe'}, ...
       'Interpreter', 'latex', ...
       'Orientation', 'horizontal', ...
       'Location', 'southoutside', ...
       'Box', 'on');
lgd.FontSize = 14;



%% Fluctuation plots
type = 'Stdev'; % Options: 'live', 'Avg', 'Stdev'

% AoA = 0
alpha = 0;
[Xgrid0, Ygrid0, Vx_grid0, Vy_grid0, Vmag_grid0] = PIV_postprocessing(windowsize, overlap, alpha, type, multipass, dt6, measurements, plotinfunction);
[x_index0, velocity_profile0] = PIV_vel_profile_u(Xgrid0, Ygrid0, Vx_grid0, Vy_grid0, Vmag_grid0, PIV_xposition);

% AoA = 5
alpha = 5;
[Xgrid5, Ygrid5, Vx_grid5, Vy_grid5, Vmag_grid5] = PIV_postprocessing(windowsize, overlap, alpha, type, multipass, dt6, measurements, plotinfunction);
[x_index5, velocity_profile5] = PIV_vel_profile_u(Xgrid5, Ygrid5, Vx_grid5, Vy_grid5, Vmag_grid5, PIV_xposition);

% AoA = 15
alpha = 15;
[Xgrid15, Ygrid15, Vx_grid15, Vy_grid15, Vmag_grid15] = PIV_postprocessing(windowsize, overlap, alpha, type, multipass, dt6, measurements, plotinfunction);
[x_index15, velocity_profile15] = PIV_vel_profile_u(Xgrid15, Ygrid15, Vx_grid15, Vy_grid15, Vmag_grid15, PIV_xposition);


% Create figure with wider size for square-like subplots
figure('Position', [100, 100, 1200, 500]); % [left, bottom, width, height]
t = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% AoA = 0 plot
nexttile
h1 = plot(flipud(velocity_profile0), Ygrid0(:, x_index0)-52, 'x-', 'LineWidth', 1.5); hold on;
h2 = plot(AoA0.Vrms, AoA0.y_locations, 'x-', 'LineWidth', 1.5);
title('\textbf{$\alpha = 0^\circ$}', 'Interpreter', 'latex');
xlabel('Velocity [m/s]');
ylabel('y [mm]');
grid on;
ylim([-60 60]);
axis square;

% AoA = 5 plot
nexttile
h4 = plot(flipud(velocity_profile5), Ygrid5(:, x_index5)-52, 'x-', 'LineWidth', 1.5); hold on;
h5 = plot(AoA5.Vrms, AoA5.y_locations, 'x-', 'LineWidth', 1.5);
title('\textbf{$\alpha = 5^\circ$}', 'Interpreter', 'latex');
xlabel('Velocity [m/s]');
grid on;
ylim([-60 60]);
axis square;

% AoA = 15 plot
nexttile
h7 = plot(flipud(velocity_profile15), Ygrid15(:, x_index15)-52, 'x-', 'LineWidth', 1.5); hold on;
h8 = plot(AoA15.Vrms, AoA15.y_locations, 'x-', 'LineWidth', 1.5);
title('\textbf{$\alpha = 15^\circ$}', 'Interpreter', 'latex');
xlabel('Velocity [m/s]');
grid on;
ylim([-60 60]);
axis square;


legendHandles = [h4, h5];
lgd = legend(legendHandles, ...
       {'Particle Image Velocimetry (PIV)', 'Hot Wire Anemometry (HWA)'}, ...
       'Interpreter', 'latex', ...
       'Orientation', 'horizontal', ...
       'Location', 'southoutside', ...
       'Box', 'on');
lgd.FontSize = 14;

