clear; close all; clc;
[PPAoA5, PPAoA15] = load_Pressure();

save('Group17_PressureProbe.mat', 'PPAoA5', 'PPAoA15');

clim = [min(PPAoA5.V), max(PPAoA5.V)];

% First subplot: Measured Field
figure;
scatter(PPAoA5.x_locations, PPAoA5.y_locations, 60, PPAoA5.V, 'filled');
colormap('turbo');
colorbar;
xlabel('x [mm]');
ylabel('y [mm]');
axis equal tight;
caxis(clim);

% Interpolation grid
xq_PPAoA5 = linspace(min(PPAoA5.x_locations), max(PPAoA5.x_locations), 200);
yq_PPAoA5 = linspace(min(PPAoA5.y_locations), max(PPAoA5.y_locations), 200);
[Xq_PPAoA5, Yq_PPAoA5] = meshgrid(xq_PPAoA5, yq_PPAoA5);

% Interpolate
Vq_PPAoA5 = griddata(PPAoA5.x_locations, PPAoA5.y_locations, PPAoA5.V, Xq_PPAoA5, Yq_PPAoA5, 'natural');

% Second subplot: Interpolated Field
figure;
contourf(Xq_PPAoA5, Yq_PPAoA5, Vq_PPAoA5, 50, 'LineColor', 'none');
colormap('turbo');
colorbar;
xlabel('x [mm]');
ylabel('y [mm]');
axis equal tight;

figure; hold on; grid on;
ylabel('y [mm]');
xlabel('Mean Velocity [m/s]');

x_target = 20; % Only one location

% AoA 5°
indices5 = find(PPAoA5.x_locations == x_target);
if isempty(indices5)
    disp('No exact match for AoA 5°. Using nearby points...');
    indices5 = find(abs(PPAoA5.x_locations - x_target) < 10);
end
y5 = PPAoA5.y_locations(indices5);
V5 = PPAoA5.V(indices5);

% If too many points, average in pairs
if mod(length(y5), 2) == 0 && length(y5) >= 2
    y5_avg = y5(1:2:end);
    V5_avg = arrayfun(@(i) mean(V5(i:i+1)), 1:2:length(V5)-1);
else
    y5_avg = y5;
    V5_avg = V5;
end

plot(V5_avg, y5_avg, 'x-', 'DisplayName', 'AoA = 5°', 'LineWidth', 1.5);

% AoA 15°
indices15 = find(PPAoA15.x_locations == x_target);
if isempty(indices15)
    disp('No exact match for AoA 15°. Using nearby points...');
    indices15 = find(abs(PPAoA15.x_locations - x_target) < 10);
end
y15 = PPAoA15.y_locations(indices15);
V15 = PPAoA15.V(indices15);

% If too many points, average in pairs
if mod(length(y15), 2) == 0 && length(y15) >= 2
    y15_avg = y15(1:2:end);
    V15_avg = arrayfun(@(i) mean(V15(i:i+1)), 1:2:length(V15)-1);
else
    y15_avg = y15;
    V15_avg = V15;
end

plot(V15_avg, y15_avg, 'x-', 'DisplayName', 'AoA = 15°', 'LineWidth', 1.5);

ax = gca;
leg = legend('Location', 'best');
set(leg, 'FontSize', ax.FontSize);
