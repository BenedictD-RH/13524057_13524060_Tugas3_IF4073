function loss = maskedCE(Y, T, w)
    valid = ~isnan(T);
    T(~valid) = 0;
    pixW = sum(T .* reshape(w, 1, 1, []), 3);        % weight of each pixel's true class
    ce = -sum(T .* log(max(Y, eps)), 3) .* pixW;     % weighted per-pixel loss
    loss = sum(ce, "all") / max(sum(pixW, "all"), eps);   % normalize by total weight
end