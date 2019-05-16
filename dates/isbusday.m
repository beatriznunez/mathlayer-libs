function isbd = isbusday(d, cal)
	% e.g.: isbusday(736099,'EUR')
	
	if ~isnumeric(d), error('first input must be a date number'); end
	if ~ischar(cal), error('second input must be a string which indicates the calendar to use'); end
	
	switch cal
	case 'EUR'
		cal = 'EUTA'
	case 'GBP'
		cal = 'GBLO'
	end
	
	if numel(cal) > 4
	
		tmpcal = cal(1:4)
		isbd = isbusday(d, tmpcal)
		for i = 5:5:numel(cal)
			tmpcal = cal((i+1):(i+4))
			isbd = isbd & isbusday(d, tmpcal)
		end
		return
		
	end
	
	isbd = ~ismember(weekday(d),[1 7]) & ~ismember(d, calendar(cal))

end
