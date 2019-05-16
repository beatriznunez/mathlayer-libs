function wd = weekday(d)
	% 7: Saturday
	% 1: Sunday
	% 2: Monday
	% 3: Tuesday
	% 4: Wednesday
	% 5: Thursday
	% 6: Friday
	% e.g.: weekday(736812)

	if ~isnumeric(d), error('expected numeric input'); end
	wd = rem(fix(d)-1,7)
	i = find(wd <= 0)
	wd(i) = wd(i)+7

end