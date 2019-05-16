function b = dominates(x,xf,y,yf)

	b = false
	if xf > yf % yf is not feasible
		b = true
	elseif yf < 0 %&& xf < 0 % none are feasible
		b = yf < xf
	elseif xf >= 0 % both are feasible
		b = all(x<=y) && any(x<y)
	end

end
