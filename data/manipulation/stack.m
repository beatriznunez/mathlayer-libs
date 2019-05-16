function ts = stack(tus)
	
	% returns the stacked table corresponding to the table t
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% tus: unstacked table
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% ts: stacked table	
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
	% data = urlread('http://www.mathlayer.com/support/downloads/timeseries.csv')
	% U = stack(timeseries)
	% U(1:5)#
	
	[nr0 nc0] = size(tus)
	vn = tus.variablenames
	nc = nc0-1
	nr = nc*nr0
	ts = table(repmat(tus{:,1},nc,1),cell(nr,1),nan(nr,1))
	col2 = repmat(vn(2:nc0),nr0,1)
	ts{:,2} = col2(:)
	for i = 1:nc
		si = (i-1)*nr0+1
		ei = si+nr0-1
		ts{si:ei,3} = tus{:,i+1}
	end
	ts.variablenames = {vn{1} 'vars' 'values'}

end