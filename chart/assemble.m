function out = assemble(c,options)

	options.overlay = false
	options.type = 'assemble'
	
	if istable(c)
	
		t = c
		t.rownames = cast(t{:,1}, 'cell') 
		t = t(:,2:end);
		x = t{:,:}	
		m = t.variableNames

		op = struct
		op.show = false
		op.barBase = min(min(x))
		op.areaBase = min(min(x))
		op.yAxisMin = min(min(x))
		op.yAxisMax = max(max(x))
		op.xAxisLabels = t.rownames
		if ~isfield(options,'visual'), options.visual = 'bar'; end 
		
		c={}		
		
		for i=1:size(x,1)
			title = m(i)
			op.title = title{:}
			switch options.visual
				case 'bar'
					c{i} = bar(x(:,i),op)
				case 'area'
					c{i} = area(x(:,i),op)
				case 'plot'	
					c{i} = plot(x(:,i),op)
				case 'scatter'
					c{i} = scatter(x(:,i),op)
				case 'stem'
					c{i} = stem(x(:,i),op)
			end
		end
	end
	
	if ~isfield(options,'height'), options.height = 450; end
	
	cellsops = cellfun(@(x) x.options, c, 'uniformoutput', false)	
	cellperc = cellfun(@(x) x.percw, cellsops)
	
	if ~isfield(options,'width')
		options.width = max(max(cellfun(@(x) x.width, cellsops)),600)
		options.gw = [num2str(options.width), 'px']
	end
	
	if any(cellperc == 100)
		for i=1:numel(c)
			graph = c{i}
			graphop = graph.options
			if options.width > 1, graphop.percw = 100*graphop.width/options.width; end
			if options.width > 1, graphop.width = 600; end
			graphop.gw = [num2str(graphop.percw) '%']
			graph.options = graphop
			c{i} = graph
		end	
		cellsops = cellfun(@(x) x.options, c, 'uniformoutput', false)	
		cellperc = cellfun(@(x) x.percw, cellsops)	
	end
		
	cellhei = cellfun(@(x) x.height, cellsops)
	cellwid = cellfun(@(x) x.width, cellsops)
	if cellhei(1) == 450, rateH = cellwid(1)/600; else rateH = 1; end
	
	for i=1:numel(c)
		graph = c{i}
		graphop = graph.options
		rateW = cellperc(i)/100		
		if options.width > 1, graphop.width = options.width*rateW; end
		graphop.height = graphop.height*rateH
		if strcmp('assemble',graph.type)
			graph.jsData = strrep(graph.jsData,'w=600',['w=' num2str(graphop.width)])
			graph.jsData = strrep(graph.jsData,'"width", 600',['"width", ' num2str(graphop.width)])
			graph.jsData = strrep(graph.jsData,'h=450',['h=' num2str(graphop.height)])
			graph.jsData = strrep(graph.jsData,'"height", 450',['"height", ' num2str(graphop.height)])
			graph.jsData = strrep(graph.jsData,'calc(100',['calc(' num2str(cellperc(i))])
		else
			graph.jsFrame = strrep(graph.jsFrame,'w=600',['w=' num2str(graphop.width)])
			graph.jsFrame = strrep(graph.jsFrame,'"width", 600',['"width", ' num2str(graphop.width)])
			graph.jsFrame = strrep(graph.jsFrame,'h=450',['h=' num2str(graphop.height)])
			graph.jsFrame = strrep(graph.jsFrame,'"height", 450',['"height", ' num2str(graphop.height)])
			graph.jsFrame = strrep(graph.jsFrame,'calc(100',['calc(' num2str(cellperc(i))])
		end
		
		graph.options = graphop
		c{i} = graph
	end
	out = chartCombine(c,options)
end