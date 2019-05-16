function md = lastfriday(y,m)
	% returns month day (md) corresponding to the last Friday of month m, year y
	% e.g.: lastfriday(2017,4)
	
	if nargin ~= 2; error('expected two input arguments'); end
	if ~isnumeric(y) | ~isnumeric(m), error('expected numeric inputs'); end
	if ~all(ismember(m,1:12)), error('expected month number (from 1 to 12)'); end
	
	n = numel(m)
	if n ~= numel(y)
		if n > 1 && numel(y) > 1, error('inputs must have same number of elements'); end
		if n == 1, m = m*ones(numel(y),1); end
		if numel(y) == 1, y = y*ones(n,1); end
	end
	dn = datenum(y,m+1,-ones(n,1)) % last month day
	[y m md] = datevec(dn)
	wd = weekday(dn)
	md = md + (6 <= wd).*(6 - wd) + (6 > wd).*(-1 - wd)
	
end