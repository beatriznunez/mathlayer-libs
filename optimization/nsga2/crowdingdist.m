function cd = crowdingdist(popCost,F)

	cd = nan(size(popCost,1),1)
	nF = numel(F)
	for k = 1:nF
		tmpF = F{k}
		costs = popCost(tmpF,:)'
		nObj = size(costs,1)
		n = numel(tmpF)
		d = zeros(n,nObj)
		for j = 1:nObj
			[cj, so] = sort(costs(j,:))
			d(so(1),j) = inf
			for i = 2:n-1
				d(so(i),j) = abs(cj(i+1)-cj(i-1))/abs(cj(1)-cj(end))
			end
			d(so(end),j) = inf
		end

		for i = 1:n
			cd(tmpF(i)) = sum(d(i,:))
		end
	end
	
end