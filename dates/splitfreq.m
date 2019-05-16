function [num str] = splitfreq(freq)
% e.g.: splitfreq('3M') returns 3 and 'M'
	let = isletter(freq)
	num = str2num(freq(:,~let))
	str = freq(:,let)
	
end