function varargout = schedule(d, settlelag, len, freq,...
								accrcal, accrconv, fixcal, fixlag,...
								fixconv, paycal, paylag, payconv,...
								ratelen, ratecal, ratelag, rateconv)

	% inputs
	% =======================================
	% d (double): start date if fwd is true, end date otherwise
	% len (string): total period length, e.g. 10D, 3M, 1Y, etc.
	% freq (string): frequency, e.g. 10D, 3M, 1Y, etc.
	% cal (string): calendar, e.g. USNY, ECB, etc.
	% ac: accrual convention, e.g. MF, F, P, A
	% fixlag (string): fixing lag, e.g. 2BD, 0BD, etc.
	% fc: fixing convention, e.g. MF, F, P, A
	% paylag (string): payment lag, e.g. 2BD, 0BD, etc.
	% pc: payment convention, e.g. MF, F, P, A

	% outputs
	% =======================================
	% if nargout == 1, schedule containing 4 columns: fixing date, accrual start date, accrual end date, pay date
	% if nargout == 2, first output will contain period start date and second output will contain period end date
	% if nargout == 3, third output will contain fixing date
	% if nargout == 4, fourth output will contain pay date
		
	% set defaults	
	if isempty(fwd), fwd = true; end

	if isempty(fixlag), fixlag = '0BD'; end
	if isempty(paylag), paylag = '0BD'; end
	if isempty(ratelag), ratelag = fixlag; end

	if isempty(fixconv), fixconv = 'P'; end
	if isempty(accrconv), accrconv = 'MF'; end
	if isempty(payconv), payconv = 'F'; end
	if isempty(rateconv), rateconv = 'MF'; end

	if isempty(accrcal), error('expected calendar'); end
	if isempty(fixcal), fixcal = accrcal; end
	if isempty(paycal), paycal = accrcal; end
	if isempty(ratecal), ratecal = accrcal; end

	if ~isempty(settlelag)
		d = addperiod(d,settlelag,[],[],paycal)
	end
	
	
	[lenNum lenStr] = splitfreq(len)
	[freqNum freqStr] = splitfreq(freq)
	
	if isempty(ratelen), ratelen = freq; end

	% period dates
	gend = basesched(d,freqNum,freqStr,lenNum,lenStr)
	ad = addperiod(gend,0,'BD',accrconv,accrcal)
	fd = addperiod(ad(1:end-1),fixlag,[],fixconv,fixcal)
	if(paylag ~= 0 | ~strcmpi(payconv,accrconv))
		pd = addperiod(gend(2:end),paylag,[],payconv,paycal)
	else
		pd = ad(2:end)
	end
	%rds = addperiod(fd,-ratelagNum,ratelagStr,rateconv,ratecal) % rate period start date
	rds = addperiod(gend(1:end-1),0,'BD',rateconv,ratecal) % rate period start date
	rde = addperiod(gend(1:end-1),ratelen,[],rateconv,ratecal) % rate period end date
	
	varargout{1} = [fd ad(1:end-1) ad(2:end) pd rds rde]

end

% generate period start and end dates
function pd = basesched(d,freqnum,freqstr,lennum,lenstr)

	% get end date
	% ed = addperiod(d,lennum,lenstr)
	
	if strcmpi(freqstr,lenstr)
		n = round(lennum/freqnum)
		if strcmpi(lenstr, 'Y')
			 lenstr = 'M'
			 freqstr = 'M'
			 lennum = 12*lennum
			 freqnum = 12*freqnum
		end
	elseif strcmpi(lenstr,'M') & strcmpi(freqstr,'Y')
		n = round(lennum/(freqnum*12)) % convert years to months
	elseif strcmpi(lenstr,'Y') & strcmpi(freqstr,'M')
		n = round(lennum*12/freqnum) % convert years to months
	else
		error(['combination of ' freqstr ' frequency and ' lenstr ' length is not handled'])
	end
	
	n = abs(n)
	pd = addperiod(d*ones(n+1,1),freqnum*(0:n)',freqstr)
	if freqnum<0, pd = sort(pd); end
	
end