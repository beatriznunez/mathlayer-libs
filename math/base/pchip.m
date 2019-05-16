function v = pchip(x,y,xq)
	
	% check arguments
	if nargin < 3
		error('not enough input arguments')
	end

	[x,y] = chckxy(x,y,xq,'pchip')
	if any(~isreal(xq))
		error('xq must be real numbers') 
	end
	
	multi = false
	[ry cy] = size(y)
	[rxq cxq] = size(xq)
	if ry > 1 & rxq > 1
		multi = true
		xq = xq(:)'
	end
	
	%  first derivatives
	h = diff(x) 			% length of the k-th subinterval
	delta = diff(y,1,2)./h 	% divided difference
	n = length(x)

	% calculate slopes
	% if numel(x)==2, use linear interpolation
	if n==2  
		d = repmat(delta,1,cy)
	else
  
		%  slopes at interior points
		n = length(h)+1
		d = zeros(ry, size(h,2))

		for i = 1: ry
			k = find(sign(delta(i,1:n-2)).*sign(delta(i,2:n-1)) > 0) + 1 
			if k >1
				w1 = 2*h(k)+h(k-1)
				w2 = h(k)+2*h(k-1)
				d(i,k) = (w1+w2)./(w1./delta(i,k-1) + w2./delta(i,k))
			end
		end
		
		%  slopes at external points
		d(:,1) = extpoints(h(1),h(2),delta(:,1),delta(:,2))
		d(:,n) = extpoints(h(n-1),h(n-2),delta(:,n-1),delta(:,n-2))
	end
	
	%  piecewise coefficients
	c = (3*delta - 2*d(:,1:n-1) - d(:,2:n))./h
	b = (d(:,1:n-1) - 2*delta + d(:,2:n))./h.^2

	k = ones(size(xq))
	for j = 2:n-1
		k(x(j) <= xq) = j
	end
	
	%  local variable
	s = xq - x(k)
	if size(k,1) == 1
		v = y(:,k) + s.*(d(:,k) + s.*(c(:,k) + s.*b(:,k)))
	else
		v = y(k) + s.*(d(k) + s.*(c(k) + s.*b(k)))
	end
	
	if multi
		vv = zeros(ry,rxq, cxq)
		j = 1
		for i = 1:rxq: size(v,2)
			vv(:,:,j) = v(:,i:i + cxq-1)
			j = j + 1
		end
		v = vv
	end
end



function d = extpoints(h1,h2,del1,del2)
	d = ((2*h1+h2)*del1 - h1*del2)/(h1+h2)
	d(sign(d) ~= sign(del1)) = 0
	aux = (sign(del1) ~= sign(del2)) & (abs(d) > abs(3*del1))
	d(aux) = 3*del1(aux)
end


