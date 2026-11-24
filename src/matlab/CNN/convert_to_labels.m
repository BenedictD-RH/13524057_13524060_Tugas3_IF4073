function convert_to_labels(trainingDataDir)
    lines = readlines(trainingDataDir + "/label_colors.txt");
    lines = lines(strlength(strtrim(lines)) > 0);
    
    n = numel(lines);
    rgb = zeros(n,3);
    classes = zeros(n,1);
    for i = 1:n
        tok = split(strtrim(lines(i)));
        rgb(i,:) = str2double(tok(1:3))';
        classes(i) = map_label(tok(4));
    end

    tableKey = rgb(:,1)*65536 + rgb(:,2)*256 + rgb(:,3);
    labelDir = trainingDataDir + "/LabeledApproved_full";
    outDirLabels   = "output/labeled_images";   mkdir(outDirLabels)
    outDirResize = "output/resized_images"; mkdir(outDirResize)
    files = dir(fullfile(labelDir, "*.png"));
    
    for k = 1:numel(files)
        L = imread(fullfile(files(k).folder, files(k).name));
        out = get_labels(L, tableKey, classes);          % your mapping function
        out = imresize(out, [360 480], "nearest");    % nearest only!
        imwrite(out, fullfile(outDirLabels, files(k).name));
        L_resize = imresize(out, [360 480], "nearest");
        imwrite(L_resize, fullfile(outDirResize, files(k).name))
    end
end