function [b,info,trace] = lsqcurvefit(f,b0,x,y,o)

	j = []
	lb = []
	ub = []
	inc = []
	l = []
	factor = []
	mv = []
	minsse = []
	maxit = []
	e = []
	nbig = []
	vect = false

	if nargin>4
		if isfield(o,'jac'), j = o.jac; end
		if isfield(o,'lb'), lb = o.lb; end
		if isfield(o,'ub'), ub = o.ub; end
		if isfield(o,'inc'), inc = o.inc; end
		if isfield(o,'lambda'), l = o.lambda; end
		if isfield(o,'factor'), factor = o.factor; end
		if isfield(o,'minvar'), mv = o.minvar; end
		if isfield(o,'minsse'), minsse = o.minsse; end
		if isfield(o,'maxit'), maxit = o.maxit; end
		if isfield(o,'dx'), e = o.dx; end
		if isfield(o,'nbig'), nbig = o.nbig; end
		if isfield(o,'vect'), vect = o.vect; end
		dispit = false
		if isfield(o,'display')
			if strcmpi(o.display,'iter'), dispit = true; end
		end

	end

	if isvector(x) && size(x,1) == 1, x = x'; end
	if isvector(y) && size(y,1) == 1, y = y'; end
	if isvector(b0) && size(b0,1) == 1, b0 = b0'; end
	
	if nargout>1 % trace is also a field of info used for plotting
		[b,info,trace] = lm(f,x,y,b0,j,lb,ub,inc,l,factor,mv,minsse,maxit,e,nbig,vect)
	else 
		b = lm(f,x,y,b0,j,lb,ub,inc,l,factor,mv,minsse,maxit,e,nbig,vect)
	end

	% For plotting
	info.f = f
	info.trace = trace
	info.x = x
	info.y = y
	info.b = b
	if ~isempty(o)
		info.o = o
		info.ub = ub
		info.lb = lb
	end
	
end