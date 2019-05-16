function b = bincoeff(n, k, warningson)
	% bincoeff: returns the binomial coefficient (n, k) = n!/(k!*(n-k)!)
	%
	% Input arguments:
	%   n: can be a scalar, a vector or a matrix. 
	%	k: can be a scalar a vector or a matrix.
	% 
	%	Outputs:
	%   b: binomial coefficient or all combinations.
	%
	% Example:	
	% >> bincoeff(10, 3)#
	%  120
	% >> bincoeff(5, 3)#
	%  10
	% >> bincoeff([10 5; 5 10], 3)#
    %        120           10
    %         10          120
	%
	
	%
	% Copyright (C) 2019 Tenokonda Ltd.
	%

	% Default activation for warning messages.
	if nargin < 3, warningson = true; end
	
	% Define constant flintmax.
	flintmax = 9.007199254740992e15

	% Checks the value of k.	
	if ( k < 0 | ~isinteger(k) | isnan(k) | isinf(k) ) & warningson		
		disp('Warning: In function bincoeff(n, k): You entered values that are not non-negative integers.')
	end
	
	% Restrictions in sizes of n and k. Sizes of n and k must match or being scalars.
	if (~isscalar(n) & ~isscalar(k)) & ~all(size(n) == size(k))
		error(": In function bincoeff(n, k, warningson) n and k must be of common size or scalars.")
	end

	% Checks the value of n.	
	if ( any(any(n<0)) | any(any(~isinteger(n))) ) & warningson		
		disp('Warning: In function bincoeff(n, k): You entered values that are not non-negative integers.')
	end

	% Checks the size of n.
	if ( any(any(n > flintmax)) ) & warningson		
		disp('Warning: In function bincoeff(n, k): You entered numbers bigger than the maximum value allowed 9.0072e+015.')
	end

	% Checks that n > k.
	%if ( any(any(n<k)) ) & warningson		
	%	disp('Warning: In function bincoeff(n, k): You entered n smaller than k.')
	%end	
	
	% Get binomial coefficient using gammaln.
	b = exp(gammaln(n+1) - gammaln(k+1) - gammaln(n-k+1))
	
	% Calculates the binomial coeff for n negative and k scalar.
	int = (n == floor(n)) & (k == floor(k))
	ii = int & (n < 0)
	if isscalar(k), k = k*ones(size(n)); end
	if isscalar(n), n = n*ones(size(k)); end
	b(ii) = (-1).^k(ii).*exp(gammaln(abs(n(ii))+k(ii))-gammaln(k(ii)+1)-gammaln(abs(n(ii))))	
	
	% Change the output for extreme or special cases.
	nok = isinf(b) | floor(k) < k | k < 0
	b(nok) = NaN	
	nok = isinf(k) | (n < k & n > 0)
	b(nok) = 0
	
	% Remove round-off errors.	
	b(int) = round(b(int))
	
	% Warning for huge results.
	if b > flintmax & warningson
		disp('Warning: In function bincoeff(n, k): Result may not be exact. The binomial coefficient is bigger than 9.0072e+015 and it is only accurate up to 15 digits.')
	end

end

 