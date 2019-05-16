function [yy s] = spline(x,y,xq)

	% check inputs and get sizes  
	if nargin < 3
		error('not enough input arguments')
	end
	
	[x y rowsy endslopes] = chckxy(x,y,xq)
	N = length(x)
  
	% cases
	if N == 2 & isempty(endslopes)    % linear interpolation 
   
		s = linearCoeff(x,y)
		yy = ppval(x,y,xq,s,rowsy,endslopes)
    
	elseif N == 2 & ~isempty(endslopes) % cubic hermite spline polynomial  

		yy = chip(x,y,xq,endslopes)
  
	elseif N == 3 & isempty(endslopes)  % parabolic interpolation
    
		s = parabCoeff(x,y)
		yy = ppval(x,y,xq,s,rowsy,endslopes)
  
	else
  
		% h holds the space between consecutive points
		h = diff(x)
  
		% delta holds the tangent between consecutive points
		delta = diff(y,1,2)./h
  
		% get the three vectors that define the tridiagonal matrix
		[a b c] = vecTriMat(h,endslopes,N)
  
		% get the right-hand side of the system A*m = B
		B = rhs(h,delta,c,a,N,endslopes)
  
		% solve the linear system with a tridiagonal matrix
		m = tridisol(a,b,c,B)
    
		if ~isempty(endslopes)
    
			m = [endslopes(:,1)'; m; endslopes(:,2)']
    
		end
  
		% find out the values of s, the polynomial coefficients
		s = polyCoeff(y,delta,h,m)
  
		% find the interpolated points     
		yy = ppval(x,y,xq,s,rowsy,endslopes)
    
	end
  
end



function [a b c] = vecTriMat(h,endslopes,N)

  if isempty(endslopes)
  
    % default not-a-knot case
    a = zeros(1,N)
    b = zeros(1,N)
    c = zeros(1,N)
    
    c(1) = h(1)+h(2)
    b(1) = h(2)
    a(2:N-1) = h(2:N-1)
    b(2:N-1) = 2*(h(2:N-1)+h(1:N-2))
    c(2:N-1) = h(1:N-2)
    a(N) = h(N-1)+h(N-2)
    b(N) = h(N-2)
    
  else
  
    % complete or "clamped" case
    a = zeros(1,N-2)
    b = zeros(1,N-2)
    c = zeros(1,N-2)
    
    a(2:N-2) = h(3:N-1)
    b(1:N-2) = 2*(h(2:N-1)+h(1:N-2))
    c(1:N-3) = h(1:N-3)
    
  end

end

function r = rhs(h,delta,c,a,N,endslopes)

    r = h(1:N-2) .* delta(:,2:N-1) + h(2:N-1) .* delta(:,1:N-2)
    r = 3 * r
  
  if isempty(endslopes) 
  
    % default not-a-knot case    
    r1 = ( (h(1) + 2*c(1) ) * h(2)*delta(:,1) + h(1)^2 * delta(:,2) ) / c(1)
    rn = ( h(N-1)^2 * delta(:,N-2) + ( 2*a(N) + h(N-1) ) * h(N-2)*delta(:,N-1) ) / a(N) 
    
    r = [r1 r rn]'
    
  else
  
    % complete or "clamped" case
    r = r'
    r(1,:) = r(1,:) - endslopes(:,1)' .* h(2)
    r(N-2,:) = r(N-2,:) - endslopes(:,2)' .* h(N-2)
    
  end
  
end

% find the coefficients in case of a linear interpolation
function  s = linearCoeff(x,y)
  m = diff(y,1,2) ./ diff(x)
  c = y(:,1) - m * x(1)
  s = [m c]
end

function s = parabCoeff(x,y)
  y = y'
  A = [x(1)^2 x(1) 1;x(2)^2 x(2) 1;x(3)^2 x(3) 1;]
  s = round((A\y),12)'
end

function s = polyCoeff(y,delta,h,m)
	[rowsy,N] = size(y) 
	s2 = zeros((N-1)*rowsy,1)
	s3 = zeros((N-1)*rowsy,1)
	s = zeros((N-1)*rowsy,4)

	h = h(:)
	h = repmat(h,rowsy,1)
    
	m1 = m(1:N-1,:)
	m1 = m1(:)
	m2 = m(2:N,:)
	m2 = m2(:)
	
	delta = delta'
	delta = delta(:)
	
	y = y(:,1:N-1)
	y = y'
	y = y(:)
    
	s2 = (3*delta - 2*m1 - m2) ./ h
	s3 = (m1 - 2*delta + m2) ./ h.^2
	s = [s3 s2 m1 y]	
end

function yy = chip(x,y,xq,endslopes)
    [ry,~] = size(y)
    [rxq,cxq] = size(xq)
	
	multi = false
	if ry > 1 & rxq > 1
		multi = true
	end
    
    t = (xq - x(1)) ./ (x(2)-x(1))

    h00 = 2*t.^3 - 3*t.^2 + 1
    h10 = t.^3 - 2*t.^2 + t
    h01 = -2*t.^3 + 3*t.^2
    h11 = t.^3 - t.^2
    
        
    if ~multi
    
        h00 = repmat(h00,ry,1)
        h10 = repmat(h10,ry,1)
        h01 = repmat(h01,ry,1)
        h11 = repmat(h11,ry,1)
		y = repmat(y,rxq,1)
		endslopes = repmat(endslopes,rxq,1)
        
        yy = h00.*y(:,1) + h10.*(x(2)-x(1)).*endslopes(:,1) + h01.*y(:,2) + h11.*(x(2)-x(1)).*endslopes(:,2)  
        
    elseif multi
	
		yy = zeros(ry*rxq,cxq)	
			k = 1
			for i = 1:rxq
				for j = 1:ry	
					yy(k,:) = h00(i,:).*y(j,1) + h10(i,:).*(x(2)-x(1)).*endslopes(j,1)...
							+ h01(i,:).*y(j,2) + h11(i,:).*(x(2)-x(1)).*endslopes(j,2)
					k = k + 1
				end
			end
        
		yy = reshape(yy,[ry rxq cxq])
		
%		h00 = repmat(h00,ry,1)
%       h10 = repmat(h10,ry,1)
%       h01 = repmat(h01,ry,1)
%       h11 = repmat(h11,ry,1)
%		y = repmat(y,rxq,1)
%		
%		endslopes = repmat(endslopes,rxq,1)
%        
%       yy = h00.*y(:,1) + h10.*(x(2)-x(1)).*endslopes(:,1) + h01.*y(:,2) + h11.*(x(2)-x(1)).*endslopes(:,2) 
	
	end
end