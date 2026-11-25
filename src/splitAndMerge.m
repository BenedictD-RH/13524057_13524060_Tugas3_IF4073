function segmentedImg = splitAndMerge(img, threshold)
	% Partition a grayscale or RGB image into homogeneous regions.
	% Floating-point images use [0,1]. 
	% The threshold is the maximum allowed grayscale range in [0,1]. 
	% The output shows each region's per-channel mean and keeps the input size and class.

	% Measure homogeneity on a grayscale intensity scale from 0 to 1.
	gray = im2double(img);
	if size(gray, 3) == 3
		gray = rgb2gray(gray);
	end

	% Split the image into homogeneous rectangles, then merge adjacent regions.
	[labels, regionPixels, regionMin, regionMax] = splitIntoLeaves(gray, threshold);
	labels = mergeNeighbors(labels, regionPixels, regionMin, regionMax, threshold);

	% Renumber labels consecutively so they can index the counts and sums.
	[~, ~, labels] = unique(labels(:));
	pixelCounts = accumarray(labels, 1);
	segmentedImg = zeros(size(img), 'like', img);
	for channel = 1:size(img, 3)
		values = double(img(:, :, channel));
		channelSums = accumarray(labels, values(:));
		channelMeans = channelSums ./ pixelCounts;

		% Use each pixel's label to look up its region mean.
		pixelMeans = channelMeans(labels);
		renderedChannel = reshape(pixelMeans, size(gray));
		segmentedImg(:, :, channel) = cast(renderedChannel, 'like', img);
	end
end

function [labels, regionPixels, regionMin, regionMax] = splitIntoLeaves(gray, threshold)
	% Split the whole image and store each leaf's pixels and intensity range.
	labels = zeros(size(gray));
	pixelIndices = reshape(1:numel(gray), size(gray));
	regionPixels = cell(numel(gray), 1);
	regionMin = zeros(numel(gray), 1);
	regionMax = zeros(numel(gray), 1);
	leafCount = 0;

	splitBlock(1, size(gray, 1), 1, size(gray, 2));
	regionPixels = regionPixels(1:leafCount);
	regionMin = regionMin(1:leafCount);
	regionMax = regionMax(1:leafCount);

	function splitBlock(firstRow, lastRow, firstCol, lastCol)
		% Split a rectangle only if its grayscale range exceeds the threshold.
		rows = firstRow:lastRow;
		cols = firstCol:lastCol;
		block = gray(rows, cols);
		[blockMin, blockMax] = bounds(block(:));

		% Give each homogeneous block a label and save its pixel indices.
		if blockMax - blockMin <= threshold
			leafCount = leafCount + 1;
			labels(rows, cols) = leafCount;
			pixels = pixelIndices(rows, cols);
			regionPixels{leafCount} = pixels(:);
			regionMin(leafCount) = blockMin;
			regionMax(leafCount) = blockMax;
			return
		end

		% Bisect each available axis. The first half gets any extra pixel.
		rowCuts = [firstRow, lastRow + 1];
		colCuts = [firstCol, lastCol + 1];
		if firstRow < lastRow
			middleRow = floor((firstRow + lastRow) / 2);
			rowCuts = [firstRow, middleRow + 1, lastRow + 1];
		end
		if firstCol < lastCol
			middleCol = floor((firstCol + lastCol) / 2);
			colCuts = [firstCol, middleCol + 1, lastCol + 1];
		end

		% Each child ends one pixel before the next cut on each axis.
		for row = 1:(numel(rowCuts) - 1)
			lastChildRow = rowCuts(row + 1) - 1;
			for col = 1:(numel(colCuts) - 1)
				lastChildCol = colCuts(col + 1) - 1;
				splitBlock(rowCuts(row), lastChildRow, colCuts(col), lastChildCol);
			end
		end
	end
end

function labels = mergeNeighbors(labels, regionPixels, regionMin, regionMax, threshold)
	% Merge homogeneous unions until a full pass makes no merge.
	merged = true;
	while merged
		% Collect label pairs from horizontal and vertical pixel neighbors.
		left = labels(:, 1:end-1);
		right = labels(:, 2:end);
		top = labels(1:end-1, :);
		bottom = labels(2:end, :);
		pairs = [left(:), right(:); top(:), bottom(:)];

		% Discard same-label pairs and sort so either order gives the same pair.
		sameLabel = pairs(:, 1) == pairs(:, 2);
		pairs(sameLabel, :) = [];
		pairs = sort(pairs, 2);
		pairs = unique(pairs, 'rows');

		merged = false;
		for i = 1:size(pairs, 1)
			first = pairs(i, 1);
			second = pairs(i, 2);

			% Skip labels absorbed during this pass. The next pass checks
			% their neighbors using the new labels.
			if isempty(regionPixels{first}) || isempty(regionPixels{second})
				continue
			end

			% Apply the same range test to the union as to a split block.
			unionMin = min(regionMin(first), regionMin(second));
			unionMax = max(regionMax(first), regionMax(second));
			unionRange = unionMax - unionMin;
			if unionRange > threshold
				continue
			end

			% Give the union one label and update its pixel list and range.
			absorbedPixels = regionPixels{second};
			labels(absorbedPixels) = first;
			regionPixels{first} = [regionPixels{first}; absorbedPixels];
			regionPixels{second} = [];
			regionMin(first) = unionMin;
			regionMax(first) = unionMax;
			merged = true;
		end
	end
end
