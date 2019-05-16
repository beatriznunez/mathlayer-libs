function [xmin,fmin,popPos,popCost,info] = ga(f,o)

	% inputs
	%===================
	% f: function handle
	% o: optimization options struct or a number specifying population size
	
	% outputs
	%===================
	% xmin: position of global minimun
	% fmin: value of global minimun
	% info.popPos: contains position for the entire population (each row corresponds to one individual)
	% info.popCost: the cost for each individuals
	% info.traceit: will store popPos and popCost for all iterations in a cell array (first row in traceIt will contain first iteration matrices)
	
	if ~isa(f,'function_handle'), error('first input needs to be a function handle'); end
	nVar = 1
	lb = realmin/100
	ub = realmax/100
	
	dispit = false
	plotanim = false	

	if nargin>1
		if isfield(o,'d'), nVar = o.d; end
		if isfield(o,'lb'), lb = o.lb; end
		if isfield(o,'ub'), ub = o.ub; end
		if isfield(o,'display')
			if strcmpi(o.display,'iter'), dispit = true; end
		end
	end
	
	if numel(lb) ~= numel(ub), error('size inconsistency between upper and lower bounds vectors'); end
	if numel(lb) > nVar, error('there are more domain boundary entries than variables'); end
	if numel(lb) < nVar
		if numel(lb)~=1, error('lower and upper bounds must either be scalars or consistent with with decision variables dimension'); end
		lb = lb .* ones(1,nVar)
		ub = ub .* ones(1,nVar)
	end
	
	nObj = numel(f(unifrnd(lb,ub))) % Number of Objective Functions
	
	% GA Parameters
	nPop = 10     % default size
	maxIt = 20    % default iterations
	method = 'Roulette Wheel' % 'Roulette Wheel','Tournament','Random','Roulette Wheel'
	if nargin>1
		if isfield(o,'pop'), nPop = o.pop; end % Population Size
		if isfield(o,'maxit'), maxIt = o.maxit; end % Maximum Number of Iterations	
		if isfield(o,'method'), method = o.method; end
	end
	pCrossover = 0.9                    % crossover rate
	nCross = 2*round(pCrossover*nPop/2) % offsprings count
	pMutation =1 % 0.3 % mutation rate
	nMut = round(pMutation*nPop)       % mutants count
	etaC = 0.2 % the lower the wider the distribution
	etaM = 0.2
	
	rndMut = randi(nPop,nMut,maxIt)
		
	RWS=strcmp(method,'Roulette Wheel')
	TS=strcmp(method,'Tournament')
	RS=strcmp(method,'Random')

	popPos = unifrnd(lb.*ones(nPop,nVar),ub.*ones(nPop,nVar)) % individuals' coordinates
	popCost = f(popPos) % individuals' costs
	
	popPos0 = popPos % Store initial population
	popCost0 = popCost
	
	[popCost, SortOrder]=sort(popCost) % Sort Population
	popPos = popPos(SortOrder,:)
	
	BestCost = popCost(1) % Store Best Solution
	WorstCost = popCost(end) % Store Cost
	
	popCPos = nan(nCross,nVar) % individuals' coordinates
	popCCost = nan(nCross,nObj) % individuals' costs
	popMPos = nan(nMut,nVar) % individuals' coordinates
	popMCost = nan(nMut,nObj) % individuals' costs
	
	% tracing info if requested
	trace = false
	if nargout > 2
		trace = true
		traceIt = cell(maxIt,2)
	end
	
	for it=1:maxIt
		
		% Calculate Selection Probabilities
		if RWS
			P=exp(-8*popCost/WorstCost)
			P=P/sum(P)
		end
		
		% Crossover
		for k1=1:nCross/2
			k2 = k1+nCross/2
			% Select Parents Indices
			if RWS
				i1=rws(P)
				i2=rws(P)
			elseif TS
				i1=ts(popCost,3)
				i2=ts(popCost,3)
			elseif RS
				i1=randi([1 nPop])
				i2=randi([1 nPop])
			end

			% Select Parents
			p1pos = popPos(i1,:)
			p1cost = popCost(i1,:)
			p2pos = popPos(i2,:)
			p2cost = popCost(i2,:)
			
			% Crossover
			[pos1, pos2] = sbx(p1pos,p2pos,etaC,lb,ub)
			popCPos(k1,:) = pos1
			popCPos(k2,:) = pos2	
			popCCost(k1,:) = f(pos1')
			popCCost(k2,:) = f(pos2')
		end
		popCCost = f(popCPos)
		
		% Mutation
		for k=1:nMut
			popMPos(k,:) = mutpol(popPos(rndMut(k,it),:),etaM,lb,ub,1/nVar)
		end
		popMCost=f(popMPos)
		
		% merging populations
		popPos = [popPos; popCPos;popMPos]
		popCost = [popCost; popCCost; popMCost]
		 
		% sorting population
		[popCost, SortOrder] = sort(popCost)
		popPos = popPos(SortOrder,:)
		
		% Update Worst Cost
		WorstCost = max(WorstCost,popCost(end))

		% truncate
		popPos = popPos(1:nPop, :)
		popCost = popCost(1:nPop, :)
		
		BestCost(it)=popCost(1) % Store Best Cost Ever Found
		
		if trace
			traceIt{it,1} = popPos
			traceIt{it,2} = popCost
		end
		
		if dispit
			disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
		end
	end
			
	xmin = popPos(1,:)
	fmin = popCost(1)
	
	% Plot animation
	info = struct
	info.f = f
	info.trace = traceIt
	info.popPos0 = popPos0
	info.popCost0 = popCost0
	info.popPos = popPos
	info.popCost = popCost
	info.dim = nVar
	if ~isempty(o)
		info.o = o
		info.ub = ub
		info.lb = lb
		info.maxIt = maxIt
	end

end