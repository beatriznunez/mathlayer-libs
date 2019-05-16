function out = waterfall(x,y,options)
	
	% check arguments	
	[x y o] = chartCheckArgs(x,y,options)
	
	% get 80% of min x spacing in order to set bar width
	n = numel(x)
	if n > 1
		sx = sort(x)
		md = min(sx(2:end) - sx(1:end-1)) * 0.8
	else
		md = 0.5
	end	
	
	% default waterfall options
	o.type = 'waterfall'
	o.barWidth = 0.8
	o.barBase = []
	if isfield(o,'posWaterfallFill'), o.barFillPos = o.posWaterfallFill; end
	if isfield(o,'negWaterfallFill'), o.barFillNeg = o.negWaterfallFill; end
	if ~isfield(o,'height'), o.height = 350; end
	if ~isfield(o,'barFillPos'), o.barFillPos = 'lightsteelblue'; end
	if ~isfield(o,'barFillNeg'), o.barFillNeg = '#b30000'; end
	if ~isfield(o,'xAxisTicks'), o.xAxisTicks = min(n,10); end
	
	% set options without considering infinite values
	[minx maxx] = axisRange(min(min(min(x))), max(max(x(isfinite(x)))))
	[miny maxy] = axisRange(min(min(cumsum(y(isfinite(y)))),0), max(cumsum(y(isfinite(y)))))
	a = 0.05*(350-110)/(o.height-110)*(maxy - miny)
	o = chartOptions(o, minx - md, maxx + md, miny-a, maxy+a)
	
	% overriden options
	o.dashArray = 'area'
	o.barCount = n
	o.markerSize = 0
	o.lineWidth = 0
	o.barWidthScale = true
	o.showVals = true
	o.hover = y
	
	y = cumsum(y)
	o.barBase = [0 y(:,1:end-1)]
	for i = 1:numel(o.barBase)
		if o.barBase(i) < o.yAxisMin, o.barBase(i) = o.yAxisMin, o.yAxisMin = o.yAxisMin-a; end
	end
	
	x = x-o.barWidth/2
	out = gen2dVect(x,y,o)

end