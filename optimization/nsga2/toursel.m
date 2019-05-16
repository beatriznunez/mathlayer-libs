function y = toursel(x1,x1f,x2,x2f)

	if dominates(x1,x1f(2),x2,x2f(2))
		y = x1
	elseif dominates(x2,x2f(2),x1,x1f(2))
		y = x2
	elseif x1f(1) > x2f(1)
		y = x1
	elseif x1f(1) < x2f(1)
		y = x2
	elseif rand <= 0.5
		y = x1
	else
		y = x2
	end
	
end