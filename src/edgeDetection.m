function edgeMap = edgeDetection(img, method, threshold, sigma)
	% Return a logical edge map the same height and width as the image.
	% Input is grayscale or RGB, with floating-point values in [0,1].
	% Custom detectors take a nonnegative scalar threshold. LoG and Canny
	% need a positive sigma in pixels. Canny takes a high threshold or an
	% increasing [low high] pair in [0,1).

	% Convert to grayscale double so all operators use the same intensity scale.
	gray = im2double(img);
	if size(gray, 3) == 3
		gray = rgb2gray(gray);
	end

	% A constant image has zero edge strength, including at threshold zero.
	if all(gray(:) == gray(1))
		edgeMap = false(size(gray));
		return
	end

	% Select the edge detection method.
	method = lower(char(method));
	switch method
		case 'canny'
			edgeMap = edge(gray, 'Canny', threshold, sigma);
			return
		case {'laplace', 'log'}
			% LoG smooths with a Gaussian before taking the Laplacian.
			if strcmp(method, 'log')
				gray = imgaussfilt(gray, sigma, 'Padding', 'replicate');
			end

			laplaceMask = [0 1 0; 1 -4 1; 0 1 0];
			laplacian = imfilter(gray, laplaceMask, 'replicate');

			% Clear roundoff before checking signs. eps gives the spacing
			% between floating-point values at the peak intensity.
			roundoffLimit = 4 * eps(max(gray(:)));
			laplacian(abs(laplacian) <= roundoffLimit) = 0;
			edgeMap = zeroCrossings(laplacian, threshold);
			return
		case 'sobel'
			maskX = [-1 0 1; -2 0 2; -1 0 1];
			maskY = [1 2 1; 0 0 0; -1 -2 -1];
		case 'prewitt'
			maskX = [-1 0 1; -1 0 1; -1 0 1];
			maskY = [1 1 1; 0 0 0; -1 -1 -1];
		case 'roberts'
			% The 2-by-2 masks are anchored at their upper-left pixel.
			maskX = [1 0; 0 -1];
			maskY = [0 1; -1 0];
		otherwise
			error('edgeDetection:Method', 'Unsupported edge detector: %s.', method);
	end

	% Combine the two gradients and keep pixels above the magnitude threshold.
	gradientX = imfilter(gray, maskX, 'replicate');
	gradientY = imfilter(gray, maskY, 'replicate');
	magnitude = sqrt(gradientX.^2 + gradientY.^2);
	edgeMap = magnitude > threshold;
end

function edgeMap = zeroCrossings(laplacian, threshold)
	% Mark zero crossings whose signed-response difference exceeds the threshold.
	[height, width] = size(laplacian);
	edgeMap = false(height, width);

	% Check right, down, and both downward diagonals to visit each pair once.
	directions = [0 1; 1 0; 1 1; 1 -1];
	for direction = 1:size(directions, 1)
		rowStep = directions(direction, 1);
		colStep = directions(direction, 2);

		% Limit the index ranges so both pixels stay inside the image.
		rows = max(1, 1 - rowStep):min(height, height - rowStep);
		cols = max(1, 1 - colStep):min(width, width - colStep);
		nextRows = rows + rowStep;
		nextCols = cols + colStep;
		first = laplacian(rows, cols);
		second = laplacian(nextRows, nextCols);

		% At an adjacent sign change, mark the pixel closer to zero.
		oppositeSigns = (first < 0 & second > 0) | (first > 0 & second < 0);
		contrast = abs(first - second);
		crossing = oppositeSigns & contrast > threshold;
		firstIsCloser = abs(first) <= abs(second);
		edgeMap(rows, cols) = edgeMap(rows, cols) | (crossing & firstIsCloser);
		edgeMap(nextRows, nextCols) = edgeMap(nextRows, nextCols) | (crossing & ~firstIsCloser);

		% An exact zero between opposite signs can also mark an edge.
		rows = (1 + abs(rowStep)):(height - abs(rowStep));
		cols = (1 + abs(colStep)):(width - abs(colStep));
		before = laplacian(rows - rowStep, cols - colStep);
		after = laplacian(rows + rowStep, cols + colStep);
		oppositeSigns = (before < 0 & after > 0) | (before > 0 & after < 0);
		contrast = abs(before - after);
		atZero = laplacian(rows, cols) == 0;
		crossing = atZero & oppositeSigns & contrast > threshold;
		edgeMap(rows, cols) = edgeMap(rows, cols) | crossing;
	end
end
