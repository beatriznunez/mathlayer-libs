function y = gamcdf(x, a, b, tail)
	% gamcdf: returns the gamma cumulative distribution function.
	%
	% Input arguments:
	%   x: values to calculate gamcdf = (1/gamma(a))*Int_{0}^{x} t^{a-1}e^{-t}dt.
	%      It can be a scalar, a vector or a matrix.
	%	a: shape parameter. It can be a scalar, a vector or a matrix.
	%	b: scale parameter. It can be a scalar, a vector or a matrix.
	%	tail: specify whether to use the lower or upper incomplete gamma function.
	%
	% Outputs:
	% 	y: contains the gamma cumulative distribution function given x, a, b and tail.
	%
	% Example:
	% 	>> gamcdf([1.5 2], 2)#
	%        0.442175     0.593994
	%
	
	%
	% Copyright (C) 2019 Tenokonda Ltd.
	%
	
	% Error message header.
	msg = ': In function gamcdf(x, a, b, tail) '

	% Check the number of input arguments.
	if nargin < 4, tail = 'lower'; end
	if nargin < 3, b = ones(size(x)); end
	if nargin < 2, error(strcat(msg, 'you must enter at least x and a.')); end
	
	% Check whether flag is correct.
	if ~strcmp(tail, 'upper') & ~strcmp(tail, 'lower'), error(": In function gamcdf(x, a, b, tail): Wrong tail entered. You should use 'lower' or 'upper' only."); end

	% Checks x and a contain complex numbers.
	if any(~isreal(x(:))) | any(~isreal(a(:)))
		error(strcat(msg, 'x and a must not be complex.'))
	end 

	% Expand x and b to have common size.
	[err, x, b] = sizestchck(x, b, [], 'expand')
	if err, error(strcat(msg, 'x, and b must have compatible sizes.')); end
	
	% xx will be the first input argument in function gammainc.
	if isscalar(b)
		xx = x/b
	else
		xx = x ./ b  
	end

	% Check correct size of xx and a.
	[err, xx, a] = sizestchck(xx, a)
	if err, error(strcat(msg, 'x./b, and a must match in size or be scalars.')); end

	% Initialize solution.
	y = zeros(size(xx))

	% Define when calculations will be performed.
	ok = (xx > 0) & (a > 0) & ~isinf(a) & (b > 0) & ~isinf(b) & isreal(b)

	% Calculates gamcdf using the incomplete gamma function
	% As explained here:
	% https://en.wikipedia.org/wiki/Incomplete_gamma_function#Regularized_Gamma_functions_and_Poisson_random_variables
	% P(a,x) = gamma(a,x)/Gamma(a) where:
	% P(a,x) is the gamma cumulative density function (the 'gamcdf' we are defininf here),
	% gamma(a,x) is the 'lower' incomplete gamma function ('gammainc' in mathlayer),
	% Gamma(a) is the gamma function ('gamma' in mathlayer),
	% i.e. we could do gamcdf = gammainc / gamma but in mathlayer gammainc comes scaled using
	% gamma as the scaling factor, i.e. gamma comes already divided by gamma, so we don't
	% need to divide gammainc by gamma to get the gamcdf
	if any(any(ok)), y(ok) = gammainc(xx(ok), a(ok), tail); end

	% Correct the output for special case input arguments.
	sp = isnan(xx) | (a < 0) | isnan(a) | (b < 0) | isnan(b) | ~isreal(b)
	y(sp) = NaN
	sp = isinf(xx) | (a == 0)
	y(sp) = 1
	sp = isinf(xx) & (b == 0)
	y(sp) = NaN
	sp = (isinf(xx) & isinf(a)) | (isinf(xx) & isnan(a))
	y(sp) = NaN

end

