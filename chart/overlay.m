function out = overlay(c,options,show)

	options.overlay = true
	options.subtype = 'overlay'

	a = c{1}
	if  strcmp(a.subtype, '3d'), out = chartCombine3d(c,options), else out = chartCombine(c,options); end
	
end