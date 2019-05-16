function y = gampdf(x, a, b)
	% gampdf: returns the gamma probability density function.
	%
	% Input arguments:
	%   x: values to calculate gampdf = x^(a-1)*exp(-x/b)/gamma(a)/b^a.
	%      It can be a scalar, a vector or a matrix.
	%	a: shape parameter. It can be a scalar, a vector or a matrix.
	%	b: scale parameter. It can be a scalar, a vector or a matrix.
	%	
	% Outputs:
	% 	y: contains the gamma probability density function given x, a, b.
	%
	% Example:
	% 	>> gampdf([1.5 2], 2)#
	%        0.33470   0.27067
	%

	%
	% Copyright (C) 2019 Tenokonda Ltd.
	%
	
	% Error message header.
	msg = ': In function gampdf(x, a, b) '

	% Check the number of input arguments.
	if nargin < 3, b = ones(size(x)); end
	if nargin < 2, error(strcat(msg, 'you must enter x and a at least.')); end

	% Checks the correct size of input arguments
	[err, x, a, b] = sizestchck(x, a, b)
	if err, error(strcat(msg, 'x, a and b must match in size or be scalars.')); end

	% Initializes solution.
	y = zeros(size(x))

	% Avoids calculations for NaN input arguments.
	aisreal = (imag(a) == 0)
	aiscomplex = ~aisreal
	nok = isnan(x) | isnan(a) | (a < 0) | aiscomplex | isnan(b) | ~isreal(b) | (b <= 0)
	y(nok) = NaN

	% Start to define in which cases calculations will be performed.
	k = (x >=0 & ~isinf(x)) & (a > 0 & ~isinf(a) & aisreal) & (b > 0)  

	% Performs calculations for the case a <= 1.
	ok = k & (a <= 1)
	if any(ok(:)), y(ok) = x(ok).^(a(ok)-1).*exp(-x(ok)./b(ok))./gamma(real(a(ok)))./(b(ok).^a(ok)); end

	% Performs calculations for the case a > 1.
	ok = k & (a > 1)
	if any(ok(:)), y(ok) = exp(-gammaln(real(a(ok))) - a(ok).*log(b(ok)) + (a(ok)-1).*log(x(ok)) - x(ok)./b(ok)); end
 
	% Corrects output for a complex.
	nok = aiscomplex & (real(a) == 0)
	y(nok) = 0
	
	% Corrects output for b complex.
	biscomplex = (imag(b) ~= 0)
	nok = aiscomplex & biscomplex
	y(nok) = NaN

	% Warning message for cases where a is complex.
	if any(aiscomplex(:))
		disp(strcat('Warning: ', msg, 'a should not contain complex values.'))
	end

end