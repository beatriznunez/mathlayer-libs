function out = immdate(d,allmonths)
	% e.g.: immdate(datenum('01/02/2017'),[3 6 9 12])
	
	if ~isnumeric(d), error('expected numeric input'); end
	
	immMonths = [3 6 9 12]
	if ~isempty(allmonths) & allmonths, immMonths = 1:12; end
	[y m] = datevec(d)
	isImmMonth = ismember(m,immMonths)
	
	immMonthsSup = repmat(immMonths,numel(m),1) + 1 - m > 0
	[~,posSup] = max(immMonthsSup,[],2)

	% get 3rd Wednesday for each immMonth surrounding d
	wd = weekday(datenum(y,immMonths(posSup),ones(numel(d),1)))
	thirdWed = 4 - wd
	thirdWed(thirdWed<0) = thirdWed(thirdWed<0) + 7
	thirdWed = thirdWed + 15
	
	% check IMM date is indeed >= d
	out = datenum(y,immMonths(posSup),thirdWed)
	isSup = d > out
	out(isSup) = datenum(y(isSup),immMonths(rem(posSup(isSup),4)+1),thirdWed(isSup))
	isSup = d > out
	out(isSup) = datenum(y(isSup)+1,immMonths(rem(posSup(isSup),4)+1),thirdWed(isSup))
	
end