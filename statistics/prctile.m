function out = prctile(x, p, dim, interpolation)
	
	% to correct the shape of the output in some cases
	totranspose = false
	
	% to avoid cases where the input p is a vector like, for instance, [25 50 75]
	[m, n] = size(p)
	if (m > 1) | (n >1) % p is a vector not a scalar
		error('in the current version of prctile an input vector p of probabilities is not accepted')
		return
	end
	
	x(isnan(x)) = [] % NaNs are considered as missing values
	if isempty(x), out = nan; return; end
	
	% defines default dimension and shape
	if nargin < 3	
		dim = 1
		if isvector(x), x = x(:); end
	end
	
	% correction due to the fact that sort([1 4 3]', 2)# returns [1 3 4]'
	% but it should return [1 4 3]'. If this is corrected, these lines
	% should not be necessary
	if nargin == 3
		if isvector(x)
			sz = size(x)
			vectordim = find(sz == max(sz))
			if vectordim ~= dim
				out = x
				return
			end
		end
	end
	
	% sort data in increasing order along the specified dimension
	x = sort(x, dim)
	
	if dim == 2
		x = x'
		totranspose = true
	end
	
	% gets the number of points or total amount of data
	[numpoints, ~ ]= size(x)
	
	% when no interpolation is specified, the output is compatible with Octave's
	if nargin < 4
	
		%using The Linear Interpolation Between Closest Ranks method
		% calculate the percent rank for each list value.
		Pi = ones(1, numpoints)
		i = 1:numpoints
		Pi(:) = (100/numpoints)*(i(:) - 0.5)
		%take those percent ranks and calculate the percentile values:
		if p < Pi(1)
			out = x(1,:)
		elseif p > Pi(numpoints)
			out = x(numpoints,:)
		else
			if sum(p == Pi(i))
				ind = find(p == Pi(i), 1)
				out = x(ind,:)
			else
				ind = find(~(p > Pi(i)), 1)
				out = x(ind-1,:) + numpoints*((p - Pi(ind-1))/100)*(x(ind,:) - x(ind-1,:))
			end
		end
		
	elseif nargin == 4
	
		% find what points in x correspond to the probability p
		% 'indices' defined as such to have compatibility with Python
		p = p/100
		indices = p * (numpoints - 1) + 1
		
		if strcmp(interpolation, 'nearest')
			out = x(round(indices),:)		
		elseif strcmp(interpolation, 'lower')
			out = x(floor(indices),:)
		elseif strcmp(interpolation, 'higher')
			out = x(ceil(indices),:) 
		elseif strcmp(interpolation, 'midpoint')
			out = 0.5 * (x(floor(indices),:) + x(ceil(indices),:))
		elseif strcmp(interpolation, 'linear')
			i = x(floor(indices),:)
			j = x(ceil(indices),:)
			fraction = indices - floor(indices)
			out = i + (j - i) * fraction
		else
			error("interpolation can only be 'linear', 'lower', 'higher', 
				    'midpoint' or 'nearest'")
		end		
		
	end
	
	if totranspose, out = out'; end
	
end