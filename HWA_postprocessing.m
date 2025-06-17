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

u = correlation.velocity - mean(correlation.velocity);  
t = correlation.time;% Extract velocity data
% Compute / plot correlation coefficient
n = 1;
sigma2 = var(u);  % Variance of velocity fluctuations
R_E(n) = mean(u.^2) / sigma2;  % Initialize


while R_E(n) > 0  % Compute while positive
    n = n + 1;  % Update counter
    R_E(n) = mean(u(1:end-n+1) .* u(n:end)) / sigma2;
end

% Calculate macro time scale & compare with target
T_E = trapz(t(1:n), R_E);  % Compute macro time scale (s)


figure;
plot(correlation.time(1:n-1), R_E(1:n-1), 'LineWidth', 1.5);
xlabel('$\tau$ [s]', 'Interpreter', 'latex');
ylabel('$R_E(\tau)$', 'Interpreter', 'latex');
grid on;


fprintf('Integral time scale T_I = %f\n', T_E);

epsilon = 1-0.997;
k = 3;
U = mean(correlation.velocity);
RMS = std(correlation.velocity);

N = (k * RMS /(epsilon*U))^2;  % Number of samples needed for convergence

fprintf('Number of samples needed for convergence N = %d\n', N);

T = 2*N*T_E;  % Total time needed for convergence
fprintf('Total time needed for convergence T = %f s\n', T);

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

xlabel('Frequency [Hz]', 'Interpreter', 'latex');
ylabel('Power Spectral Density [$m^2/s^2/Hz$]', 'Interpreter', 'latex');
legend({'$\alpha = 0^\circ$', '$\alpha = 5^\circ$', '$\alpha = 15^\circ$'}, ...
    'Interpreter', 'latex', 'Location', 'best');

