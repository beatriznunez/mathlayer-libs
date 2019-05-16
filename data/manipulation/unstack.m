function out = unstack(t,vars,ivar,name,value)

	% returns the unstacked table corresponding to the table t
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% t (table): table to unstack
	% vars (string): column that will be used to fill the output table (except from first column)
	% ivar (string): the index column. It's (unique) values will define the output column names
	% value (function handle)
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% out: unstacked table
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
	% ticker = {'x1';'x1';'x2';'x2';'x3';'x3';'x3'}
	% date = {'20160731';'20160730';'20160731';'20160730';'20160731';'20160730';'20160729'}
	% value = [10;12;9;5;-2;17;-3]
	% t = table(ticker,date,value)
	% unstack(t,'value','ticker')

	if ~strcmp(class(t),'table'), error('1st input must be a table'); end
	if ~ischar(vars) | size(vars,1)~=1, error('2nd input must be a single string specifying value column'); end
	if ~ischar(ivar) | size(ivar,1)~=1, error('3rd input must be a single string specifying unstack column'); end
	ivarcol = strcmp(ivar,t.variablenames)
	varscols = strcmp(vars,t.variablenames)
	if all(~ivarcol), error([ivar ' column not found in table']); end
	if all(~varscols), error([vars{1} ' column not found in table']); end
	
	op = []
	if nargin > 4, op = value; end
		
	keys = ~strcmp(ivar, t.variablenames) & ~strcmp(vars,t.variablenames)
	t = sortrows(t,t.variablenames(keys))

	ivarvalues = t{:,ivarcol}
	[newcols, ~, inewcols] = unique(ivarvalues)

	if isnumeric(newcols), newcols = num2str(newcols); end

	pivot = t(:,keys)
	[upivot, ~, iupivot] = unique(pivot)%,'stable')
	
	nk = numel(keys)
	nc = numel(newcols)
	
	nrout = height(upivot)
	if nrout == height(t)
		error('unstacking with these paramters leads to the same number of rows: what you are trying to do probably does not make sense.')
	end
	tmp = array2table(nan(nrout, nc))
	tmp.variablenames = cast(newcols,'cell')
	out = [upivot tmp]
	nc = nc + width(pivot)
	nk = width(pivot) + 1
	values = t{:,varscols}
	
	nr = height(pivot)
	nc2 = nc-nk+1
	
	if isempty(op)
	
		for i = nk:nc
			idx = strcmp(newcols(i-nk+1),ivarvalues)
			uidx = iupivot(idx)
			out{uidx,i} = values(idx)
		end
		%out{:,nk:nc} = unstackcpp(ivarvalues, inewcols-1, newcols, iupivot - 1, values, nrout)
				
	else % apply operation
	
		for i = 1:nrout
			idi = ismember(iupivot, i)
			for j = nk:nc
				id = idi & strcmp(ivarvalues, newcols(j-nk+1))
				if sum(double(id)) > 0
					out{i,j} = op(values(id))
				end
			end		
		end
		
	end
	
end