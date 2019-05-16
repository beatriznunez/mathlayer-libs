function t = struct2table(s)
	
	% converts the struct s into a table
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% s: struct object with only one level of struct and fields with the same number of elements
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% t: table object
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
	% struct2table(struct('a',10))
	
	
	% check input type
	if ~isstruct(s)
		error('input must be a struct')
	end
	
	fields = fieldnames(s)
	nc = numel(fields)			% number of columns for table t
	nr = size(s.(fields{1}),1)	% number of rows for table t
	t =  cell2table(cell(nr,nc))% initialize table t
	t.variableNames = fields

	for i = 1:nc
		c = s.(fields{i})
		if iscell(c)
			if numel(c) == 1, c = c{:} % for char object
			elseif numel(c) ~= nr
				error('fields must have the same number of rows')
			end
		elseif isstruct(c) | istable(c)
			error('field type not allowed')
		end
		if size(c,1) ~= nr
			error('fields must have the same number of rows')
		end
		if isempty(c), c = ' '; end
		t(:,i) =  c
	end
end