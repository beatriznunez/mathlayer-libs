function graphs = optimview(type,op)

	f = op.f
	if isfield(op,'o'), o = op.o; else, o = struct; end
	trace = op.trace
	if isfield(op,'lb'), lb = op.lb; end
	if isfield(op,'ub'), ub = op.ub; end

	% inializate
	popPos = []
	popCost = []
	% info = []
	
	% animate options
	animfreq = 1 	% frame frequency
	animstart = 1 	% inicial frame to start animation

	if isfield(op,'animfreq'), animfreq = op.animfreq; end
	if isfield(op,'animstart'), animstart = op.animstart; end	
	if isfield(op,'animfreq'), animfreq = op.animfreq; end	
	
	switch type
	case 'fminsearch'
		dim = op.dim
		nit = op.nit
		x0 = op.x0
		
		sol = [] 	% solution
		np = 10 	% number of points for meshgrid
		os = struct('markerSize', 3, 'markerFill', 'red') 		% plotting options for trace
		osol = struct('markerSize', 3, 'markerFill', '#404040') % plotting options for solution
		if isfield(op,'sol'), sol = op.sol; end
		if isfield(op,'np'), np = op.np; end
		if isfield(op,'os'), os = op.os; end
		if isfield(op,'osol'), osol = op.osol; end
		
		if dim ~= 2
			error('only problems with 2 dimensions can be animated')
		else
			if isempty(ub), ub = max(trace.x(:)); end
			if isempty(lb), lb = min(trace.x(:)); end
			if numel(lb) == 1 && numel(ub) == 1
				[x,y] =  meshgrid(linspace(lb(1),ub(1),np(1)))
			else
				if numel(np) == 1, np = [np np]; end
				if numel(lb) == 1, lb = [lb lb]; end
				if numel(ub) == 1, ub = [ub ub]; end
				[x,y] = meshgrid(linspace(lb(1),ub(1),np(1)), linspace(lb(2),ub(2),np(2)))
			end

			po = struct('show',false)
			po.xAxisMin = min(min(x))
			po.xAxisMax = max(max(x))
			po.yAxisMin = min(min(y))
			po.yAxisMax = max(max(y))
			idx = rem(nit,animfreq):animfreq:nit
			idx(idx<animstart) = []
			c = cell(size(idx,2), 1) % initialize cell array to contain graphs

			for i = 1:numel(c)
				it = idx(i)
				po.titleAnchor = 'start'
				po.titleX = 0
				po.title = ['Step:' sprintf('%03d',it) ' - f(' sprintf('%.2f',trace.x(it,1)) ',' sprintf('%.2f',trace.x(it,2)) ') = ' sprintf('%.3f',trace.f(it))] 
				if isempty(sol)
					c{i} = surf({x trace.x(it,1)},{y trace.x(it,2)},... 
				{f([x(:) y(:)]) trace.f(it)},{po os})
				else
					c{i} = surf({x trace.x(it,1) sol(1)},{y trace.x(it,2) sol(2)},... 
				{f([x(:) y(:)]) trace.f(it) sol(3)},{po os osol})
				end
			end
			if animstart == 1
				os.show = false
				po.title = ['Step:000 - f(' sprintf('%.2f',x0(1)) ',' sprintf('%.2f',x0(2)) ') = ' sprintf('%.3f',f(x0))] 
				if isempty(sol)
					c0{1} = surf({x x0(1)},{y x0(2)},... 
				{f([x(:) y(:)]) f(x0)},{po os})
				else
					c0{1} =  surf({x x0(1) sol(1)},{y x0(2) sol(2)},... 
					{f([x(:) y(:)]) f(x0) sol(3)},{po os osol})
				end
				c = [c0;c]
			end
			graphs = animate(c, struct('timelapse', 250))	
		end
	
	case 'ga'
		np = 10 	% number of points for meshgrid
		dim = op.dim
		maxIt = op.maxIt
		popPos0 = op.popPos0
		popCost0 = op.popCost0
		popCost = op.popCost
		popPos = op.popPos
		
		if dim ~= 2 & dim ~= 1
			error('only problems with 1 or 2 dimensions can be animated')
		else
			sol = [] % solution
			os = struct('markerSize', 3, 'markerFill', 'red','show',false) % plotting options for trace
			osol = struct('markerSize', 3, 'markerFill', '#404040','show',false) % plotting options for solution
			if isfield(op,'np'), np = op.np; end
			if isfield(op,'sol'), sol = op.sol; end
			if isfield(op,'os'), os = op.os; end
			if isfield(op,'osol'), osol = op.osol; end
		
			idx = rem(maxIt,animfreq):animfreq:maxIt
			idx(idx<animstart) = []
			c = cell(size(idx,2),1) % initialize cell array to contain graphs
			
			po = struct('show',false) % global plot options
			po.titleAnchor = 'start'
			po.titleX = 0
			
			if dim == 2 % 2D problems
			
				if numel(lb) == 1 && numel(ub) == 1 % calculate x,y,z
					[x,y] =  meshgrid(linspace(lb(1),ub(1),np(1)))
				else
					if numel(np) == 1, np = [np np]; end
					if numel(lb) == 1, lb = [lb lb]; end
					if numel(ub) == 1, ub = [ub ub]; end
					[x,y] = meshgrid(linspace(lb(1),ub(1),np(1)), linspace(lb(2),ub(2),np(2)))
				end
				z = f([x(:),y(:)])
			
				po.xAxisMin = min(min(x))
				po.xAxisMax = max(max(x))
				po.yAxisMin = min(min(y))
				po.yAxisMax = max(max(y))
				po.zAxisMin = min(min(z))
				po.zAxisMax = max(max(z))
				for i = 1:numel(c)
					it = idx(i)
					aux = trace{it,1}
					aux2 = trace{it,2}
					po.title = ['Step:' sprintf('%03d',it) ' - min cost: f(' sprintf('%.2f',aux(1,1)) ',' sprintf('%.2f',aux(1,2)) ') = ' sprintf('%.3f',aux2(1))] 
					if isempty(sol)
						c{i} = surf({x aux(:,1)},{y aux(:,2)},... 
					{z trace{it,2}},{po os})
					else
						c{i} = surf({x aux(:,1) sol(1)},{y aux(:,2) sol(2)},... 
					{z trace{it,2} sol(3)},{po os osol})
					end
				end
				
				if animstart == 1
					po.title = ['Step:000 - min cost:  f(' sprintf('%.2f',popPos0(1)) ',' sprintf('%.2f',popPos0(2)) ') = ' sprintf('%.3f',popCost0(1))] 
					if isempty(sol)
						c0{1} = surf({x popPos0(:,1)},{y popPos0(:,2)},... 
					{z popCost0},{po os})
					else
						c0{1} =  surf({x popPos0(:,1) sol(1)},{y popPos0(:,2) sol(2)},... 
						{z popCost0 sol(3)},{po os osol})
					end
					c = [c0;c]
				end
			else % 1D problems
				x = linspace(lb, ub, np) % calculate x,f(x)
				for i = 1:numel(c)
					it = idx(i)
					auxX = trace{it,1}
					auxY = trace{it,2}
					po.title = ['Step:' sprintf('%03d',it) ' - min cost: f(' sprintf('%.2f',auxX(1)) ') = ' sprintf('%.3f',auxY(1))] 
					s1 = scatter(trace{it,1}, trace{it,2},os)
					p1 = plot(x, f(x),po)
					if isempty(sol)
						c{i} = overlay({p1,s1},po)
					else
						c{i} = overlay({p1,s1,scatter(sol(1), sol(2), osol)},po)
					end
				end
				if animstart == 1
					po.title = ['Step:000 - min cost:  f(' sprintf('%.2f',popPos0(1)) ') = ' sprintf('%.3f',popCost0(1))] 
					if isempty(sol)
						c0{1} = overlay({p1,scatter(popPos0, popCost0,os)},po)
					else
						c0{1} = overlay({p1,scatter(popPos0, popCost0,os), scatter(sol(1), sol(2), osol)},po)
					end
					c = [c0;c]
				end
			end
		end
		graphs = animate(c, struct('timelapse', 250))
			
	case 'lsqcurvefit'
		plotanim = false
		if isfield(op,'animate'), plotanim = op.animate; end

		x = op.x
		y = op.y
		info = [op.nit; op.sse0; op.sse]
		b = op.b

		po = struct('show',false)
		xmin = min(x)
		xmax = max(x)
			if ~plotanim
				po2 = struct('show',true)
				po2.titleAnchor = 'start'
				po2.titleX = 0
				po2.title = ['Step:' sprintf('%03d',info(1)) ' - SSE:' sprintf('%03d',info(3)) ' - Initial SSE:' sprintf('%03d',info(2)) ]
				switch size(x,2)
				case 1
					xl = linspace(xmin,xmax,100)
					graphs = overlay({plot(xl,f(xl,b),po),scatter(x,y,po)})
				case 2
					xl1 = linspace(xmin(1),xmax(1),20)'
					xl2 = linspace(xmin(2),xmax(2),20)'
					[xl1 xl2] = meshgrid(xl1,xl2)
					po.surfOpanity = 0
					po.markerSize = 3
					graphs = surf({xl1 x(:,1)},{xl2 x(:,2)},{f([xl1(:) xl2(:)],b) y},{po2 po})
				otherwise
					error('cannot plot problems having 3 dimensions or more')
				end
			else
				sse = trace{1}
				btr = trace{2}
				itvect = trace{3}
				nit = numel(itvect)
				idx = rem(nit,animfreq):animfreq:nit
				idx = unique(sort([1 idx]))
				idx(idx<animstart) = []
				c = cell(size(idx,2), 1) % initialize cell array to contain graphs
				switch size(x,2)
				case 1
					po.yAxisMin = min(min(f(x,b)),min(y))
					po.yAxisMax = max(max(f(x,b)),max(y))
					po.lineStroke = '#cc6600'
					xl = linspace(xmin,xmax,100)
					for i = 1:numel(c)
						it = idx(i)
						po.titleAnchor = 'start'
						po.titleX = 0
						po.title = ['Step:' sprintf('%03d',itvect(it)) ' - SSE:' sprintf('%10.4f',sse(it))] 
						c{i} = overlay({plot(xl,f(xl,btr(it,:)'),po),scatter(x,y,po)},po)
					end
				case 2
					po2 = struct('show',false)
					po2.zAxisMin = min(min(f(x,b)),min(y))
					po2.zAxisMax = max(max(f(x,b)),max(y))
					xl1 = linspace(xmin(1),xmax(1),20)'
					xl2 = linspace(xmin(2),xmax(2),20)'
					[xl1 xl2] = meshgrid(xl1,xl2)
					po.surfOpanity = 0
					po.markerSize = 3
					for i = 1:numel(c)
						it = idx(i)
						po2.titleAnchor = 'start'
						po2.titleX = 0
						po2.title = ['Step:' sprintf('%03d',itvect(it)) ' - SSE:' sprintf('%10.4f',sse(it))]
						c{i} = surf({xl1 x(:,1)},{xl2 x(:,2)},{f([xl1(:) xl2(:)],btr(it,:)') y},{po2 po})
					end
				otherwise
					error('cannot plot problems having 3 dimensions or more')
				end
				graphs = animate(c)
			end

			
	case 'nsga2'
		dim = op.dim
		maxIt = op.maxIt
		popCost = op.popCost
		popPos = op.popPos
		nObj = op.nObj
	
		plotanim = false
		if isfield(op,'animate'), plotanim = op.animate; end
		gpo = struct('show',false,'timelapse', 250) % global plot options
		gpo2 = gpo
		gpo2.markerFill = 'red'
		graphs = cell(1,4)
		if plotanim
			po = struct('show',false)
			po.titleAnchor = 'start'
			po.titleX = 0
			idx = rem(size(trace,1),animfreq):animfreq:size(trace,1)
			idx = unique(sort([1 idx]))
			idx(idx<animstart) = []
			if nObj == 1
				error('cannot plot Pareto front on single objective problems')
			elseif nObj == 2
				tmp6 = trace(idx,6)
				tmp3 = trace(idx,3)
				if isfield(op,'xAxisMin'), po.xAxisMin = op.xAxisMin;
				else, po.xAxisMin = min(cellfun(@(x) min(x(:,1)),tmp6)); end
				if isfield(op,'xAxisMax'), po.xAxisMax = op.xAxisMax;
				else, po.xAxisMax = max(cellfun(@(x) max(x(:,1)),tmp6)); end
				if isfield(op,'yAxisMin'), po.yAxisMin = op.yAxisMin;
				else, po.yAxisMin = min(cellfun(@(x) min(x(:,2)),tmp6)); end
				if isfield(op,'yAxisMax'), po.yAxisMax = op.yAxisMax;
				else, po.yAxisMax = max(cellfun(@(x) max(x(:,2)),tmp6)); end
				c = cellfun(@(x) scatter(x(:,1),x(:,2),po),tmp3,'uniformoutput',false)
				po.markerFill = 'red'
				cfront = cellfun(@(x) scatter(x(:,1),x(:,2),po),tmp6,'uniformoutput',false)
				for i = 1:numel(c)
					it = idx(i)
					po.title = ['Step:' sprintf('%03d',it) ' - front count = ' num2str(numel(trace{it,2})) ]
					c{i} = overlay({c{i},cfront{i}},po)
				end
			elseif nObj == 3
				tmp6 = trace(idx,6)
				if isfield(op,'xAxisMin'), po.xAxisMin = op.xAxisMin;
				else, po.xAxisMin = min(cellfun(@(x) min(x(:,1)),tmp6)); end
				if isfield(op,'xAxisMax'), po.xAxisMax = op.xAxisMax;
				else, po.xAxisMax = max(cellfun(@(x) max(x(:,1)),tmp6)); end
				if isfield(op,'yAxisMin'), po.yAxisMin = op.yAxisMin;
				else, po.yAxisMin = min(cellfun(@(x) min(x(:,2)),tmp6)); end
				if isfield(op,'yAxisMax'), po.yAxisMax = op.yAxisMax;
				else, po.yAxisMax = max(cellfun(@(x) max(x(:,2)),tmp6)); end
				if isfield(op,'zAxisMin'), po.zAxisMin = op.zAxisMin;
				else, po.zAxisMin = min(cellfun(@(x) min(x(:,3)),tmp6)); end
				if isfield(op,'zAxisMax'), po.zAxisMax = op.zAxisMax;
				else, po.zAxisMax = max(cellfun(@(x) max(x(:,3)),tmp6)); end
				c = cellfun(@(x) scatter(x(:,1),x(:,2),po),tmp6,'uniformoutput',false)
				po2 = po
				po2.markerFill = 'red'
				for i = 1:numel(c)
					it = idx(i)
					po.title = ['Step:' sprintf('%03d',it) ' - front count = ' num2str(numel(trace{it,2})) ]
					x = trace{i,3}
					xf = trace{i,6}
					c{i} = scatter3({x(:,1) xf(:,1)},{x(:,2) xf(:,2)},{x(:,3) xf(:,3)},{po po2})
				end
			else
				error('cannot plot Pareto front on problems having 4 or more objectives')
			end
			graphs{1} = animate(c,gpo)
		else
			costs = popCost(f{1},:)
			if nObj == 1
				error('cannot plot Pareto front on single objective problems')
			elseif nObj == 2
				graphs{2} = overlay({scatter(costs(:,1),costs(:,2),gpo) scatter(popCost(:,1),popCost(:,2),gpo2)},gpo)
			elseif nObj == 3
				graphs{2} = scatter3({costs(:,1) popCost(:,1)},{costs(:,2) popCost(:,2)},{costs(:,3) popCost(:,3)},{gpo gpo2})
			else
				error('cannot plot Pareto front on problems having 4 or more objectives')
			end
		end

		if plotpos
			if plotanim
				po = struct('show',false)
				idx = rem(size(trace,1),animfreq):animfreq:size(trace,1)
				idx(idx<animstart) = []
				if dim == 1
					tmp1 = trace(idx,1)
					tmp5 = trace(idx,5)
					po.yAxisMin = min(cellfun(@(x) min(x(:,2)),tmp1))
					po.yAxisMax = max(cellfun(@(x) max(x(:,2)),tmp1))
					c = cellfun(@(x) scatter(x,po),tmp1,'uniformoutput',false)
					po.markerFill = 'red'
					cfront = cellfun(@(x) scatter(x,po),tmp5,'uniformoutput',false)
					for i = 1:numel(c)
						it = idx(i)
						po.title = ['Step:' sprintf('%03d',it) ' - front count = ' num2str(numel(trace{it,2})) ]
						c{i} = overlay({c{i},cfront{i}},po)
					end				
				elseif dim == 2
					tmp1 = trace(idx,1)
					tmp5 = trace(idx,5)
					po.xAxisMin = min(cellfun(@(x) min(x(:,1)),tmp1))
					po.xAxisMax = max(cellfun(@(x) max(x(:,1)),tmp1))
					po.yAxisMin = min(cellfun(@(x) min(x(:,2)),tmp1))
					po.yAxisMax = max(cellfun(@(x) max(x(:,2)),tmp1))
					c = cellfun(@(x) scatter(x(:,1),x(:,2),po),tmp1,'uniformoutput',false)
					po.markerFill = 'red'
					cfront = cellfun(@(x) scatter(x(:,1),x(:,2),po),tmp5,'uniformoutput',false)
					for i = 1:numel(c)
						it = idx(i)
						po.title = ['Step:' sprintf('%03d',it) ' - front count = ' num2str(numel(trace{it,2})) ]
						c{i} = overlay({c{i},cfront{i}},po)
					end				
				elseif dim == 3
					tmp1 = trace(idx,1)
					po.xAxisMin = min(cellfun(@(x) min(x(:,1)),tmp1))
					po.xAxisMax = max(cellfun(@(x) max(x(:,1)),tmp1))
					po.yAxisMin = min(cellfun(@(x) min(x(:,2)),tmp1))
					po.yAxisMax = max(cellfun(@(x) max(x(:,2)),tmp1))
					po.zAxisMin = min(cellfun(@(x) min(x(:,3)),tmp1))
					po.zAxisMax = max(cellfun(@(x) max(x(:,3)),tmp1))
					po2 = po
					po2.markerFill = 'red'
					for i = 1:numel(c)
						it = idx(i)
						po.title = ['Step:' sprintf('%03d',it) ' - front count = ' num2str(numel(trace{it,2})) ]
						x = trace{i,1}
						xf = trace{i,5}
						c{i} = scatter3({x(:,1) xf(:,1)},{x(:,2) xf(:,2)},{x(:,3) xf(:,3)},{po po2})
					end
				else
					error('cannot plot problems having 4 or more dimensions')
				end
				graphs{3} = animate(c,gpo)
			else
				pos = popPos(f{1},:)
				if dim == 1
					graphs{4} = overlay({scatter(pos,gpo) scatter(popPos,gpo2)},gpo)
				elseif dim == 2
					graphs{4} = overlay({scatter(pos(:,1),pos(:,2),gpo) scatter(popPos(:,1),popPos(:,2),gpo2)},gpo)
				elseif dim == 3
					graphs{4} = scatter3({pos(:,1) popPos(:,1)},{pos(:,2) popPos(:,2)},{pos(:,3) popPos(:,3)},{gpo gpo2})
				else
					error('cannot plot problems having 4 or more dimensions')
				end
			end
		end
		
		idx = cellfun(@isempty,graphs)
		graphs = graphs(~idx)
		if ~isempty(graphs)
			assemble(graphs)
		end
	end

end