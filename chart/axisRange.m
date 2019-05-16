function [minx maxx] = axisRange(minx,maxx)

	if maxx == minx
		if maxx ~= 0
			maxx = maxx * 1.01
			minx = minx * 0.99
		else
			maxx = 1
			minx = -1
		end
	end
	
	if maxx < minx
		temp = maxx
		maxx = minx
		minx = temp
	end
	
	if (isempty(minx) || isempty(maxx))
		maxx = 1.01
		minx = 0.99
	end
		
end