function [out] = bar(x, y, options)

	% check if table object
	if isa(x,'table')
		if nargin == 2, options = y; y = []; end
		options.legendLabels = x.variablenames
		x = x{:,:}
	end
	
	% check arguments
	[x y o] = chartCheckArgs(x,y,options)
	if isempty(o), o = struct; end
	if size(y,1) > 1 & size(y,2) > 1
		if isfield(o,'barStack') && o.barStack == true
			o.hover = flipud(y)
			y = cumsum(y,1)
		end
		y = flipud(y)
	end
	
	% get 80% of min x spacing in order to set bar width
	n = numel(x)
	if n > 1
		sx = sort(x)
		md = min(sx(2:end) - sx(1:end-1)) * 0.8
	else
		md = 0.5
	end	
	
	% default bar options
	if ~isfield(o,'type'), o.type = 'bar'; end
	if ~isfield(o,'barFill'), o.barFill = 'lightsteelblue'; end
	if ~isfield(o,'barWidth'), o.barWidth = md; end
	if ~isfield(o,'xAxisTicks'), o.xAxisTicks = min(n,10); end
	
	% set options without considering infinite values
	[minx maxx] = axisRange(min(min(min(x))), max(max(x(isfinite(x)))))
	[miny maxy] = axisRange(min(min(min(y)),0), max(max(y(isfinite(y)))))
	o = chartOptions(o, minx - md, maxx + md, miny, maxy)
	
	% overriden options
	o.dashArray = 'area'
	o.barCount = n
	o.markerSize = 0
	o.lineWidth = 0
	o.barWidthScale = true
	if ~o.barStack, o.hover = y; end
	if ~isempty(o.xAxisLabels), o.xAxisTicks = max(size(o.xAxisLabels)); end
	if ~isempty(o.yAxisLabels), o.yAxisTicks = max(size(o.yAxisLabels)); end
	
	if (size(y,1) > 1 & size(y,2) > 1)
		out = gen2d(x,y,o)
	else
		x = x-o.barWidth/2
		out = gen2dVect(x,y,o)
	end

end