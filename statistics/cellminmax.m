function [cmin cmax] = cellminmax(c)

	cmin = min(min(cellfun(@(x) min(x(~isnan(x))),c)))
	cmax = max(max(cellfun(@(x) max(x(~isnan(x))),c)))
	
end