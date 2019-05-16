function out = chartCombine3d(c, options)
	if ~iscell(c) | numel(c) == 0, error("first argument must be a non empty cell array containing graphs scripts"); end
	if nargin < 2, options.type = 'default'; end
	currentGraph = c{1}
	tmpOpt = currentGraph.options
	xMin = tmpOpt.xAxisMin
	xMax = tmpOpt.xAxisMax
	yMin = tmpOpt.yAxisMin
	yMax = tmpOpt.yAxisMax
	% set options
	options = chartOptions(options, xMin, xMax, yMin, yMax)

	legend = ''
	dataSet = ''
	image = ''
	css = currentGraph.css

	colors = colorSet(1)

	optionsVals = chartOptions(tmpOpt, minx, maxx, miny, maxy)
	chartType = ['"' optionsVals.type '"']
	if ~isempty(optionsVals.labels)
		txt = optionsVals.labels
		if isfield(txt,'txt'), txtvect = txt.txt; end
		jsDataLabels = [ sprintf('"%s",',txtvect{1:end-1}) sprintf('"%s"',txtvect{end}) ]
	end		
	axes3d = options.axesNames
	if ~isempty(options.xAxisName), axes3d{1} = options.xAxisName; end
	if ~isempty(options.yAxisName), axes3d{2} = options.yAxisName; end
	if ~isempty(options.zAxisName), axes3d{3} = options.zAxisName; end
	options.axesNames = axes3d
	if ~isempty(options.axesNames)
		txt = options.axesNames
		jsDataAxesNames = [ sprintf('"%s",',txt{1:end-1}) sprintf('"%s"',txt{end}) ]
	end	
	labels = [labels, '[' jsDataLabels ']']
	axesNames = [axesNames, '[' jsDataAxesNames ']']
	dataSet = [dataSet, '' currentGraph.dataSet '']
	markerSize = num2str(optionsVals.markerSize)
	labelsFont = ['"' optionsVals.labelsFont '"']
	markerStroke3d = ['"' optionsVals.markerStroke3d '"']
	markerFill = ['"' optionsVals.markerFill '"']
	opacity = num2str(optionsVals.opacity)
	surfOpacity = num2str(optionsVals.surfOpacity)
	lineWidth = num2str(optionsVals.lineWidth)
	lineStroke = [lineStroke '"' optionsVals.lineStroke '"']
	lineInterpolate = [lineInterpolate '"' optionsVals.lineInterpolate '"']
	for i = 2:numel(c)
		a = c{i}
		tmpOpt = a.options
		if strcmp(tmpOpt.markerFill,"#3366cc")
			tmpOpt.markerFill = colors{rem(i-1,numel(colors)) + 1}
		end

		optionsVals = chartOptions(tmpOpt, minx, maxx, miny, maxy)
		chartType = [chartType, ',"' optionsVals.type '"']
		if ~isempty(optionsVals.labels)
			txt = optionsVals.labels
			if isfield(txt,'txt'), txtvect = txt.txt; end
			jsDataLabels = [ sprintf('"%s",',txtvect{1:end-1}) sprintf('"%s"',txtvect{end}) ]
			labels = [labels, ',' '[' jsDataLabels ']']
		else
			labels = [labels, ',' '['  ']']
		end		
		dataSet = [dataSet ',' a.dataSet '']
		markerSize = [markerSize ',' num2str(optionsVals.markerSize)]
		labelsFont = [labelsFont ',"' optionsVals.labelsFont '"']
		markerStroke3d = [markerStroke3d ',"' optionsVals.markerStroke3d '"']
		markerFill = [markerFill ',"' optionsVals.markerFill '"']
		opacity = [opacity ',' num2str(optionsVals.opacity)]
		surfOpacity = [surfOpacity ',' num2str(optionsVals.surfOpacity)]
		lineWidth = [lineWidth ',' num2str(optionsVals.lineWidth)]
		lineStroke = [lineStroke ',"' optionsVals.lineStroke '"']
		lineInterpolate = [lineInterpolate ',"' optionsVals.lineInterpolate '"']
	end
	
	for i = 1:numel(c)
		a = c{i}
		b = a.options
		minX = [minX b.xAxisMin]
		maxX = [maxX b.xAxisMax]
		minY = [minY b.yAxisMin]
		maxY = [maxY b.yAxisMax]
		minZ = [minZ b.zAxisMin]
		maxZ = [maxZ b.zAxisMax]
	end

	minx = min(minX)
	maxx = max(maxX)
	miny = min(minY)
	maxy = max(maxY)
	minz = min(minZ)
	maxz = max(maxZ)
	
	options.paddingLeft = options.paddingLeft + 40
	options.paddingRight = options.paddingRight + 40
	
	add2Padding = 60*options.zoom
	options.paddingTop = options.paddingTop + add2Padding
	options.paddingBottom = options.paddingBottom + add2Padding
	options.height = options.height + 2*add2Padding
	[css jsFrame xf yf] = chartFrame(options)
	
	% temporarily setting jsFrame to empty string
	jsFrame = ''
	% convert data into string format
	data = ''
	xData = ''
	yData = ''
	jsData = ''

	jsData = ['var yaw=' num2str(options.yaw) ';
var pitch=' num2str(options.pitch) ';
var width=' num2str(options.width) ';
var depth=' num2str(options.depth) ';
var height=' num2str(options.height) ';
var zoom=' num2str(options.zoom) ';
var showCanvas=' num2str(double(options.showCanvas),0) ';
var drag=false;
var dataset = [' dataSet '];
var labels = [' labels '];
var axesNames = [' axesNames '];
var svg = d3.select("#' options.tag '")
				.append("svg")
				.attr("height","100%")
				.attr("width","100%")
				.attr("viewBox","0 0 ' num2str(max(options.width,options.depth)*options.zoom) ' ' num2str(options.height*options.zoom) '");

var group = svg.append("g").attr("transform", "translate(" + ' num2str(options.paddingLeft) '*zoom + "," + ' num2str(options.paddingTop) '*zoom + ")");

var groupData = {
	showCanvas: showCanvas,
	zoom: zoom,
	tooltip: ' num2str(double(1),0) ',
	labels: labels,
	axesNames: axesNames,
	height: ' num2str(options.height - options.paddingTop - options.paddingBottom) '*zoom,
	width: ' num2str(options.width - options.paddingLeft - options.paddingRight) '*zoom,
	depth: ' num2str(options.depth - options.paddingLeft - options.paddingRight) '*zoom,
	yaw: yaw,
	pitch: pitch,
	dataset: dataset,
	opacity: [' opacity '],
	surfOpacity: [' surfOpacity '],
	chartType: [' chartType '],
	markerSize: [' markerSize '],
	markerStroke3d: [' markerStroke3d '],
	markerFill: [' markerFill '],
	labelsFont: [' labelsFont '],
	lineStroke: [' lineStroke '],
	lineWidth: [' lineWidth '],
	lineInterpolate: [' lineInterpolate '],
	minX: ' num2str(minx) ',
	maxX: ' num2str(maxx) ',
	minY: ' num2str(miny) ',
	maxY: ' num2str(maxy) ',
	minZ: ' num2str(minz) ',
	maxZ: ' num2str(maxz) ',
	xDate: ' num2str(double(strcmpi(options.xAxisFormat,'date')),0) ',
	yDate: ' num2str(double(strcmpi(options.yAxisFormat,'date')),0) ',
	zDate: ' num2str(double(strcmpi(options.zAxisFormat,'date')),0) '
	};
	
var ' options.tag ' = group.data([groupData])
					.surface3D()
					.surfaceColor(function(d){
						var c = d3.hsl(d+50, 0.5, 0.5).rgb();
						return "rgb("+parseInt(c.r)+","+parseInt(c.g)+","+parseInt(c.b)+")";
					});

svg.on("mousedown",function(){ d3.event.preventDefault(); drag = [d3.mouse(this),yaw,pitch]; })
.on("mouseup",function(){ drag = false; })
.on("mousemove",function(){ 
if(drag){
var mouse = d3.mouse(this);
yaw = drag[1]-(mouse[0]-drag[0][0])/50;
yaw = Math.max(-Math.PI,Math.min(Math.PI,yaw));
pitch = drag[2]+(mouse[1]-drag[0][1])/50;
pitch = Math.max(-Math.PI/2,Math.min(Math.PI/2,pitch));
' options.tag '.turntable(yaw,pitch);
gyaw = yaw;
gpitch = pitch;
}
})
.on("mouseleave", function() { 
	if(document.querySelectorAll( ":hover" )[document.querySelectorAll( ":hover" ).length-1].tagName == "DIV" || document.querySelectorAll( ":hover" )[document.querySelectorAll( ":hover" ).length-1].tagName == "HTML" || document.querySelectorAll( ":hover" )[document.querySelectorAll( ":hover" ).length-1].tagName == "svg") 
		drag = false; 
})
.on("touchstart",function(){ d3.event.preventDefault(); drag = [d3.mouse(this),yaw,pitch];})
.on("touchend",function(){ drag = false; })
.on("touchmove",function(){  
if(drag){
var mouse = d3.mouse(this);
yaw = drag[1]-(mouse[0]-drag[0][0])/50;
yaw = Math.max(-Math.PI,Math.min(Math.PI,yaw));
pitch = drag[2]+(mouse[1]-drag[0][1])/50;
pitch = Math.max(-Math.PI/2,Math.min(Math.PI/2,pitch));
' options.tag '.turntable(yaw,pitch);
gyaw = yaw;
gpitch = pitch;
}
});
']
if options.arrows
jsData = [jsData '
$("body").keydown(function(e) {
	pitch = 0;
	yaw = 0;
	if(e.keyCode == 37) {
		yaw = -(10)/50;
	}
	else if(e.keyCode == 39) {
		yaw = (10)/50;
	}
	else if(e.keyCode == 38) {
		pitch = (10)/50;
	}
	else if(e.keyCode == 40) {
		pitch = -(10)/50;
	}
	rotate(pitch,yaw)
});
function rotate(p,y){
	gyaw = Math.max(-Math.PI,Math.min(Math.PI,(gyaw-y)));
	gpitch = Math.max(-Math.PI/2,Math.min(Math.PI/2,(gpitch-p)));
	' options.tag '.turntable(gyaw,gpitch);
};
']
end
if ~isempty(options.title)
		jsData = [jsData '
svg.append("text")
.style("font", "' options.titleFont '")
.attr("text-anchor", "' options.titleAnchor '")
.attr("x", ' num2str(options.titleX) ')
.attr("y", 25)
.text("' options.title '");	
']
end	
	if options.save
		html = chartHtml(options, css, [jsData jsFrame], false, options.web)
		filePath = [options.folder '\' options.name '.html']
		fid = fopen(filePath,'w+')
		fprintf(fid,'%s',html)
		fclose(fid)
	end
	if options.show
		sh(filePath)
	end
	
	out.type = '3d graph'
	out.subtype = 'chartCombine'
	out.dataSet = dataSet  % data from heatmap
	out.jsData = jsData
	out.jsFrame = jsFrame
	out.legend = legend
	out.image = image
	out.css = css
	out.tag = options.tag
	out.options = options
	out.divTag = ['<div id="' options.tag '"></div>']	
end