function df = table2json(t)

	% table2json(t) converts a mathlayer® table t into a json string
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% t: table
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% df: json string	
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
	% table2json(table([1; NaN; 2], {'a';'b';'c'}))#
	
	% call table2dataframe ignoring rownames
	df = table2dataframe(t, true)
end