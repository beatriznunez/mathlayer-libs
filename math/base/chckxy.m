function [x,y,rowsy,endslopes] = chckxy(x,y,xq,met)

	% default
	endslopes = []

	% check inputs for spline and pchip	
	if ~isvector(x) 
		error('x must be a vector')
	end  

	if any(~isreal(x))
		error('x must have real numbers')
	end
	
	x=x(:).' % force x to be a row vector
	if isvector(y), y = y(:).'; end
	
	nanx = find(isnan(x))
	if ~isempty(nanx)
		x(nanx) = []
		y(:,nanx) = []
		warning('NaN values will be ignored')
	end	
	
	if ~isequal(numel(x), size(y,2)) 
		if size(y,2) == numel(x)+2 & ~strcmp(met, 'pchip')    
			N = size(y,2)                 
			endslopes = [y(:,1) y(:,N)]
			if sum(isnan(endslopes)), error('endslopes can not be NaN');end
			y = y(:,2:N-1)
		elseif isequal(numel(x), size(y,1)) & ~isvector(y) 
			error('the number of sites is incompatible with the number of values')
		else
			error('check the length of inputs x and y')
		end
	end
	
	[~,nany] = find(isnan(y))
	nany = unique(nany)
	if ~isempty(nany)
		x(nany) = []
		y(:,nany) = []
		warning('NaN values will be ignored') 
	end	

	if numel(x)<2 | numel(y)<2
		error('at least 2 data points are needed')
	end

	if ~isequal(size(x), size(unique(x)))
		error('inputs x can not have duplicated elements')
	end
	
	% re-sort
	[x in] = sort(x)
	y = y(:,in)
  
	% get the number of rows in y     
	[rowsy,~] = size(y)            
  
end

