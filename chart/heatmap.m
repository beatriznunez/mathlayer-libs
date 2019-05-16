function out = heatmap(x, options)
	
	if istable(x)
		x = x{:,:}		
	end
	
	minx = min(min(x))
	maxx = max(max(x))
	miny = min(size(labels))
	maxy = max(size(labels))	
	
	[minx maxx] = axisRange(minx,maxx)
	
	options.markerSize = 0; 
	options.type = 'heatmap';

	if isfield(options,'xAxisMin'), options.cminx = options.xAxisMin, rmfield(options,'xAxisMin'); end
	if isfield(options,'xAxisMax'), options.cmaxx = options.xAxisMax, rmfield(options,'xAxisMax'); end
	if isfield(options,'yAxisMin'), options.cminy = options.yAxisMin, rmfield(options,'yAxisMin'); end
	if isfield(options,'yAxisMax'), options.cmaxy = options.yAxisMax, rmfield(options,'yAxisMax'); end
	
	if isfield(options,'xAxisLabels') && isempty(options.xAxisLabels)
		tmp = {}
		for i = 1:size(x,2), tmp{i} = num2str(i); end
		options.xAxisLabels= tmp	
	end	
	
	if isfield(options,'yAxisLabels') && isempty(options.yAxisLabels)
		tmp = {}
		for i = 1:size(x,1), tmp{i} = num2str(i); end
		options.yAxisLabels= tmp
	end
	
	o = chartOptions(options, minx, maxx, miny, maxy)
	
	if isempty(o.xAxisLabels), o.xAxisShow = false; end
	if isempty(o.yAxisLabels), o.yAxisShow = false; end
	
	if o.vertical
		o.translate = ['-' num2str(o.paddingLeft) ',' num2str(o.paddingTop)]
		o.rotate = '90'
	end
	
	if strcmpi(o.xAxisPos,'Bottom')
		o.xAxisTranslate = '"+(cw/dx)/2+",0'
		o.xAxisPosition = '0,"+(h-pb)+"'
		if o.vertical
			o.xAxisTranslate = '-10,"+(cw/dx/2-10)+"'
		end
	elseif 	strcmpi(o.xAxisPos,'Top')
		o.xAxisTranslate = '"+(cw/dx)/2+",0'
		o.xAxisPosition = '0,"+(pt)+"'
		if o.vertical
			o.xAxisTextAnchor = 'start'
			o.xAxisTranslate = '+10,"+(cw/dx/2+10)+"'
		end
	end
	if strcmpi(o.yAxisPos,'Left')
		o.yAxisTranslate = '0,"+((ch/(2*dy))-(ch/dy))+"'
		o.yAxisPosition = '"+(pl)+",0'
		if o.vertical
			o.yAxisTranslate = '"+(ch/dy)/2+",-10'
		end
	elseif 	strcmpi(o.yAxisPos,'Right')
		o.yAxisPosition = '"+(pl+cw)+",0'
		o.yAxisTextAnchor = 'start'
		o.yAxisTranslate = '0,"+((ch/(2*dy))-(ch/dy))+"'
		if o.vertical
			o.yAxisTextAnchor = 'middle'
			o.yAxisTranslate = '"+(ch/dy)/2+",+10'
		end
	end
	
	o.showLegend = true
	o.legendType = 'gradient'
	o.xAxisTicks = size(x,2)
	o.yAxisTicks = size(x,1)
	x = x(end:-1:1,:)	% invert Yvalues
	y=x
	out = gen2dVect(x,y,o)	
end