function d = eomday(y,m)
	% returns total number of days for month m, year y
	% e.g.: eomday(2017,2)

	if nargin ~= 2; error('expected two input arguments'); end
	if ~isnumeric(y) | ~isnumeric(m), error('expected numeric inputs'); end
	
	dpm = [31 28 31 30 31 30 31 31 30 31 30 31]'
	d = y - m
	d(:) = dpm(m)
	d((m == 2) & ((rem(y,4) == 0 & rem(y,100) ~= 0) | rem(y,400) == 0)) = 29

end