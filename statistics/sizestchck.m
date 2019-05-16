function [err, x1, x2, x3] = sizestchck(x1, x2, x3, opt)
	% sizestchck: can perform two separate actions: 'check' and 'expand' or both 
	%           consecutively. If only 'check' is performed, then sizestchck checks 
	%           the size of the numerical input arguments. If they have the same 
	%           size or are scalars, then no error is found and err is set to false. 
	%           If only 'expand' is performed, sizestchck does not look at whether 
    %           the numerical inputs have the same size or are scalars, but tries 
	%           to expand the numerical inputs to have the same size as the 
	%           biggest one. If this is achievable, then no error is found and err 
	%           is set to false. If neither the option 'check' or 'expand' is 
    %           specified, then sizestchck performs both actions, i.e. checks whether 
	%           all inputs have the same size or are scalars and, if no error is found, 
	%           it tries to expand them to match the size of the biggest/dominant input.
	% 
	% Input arguments:
	%		x1, x2, x3: scalars, vectors or matrices containing numerical data.
	%       opt: it can be 'check' or 'expand' to perform only a check of sizes
	%            or an expansion of the input arguments. If nothing is stated, 
	%            then both actions are performed consecutively.
	%
	% Ouputs:
	% 	err: logical variable. If err is false, then x1, x1 and x3 had originally
	%        the same size or were scalars or can be expanded to have the same size. 
	%        If err is true, then x1, x2 and x3 did not have all the same size or 
	%        were scalars or could not be expanded to a common size. Then err can be 
	%        used to trigger an error message.
	%	x1:  identical or expanded input argument x.
	%   x2:  identical or expanded input argument y.
	%   x3:  identical or expanded input argument z.
	%
	%
	% Examples:
    %
	% 	>> [err, x, y, z] = sizestchck([1 2; 3 4], [5 6; 7 8], 33.33)
    % 	[err:false]
    % 	[x:2x2 double]
    % 	[y:2x2 double]
    % 	[z:2x2 double]
	%
	% 	>> x#
	%           1        2
	%           3        4
	%
	% 	>> y#
	%           5        6
	%           7        8
	%
	% 	>> z#
	%       33.33    33.33
	%       33.33    33.33
	%
	%	>> [err, x, y, z] = sizestchck([1 2; 3 4], [1 2], 33.33)
	%	[err:true]
    %   [x:2x2 double]
    %   [y:1x2 double]
    %   [z:33.33]
	%

    %
	% Copyright (C) 2019 Tenokonda Ltd.
	%	

	% Error message header.
	msg = ': In function sizestchck(x1, x2, x3, opt) '

	% Error if too few inputs.
	if isempty(x3) & isempty(x2), error(strcat(msg, 'you should specify at least x1 and x2.')); end

	% Initializes actions to be performed.
	check = false
	expand = false
	both = false

	switch nargin 
		% When an option is specified.
		case 4	
			% Checks opt is of type char.
			if ~ischar(opt), error(strcat(msg, 'opt must be of type char.')); end
		
			% Gets the action to perform.
			check = strcmp(opt, 'check')     
			expand = strcmp(opt, 'expand')
		
			% Error if wrong option.
			if ~check & ~expand, error(strcat(msg, 'unrecognized value for opt.')); end

		% If no options are specified.
		otherwise            
			both = true     % States to perform both actions.
	end

	% States the number of numerical inputs.
	numin = 3 
	if isempty(x3), numin = 2; end

	% ###
	% ### Performs the cheking and/or the expansion ###
	% ###

	% Initializes error ouput.
	err = true

	% Case: 3 numerical input arguments.
	if numin == 3
		if check | both
			err = check_common_size(x1, x2, x3)
		end
		if expand | (both & ~err)
			[err, x1, x2, x3] = expand_common_size(x1, x2, x3)
		end
	end

	% Case: 2 numerical input arguments.
	if numin == 2
		if check | both
			err = check_common_size(x1, x2)
		end
		if expand | (both & ~err)
			[err, x1, x2] = expand_common_size(x1, x2)
		end
	end

end 


function err = check_common_size(x, y, z)
	% check_common_size: checks whether x, y and z have the same size or are scalars. It
	%                    returns err = true if an error is found, i.e. if not all the input 
	%	                 arguments are the same size or scalars.
	%
	% Input arguments:
	%		x, y, z: scalars, vectors or matrices containing data.
	%
	% Ouput:
	% 	err: logical variable containing information about whether x, y, and z have all the 
	%        same size or are scalars. If all have the same size, err is set to false. If not
	%        all them have the same size or are scalars, then err is set to true and can be 
	%		 used to trig an error message.
	% 
	% Examples:
	% >> err = check_common_size([1 2], [3 4], 5)
	% [err:false]
	%
	% >> err = check_common_size([1 2; 1 2], [3 4], 5)
	% [err:true]

	%
	% Copyright (C) 2019 Tenokonda Ltd.
	%

	% Checks the number of input arguments.
	if nargin == 3, nv = 3; end
	if nargin == 2, nv = 2; end
	if nargin == 1, error(': check_common_size(x, y, z) requires at least two input arguments.'); end

	% Initialize cell to hold input arguments (real and imaginary parts).
	v = cell(1, nv)

	% Put the input arguments (real values) into an cell array. 
	v(1) = {x}
	v(2) = {y}
	if nargin == 3, v(3) = {z}; end

	% Initialize error flag.
	err = false

	% Number of elements.
	nel = cellfun(@numel, v)

	% Find indices of scalars.
	scid = (nel == 1)

	% Find whether all input arguments are scalars.
	allInputsScalars = (sum(scid) == nv)

	% If all input arguments are scalars, then error is set to false
	% and nothing else is done.
	if allInputsScalars

		err = false

	% If not all the input arguments are scalars, then their size is checked.
	else

		% Get the number of rows of each non-scalar input argument.
		nr = cellfun(@(x) size(x, 1), v(~scid))

		% Get the number of columns of each non-scalar input argument.
		nc = cellfun(@(x) size(x, 2), v(~scid))

		% Error set to true if not all input arguments have the same 
		% number of rows.
		err = ~all(nr == nr(1))

		% Error set to true if not all input arguments have the same 
		% number of columns.
		err = err | ~all(nc == nc(1))

	end

end


function [err, x, y, z] = expand_common_size(x, y, z)
	% expand_common_size: checks whether x, y and z have compatible sizes or are scalars.
	%                     By "compatible" size we mean that the function finds out which
	%                     is the biggest or "dominant" array in x, y and z and check whether 
	%                     the other two arrays can be expanded to match the dominant's size.
	%                     If this expansion cannot be done, then err is set to be true and 
	%                     can be easily used to trigger an error message.
	%
	% Input arguments:
	%    x, y, z: scalars, vectors or matrices containing data.
	%
	% Ouputs:
	%    err: logical variable containing information about whether x, y, and z have all  
	%        compatible sizes or are scalars. If x, y and z can be expanded to have common
	%        size err is set to false and x, y and z are subsequently expanded.
	%
	% Examples:
	%
	% % Expansion to common size is possible.
	% >> [err, x, y, z] = expand_common_size([1 2], [1 2; 3 4], 0)
    % [err:false]
    % [x:2x2 double]
    % [y:2x2 double]
    % [z:2x2 double]
	%
	% >> x#
	%			1		2
	%			1		2
	%
	% >> y#
	%			1		2
	%			3		4
	%
	% >> z#
	%			0		0
	%			0		0
	%
	% % Expansion to common size is not possible.
	% >> [err, x, y, z] = expand_common_size([1 2], [1 2 3], 0)
    % [err:true]
    % [x:1x2 double]
    % [y:1x3 double]
    % [z:0]
	%
	% >> x#
	%			1		2
	%
	% >> y#
	%			1		2		3
	%
	% >> z#
	%  0
	%
	
	%
	% Copyright (C) 2019 Tenokonda Ltd.
	%


	% Checks the number of input arguments.
	if nargin == 3, nv = 3; end
	if nargin == 2, nv = 2; end
	if nargin == 1, error(': expand_common_size(x, y, z) requires at least two input arguments.'); end

	% Initialize cell to hold input arguments (real and imaginary parts).
	v = cell(1, nv)
	vi = cell(1, nv)

	% Put the input arguments (real values) into an cell array. 
	v(1) = {real(x)}
	v(2) = {real(y)}
	if nargin == 3, v(3) = {real(z)}; end

	% Put the input arguments (imaginary values) into an cell array. 
	% This is done because at the moment of working, cell2mat does not return imaginary parts.
	vi(1) = {imag(x)}
	vi(2) = {imag(y)}
	if nargin == 3, vi(3) = {imag(z)}; end

	% Initialize error flag.
	err = false

	% Number of elements.
	nel = cellfun(@numel, v)

	% Find indices of scalars.
	scid = (nel == 1)

	% If all input arguments are scalars this function does nothing.
	if sum(scid) ~= nv

		% Find indices of cells with the highest number of elements.
		maxid = (nel == max(nel))

		% Get the number of rows of each element.
		nr = cellfun(@(x) size(x, 1), v)

		% Get the number of columns of each element.
		nc = cellfun(@(x) size(x, 2), v)

		% Find the indices of column vectors.
		clid = cellfun(@(x) iscolumn(x), v) & ~scid

		% Find the indices of row vectors.
		rwid = cellfun(@(x) isrow(x), v) & ~scid

		% Find the indices of all vectors.
		vcid = clid | rwid

		% Find the indices of matrices.
		mtid = ~scid & ~vcid

		% Get index and position in v of the 'dominant' element.
		if any(mtid == true)
			domid = mtid & maxid
		else
			domid = vcid & maxid
		end
		dompos = find((maxid & domid) == 1, 1)

		% All matrices must be of the same size. If not, err = true.
		err = err | (any(nr(mtid) ~= nr(dompos)) | any(nc(mtid) ~= nc(dompos)))  

		% For the expansion to common size to work, all row vectors must have
		% the same number of columns. If not, err = true.
		ncols = nc(rwid)    % number of columns in row vectors
		if ~isempty(ncols), err = err | ~all(ncols == ncols(1)); end		

		% For the expansion to common size to work, all column vectors must have
		% the same number of rows. If not all can be expanded, err = true.
		nrows = nr(clid)    % number of rows in column vectors
		if ~isempty(nrows), err = err | ~all(nrows == nrows(1)); end				

		% Get information to expand vectors if the dominant element is a matrix.
		if any(mtid == true)

			% Checks whether it can expand column vectors to match the size of a 
			% dominant matrix. If not all can be expanded, err = true.		
			xcid = (nr == nr(dompos)) & clid    % indices of expansible column vectors		
			err = err | (sum(xcid) ~= sum(clid)) 

			% Checks whether it can expand row vectors to match the size of a 
			% dominant matrix. If not all can be expanded, err = true.	
			xrid = (nc == nc(dompos)) & rwid    % indices of expansible column vectors.		
			err = err | (sum(xrid) ~= sum(rwid))
		
		% Get information for expansion of vectors if the dominant element is a column vector.
		elseif iscolumn(cell2mat(v(dompos))) & (sum(rwid) ~= 0)
			
			% If no errors, the exapansion is plausible.
			if ~err
				% Expand the dominant element.
				v(dompos) = {repmat(cell2mat(v(dompos)), 1, ncols(1))}
				vi(dompos) = {repmat(cell2mat(vi(dompos)), 1, ncols(1))}

				% Update size of dominant element.
				nc(dompos) = ncols(1)
				
				% Indices of expansible row vectors.
				xrid = rwid

				% Indices of expansible column vectors.
				xcid = clid
				xcid(dompos) = false
			end

		% Get information for expansion of vectors if the dominant element is a row vector.
		elseif isrow(cell2mat(v(dompos))) & (sum(clid) ~= 0)

			% If no errors, the exapansion is plausible.
			if ~err
				% Expand the dominant element.
				v(dompos) = {repmat(cell2mat(v(dompos)), nrows(1), 1)}
				vi(dompos) = {repmat(cell2mat(vi(dompos)), nrows(1), 1)}

				% Update size of dominant element.
				nr(dompos) = nrows(1)

				% Indices of expansible column vectors.
				xcid = clid

				% Indices of expansible row vectors
				xrid = rwid
				xrid(dompos) = false
			end

		end
		
	end

	% If no error to return, perform the expansions.
	if ~err

		% Expand the scalars if not all the elements in v are scalars.
		if sum(scid) ~= nv
			i = 1:nv
			i = i(scid)
			for j = 1:length(i)
				v(i(j)) =  {repmat(cell2mat(v(i(j))), nr(dompos), nc(dompos))}
				vi(i(j)) =  {repmat(cell2mat(vi(i(j))), nr(dompos), nc(dompos))}
			end	
		end

		% Expand the expansible column vectors
		i = 1:nv
		i = i(xcid)
		for j = 1:length(i)
			v(i(j)) =  {repmat(cell2mat(v(i(j))), 1, nc(dompos))}
			vi(i(j)) =  {repmat(cell2mat(vi(i(j))), 1, nc(dompos))}
		end

		% Expand the expansible row vectors
		i = 1:nv
		i = i(xrid)
		for j = 1:length(i)
			v(i(j)) =  {repmat(cell2mat(v(i(j))), nr(dompos), 1)}
			vi(i(j)) =  {repmat(cell2mat(vi(i(j))), nr(dompos), 1)}
		end

	end

	% Get the elements to return.
	x = cell2mat(v(1))
	y = cell2mat(v(2))
	if nargin == 3, z = cell2mat(v(3)); end

	% If any imaginary part, add this to the elements to return.
	% This is done because at the moment of working, cell2mat does not return imaginay parts.
	if any(any(cell2mat(vi(1)) ~= 0)), x = x + complex(zeros(size(x)), cell2mat(vi(1))); end
	if any(any(cell2mat(vi(2)) ~= 0)), y = y + complex(zeros(size(y)), cell2mat(vi(2))); end
	if nv == 3
		if any(any(cell2mat(vi(3)) ~= 0)), z = z + complex(zeros(size(z)), cell2mat(vi(3))); end
	end

end