function out = animate(c,options)

	options.type = 'animate'
	options.overlay = false

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
		op.xAxisLabels = m
		if ~isfield(options,'visual'), options.visual = 'bar'; end 
		
		c={}		
		
		for i=1:size(x,1)
			title = t.rownames{i}
			op.title = title{:}
			switch options.visual
				case 'bar'
					c{i} = bar(x(i,:),op)
				case 'area'
					c{i} = area(x(i,:),op)
				case 'plot'	
					c{i} = plot(x(i,:),op)
				case 'scatter'
					c{i} = scatter(x(i,:),op)
				case 'stem'
					c{i} = stem(x(i,:),op)
			end
		end
	end

	
	% take pitch and yaw of the first graph
	c1 = c{1}
	c1op = c1.options
	if ~isfield(options,'pitch'), options.pitch = c1op.pitch; end 
	if ~isfield(options,'yaw'), options.yaw = c1op.yaw; end 
	
	co = cellfun(@(x) x.options,c,'uniformoutput',false)
	vert = cellfun(@(x) isequal(x.vertical,1),co)
	wid = cellfun(@(x) x.width,co)
	hei = cellfun(@(x) x.height,co)
	if sum(vert) > 1
		if ~isfield(options,'height'), options.height = max(wid); end
		options.vertical = true
	else
		if ~isfield(options,'height'), options.height = max(hei); end
	end
	
	out = chartCombine(c,options)
end