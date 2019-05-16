function [out bw minx maxx] = histfit(x, nbins, options)
	
	% check arguments
	if isstruct(nbins)
		options = nbins
		nbins = []
	end
	
	on = fieldnames(options)
	
	% take lineWidth if it is defined in options
	if numel(options) > 0
		if any(strcmp('lineWidth', on)), lineWidth = options.lineWidth; end
	end
	
	x = sort(x)
	n = numel(x)
	
	if numel(nbins) > 0
		nb = nbins
	else
		nu = numel(unique(x)) % number of different elements
		nb = min(nu,20) % number of bins
	end
	
	if nb > 1
		sx = sort(unique(x))
		md = min(sx(2:end) - sx(1:end-1))
	else
		md = 1
	end
	
	minx = x(1)
	maxx = x(end)
	bw = (maxx-minx)/nb  % bucket width
	y = zeros(1,nb)
 	xb = y
 	xb(1) = minx + bw/2 
	y(1) = sum(x < (minx + bw))
 	for i = 2:nb-1
 		xb(i) = minx + (i - 0.5)*bw
		y(i) = sum(x < (minx + i*bw) & x >= (minx + (i-1)*bw))
 	end
 	xb(nb) = minx + (nb - 0.5)*bw
	y(nb) = n - sum(y(1:(nb-1)))
	
	opHist = options
 	opHist.type = 'histogram'
 	
 	% set options
	[miny maxy] = axisRange(min(y),max(y))
	opHist = chartOptions(opHist, min(x), max(x), 0, maxy)
	
	% overriden options HISTOGRAM
	opHist.barCount = nb
	opHist.markerSize = 0
	opHist.lineWidth = 0
	if isempty(opHist.barFillPos), opHist.barFillPos = 'lightsteelblue'; end
	opHist.show = false
	
	if isempty(opHist.barWidth), opHist.barWidth = md; end
	hist = gen2d(xb,y,opHist)
	
	% define PLOT properties
	opPlot = options
	opPlot.show = false
	opPlot.markerSize = 0
	opPlot.barCount = 0
	opPlot.lineFill = 'none'
	opPlot.lineWidth = max(1, lineWidth)
	
	% plot normal distribution
	mu = round(mean(x)) % mean in normal distribution
	sigma = std(x) % standard deviation
	z = min(x):0.1: max(x)
	p1 = -.5 * ((z - mu)/sigma) .^ 2
	p2 = (sigma * sqrt(2*pi));
	f = (exp(p1) ./ p2)*sum(y)*bw % normal distribution
	fit = plot(z, f, opPlot)
	
	out = overlay({hist, fit})	

end