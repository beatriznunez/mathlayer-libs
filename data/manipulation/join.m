function out = join(a,b,o1,v1,o2,v2,type)

	[nra nca] = size(a)

	if isempty(type)
		type = 'inner'
	else
		if isempty(o1)
			nargin = 2
		elseif isempty(o2)
			nargin = 4
		else
			nargin = 6
		end
	end
	if ~strcmp(class(a),'table') | ~strcmp(class(b),'table'), error('expected table input arguments'); end
	
	avt = a.variabletypes
	bvt = b.variabletypes

	if nargin == 2	
		% columns of a that are in b too will define keys
		% ib: is column of a in b
		% wib: where in b
		% ia: is column of b in a
		% wia: where in a
		[ia wia] = ismember(b.variablenames, a.variablenames)
				
		wia = wia(ia)
		nc = numel(wia)
		
		ncb = size(b,2)
		wib = 1:ncb
		wib = wib(ia)
		
		% make sure there are common columns
		if isempty(ia), error('no common columns found'); end
		
	elseif nargin == 4
	
		if ~ischar(o1) | ~strcmpi(o1,'keys') | ~isreal(v1), error('invalid option type'); end
		if numel(v1) == 0 | ~isequal(v1,unique(v1,'stable')) | min(v1) < 1 | max(v1) > min(size(a,2),size(b,2)), error('invalid options'); end
		wia = v1
		wib = v1
		ia = ismember(1:size(b,2), wib)
				
	elseif nargin == 6

		if ~ischar(o1) | ~strcmpi(o1,'leftkeys') & ~strcmpi(o1,'rightkeys') | ~isreal(v1), error('invalid option type'); end
		if ~ischar(o2) | ~strcmpi(o2,'leftkeys') & ~strcmpi(o2,'rightkeys') | ~isreal(v2), error('invalid option type'); end
		if strcmpi(o1,o2), error('invalid options'); end
		
		if strcmpi(o1,'rightkeys')
			tmp = v1
			v1 = v2
			v2 = tmp
		end
		if numel(v1) == 0 | ~isequal(v1,unique(v1,'stable')) | min(v1) < 1 | max(v1) > min(size(a,2)), error('invalid options'); end
		if numel(v2) == 0 | ~isequal(v2,unique(v2,'stable')) | min(v2) < 1 | max(v2) > min(size(b,2)), error('invalid options'); end
		wia = v1
		wib = v2
		ia = ismember(1:size(b,2), wib)

	else

		error('wrong number of input arguments')

	end
	
	% make sure variable types are consistent
	avt = avt(wia)
	bvt = bvt(wib)
	if sum(~strcmp(avt,bvt)) > 0, error('inconsistent key column types'); end

	% find common rows based on keys
	fca = a(:,wia)
	fcb = b(:,wib)
	[ib0 wib0] = ismember(fca, fcb, 'rows') % get the keys of "a" that are in "b"
	wib0 = wib0(ib0) % keep first matches
	
	brows = (1:size(b,1))'
	ibrows = ~ismember(brows,wib0)
	[ia0 wia0] = ismember(fcb, fca, 'rows') % get keys of "b" that are in "a"
	idb = ia0 & ibrows % keep the keys of "b" that are in "a" that where omitted in initial ismember
	clear('fca','fcb')
	posab = sortrows([find(ib0) wib0; wia0(idb) find(idb)])
	
	% disp(ia)
	% disp(ib0)
	switch type
	case 'inner'
		if ~isempty(posab), out = [a(posab(:,1),:) b(posab(:,2),~ia)]; end
		
	case 'left'
		bex = b(1,~ia)
		nbexc = size(bex,2)
		for i = 1:nbexc
			if isnumeric(bex{1,i})
				bex{1,i} = nan
			else
				bex{1,i} = {''}
			end
		end

		arowsleft = setdiff(1:nra, posab(:,1))
		if numel(arowsleft)>0
			b = [b(:,~ia);bex]
			posab = sortrows([posab; arowsleft size(b,1)*ones(numel(arowsleft),1)])
		end

		out = [a(posab(:,1),:) b(posab(:,2),:)]
		
		% %bex(ib0,:) = b(wib0,~ia)
		% out = [a bex]
		% out(ib0,nca+1:end) = b(wib0,~ia)
		% out = [out; a(arows(idb),:) b(find(idb),~ia)]
		
	case right
		error(['join type "' type '" not handled'])
		
	otherwise
		error(['join type "' type '" not handled'])
		
	end
	
	clear('a','b')
	
end