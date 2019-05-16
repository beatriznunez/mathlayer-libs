function r = roots(v)

	n = length(v)
	v = reshape(v,1,n)
	f = find (v)
	m = max (size (f))

	if m > 0 && n > 1
		v = v(f(1):f(m))
		l = max(size(v))
		if (l > 1)
			A = diag(ones(1, l-2), -1)
			A(1,:) = -v(2:l)/v(1)
			r = eig(A)
			if (f(m) < n)
				tmp = zeros(n - f(m), 1)
				r = [r; tmp]
			end
		else
		  r = zeros (n - f(m), 1)
		end
	else
		r = []
	end

end