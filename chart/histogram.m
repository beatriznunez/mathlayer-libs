function [out bw minx maxx] = histogram(x, options)
	
	% check arguments
	if isempty(options), options = struct; end
	[xb,y,edges,nb] = histcounts(x,options)
	
	if nb > 1
		sx = sort(xb)
		md = min(sx(2:end) - sx(1:end-1))
	else
		md = 1
	end	
	
	% default plot options
	options.type = 'histogram'
	if ~isfield(options,'barFill'), options.barFill = 'lightsteelblue'; end
	if isfield(options,'edges')
		options.xAxisMin = min(edges)
		options.xAxisMax = max(edges)
		options.barWidth = edges(2:end) - edges(1:end-1)
		options.barWidthScale = false % set to false, barWidthScale not compatible with edges
	end
	
	% set options without considering infinite values
	[miny maxy] = axisRange(min(y),max(y))
	if min(x) ~= max(x)
		o = chartOptions(options, min(x(isfinite(x))), max(x(isfinite(x))), 0, maxy)
	else
		o = chartOptions(options, min(x(isfinite(x)))-0.5, max(x(isfinite(x)))+0.5, 0, maxy)
	end
	
	if ~isempty(o.barWidth)
		if (~o.barWidthScale && length(o.barWidth) == 1)
			o.barWidth = (o.xAxisMax-o.xAxisMin)*o.barWidth/(o.width-o.paddingLeft-o.paddingRight)
		end
	else
		o.barWidth = md
	end
	
	% overriden options
	o.dashArray = 'area'
	o.barCount = nb
	o.markerSize = 0
	o.lineWidth = 0
	o.hover = y
	
	if o.horizontal == true
		bw = o.barWidth
		o.barBase = bw/2+xb
		o.barWidth = y
		y = xb-bw/2
		xb = o.barWidth/2
	end
	
	xb = xb-o.barWidth/2
	out = gen2dVect(xb,y,o)
	
end