function out = gen3d(x,y,z,options)
	if nargin < 3, error('not enough input arguments'); end

	if iscell(x), xvals = x{1}; else xvals = x; end
	if iscell(y), yvals = y{1}; else yvals = y; end
	if iscell(z), zvals = z{1}; else zvals = z; end
	
	% remove anything that is nan, inf of -inf
	%if ~iscell(zvals), error('pb');end
	
	% handling z with diferent dimensions than x and y
	if size(zvals,1) ~= size(xvals,1), 	zvals = reshape(zvals, size(xvals,1), size(xvals,2)); end
	
	finiteIdx = isfinite(xvals) & isfinite(yvals) & isfinite(zvals)
	xvect = xvals(finiteIdx)
	yvect = yvals(finiteIdx)
	zvect = zvals(finiteIdx)
	
	[minx maxx] = cellminmax(x)
	[miny maxy] = cellminmax(y)
	[minz maxz] = cellminmax(z)
	
	% set options
	if iscell(options) && ~isempty(options), o = options{1}; else o = struct; end
	if isfield(o,'xAxisMin'), minx = o.xAxisMin; end
	if isfield(o,'xAxisMax'), maxx = o.xAxisMax; end
	if isfield(o,'yAxisMin'), miny = o.yAxisMin; end
	if isfield(o,'yAxisMax'), maxy = o.yAxisMax; end
	if isfield(o,'zAxisMin'), minz = o.zAxisMin; end
	if isfield(o,'zAxisMax'), maxz = o.zAxisMax; end
	
	[minx maxx] = axisRange(minx, maxx)
	[miny maxy] = axisRange(miny, maxy)
	[minz maxz] = axisRange(minz, maxz)

	if iscell(options)

		optionsVals = chartOptions(options{1}, minx, maxx, miny, maxy)
		chartType = ['"' optionsVals.type '"']
		if ~isempty(optionsVals.labels)
			txt = optionsVals.labels
			if isfield(txt,'txt'), txtvect = txt.txt; end			
			jsDataLabels = [ sprintf('"%s",',txtvect{1:end-1}) sprintf('"%s"',txtvect{end}) ]
		end
		axes3d = optionsVals.axesNames
		if ~isempty(optionsVals.xAxisName), axes3d{1} = optionsVals.xAxisName; end
		if ~isempty(optionsVals.yAxisName), axes3d{2} = optionsVals.yAxisName; end
		if ~isempty(optionsVals.zAxisName), axes3d{3} = optionsVals.zAxisName; end
		optionsVals.axesNames = axes3d
		if ~isempty(optionsVals.axesNames)
			txt = optionsVals.axesNames
			jsDataAxesNames = [ sprintf('"%s",',txt{1:end-1}) sprintf('"%s"',txt{end}) ]
		end	
		labels = [labels, '[' jsDataLabels ']']
		axesNames = [axesNames, '[' jsDataAxesNames ']']
		markerSize = num2str(optionsVals.markerSize)
		labelsFont = ['"' optionsVals.labelsFont '"']
		markerStroke3d = ['"' optionsVals.markerStroke3d '"']
		markerFill = ['"' optionsVals.markerFill '"']
		opacity = num2str(optionsVals.opacity)
		surfOpacity = num2str(optionsVals.surfOpacity)
		lineWidth = num2str(optionsVals.lineWidth)
		lineStroke = [lineStroke '"' optionsVals.lineStroke '"']
		lineInterpolate = [lineInterpolate '"' optionsVals.lineInterpolate '"']
		for i = 2:numel(options)
			optionsVals = chartOptions(options{i}, minx, maxx, miny, maxy)
			chartType = [chartType, ',"' optionsVals.type '"']
			if ~isempty(optionsVals.labels)
				txt = optionsVals.labels
				if isfield(txt,'txt'), txtvect = txt.txt; end
				jsDataLabels = [ sprintf('"%s",',txtvect{1:end-1}) sprintf('"%s"',txtvect{end}) ]
				labels = [labels, ',' '[' jsDataLabels ']']
			else
				labels = [labels, ',' '['  ']']
			end		
			if ~isempty(optionsVals.axesNames)
				txt = optionsVals.axesNames
				jsDataAxesNames = [ sprintf('"%s",',txt{1:end-1}) sprintf('"%s"',txt{end}) ]
				axesNames = [axesNames, ',' '[' jsDataAxesNames ']']
			else
				axesNames = [axesNames, ',' '['  ']']
			end	
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
		options = options{1}
	end

	options = chartOptions(options, minx, maxx, miny, maxy)
	options.paddingLeft = options.paddingLeft + 40
	options.paddingRight = options.paddingRight + 40
	
	add2Padding = 60*options.zoom
	options.paddingTop = options.paddingTop + add2Padding
	options.paddingBottom = options.paddingBottom + add2Padding
	options.height = options.height + 2*add2Padding
	options.width = options.width*options.zoom
	options.depth = options.depth*options.zoom
	options.height = options.height*options.zoom
	[css jsFrame xf yf] = chartFrame(options)
	
	% temporarily setting jsFrame to empty string
	jsFrame = ''
	% convert data into string format
	data = ''
	xData = ''
	yData = ''
	jsData = ''
	dataSet = ''

	for k = 1:size(zvals,1)
		tmp = sprintf('%f,',zvals(k,:))
		data = [data '['  tmp(1:end-1) '],
']
		tmp = sprintf('%f,',xvals(k,:))
		xData = [xData '['  tmp(1:end-1) '],
']
		tmp = sprintf('%f,',yvals(k,:))
		yData = [yData '['  tmp(1:end-1) '],
']
	end
	
	dataSet = ['[[' xData(1:end-2) '],
[' yData(1:end-2) '],
[' data(1:end-2) ']]
']
	if iscell(z)
		for i = 2:numel(z)
			data = ''
			xData = ''
			yData = ''
			if iscell(x), xvals = x{i}; else xvals = x; end
			if iscell(y), yvals = y{i}; else yvals = y; end
			zvals = z{i}
			for k = 1:size(zvals,1)
				tmp = sprintf('%f,',zvals(k,:))
				data = [data '['  tmp(1:end-1) '],
']
				tmp = sprintf('%f,',xvals(k,:))
				xData = [xData '['  tmp(1:end-1) '],
']
				tmp = sprintf('%f,',yvals(k,:))
				yData = [yData '['  tmp(1:end-1) '],
']
			end
			dataSet = [dataSet ',[[' xData(1:end-2) '],
[' yData(1:end-2) '],
[' data(1:end-2) ']]
']
		end
	end

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
				.attr("viewBox","0 0 ' num2str(max(options.width,options.depth)) ' ' num2str(options.height) '");

var group = svg.append("g").attr("transform", "translate(" + ' num2str(options.paddingLeft) '*zoom + "," + ' num2str(options.paddingTop) '*zoom + ")");

var groupData = {
	showCanvas: showCanvas,
	zoom: zoom,
	tooltip: ' num2str(double(1),0) ',
	labels: labels,
	axesNames: axesNames,
	height: ' num2str(options.height/options.zoom - options.paddingTop - options.paddingBottom) '*zoom,
	width: ' num2str(options.width/options.zoom - options.paddingLeft - options.paddingRight) '*zoom,
	depth: ' num2str(options.depth/options.zoom - options.paddingLeft - options.paddingRight) '*zoom,
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
});']

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
	
options.zAxisMin = minz
options.zAxisMax = maxz
	if options.save
		html = chartHtml(options, css, [jsData, jsFrame], false, options.web)
		filePath = [options.folder '\' options.name '.html']
		fid = fopen(filePath,'w+')
		fprintf(fid,'%s',html)
		fclose(fid)
	end
	if options.show
		sh(filePath)
	end
	
	out.type = 'graph'
	out.subtype = '3d'
	out.css = css
	out.dataSet = dataSet
	out.jsFrame = jsFrame
	out.jsData = jsData
	out.legend = ''
	out.image = ''
	out.tag = options.tag
	out.options = options
	out.divTag = ['<div id="' options.tag '"></div>']

end