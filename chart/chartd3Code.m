function jsData = chartd3Code(id,o)
	
	yScale = 'yScale'
	if o.useSecondaryAxis, yScale = 'y2Scale'; end
	
	jsData = ['
for (i = 0; i < sizeY[0]; i++) {
	var rdat = dat.slice(sizeY[1]*i, ((i+1)*sizeY[1]));
	rdat = rdat.filter(function(d) { return (!isNaN(d.x) && !isNaN(d.y) &&
											isFinite(d.x) && isFinite(d.y) &&
											!isNaN(xScale(d.x)) && !isNaN(' yScale '(d.y)) &&
											isFinite(xScale(d.x)) && isFinite(' yScale '(d.y)));});
	if (op.hover != "null") {
		op.hover[i] = op.hover[i].filter(function(d) { return (d != null && isFinite(d) && xScale(d) != null && isFinite(xScale(d))); });
	}
']
	
	switch id
		case 'showArea'
			jsData = [jsData '
	var area = d3.area()
		.x(function(d,i) { return xScale(d.x); })
		.y0(' yScale '(op.areaBase))
		.y1(function(d) { return ' yScale '(d.y); });

	var defs = svg.append("defs");
	defs.append("clipPath")
		.attr("id", "clip-above_" + op.tag + "")
		.append("rect")
		.attr("width", w)
		.attr("height", ' yScale '(op.areaBase));
	  
	defs.append("clipPath")
		.attr("id", "clip-below_" + op.tag + "")
		.append("rect")
		.attr("y", ' yScale '(op.areaBase))
		.attr("width", w)
		.attr("height", h-' yScale '(op.areaBase));

	var areaGraphAbove = svg.append("path")
		.datum(rdat)
		.attr("clip-path", "url(#clip-above_" + op.tag + ")")
		.attr("fill",op.areaAboveStroke[i % op.areaAboveStroke.length])
		.style("opacity",op.areaOpacity)
		.style("stroke-dasharray",op.dashArray)
		.attr("d", area);

	var areaGraphBelow = svg.append("path")
		.datum(rdat)
		.attr("clip-path", "url(#clip-below_" + op.tag + ")")
		.attr("fill",op.areaBelowStroke[i % op.areaBelowStroke.length])
		.style("opacity",op.areaOpacity)
		.style("stroke-dasharray",op.dashArray)
		.attr("d", area);
}
']
		case 'showLine'
			jsData = [jsData '
	var lineFunction = d3.line()
		.x(function(d) { return xScale(d.x); })
		.y(function(d) { return ' yScale '(d.y); })
		.curve(eval(op.lineInterpolate[i % op.lineInterpolate.length]));
	var lineGraph = svg.append("path")
		.attr("d", lineFunction(rdat))
		.attr("stroke",op.lineStroke[i % op.lineStroke.length])
		.style("stroke-dasharray",op.dashArray)
		.attr("stroke-width",op.lineWidth)
		.attr("fill",op.lineFill)	
		.attr("clip-path","url(#clipPath_" + op.tag + ")");		
}
']
		case 'showMarkers'
			jsData = [jsData '
	var bubScale = d3.scaleLinear().domain([' num2str(min(o.markerSize)) ',' num2str(max(o.markerSize)) ']).range([' o.minRange ', ' o.maxRange ']);
	
	var sym = svg.append("g").attr("clip-path","url(#clipPath_" + op.tag + ")");
	sym.selectAll()
		.data(rdat)
		.enter()
		.append("path")
		.attr("d",d3.symbol(i)
			.type(eval(op.markerShape[i % op.markerShape.length]))
			.size(function(d,i) {return Math.PI*Math.pow(bubScale(op.markerSize[0][i % op.markerSize[0].length]),2)}))
		.attr("stroke",function(d,ii){
			if (Array.isArray(op.markerStroke) && typeof(op.markerStroke[0]) != "string") return colorScale(op.markerStroke[0][ii]);
			else return op.markerStroke[i % op.markerStroke.length];
		})
		.attr("fill",function(d,i){
			if (typeof(op.markerFill[0]) == "string") return op.markerFill[i % op.markerFill.length];
			else return colorScale(op.markerFill[0][i]);
		})
		.attr("transform",function(d,i) { 
			return "translate("+xScale(d.x)+","+' yScale '(d.y)+")"; 
		})
		.style("cursor","pointer")
		.on("mouseover", function(d,i){
			eval(op.hov);
			copyData.style("font-family", "Arial");
			copyData.style("font-size", "0.8em");
			copyData.style("background-color", "#f2f2f2");
			copyData.style("border", "1px solid #B0B0B0");
			copyData.style("padding", "5px");
			copyData.style("visibility", "visible");
			return copyData.style("top", (d3.event.pageY+8)+"px").style("left",(d3.event.pageX+12)+"px");
		})
		.on("mouseout", function(){return copyData.style("visibility", "hidden");})
		.on("click", function (d,i) {
			var $temp = $("<textarea>");
			$("body").append($temp);
			eval(op.cop);
			document.execCommand("copy");
			$temp.remove();
		});
}
']
		case 'showBars'
			if numel(o.barBase) == 1
				jsData = [jsData '
	var baseLine = svg.append("line")
		.attr("stroke","black")
		.attr("shape-rendering","crispEdges") 
		.attr("x1",pl-as)
		.attr("x2",w-pr)
		.attr("y1",' yScale '(op.barBase))
		.attr("y2",' yScale '(op.barBase))	
		.attr("clip-path","url(#clipPath_c0)");']
			end
			jsData = [jsData '
	var bar = svg.append("svg").attr("width",w,"height",h);
	bar.selectAll()
		.data(rdat)
		.enter()
		.append("rect")
		.attr("x",function(d,ii) { 
			return xScale(d.x-op.barTranslate[i % op.barTranslate.length]); 
		})
		.attr("y",function(d,i) { return Math.min(' yScale '(d.y),' yScale '(op.barBase[0][i % op.barBase[0].length])); })
		.attr("width",function(d,i) {
			return (xScale(op.barWidth[0][i % op.barWidth[0].length])-xScale(0));
		})
		.attr("height",function(d,i) { 
			return Math.abs(-yScale(d.y)+yScale(op.barBase[0][i % op.barBase[0].length])); 
		})
		.style("fill",function(d,ii) { 
			if (sizeY[0] > 1) {n = i;}
			else {n = ii;}
			if ((-yScale(d.y)+yScale(op.barBase[0][ii % op.barBase[0].length]))>0)	{ return op.barFillPos[n % op.barFillPos.length];}
			else { return op.barFillNeg[n % op.barFillNeg.length];}
		})
		.style("opacity",op.barOpacity)
		.style("shape-rendering","crispEdges")
		.style("stroke",op.barStroke)
		.style("stroke-width",op.barStrokeWidth)
		.on("mouseover",function() {
			c = this.style.fill;
			d3.select(this).style("fill","red");
		})
		.on("mouseout",function() { d3.select(this).style("fill",c);})
		.append("svg:title")
		.html(function(d,ii) { return op.hover[i][ii]; });
	bar.attr("clip-path","url(#clipPath_c0)");
}
']
		case 'heatmap'
			if ~o.gradientHM
				jsData = [jsData '
	svg.selectAll()
		.data(rdat)
		.enter()
		.append("rect")
		.attr("x",function(d,i) {return i*(cw/dx)+pl;})
		.attr("y",i*(ch/dy)+pt)
		.attr("width",function(d) {return cw/dx } )
		.attr("height",function(d) {return ch/dy; })
		.style("fill",function(d,i) {return color(d.x);})
		.style("opacity",1)
		.style("shape-rendering","crispEdges")
		.on("mouseover",function(){c = this.style.fill,d3.select(this).style("fill","#4d1a00");})
		.on("mouseout",function(d,i){ d3.select(this).style("fill",c);})
		.append("svg:title")
		.html(function(d) { return d.x; });
};	  
']
			else
				jsData = [ '
	canvas.draw = function () {
		image = canvas.createImageData(dx,dy);
		for (var y = 0,p = -1; y < dy; ++y) {
			for (var x = 0; x < dx; ++x) {
				var c = d3.rgb(color(datasetX[x+y*dx]));
				image.data[++p] = c.r;
				image.data[++p] = c.g;
				image.data[++p] = c.b;
				image.data[++p] = 255;
			}
		}
		canvas.putImageData(image,0,0);
	}
	canvas.draw();
']
			end
		case 'pie'
			jsData = [jsData '
	var radius = ch / 2;

	var arc = d3.arc()
		.innerRadius(0)
		.outerRadius(radius);

	var pie = d3.pie()
		.value(function(d) { return d.y; })
		.sort(null);

	var path = svg.selectAll("path")
		.data(pie(rdat))
		.enter()
		.append("path")
		.attr("d", arc)
		.attr("stroke", "white")
		.attr("fill", function(d,i) {
			return colorPie(i);
		})
		.attr("transform", function(d,i) {
			var x = explode[i]*arc.centroid(d)[0]/8;
			var y = explode[i]*arc.centroid(d)[1]/8;
			return "translate(" + x +"," + y + ")";
		})
		.on("mouseover",function(){ c = this.style.fill, d3.select(this).style("fill","red");})
		.on("mouseout",function(d,i){ d3.select(this).style("fill",c) 
		})
		.append("svg:title")
		.html(function(d,i) { return datasetY[i]; });
']
			if ~strcmp(o.pieVal,'none')
				jsData = [jsData '
	var text = svg.selectAll("text.pie")
		.data(pie(rdat))
		.enter()
		.append("text")
		.attr("class", "pie")
		.attr("x", function(d) {return arc.centroid(d)[0]*op.pieValue; })
		.attr("y",function(d,i) {return arc.centroid(d)[1]*op.pieValue; })
		.attr("dy", ".45em")
		.attr("transform", function(d,i) {
			var x = explode[i]*arc.centroid(d)[0]/8;
			var y = explode[i]*arc.centroid(d)[1]/8;
			return "translate(" + x +"," + y + ")";
		})
		.text( function (d,i) { return [d3.format(".2f")(datasetX[i]) + "%"]; })
		.style("text-anchor", "middle")
		.style("font", op.xAxisFont);
		
	var rem = text.filter(function(d,i) {
		if (i == 0){
			return ((Math.abs(text._groups[0][i].y.animVal[0].value-
			text._groups[0][datasetX.length-1].y.animVal[0].value) < 10) && 
			(Math.abs(text._groups[0][i].x.animVal[0].value-
			text._groups[0][datasetX.length-1].x.animVal[0].value) < 30));
		}
		else {
			return ((Math.abs(text._groups[0][i].y.animVal[0].value-
			text._groups[0][i-1].y.animVal[0].value) < 10) && 
			(Math.abs(text._groups[0][i].x.animVal[0].value-
			text._groups[0][i-1].x.animVal[0].value) < 30));
		}
		}).remove();
		
	var rem2 = text.filter(function(d,i) { return datasetX[i] == 0; }).remove();
']
				jsData = [jsData '}
']
			end
		case 'showLabels'
			jsData = ['
svg.selectAll()
	.data(op.labels.txt)
	.enter()
	.append("text")
	.attr("x",function(d,i) { return xScale(op.labX[0][i])+op.markerSize[0][i % op.markerSize[0].length]; })
	.attr("y",function(d,i) { return yScale(op.labY[0][i]); })
	.text( function (d) { return d; })
	.style("text-anchor", op.labelsAnchor)
	.style("font",op.labelsFont)
	.attr("fill","black");
']
		case 'refLines'
			jsData = [' 
var starts = svg.append("svg")
	.selectAll("line")
	.data(dat)
	.enter()
	.append("line")
	.attr("stroke","black")
	.style("stroke-dasharray",("1 2"))
	.attr("shape-rendering","crispEdges")
	.attr("x1",function(d) { return xScale(d.x); })
	.attr("x2",function(d) { return xScale(d.x); })
	.attr("y1",function(d,i) { return yScale(yMin); })
	.attr("y2",function(d,i) { return yScale(d.y); });
']
		case 'showValues'
			jsData = [' 
var values = svg.append("svg")
	.selectAll("text")
	.data(dat)
	.enter()
	.append("text")
	.attr("x", function(d,i) {return xScale(d.x+op.barWidth[0][i % op.barWidth[0].length]/2); })
	.attr("y",function(d,i) { 
		if ((-yScale(d.y)+yScale(op.barBase[0][i % op.barBase[0].length]))>0) {
			return yScale(d.y)-4;}
		else {return yScale(d.y)+10;} 
	})
	.text(function(d,i) { return d3.format(op.barValueFormat)(op.hover[0][i]); })
	.style("text-anchor", "middle")
	.style("font", "0.65em arial")
	.style("fill", "black");
']
	end

end

