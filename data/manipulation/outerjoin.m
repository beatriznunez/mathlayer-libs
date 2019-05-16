function out = outerjoin(a,b,o1,v1,o2,v2,type)
	
	if isempty(type), type = 'left'; end
	out = join(a,b,o1,v1,o2,v2,type)
	clear('a','b')
	
end