function x = norminv(p,m,sigma)

	if isempty(m), m = zeros(size(p)); end
	if isempty(sigma), sigma = ones(size(p)); end
	sigma(sigma <= 0) = NaN
	p(p <= 0 | 1 <= p) = NaN
	x0 = -sqrt(2).*erfcinv(2*p)
	x = sigma.*x0 + m
	
end
