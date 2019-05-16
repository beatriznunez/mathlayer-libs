function out = gen2dVect(x,y,o)
	
	% convert data into 'javascript readable string' and modify some options
	[jsData o] = getdata(x,y,o)
	
	% TODO: adapt to the new data 
	[css jsFrame xf yf] = chartFrame(o)
	if strcmp(o.type,'treemap'), jsFrame = ''; end
	
	% to display only content inside axes
	yy = y(isfinite(y))
	if strcmp(o.yAxisScale,'Log')
		miny = log(min(min(y)))
		axismin = log(o.yAxisMin)
		maxy = log(max(max(y)))
		axismax = log(o.yAxisMax)
	else
		miny = min(min(yy))
		axismin = o.yAxisMin
		maxy = max(max(yy))
		axismax = o.yAxisMax
	end
	if (~isempty(miny) && ~isempty(maxy)) && (~isinf(miny) && ~isinf(maxy))
		if ((maxy > axismax) || (miny < axismin))
			clip = chartClipPath(o)
			jsData = [jsData clip]
		end
	end

	% add function code for each kind of graph and element in graph (labels, legend...)
	% AREA
	if numel(o.areaAboveStroke) > 0 % show area
		js = chartd3Code('showArea',o)
		jsData = [jsData js]
	end
	
	% LINES
	if o.lineWidth > 0 
		js = chartd3Code('showLine',o)
		jsData = [jsData js]
	end
	
	% MARKERS
	if max(o.markerSize) > 0 
		js = chartd3Code('showMarkers',o)
		jsData = [jsData js]
	end
	
	% BARS
	if o.barCount > 0
		js = chartd3Code('showBars',o)
		jsData = [jsData js]
	end
	
	% HEATMAP
	if strcmp(o.type,'heatmap')
		js = chartd3Code('heatmap',o)
		jsData = [jsData js]
	end
	
	% PIE
	if strcmp(o.type,'pie')
		js = chartd3Code('pie',o)
		jsData = [jsData js]
	end
	
	% REFERENCE LINES
	if o.refLines
		js = chartd3Code('refLines',o)
		jsData = [jsData js]
	end
	
	% LABELS
	if ~isempty(o.labels)
		js = chartd3Code('showLabels',o)
		jsData = [jsData js]
	end
	
	% SHOW VALUES
	if (o.showVals)
		js = chartd3Code('showValues',o)
		jsData = [jsData js]
	end
	
	% LEGEND
	if o.showLegend
		legend = chartLegend(y,o)
	else
		legend = ''
	end
	
	if o.save
		html = chartHtml(o,css,[jsFrame jsData legend],false,o.web)		
		filePath = [o.folder '\' o.name '.html']
		fid = fopen(filePath,'w+')
		fprintf(fid,'%s',html)
		fclose(fid)
	end
	if o.show
		sh(filePath)
	end
	
	out = struct
	out.type = o.type
	out.subtype = '2d'
	out.css = css
	out.jsFrame = jsFrame
	out.jsData = jsData
	out.legend = legend
	out.image = ''
	out.tag = o.tag
	out.options = o
	out.divTag = ['<div id="' o.tag '"></div>']
		
end