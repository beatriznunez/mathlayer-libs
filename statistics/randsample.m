function y = randsample(n, k, nc)

	if nargin < 2, error('expected at least 2 input arguments'); end
	if k > n, error('first input must be bigger than the second one'); end
	
	if nargin == 2
		x = zeros(n,1)
		sumx = 0
		while sumx < k
			x(ceil(n * rand(1,k-sumx))) = 1
			sumx = sum(x)
		end
		y = find(x > 0)
		[~, p] = sort(rand(1, k))
		y = y(p)
	else
		y = nan(k,nc)
		for i = 1:nc
			y(:,i) = randsample(n,k)
		end
	end
	
end