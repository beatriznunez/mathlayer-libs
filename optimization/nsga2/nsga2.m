function [popPos,popFront,popCost,popInfo,traceIt,info] = nsga2(f,o,objmin)
	
	% inputs
	%===================
	% f: function handle [f1,f2,...,fn]
	% o: optimization options struct or a number specifying population size
	% n: max number of iterations (in case o is a scalar)
	% objmin: logical vector to define if fi(x) is a minimization (true) or maximization(false) objective
	
	% outputs
	%===================
	% in case of one output only popPos contains the Pareto frontier of the last iteration
	% in case of more than one output:
	% popPos: contains position for the entire population (each row corresponds to one individual)
	% popFront: pareto frontier indices (popPos(popFront,:) returns the Pareto frontier positions)
	% popCost: the cost for each individuals
	% popInfo: additional information for each individual: rank, crowding distance, feasibility
	% traceit: will store all the previous outputs and for all iterations in a cell array (first row in traceIt will contain first iteration matrices)
	
	if ~isa(f,'function_handle'), error('first input needs to be a function handle'); end
	costFun = f
	g = @() 0
	nVar = 1
	lb = realmin/100
	ub = realmax/100

	dispit = false
	plotopt = {}
	plotfront = false
	plotpos = false
	plotanim = false

	if nargin>1
		if isfield(o,'d'), nVar = o.d; end
		if isfield(o,'g'), g = o.g; end
		if isfield(o,'lb'), lb = o.lb; end
		if isfield(o,'ub'), ub = o.ub; end
		if isfield(o,'display')
			if strcmpi(o.display,'iter'), dispit = true; end
		end
		if isfield(o,'plot')
			plotopt = o.plot
			if any(isinstr('pos',plotopt)), plotpos = true; end
			if any(isinstr('pareto',plotopt)), plotfront = true; end
		end
		if isfield(o,'animate'), plotanim = o.animate; end
	end
	
	if numel(lb) ~= numel(ub), error('size inconsistency between upper and lower bounds vectors'); end
	if numel(lb) > nVar, error('there are more domain boundary entries than variables'); end
	if numel(lb) < nVar
		if numel(lb)~=1, error('lower and upper bounds must either be scalars or consistent with with decision variables dimension'); end
		lb = lb .* ones(1,nVar)
		ub = ub .* ones(1,nVar)
	end
	
	nObj = numel(costFun(unifrnd(lb,ub))) % Number of Objective Functions
	
	if ~isempty(objmin) 
		if numel(objmin) ~= nObj, error('size inconsistency between vector to define min/max objective functions and number of objective functions'); end
		objmin = objmin(:).' %force row vector
		[~, j] = find(objmin==0)
		objmin(j) = -1*ones(1,numel(j))
	end

	% NSGA2 params
	nPop = 10 % default size
	maxIt = 10 % default iterations
	if nargin>1
		if isfield(o,'pop'), nPop = o.pop; end % Population Size
		if isfield(o,'maxit'), maxIt = o.maxit; end % Maximum Number of Iterations	
	end
	
	pCrossover = 0.9                     % crossover rate
	nCross = 4*round(pCrossover*nPop/4) % offsprings count
	pMutation = 1 % mutation rate
	nMut = round(pMutation*nPop)       % mutants count
	etaC = 0.2 % the lower the wider the distribution
	etaM = 0.2

	popInfo = nan(nPop,3) % matrix containing by column: rank, crowding distance, feasibility
	popPos = unifrnd(lb.*ones(nPop,nVar),ub.*ones(nPop,nVar)) % individuals' coordinates
	popCost = costFun(popPos) % individuals' costs
	popInfo(:,3) = g(popPos) 

	[rank, F] = mocnds(popInfo,popCost) % constrained non dominated sorting
	popInfo(:,1) = rank
	popInfo(:,2) = crowdingdist(popCost,F) % crowding distance
	[popInfo,popPos,popCost,F] = sortpopulation(popInfo,popPos,popCost) % sort population
	rndCross1 = randi(nPop,nCross,maxIt)
	rndCross2 = randi(nPop,nCross,maxIt)
	rndMut = randi(nPop,nMut,maxIt)

	popCInfo = nan(nCross,3) % matrix containing by column: rank, crowding distance, feasibility
	popCPos = nan(nCross,nVar) % individuals' coordinates
	popCCost = nan(nCross,nObj) % individuals' costs

	popMInfo = nan(nMut,3) % matrix containing by column: rank, crowding distance, feasibility
	popMPos = nan(nMut,nVar) % individuals' coordinates
	popMCost = nan(nMut,nObj) % individuals' costs

	% tracing info if requested
	trace = false
	if nargout > 2
		trace = true
		traceIt = cell(maxIt,6)
	end
	
	for it = 1:maxIt

		% Crossover
		for k1 = 1:nCross/4
			k2 = k1+nCross/4
			k3 = k2+nCross/4
			k4 = k3+nCross/4
			
			par1 = toursel(popPos(rndCross1(k1,it),:),popInfo(rndCross1(k1,it),2:3),popPos(rndCross1(k2,it),:),popInfo(rndCross1(k2,it),2:3))
			par2 = toursel(popPos(rndCross1(k3,it),:),popInfo(rndCross1(k3,it),2:3),popPos(rndCross1(k4,it),:),popInfo(rndCross1(k4,it),2:3))
			par3 = toursel(popPos(rndCross2(k1,it),:),popInfo(rndCross2(k1,it),2:3),popPos(rndCross2(k2,it),:),popInfo(rndCross2(k2,it),2:3))
			par4 = toursel(popPos(rndCross2(k3,it),:),popInfo(rndCross2(k3,it),2:3),popPos(rndCross2(k4,it),:),popInfo(rndCross2(k4,it),2:3))
			
			% par1 = popPos(rndCross1(k1,it),:)
			% par2 = popPos(rndCross1(k2,it),:)
			% par3 = popPos(rndCross1(k3,it),:)
			% par4 = popPos(rndCross1(k4,it),:)
			
			[pos1, pos2] = sbx(par1, par2, etaC, lb, ub)
			popCPos(k1,:) = pos1
			popCPos(k2,:) = pos2	
			popCCost(k1,:) = costFun(pos1')
			popCCost(k2,:) = costFun(pos2')
			popCInfo(k1,3) = g(pos1')
			popCInfo(k2,3) = g(pos2')
			
			[pos1, pos2] = sbx(par3, par4, etaC, lb, ub)
			popCPos(k3,:) = pos1
			popCPos(k4,:) = pos2	
			popCCost(k3,:) = costFun(pos1')
			popCCost(k4,:) = costFun(pos2')
			popCInfo(k3,3) = g(pos1')
			popCInfo(k4,3) = g(pos2')
		end

		% Mutation
		for k = 1:nMut
			popMPos(k,:) = mutpol(popPos(rndMut(k,it),:),etaM,lb,ub,1/nVar)
		end
		popMCost = costFun(popMPos)
		popMInfo(:,3) = g(popMPos)

		% merging populations
		popPos = [popPos; popCPos; popMPos]
		popInfo = [popInfo; popCInfo; popMInfo]
		popCost = [popCost; popCCost; popMCost]
		[rank, F] = mocnds(popInfo,popCost) % constrained non dominated sorting
		popInfo(:,1) = rank
		popInfo(:,2) = crowdingdist(popCost,F) % crowding distance
		[popInfo,popPos,popCost] = sortpopulation(popInfo,popPos,popCost) % sort population
		
		% truncate
		popPos = popPos(1:nPop,:)
		popInfo = popInfo(1:nPop,:)
		popCost = popCost(1:nPop,:)

		[rank, F] = mocnds(popInfo,popCost) % constrained non dominated sorting
		popInfo(:,1) = rank
		popInfo(:,2) = crowdingdist(popCost,F) % crowding distance
		[popInfo,popPos,popCost,F] = sortpopulation(popInfo,popPos,popCost) % sort population
		
		if ~isempty(objmin), popCost = popCost.*objmin; end % updating popCost if max. objective
		
		if trace
			traceIt{it,1} = popPos
			traceIt{it,2} = F{1}
			traceIt{it,3} = popCost
			traceIt{it,4} = popInfo
			traceIt{it,5} = popPos(F{1},:) % pareto front pos
			traceIt{it,6} = popCost(F{1},:) % pareto front cost
		end
		
		if dispit
			disp(['it ' num2str(it) ': front count = ' num2str(numel(F{1}))]) % Show Iteration Information
		end
		%costs = [costs; popCost(F{1},:)]
		
	end

	popFront = F{1}
	if nargout == 1, popPos = popPos(popFront,:); end
	
	% For plotting
	info = struct
	info.f = F
	info.o = o
	info.trace = traceIt
	info.ub = ub
	info.lb = lb
	info.dim = nVar
	info.maxIt = maxIt
	info.popCost = popCost
	info.popPos = popPos
	info.nObj = nObj

end