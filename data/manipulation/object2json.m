function js = object2json(o,vn)
	
	if isempty(vn), vn = false; end
	
	js = object2struct(o)
	if vn, js.vn = whos('caller'); end
	
	js = struct2json(js)
	
end