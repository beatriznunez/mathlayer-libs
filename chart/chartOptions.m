function out = chartOptions(o, minx, maxx, miny, maxy, miny2, maxy2)

	override('get','chartoptions', o)

	if nargin < 6, miny2 = miny, maxy2 = maxy; end
	
	% colors
	if ~isfield(o,'colors'), o.colors = colorSet(1); end
	if ~isfield(o,'areaColors'), o.areaColors = colorSet(1); end
	% folder, filename,overlay
	if ~isfield(o,'web'), o.web = false; end
	if ~isfield(o,'type'), o.type = ''; end
	if ~isfield(o,'folder'), o.folder = pwd; end
	if ~isfield(o,'name'), o.name = 'mathlayer'; end
	if ~isfield(o,'overlay'), o.overlay = false; end
	% display
	if ~isfield(o,'show'), o.show = true; end
	if ~isfield(o,'save'), o.save = o.show; elseif o.show, o.save = true; end
	if ~isfield(o,'zoom'), o.zoom = 0.8; end
	% svg tag
	if ~isfield(o,'tag'), o.tag = ['c' num2str(inc,0)]; end
	% title
	notitle = false
	if ~isfield(o,'title'), o.title = ''; notitle = true; end
	if ~isfield(o,'titleFont'), o.titleFont = 'bold 0.85em arial'; end
	if ~isfield(o,'titleAnchor'), o.titleAnchor = 'middle'; end
	if ~isfield(o,'pageTitle'), o.pageTitle = 'mathlayer charts'; end
	% body
	if ~isfield(o,'bodyColor'), o.bodyColor = 'white'; end
	% frame
	if ~isfield(o,'backgroundColor'), o.backgroundColor = 'white'; end
	if ~isfield(o,'width'), o.width = 600; end
	if o.width <= 1
		o.width = o.width*100
		o.percw = o.width
	else
		o.percw = 100
	end
	if ~isfield(o,'gw')
		if o.width <= 100
			o.gw = [num2str(o.width) '%']
			o.width = 600
		else
			o.gw = [num2str(o.width) 'px']
		end
	end
	if ~isfield(o,'depth'), o.depth = 600; end
	if ~isfield(o,'height'), o.height = 450; end
	if ~isfield(o,'showCanvas'), o.showCanvas = true; end
	% legend
	if ~isfield(o,'legendType'), o.legendType = 'default'; end
	if ~isfield(o,'legendLabels'), o.legendLabels = cell(0,0); end
	if ~isfield(o,'legendFont'), o.legendFont = '12px arial'; end
	if ~isfield(o,'showLegend'), o.showLegend = ~isempty(o.legendLabels); end
	if ~isfield(o,'rectLegend'), o.rectLegend = true; end
	%if ~isfield(o,'showLegend'), o.showLegend = true; end
	if ~isfield(o,'legendX'), o.legendX = []; end
	if ~isfield(o,'legendY'), o.legendY = []; end
	if ~isfield(o,'legendOpacity'), o.legendOpacity = 0.9; end
	if ~isfield(o,'legendStroke'), o.legendStroke = 'black'; end
	if ~isfield(o,'legendColor'), o.legendColor = 'white'; end
	% image
	if isfield(o,'bkgImage') || (isfield(o,'image') && ~strcmp(o.image,'white')), o.canvasOpacity = 0, o.backgroundColor = 'url(#pic1)'; end
	if isfield(o,'canvasImage'), o.image = o.canvasImage, o.canvasColor = 'url(#pic1)'; end
	% if isfield(o,'bkgImage'), o.image = o.bkgImage; end
	if ~isfield(o,'image'), o.image = 'white'; end
	if ~isfield(o,'showImage'), o.showImage = false; end
	if ~isfield(o,'imageOpacity'), o.imageOpacity = 0.4; end
	% canvas
	if ~isfield(o,'canvasOpacity'), o.canvasOpacity = 1; end
	if ~isfield(o,'canvasColor'), o.canvasColor = 'white'; end
	if ~isfield(o,'paddingLeft'), o.paddingLeft = 80; end
	if ~isfield(o,'paddingBottom'), o.paddingBottom = 80; end
	if ~isfield(o,'paddingRight'), o.paddingRight = 80; end
	if ~isfield(o,'paddingTop'), o.paddingTop = notitle * 30 + ~notitle * 80; end
	if ~isfield(o,'titleX'), o.titleX = (o.width-o.paddingRight-o.paddingLeft)/2; end
	if ~isfield(o,'titleY'), o.titleY = 20; end
	% canvas gradient
	if ~isfield(o,'gradient'), o.gradient = false; end
	if ~isfield(o,'gradientColor1'), o.gradientColor1 = '#FF5C33'; end
	if ~isfield(o,'gradientColor2'), o.gradientColor2 = '#CCE0F5'; end	% canvas gradient
	% 3d
	if ~isfield(o,'pitch'), o.pitch = 0.5; end
	if ~isfield(o,'yaw'), o.yaw = -0.5; end
	if ~isfield(o,'markerStroke3d'), o.markerStroke3d = 'default'; end
	if ~isfield(o,'axesNames'), o.axesNames = {'','',''}; end
	if ~isfield(o,'zAxisName'), o.zAxisName = ''; end
	if ~isfield(o,'arrows'), o.arrows = true; end
	% axis
	if ~isfield(o,'axisSpacing'), o.axisSpacing = 0; end
	if ~isfield(o,'useSecondaryAxis'), o.useSecondaryAxis = false; end
	if ~isfield(o,'showSecondaryAxis'), o.showSecondaryAxis = o.useSecondaryAxis; end
	if ~isfield(o,'xAxisShow'), o.xAxisShow = true; end
	if ~isfield(o,'yAxisShow'), o.yAxisShow = true; end
	if ~isfield(o,'showSquaredCanvas'), o.showSquaredCanvas = false; end
	if ~isfield(o,'showGrid'), o.showGrid = false; elseif isequal(o.showGrid,1), o.showGridX = true, o.showGridY = true; end
	if ~isfield(o,'showGridX'), o.showGridX = false; end
	if ~isfield(o,'showGridY'), o.showGridY = false; end
	
	if ~isfield(o,'xAxisFont'), o.xAxisFont = '1em arial'; end
	if ~isfield(o,'yAxisFont'), o.yAxisFont = '1em arial'; end
	if ~isfield(o,'y2AxisFont'), o.y2AxisFont = '1em arial'; end
	
	if ~isfield(o,'xAxisColor'), o.xAxisColor = 'black'; end
	if ~isfield(o,'yAxisColor'), o.yAxisColor = 'black'; end
	if ~isfield(o,'y2AxisColor'), o.y2AxisColor = 'black'; end
	
	if ~isfield(o,'xAxisNameFont'), o.xAxisNameFont = 'bold 0.9em arial'; end
	if ~isfield(o,'yAxisNameFont'), o.yAxisNameFont = 'bold 0.9em arial'; end
	if ~isfield(o,'y2AxisNameFont'), o.y2AxisNameFont = 'bold 0.9em arial'; end

	if ~isfield(o,'xAxisNameColor'), o.xAxisNameColor = 'black'; end
	if ~isfield(o,'yAxisNameColor'), o.yAxisNameColor = 'black'; end
	if ~isfield(o,'y2AxisNameColor'), o.y2AxisNameColor = 'black'; end
	
	if ~isfield(o,'xAxisName'), o.xAxisName = ''; end
	if ~isfield(o,'yAxisName'), o.yAxisName = ''; end
	if ~isfield(o,'y2AxisName'), o.y2AxisName = ''; end
	
	if ~isfield(o,'xAxisTicks'), o.xAxisTicks = 11; end
	if ~isfield(o,'yAxisTicks')
		if isfield(o,'vertical'), o.yAxisTicks = 9, else o.yAxisTicks = 11; end
	end
	if ~isfield(o,'y2AxisTicks'), o.y2AxisTicks = 11; end
	
	if ~isfield(o,'xAxisMin'), o.xAxisMin = minx; end
	if ~isfield(o,'yAxisMin'), o.yAxisMin = miny; end
	if ~isfield(o,'y2AxisMin'), o.y2AxisMin = miny2; end
	
	if ~isfield(o,'xAxisMax'), o.xAxisMax = maxx; end
	if ~isfield(o,'yAxisMax'), o.yAxisMax = maxy; end
	if ~isfield(o,'y2AxisMax'), o.y2AxisMax = maxy2; end
	
	if ~isfield(o,'xAxisPosition'), o.xAxisPosition = '0," + (h - pb + as) + "'; end
	if ~isfield(o,'yAxisPosition'), o.yAxisPosition = '" + (pl - as) + ",0'; end
	
	if ~isfield(o,'xAxisFormat'), o.xAxisFormat = ''; end
	if ~isfield(o,'yAxisFormat'), o.yAxisFormat = ''; end
	if ~isfield(o,'zAxisFormat'), o.zAxisFormat = ''; end
	if ~isfield(o,'y2AxisFormat'), o.y2AxisFormat = ''; end
	
	if ~isfield(o,'xAxisScale'), o.xAxisScale = 'Linear'; end
	if ~isfield(o,'yAxisScale'), o.yAxisScale = 'Linear'; end
	if ~isfield(o,'y2AxisScale'), o.y2AxisScale = 'Linear'; end
	
	if ~isfield(o,'xAxisRotate'), o.xAxisRotate = 0; end
	if ~isfield(o,'yAxisRotate'), o.yAxisRotate = 0; end
	if ~isfield(o,'y2AxisRotate'), o.y2AxisRotate = 0; end
	
	if ~isfield(o,'xAxisTranslate'), o.xAxisTranslate = '0'; end
	if ~isfield(o,'yAxisTranslate'), o.yAxisTranslate = '0'; end
	if ~isfield(o,'y2AxisTranslate'), o.y2AxisTranslate = '0'; end
	
	if ~isfield(o,'xAxisDateFormat'), o.xAxisDateFormat = '%Y-%m-%d'; end
	if ~isfield(o,'yAxisDateFormat'), o.yAxisDateFormat = '%Y-%m-%d'; end
	if ~isfield(o,'y2AxisDateFormat'), o.y2AxisDateFormat = '%Y-%m-%d'; end
	if ~isfield(o,'markerStrFormDate'), o.markerStrFormDate = '%Y-%m-%d'; end
	
	if ~isfield(o,'xAxisLabels'), o.xAxisLabels = ''; end
	if ~isfield(o,'yAxisLabels'), o.yAxisLabels = ''; end
	if ~isfield(o,'y2AxisLabels'), o.y2AxisLabels = ''; end
	if ~isempty(o.xAxisLabels), o.xAxisTicks = max(size(o.xAxisLabels))-1; end
	if ~isempty(o.yAxisLabels), o.yAxisTicks = max(size(o.yAxisLabels))-1; end
	
	xAxisTextAnchor = 'middle'
	if o.xAxisRotate > 10, xAxisTextAnchor = 'end'
	elseif o.xAxisRotate < -10, xAxisTextAnchor = 'start'; end
	if ~isfield(o,'xAxisTextAnchor'), o.xAxisTextAnchor = xAxisTextAnchor; end
	if ~isfield(o,'yAxisTextAnchor'), o.yAxisTextAnchor = 'end'; end
	if ~isfield(o,'y2AxisTextAnchor'), o.y2AxisTextAnchor = 'start'; end
	% data
	if ~isfield(o,'opacity'), o.opacity = 1; end
	if ~isfield(o,'dataColor'), o.dataColor = o.colors(1); end
	% marker
	if ~isfield(o,'markerSize'), o.markerSize = 3; end
	if ~isfield(o,'markerFill'), o.markerFill = 'rgba(255,0,0,0)'; end
	if ~isfield(o,'markerStroke'), o.markerStroke = o.colors; else o.dataColor = o.markerStroke; end
	if ~isfield(o,'markerShape'), o.markerShape = 'd3.symbolCircle'; else o.markerShape = ['d3.symbol' o.markerShape]; end
	% line
	if ~isfield(o,'lineWidth'), o.lineWidth = 0; end
	if ~isfield(o,'lineStroke'), o.lineStroke = o.colors{1}; else o.dataColor = o.lineStroke; end
	if ~isfield(o,'lineFill'), o.lineFill = 'none'; end
	if ~isfield(o,'lineInterpolate'), o.lineInterpolate = 'd3.curveLinear'; else o.lineInterpolate = ['d3.curve' o.lineInterpolate]; end
	if ~isfield(o,'dashArray'), o.dashArray = ''; end
	% surf
	if ~isfield(o,'surfOpacity'), o.surfOpacity = o.opacity; end
	% area
	if ~isfield(o,'areaStroke'), o.areaStroke = ''; end
	if ~isfield(o,'areaAboveStroke'), o.areaAboveStroke = ''; else o.dataColor = o.areaAboveStroke; end
	if ~isfield(o,'areaBelowStroke'), o.areaBelowStroke = ''; end
	if ~isfield(o,'areaOpacity'), o.areaOpacity = 1; end
	if ~isfield(o,'areaBase'), o.areaBase = 0; end
	% bars
	if ~isfield(o,'barCount'), o.barCount = 0; end
	if ~isfield(o,'barStroke'), o.barStroke = 'black'; end
	if ~isfield(o,'barStrokeWidth'), o.barStrokeWidth = 1; end
	if ~isfield(o,'barFill'), o.barFill = ''; else o.dataColor = o.barFill; end
	if ~isfield(o,'barFillPos'), o.barFillPos = o.barFill; end
	if ~isfield(o,'barFillNeg'), o.barFillNeg = o.barFill; end
	if ~isfield(o,'barWidth'), o.barWidth = []; end
	if ~isfield(o,'barWidthScale'), o.barWidthScale = false; end % transform from values to pixels
	if ~isfield(o,'barBase'), o.barBase = 0; end
	if ~isfield(o,'barOpacity'), o.barOpacity = 1; end
	if ~isfield(o,'barStack'), o.barStack = false; end
	if ~isfield(o,'barTranslate'), o.barTranslate = 0; end
	%histogram
	if ~isfield(o,'horizontal'), o.horizontal = false; end
	% mouse
	if ~isfield(o,'xName'), o.xName = 'X'; end
	if ~isfield(o,'yName'), o.yName = 'Y'; end
	if ~isfield(o,'xFormat'), o.xFormat = '.4f'; end
	if ~isfield(o,'yFormat'), o.yFormat = '.4f'; end
	if ~isfield(o,'y2Format'), o.y2Format = '.4f'; end
	if ~isfield(o,'tooltip'), o.tooltip = false; end
	if ~isfield(o,'tooltipPosition'), o.tooltipPosition = 'mouse'; end
	if ~isfield(o,'hover'), o.hover = []; end
	% labels
	if ~isfield(o,'labels'), o.labels = []; end
	if ~isfield(o,'labelsFont'), o.labelsFont = '0.7em arial'; end
	if ~isfield(o,'labelsAnchor'), o.labelsAnchor = 'start'; end
	% animation
	if ~isfield(o,'timelapse'), o.timelapse = 500; end
	if ~isfield(o,'navbar'), o.navbar = true; end
	if ~isfield(o,'navbarWidth'), o.navbarWidth = 520; end
	if ~isfield(o,'navbarPosition'), o.navbarPosition = 'bottom'; end
	if ~isfield(o,'animPaused'), o.animPaused = 'false'; end
	% heatmap
	if ~isfield(o,'colorScale'), o.colorScale = {'blue','cyan','yellow','red'}; end
	if ~isfield(o,'rangeMin'), o.rangeMin = 100/(size(o.colorScale,2)-1); end
	if ~isfield(o,'rangeMax'), o.rangeMax = 100/(size(o.colorScale,2)-1); end
	if ~isfield(o,'legendTicks'), o.legendTicks = 5; end
	if ~isfield(o,'legendFormat'), o.legendFormat = '.1f'; end
	if ~isfield(o,'gradientHM'), o.gradientHM = false; end
	if ~isfield(o,'xAxisPos'), o.xAxisPos = 'Bottom'; end
	if ~isfield(o,'yAxisPos'), o.yAxisPos = 'Left'; end
	% statistics
	if ~isfield(o,'confTable'), o.confTable = false; end
	if ~isfield(o,'copyData'), o.copyData = ''; end
	% waterfall
	if ~isfield(o,'barValueFormat'), o.barValueFormat = '.0f'; end
	if ~isfield(o,'refLines'), o.refLines = false; end
	if ~isfield(o,'showVals'), o.showVals = false; end
	% pie
	if ~isfield(o,'pieVal'), o.pieVal = 'out'; end	
	if ~isfield(o,'pieValue'), o.pieValue = ''; end	
	if ~isfield(o,'explode'), o.explode = []; end	
	% table
	if ~isfield(o,'styleTable'), o.styleTable = ''; end
	if ~isfield(o,'styleTableth'), o.styleTableth = ''; end
	if ~isfield(o,'styleTabletd'), o.styleTabletd = ''; end
	if ~isfield(o,'styleTabletr'), o.styleTabletr = ''; end
	if ~isfield(o,'tableVN'), o.tableVN = false; end
	if ~isfield(o,'tableRN'), o.tableRN = false; end
	if ~isfield(o,'tdAlign'), o.tdAlign = 'center'; end
	% timeline
	if ~isfield(o,'vertical')
		o.vertical = false
	else 
		if o.vertical
			o.xAxisRotate = 90
			o.yAxisRotate = 90
			o.y2AxisRotate = 90
			o.xAxisTextAnchor = 'end'
			o.yAxisTextAnchor = 'middle'
			o.xAxisTranslate = '-8,-12'
			o.yAxisTranslate = '12,-12'
			o.y2AxisTranslate = '-16,12'
			if ~isfield(o,'translate'), o.translate = [num2str((o.height-o.width)/2) ',' num2str((o.width-o.height)/2)]; end
			if ~isfield(o,'rotate'), o.rotate = 90; end
		end
	end
	if ~isfield(o,'translate'), o.translate = '0'; end
	if ~isfield(o,'rotate'), o.rotate = 0; end
	
	out = o
end