function [out] = timeline(x, y, options)
	
	x(isnan(x)) = []
	x(isinf(x)) = []
	
	if nargin == 2, options = struct; end
	
	if isfield(options,'xAxisFormat') && strcmp(options.xAxisFormat, 'date')
		options.yAxisFormat = 'date'
	end
	
	[x y o] = chartCheckArgs(x,y,options)
	
	if ~isfield(o,'barFill'), o.barFill = 'lightsteelblue',o.dataColor = o.barFill; end
	if strcmp(o.barFill,'colors'), o.barFill = colorSet(1); end
	
	% set options
	[miny maxy] = axisRange(min(x),max(y))
	
	if ~isfield(o,'width'), o.width = 800; end
	
	
	o = chartOptions(o,  0, numel(x), miny, maxy)
	
	
	% overriden options
	o.type = 'timeline'
	o.horizontal = true
	o.barCount = numel(x)
	o.yAxisShow = false
	o.dashArray = 'area'
	o.markerSize = 0
	o.lineWidth = 0
	o.barWidth = y - x
	o.refLines = true
	o.labelsAnchor = 'end'
	o.hover = y
	
	yy = (1:o.barCount)
	o.barBase = yy-1+0.05
	y = yy-0.05
	
	out = gen2dVect(x,y,o)

end