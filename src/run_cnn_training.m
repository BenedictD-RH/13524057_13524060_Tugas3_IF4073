function run_cnn_training(trainingDataDir, outputNetName)
    [imds, pxds] = convert_to_labels(trainingDataDir);
    rng(0)
    N = numel(imds.Files);
    idx = randperm(N);
    nTrain = round(0.6*N);  nVal = round(0.2*N);
    trainIdx = idx(1:nTrain);
    valIdx   = idx(nTrain+1 : nTrain+nVal);
    testIdx  = idx(nTrain+nVal+1 : end);
    
    save("output/split.mat", "trainIdx", "valIdx", "testIdx")
    
    testFiles = subset(imds, testIdx);
    save("output/testFiles.mat", "testFiles")
    
    train_model(imds, pxds, "split.mat", outputNetName);
end