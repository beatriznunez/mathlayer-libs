function df = table2dataframe(t, js)

	% table2dataframe(t) converts a mathlayer® table t into a python pandas dataframe
	% if the second input is defined, the output will be a json string
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% t: table. Define rownames to have index in dataframe
	% js: convert into json string. false, by default
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% df: dataframe	(or a json string if specified second input)
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
	% table2dataframe(table({'John';'Marc';'Sam';'Toni'},{'B';'A';'B';'F'}, 'VariableNames', {'First_Name' 'Grade'},...
	% 'RowNames', {'a1'; 'a2'; 'a3'; 'a4'}))#
	
	% check inputs
	if ~istable(t), error('first input must be a table'), end
	
	varName = t.variableNames
	types = t.variableTypes
	[row,col] = size(t)
	
	% add index
	index = ''
	isindex = false
	if isempty(js) % if json there is no index
		nanvalue = 'float(''nan'')'	% use NaN without numpy (np.nan if import numpy as np) for dateframe
		try
			rowNames = t.rowNames
			isindex = true
		catch 
		end
	else
		nanvalue = 'null'	% nan for json
	end
	
	df = '{
'

	for i = 1:col
		% str: modified string following specification for dataframe or json object
		if strcmp(types{i}, 'string array')
			str = strrep(t{:,i}, '"', '\"')  % double quotes in string: \"
			qs = '"'
		else
			str = strrep(sprintf('%.16g, ',t{:,i}), 'NaN', nanvalue)
			str = str(1:end-2) % remove last comma
			qs = ''
		end
		if (isempty(str)), str = ''; end
		delim = [qs, ', ',qs]
		df = strcat(df, '	"', varName{i}, '": [', qs, strjoin(cast(str, 'cell'),delim), qs, ']')
		
		% add comma if it is not the last column
		if i ~= col
			df = strcat(df, ',
')
		end
	end
	
	if isindex	% add rownames to dataframe if they are defined
		index = strcat(',
index = ["', strjoin(rowNames, '","'),  '"]')
	end

	df = strcat(df, '
}', index)
end