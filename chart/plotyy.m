function [out] = plotyy(x1, y1, x2, y2, o1, o2, og)
	
	% check arguments
	if nargin < 4, error('not enough input arguments'); end
	if nargin < 6, o2 = o1; end
	if nargin < 7, og = o1; end
	
	[x1 y1] = chartCheckArgs(x1,y1,o1)
	[x2 y2] = chartCheckArgs(x2,y2,o2)
	
	% default plot options
	o1.type = 'plotyy'
	o2.type = 'plotyy'
	og.type = 'plotyy'
	og.overlay = true;
	o1.show = false
	o2.show = false
	o1.colors = colorSet(1)
	o2.colors = colorSet(2)
	o2.useSecondaryAxis = true
	if ~isfield(o1,'markerShape') && ~isfield(o1,'markerSize'), o1.markerShape = 'Line'; end
	if ~isfield(o2,'markerShape') && ~isfield(o2,'markerSize'), o2.markerShape = 'Line'; end
	if ~isfield(o1,'dashArray'), o1.dashArray = '1 0'; end
	if ~isfield(o2,'dashArray'), o2.dashArray = '1 0'; end
	if ~isfield(o1,'markerSize'), o1.markerSize = 0; end
	if ~isfield(o2,'markerSize'), o2.markerSize = 0; end
	if ~isfield(o2,'lineStroke'), o1.lineStroke = o1.colors{1}; end
	if ~isfield(o2,'lineStroke'), o2.lineStroke = o2.colors{1}; end
	if ~isfield(o2,'yAxisColor'), o1.yAxisColor = o1.lineStroke; end
	if ~isfield(o2,'y2AxisColor'), o2.y2AxisColor = o2.lineStroke; end
	if ~isfield(o1,'lineWidth'), o1.lineWidth = 1; end
	if ~isfield(o2,'lineWidth'), o2.lineWidth = 1; end
	
	% set options without considering infinite values
	[minx1 maxx1]=axisRange(min(min(x1(isfinite(x1)))), max(max(x1(isfinite(x1)))))
	[minx2 maxx2]=axisRange(min(min(x2(isfinite(x2)))), max(max(x2(isfinite(x2)))))
	[miny1 maxy1]=axisRange(min(min(y1(isfinite(y1)))), max(max(y1(isfinite(y1)))))
	[miny2 maxy2]=axisRange(min(min(y2(isfinite(y2)))), max(max(y2(isfinite(y2)))))
	if isfield(og,'vertical') && og.vertical, o1.vertical = true, o2.vertical = true; end
	o1 = chartOptions(o1, minx1, maxx1, miny1, maxy1, miny2, maxy2)
	o2 = chartOptions(o2, minx2, maxx2, miny1, maxy1, miny2, maxy2)
	
	% overriden options	
	if minx1<=0 & strcmp(o1.xAxisScale,'Log'), o1.xAxisMin = min(min(x1(x1>0))); end
	if miny1<=0 & strcmp(o1.yAxisScale,'Log'), o1.yAxisMin = min(min(y1(y1>0))); end
	if minx2<=0 & strcmp(o2.xAxisScale,'Log'), o2.xAxisMin = min(min(x2(x2>0))); end
	if miny2<=0 & strcmp(o2.y2AxisScale,'Log'), o2.y2AxisMin = min(min(y2(y2>0))); end
	
	out = chartCombine({gen2d(x1,y1,o1),gen2d(x2,y2,o2)},og)
end