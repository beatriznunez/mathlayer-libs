function str = sentence(str)
	% sentence case capitalises the first letter of the first word in a heading
	if istable(str) | iscell(str)
		[nr nc] = size(str)
		for i = 1:nr
			for j = 1:nc
				if ~sum(isinstr(class(str{i,j}), {'string array'; 'char'}))
					error('impossible to convert to sentence case non string objects')	
				end
				str{i,j} = conv(str{i,j})
			end
		end
		
	elseif ischar(str) 
		str = conv(str)
		
	elseif  strcmp(class(str), 'string array')
		str = cast(str, 'cell')
		str = cellfun(@conv, str, 'UniformOutput', false)'
		
	else
		error('impossible to convert to sentence case non string objects')	
	end
end

function str = conv(str)
	if ~isempty(str)
		str = lower(char(str)) % if string array
		% convert each array
		pos = strfind(str, '. ')
		str(1) = upper(str(1))
		if numel(pos) ~= 0
			str(pos+2) = upper(str(pos+2))
		end
	end
end