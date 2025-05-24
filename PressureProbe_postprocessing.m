[AoA5, AoA15] = load_Pressure();


% Define grid for interpolation for AoA15
xq = linspace(min(AoA15.x_locations), max(AoA15.x_locations), 200);
yq = linspace(min(AoA15.y_locations), max(AoA15.y_locations), 200);
[Xq, Yq] = meshgrid(xq, yq);

% Interpolate the scattered data onto the grid
Vq_AoA15 = griddata(AoA15.x_locations, AoA15.y_locations, AoA15.V, Xq, Yq, 'natural');

% Plot the smoothed heat map with a differentiating colormap
figure;
contourf(Xq, Yq, Vq_AoA15, 50, 'LineColor', 'none');  % 50 contour levels
colormap('turbo'); % Use 'parula' for a more differentiating color scheme
colorbar;
xlabel('x');
ylabel('y');
title('Smoothed Velocity Magnitude Heat Map (AoA15)');
axis equal tight;

% Store color limits for consistency
clims = caxis;

% Define grid for interpolation for AoA5
xq = linspace(min(AoA5.x_locations), max(AoA5.x_locations), 200);
yq = linspace(min(AoA5.y_locations), max(AoA5.y_locations), 200);
[Xq, Yq] = meshgrid(xq, yq);

% Interpolate the scattered data onto the grid
Vq_AoA5 = griddata(AoA5.x_locations, AoA5.y_locations, AoA5.V, Xq, Yq, 'natural');

% Plot the smoothed heat map using the same colormap and color scale
figure;
contourf(Xq, Yq, Vq_AoA5, 50, 'LineColor', 'none');  % 50 contour levels
colormap('turbo'); % Use the same colormap as the first figure
colorbar;
caxis(clims);      % Use the same color scale as the first figure
xlabel('x');
ylabel('y');
title('Smoothed Velocity Magnitude Heat Map (AoA5)');
axis equal tight;


function [AoA5, AoA15] = load_Pressure()
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
            AoA5.V = V;
            AoA5.x_locations = x_locations;
            AoA5.y_locations = y_locations;
        elseif strcmp(filename, '15.txt')
            AoA15.V = V;
            AoA15.x_locations = x_locations;
            AoA15.y_locations = y_locations;
        end
    end
    disp('Completed!');
end