function x = chi2inv(y, df)
	% chi2inv: returns the inverse Chi-square cumulative distribution function. 
	%
	% Input arguments:
	% 	y: is the value result of a Chi-square cdf function. It can be a scalar, 
	%	   a vector or a matrix.
	%	df: degrees of freedom. It can be a scalar, a vector or a matrix.
	%
	% Outputs:
	%	x: the value that makes y = chi2cdf(x, df).
	%
	% Example:
	% >> df = 1
	% >> x = 10
	% >> chi2cdf(x, df)#
	%  0.998434597741997
	% >> chi2inv(0.998434597741997, df)#
	%  10
	%	

	% Checks the sizez of inputs
	[err, y, df] = sizestchck(y, df)
	if err, error(': In function chi2inv(y, df) y and df must match in size or be scalars.'); end
	
	% Calculates chi2inv using gaminv:
	% Ref: https://en.wikipedia.org/wiki/Chi-squared_distribution. According to this,
	% the Chi Squared CDF is equal to (1/gamma(x/2))*gamcdf(x/2, n/2) where
	% "gamma" in the gamma function and "gamcdf" is the lower gamma cumulative distribution function.
	% In mathlayer, gamcdf(x, a, b) function comes already scaled down by the factor 1/gamma(x) so
	% we don't need to divide by gamma(x) here, all we need to do is call gamcdf putting df/2 as the
	% second parameter and ensure we use x/2 rather than x. This is achieved putting 2 as the 
	% third input argument in gamcdf.
	% Exctly the same happens with chi2inv. To calculate gaminv all we have to do is to 
	% call gaminv(y/2, n/2) and in mathlayer doing gaminv(y, df/2, 2) as the third input
	% argument divides the value of the first input argument.
	x = gaminv(y, df/2, 2)
end

