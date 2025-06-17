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
            PPAoA5.u = u;
            PPAoA5.v = v;
        elseif strcmp(filename, '15.txt')
            PPAoA15.V = V;
            PPAoA15.x_locations = x_locations;
            PPAoA15.y_locations = y_locations;
            PPAoA15.u = u;
            PPAoA15.v = v;
        end
    end

        % --- New code: Use only x_target = 20 and average if needed ---
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

    PPAoA5.V_mean = V5_avg;
    PPAoA5.y_locations_mean = y5_avg;

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

    PPAoA15.V_mean = V15_avg;
    PPAoA15.y_locations_mean = y15_avg;

    disp('Completed!');
end