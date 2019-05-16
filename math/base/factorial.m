function y = factorial(x)
	% factorial: calculates the factorial of x.
	%
	% Input arguments:
	%		x: can be a scalar, a vector or a matrix. It must contain 
	%			 possitive integer numbers only.
	%
	% Outputs:
	%		y: contains the factorial of x. It is of the same shape of x.
	%
	% Example:
	% >> x = [0 1 2; 3 4 5]
	% >> factorial(x)#
	% 			  1      1      2
	%             6     24    120
	%

	% Error if x is not an integer.
	if any(any(x<0)) | any(any(isnan(x))) | any(any(floor(x) ~= x)) 
		error(': Input should contain non-negative integers only.')
	end

	% Calculates the factorial of x using the gamma function.
	y = round(gamma(x + 1))

end