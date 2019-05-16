function out = combvec(varargin)

	% combvec(x1,x2,...,xn) returns all combinations of vectors xi
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% x1,x2,...,xn: vector of doubles
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% out: matrix with combinations
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
	% combvec([1 2 3], [5 6])#
	
    out = varargin{1}
	n = length(varargin)
    for i=2:n
        aux = varargin{i}
        out = [rep(out,size(aux,2)); ord(aux,size(out,2))]
    end
end


function out = rep(x,s)
	i = 1:size(x,2)
	i = i(ones(s,1),:).'
	out = x(:,i(:))
end


function out = ord(x,s)
	i = 1:size(x,2)
	i = i(ones(s,1),:)
	out = x(:,i(:))
end