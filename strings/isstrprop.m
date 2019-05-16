function z = isstrprop(str, c)

	if ~ischar(str)
		z = cellfun(@(x) isstrprop(x, c), str, 'UniformOutput', false)
		break;
	end
	
	switch c
		case 'alpha'
			m = regexp(str, {'[a-zA-Z]'})
		case 'alphanum'
			m = regexp(str, {'\w'})
		case 'digit'
			m = regexp(str, {'[0-9]'})
		case 'lower'
			m = regexp(str, {'[a-z]'})
		case 'punct'
			m = regexp(str, {'[,;:\.]'})
		case 'wspace'
			m = regexp(str, {'\s'})
		case 'upper'
			m = regexp(str, {'[A-Z]'})
		case 'xdigit'
			m = regexp(str, {'[A-Fa-f0-9]'})
		otherwise % add: 'cntrl', 'graphic', 'print'
			error('category not found')
	end

	m = m{:,:}
	z = 1:numel(str)
	for i = 1: numel(str)
		if sum(z(i) == m)
			z(i) = 1
		else
			z(i) = 0
		end
	end


end