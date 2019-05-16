function [xmin,fmin,info,trace] = fminsearch(f,x0,o)

	% Adaptive Nelder-Mead Simplex
	% cf. "Implementing the Nelder-Mead simplex algorithm with adaptive parameters" 
	% Computational Optimization and Applications, 2012, 51: 259-277. 

	% defaults
	tol = 1e-6
	maxit = 100
	maxfc = 100
	lb = []
	ub = []
	
	info = struct('f', f)

	if nargin < 2
		error('expected at least 2 arguments')
	elseif nargin>2
		% retrieving options
		if ~isstruct(o), error('options must be a struct'); end
		if isfield(o,'maxit'), maxit = o.maxit; end
		if isfield(o,'maxfc')
			maxfc = o.maxfc
		else
			maxfc = inf
		end
		if isfield(o,'tol'), tol = o.tol; end
		if isfield(o,'lb'), lb = o.lb; end
		if isfield(o,'ub'), ub = o.ub; end
	end

	x0 = x0(:)' % convert into row vector
	dim = numel(x0) % dimension of the problem
	
	% modifying the problem for lower and/or upper bounds
	if ~isempty(lb)
		if numel(lb) < dim
			if numel(lb)~=1, error('lower and upper bounds must either be scalars or consistent with with decision variables dimension'); end
		end
		if any(x0<lb), error('make sure the starting point x0 is within the boundaries'); end
		gl = f
		f = @(x) gl(x) + realmax/2 * any(any(x<lb.*ones(size(x))))
	end
	if ~isempty(ub)
		if numel(ub) < dim
			if numel(ub)~=1, error('lower and upper bounds must either be scalars or consistent with with decision variables dimension'); end
		end
		if any(x0>ub), error('make sure the starting point x0 is within the boundaries'); end
		gu = f
		f = @(x) gu(x) + realmax/2 * any(any(x>ub.*ones(size(x))))
	end

	% set up adaptive parameters
	alpha = 1
	beta = 1 + 2/dim
	gamma = 0.75 - 0.5/dim
	delta = 1 - 1/dim

	% initial simplex
	scalefactor = min(max(max(abs(x0)),1),10)
	scaledtol = scalefactor*tol

	D0 = eye(dim)
	D0(dim+1,:) = (1-sqrt(dim+1))/dim*ones(1,dim)
	X = nan(dim+1,dim)
	for i = 1:dim+1
		X(i,:) = x0 + scalefactor*D0(i,:)
		FX(i) = f(X(i,:))
	end
	ct = dim+1
	[FX,I] = sort(FX)
	X = X(I,:)
	cit = 0
	
	kt = nargout>2 % keep trace
	if kt
		XTrace = nan(maxit,dim)
		FTrace = nan(maxit,1)
		XTrace(1,:) = X(1,:)
		FTrace(1,:) = FX(1)
	end

	i0 = 1:dim
	i = i0+1
	while max(abs(X(i,:)-X(i0,:))) >= scaledtol
		if ct>maxfc | cit>maxit, break; end   
		M = mean(X(i0,:)) % Centroid of the dim best vertices
		xref = (1+alpha)*M- alpha*X(end,:)
		Fref = f(xref)
		ct = ct+1;
		if Fref<FX(1) % expansion
			xexp = (1+alpha*beta)*M-alpha*beta*X(end,:)
			Fexp = f(xexp)
			ct = ct+1
			if Fexp < Fref
				X(end,:) = xexp
				FX(end) = Fexp
			else
				X(end,:) = xref
				FX(end) = Fref
			end
		else
			if Fref<FX(dim) % accept reflection point
				X(end,:) = xref
				FX(end) = Fref
			else 
				if Fref<FX(end) % Outside contraction
					xoc = (1+alpha*gamma)*M-alpha*gamma*X(end,:)
					Foc = f(xoc)
					ct = ct+1   
					if Foc<=Fref
						X(end,:) = xoc
						FX(end) = Foc
					else % shrink
						X(i,:) = X(1,:) + delta*(X(i,:)-X(1,:))
						FX(i) = f(X(i,:))
						ct = ct + dim
					end
				else %inside contraction
					xic = (1-gamma)*M+gamma*X(end,:)
					Fic = f(xic)
					ct = ct+1
					if Fic<FX(end)
						X(end,:) = xic
						FX(end) = Fic
					else % shrink
						X(i,:) = X(1,:)+ delta*(X(i,:)-X(1,:))
						FX(i) = f(X(i,:))
						ct = ct+dim
					end
				end
			end
		end
		[FX,I] = sort(FX)
		X = X(I,:)
		cit = cit + 1
		if kt
			XTrace(cit,:) = X(1,:)
			FTrace(cit,:) = FX(1)
		end
	end
	
	xmin = X(1,:)
	fmin = FX(1)
	info.x0 = x0
	info.nit = cit
	info.nfc = ct
	info.tol = tol

	if kt
		trace.x = XTrace(1:cit,:)
		trace.f = FTrace(1:cit,:)
	end
	
	% For plotting
	info.trace = trace
	info.dim = dim
	if ~isempty(o)
		info.o = o
		info.ub = ub
		info.lb = lb
	end
end