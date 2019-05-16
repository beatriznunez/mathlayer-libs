function image = chartImage(options)

	% extract image settings from options object
	opacity = options.imageOpacity
	

	% create javascript image	
	image = ['
svg.append("pattern")
	.attr("id", "pic1")
	.attr("patternUnits", "userSpaceOnUse")
	.attr("width", w)
	.attr("height", h)
.append("svg:image")
	.attr("xlink:href", "' options.image '")
	.attr("width", w)
	.attr("height", h)
	.attr("opacity", ' num2str(opacity) ');
']

end