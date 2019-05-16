function y = mutpol(x,mu,lb,ub,p)

	n = numel(x)
	nrs = ceil(p*n)
	rs = randsample(n,nrs,1)
	u = rand(nrs,1)
	deltaR = 1-(2*(1-u)).^(1/(1+mu))
	deltaL = (2*u).^(1/(1+mu))-1
	y = x
	y(rs) = x(rs) + deltaR.*(ub(rs)-x(rs)).*(u>0.5) + deltaL.*(x(rs)-lb(rs)).*(u<=0.5)
	y(y<lb) = lb(y<lb)
	y(y>ub) = ub(y>ub)
	
end