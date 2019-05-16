function [popInfo,popPos,popCost,F] = sortpopulation(popInfo,popPos,popCost)

	% % sort on crowding distance and on rank
	% [~, idx] = sortrows([-popInfo(:,2) popInfo(:,1)])
	% popInfo = popInfo(idx,:)
	% popPos = popPos(idx,:)
	
	% sort on crowding distance
	[~, idx] = sort(popInfo(:,2),'descend')
	popInfo = popInfo(idx,:)
	popPos = popPos(idx,:)
	popCost = popCost(idx,:)
	
	% sort on rank
	[~, idx] = sort(popInfo(:,1))
	popInfo = popInfo(idx,:)
	popPos = popPos(idx,:)
	popCost = popCost(idx,:)
	
	% update fronts
	ranks = popInfo(idx,1)
	maxrank = max(ranks)
	F = cell(maxrank,1)
	for r = 1:maxrank
		F{r} = find(ranks==r)
	end	
	
end