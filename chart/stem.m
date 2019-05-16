function [out] = stem(x, y, options)
	
	% check arguments
	[x y o] = chartCheckArgs(x,y,options)
	
	% default stem options
	o.type = 'stem'
	
	% set options without considering infinite values
	[minx maxx] = axisRange(min(min(x(isfinite(x)))), max(max(x(isfinite(x)))))
	[miny maxy] = axisRange(min(min(min(y(isfinite(y)))),0), max(max(y(isfinite(y)))))
	o = chartOptions(o, minx, maxx, miny, maxy)
	
	% overriden options
	o.lineWidth = 0
	o.barCount = numel(x)
	o.barStrokeWidth = 0
	o.barWidth = (o.xAxisMax - o.xAxisMin)/(o.width - o.paddingLeft - o.paddingRight)
	if numel(o.barFill) == 0, o.barFillPos = o.markerStroke{1}, o.barFillNeg = o.markerStroke{1}; end
	
	if (size(y,1) > 1 & size(y,2) > 1)
		out = gen2d(x,y,o)
	else
		out = gen2dVect(x,y,o)
	end

end

