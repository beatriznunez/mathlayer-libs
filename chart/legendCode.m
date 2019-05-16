function out = legendCode(type, o)
	
	switch type
		case 'gradient'
			legend = ['
var key = svg.append("g");
var legend = svg.append("defs").append("svg:linearGradient")
	.attr("id", "gradient_" + legop.tag + "")
	.attr("x1", "100%")
	.attr("y1", "0%")
	.attr("x2", "100%")
	.attr("y2", "100%"); 
	
for (i = 0; i < legop.colorScale.length; i++) {
	legend.append("stop").attr("offset", legop.range[0][i]+"%").attr("stop-color", legop.colorScale[i]);
}

key.append("rect")
	.attr("x", legop.x+legop.offsetleg)
	.attr("y", legop.y+legop.offset)
	.attr("width", 15)
	.attr("height", ch-legop.offset)
	.style("fill", "url(#gradient_" + legop.tag + ")")
	.attr("stroke", "black")
	.style("shape-rendering", "crispEdges");
	
var y = d3.scaleLinear()
	.range([ch-legop.offset, 0])
	.domain([legop.legMin, legop.legMax]);
var legendAxis = eval(legop.axis[0])
	.tickFormat(d3.format(legop.legendFormat))
	.tickValues(y.ticks(legop.legendTicks).concat(y.domain()));
key.append("g")
	.attr("class", "yaxis")
	.style("font", "10px arial")
	.attr("transform", "translate("+(legop.x+legop.width+legop.offsetleg)+","+(legop.y+legop.offset)+")")
	.call(legendAxis);
'] 
		case 'buble'
			legend = ['
var legend = svg.selectAll("legend")
	.data(legop.dataset[0])
	.enter()
	.append("g")
	.attr("class", "legend")
	.attr("transform", function(d,i) {
		var horz = legop.x + bubScale(legop.dataset[0][2]);
		var vert = legop.y + bubScale(d);
		return "translate(" + horz + "," + vert + ")";
	});
	
legend.append("path")
	.attr("transform","translate(0,0)")
	.attr("d",d3.symbol()
		.type(function(d,i) { return eval(legop.ms[0]); })
		.size(function(d,i) { return Math.PI*Math.pow(bubScale(d),2);}))
	.attr("stroke", "black")
	.attr("fill", "rgba(255,0,0,0)")
	.style("shape-rendering", "crispEdges");
	
legend.append("text") 
	.attr("x", 0)
	.attr("y",function(d) { return bubScale(d)+12; } )
	.style("text-anchor", "middle")
	.text(function(d) { return d; })
	.style("font", legop.lf);
']
		case 'default'
			if o.rectLegend
				legend = ['
svg.append("rect")
	.attr("x", legop.x)
	.attr("y", legop.y)
	.attr("transform","rotate("+legop.rot+")")
	.attr("width", legop.legendWidth)
	.attr("height", legop.legendHeight)
	.attr("fill", legop.lc)
	.attr("opacity", legop.lo)
	.attr("stroke", legop.ls)
	.attr("shape-rendering", "crispEdges");
']
			end
			legend = [legend '
for (i = 0; i < legop.dataset.length; i++) {
	var legend = svg.selectAll("legend")
		.data(legop.dataset[i][0])
		.enter()
		.append("g")
		.attr("class", "legend")
		.attr("transform", function(d) {
			var horz = i*legop.width + legop.horz;
			var vert = i*legop.height + legop.vert;
			return "translate(" + horz + "," + vert + ") rotate("+legop.rot+")";
		});
		
	if (legop.lst[i % legop.lst.length] == null && legop.ms[i % legop.ms.length] != "d3.symbolLine"){
		legend.append("path")
		.attr("transform","translate("+8.5+","+10+")")
		.attr("d",d3.symbol()
			.type(eval(legop.ms[i % legop.ms.length]))
			.size(35))
		.attr("stroke", legop.mst[i % legop.mst.length])
		.attr("fill", legop.mf[i % legop.mf.length])
		.style("shape-rendering", "crispEdges");
		
		legend.append("text") 
		.attr("x", legop.legendRectSize + legop.legendSpacing)
		.attr("y", legop.legendRectSize - legop.legendSpacing)
		.text(legop.dataset[i])
		.style("font", legop.lf);
	}
	else if (legop.lst[i % legop.lst.length] == "area"){
		legend.append("rect")
		.attr("width", legop.legendRectSize)
		.attr("height", legop.legendRectSize)
		.attr("fill", legop.color[i % legop.color.length])
		.style("shape-rendering", "crispEdges");
		
		legend.append("text") 
		.attr("x", legop.legendRectSize + legop.legendSpacing)
		.attr("y", legop.legendRectSize - legop.legendSpacing)
		.text(legop.dataset[i])
		.style("font", legop.lf);
	}
	else if (legop.lst[i % legop.lst.length] != "" && legop.ms[i % legop.ms.length] != "d3.symbolLine"){
		legend.append("line")
		.attr("x1", 2)
		.attr("y1", 10)
		.attr("x2", 15)
		.attr("y2", 10)
		.attr("stroke-width", 1)
		.attr("stroke", legop.color[i % legop.color.length])
		.style("stroke-dasharray", legop.lst[i % legop.lst.length])
		.style("shape-rendering", "crispEdges");
		
		legend.append("path")
		.attr("transform","translate("+8.5+","+10+")")
		.attr("d",d3.symbol()
			.type(eval(legop.ms[i % legop.ms.length]))
			.size(35))
		.attr("stroke", legop.mst[i % legop.mst.length])
		.attr("fill", legop.mf[i % legop.mf.length])
		.style("shape-rendering", "crispEdges");
		
		legend.append("text") 
		.attr("x", legop.legendRectSize + legop.legendSpacing)
		.attr("y", legop.legendRectSize - legop.legendSpacing)
		.text(legop.dataset[i])
		.style("font", legop.lf);
	}
	else {
		legend.append("line")
		.attr("x1", 2)
		.attr("y1", 10)
		.attr("x2", 15)
		.attr("y2", 10)
		.attr("stroke-width", 3)
		.attr("stroke", legop.color[i])
		.style("stroke-dasharray", legop.lst[i])
		.style("shape-rendering", "crispEdges");
		
		legend.append("text") 
		.attr("x", legop.legendRectSize + legop.legendSpacing)
		.attr("y", legop.legendRectSize - legop.legendSpacing)
		.text(legop.dataset[i])
		.style("font", legop.lf);
	}
};
']
	end
	out = legend
end