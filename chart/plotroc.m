function [out TPR FPR AUC] = plotroc(act,pred,pos,thr,options)
	
	op = options
	
	if isstruct(thr), options = thr, thr = []; end
	if isstruct(pos), options = pos, pos = []; end

	if isempty(pos), pos = true; end

	if numel(thr) > 1 && ~ischar(thr)
		for i = 1:numel(thr)
			op.show = false
			c{i} = plotroc(act,pred,pos,thr(i),op)
		end
		if isfield(op,'confTable') && strcmp(options.confTable,'plot'), options.height = 730; end
		out = animate(c,options)
		return
	end
	
	% control if act has less than 2 different values
	a=1
	sortact = sort(act)
	for i=1:(size(sortact,1)-1)
		if ~isequal(sortact(i),sortact(i+1)), a = a + 1; end
	end
	if a>2, error('only two diferent values handled in act'); end

	if iscell(act)
		if ~ischar(pos), error('pos has to be a value in act'); end
		actpos = strcmp(pos,act)
		if iscell(pred), predpos = strcmp(pos,pred); else, predpos = pred; end
	else
		if prod(ismember(pred,act)) == 1, predpos = pred == pos; else predpos = pred; end
		actpos = act == pos
	end

	n = numel(actpos)
	anim = false
	AP = sum(actpos)			% true positives
	AN = n-AP				% true negatives
	FPR = nan(n,1)		% false positives rate
	TPR = nan(n,1)		% true positives rate

	options.xAxisMin = 0
	options.xAxisMax = 1
	options.yAxisMin = 0
	options.yAxisMax = 1
	options.xAxisName = 'False Positive Rate'
	options.yAxisName = 'True Positive Rate'
	options.type = 'plotroc'
	
	sortedap = sortrows([actpos predpos],-2)	% sort labels based on predictions
	sortedact = sortedap(:,1)
	TPR = cumsum(sortedact)/AP
	FPR = ((1:n)'-TPR*AP)/AN
	x = [0;FPR]
	dx = x(2:end) - x(1:end-1)
	AUC = sum(dx.*TPR)
	options.title = [' ROC Curve - AUC: ' num2str(AUC*100,2) '%']
	
	if isfield(options,'confTable') && strcmp(options.confTable,'plot')
		options.show = false
	end
	
	opt = options
	opt.show = false
	opt.markerFill = 'red'
	
	diagonal = plot([0,1],[0,1],struct('lineStroke','#bfbfbf','show',false))
	
	if ~isempty(thr)

		[~,metrics,~,~] = confusion(actpos,predpos,[],thr)
		a = metrics(4)
		b = metrics(5)
		out = overlay({plot(FPR,TPR,opt),scatter(b,a,opt),diagonal},options)

	else
		out = overlay({plot(FPR,TPR,opt),diagonal},options)	
	end

	if isfield(options,'confTable') && strcmp(options.confTable,'plot')
		opt.show = false
		out = assemble({out,plotconfusion(act,pred,pos,thr,opt)},op)
	end

	
end