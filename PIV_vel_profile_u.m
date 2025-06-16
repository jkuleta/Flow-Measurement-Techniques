function [x_index, velocity_profile] = PIV_vel_profile_u(Xgrid, Ygrid, Vx_grid, Vy_grid,Vmag_grid, x_position)

[~, x_index] = min(abs(Xgrid(1,:) - x_position)); % Find the index where Xgrid is closest to 120
velocity_profile = Vx_grid(:, x_index); % Velocity magnitude at that x
end
