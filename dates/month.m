function y = month(d,f)

	if isempty(f), f = 'mm/dd/yyyy'; end
	y = datevec(datenum(d,f))
	y(:,[1 3:end]) = []

end