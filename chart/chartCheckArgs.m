function [x y options] = chartCheckArgs(x, y, options)
	
	oneArg = false
	if isempty(y) % nargin == 1
		oneArg = true
	elseif isstruct(y)
		options = y
		oneArg = true
	end
	
	if oneArg
		y = x
		n = numel(y)
		if size(y,1) > 1 & size(y,2) > 1, n = size(y,1); end
		x = 1:n
	end
	
	if size(x,2)==1, x = x'; end
	if size(y,2)==1, y = y'; end
	
	[nrx ncx] = size(x)
	[nry ncy] = size(y)
	
	if (nrx~=1 && nry~=1)
		if (ncx~=ncy || nrx~=nry), error('inconsistent dimensions: X and Y must have same number of columns'); end
		x = x'
		y = y'
	else
		if (nry==ncx || ncy==ncx)
			if nry==ncx, y = y'; end
		else
			error('inconsistent dimensions between arguments')
		end
	end
	
	if isstruct(options)
		if isfield(options,'markerStrokeFormat') && strcmp(options.markerStrokeFormat, 'date')
			options.markerStroke = 1000.*m2udate(options.markerStroke)
		end
		if isfield(options,'xAxisFormat') && strcmp(options.xAxisFormat, 'date')
			x = 1000*m2udate(x)
		end
		if isfield(options,'yAxisFormat') && strcmp(options.yAxisFormat, 'date')
			y = 1000*m2udate(y)
		end
		if isfield(options,'y2AxisFormat') && strcmp(options.y2AxisFormat, 'date')
			y2 = 1000*m2udate(y2)
		end
	end
end
	