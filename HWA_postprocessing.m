clear; close all; clc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% VERIFY LOCATIONS FOR SPECTRAL PLOTS, THERE MIGHT BE A MISTAKE IN DECIDING 
% WHICH PROBE LOCATION WE SHOULD CONSIDER
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[AoA0, AoA5, AoA15, calibration, correlation] = load_HWA();


load('Group17_PressureProbe.mat');

set(groot, 'defaultAxesFontSize', 12);
set(groot, 'defaultTextFontSize', 12);

figure;
plot(correlation.time, correlation.velocity, 'LineWidth', 1.5);
title('Velocity');

% Sampling time and autocorrelation
% Correlation coefficient
sigma2 = var(correlation.velocity);
n = 1; R_E(n) = mean(correlation.velocity.^2)/sigma2;
while R_E(n) > 0
    n= n+1;
    R_E(n) = mean(correlation.velocity(1:end-n+1).*correlation.velocity(n:end))/sigma2;
end
R_E = R_E/R_E(1); % Normalize the correlation coefficient 

figure;
plot(correlation.time(1:n-1), R_E(1:n-1));
title('Autocorrelation');

T_I = trapz(correlation.time(1:n-1), R_E(1:n-1));
fprintf('Intergral time scale T_I = %f', T_I);

figure;
scatter(calibration.voltage, calibration.velocity, 80, 's', 'filled', 'k', 'DisplayName', 'Measurement data'); hold on;
plot(linspace(min(calibration.voltage), max(calibration.voltage), 100), calibration.polynomial(linspace(min(calibration.voltage), max(calibration.voltage), 100)), 'k--', 'DisplayName', 'Polynomial fit', 'LineWidth', 1.5);
% Display the polynomial equation on the plot
eq_str = sprintf(['$U = %.3g V^4 %+.3g V^3 %+.3g V^2$\n' ...
                  '$\\quad %+.3g V %+.3g$'], calibration.coeffs);
text(-3, 17, eq_str, ...
    'Interpreter', 'latex', 'FontSize', 14, 'VerticalAlignment', 'top');
grid on;
xlabel('Voltage $V$ [V]', 'Interpreter', 'latex');
ylabel('Velocity $U$[m/s]', 'Interpreter', 'latex');
legend('Location', 'best');


figure;

% Subplot 1: Mean velocity
subplot(1,2,1);
plot(AoA0.Vmean, AoA0.y_locations, 'x-',  'LineWidth', 1.5);
hold on;
plot(AoA5.Vmean, AoA5.y_locations, 'x-', 'LineWidth', 1.5);
plot(AoA15.Vmean, AoA15.y_locations,  'x-', 'LineWidth', 1.5);
ylabel('$y$ [m]', 'Interpreter', 'latex');
xlabel('Mean velocity $\bar{U}$ [m/s]', 'Interpreter', 'latex');
legend({'$\alpha = 0^\circ$', '$\alpha = 5^\circ$', '$\alpha = 15^\circ$'}, ...
       'Interpreter', 'latex', 'Location', 'best');
ylim([min(AoA0.y_locations) max(AoA15.y_locations)]);
grid on;

% Subplot 2: RMS of fluctuations
subplot(1,2,2);
plot(AoA0.Vrms, AoA0.y_locations, 'x-', 'LineWidth', 1.5);
hold on;
plot(AoA5.Vrms, AoA5.y_locations,  'x-', 'LineWidth', 1.5);   
plot(AoA15.Vrms, AoA15.y_locations, 'x-', 'LineWidth', 1.5);
xlabel("Fluctuation RMS $\sqrt{u'}$ [m/s]", 'Interpreter', 'latex');
ylabel('$y$ [m]', 'Interpreter', 'latex');
legend({'$\alpha = 0^\circ$', '$\alpha = 5^\circ$', '$\alpha = 15^\circ$'}, ...
       'Interpreter', 'latex', 'Location', 'best');
grid on;


figure;
x_piv = 4.15;

% Plot once to get y-limits for shading, store plot handles for legend colors
h1 = loglog(AoA0.f, AoA0.pxx, '-', 'LineWidth', 1.5); 
hold on;
h2 = loglog(AoA5.f, AoA5.pxx, '-', 'LineWidth', 1.5);  
h3 = loglog(AoA15.f, AoA15.pxx, '-', 'LineWidth', 1.5); 

xlim([0 10000]); % Set x-axis limits
grid on;
ylim([1e-7 250])
y_limits = ylim;

% Plot the shaded region first so it stays in the background
fill([1e-1 x_piv x_piv 1e-1], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
    [0.7 1 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.3);

% Redraw plots to keep them above the fill, using the same colors as before
loglog(AoA0.f, AoA0.pxx, '-', 'Color', h1.Color, 'DisplayName', 'AoA 0°', 'LineWidth', 1.5); 
loglog(AoA5.f, AoA5.pxx, '-', 'Color', h2.Color, 'DisplayName', 'AoA 5°', 'LineWidth', 1.5);  
loglog(AoA15.f, AoA15.pxx, '-', 'Color', h3.Color, 'DisplayName', 'AoA 15°', 'LineWidth', 1.5); 

% Add vertical dashed line at x_piv
xline(x_piv, '--', 'LineWidth', 1);

% Annotate the vertical line
text(x_piv * 0.6, y_limits(1) * 2, 'PIV resolution', 'Rotation', 0, ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 14);

xlabel('Frequency (Hz)');
ylabel('Power Spectral Density (m^2/s^2/Hz)');
legend({'AoA 0°', 'AoA 5°', 'AoA 15°'}, 'Location', 'best');



function [AoA0, AoA5, AoA15, calibration, correlation] = load_HWA()  
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

            calibration.polynomial = polynomial; % Store the polynomial function for later use
            calibration.coeffs = coeffs; % Store the coefficients for reference
            calibration.voltage = voltage; % Store the voltage data
            calibration.velocity = velocity; % Store the velocity data

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
        elseif strcmp(name_parts{1}, 'correlation') && numel(name_parts) == 2
            time = data(:, 1);
            voltage = data(:, 2);
            velocity = polynomial(voltage);

            correlation.time = time;
            correlation.velocity = velocity;
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