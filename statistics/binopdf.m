function y = binopdf(x, n, p)
	% binopdf: computes the binomial probability density function (pdf)
	%					 of the values in x considering the corresponding number
	%					 of trials n and with a probability of success p.
	%
	% Input arguments:
	%		x: integer numbes of successes. It can be a matrix/vector.
	%		n: integer number of independent trials. It can be a matrix/vector.
	%		p: probability of success. It must be a number between 0 and 1.
	%
	%	Outputs:
	%		y: the corresponding binomial pdf.
	%
	% Example:
	%  >> binopdf(2, 10, 0.05)#
	%   0.0746348
	%  >> binopdf(5, 10, 0.05)#
	%   6.09352e-05
	%
	
	%
	% Copyright (C) 2019 Tenokonda Ltd.
	%
	
	% Error message header.
	msg = ': In function binopdf(x, n, p) '
	
	% Checks the number of inputs.
	if nargin < 3, error(strcat(msg, 'you must enter x, n and p.')); end

	% Checks the case of input arguments being multidimensional.
	[~, ~, hx] = size(x)
	[~, ~, hn] = size(n)
	[~, ~, hp] = size(p)
	if (hx ~= 1) | (hn ~= 1) | (hp ~= 1)
		error(strcat(msg, 'multidimensional arrays are not handled.'))
	end

	% Checks x is real.
	if ~isreal(x), error(strcat(msg, 'inputs must not be complex.')); end

	% Checks the sizes of x, n and p.
	[err, x, n, p] = sizestchck(x, n, p)
	if err, error(strcat(msg, 'x, n and p must match in size or be scalars.')); end
	
	% Initialize solution.
	y = zeros(size(x))

	% Define in which cases the calculations are to be performed.
	ok = (x >= 0) & (~isinf(x)) & (n >= x) & (x == floor(x) | isnan(x))

	% Calculates the binomial pdf.
	q = 1-p
	y(ok) = bincoeff(n(ok), x(ok), false) .* p(ok).^x(ok) .* q(ok).^(n(ok)-x(ok))

	
	% Special inputs with outputs to be corrected.
	ksp = (n<0) | n ~= floor(n) 
	y(ksp) = NaN

	% Ensures correct output if p is not a number
	% between 0 and 1.
	if (p > 1) | (p < 0), y(:) = NaN; end

	% Clean outputs like -nan(ind)-nan(ind)i and makes them NaN.
	y(isnan(y)) = NaN
	if all(imag(y(:)) == 0), y = real(y); end

end


