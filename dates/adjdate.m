function d = adjdate(d,conv,cal)
	% return nearest date from d based on convention (conv) and (cal)
	% e.g.: datestr(adjdate(today,'P','EUR'))
	
	idbd = ~isbusday(d,cal)

	if isempty(conv) || strcmpi(conv,'F')
		d(idbd) = adj(d(idbd),cal,1)
	elseif strcmpi(conv,'MF')
		d(idbd) = adjmf(d(idbd),cal)
	elseif strcmpi(conv,'P')
		d(idbd) = adj(d(idbd),cal,-1)
	else
		error([conv ' conv not handled'])
	end
	
end

function d = adj(d,cal,add)

	d = d + add
	idbd = ~isbusday(d, cal)
	while sum(idbd) > 0
		d(idbd) = d(idbd) + add
		idbd = ~isbusday(d, cal)
	end

end

function d = adjmf(d,cal) % modified following
	d2 = d
	[yo mo] = datevec(d) % back out original months
	d = adj(d, cal, 1)
	% in case business day is in different month use preceding
	[y m] = datevec(d)
	idnm = m > mo
	d(idnm) = adj(d2(idnm) - 1,cal,-1)

end
