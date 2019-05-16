function [b,info,trace] = lm(f,x,y,b0,j,lb,ub,inc,l,factor,mv,minsse,maxit,e,nbig,vect)
	% ===============================
	% INPUTS
	% ===============================
	% x: abscissae
	% y: values to match
	% b0: initial beta
	% j: Jobian, if empty, numerical approximation will be used
	% lb: lower bounds
	% ub: upper bounds
	% inc: list of parameters to include for minimization
	% l: dumping factor (lamda)
	% factor: increase / decrease factor
	% mv: sum of squared errors minimum variation (convergence towards local minimum criterion)
	% minsse: target sum of squared errors
	% maxit: maximum number of iterations
	% e: this is the tweak precision for derivatives calculation
	% nbig: number of random initial guesses
	% vect: vectorized function handle (default: true)
	% ===============================
	% OUTPUTS
	% ===============================
	% b: result
	% info: number of iterations, intial and final SSE
    % ===============================
	% EXAMPLE: SABR calibration
	% ===============================
	% f is sabr function that takes 2 matrix inputs: 
	% x for the strikes we want to calibrate on and beta for its parameters [alpha, beta, rho, nu]
	% y is the target, ie the market vols (therefore the size of this vector must be consistent with the strikes vector x)
	
	if nargin < 4, error('expected at least 4 input arguments'); end
	dim = numel(b0) % dimension of the minimization problem
	if isempty(inc), inc = true(dim, 1); end % in this case we inc all parameters	

	if numel(nbig) > 0
		if numel(lb) ~= dim || numel(ub) ~= dim
			error('in case of multiple initial guesses all constraints (lower and upper bounds) must be defined');
		end
		[b,info] = lm(f, x, y, b0, j, lb, ub, inc, l, factor, mv, minsse, maxit, e);
		if info.sse < minsse, return; end % if sse is lower than target then return
		for i = 1:nbig % run lm on multiple random initial guesses
			ig = inc.*(lb + (ub - lb)*rand) + (1 - inc).*b0;
			[btmp infotmp] = lm(f, x, y, b0, j, lb, ub, inc, l, factor, mv, minsse, maxit, e);
			if infotmp.sse < info.sse
				b = btmp;
				info = infotmp;
				if info.sse < minsse, return; end
			end
		end
	end
	
	% default values
	nj = false
	if isempty(j), nj = true; end
	if numel(minsse) == 0, minsse = 1.e-40; end
	if isempty(e), e = 1.e-7; end
	if isempty(maxit),	maxit = 500; end
	if isempty(mv), mv = 1.e-40; end
	if isempty(factor), factor = 1.3; end
	if isempty(l), l = 0.01; end
	if isempty(vect), vect = true; end
	
	kt = nargout>2 % keep trace
	if kt
		bTrace = nan(maxit,dim)
		sseTrace = nan(maxit,1)
		iTrace = nan(maxit,1)
	end

	%initializations
	info = struct
	b = b0
	nb = size(x,1) % number of points
	 
	haslb = false
	hasub = false
	if numel(lb) ~= 0
		haslb = true;
		if(numel(lb) ~= dim)
			error('number of constraints inconsistent with number of minimization parameters');
		end
	end
	if numel(ub) ~= 0
		hasub = true
		if(numel(ub) ~= dim)
			error('number of constraints inconsistent with number of minimization parameters');
		end
	end

	% calculate initial sum of squared errors
	diffs = y - f(x,b)

	pf = 10000000000. % penalisation factor
	sse = sumsqr(diffs)
	if haslb && any(b < lb), sse = sse + pf; end
	if hasub && any(b > ub), sse = sse + pf; end
	info.sse0 = sse % store initial sse

	% right part of A*x = b
	if vect
		em = e * diag(inc)
		if nj, J = (f(x,b + em) - f(x,b - em)) / (2*e)
		else J = j(x,b) * (e*inc); end
	else
		J = jacobian(f,x,b,e,inc)
	end
	B = J' * diffs
			
	% hessian
	ap = J' * J % a prime
	% new alpha matrix: multiply diagonal elements by 1 + lamda
	[nr, nc] = size(ap)
	ap(1:(nr+1):nr*nc) = (1. + l) .* ap(1:(nr+1):nr*nc)

	% iteration and convergence parameters
	lmit = -1 % low move iteration
	delta = 1
	dp = 1 % previous delta
	dbsse = 1 % delta beta sse
	dbssep = 2 % previous delta beta sse
	dsse = 1 % delta sse
	db = zeros(dim, 1)
	btmp = zeros(dim, 1)
	i = 0

	for it = 1:maxit
		db = ap \ B
		btmp = b + db
		% apply delta b
		diffs = y - f(x, btmp)
		ssen = sumsqr(diffs)
		if haslb && any(btmp < lb), ssen = sse + pf; end
		if hasub && any(btmp > ub), ssen = sse + pf; end
		delta = ssen - sse
		
		if delta < 0
			% convergence criteria
			if (abs(delta) < mv) & (abs(dp) < mv) | abs(dbsse / dbssep - 1.) < mv & abs(dsse) < mv | ssen < minsse
				it = it - 1; break
			end
			% udpate lamda, beta and sse
			l = l / factor
			b = btmp
			sse = ssen
			% update diffs
			diffs = y - f(x,b)
			% update Jobian, b and hessian
			if vect
				if nj, J = (f(x,b + em) - f(x,b - em)) / (2*e)
				else J = j(x,b) * (e*inc); end
			else
				J = jacobian(f,x,b,e,inc)
			end
			B = J' * diffs
			ap = J' * J
			% update indicators
			dbssep = dbsse
			dbsse = sumsqr(db)
			dsse = sumsqr(b)
			i = i + 1
			if kt
				sseTrace(i) = ssen
				bTrace(i,:) = b
				iTrace(i) = it
			end
		elseif (abs(delta) < 1.e-12)
			if (it - lmit) == 1, it = it-1; break; end % ie if in previous iteration we had low delta
			lmit = it
		else 
			l = l * factor
		end
		% update diagonal using new lamda
		ap(1:(nr+1):nr*nc) = (1. + l) .* ap(1:(nr+1):nr*nc)
		dp = delta
	end
	info.sse = sse % final sse
	info.nit = it % final index
	if kt
		trace = cell(3,1)
		trace{1} = sseTrace(1:i)
		trace{2} = bTrace(1:i,:)
		trace{3} = iTrace(1:i)
	end
	
end

function J = jacobian(f,x,b,e,inc)
	dim = numel(b)
	bu = b
	bd = b 
	J = zeros(size(x,1),dim)
	for i = 1:dim
		if inc(i)
			% tweak beta
			bu(i) = bu(i)+e
			bd(i) = bd(i)-e
			J(:,i) = f(x,bu)-f(x,bd)
			% reset beta
			bu = b
			bd = b
		end
	end
	J = J/(2*e)
end