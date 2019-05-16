function jsData = chartClipPath(o)

	jsData = ['
svg.append("clipPath")
	.attr("id", "clipPath_' o.tag '")
	.append("rect")']
	if o.markerSize > o.lineWidth
		left = num2str(o.markerSize)
		top = num2str(o.markerSize)
		right = num2str(o.markerSize*2)
		bottom = num2str(o.markerSize*2)
		jsData = [jsData '
	.attr("x", pl-1-' left ')
	.attr("y", pt-1-' top ')
	.attr("width",2+cw+' right ')        
	.attr("height", 2+ch+' bottom ');
']
	else
		if isfield(o,'marginLeft')
			left = num2str(0)
		else 
			left = num2str(o.lineWidth/2)
		end
		if isfield(o,'marginTop')
			top = num2str(0)
		else 
			top = num2str(o.lineWidth/2)
		end
		if isfield(o,'marginRight') && isfield(o,'marginLeft')
			right = num2str(0)
		elseif isfield(o,'marginRight')
			right = num2str(o.lineWidth/2)
		else 
			right = num2str(o.lineWidth)
		end
		if isfield(o,'marginBottom') && isfield(o,'marginTop')
			bottom = num2str(0)
		elseif isfield(o,'marginBottom')
			bottom = num2str(o.lineWidth/2)
		else 
			bottom = num2str(o.lineWidth)
		end
		jsData = [jsData '
	.attr("x", pl-' left ')
	.attr("y", pt-' top ')
	.attr("width",cw+' right ')        
	.attr("height", ch+' bottom ');
']
	end
end