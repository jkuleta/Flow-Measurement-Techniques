type = 'Avg';
windowsize = 32;
overlap = 50;
alpha = 0;
multipass = false;
dt6 = false;
measurements = 100;
plotinfunction = false;

[Xgrid, Ygrid, Vx_grid, Vy_grid,Vmag_grid]=PIV_postprocessing(windowsize,overlap,alpha,type,multipass,dt6,measurements, plotinfunction);
    
x_position = 120;
[~, x_index] = min(abs(Xgrid(1,:) - x_position)); % Find the index where Xgrid is closest to 120
velocity_profile = Vmag_grid(:, x_index); % Velocity magnitude at that x

figure;
plot(velocity_profile, Ygrid(:, x_index), 'b-o');
xlabel('Velocity Magnitude');
ylabel('Y Position');
title('Velocity Profile at Selected X Position');
grid on;