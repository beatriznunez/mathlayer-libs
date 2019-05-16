function y = chi2cdf(x, df, tail)
	% chi2cdf: calculates the Chi-square cumulative distribution function (cdf)
	% 		   for each value in x considering the degrees of freedom give in df.
	%
	% Input arguments:
	% 	x: can be a scalar, a vector or a matrix.
	%	df: can be a scalar, a vector or a matrix.
	%	tail: It can be either be 'lower' or 'upper' to specify calculations
	%		  of the extreme lower or upper tail.
	%
	% Outputs:
	%	y: the result of calculating the Chi-square cumulative distribution function.
	%
	% Examples:
	% >> chi2cdf(1:3,1:3)#
	%     0.682689     0.632121     0.608375
	% >> chi2cdf(1:3,1:3, 'upper')#
	%     0.317311     0.367879     0.391625
	%

	%
	% Copyright (C) 2019 Tenokonda Ltd.
	%
	
	% Error message header.
	msg = ': In function chi2cdf(x, df, tail) '
	
	% Checks the input for tail.
	if nargin == 3 & (~strcmp(tail, 'upper') & ~strcmp(tail, 'lower'))
		error(strcat(msg, "unrecognized value for tail. Use 'upper' or 'lower'."))
	end

	% Check the number of inputs.
	if nargin < 3, tail = 'lower'; end
	if nargin < 2, error(strcat(msg, 'you need to specify at least x and df.')); end

	% Check the correct sizes of ax and df.
	[err, x, df] = sizestchck(x, df)
	if err, error(strcat(msg, 'x and df must match in size or be scalars.')); end
	
	% Calculates chi2cdf using gamcdf:
	% Ref: https://en.wikipedia.org/wiki/Chi-squared_distribution. According to this,
	% the Chi Squared CDF is equal to (1/gamma(x/2))*gamcdf(x/2, n/2) where
	% "gamma" in the gamma function and "gamcdf" is the lower gamma cumulative distribution function.
	% In mathlayer, gamcdf(x, a, b) function comes already scaled down by the factor 1/gamma(x) so
	% we don't need to divide by gamma(x) here, all we need to do is call gamcdf putting df/2 as the
	% second parameter and ensure we use x/2 rather than x. This is achieved putting 2 as the 
	% third input argument in gamcdf.
	y = gamcdf(x, df/2, 2, tail)	

end

