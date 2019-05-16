function [x y z o] = norm3dArgs(x,y,z,o,type,nargs)
	
	if ~iscell(x), x(isinf(x(:))) = NaN; end
	if ~isstruct(y) && ~iscell(y), y(isinf(y(:))) = NaN;	end
	z(isinf(z(:))) = NaN;

	if strcmp(type,'surf')
		
		if isvector(x) & ~iscell(x), x = meshgrid(x); end
		
		switch nargs
		case 1
			if isscalar(x), error('invalid input arguments'); end
			z = x
			[x y] = meshgrid(1:size(z,2),1:size(z,1))
			
		case 2
			if ~isstruct(y), error('invalid input arguments'); end
			o = y
			z = x
			[x y] = meshgrid(1:size(z,2),1:size(z,1))
			
		case 3
			if isstruct(z), error('invalid input arguments'); end
			if isvector(x) & isreal(x), x = meshgrid(x); end
			if isvector(y) & isreal(y), [~, y] = meshgrid(y); end
			
		end
		
	end
	
	nx = 1; ny = 1; nz = 1; no = 1
	if iscell(x), nx = numel(x); end
	if iscell(y), ny = numel(y); end
	if iscell(z), nz = numel(z); end
	if iscell(o), no = numel(o); end
	n = max([nx,ny,nz,no])
	
	if nx~=n && nx~=1, error('inconsistent input arguments dimensions'); end
	if ny~=n && ny~=1, error('inconsistent input arguments dimensions'); end
	if nz~=n && nz~=1, error('inconsistent input arguments dimensions'); end
	if no~=n && no~=1, error('inconsistent input arguments dimensions'); end

	if nx<n, x = {x}; x = repmat(x,1,n); end
	if ny<n, y = {y}; y = repmat(y,1,n); end
	if nz<n, z = {z}; z = repmat(z,1,n); end
	if no<n, o = {o};  o = repmat(o,1,n); end
	if n == 1, x = {x}; y = {y}; z = {z}; o = {o}; end
	
	colors = colorSet(1)
	if no<n
		for i = 1:n
			tmp = o{i}
			tmp.markerFill = colors{rem(i-1,numel(colors)) + 1}
			o{i} = tmp
		end
	end
	
	if strcmp(type,'scatter3')
		for i = 1:nz
			if isempty(o{i}), tmpo = struct; else tmpo = o{i}; end
			if ~any(strcmp('type',fieldnames(tmpo))), tmpo.type = type; end
			if ~any(strcmp('markerSize',fieldnames(tmpo))), tmpo.markerSize = 3; end
			if ~any(strcmp('markerFill',fieldnames(tmpo))), tmpo.markerFill = colors{rem(i-1,numel(colors)) + 1}; end
			if ~any(strcmp('markerStroke',fieldnames(tmpo))), tmpo.markerStroke = 'black'; end
			o{i} = tmpo
		end
	elseif strcmp(type,'plot3')
		for i = 1:nz
			if isempty(o{i}), tmpo = struct; else tmpo = o{i}; end
			if ~any(strcmp('type',fieldnames(tmpo))), tmpo.type = type; end
			if ~any(strcmp('markerSize',fieldnames(tmpo))), tmpo.markerSize = 0; end
			if ~any(strcmp('lineWidth',fieldnames(tmpo))), tmpo.lineWidth = 1; end
			if ~any(strcmp('lineStroke',fieldnames(tmpo))), tmpo.lineStroke = 'blue'; end
			if ~any(strcmp('lineInterpolate',fieldnames(tmpo))), tmpo.lineInterpolate = 'Linear'; end
			o{i} = tmpo
		end
	elseif strcmp(type,'surf')
		for i = 1:nz
			if isempty(o{i}), tmpo = struct; else tmpo = o{i}; end
			if ~any(strcmp('type',fieldnames(tmpo))), tmpo.type = type; end
			if ~any(strcmp('markerSize',fieldnames(tmpo))), tmpo.markerSize = 0; end
			if ~any(strcmp('lineWidth',fieldnames(tmpo))), tmpo.lineWidth = 0.2; end
			if ~any(strcmp('lineStroke',fieldnames(tmpo))), tmpo.lineStroke = 'black'; end
			o{i} = tmpo
		end
	end
	
end