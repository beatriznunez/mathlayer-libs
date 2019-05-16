function out = html(s,options)

	if nargin < 2, options = struct(); end
	o = chartOptions(options)

	out.type = 'html'
	out.subtype = 'html'
	out.css = 'div {
	diplay: inline;
	float: left;
}
.xaxis path,
.xaxis line,
.yaxis path,
.yaxis line,
.y2axis path,
.y2axis line {
	fill: none;
	stroke: black;
	shape-rendering: crispEdges;
}'
	out.jsFrame = ''
	out.jsData = s
	out.dataSet = s
	out.legend = ''
	out.image = ''
	out.tag = o.tag
	out.options = o
	out.divTag = ['<div id="' o.tag '">' s '</div>']

	if o.save 
		data = chartHtml(o, out.css, out.divTag, true, o.web)
		filePath = [o.folder '\' o.name '.html']	
		fid = fopen(filePath,'w+')
		fprintf(fid,'%s',data)
		fclose(fid)
	end
	if o.show 
		sh(filePath)
	end
	
end