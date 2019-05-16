function s = object2struct(o)
	
	% converts the object o into a struct
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% o: mathlayer object
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% s: struct
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
	% x = [1;2]
	% s = object2struct(x)#
	
	varname = inputname(1)
	obtype = class(o)
	obsize = size(o)
	if isempty(varname), varname ='ans'; end
	
	s = struct('varname',varname,'type',obtype,'size',obsize,'value',o)
	
end

