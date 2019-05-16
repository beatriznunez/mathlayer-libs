function legend = chartLegend(n, o)
	
	if strcmp('pie', o.type), n = n'; end
	if numel(n)>1,n = size(n,1);end
	
	% defining default average width for lower case and upper case
	font = o.legendFont
	font = regexprep(font, '[a-z]','')
	font = regexprep(font, '\s','')
	
	pxLowerCase = str2num(font)*0.55
	pxUpperCase = str2num(font)*2/3
	textWidth = 12
	
	if isempty(o.legendLabels)
		legendVect = cast(num2str(1:n),'cell')
	else
		legendVect = o.legendLabels
		for i = 1:numel(legendVect) % calculate text box needed width
			nbUpper = numel(regexp(legendVect{i},'[A-Z]'))
			textWidth = max(textWidth, nbUpper*pxUpperCase + (numel(legendVect{i}) - nbUpper)*pxLowerCase)
		end
	end
	
	% extract legend settings from o object
	if isfield(o,'Fill'), markerFill = o.Fill; else, markerFill = o.markerFill; end 
	
	op = struct
	op.tag = o.tag
	op.lc = o.legendColor
	op.lo = o.legendOpacity
	op.ls = o.legendStroke
	op.dataset = legendVect
	op.color = o.dataColor
	op.mf = markerFill
	op.mst = o.markerStroke
	op.lst = o.dashArray
	op.ms = o.markerShape
	op.lf = o.legendFont
	op.legendPadding = 6;
	op.legendRectSize = 18;
	op.legendSpacing = 4;
	op.height = op.legendRectSize + op.legendSpacing;
	op.legendWidth = textWidth + 2*op.legendPadding + op.legendRectSize + op.legendSpacing;
	op.legendHeight = n*op.height + op.legendPadding + op.legendSpacing/2;
	op.legMin = o.xAxisMin;
	op.legMax = o.xAxisMax;
	op.offset = 0;
	
	% calculate x and y coordinates of text box top left corner
	x = o.legendX
	y = o.legendY
	
	if isempty(x)
		if o.vertical, op.x = -o.paddingTop - op.legendWidth;
		else, op.x = o.width - o.paddingRight - op.legendWidth; end
	else
		op.x = x
	end
	
	if isempty(y)
		if o.vertical
			op.y = o.paddingLeft + op.legendPadding;
		else
			offset = min(op.height*n/2 - o.paddingTop, -o.paddingTop)
			op.y = -offset - op.legendPadding
		end
	else
		op.y = y 
	end
	
	if o.vertical
		op.rot = -90
		op.vert = o.paddingTop + op.legendWidth - op.legendPadding;
		op.horz = o.paddingLeft + 5 + op.legendPadding;
		op.width = op.height
		op.height = 0
	else
		op.width = 0
		op.rot = 0
		op.horz = op.x  + op.legendPadding;
		op.vert = op.y + op.legendPadding;
	end
	
	if strcmp('bar', o.type) || strcmp('area', o.type)
		if iscell(op.color), op.color = fliplr(op.color); end
	end
	
	if strcmp('pie', o.type)
		op.color = o.colors
		op.x = (o.height-o.paddingTop-o.paddingBottom)/2 + 30
		op.y = -(o.height-o.paddingTop-o.paddingBottom)/2
		op.horz = op.x  + op.legendPadding;
		op.vert = op.y + op.legendPadding;
	end
	
	if (strcmp('heatmap', o.type) || (~ischar(o.markerStroke) && ~iscell(o.markerStroke))) || (~ischar(o.markerFill) && ~iscell(o.markerFill))
		op.legendTicks = o.legendTicks
		op.y = o.paddingTop
		op.legendFormat = o.legendFormat
		op.colorScale = fliplr(o.colorScale)
		op.offsetleg = 0
		
		nc = size(o.colorScale,2)
		op.range = ones(1,nc)
		op.range(1) = 0
		op.range(nc) = 100
		for i=1:nc-4
			op.range(i+2) = o.rangeMin+i*(100-o.rangeMin-o.rangeMax)/(nc-3)
		end
		if nc>2
			op.range(2) = o.rangeMax
		end
		if nc>3
			op.range(nc-1) = 100-o.rangeMin
		end
		
		if strcmpi(o.yAxisPos,'left')
			op.x = o.width-o.paddingRight+10
			op.width = 15
			op.axis = "d3.axisRight(y)"
		elseif 	strcmpi(o.yAxisPos,'right')
			op.x = o.paddingLeft-30
			op.width = 0
			op.axis = "d3.axisLeft(y)"
		end
		if (~strcmp('heatmap', o.type))
			if (~ischar(o.markerStroke) && ~iscell(o.markerStroke))
				op.legMin = min(o.markerStroke)
				op.legMax = max(o.markerStroke)
			elseif (~ischar(o.markerFill) && ~iscell(o.markerFill))
				op.legMin = min(o.markerFill)
				op.legMax = max(o.markerFill)
			end
			if (~strcmp('gradient', o.legendType))
				twolegends = true
				op.offset = o.paddingTop + max(o.markerSize)*2
				op.offsetleg = max(o.markerSize)/2
			end
		end
	end
	
	if strcmp(o.legendType,'buble')
		a = min(o.markerSize)
		b = max(o.markerSize)
		op.dataset = [a,a+(b-a)/2,b]
		op.x = o.width-o.paddingRight
		op.y = o.paddingTop
	end
	
	opnames = fieldnames(op)
	ops = struct
	for i = 1:size(op,1)
		name = opnames{i}
		if ischar(op(name))
			ops(name) = cast(op(name),'cell')
		else 
			ops(name) = op(name)
		end
	end
	
	% create javascript legend
	legend = [legend '
var legop = ' struct2json(ops) ';
']
	if twolegends
		legend = [legend legendCode('gradient',o)]
	end
	
	legend = [legend legendCode(o.legendType,o)]
	
end
