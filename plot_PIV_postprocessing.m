clear all; close all; clc;

type = 'Stdev'; % Options: 'live', 'Avg', 'Stdev'
windowsize = 32;
overlap = 50;
alpha = 15;
multipass = false;
dt6 = false; %only available for alpha = 15
measurements = 100; %can only be set to 10 for alpha =15
plotinfunction = false;

[Xgrid, Ygrid, Vx_grid, Vy_grid,Vmag_grid]=PIV_postprocessing(windowsize,overlap,alpha,type,multipass,dt6,measurements, plotinfunction);

x_position = 120;
[~, x_index] = min(abs(Xgrid(1,:) - x_position)); % Find the index where Xgrid is closest to 120
velocity_profile = Vmag_grid(:, x_index); % Velocity magnitude at that x

figure;
plot(velocity_profile, Ygrid(:, x_index), 'b-o');
xlabel('Velocity Magnitude');
ylabel('y [mm]');
% title('Velocity Profile at Selected X Position');
grid on;

% Find indices where Xgrid is between -20 and 120
x_range_indices = find(Xgrid(1,:) >= -20 & Xgrid(1,:) <= 120);

% Restrict Vmag_grid to these columns
Vmag_sub = Vmag_grid(:, x_range_indices);

% Find max in the restricted region
[max_val, linear_index] = max(Vmag_sub(:));
[y_max, x_sub_max] = ind2sub(size(Vmag_sub), linear_index);
x_max = x_range_indices(x_sub_max);

disp(['Maximum velocity is ', num2str(max_val), ...
    ' at (x, y) = (', num2str(Xgrid(1, x_max)), ', ', num2str(Ygrid(y_max, x_max)), ')']);
