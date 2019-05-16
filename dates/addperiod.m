function d = addperiod(d,freqnum,freqstr,conv,cal)
	% adds a period to date
	% e.g.: 
	% datestr(addperiod(today,'3M'))
	% datestr(addperiod([736838;736899],{'6d';'5y'}))
	% datestr(addperiod([736838;736899],[6;5],{'d';'y'}))

	if  nargin == 1, error('expected at least 2 input arguments'); end
	
	if ~isempty(conv) & ~ischar(conv), error('expected a string for convection'); end
	if ~isempty(cal) & ~ischar(cal), error('expected a string for calendar'); end
	
	% check dimensions d and freqnum
	if (size(freqnum,2) > 1 & size(d,2) > 1) | ((size(d,1) ~= size(freqnum)) & (size(d,1) ~= 1 & size(freqnum,1) ~= 1))
		error('dimension mismatch')
	end
	
	if isempty(freqstr)
		if strcmp(class(freqnum),'string array') & size(freqnum,1) > 1
			freqnum = cast(freqnum,'cell')
		end
		if iscell(freqnum)
			fh = @(x) addperiodu(d,x,'',conv,cal)
			d = cellfun(fh,freqnum)
			d = d(1,:)'
			return
		end	
	end
	
	d = addperiodu(d,freqnum,freqstr,conv,cal)
end

function d = addperiodu(d,freqnum,freqstr,conv,cal)	

	[y m D] = datevec(d)
	if isempty(freqstr), [freqnum freqstr] = splitfreq(freqnum); end
	if ~isnumeric(freqnum), error('freqnum must be a number'); end
	
	switch lower(freqstr)
	case 'm'
		newy = y + floor((freqnum + m - 1) / 12)
		newm = rem(freqnum + m - 1, 12) + 1
		newm(newm<=0) = newm(newm<=0) + 12
		newd = D
		newdmax = eomday(newy,newm)
		newd(newd > newdmax) = newdmax(newd > newdmax)
		d = datenum(newy, newm, newd)

	case 'y'	
		d = datenum(y + freqnum, m, D)
			
	case 'w'	
		d = datenum(y, m, D) + freqnum * 7
		
	case 'bd'
		add = freqnum/abs(freqnum)
		count = 0			
		if ischar(d), d = datenum(d); end
		while count < abs(freqnum)
			d = adjdate(d + add, conv, cal)
			count = count + 1
		end
		
	case 'd' % 'a'		
		d = datenum(y, m, D) + freqnum
		
	otherwise
		error([freqstr ' frequency not handled'])
	end

	if ~isempty(conv) & ~isempty(cal) & ~strcmpi(conv, 'A')
		nonbd = ~isbusday(d, cal)
		d(nonbd) = adjdate(d(nonbd),conv,cal)
	end


end

