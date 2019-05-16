function [xb,y,edges,nb,bin] = histcounts(x,options)
	
	x(isnan(x)) = []
	x(isinf(x)) = []
	minx = min(x)
	maxx = max(x)
	n = numel(x)

	if ~isfield(options,'nbins') && ~isfield(options,'widthbins') && ~isfield(options,'edges')
		options.nbins = min(20,numel(unique(x)))	% number of bins by default
	end	
	
	if ~isfield(options,'norm'), options.norm = 'count'; end
	
	% calculate distribution edges
	if isfield(options,'nbins')		% number of bins defined in options
	
		nb = options.nbins			% number of bins
		bw = (maxx-minx)/nb 		% bucket width
		edges = minx + (0:nb) .* bw	% get edges with exact multiples
		
	elseif isfield(options,'widthbins')		% bucket width defined in options
	
		bw = options.widthbins				% bucket width
		leftEdge = bw*floor(minx/bw)		% left edge to get exact multiples edges
		nb = max(1,ceil((maxx-leftEdge) ./ bw))	% number of bins
		edges = leftEdge + (0:nb) .* bw		% get edges with exact multiples
		
	elseif isfield(options,'edges')	% edges defined in options
	
		edges = options.edges
		nb = length(edges) -1
		
	else
		error('invalid second argument')
	end
	
	switch options.norm		% normalization options
		case 'count'
			total  = 1
		case 'probability'
			total  = n
	end
	
	xb = zeros(1,nb)
	y = zeros(1,nb)
	xb = (edges(2:end)+edges(1:end-1)) / 2	% vector of means between edges
	
	for i = 1:nb-1
		y(i) = sum(x >= edges(i) & x < edges(i+1))
	end
	y(nb) = sum(x >= edges(nb))
	
	y = y/total
	
	if nargout > 4
		bin = zeros(1,n)				% indices of the bins that contain the elements of X
		for i = 1:numel(x)
			for j = 1:numel(edges)-1
				if x(i)>=edges(j), bin(i) = j; end
			end
		end
	end
	
end