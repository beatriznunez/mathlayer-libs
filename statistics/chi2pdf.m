function y = chi2pdf(x, df)
	% chi2pdf: calculates the Chi-square probability density function (pdf)
	% 		     for each value in x considering the degrees of freedom give in df.
	%
	% Input arguments:
	% 	x: can be a scalar, a vector or a matrix.
	%	  df: can be a scalar, a vector or a matrix.
	%
	% Outputs:
	%		y: the result of calculating the Chi-square probability density function.
	%
	% Example:
	% >> chi2pdf(1:3,1:3)#
	%     0.241971      0.18394      0.15418
	%

	%
	% Copyright (C) 2019 Tenokonda Ltd.
	%
	
	% Error message header.
	msg = ': In function chi2pdf(x, df) '

	% Check the number of inputs.
	if nargin < 2, error(strcat(msg, 'you need to enter x and df.')); end

	% Checks the correct size of input arguments
	[err x df]= sizestchck(x, df)
	if err, error(strcat(msg, 'x, and df must match in size or be scalars.')); end	

	% Calculates chi2pdf using gampdf:
	% Ref: https://en.wikipedia.org/wiki/Chi-squared_distribution. 
	% According to this, the Chi Squared PDF is chi2pdf(x, df) = x^(df/2-1)*e^(-x/2)/gamma(df/2)/2^(df/2)
	% where "gamma" is the gamma function. So, chi2pdf(x, df) is very similar to gampdf(x, df, C)
	% as we have that gampdf(x, df, C) = x^(df-1)*e^(-x/C)/gamma(df)/C^df.
	% Thus, to calculate chi2pdf we can call gampdf using the transformations:
	% df -> df/2
	% C -> 2	
	y = gampdf(x, df/2, 2)	

end