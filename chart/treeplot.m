function out = treeplot(t,o)
	
	if nargin == 0, error('not enough input arguments'), end
	if strcmp(class(t), 'struct') == 0, error('input must be a struct'), end
	if nargin < 2, o = struct(); end
	
	check(t)
	
	% default treeplot options
	if ~isfield(o,'type'), o.type = 'treemap'; end
	o.markerSize = 0
	
	% set options
	o = chartOptions(o, 1, 1, 1, 1)
	
	x = t
	y = 1
	op = o
	op.show = false
	
	button = '<button onclick="changeTreeView(this)">CHANGE TO HORIZONTAL VIEW</button>'
	
	out = chartCombine({html(button,op),gen2dVect(x,y,op)},o)
end
function check(t)
	fn = fieldnames(t)
	c = cellfun(@(x) iscell(t(x)),fn)
	if sum(c) > 1
		error('only one field with cell of structs as value accepted per node')
	elseif sum(c) == 1
		[ism idx] = ismember(true,c)
		field = t(fn{idx})
		nc = size(field,2)
		if sum(cellfun(@isstruct,field)) == nc
			for ii = 1:nc, check(field{ii}); end
		else
			 error('only struct type accepted as node of the treeplot')
		end
	end
end