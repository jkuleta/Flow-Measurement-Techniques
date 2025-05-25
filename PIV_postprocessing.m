
function [x,y,Vx,Vy] = PIV_postprocessing(window_size, overlap, alpha, type, multipass, dt6, measurements)
    % PIV_postprocessing.m
    % This function processes PIV data based on the specified parameters.
    % Parameters:
    %   window_size: Size of the PIV window 16, 24, 32, 64
    %   overlap: Overlap percentage (0, 50)
    %   alpha: Angle of attack (0, 5, 15)
    %   type: Type of processing ('live', 'Avg', 'Stdev')
    %   multipass: Boolean for multipass processing (true, false)
    %   dt6: Boolean for dt6 time (only set true with alpha 15) 
    %   (true, false)

    %   measurements: Number of measurements (100, 10) only set to 
    %   10 for alpha 15, otherwise set to 100!!!
    foldername_prefix = ['Alpha_' num2str(alpha)];
    if dt6
        foldername_prefix = [foldername_prefix '_dt6microsec'];
    end

    foldername_postfix = '=unknown';


    foldername_mid = '_SubOverTimeMin_sL=all_';

    if alpha==0 && overlap == 50
        foldername_mid = '_SubOverTimeMin_sL=all_SubOverTimeMin_sL=all_';
    end
    if dt6 && overlap == 0
        foldername_mid = '_SubLocalMinOfSeriesSubLocalMin_';
    end
    if multipass
        foldername_middle = [foldername_mid, '01_PIV_MP'];
    else
        foldername_middle = [foldername_mid, 'PIV_SP'];
    end
    if measurements == 10 && multipass
        foldername_middle = [foldername_mid, '03_PIV_MP_10'];
        foldername_postfix = '';
    elseif measurements == 10 && ~multipass
        foldername_middle = [foldername_mid, '02_PIV_SP_10' ];
        foldername_postfix = '';
    end
    if ~multipass && measurements ~= 10
        foldername_window = ['(' num2str(window_size) 'x' num2str(window_size) '_' num2str(overlap) 'ov)'];
    elseif multipass && measurements ~= 10
        foldername_window = ['(3x' num2str(window_size) 'x' num2str(window_size) '_' num2str(overlap) 'ov)'];
    elseif multipass && measurements == 10
        foldername_window = ['(3x' num2str(window_size) 'x' num2str(window_size) '_' num2str(overlap) '_ov)'];
    else
        foldername_window = ['(' num2str(window_size) 'x' num2str(window_size) '_' num2str(overlap) '_ov)'];
    end

    if strcmp(type, 'live') 
        foldername_type = '';
    elseif (strcmp(type, 'Avg') || strcmp(type, 'Stdev')) && (alpha ~= 5 && overlap ~= 0) && (alpha ~= 15 && overlap ~= 0)
        foldername_type = '_Avg_Stdev';
    elseif (strcmp(type, 'Avg') || strcmp(type, 'Stdev')) && ((alpha == 5 && overlap == 0) || (alpha == 15 && overlap == 0))
        foldername_type = '_TimeMeanQF_Vector'; 
    end
    full_foldername = [foldername_prefix, foldername_middle,foldername_window, foldername_type, foldername_postfix];

    filename = fullfile('Group17pivpostprocessing\Group17\',full_foldername, 'B00001.dat');
    fid = fopen(filename, 'r');
    if fid == -1
        error(['Cannot open file: ' filename]);
    end
    % Skip the first 3 lines
    for i = 1:3
        fgetl(fid);
    end

    % Read the rest of the data
    data = fscanf(fid, '%f', [5, Inf])';

    x = data(:,1);
    y = data(:,2);
    Vx = data(:,3);
    Vy = data(:,4);
    disp(size(x));
    % Read or process the file as needed
    % fclose(fid); % Close when done

    % Calculate velocity magnitude
    Vmag = sqrt(Vx.^2 + Vy.^2);

    % Create scatter plot with colormap
    figure;
    scatter(x, y, 40, Vmag, 'filled');
    colorbar;
    colormap(jet);
    xlabel('x');
    ylabel('y');
    title('Velocity Magnitude Map');
    axis equal tight;
end

% % Example usage:
% [x,y,Vx,Vy] = PIV_postprocessing(32,50,0,'Avg', multipass=true, dt6=false, measurements = 100);