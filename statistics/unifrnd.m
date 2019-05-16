function r = unifrnd(a,b,varargin)

	if nargin < 2, error('expected at least 2 input arguments'); end
	
	try
		tmp = a + b
		if ~isempty(varargin), tmp = tmp + zeros(varargin{1:end}); end
		n = size(tmp)
	catch
		error('input arguments size mismatch')
	end
	
	r = (a + b)/2 + (b - a)/2 .* (2*rand(n)-1)

	if ~isscalar(a) || ~isscalar(b)
		r(a > b) = NaN
	elseif a > b
		r(:) = NaN
	end

end