function y = year(d,f)

	if isempty(f), f = 'mm/dd/yyyy'; end
	y = datevec(datenum(d,f))
	y(:,2:end) = []

end