function [m i] = bisection(f,a,b,tol,maxit)
	
	n = size(a,1)
	if isempty(tol), tol = 1e-6; end
	if isempty(maxit), maxit = 100; end
	i = nan
	nanpos = f(a) .* f(b) > 0
	
	for i = 1:maxit
		m = (a+b)/2
		fm = f(m)
		if all(abs(fm) < tol), return; end
		idxpos = f(a) .* fm > 0
		a(idxpos) = m(idxpos)
		b(~idxpos) = m(~idxpos)
	end
	
	m(nanpos) = nan
	%disp('tolerance not reached')
	
end