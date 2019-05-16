function str = strsplit(string,delim)
	
	if isempty(delim), delim = ','; end
	commas = strfind(string,delim); %number of commas
	if numel(commas) == 0
		str = {string}
	else
		try
			str = regexp(string,['(?:\', delim,  ')+'],'split')
			
		catch e
			str = regexp(string, ['(?:', delim, ')+'],'split')
		end
	end

end


