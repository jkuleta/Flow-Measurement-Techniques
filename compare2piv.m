clear all; close all; clc;

type = 'Avg'; % Options: 'live', 'Avg', 'Stdev'
windowsize = 32;
overlap = 50;
alpha = 15;
multipass = false;
dt6 = false; %only available for alpha = 15
measurements1 = 100; %can only be set to 10 for alpha =15
measurements2 = 10; %can only be set to 10 for alpha =15
plotinfunction = false;
[Xgrid1, Ygrid1, Vx_grid1, Vy_grid1,Vmag_grid1]=PIV_postprocessing(windowsize,overlap,alpha,type,multipass,dt6,measurements1, plotinfunction);
[Xgrid2, Ygrid2, Vx_grid2, Vy_grid2,Vmag_grid2]=PIV_postprocessing(windowsize,overlap,alpha,type,multipass,dt6,measurements2, plotinfunction);
figure;
size(Xgrid1)
size(Vmag_grid2)
size(Vmag_grid1)
size(Vmag_grid1-Vmag_grid2)
size((Vmag_grid1-Vmag_grid2)./Vmag_grid2)
relative_difference = (Vmag_grid1-Vmag_grid2)./Vmag_grid2;
relative_difference(Vmag_grid2 == 0) = 0;
contourf(Xgrid1, Ygrid1, relative_difference, 20, 'LineColor', 'none');
colorbar;
hold on;
xlabel('x [mm]');
ylabel('y [mm]');
% title('Velocity Magnitude Contour with Velocity Vectors');
axis equal tight;
hold off;