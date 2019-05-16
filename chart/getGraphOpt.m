function out = getGraphOpt(options)
	
	o = struct
	
	% tag
	o.tag = options.tag	
	% legend
	o.legendFont = options.legendFont
	% axis
	o.xAxisFont = options.xAxisFont	
	% data
	o.dataColor = options.dataColor
	% marker
	o.markerSize = options.markerSize
	o.markerFill = options.markerFill		
	o.markerStroke = options.markerStroke
	o.markerShape = options.markerShape		
	% line
	o.lineWidth = options.lineWidth	
	o.lineStroke = options.lineStroke	
	o.lineFill = options.lineFill	
	o.lineInterpolate = options.lineInterpolate	
	o.dashArray = options.dashArray	
	% area
	o.areaAboveStroke = options.areaAboveStroke	
	o.areaBelowStroke = options.areaBelowStroke	
	o.areaOpacity = options.areaOpacity	
	o.areaBase = options.areaBase	
	% bars
	o.barStroke = options.barStroke	
	o.barStrokeWidth = options.barStrokeWidth	
	o.barFillPos = options.barFillPos	
	o.barFillNeg = options.barFillNeg
	o.barWidth = options.barWidth	
	o.barBase = options.barBase		
	o.barOpacity = options.barOpacity
	o.barTranslate = options.barTranslate	
	% mouse
	o.hover = options.hover
	% labels
	o.labels = options.labels
	o.labelsFont = options.labelsFont
	o.labelsAnchor = options.labelsAnchor
	% waterfall
	o.barValueFormat = options.barValueFormat
	% pie
	o.pieValue = options.pieValue
	
	out = o
end