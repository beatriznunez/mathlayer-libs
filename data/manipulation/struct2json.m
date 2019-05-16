function j = struct2json(s)
	
	% converts the struct s into a JSON content
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% s: struct
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% j: json string	
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
	% s = struct('country', 'Spain', 'capital', 'Madrid', 'population', '3,141,991')
	% j = struct2json(s)#
	
	j = struct2json2(s)
	
	% clean output
	j = regexprep(j, '\},\}', '}}')
	j = regexprep(j, '\},\]', '}]')
	j = regexprep(j, '\],\}', ']}')
	j = regexprep(j, '\],\]', ']]')
	j = regexprep(j, '\},\}', '}}')
	j = regexprep(j, '\},\]', '}]')
	j = regexprep(j, '\],\}', ']}')
	j = regexprep(j, '\],\]', ']]')
	j = strrep(j, ',,', ',')
	if strcmp(j(end), ','), j(end) = '';end

end


function j = struct2json2(s)

	% check input type
	if ~isstruct(s)
		error('input must be a struct')
	end
	
	fields = fieldnames(s)
	n = numel(fields)
	if n == 0 
		j = '{},'
	else
		j = '{'
		for i = 1:n
			c = s.(fields{i})
			% check type of field value
			if isstruct(c)
				fv = [struct2json2(c), ' ']
			elseif iscell(c)
				if isempty(c)
					fv = '[null],'
				else
					fv = '['
					for ii = 1:numel(c)
						if isempty(c{ii})
							fv = [fv, 'null,']
						elseif isstruct(c{ii})  % cell of structs
							fv = [fv, struct2json2(c{ii}), ' ']
						else
							fv = [fv, getexp(c{ii})]
						end
					end
					fv(end:end+1) =  '],'
				end
							
			elseif istable(c)
				fv =  [table2json(c) ',']	
			% if char, double or logical, get expression
			else
				fv = getexp(c)
			end
			
			% add new field
			j = [j, '"', fields{i}, '":', fv]
		end		
		j(end:end+1) = '},'	
	end
end


function y = getexp(x)
	% get expression of the field values. (ie. if x is a vector, y =[1 2 3])
	[nr nc] = size(x)
	% if nr>1, error('error defining matrix in JSON content'); end

	if (isnumeric(x) | islogical(x)) & numel(x)>1
		y = '['
		for j = 1:nr
			y = [y, '[']
			for jj = 1:nc
				if isnan(x(j,jj))
					y = [y, "null"]
				elseif ~isfinite(x(j,jj))
					y = [y, "Infinity"]
				else
					y = [y, sprintf('%.16g',double(x(j,jj)))]
				end
				if jj~=nc, y = [y, ',']; end
			end
			y  = [y, '],']
		end
		y  = [y, '],']
  
	else
		if isnumeric(x)	| islogical(x)
			if isempty(x) | isnan(x)
				y = '"null",'
			elseif ~isfinite(x)
				y = '"Infinity",'
			else
				y = sprintf('%.16g,',double(x))
			end
		elseif ischar(x)
			if isinstr('{',x)
				try
					json(x)
					y = [x, ',' ]
				catch
					x = regexprep(x, '"', '''')
					y = ['"', x, '",' ]
				end
			else
				x = regexprep(x, '"', '''')
				y = ['"', x, '",' ]
			end
		elseif iscell(x)
			y = '['
			for i = 1:numel(x)
				y = [y, getexp(x{i})]
			end
			y(end:end+1) =  '],'
		end
	end
end

