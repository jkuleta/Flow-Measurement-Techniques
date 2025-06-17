clear; close all; clc;
[AoA0, AoA5, AoA15, calibration, correlation] = load_HWA();
type = 'Avg'; % Options: 'live', 'Avg', 'Stdev'
windowsize = 32;
overlap = 50;
alpha = 15;
multipass = true;
dt6 = false; %only available for alpha = 15
measurements = 100; %can only be set to 10 for alpha =15
plotinfunction = false;
PIV_xposition = 120;
[Xgrid15, Ygrid15, Vx_grid15, Vy_grid15,Vmag_grid15]=PIV_postprocessing(windowsize,overlap,alpha,type,multipass,dt6,measurements, plotinfunction);
[x_index15, velocity_profile15] = PIV_vel_profile_u(Xgrid15, Ygrid15, Vx_grid15, Vy_grid15,Vmag_grid15, PIV_xposition);

alpha = 5;

[Xgrid5, Ygrid5, Vx_grid5, Vy_grid5,Vmag_grid5]=PIV_postprocessing(windowsize,overlap,alpha,type,multipass,dt6,measurements, plotinfunction);
[x_index5, velocity_profile5] = PIV_vel_profile_u(Xgrid5, Ygrid5, Vx_grid5, Vy_grid5,Vmag_grid5, PIV_xposition);

alpha = 0;

[Xgrid0, Ygrid0, Vx_grid0, Vy_grid0,Vmag_grid0]=PIV_postprocessing(windowsize,overlap,alpha,type,multipass,dt6,measurements, plotinfunction);
[x_index0, velocity_profile0] = PIV_vel_profile_u(Xgrid0, Ygrid0, Vx_grid0, Vy_grid0,Vmag_grid0, PIV_xposition);

figure;
plot(flipud(velocity_profile0), (Ygrid0(:, x_index0)-52), 'x-','LineWidth', 1.5);
hold on;
plot(flipud(velocity_profile5), (Ygrid5(:, x_index5)-52), 'x-','LineWidth', 1.5);
plot(flipud(velocity_profile15), (Ygrid15(:, x_index15)-52), 'x-','LineWidth', 1.5);
plot(AoA0.Vmean, AoA0.y_locations, 'x-',  'LineWidth', 1.5);
plot(AoA5.Vmean, AoA5.y_locations, 'x-',  'LineWidth', 1.5);
plot(AoA15.Vmean, AoA15.y_locations, 'x-',  'LineWidth', 1.5);
legend({'PIV $\alpha = 0^\circ$', 'PIV $\alpha = 5^\circ$', 'PIV $\alpha = 15^\circ$','HWA $\alpha = 0^\circ$', 'HWA $\alpha = 5^\circ$', 'HWA $\alpha = 15^\circ$' }, ...
       'Interpreter', 'latex', 'Location', 'best');
xlabel('Streamwise Velocity Magnitude ]m/s]');
ylabel('y [mm]');
% title('Velocity Profile at Selected X Position');
grid on;