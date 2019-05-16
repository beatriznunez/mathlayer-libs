function out = chartCombine(c, options)
	
	if ~iscell(c) | numel(c) == 0, error("first argument must be a non empty cell array containing graphs scripts"); end
	if nargin < 2, options.type = 'default'; end
	currentGraph = c{1}
	tmpOpt = currentGraph.options
	xMin = tmpOpt.xAxisMin
	xMax = tmpOpt.xAxisMax
	yMin = tmpOpt.yAxisMin
	yMax = tmpOpt.yAxisMax
	% set options
	o = chartOptions(options, xMin, xMax, yMin, yMax)
	legend = ''
	image = ''
	tmpOpts = tmpOpt
	tmpOpts.type = 'default'
	[css] = chartFrame(tmpOpts)
	nr = size(c,1)
	nc = size(c,2)
	jsData = ''
	jsFrame = ''
	dataSet = ''
	if ~o.overlay
		isass = strcmp('assemble',cellextract(c,'type'))
		isanim = strcmp('animate',cellextract(c,'type'))
		ishtml = strcmp('html',cellextract(c,'type'))
		istab = strcmp('table',cellextract(c,'type'))
		isother = ~isass & ~isanim & ~ishtml & ~istab
		jsData = cast(char(zeros(nr*nc,0)),'string array')
		htmlprefix = cast(char(zeros(nr*nc,0)),'string array')
		cass = c(isass)
		canim = c(isanim)
		chtml = c(ishtml)
		ctab = c(istab)
		cother = c(isother)
		nass = numel(cass)
		nanim = numel(canim)
		nhtml = numel(chtml)
		ntab = numel(ctab)
		nother = numel(cother)
		is3d = cellfun(@(x) strcmpi(x.subtype,'3d'), c)
		if any(is3d)
			o.tags = cellfun(@(x) x.tag, c(is3d), 'uniformoutput', false)
		end
		[navbar navbarid animscript closeanim] = chartAnimate(o)
		
		if nother > 0
			cellsops = cellfun(@(x) x.options, cother, 'uniformoutput', false)
			cellswidth = cellfun(@(x) struct('w',num2str(x.width)), cellsops, 'uniformoutput', false)
			cellsheight = cellfun(@(x) struct('h',num2str(x.height)), cellsops, 'uniformoutput', false)
			cellsrate = cellfun(@(x) struct('r',num2str(x.height/x.width)), cellsops, 'uniformoutput', false)
			cellsperc = cellfun(@(x) struct('r',num2str(x.percw)), cellsops, 'uniformoutput', false)
			if strcmp(o.type,'animate')
				htmlprefix(isother) = strcat('<div id="',cellextract(cother,'tag'),'" style="max-width:',...
								cellextract(cellswidth,'w'),'px;width:', cellextract(cellsperc,'r'),...
								'%;height:calc(' , cellextract(cellsperc,'r'), 'vw * ',...
								cellextract(cellsrate,'r'),');max-height:',...
								cellextract(cellsheight,'h'),'px;"></div>')
				jsData(isother) = strcat(repmat('
<script type="text/javascript">',nother,1), ...
								cellextract(cother,'jsFrame'),...
								cellextract(cother,'jsData'),...
								cellextract(cother,'legend'),...
								cellextract(cother,'image'),...
								repmat('</script>',nother,1))
								
			else
				
				
				jsData(isother) = strcat('<div id="',cellextract(cother,'tag'),'" style="max-width:',...
								cellextract(cellsperc,'r'),'%;width:', cellextract(cellsperc,'r'),...
								'%;height:calc(' , cellextract(cellsperc,'r'), 'vw * ',...
								cellextract(cellsrate,'r'),');max-height:',...
								cellextract(cellsheight,'h'),'px;"></div>',...
								repmat('
<script type="text/javascript">',nother,1), ...
								cellextract(cother,'jsFrame'),...
								cellextract(cother,'jsData'),...
								cellextract(cother,'legend'),...
								cellextract(cother,'image'),...
								repmat('</script>',nother,1))
				if strcmp(o.type,'assemble')
					tmpOpt.type = 'assemble'
					[css] = chartFrame(tmpOpt)
				end
			end
		end
		if nanim >  0		
			tmpOpt.type = 'animate'
			[cssan] = chartFrame(tmpOpt)
			css = [css cssan]
			jsData(isanim) = strcat(repmat(['<div style="max-width:' num2str(tmpOpt.width) 'px;display:inline;float:left">'],nanim,1),cellextract(canim,'jsData'),repmat('</div>',nanim,1))
		end
		if nass >  0
			if ~any(strcmp('plotroc',cellextract(c,'subtype')))
				tmpOpt.type = 'assemble'
				[cssas] = chartFrame(tmpOpt)
				css = [css cssas]
			end
			cellassop = cellfun(@(x) x.options, cass, 'uniformoutput', false)
			cellasswidth = cellfun(@(x) struct('w',x.width), cellassop, 'uniformoutput', false)
			cellassgw = cellfun(@(x) struct('w',x.gw), cellassop, 'uniformoutput', false)
			cellassper = cellfun(@(x) struct('p',num2str(x.percw)), cellassop, 'uniformoutput', false)

			jsData(isass) = strcat(repmat('<div  style="max-width:',nass,1),cellextract(cellassper,'p'),repmat('%;width:',nass,1),cellextract(cellassper,'p'),repmat('%;display:inline;float:left">',nass,1),cellextract(cass,'jsData'),repmat('</div>',nass,1))
		end
		if nhtml > 0
			tmpOpt.type = 'html'
			[csshtml] = chartFrame(tmpOpt)
			css = [css csshtml]
			%htmlprefix(ishtml) = cellextract(chtml,'divTag')
			jsData(ishtml) = cellextract(chtml,'divTag')
			%jsData(ishtml) = strcat(repmat('<div>',nhtml,1),cellextract(chtml,'divTag'),repmat('</div>',nhtml,1))			
		end
		if ntab > 0
			tmpOpt.type = 'table'
			[csstb] = chartFrame(tmpOpt)
			css = [css csstb]
			jsData(istab) = cellextract(ctab,'divTag')		
		end
		if strcmp('animate',o.type) && any(strcmp('assemble',cellextract(c,'type')))
			tmpOpt.type = 'animate'
			tmpOpt.subtype = 'animate'
			if ~any(strcmp('plotroc',cellextract(c,'subtype')))
				[css] = chartFrame(tmpOpt)
			end
		end
		if strcmp('top',o.navbarPosition)
			jsData = sprintf('%s%s%s%s%s%s',...
				navbar,...
				navbarid,...
				htmlprefix,...
				jsData,...
				closeanim,...
				animscript)
		else
			jsData = sprintf('%s%s%s%s%s%s',...
				navbarid,...
				htmlprefix,...
				jsData,...
				closeanim,...
				navbar,...
				animscript)
		end
	else % overlay
		
		o.gw = [num2str(tmpOpt.width) 'px']
		if ~isempty(o.title) % set title defined in overlay
			tmpOpt.title = o.title
			tmpOpt.titleFont = o.titleFont
			tmpOpt.titleAnchor = o.titleAnchor
			tmpOpt.titleX = o.titleX
		end
	
		hm = cellfun(@(x) strcmp(x.type,'heatmap'),c) % vector identifying heatmaps in c
		hashm = any(any(hm))
		if sum(sum(hm)) > 1, error('cannot overlay more than one heatmap'); end
		if ~hm(1) && hashm, error('heatmap has to be on first position'); end
		if hashm
		
			if isempty(o.tag)
				o.tag = ['c' num2str(inc,0)]
			end
			tmpOpt.tag = o.tag
			
			co = cellfun(@(x) x.options,c(2:end),'uniformoutput',false)
			cminx = min(cellfun(@(x) x.xAxisMin,co))
			cmaxx = max(cellfun(@(x) x.xAxisMax,co))
			cminy = min(cellfun(@(x) x.yAxisMin,co))
			cmaxy = max(cellfun(@(x) x.yAxisMax,co))
			
			% set xMin, xMax, yMin and yMax on heatmap to rescale overlayed graphs
			if isfield(tmpOpt,'cminx'), cminx = tmpOpt.cminx; end
			if isfield(tmpOpt,'cmaxx'), cmaxx = tmpOpt.cmaxx; end
			if isfield(tmpOpt,'cminy'), cminy = tmpOpt.cminy; end
			if isfield(tmpOpt,'cmaxy'), cmaxy = tmpOpt.cmaxy; end
			
			% set a scale to adapt to heatmap canvas
			scale = ['
	var xScale = d3.scaleLinear().domain([' num2str(cminx) ', ' num2str(cmaxx) ']).range([pl, w - pr]);
	var yScale = d3.scaleLinear().domain([' num2str(cminy) ', ' num2str(cmaxy) ']).range([h - pb, pt]);	
	']
			legend = chartLegend(x, tmpOpt)
		else % no heatmap
			cAux = c
			if isempty(o.tag)
				o.tag = ['cAux' num2str(inc,0)]
			end
			tmpOpt.tag = o.tag
			% get global min and max for x-axis
			co = cellfun(@(x) x.options,cAux,'uniformoutput',false)
			cminx = min(cellfun(@(x) x.xAxisMin,co))
			cmaxx = max(cellfun(@(x) x.xAxisMax,co))
			
			% look for secondary axis
			cshowSecondaryAxis = max(cellfun(@(x) x.showSecondaryAxis,co))		
			% [~,position] = ismember(1, cellfun(@(x) x.showSecondaryAxis,co))
			position = cellfun(@(x) x.showSecondaryAxis,co)
			ma = []
			mi = []
			ca = {}
			
			% get global min and max for y2-axis
			jj=1
			j=1
			for ii = 1:length(position)
				if position(ii) ~= 0
					sety2 = cAux{jj}
					sety2Axis = sety2.options
					ca{j} = sety2Axis.y2AxisColor
					ma = [ma sety2Axis.y2AxisMax]
					mi = [mi sety2Axis.y2AxisMin]
					if (prod(position) == 0), cAux(jj) = {}; end
					j=j+1
				else
					jj=jj+1
				end
			end
			tmpOpt.y2AxisMin = min(mi)
			tmpOpt.y2AxisMax = max(ma)
			if ~isempty(ca), tmpOpt.y2AxisColor = ca{1}; end
			
			% get global min and max for y-axis
			co = cellfun(@(x) x.options,cAux,'uniformoutput',false)
			cminy = min(cellfun(@(x) x.yAxisMin,co))
			cmaxy = max(cellfun(@(x) x.yAxisMax,co))		
			
			tmpOpt.xAxisMin = cminx
			tmpOpt.xAxisMax = cmaxx
			tmpOpt.yAxisMin = cminy
			tmpOpt.yAxisMax = cmaxy
			tmpOpt.showSecondaryAxis = cshowSecondaryAxis
			
		end
		[css jsFrame] = chartFrame(tmpOpt)
		colors = cell(1,(nr*nc))
		a=1
		b=1
		for i = 1:nr*nc
			currentGraph = c{i}
			tmp = currentGraph.options
			if iscell(tmp.dataColor)  			 % if the graph has more than one line(chartCombine)
				for j = 1:numel(tmp.dataColor)
					colors{i-b+a} = tmp.dataColor{j}
					Fill{i-b+a} = tmp.markerFill
					if iscell(tmp.markerSize)
						markerSize{i-b+a} = max(cellfun(@(x) (x), tmp.markerSize))
					else
						markerSize{i-b+a} = tmp.markerSize
					end
					markerStroke{i-b+a} = tmp.markerStroke{j}
					
					if ~isempty(tmp.dashArray)
						dashArray{i-b+a} = tmp.dashArray
					else
						dashArray(i-b+a) = {''}
					end
					if ~isempty(tmp.markerShape)
						markerShape{i-b+a} = tmp.markerShape
					end
					a=a+1
				end
				b=b+1
				ms = max(cellfun(@(x) (x), markerSize))
				markerSize{i} = ms
			else
				colors{i-b+a} = tmp.dataColor
				Fill{i-b+a} = tmp.markerFill
				markerSize{i-b+a} = tmp.markerSize
				if iscell(tmp.markerStroke)
					markerStroke{i-b+a} = tmp.markerStroke{1}
				else 
					markerStroke{i-b+a} = tmp.markerStroke
				end
				if ~isempty(tmp.dashArray)
					dashArray{i-b+a} = tmp.dashArray
				else
					dashArray(i-b+a) = {''}
				end
				if ~isempty(tmp.markerShape)
					markerShape{i-b+a} = tmp.markerShape
				end
			end
			jsData = [jsData scale currentGraph.jsData]
		end
		o.dashArray = dashArray
		o.markerShape = markerShape
		o.markerStroke = markerStroke
		o.dataColor = colors
		o.Fill = Fill
		o.markerSize = markerSize
		
		if o.showLegend
			if strcmp('area',tmp.type) | strcmp(tmp.type, 'bar')
				for i = 1:numel(colors)
					[a idx] = ismember(1,strcmp(colors{i},colors(i+1:end)))
					if idx ~= 0, s = [s idx+i]; end
				end
				colors(s)={}
				n = numel(colors)
			else
				n = numel(markerShape)
			end
			legend = chartLegend(n, o)
		end
		if o.showImage
			image = chartImage(o)
		end
	end
	if o.save 
		html = chartHtml(o, css, [jsFrame jsData legend image], true, o.web)
		filePath = [o.folder '\' o.name '.html']	
		fid = fopen(filePath,'w+')
		fprintf(fid,'%s',html)
		fclose(fid)
	end
	if o.show 
		sh(filePath)
	end
	
	out.type = o.type
	if any(strcmp('plotroc',cellextract(c,'type')))
		out.subtype = 'plotroc'
	else
		out.subtype = 'chartCombine'
	end
	out.jsData = jsData
	out.jsFrame = jsFrame
	out.legend = legend
	out.image = image
	out.css = css
	out.tag = o.tag
	out.options = o
	out.divTag = ['<div id="' o.tag '"></div>']
end