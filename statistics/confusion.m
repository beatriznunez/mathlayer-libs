function [conf metrics act pred] = confusion(act,pred,pos,thr)

	% https://en.wikipedia.org/wiki/Confusion_matrix
	%========================
	% input arguments:
	% act: column vector with actual classes
	% pred: column vector with predicted classes
	% pos (optional): string specifying the positives

	if isempty(pos), pos = true; end
	
	[nr nc] = size(act)
	[nr2 nc2] = size(pred)
	if nr ~= nr2 || nc ~= nc2 || nc ~=1, error('act and pred must be equally sized column vectors'); end

	if iscell(act)
		if ~ischar(pos), error('pos has to be a value in act'); end
		actpos = strcmp(pos,act)
		if iscell(pred), predpos = strcmp(pos,pred); else predpos = pred >= thr; end
	else
		if ~isempty(thr) && ~prod(ismember(pred,act)) == 1, pred = pred >= thr; end
		actpos = act == pos
		predpos = pred == pos
	end
	
	tp = double(actpos & predpos)
	tn = double(~actpos & ~predpos)
	fn = double(actpos & ~predpos)
	fp = double(~actpos & predpos)
	TPR = sum(tp)/(sum(tp+fn))
	FPR = sum(fp)/(sum(fp+tn))
	
	conf = [sum(tp) sum(fn); sum(fp) sum(tn)]
	
	totalpopulation = nr
	accuracy = sum(tp + tn) / totalpopulation
	precision = sum(tp) / sum(tp+fp)
	F1score = 2*sum(tp)/(2*sum(tp)+sum(fp+fn))
	% recall = sum(tp)/sum(tp+fn)
	%prevalence = 
	metrics = [accuracy precision F1score TPR FPR]

end