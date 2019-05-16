function out = gen2d(x,y,options)

	if nargin == 0, error('not enough input arguments')
	elseif nargin == 1, y = x; end

	if nargin < 3, options.type = 'default'; end
		
	[nrx ncx] = size(x)
	[nry ncy] = size(y)
	isarea = strcmp(options.type, 'area')
	isbar = strcmp(options.type, 'bar')
	iswat = strcmp(options.type, 'waterfall')

	if (nry > 1 & ncy > 1)
		% prepare options
		barTranslate = false
		nc = numel(options.colors)
		nac = numel(options.areaColors)		
		color = options.colors
		areaColor = options.areaColors
		if nry <= nc, col = color(1:nry), else, col = color; end
		if nry <= nac, acol = areaColor(1:nry), else, acol = areaColor; end
		
		if isarea | isbar
			% extract colors in the right order for bar and area charts
			if isbar
				if ~options.barStack
					options.barWidth = options.barWidth / nry
					barTranslate = true
					bT = cell(1,nry)
					for i = 1:nry
						bT{i} = options.barWidth * (i - (nry+1)/2)
					end
					options.barTranslate = bT
				end
				x = x-options.barWidth/2
			end
			if nry <= nc
				colorsExtract = options.colors
				options.colors = fliplr(colorsExtract(1:nry))
				col = options.colors
			end
			if nry <= nac
				areaColorsExtract = options.areaColors
				options.areaColors = fliplr(areaColorsExtract(1:nry))
				acol = options.areaColors
			end
			options.dataColor = acol
			if isarea, options.areaStroke = acol,options.areaAboveStroke = acol, options.areaBelowStroke = acol; end
		else
			options.dataColor = col
		end
		
		options.lineStroke = col
		options.markerStroke = col
		options.barFillPos = acol
		options.barFillNeg = acol
		
	end
	
	out = gen2dVect(x,y,options)
end