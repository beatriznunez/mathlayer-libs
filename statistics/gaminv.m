function x = gaminv(y, a, b)
	% gaminv(y, a, b) computes the inverse of the gamma cdf  function.
	%
	% Input arguments:
	% 	y: is the value result of a gamma cdf function.
	% 	a: is the 'shape' parameter. It can be a scalar, a vector or a matrix.
	%	b: is the 'scale' parameter. It can be a scalar, a vector or a matrix.
	%
	% Outputs:
	%	x: the value that makes y = gamcdf(x, a, b).
	%
	% Example:
	% >> a = 1; b = 2
	% >> x = 0.5
	% >> gaminv(x, a, b)#
	%  1.386294361119890
	% >> gamcdf(1.386294361119890, a, b)#
	%  0.5
	%

	% Checks the correct size of input arguments
	err1 = sizestchck(y, a, [], 'check')
	[err2, y, a, b] = sizestchck(y, a, b, 'expand')
	if (err1 | err2), error(': In function gaminv(y, a, b) y, a and b must match in size or be scalars.'); end

	% Initializes the solution.
	x = zeros(size(y))

	% Determines when calculations will be performed.
	ok = (a > 0) & (b > 0) & (y >= 0) & (y < 1) & ~isinf(a)
	ok(y == false) = false

	% We need to obtain gaminv(y, a, b) that is the inverse function
	% of gamcdf(x, a, b). That is, we want to have the relation:
	%
	% 	y = gamcdf(x, a, b) <--> x = gaminv(y, a, b)
	%
	% But currently, in mathlayer we have available only
	% the function gammaincinv(y, a) therefore the only relation we have is:
	%
	% 	y = gammainc(x/b, a) <--> x/b = gammaincinv(y, a)
	%
	% Fortunately, we have can use the result:
	%
	% 	gamcdf(x, a, b) = gammainc(x/b, a) 
	%
	% which means that if we want to find x, we can use gammaincinv
	% to obtain x/b. From here, getting x is straight forward.
	if any(ok(:)), x(ok) = b(ok) .* gammaincinv(y(ok), a(ok)); end		

	% Corrects ouput for cases where ouput should be Inf
	iid = ((y == 1) & (a ~= 0) & ~isnan(a) & (b~=0)) | (isinf(b) & (a > 0) & (~isnan(a)) & (~isinf(b)))
	x(iid) = Inf

	% Corrects ouput for cases where ouput should be NaN
	nid = ( (y < 0) & (a~=0)) | (y > 1) | isinf(y) | isnan(y) | (a < 0) | isinf(a) | isnan(a) | ((b <= 0) & (y~=0) & (y~=1) & (a~=0))
	x(nid) = NaN
	nid = ~isreal(y)
	x(nid) = NaN

	% Corrects ouput for cases where ouput should be zero.
	zid = (a==0) & (isinf(y) | isnan(y) | (y>1)) 
	x(zid) = 0

end




