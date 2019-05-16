function [out] = area(x, y, options)
	
	% check if table object
	if isa(x,'table') 
		if nargin == 2, options = y; y = []; end
		try 
			options.legendLabels = x.rownames
		catch e
		end
		options.xAxisTicks = size(x, 2) -1
		options.xAxisLabels = x.variablenames
		x = x{:,:}
		x = x'
	end
	
	% check arguments
	[x y o] = chartCheckArgs(x,y,options)
	if size(y,1) > 1 & size(y,2) > 1
		y = cumsum(y,1)
		y = flipud(y)
	end
	
	% default area options
	o.type = 'area'
	if ~isfield(o,'colors'), hasLineColors = false; else, hasLineColors = true; end
	if ~isfield(o,'areaStroke'), o.areaStroke = 'lightsteelblue'; end
	if isfield(o,'areaBelowStroke') || isfield(o,'areaAboveStroke')
		if ~isfield(o,'areaBelowStroke'), o.areaBelowStroke = 'none'; end
		if ~isfield(o,'areaAboveStroke'), o.areaAboveStroke = 'none'; end
	else
		o.areaAboveStroke = o.areaStroke
		o.areaBelowStroke = o.areaStroke
	end
	if ~isfield(o,'markerSize'), o.markerSize = 0; end
	if ~isfield(o,'lineWidth'), o.lineWidth = 1; end
	if ~isfield(o,'areaBase'), o.areaBase = 0; end

	% set options without considering infinite values
	[minx maxx] = axisRange(min(min(x(isfinite(x)))), max(max(x(isfinite(x)))))
	[miny maxy] = axisRange(min(min(min(y(isfinite(y)))),o.areaBase), max(max(y(isfinite(y)))))
	o = chartOptions(o, minx, maxx, miny, maxy)
	
	% overriden options
	o.dashArray = 'area'
	if ~hasLineColors, o.colors = {'black'}; end
	
	if (size(y,1) > 1 & size(y,2) > 1)
		out = gen2d(x,y,o)
	else
		out = gen2dVect(x,y,o)
	end
end