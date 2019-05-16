function n = months(d1,d2)
	% returns number of months between 2 dates
	% e.g.: months(736812, 736813)

	if nargin ~= 2; error('expected two input arguments'); end
	if ~isnumeric(d1) | ~isnumeric(d2), error('expected numeric inputs'); end
	
	neg = d2<d1
	aux = d2
	aux(neg) = d2(neg)
	d2(neg) = d1(neg)
	d1(neg) = aux(neg)
	
	[y1,m1,d1] = datevec(d1)
	[y2,m2,d2] = datevec(d2)
	
	n = (y2-y1)*12 + (m2-m1-1) + double(d1 <= d2 | d2 == eomday(y2,m2))

	n(neg) = -n(neg) 
end
