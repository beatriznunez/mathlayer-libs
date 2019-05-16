function [y idxl idxu] = interp1(x,v,xq,opt,ext)
	
	if nargin == 2
		xq = v
		v = x
		x = 1:length(v)
	end
	
	if isempty(opt), opt = 'linear'; end
	if isempty(ext), ext = 'flat'; end
	if ischar(ext), if ~isinstr(ext,{'linear','flat','flatright','flatleft','extrap'}), error('unrecognized extrapolation setting'); end; end
	
	transp = false;
	% transform to column vectors
	if size(xq,1) == 1, xq = xq'; transp = true; end
	if size(x,1) == 1, x = x'; end
	if size(v,1) == 1, v = v'; end

	nx = size(x,1)
	nxq = size(xq,1)

	% error handling
	if nx ~= size(v,1), error('inputs x and v must have same length'); end
	if nx ~= numel(x) | nxq ~= numel(xq), error('interp1 handles only vectors'); end
	
	tmp = sortrows([x v],1)
	x = tmp(:,1)
	v = tmp(:,2:end)
	% find surrounding points
	xq_extended = ones(nx,1)*xq'
	x_extended = x*ones(1,nxq)
	
	nrx = size(x,1)
	ncv = size(v,2)
	
	if strcmpi(opt,'linear')

		loc = x_extended<xq_extended
		idxlraw = round(sum(loc))
		idxl = max(idxlraw,1)
		idxu = min(idxlraw+1,nrx)

		if strcmpi(ext,'linear') | strcmpi(ext,'extrap')
			idol = idxlraw<1 % out and lower than min
			idou = idxlraw>nrx-2 % out and upper than max
			idxl(idol) = 1
			idxu(idol) = 2
			idxl(idou) = nrx-1
			idxu(idou) = nrx
		else
			if strcmpi(ext,'flatleft')
				idou = idxlraw>nrx-2 % out and upper than max
				idxl(idou) = nrx-1
				idxu(idou) = nrx
			end
			if strcmpi(ext,'flatright')
				idol = idxlraw<1 % out and lower than min
				idxl(idol) = 1
				idxu(idol) = 2
			end
		end

		yl = v(idxl,:)
		yu = v(idxu,:)
		xl = x(idxl,:)*ones(1,ncv)
		xu = x(idxu,:)*ones(1,ncv)
		xq = xq*ones(1,ncv)
		
		y = (yu-yl)./(xu-xl).*(xq-xl)+yl
		idx_onnode = xu == xl
		y(idx_onnode) = yl(idx_onnode)
	
	elseif strcmpi(opt,'previous')

		loc = x_extended <= xq_extended
		idx = max(round(sum(loc)),1)
		y = v(idx,:)
		
	elseif strcmpi(opt,'next')

		loc = x_extended < xq_extended
		idx = min(round(sum(loc))+1,size(x,1))
		y = v(idx,:)

	elseif strcmpi(opt,'nearest')
        xx = zeros(1,numel(x))
        xx(1:end-1) =  (x(1:end-1) + x(2:end)) /2
        xx(end) = x(end)
        loc = xq_extended' >= ones(nxq,1)*xx
        idx = sum(loc,2)+1
        idx(find(idx == 0)) = 1
		idx(find(idx > numel(x))) = numel(x)
        y = v(idx)

	elseif strcmpi(opt,'pchip')
		y = pchip(x,v,xq)
		
	elseif strcmpi(opt,'spline')
		y = spline(x,v,xq)
	else
		error(['invalid option "' opt '"'])
	
	end
	
	% extrapolation
	if isscalar(ext)
		if ~isempty(find(xq > max(x))), y(find(xq > max(x))) = ext; end
		if ~isempty(find(xq < min(x))), y(find(xq < min(x))) = ext; end
	
	elseif strcmpi(ext,'extrap')
		if strcmpi(opt,'previous')
			if ~isempty(find(xq > max(x))), y(find(xq > max(x))) = v(end); end
			if ~isempty(find(xq < min(x))), y(find(xq < min(x))) = NaN; end
		elseif strcmpi(opt,'next')
			if ~isempty(find(xq > max(x))), y(find(xq > max(x))) = NaN; end
			if ~isempty(find(xq < min(x))), y(find(xq < min(x))) = v(1); end
		elseif strcmpi(opt,'nearest')
			if ~isempty(find(xq > max(x))), y(find(xq > max(x))) = v(end); end
			if ~isempty(find(xq < min(x))), y(find(xq < min(x))) = v(1); end
		end
	elseif strcmpi(opt,'previous') | strcmpi(opt,'next')  | strcmpi(opt,'nearest') 

		if ~isempty(find(xq > max(x))), y(find(xq > max(x))) = NaN; end
		if ~isempty(find(xq < min(x))), y(find(xq < min(x))) = NaN; end
	end
	
	if transp, y = y'; end
	
end

