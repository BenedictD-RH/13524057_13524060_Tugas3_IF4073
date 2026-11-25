[imds, pxds] = convert_to_labels('training_data');
% rng(0)
% N = numel(imds.Files);
% idx = randperm(N);
% nTrain = round(0.6*N);  nVal = round(0.2*N);
% trainIdx = idx(1:nTrain);
% valIdx   = idx(nTrain+1 : nTrain+nVal);
% testIdx  = idx(nTrain+nVal+1 : end);

% save("output/split.mat", "trainIdx", "valIdx", "testIdx")
% net = train_model(imds, pxds, "split.mat", "camvidNet.mat");


% S = load("output\camvidNet.mat", "net", "classNames");
% net = S.net;  classNames = S.classNames;
% 
% img = imread("image.png");
% img = imresize(img, [360 480]);                 % same size as training
% if size(img,3) == 1, img = repmat(img,1,1,3); end   % force 3 channels
% 
% C = semanticseg(img, net, Classes=classNames);  % categorical H x W label map
% 
% cmap = [128 128 128; 128 0 0; 192 192 128; 128 64 128; 60 40 222; ...
%     128 128 0; 192 128 128; 64 64 128; 64 0 128; 64 64 0; 0 128 192] / 255;
% B = labeloverlay(img, C, Colormap=cmap, Transparency=0.4);
% 
% figure
% subplot(1,2,1), imshow(img), title("Input")
% subplot(1,2,2), imshow(B),   title("Segmentation")


% split = load("output\split.mat");
% trainIdx = split.trainIdx;
% valIdx = split.valIdx;
% testIdx = split.testIdx;
% 
% imdsTest   = subset(imds, testIdx);     pxdsTest   = subset(pxds, testIdx);
% 
% k = 5;                                           % any index into the test set
% img = readimage(imdsTest, k);
% gt  = readimage(pxdsTest, k);
% 
% C = semanticseg(img, net, Classes=pxds.ClassNames);
% 
% figure
% subplot(1,3,1), imshow(img),                                          title("Input")
% subplot(1,3,2), imshow(labeloverlay(img, gt, Colormap=cmap)),         title("Ground truth")
% subplot(1,3,3), imshow(labeloverlay(img, C,  Colormap=cmap)),         title("Prediction")