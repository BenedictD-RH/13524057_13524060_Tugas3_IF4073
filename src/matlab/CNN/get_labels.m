function labels = get_labels(L, tableKey, labelMap)
    L = double(L);
    pixKey = L(:,:,1)*65536 + L(:,:,2)*256 + L(:,:,3);

    [found, loc] = ismember(pixKey, tableKey);
    labels = zeros(size(pixKey), "uint8");
    labels(found) = labelMap(loc(found));  
end