function h = normplot(x, options)

	[n,m] = size(x)
	if n == 1
		x = x'
		n = m
	end
	
	[sx i] = sort(x)
	minx = min(sx(1,:))
	maxx = max(sx(n,:))
	range = maxx-minx

	if range>0
		minxaxis = minx-0.025*range
		maxxaxis = maxx+0.025*range
	else
		minxaxis = minx - 1
		maxxaxis = maxx + 1
	end
	
	eprob = [0.5/n:1/n:(n-0.5)./n]
	y = norminv(eprob,0,1)
	
	minyaxix = norminv(0.25 ./n,0,1)
	maxyaxis = norminv((n-0.25)./n,0,1)
	
	p = [0.001 0.003 0.01 0.02 0.05 0.1 0.25 0.5 ...
	0.75 0.9 0.95 0.98 0.99 0.997 0.999]

	tick = norminv(p,0,1)
	
	q1x = prctile(x,25)
	q3x = prctile(x,75)
	q1y = prctile(y,25)
	q3y = prctile(y,75)
	qx = [q1x; q3x]
	qy = [q1y; q3y]
	
	dx = q3x-q1x
	dy = q3y-q1y
	slope = dy./dx
	centerx = (q1x+q3x)/2
	centery = (q1y+q3y)/2
	maxx = max(x)
	minx = min(x)
	maxy = centery + slope.*(maxx-centerx)
	miny = centery - slope.*(centerx-minx)
	
	mx = [minx; maxx]
	my = [miny; maxy]
	
	o = struct('show',false)
	o1 = o
	o2 = o
	o.dashArray = '10 4 2 4'
	o1.markerStroke = 'blue'
	o2.lineStroke = 'red'
	o.lineStroke = 'red'
	h = overlay({scatter(sx,y,o1),plot(qx,qy,o2),plot(mx,my,o)})
	
end