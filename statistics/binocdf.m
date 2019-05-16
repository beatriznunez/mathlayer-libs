function y = binocdf(x, n, p, tail)
	% binocdf: returns the binomial comulative distribution function (cdf)
	%		   with parameters n and p at the values of x.
	% 
	% Input arguments:
	%	x: integer number of successes. It can be a matrix/vector.
	%	n: integer number of trial. It can be a matrix/vector.
	%	p: probability of success. It must be a number between 0 and 1.
	%
	% Outputs:
	%	y: binomial cdf. 
	%
	% Example:
	%	>> binocdf(9,250,0.01)#
	%	 0.99975
	%

	%
	% Copyright (C) 2019 Tenokonda Ltd.
	%
	
	% Error message header.
	msg = ': In function binocdf(x, n, p, tail) '

	% Checks the input for tail.
	if nargin == 4 & ~strcmp(tail, 'upper'), error(strcat(msg, 'unrecognized value for tail.')); end
	
	% Checks the number of inputs.
	if nargin < 4, tail = 'lower'; end
	if nargin < 3, error(strcat(msg, 'you must enter at least three input arguments.')); end
	
	% Checks x is real.
	if ~isreal(x)
		if (n > x), error(strcat(msg, 'x must not be complex.')); end
	end

	% Checks the case of input arguments being multidimensional.
	[~, ~, hx] = size(x)
	[~, ~, hn] = size(n)
	[~, ~, hp] = size(p)
	if (hx ~= 1) | (hn ~= 1) | (hp ~= 1), error(strcat(msg, 'multidimensional arrays are not handled.')); end

	% Checks the sizes of x, n and p.
	[err, x, n, p] = sizestchck(x, n, p)
	if err, error(strcat(msg, 'x, n, and p must be of common size or scalars.')); end	
	
	% Initialize solution.
	y = zeros(size(x))

	% Define in which cases the calculations are to be performed.
	ok = (x >= 0) & (n > x) & (n == floor(n)) & (p >= 0) & (p <= 1) & (imag(p) == 0)

	%
	% Calculates the binomial cdf using the incomplete beta function following
	% the result binocdf(x,n,p) == betainc(1-p,n-x,x+1).
	%

	% Re-define the input arguments for an easy implementation in function betainc.
	q = 1-p
	x = floor(x)
	nx = n - x
	xpp = x + 1

	% Performs the calculation of binocdf using function betainc.
	if any(any(ok)), y(ok) = betainc(real(q(ok)), nx(ok), xpp(ok)); end

	%
	% Calculations of binocdf in case p contains complex numbers.
	%
	% Find indices of p being complex.
	pcx = (imag(p) ~= 0)
	if any(pcx(:)) & all(real(n))

		% Get the x corresponding to p complex.
		xcx = zeros(size(x))
		xcx(pcx) = x(pcx)

		% Get the thresholds in x above which there will not be 
		% any sum of binomial Pdf.
		xthr = xcx(:)

		% Bigest value of all the x corresponding to p complex.
		xmax = max(xthr)

		% Reshape x, n and p to be entered in the binomial Pdf function
		% and get the array of values that will be added to get the
		% the binomial Cdf
		if isnan(x) | isinf(x)
			xx = x
		else
			xx = repmat([0:xmax], length(xthr), 1)
		end
		nn = repmat(n(:), 1, length(xx))
		pp = repmat(p(:), 1, length(xx))

		% Reshape xthr.
		xthr = repmat(xthr, 1, length(xx))

		% Calculates the binomial Cdf adding up all the binomial Pdf.
		ycx = binopdf(xx, nn, pp)
		ycx(xx > xthr) = 0
		ycx = sum(ycx, 2)
		ycx(~pcx(:)) = 0

		% Reshape ycx
		[nr, nc] = size(y)
		ycx = reshape(ycx, nr, nc)

		% Add these calculations to the final solution.
		y = y + ycx
	end

	% Correct the ouput for special cases.
	sp = (x >= n) & (n >= 0) & (n == floor(n) & (p >= 0) & (p <= 1))
	y(sp) = 1
	sp = isnan(x) | (n < 0) | (n ~= floor(n)) | (p < 0) | (p > 1)
	y(sp) = NaN

	% Calculates the upper tail if required.
	if strcmp(tail, 'upper'), y = 1 - y; end

	% Corrects roundoff errors
	y(y > 1) = 1

end


