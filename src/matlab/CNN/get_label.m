function label = get_label(color)
    lines = readlines("label_colors.txt");
    lines = lines(strlength(strtrim(lines)) > 0);
    
    n = numel(lines);
    for i = 1:n
        tok = split(strtrim(lines(i)));
        rgb = str2double(tok(1:3))';
        name = tok(4);
        if color_key(rgb) == color_key(color)
            label = map_label(name);
            break;
        end
    end 
end