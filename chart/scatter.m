function [out] = scatter(x, y, options)
	
	% check if table object
	if isa(x,'table')
		n = size(x, 2)
		if nargin == 2, options = y; end
		options.legendLabels = x.variablenames{2: n}
		y = x{:,[2:n]} % split the table
		x = x{:,1}
	end
	
	% check arguments
	[x y o] = chartCheckArgs(x,y,options)
	
	% default scatter options
	o.type = 'scatter'
	if isfield(o, 'lineWidth'), o.dashArray = '1 0'; end
	
	% set options without considering infinite values
	[minx maxx] = axisRange(min(min(x(isfinite(x)))), max(max(x(isfinite(x)))))
	[miny maxy] = axisRange(min(min(y(isfinite(y)))), max(max(y(isfinite(y)))))
	o = chartOptions(o, minx, maxx, miny, maxy)
	
	% overriden options
	if minx<=0 & strcmp(o.xAxisScale,'Log'), o.xAxisMin = min(min(x(x>0))); end
	if miny<=0 & strcmp(o.yAxisScale,'Log'), o.yAxisMin = min(min(y(y>0))); end
	
	if (size(y,1) > 1 & size(y,2) > 1)
		out = gen2d(x,y,o)
	else
		out = gen2dVect(x,y,o)
	end

end