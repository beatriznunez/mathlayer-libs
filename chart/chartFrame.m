function [css js xf yf] = chartFrame(o)

	w = num2str(o.width)
	h = num2str(o.height)
	pl = num2str(o.paddingLeft)
	pb = num2str(o.paddingBottom)
	pr = num2str(o.paddingRight)
	pt = num2str(o.paddingTop)
	as = num2str(o.axisSpacing)
	if ~isempty(o.xAxisMin), xMin = num2str(o.xAxisMin,6); end
	if ~isempty(o.xAxisMax), xMax = num2str(o.xAxisMax,6); end
	if ~isempty(o.yAxisMin), yMin = num2str(o.yAxisMin,6); end
	if ~isempty(o.yAxisMax), yMax = num2str(o.yAxisMax,6); end
	if ~isempty(o.y2AxisMin), y2Min = num2str(o.y2AxisMin,6); end
	if ~isempty(o.y2AxisMax), y2Max = num2str(o.y2AxisMax,6); end
	xName = o.xAxisName
	yName = o.yAxisName
	y2Name = o.y2AxisName
	xf = 'xf(d[0])' % x value formatted
	yf = 'yf(d[1])' % y value formatted
	tag = o.tag
	
	if o.horizontal == true % horizontal histogram
		xMin = num2str(o.yAxisMin)
		xMax = num2str(o.yAxisMax)
		yMin = num2str(o.xAxisMin)
		yMax = num2str(o.xAxisMax)
	end
	if o.vertical
		tmpWidth = o.width
		o.width = o.height
		o.height = tmpWidth
	end
	
	css = ['
body {
	background-color: ' o.bodyColor ';
}

.xaxis path,
.xaxis line,
.yaxis path,
.yaxis line,
.y2axis path,
.y2axis line {
	fill: none;
	stroke: black;
	shape-rendering: crispEdges;
}
.node text{
   font: 12px sans-serif;
}
.link{
   fill: none;
   stroke: #ccc;
   stroke-width: 2px;
']
	if strcmp(o.type,'treemap')
		css = ['.node text{
   font: 12px sans-serif;
}
.link{
   fill: none;
   stroke: #ccc;
   stroke-width: 2px;
}']
	elseif strcmp(o.type,'animate')
		css = ['button{
	width: 30px;
	height: 22.5px;
}']
	end
	if strcmp(o.type,'assemble') || (isfield(o,'subtype') && strcmp(o.subtype,'animate'))
		css = ['#container > div, #container > div > div  {
	display: inline;
	float: left;
}']
	end
	y2Vars = ''
	if o.showSecondaryAxis
		y2Vars = ['var y2Min=' y2Min  ',y2Max=' y2Max ';']
	end
	
	js = ['
var w=' w ',h=' h ',pl=' pl ',pb=' pb ',pr=' pr ',pt=' pt ',as=' as ',xMin=' xMin ',xMax=' xMax ',yMin=' yMin ',yMax=' yMax ';
' y2Vars '
var xf=d3.format("' o.xFormat '"); var yf=d3.format("' o.yFormat '");
var cx=pl,cy=pt,cw=w-pr-pl,ch=h-pb-pt;
']

	if strcmp(o.type,'heatmap')
		if o.gradientHM
			js = [js '
canvas = d3.select("#' tag '").append("canvas")
	.attr("width", ' num2str(o.xAxisTicks) ')
	.attr("height", ' num2str(o.yAxisTicks) ')
	.style("position", "absolute")
	.style("width", cw + "px")
	.style("height", ch + "px")
	.style("padding-top", pt + "px")
	.style("padding-left", pl + "px")
	.node().getContext("2d");
	
svg = d3.select("#' tag '")
    .append("svg")
	.attr("width","100%")
	.attr("height","100%")
	.attr("viewBox","0 0 " + w + " " + h)
	.attr("transform", "translate(' o.translate ') rotate(' num2str(o.rotate) ')")
	.style("position", "relative")
    .append("g");

window.onresize = function(){ resizeCanvas_' o.tag '()};
$(document).ready(function(){ resizeCanvas_' o.tag '()});
function resizeCanvas_' o.tag '() {
	canvas.clientWidth = $("#' o.tag ' rect")[0].getBoundingClientRect().width
	canvas.clientHeight = $("#' o.tag ' rect")[0].getBoundingClientRect().height
	canvas.x = $("#' o.tag ' rect")[0].getBoundingClientRect().x - $("#' o.tag ' > canvas")[0].offsetLeft
	canvas.y = $("#' o.tag ' rect")[0].getBoundingClientRect().y - $("#' o.tag ' > canvas")[0].offsetTop
	$("#' o.tag ' > canvas")[0].style.width = canvas.clientWidth.toString().concat("px")
	$("#' o.tag ' > canvas")[0].style.height = canvas.clientHeight.toString().concat("px")
	$("#' o.tag ' > canvas")[0].style.paddingLeft = canvas.x.toString().concat("px")
	$("#' o.tag ' > canvas")[0].style.paddingTop = canvas.y.toString().concat("px")
}
']
		else
			js = [js '
var svg = d3.select("#' tag '")
.append("svg")
.attr("width","100%")
.attr("height","100%")
.attr("viewBox","0 0 " + w + " " + h)
.attr("transform", "translate(' o.translate ') rotate(' num2str(o.rotate) ')");']
		end	
		for i=1:size(o.colorScale,2)
			tmp = sprintf('%f,',o.colorScale{i})
			colors = [colors '"'  tmp(1:end-1) '",']
		end
		for i=1:size(o.colorScale,2)-4
		ranges = [ranges '((xMax-xMin)*' num2str(o.rangeMin+i*(100-o.rangeMin-o.rangeMax)/(size(o.colorScale,2)-3)) '/100)+xMin' ',']
		end
		if size(o.colorScale,2)>2
		rangeMax = [ '((xMax-xMin)*' num2str(100-o.rangeMax) '/100)+xMin' ',']
		end
		if size(o.colorScale,2)>3
		rangeMin = [ '((xMax-xMin)*' num2str(o.rangeMin) '/100)+xMin' ',']
		end
	js = [js '
var color = d3.scaleLinear();
var ranges = [xMin, ' rangeMin '' ranges '' rangeMax ' xMax]		
var colorScale = [' colors(1:end-1) ']
color.domain(ranges, function(d,i){ return d[i]; });
color.range(colorScale, function(d,i){ return d[i]; });
var dx = ' num2str(o.xAxisTicks) ';
var dy = ' num2str(o.yAxisTicks) ';
var x = d3.scaleLinear().domain([0, dx]).range([pl, w - pr]);
var y = d3.scaleLinear().domain([0, dy]).range([h - pb, pt]);	

var xAxis = d3.axis' o.xAxisPos '(x).ticks(dx);
var yAxis = d3.axis' o.yAxisPos '(y).ticks(dy);

svg.append("rect")
	.attr("x",pl)
	.attr("y",pt)
	.attr("width",cw)
	.attr("height",ch)
	.attr("fill","none")
	.style("shape-rendering", "crispEdges")
	.style("stroke","black");
']
	else

	js = [js '
var xScale = d3.scale' o.xAxisScale '().domain([xMin, xMax]).range([pl, w - pr]);
var yScale = d3.scale' o.yAxisScale '().domain([yMin, yMax]).range([h - pb, pt]);
var xAxis = d3.axisBottom(xScale).ticks(' num2str(o.xAxisTicks) ');
var yAxis = d3.axisLeft(yScale).ticks(' num2str(o.yAxisTicks) ');']
	end
	% if max(o.markerSize) > 0 
	% js = [js '
% var bubScale = d3.scaleLinear().domain([' num2str(min(o.markerSize)) ',' num2str(max(o.markerSize)) ']).range([' o.minRange ', ' o.maxRange ']);']
	% end
	if o.showGridX
		css = [css '
.xaxis line{
    opacity: 0.2;
}']
		js = [js '
xAxis.tickSizeInner(-ch).tickSizeOuter(0);']
	end
	if o.showGridY
		css = [css '
.yaxis line{
    opacity: 0.2;
}']
		js = [js '
yAxis.tickSizeInner(-cw).tickSizeOuter(0);']
	end
	if o.showSecondaryAxis
	js = [js '
var y2Scale = d3.scale' o.y2AxisScale ' ().domain([y2Min, y2Max]).range([h - pb, pt]);
var y2Axis = d3.axisRight(y2Scale).ticks(' num2str(o.y2AxisTicks) ');
']
	end
	
	xPos = 'xInvScale(coordinates[0])'
	yPos = 'yInvScale(coordinates[1])'
	
	if iscell(o.markerSize)
		maxopms = max(cellfun(@(x) (x), o.markerSize))
	else
		maxopms = max(o.markerSize)
	end
	if o.tooltip || maxopms > 0
		if strcmpi(o.tooltipPosition,'mouse')
			yPosTooltip = '(d3.event.pageY+8)+"px"' 
			xPosTooltip = '(d3.event.pageX+12)+"px"'
		elseif strcmpi(o.tooltipPosition,'top')
			yPosTooltip = '(pt-16)+"px"' 
			xPosTooltip = '(pl)+"px"'
		end
		if maxopms > 0
			js = [js 'var copyData = d3.select("body").append("div").style("position", "absolute").style("z-index", "10").style("visibility", "hidden");']
		end
		if o.tooltip
			js = [js 'var tooltip = d3.select("body").append("div").style("position", "absolute").style("z-index", "10").style("visibility", "hidden");']
		end
	end
	if ~strcmp(o.type,'heatmap') && ~strcmp(o.type,'pie')
		js = [ js '
var svg = d3.select("#' tag '").append("svg").attr("width","100%").attr("height","100%").attr("viewBox","0 0 " + w + " " + h);
svg.attr("transform", "translate(' o.translate ') rotate(' num2str(o.rotate) ')");
svg.append("rect").attr("width", ' num2str(o.width) ').attr("height", ' num2str(o.height) ').attr("fill", "' o.backgroundColor '");

var canvas = svg.append("rect")
.attr("x", cx)
.attr("y", cy)
.attr("width", cw)
.attr("height", ch)
.attr("fill", "' o.canvasColor '")
.attr("opacity", ' num2str(o.canvasOpacity) ')
.style("cursor", "crosshair")
.style("position", "relative")']
	elseif strcmp(o.type,'pie')
			js = [ js '
var svg = d3.select("#' tag '").append("svg").attr("width","100%").attr("height","100%").attr("viewBox","0 0 " + w + " " + h).append("g").attr(''transform'', ''translate('' + (h / 2) +'','' + (h / 2) + '' ) rotate(' num2str(o.rotate) ')'')']
	end
	if o.tooltip
		js = [js '
.on("mouseover", function(){return tooltip.style("visibility", "visible");})
.on("mousemove", function(){
var xInvScale = d3.scaleLinear()
.domain([pl, w - pr])
.range([' xMin ', ' xMax ']);
var yInvScale = d3.scaleLinear()
.domain([h - pb, pt])
.range([' yMin ', ' yMax ']);
var coordinates = [0, 0];
coordinates = d3.mouse(this);
tooltip.html("X: " + xf(' xPos ') + "<br/>Y: " + yf(' yPos '));
tooltip.style("font-family", "Arial");
tooltip.style("font-size", "0.8em");
return tooltip.style("top", ' yPosTooltip ').style("left",' xPosTooltip ');
})
.on("mouseout", function(){return tooltip.style("visibility", "hidden");})']
	end
	
	js = [js ';']
		
	if o.gradient
		js = [ js '
var gradient = svg.append("svg:defs")
.append("svg:linearGradient")
.attr("id", "gradient")
.attr("x1", "0%")
.attr("y1", "0%")
.attr("x2", "100%")
.attr("y2", "0%")
.attr("spreadMethod", "pad");

gradient.append("svg:stop")
.attr("offset", "0%")
.attr("stop-color", "' o.gradientColor1 '")
.attr("stop-opacity", 1);

gradient.append("svg:stop")
.attr("offset", "100%")
.attr("stop-color", "' o.gradientColor2 '")
.attr("stop-opacity", 1);

canvas.style("fill","url(#gradient)");
']
	end

	if numel(o.xAxisFormat) > 0
		% xPos = 'new Date(xInvScale(coordinates[0]))'
		if strcmpi(o.xAxisFormat, 'date')
			xIsDate = true;
			js = [ js  '
var xaf = d3.timeFormat("' o.xAxisDateFormat '");
xAxis.tickFormat(function(d){ return xaf(new Date(d)) });']
		
		else
			js = [ js  '
var xaf = d3.format("' o.xAxisFormat '");
xAxis.tickFormat(function(d){ return xaf(d) });']
		end
	end
	if  numel(o.yAxisFormat) > 0
		if strcmpi(o.yAxisFormat, 'date')
			yIsDate = true;
			yf = 'yf(new Date(d[0]))';
			js = [ js  '
var yaf = d3.timeFormat("' o.yAxisDateFormat '");
yAxis.tickFormat(function(d){ return yaf(new Date(d)) });']
		
		else
			js = [ js  '
var yaf = d3.format("' o.yAxisFormat '");
yAxis.tickFormat(function(d){ return yaf(d) });']
		end
	end	
	if  numel(o.y2AxisFormat) > 0
		if strcmpi(o.y2AxisFormat, 'date')
			js = [ js  '
var y2af = d3.timeFormat("' o.y2AxisDateFormat '");
y2Axis.tickFormat(function(d){ return y2af(new Date(d)) });']
		
		else
			js = [ js  '
var y2af = d3.format("' o.y2AxisFormat '");
y2Axis.tickFormat(function(d){ return y2af(d) });']
		end
	end	
	% format labels
	if numel(o.xAxisLabels) > 0 
		tmp = o.xAxisLabels
		xLabels = sprintf('"%s",',tmp{:})
		js = [ js  '
var xLabels = [' xLabels(1:end-1) '];
xAxis.tickFormat(function(d,i){ return xLabels[i] });
']
	end
	if  numel(o.yAxisLabels) > 0 
		% format labels
		tmp2 = o.yAxisLabels
		yLabels = sprintf('"%s",',tmp2{:})
		js = [ js  '
var yLabels = [' yLabels(1:end-1) ']
yAxis.tickFormat(function(d,i){ return yLabels[i] });
']
	end
	if o.xAxisShow
		js = [js '	
svg.append("g")
.attr("class", "xaxis")
.attr("transform", "translate(' o.xAxisPosition ')")
.call(xAxis)
.selectAll("text")
.style("text-anchor", "' o.xAxisTextAnchor '")
.style("font", "' o.xAxisFont '")
.style("fill", "' o.xAxisColor '")
.attr("transform", "rotate(' num2str(-o.xAxisRotate) ') translate(' o.xAxisTranslate ')" );
$("#' tag ' .xaxis path, #' tag ' .xaxis line").css("stroke","' o.xAxisColor '");
']
	end
	if o.yAxisShow
		js = [js '
svg.append("g")
.attr("class", "yaxis")
.attr("transform", "translate(' o.yAxisPosition ')")
.call(yAxis)
.selectAll("text") 
.style("text-anchor", "' o.yAxisTextAnchor '")
.style("font", "' o.yAxisFont '")
.style("fill", "' o.yAxisColor '")
.attr("transform", "rotate(' num2str(-o.yAxisRotate) ') translate(' o.yAxisTranslate ')" );
$("#' tag ' .yaxis path, #' tag ' .yaxis line").css("stroke","' o.yAxisColor '");
']
	end
	if o.showSecondaryAxis
		js = [js '
svg.append("g")
.attr("class", "y2axis")
.attr("transform", "translate(" + (w - pr) + ",0)")
.call(y2Axis)
.selectAll("text")
.style("font", "' o.y2AxisFont '")
.style("fill", "' o.y2AxisColor '")
.attr("transform", "rotate(' num2str(-o.y2AxisRotate) ') translate(' o.y2AxisTranslate ')" );
$("#' tag ' .y2axis path, #' tag ' .y2axis line").css("stroke","' o.y2AxisColor '");
']
	end
	if o.showSquaredCanvas
		js = [js '
svg.append("g")
.attr("class", "xaxis")
.attr("transform", "translate(0," + (pt + as) + ")")
.call(xAxis.ticks(0));
svg.append("g")
.attr("class", "yaxis")
.attr("transform", "translate(" + (w - pr - as) + ",0)")
.call(yAxis.ticks(0));		
']
	end
	
	if ~isempty(xName)
		js = [js '
svg.append("text")
.style("font", "' o.xAxisNameFont '")
.style("fill", "' o.xAxisNameColor '")
.attr("text-anchor", "middle")
.attr("x", cx + cw / 2)
.attr("y", cy + ch + 50)
.text("' xName '");
']
	end
	
	if ~isempty(yName)
		js = [js '
svg.append("text")
.style("font", "' o.yAxisNameFont '")
.style("fill", "' o.yAxisNameColor '")
.attr("text-anchor", "middle")
.attr("x", -cy - ch / 2)
.attr("y", cx - 50)
.attr("transform", "rotate(-90)")
.text("' yName '");
']
	end

	if ~isempty(y2Name)
		js = [js '
svg.append("text")
.style("font", "' o.y2AxisNameFont '")
.style("fill", "' o.y2AxisNameColor '")
.attr("text-anchor", "middle")
.attr("x", -cy + -ch / 2)
.attr("y", w - pr+60)
.attr("transform", "rotate(-90)")
.text("' y2Name '");
']
	end
	if ~isempty(o.title)
		js = [js '
svg.append("text")
.style("font", "' o.titleFont '")
.attr("text-anchor", "' o.titleAnchor '")
.attr("x", cx + ' num2str(o.titleX) ')
.attr("y", cy - ' num2str(o.titleY) ')
.text("' o.title '");	
']
	end
end