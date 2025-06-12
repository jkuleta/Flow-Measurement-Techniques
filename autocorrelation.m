function T = integral_time_scale(u, dt)
    % Remove mean from signal
    u = u - mean(u);

    % Compute autocorrelation using unbiased estimate
    [R, lags] = xcorr(u, 'unbiased');

    % Normalize autocorrelation by zero-lag value
    R = R / R(lags == 0);

    % Use only non-negative lags
    R_pos = R(lags >= 0);
    lags_pos = lags(lags >= 0);

    % Find first zero crossing
    zero_idx = find(R_pos <= 0, 1);
    if isempty(zero_idx)
        % If no zero crossing found, use full autocorrelation
        zero_idx = length(R_pos);
    end

    % Integrate using trapezoidal rule up to zero crossing
    T = trapz(lags_pos(1:zero_idx) * dt, R_pos(1:zero_idx));
end
