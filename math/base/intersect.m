function c = intersect(a, b)
	% Determine if a and b are row vectors.
	rowvec = isrow(a) && isrow(b)
	if ~strcmp(class(a),'table')
		% Convert to columns.
		a = a(:);   
		b = b(:);
	end
	% concatenate and remove duplicated values
	c = unique(a(ismember(a, b)))
	% if a and b are rows, convert c to row
	if rowvec
		c = c.';
	end
end