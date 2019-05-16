function [out] = pie(x, input2, input3, options)
	
	if nargin > 1
		
		if nargin > 2	% third argument handling
			if isstruct(input3) && nargin == 3
				options = input3
				opt = options
			elseif ischar(input3) && strcmp(input3, 'probability')
				opt.norm = 'probability'
			else
				error('invalid arguments')
			end
		end
		
		if isstruct(input2)	% second argument handling
			options = input2
			opt = options
		elseif isfloat(input2)
			if numel(input2) > 1, opt.edges = input2, edges = opt.edges; end % if bins is a vector refers to the edges
			if numel(input2) == 1, opt.nbins = input2; end
		elseif ischar(input2) && strcmp(input2, 'probability')
			opt.norm = 'probability'
		else
			error('invalid arguments')
		end
	else
		opt = struct
	end
	
	x(isnan(x)) = []
	x(isinf(x)) = [] 
	
	if isempty(options) || ~isfield(options, 'categorical'), options.categorical = false; end
	
	if isempty(options) || ~options.categorical
		y = x, xb = x, nb = numel(x)
		% if nb > 20, error('too many elements in first input: change options.categorical to true'); end
		options.categorical = false
		lab = x
	else
		x = sort(x)
		lab = unique(x)
		if isempty(opt) || (~isfield(opt,'nbins') && ~isfield(opt,'widthbins') && ~isfield(opt,'edges'))	% discretize method not defined
			opt.nbins = min(10,numel(unique(x)))	% number of bins by default
			opt.edges = [unique(x) max(unique(x))+1]
			edges = opt.edges
		end
		
		if numel(unique(x)) <= 10
			xb = (edges(2:end)+edges(1:end-1)) / 2
			nb=numel(edges)-1
			y = zeros(1,nb)
			for i = 1:nb-1
				y(i) = sum(x >= edges(i) & x < edges(i+1))
			end
			y(nb) = sum(x >= edges(nb))
		else
			[xb,y,edges,nb] = histcounts(x,opt)
		end
	end
	
	per = zeros(1,nb)
	for i = 1:nb
		per(i) = y(i)*100/sum(y)
	end
		
	options.type = 'pie'
	if ~isfield(options, 'showLegend'),options.showLegend = true; end
	if ~isfield(options,'titleX'), options.titleX = -40; end
	if ~isfield(options,'titleY'), options.titleY = 250; end
	% set options
	[miny maxy] = axisRange(min(y),max(y))
	
	if min(x) ~= max(x)
		o = chartOptions(options, min(x), max(x), 0, maxy)
	else
		o = chartOptions(options, min(x)-0.5, max(x)+0.5, 0, maxy)
	end
	if o.vertical, o.translate = [num2str(o.width/2) ',' num2str(o.width/2)]; end
	if isempty(o.legendLabels)
		legendLabels = cell(1,nb)
		if numel(unique(x)) == nb || ~o.categorical
			for i = 1:nb
				legendLabels{i} = sprintf('%d',lab(i))
			end
		else
			for i = 1:nb-1
				legendLabels{i} = sprintf('%.2f-%.2f',edges(i),edges(i+1)-0.01)
			end
			legendLabels{nb} = sprintf('%.2f-%.2f',edges(nb),edges(nb+1))
		end
		o.legendLabels = legendLabels
	end
	
	if strcmp(o.pieVal,'in'), o.pieValue = 1.5; end
	if strcmp(o.pieVal,'out'), o.pieValue = 2.2+abs((450-o.height)*0.2/120); end
	[x y o] = chartCheckArgs(per,y,o)
	c = cell(1,numel(per))
	c{1,:} = 'area'
	
	% overriden options
	o.markerFill = ''
	o.dashArray = c
	o.xAxisShow = false
	o.yAxisShow = false
	o.showSecondaryAxis = false
	o.xName = false
	o.yName = false
	o.y2Name = false
	o.xAxisFont = '0.7em arial'
	o.markerSize = 0
	o.width = o.height + o.showLegend*100
	o.paddingLeft = 60
	if numel(x) > 15, o.showLegend = false; end
	
	out = gen2dVect(x,y,o)
	
end