function out = dcf(D1,D2,dcc)
	% returns day count fraction between 2 dates	
	% e.g.: dcf(736809,737160,'act/365')

	if nargin ~= 3; error('expected three input arguments'); end
	
	[y1 m1 d1] = datevec(D1)
	[y2 m2 d2] = datevec(D2)
		
	switch lower(char(dcc))
	case '30/360'
		%  if d1 is 31, d1 is changed to 30. If d2 is 31 and d1 is 30 or 31, d2 is changed to 30
		d1(d1==31) = 30
		d2(d2 == 31 & (d1 == 31 | d1 ==30)) = 30
		out = (360*(y2-y1) + 30*(m2-m1) + (d2-d1))./360	
		
	case {'act/365','act/365f'} % actual/365, actual/365 ISMA
		% actual number of days divided by 365
		out = (D2 - D1)./ 365
		
	case 'act/act' % actual/actual ISMA
		% number of days in a year: number of days in the calendar year after D1
		out = (D1-D2)./(datenum(y1, m1,d1) - datenum(y1 + 1, m1, d1))
			
	case 'act/360' % actual/360, actual/360 ISMA
		% actual number of days divided by 360
		out = (D2 - D1)./ 360
		
	case '30/360sia'
		% if d1 and d2 are the last day of February, d2 is changed to 30. 
		% If d1 is 31 or the last day of February, it is changed to the 30, 
		% if after this change, d1 is 30 and d2 is 31, d2 is changed to 30.
		d2(m1 == 2 &  m2 == 2 & d1 == eomday(y1,m1) & d2 == eomday(y2,m2)) = 30
		d1(d1 == 31 | (m1 == 2 & d1 == eomday(y1,m1))) = 30
		d2(d1 == 30 & d2 == 31) = 30
		out = (360*(y2-y1) + 30*(m2-m1) + (d2-d1))./360	

		
	case '30/360psa' 
		% 30 days per month (including February). 
		% If d1 is 31 or the last day of February, d1 is changed to 30, 
		% while if d1 is 30 and d2 is 31, d2 is changed to 30.
		d1(d1 == 31 | (m1 == 2 & d1 == eomday(y1,m1)))= 30
		d2(d1 == 30 & d2 ==31) = 30
		out = (360*(y2-y1) + 30*(m2-m1) + (d2-d1))./360

	case '30/360isda'
		% 30 days per month, except February (actual number of days). 
		% If d1 is 31,  d1 is changed to 30, while if d1 is 30 and d2 is 31, d2 is changed to 30. 
		d1(d1 == 31) = 30
		d2(d1 == 30 & d2 ==31) = 30
		out = (360*(y2-y1) + 30*(m2-m1) + (d2-d1))./360
		
	case {'30i/360', '30e/360'} % 30/360 European, 30/360 ISMA		
		% 30 days per month, except February (actual number of days)
		% If d1 or d2 is 31, that date is changed to 30.
		d1(d1 == 31) = 30
		d2(d2 == 31) = 30
		out = (360*(y2-y1) + 30*(m2-m1) + (d2-d1))./360
	
	case 'act/365j' % japanese
		% actual number of days in a period, except for leap days which are ignored. 
		td = [0;31;59;90;120;151;181;212;243;273;304;334] % total days: convert months into days
		out = (365*(y2-y1) + (td(m2)-td(m1)) + (d2-d1))./365
		
	case '30e+/360' %  '30E+/360 ISDA'
		% if d1 is 31, d1 is changed to 30. If d2 is 31, d2 is changed to  1 and m2 to m2+1
		d1(d1==31) = 30
		aux = d2 == 31
		d2(aux) = 1
		m2(aux) = m2(aux)+1
		out = (360*(y2-y1) + 30*(m2-m1) + (d2-d1))./360
		
	case 'act/actisda'
		aux = ones(size(y1))
		D11 = (1 + (datenum(y1,aux*12,aux*31)-D1))./(datenum(y1+1,aux,aux) - datenum(y1, aux,aux))
		D22 = (D2-datenum(y2,aux,aux))./(datenum(y2+1,aux,aux) - datenum(y2,aux,aux))
		out = D11 + D22 - y1 + y2-1
			
	otherwise		
		error(['convention ' dcc ' not handled'])
	end

end