function [y1 y2] = sbx(x1,x2,mu,lb,ub)

	n = numel(x1)
	u = rand(n,1)
	bq = nan(n,1)
	usmall = u <= 0.5
	bq(usmall) = (2*u(usmall)).^(1/(1+mu))
	bq(~usmall) = 1%./(2*(1-u(~usmall))).^(1/(1+mu))
	y1 = 0.5*(((1+bq).*x1)+(1-bq).*x2)
	y2 = 0.5*(((1-bq).*x1)+(1+bq).*x2)
	y1(y1<lb) = lb(y1<lb)
	y1(y1>ub) = ub(y1>ub)		
	y2(y2<lb) = lb(y2<lb)
	y2(y2>ub) = ub(y2>ub)

end