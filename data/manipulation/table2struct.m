function s = table2struct(t,varargin)

	% converts table t into a struct
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% t: table
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% s: struct
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
	% table2struct(table([1; NaN; 2], {'a';'b';'c'}))#
	
	s = struct
	vn = t.variablenames
	for i = 1:numel(vn)
		s(vn{i}) = t{:,i}
	end
end