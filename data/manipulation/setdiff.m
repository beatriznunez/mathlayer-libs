function c = setdiff(a, b)

	% returns the data in a that is not in b in ascending order and without repetition
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% a,b: arrays of the same class
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% c: set difference
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
	% A = [9 7 1 4 5 1]
	% B = [4 5 9]
	% setdiff(A,B)#
	
	if ~istable(a)	% Convert to columns
		a = a(:)   
		b = b(:)
	end

	% determine non-matching elements of a
	c = a(~ismember(a,b))
	% remove duplicate values
	c = unique(c)

	% if a is rows, convert c to row
	if isrow(a), c = c'; end
		
end