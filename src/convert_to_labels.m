function [imds, pxds] = convert_to_labels(trainingDataDir)
    lines = readlines(trainingDataDir + "\label_colors.txt");
    lines = lines(strlength(strtrim(lines)) > 0);
    
    n = numel(lines);
    rgb = zeros(n,3);
    classes = zeros(n,1);
    classNames = strings(n, 1);
    unique_n = 0;
    for i = 1:n
        tok = split(strtrim(lines(i)));
        rgb(i,:) = str2double(tok(1:3))';
        [classes(i), name] = map_label(tok(4));
        if ismember(name, classNames) == 0 && strcmp(name, 'None') == 0
            unique_n = unique_n + 1;
            classNames(classes(i)) = name;
        end
    end

    tableKey = rgb(:,1)*65536 + rgb(:,2)*256 + rgb(:,3);
    labelDir = trainingDataDir + "\LabeledApproved_full";
    rawDir = trainingDataDir + "\701_StillsRaw_full";
    outDirLabels   = "output\labeled_images";   mkdir(outDirLabels)
    outDirResize = "output\resized_images"; mkdir(outDirResize)
    files = dir(fullfile(labelDir, "*.png"));
    rawFiles = dir(fullfile(rawDir, "*.png"));
    
    for k = 1:numel(files)
        if isfile(fullfile(outDirLabels, files(k).name)) == 0
            L = imread(fullfile(files(k).folder, files(k).name));
            out = get_labels(L, tableKey, classes);
            out = imresize(out, [360 480], "nearest");
            imwrite(out, fullfile(outDirLabels, files(k).name));
        end
    end

    for k = 1:numel(rawFiles)
        if isfile(fullfile(outDirResize, rawFiles(k).name)) == 0
            L = imread(fullfile(rawFiles(k).folder, rawFiles(k).name));
            LResize = imresize(L, [360 480], "nearest");
            imwrite(LResize, fullfile(outDirResize, rawFiles(k).name))
        end
    end
    
    labelIDs = 1:unique_n;
    classNames = classNames(1:unique_n);

    imds = imageDatastore(outDirResize);
    pxds = pixelLabelDatastore(outDirLabels, classNames, labelIDs);
end