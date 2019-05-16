function str = strjoin(c, delim)

	% joins text in cell c according to delimiters specified by delim.
	% The default delimiter is a single space 
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% c: cell array
	% delim: a single char o cell array with numel(c)-1 elements, to link each element
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% str: char object with the joined cell 	
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
	% strjoin({'a' 'b' 'c'},',')
	
	% check input type
	if ~iscell(c)
		error('first input must be a cell')
	elseif ~prod(cellfun(@ischar,c))
		error('first input must be a cell array of strings')	
	end
	
	n  = numel(c)
	% cell with values of cell c (1st row) and delimiters (2nd row)
	cdel = cell(2,n)
	cdel(1,:) = c
	if nargin < 2
		delim = {' '}
	elseif ischar(delim)
		delim = {delim}
	end

	cdel(2,1:n-1) = delim
	str = [cdel{:}]

end