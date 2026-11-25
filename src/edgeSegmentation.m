function segmentedImg = edgeSegmentation(img, edgeMap, closingRadius)
	% Keep the largest four-connected interior in a grayscale or RGB image.
	% Use a logical edge map of the same height and width. 
	% The closing radius is a nonnegative integer in pixels. 
	% The output keeps the size and class.

	% Close short gaps so contours can enclose regions.
	closedEdges = edgeMap;
	if closingRadius > 0
		disk = strel('disk', closingRadius, 0);
		closedEdges = imclose(edgeMap, disk);
	end

	% Keep only the pixels added by filling the closed contours.
	filledEdges = imfill(closedEdges, 4, 'holes');
	interiors = filledEdges & ~closedEdges;

	% Select the largest interior by counting pixels in each connected region.
	regions = bwconncomp(interiors, 4);
	selectedMask = false(size(edgeMap));
	if regions.NumObjects > 0
		regionSizes = cellfun(@numel, regions.PixelIdxList);
		[~, largestRegion] = max(regionSizes);
		selectedPixels = regions.PixelIdxList{largestRegion};
		selectedMask(selectedPixels) = true;
	end

	% Repeat the background mask across all channels before applying it.
	background = repmat(~selectedMask, 1, 1, size(img, 3));
	segmentedImg = img;
	segmentedImg(background) = 0;
end
