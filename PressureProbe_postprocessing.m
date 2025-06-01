clear; close all; clc;
[PPAoA5, PPAoA15] = load_Pressure();

save('Group17_PressureProbe.mat', 'PPAoA5', 'PPAoA15');

figure;
scatter(PPAoA5.x_locations, PPAoA5.y_locations, 60, PPAoA5.V, 'filled');
colormap('turbo');
colorbar;
xlabel('x location (mm)');
ylabel('y location (mm)');
title('Velocity Magnitude at PPAoA5');
axis equal tight;

figure;
scatter(PPAoA15.x_locations, PPAoA15.y_locations, 60, PPAoA15.V, 'filled');
colormap('turbo');
colorbar;
xlabel('x location (mm)');
ylabel('y location (mm)');
title('Velocity Magnitude at PPAoA15');
axis equal tight;

% Define grid for interpolation for PPAoA15
xq_PPAoA15 = linspace(min(PPAoA15.x_locations), max(PPAoA15.x_locations), 200);
yq_PPAoA15 = linspace(min(PPAoA15.y_locations), max(PPAoA15.y_locations), 200);
[Xq_PPAoA15, Yq_PPAoA15] = meshgrid(xq_PPAoA15, yq_PPAoA15);

% Interpolate the scattered data onto the grid
Vq_PPAoA15 = griddata(PPAoA15.x_locations, PPAoA15.y_locations, PPAoA15.V, Xq_PPAoA15, Yq_PPAoA15, 'natural');

% Plot the smoothed heat map with a differentiating colormap
figure;
contourf(Xq_PPAoA15, Yq_PPAoA15, Vq_PPAoA15, 50, 'LineColor', 'none');  % 50 contour levels
colormap('turbo'); % Use 'parula' for a more differentiating color scheme
colorbar;
xlabel('x');
ylabel('y');
title('Smoothed Velocity Magnitude Heat Map (PPAoA15)');
axis equal tight;

% Store color limits for consistency
%clims = caxis;

% Define grid for interpolation for PPAoA5
xq_PPAoA5 = linspace(min(PPAoA5.x_locations), max(PPAoA5.x_locations), 200);
yq_PPAoA5= linspace(min(PPAoA5.y_locations), max(PPAoA5.y_locations), 200);
[Xq_PPAoA5, Yq_PPAoA5] = meshgrid(xq_PPAoA5, yq_PPAoA5);

% Interpolate the scattered data onto the grid
Vq_PPAoA5 = griddata(PPAoA5.x_locations, PPAoA5.y_locations, PPAoA5.V, Xq_PPAoA5, Yq_PPAoA5, 'natural');

% Plot the smoothed heat map using the same colormap and color scale
figure;
contourf(Xq_PPAoA5, Yq_PPAoA5, Vq_PPAoA5, 50, 'LineColor', 'none');  % 50 contour levels
colormap('turbo'); % Use the same colormap as the first figure
colorbar;
caxis;%(clims);      % Use the same color scale as the first figure
xlabel('x');
ylabel('y');
title('Smoothed Velocity Magnitude Heat Map (PPAoA5)');
axis equal tight;

figure;
plot(PPAoA5.y_locations_mean, PPAoA5.V_mean, 'x-', 'DisplayName', 'AoA 5°', 'LineWidth', 1.5);
hold on;
plot(PPAoA15.y_locations_mean, PPAoA15.V_mean, 'x-', 'DisplayName', 'AoA 15°', 'LineWidth', 1.5);
xlabel('y location (m)');
ylabel('Mean Velocity (m/s)');
legend('Location', 'best');
grid on;

function [PPAoA5, PPAoA15] = load_Pressure()
    folder_path = 'Group17_Pressure';
    files = dir(fullfile(folder_path, '*.txt'));

    disp('Running Pressure Probe postprocessing...');

    for i = 1:length(files)
        filename = files(i).name;
        file_path = fullfile(folder_path, filename);

        data = readmatrix(file_path, 'NumHeaderLines',1);

        data = data(~any(isnan(data), 2), :); % Remove rows with NaN values

        x_locations = data(:, 1);
        y_locations = data(:, 2);
        u = data(:, 3);
        v = data(:, 4);

        V = sqrt(u.^2 + v.^2); % Calculate velocity magnitude

        if strcmp(filename, '5.txt')
            PPAoA5.V = V;
            PPAoA5.x_locations = x_locations;
            PPAoA5.y_locations = y_locations;
        elseif strcmp(filename, '15.txt')
            PPAoA15.V = V;
            PPAoA15.x_locations = x_locations;
            PPAoA15.y_locations = y_locations;
        end
    end
    % Extract velocity magnitude at an x location of interest
    x_loc_mean = 50;
    indices_PPAoA5 = find(PPAoA5.x_locations == x_loc_mean);
    indices_PPAoA15 = find(PPAoA15.x_locations == x_loc_mean);

    PPAoA5.y_locations_mean = PPAoA5.y_locations(indices_PPAoA5);
    PPAoA5.V_mean = PPAoA5.V(indices_PPAoA5);

    PPAoA15.y_locations_mean = PPAoA15.y_locations(indices_PPAoA15);
    PPAoA15.V_mean = PPAoA15.V(indices_PPAoA15);


    if isempty(indices_PPAoA15)
        disp('No data found for AoA 15° at the specified x location. Averaging around the closest points...');
        indices_PPAoA15 = find(abs(PPAoA15.x_locations - x_loc_mean) < 10);
        PPAoA15.y_locations_mean = PPAoA15.y_locations(indices_PPAoA15);
        PPAoA15.y_locations_mean = PPAoA15.y_locations_mean(1:2:end-1);
        disp(length(PPAoA15.y_locations_mean));

        V = PPAoA15.V(indices_PPAoA15);
        for i=1:length(PPAoA15.y_locations_mean)
            PPAoA15.V_mean(i) = 0.5*(V(2*i) + V(2*i-1)); % Average the two closest points
        end
    end

    if isempty(indices_PPAoA5)
        disp('No data found for AoA 5° at the specified x location. Averaging around the closest points...');
        indices_PPAoA5 = find(abs(PPAoA5.x_locations - x_loc_mean) < 10);
        PPAoA5.y_locations_mean = PPAoA5.y_locations(indices_PPAoA5);
        PPAoA5.y_locations_mean = PPAoA15.y_locations_mean(1:2:end-1);
        V = PPAoA5.V(indices_PPAoA5);
        for i=1:length(PPAoA5.y_locations_mean)
            PPAoA5.V_mean(i) = 0.5*(V(2*i) + V(2*i-1)); % Average the two closest points
        end
    end

    disp('Completed!');
end