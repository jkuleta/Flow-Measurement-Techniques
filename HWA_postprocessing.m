[AoA0, AoA5, AoA15] = load_HWA();

figure;
subplot(1,2,1);
plot(AoA0.y_locations, AoA0.Vmean, 'x-', 'DisplayName', 'AoA 0°', 'LineWidth', 1.5);
hold on;
plot(AoA5.y_locations, AoA5.Vmean, 'x-', 'DisplayName', 'AoA 5°', 'LineWidth', 1.5);
plot(AoA15.y_locations, AoA15.Vmean, 'x-', 'DisplayName', 'AoA 15°', 'LineWidth', 1.5);
xlabel('y location (m)');
ylabel('Mean Velocity (m/s)');
legend('Location', 'best');
grid on;

subplot(1,2,2);
plot(AoA0.y_locations, AoA0.Vrms, 'x-', 'DisplayName', 'AoA 0°', 'LineWidth', 1.5);
hold on;
plot(AoA5.y_locations, AoA5.Vrms, 'x-', 'DisplayName', 'AoA 5°','LineWidth', 1.5);   
plot(AoA15.y_locations, AoA15.Vrms, 'x-', 'DisplayName', 'AoA 15°', 'LineWidth', 1.5);
grid on;
legend('Location', 'best');
ylabel('RMS Velocity (m/s)');
xlabel('y location (m)');



figure;
loglog(AoA0.f, AoA0.pxx, 'DisplayName', 'AoA 0°', 'LineWidth',1.5);
hold on;
loglog(AoA5.f, AoA5.pxx, 'DisplayName', 'AoA 5°', 'LineWidth',1.5);
loglog(AoA15.f, AoA15.pxx, 'DisplayName', 'AoA 15°', 'LineWidth',1.5);
xlabel('Frequency (Hz)');
ylabel('Power Spectral Density (m^2/s^2/Hz)');
legend('Location', 'best');
grid on;


function [AoA0, AoA5, AoA15] = load_HWA()  
    folder_path = 'Group17_HWA';
    files = dir(fullfile(folder_path, '*.txt'));

    nb_files = (numel(files) - 3)/3; % remove three non-measurement files and pass forward

    y_locations_AoA0 = [];
    y_locations_AoA5 = [];
    y_locations_AoA15 = [];

    Vmean_AoA0 = [];
    Vmean_AoA5 = [];
    Vmean_AoA15 = [];

    Vrms_AoA0 = [];
    Vrms_AoA5 = [];
    Vrms_AoA15 = [];

    disp('Running HWA postprocessing...');

    for k = 1:length(files)
        filename = files(k).name;
        file_path = fullfile(folder_path, filename);

        data = load(file_path);
        name_parts = split(erase(filename, '.txt'), '_');

        if strcmp(name_parts{1}, 'calibration') && numel(name_parts) == 1
            velocity = data(:, 1);
            voltage = data(:, 2);

            % Fit a 4th order polynomial: velocity = f(voltage)
            coeffs = polyfit(voltage, velocity, 4);
            polynomial = @(v) polyval(coeffs, v);

        elseif numel(name_parts) == 3
            y_location = str2double(name_parts{2});
            AoA = str2double(name_parts{3});

            velocity = polynomial(data(:, 2)); % data(:,2) is voltage

            Mean = mean(velocity);
            Rms = std(velocity);

            if AoA == 0
                y_locations_AoA0(end+1) = y_location;
                Vmean_AoA0(end+1) = Mean;
                Vrms_AoA0(end+1) = Rms;

                if y_location == 0
                    [pxxAoA0, fAoA0] = pwelch(velocity, [], [], [], 1/(data(2,1)-data(1,1)));
                end
            elseif AoA == 5
                y_locations_AoA5(end+1) = y_location;
                Vmean_AoA5(end+1) = Mean;
                Vrms_AoA5(end+1) = Rms;

                if y_location == -4
                    [pxxAoA5, fAoA5] = pwelch(velocity, [], [], [], 1/(data(2,1)-data(1,1)));
                end
            else
                y_locations_AoA15(end+1) = y_location;
                Vmean_AoA15(end+1) = Mean;
                Vrms_AoA15(end+1) = Rms;
                if y_location == -24
                    [pxxAoA15, fAoA15] = pwelch(velocity, [], [], [], 1/(data(2,1)-data(1,1)));
                end
            end
        end
    end

    % Sort AoA 0
    [y_locations_AoA0, idx0] = sort(y_locations_AoA0);
    Vmean_AoA0 = Vmean_AoA0(idx0);
    Vrms_AoA0 = Vrms_AoA0(idx0);

    % Sort AoA 5
    [y_locations_AoA5, idx5] = sort(y_locations_AoA5);
    Vmean_AoA5 = Vmean_AoA5(idx5);
    Vrms_AoA5 = Vrms_AoA5(idx5);

    % Sort AoA 15
    [y_locations_AoA15, idx15] = sort(y_locations_AoA15);
    Vmean_AoA15 = Vmean_AoA15(idx15);
    Vrms_AoA15 = Vrms_AoA15(idx15);

    disp('Completed!');

    AoA0.y_locations = y_locations_AoA0;
    AoA0.Vmean = Vmean_AoA0;
    AoA0.Vrms = Vrms_AoA0;
    AoA0.pxx = pxxAoA0;
    AoA0.f = fAoA0;

    AoA5.y_locations = y_locations_AoA5;
    AoA5.Vmean = Vmean_AoA5;
    AoA5.Vrms = Vrms_AoA5;
    AoA5.pxx = pxxAoA5;
    AoA5.f = fAoA5;


    AoA15.y_locations = y_locations_AoA15;
    AoA15.Vmean = Vmean_AoA15;
    AoA15.Vrms = Vrms_AoA15;
    AoA15.pxx = pxxAoA15;
    AoA15.f = fAoA15;

end