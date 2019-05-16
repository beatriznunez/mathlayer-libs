(function()
{
	var Surface = function(node)
	{
		var colorFunction,timer,timer,transformPrecalc=[];
		var trans, xFactor, yFactor, zFactor, canvasData, dr;
		var cb0, cb1, cb2, cb3, cl0, cl1, cl2, cl3, cf0, cf1, cf2, cf3;
		var xFactor, yFactor, zFactor;
		// store data
		var allData = node.datum();
		var data = allData.dataset;
		var zoom = allData.zoom;
		var showCanvas = allData.showCanvas;
		var tooltip = allData.tooltip > 0.5;
		var chartType = allData.chartType;
		var labels = allData.labels;

		var displayYaw = allData.yaw;
		var displayPitch = allData.pitch;
		var displayDepth = allData.depth;
		var displayHeight = allData.height;
		var displayWidth = allData.width;
		
		var labelsFont = allData.labelsFont;
		var markerSize = allData.markerSize;
		var markerFill = allData.markerFill;
		var markerStroke3d = allData.markerStroke3d;
		var opacity = allData.opacity;
		var surfOpacity = allData.surfOpacity;
		var lineStroke = allData.lineStroke;
		var lineWidth = allData.lineWidth;
		var lineInterp = allData.lineInterpolate;
		var lineFill = "none";
		
		var xDate = allData.xDate;
		var yDate = allData.yDate;
		var zDate = allData.zDate;
		
		var axesNames = allData.axesNames;
		
		var minX = allData.minX;
		var maxX = allData.maxX;
		var minY = allData.minY;
		var maxY = allData.maxY;
		var minZ = allData.minZ;
		var maxZ = allData.maxZ;
		var rngX = maxX - minX;
		var rngY = maxY - minY;
		var rngZ = maxZ - minZ;
	
		this.setZoom = function(zoomLevel)
		{
			zoom = zoomLevel;
			if(timer) clearTimeout(timer);
			timer = setTimeout(renderSurface);
		};

		var transformPoint = function(point)
		{
			var x = transformPrecalc[0]*point[0]+transformPrecalc[1]*point[1]+transformPrecalc[2]*point[2]+Math.max(displayWidth,displayDepth)/2;
			var y = transformPrecalc[3]*point[0]+transformPrecalc[4]*point[1]+transformPrecalc[5]*point[2]+displayHeight/2;
			var z = transformPrecalc[6]*point[0]+transformPrecalc[7]*point[1]+transformPrecalc[8]*point[2];
			if(isNaN(x+y+z) || !isFinite(x+y+z))
			{
				return [NaN,NaN,0];
			}
			return [x,y,z];
		};

		var getTransformedData = function(i)
		{
			var t, nr = data[i][0].length, nc = data[i][0][0].length, output = [];
			for(var x=0;x<nr;x++)
			{
				output.push(t=[]);
				for(var y=0;y<nc;y++)
				{
					t.push(transformPoint([(data[i][0][x][y]-(maxX+minX)/2)*xFactor, (-data[i][2][x][y]+(maxZ+minZ)/2)*zFactor, (data[i][1][x][y]-(maxY+minY)/2)*yFactor]));
				}
			}
			return output;
		};
		
		var renderSurface = function()
		{
			xFactor = 1/rngX*displayDepth*zoom;
			yFactor = 1/rngY*displayWidth*zoom;
			zFactor = 1/rngZ*displayHeight*zoom;
			
			if(showCanvas)
			{
				// cb: canvas base
				cb0 = transformPoint([-rngX/2*xFactor,rngZ/2*zFactor,-rngY/2*yFactor]);
				cb1 = transformPoint([rngX/2*xFactor,rngZ/2*zFactor,-rngY/2*yFactor]);
				cb2 = transformPoint([rngX/2*xFactor,rngZ/2*zFactor,rngY/2*yFactor]);
				cb3 = transformPoint([-rngX/2*xFactor,rngZ/2*zFactor,rngY/2*yFactor]);
				// cl: canvas left
				cl0 = transformPoint([-rngX/2*xFactor,rngZ/2*zFactor,rngY/2*yFactor]);
				cl1 = transformPoint([rngX/2*xFactor,rngZ/2*zFactor,rngY/2*yFactor]);
				cl2 = transformPoint([rngX/2*xFactor,-rngZ/2*zFactor,rngY/2*yFactor]);
				cl3 = transformPoint([-rngX/2*xFactor,-rngZ/2*zFactor,rngY/2*yFactor]);
				// cf: canvas front
				cf0 = transformPoint([rngX/2*xFactor,rngZ/2*zFactor,-rngY/2*yFactor]);
				cf1 = transformPoint([rngX/2*xFactor,-rngZ/2*zFactor,-rngY/2*yFactor]);
				cf2 = transformPoint([rngX/2*xFactor,-rngZ/2*zFactor,rngY/2*yFactor]);
				cf3 = transformPoint([rngX/2*xFactor,rngZ/2*zFactor,rngY/2*yFactor]);			

				cb = [	{"x":cb0[0],"y":cb0[1]},
				{"x":cb1[0],"y":cb1[1]},
				{"x":cb2[0],"y":cb2[1]},
				{"x":cb3[0],"y":cb3[1]}];

				cl = [	{"x":cl0[0],"y":cl0[1]},
				{"x":cl1[0],"y":cl1[1]},
				{"x":cl2[0],"y":cl2[1]},
				{"x":cl3[0],"y":cl3[1]}];

				cf = [	{"x":cf0[0],"y":cf0[1]},
				{"x":cf1[0],"y":cf1[1]},
				{"x":cf2[0],"y":cf2[1]},
				{"x":cf3[0],"y":cf3[1]}];

				canvasData = [cb, cl, cf];

				dr = node.selectAll("polygon").data(canvasData);
				dr.enter().append("polygon");
				node.selectAll("polygon").attr("points",function(d) { return d.map(function(d) { return [d.x,d.y].join(","); }).join(" ");})
				.attr("stroke","black")
				.attr("stroke-width",1)
				.attr("fill","steelBlue")
				.attr("opacity",0.2)
				.attr("shape-rendering","crispEdges");
			}
			
			var nrt, nct, depth, color, path, tData, d0=[], d1=[], d2=[];		
			for(var i = 0; i<data.length; i++)
			{
				tData = getTransformedData(i);
				nrt = tData.length;
				nct = tData[0].length;
				if (tooltip || 0==chartType[i].localeCompare("scatter3"))
				{
					var markerO, markerF, markerR;
					if(markerSize[i] == 0)
					{
						markerR = 10*zoom;
						markerO = 0;
						markerF = 'black';
						markerSW = 0;
					}
					else
					{
						markerR = markerSize[i];
						markerO = opacity[i];
						markerF = markerFill[i];		
						markerSW = 1;	
					}
					for(var x=0;x<nrt;x++)
					{
						for(var y=0;y<nct;y++)
						{
							if(0==markerStroke3d[i].localeCompare("default")){
								markerStroke3dTemp="#3366cc"
							}
							else if(0==markerStroke3d[i].localeCompare("gradient")){
								markerStroke3dTemp=colorFunction(data[i][2][x][y]*zFactor)
							}
							else{
								markerStroke3dTemp=markerStroke3d[i]
							}
						
							d1.push(
							{
								x0: data[i][0][x][y],
								y0: data[i][1][x][y],
								z0: data[i][2][x][y],
								x: tData[x][y][0],
								y: tData[x][y][1],
								z: data[i][2][x][y]*zFactor,
								depth: tData[x][y][2],
								r: markerR,
								opacity: markerO,
								l: labelsFont[i],
								stroke: markerStroke3dTemp,
								strokeWidth: markerSW,
								fill: markerF,
								lab: labels[i][(x*nct)+y]
							});
						}
					}
				}

				if(0==chartType[i].localeCompare("scatter3") || 0==chartType[i].localeCompare("plot3"))
				{
					var x, y, x2, y2;
					for(var k=0;k<nrt*nct-1;k++)
					{
						path = "";
						color = 0;
						x = k % nrt;
						y = Math.floor(k/nrt);
						x2 = (k+1) % nrt;
						y2 = Math.floor((k+1)/nrt);
						if(!isNaN(tData[x][y][0])){ path += "L" + tData[x][y][0] + "," + tData[x][y][1]; color = data[i][2][x][y]; }
						if(!isNaN(tData[x2][y2][0])){ path += "L" + tData[x2][y2][0] + "," + tData[x2][y2][1]; color = data[i][2][x2][y2]; }
						path = "M" + path.substr(1,path.length);
						d0.push(
						{
							path: path,	
							depth: tData[x][y][2] + tData[x2][y2][2],
							data: color * 200/rngZ,
							lineWidth: lineWidth[i],
							lineStroke: lineStroke[i],
							lineInterp: lineInterp[i]
						});
					}
				}
				if(0==chartType[i].localeCompare("surf"))
				{
					for(var x=0;x<nrt-1;x++)
					{
						for(var y=0;y<nct-1;y++)
						{
							path = "";
							color = 0;
							non = 0;
							if(!isNaN(tData[x][y][0])){ non=non+1; path += "L" + tData[x][y][0] + "," + tData[x][y][1]; }
							if(!isNaN(tData[x+1][y][0])){ non=non+1; path += "L" + tData[x+1][y][0] + "," + tData[x+1][y][1]; }
							if(!isNaN(tData[x+1][y+1][0])){ non=non+1; path += "L" + tData[x+1][y+1][0] + "," + tData[x+1][y+1][1]; }
							if(!isNaN(tData[x][y+1][0])){ non=non+1; path += "L" + tData[x][y+1][0] + "," + tData[x][y+1][1]; }
							color = data[i][2][x][y];
							if(non == 4){path = "M" + path.substr(1,path.length) + "Z";}
							d0.push(
							{
								path: path,	
								depth: tData[x][y][2]+tData[x+1][y][2]+tData[x+1][y+1][2]+tData[x][y+1][2],
								data: color * 200/rngZ,
								opacity: surfOpacity[i],
								lineWidth: lineWidth[i],
								lineStroke: lineStroke[i],
								lineInterp: lineInterp[i]
							});
						}
					}
				}
			}
			d0.sort(function(a, b){return b.depth - a.depth;});
			d1.sort(function(a, b){return b.depth - a.depth;});
			//d2.sort(function(a, b){return b.depth - a.depth;});

/////////////////////////////////////////////////////////////////
// path: line or surf
			dr = node.selectAll("path").data(d0);
			dr.enter().append("path");
			node.selectAll("path").attr("d",function(d){return d.path;})
			.attr("opacity",function(d) { return d.opacity;})
			.attr("stroke",function(d){return d.lineStroke;})
			.attr("stroke-width",function(d){return d.lineWidth;});
			//dr.attr("interpolate",function(d){return d.lineInterp;});
			if(colorFunction)
			{ 
		
				node.selectAll("path").attr("fill",function(d){return colorFunction(d.data)});
			}	

			
/////////////////////////////////////////////////////////////////
// scatter
			dr = node.selectAll("circle").data(d1);
			dr.enter().append("circle");
			node.selectAll("circle").attr("cx",function(d) { return d.x;})
			.attr("cy",function(d) { return d.y;})
			.attr("stroke",function(d) { return d.stroke;})
			.attr("stroke-width",function(d){ return d.strokeWidth;})
			.attr("opacity",function(d) { return d.opacity;})
			.attr("fill",function(d) { return d.fill;})
			.attr("r",function(d) { return d.r;})
			.filter(function(d) { return isNaN(d.x); }).remove()
			.filter(function(d) { return isNaN(d.y); }).remove()
			.attr("shape-rendering","crispEdges");
			if(showCanvas)
			{
				node.selectAll("circle").on("mouseover",function(d)
				{
					var x = transformPoint([(d.x0-(maxX+minX)/2)*xFactor, rngZ/2*zFactor,-rngY/2*yFactor]);
					var z = transformPoint([-rngX/2*xFactor, (-d.z0+(maxZ+minZ)/2)*zFactor,rngY/2*yFactor]);
					var y = transformPoint([-rngX/2*xFactor, rngZ/2*zFactor,(d.y0-(maxY+minY)/2)*yFactor]);
					d3.select(this.parentNode).append("circle")
						.attr("id","x")
						.attr("cx",x[0])
						.attr("cy",x[1])
						.attr("stroke","black")
						.attr("fill","steelBlue")
						.attr("r",3);
					d3.select(this.parentNode).append("circle")
						.attr("id","y")
						.attr("cx",y[0])
						.attr("cy",y[1])
						.attr("stroke","black")
						.attr("fill","steelBlue")
						.attr("r",3);
					d3.select(this.parentNode).append("circle")
						.attr("id","z")
						.attr("cx",z[0])
						.attr("cy",z[1])
						.attr("stroke","black")
						.attr("fill","steelBlue")
						.attr("r",3);
					d3.select(this.parentNode).append("circle")
						.attr("id","xyz")
						.attr("cx",d.x)
						.attr("cy",d.y)
						.attr("stroke","black")
						.attr("fill","steelBlue")
						.attr("r",3);
						
					d3.select(this.parentNode).append("text")
						.attr("id","xt")
						.attr("dx",x[0]+20)
						.attr("dy",x[1]+10)
						.attr("font-size","10px")
						.text(xDate == 0 ? d3.format(".3f")(d.x0) : d3.timeFormat("%Y-%m-%d")(new Date(d.x0)));
					d3.select(this.parentNode).append("text")
						.attr("id","yt")
						.attr("dx",y[0]-20)
						.attr("dy",y[1]+20)
						.attr("font-size","10px")
						.text(yDate == 0 ? d3.format(".3f")(d.y0) : d3.timeFormat("%Y-%m-%d")(new Date(d.y0)));
					d3.select(this.parentNode).append("text")
						.attr("id","zt")
						.attr("dx",z[0]-35)
						.attr("dy",z[1])
						.attr("font-size","10px")
						.text(zDate == 0 ? d3.format(".3f")(d.z0) : d3.timeFormat("%Y-%m-%d")(new Date(d.z0)));
				});
			}
			node.selectAll("circle").on("mouseout", function(d)
									{
										d3.select(this.parentNode).select("#x").remove();
										d3.select(this.parentNode).select("#y").remove();
										d3.select(this.parentNode).select("#z").remove();
										d3.select(this.parentNode).select("#xyz").remove();
										d3.select(this.parentNode).select("#xt").remove();
										d3.select(this.parentNode).select("#yt").remove();
										d3.select(this.parentNode).select("#zt").remove();
									});
			
			tickPos = [
							[cb0[0],cb0[1],minY,-30,15,yDate],		[cb3[0],cb3[1],maxY,-30,15,yDate],
							[cb0[0],cb0[1],minX,10,10,xDate],	[cb1[0],cb1[1],maxX,10,10,xDate],
							[cl0[0],cl0[1],minZ,-35,0,zDate],		[cl3[0],cl3[1],maxZ,-35,0,zDate]
						];
			
			axesNamesData = [axesNames[0][1],axesNames[0][0],axesNames[0][2]]
			
			// dr = node.selectAll("circle").data(tickPos);
			// dr.enter().append("circle");
			// dr.attr("cx",function(d) { return d[0]})
			// .attr("cy",function(d) { return d[1]})
			// .attr("stroke","black")
			// .attr("stroke-width",1)
			// .attr("fill","steelBlue")
			// .attr("opacity",0.3)
			// .attr("r",3)
			// .attr("shape-rendering","crispEdges");
			
			dr = node.selectAll("text.axes").data(tickPos);
			dr.enter().append("text").attr('class', 'axes');
			node.selectAll("text.axes").attr("x",function(d) { return d[0]+d[3]})
			.attr("y",function(d) { return d[1]+d[4]})
			.text(function(d){ return d[5] == 0 ? d3.format(".3f")(d[2]) : d3.time.format("%Y-%m-%d")(new Date(d[2]));})
			.attr("font-size","10px");
			
			// add labels
			dr = node.selectAll("text.labels").data(d1);
			dr.enter().append("text").attr('class', 'labels');
			node.selectAll("text.labels").attr("x",function(d) { return d.x + 6;})
			.attr("y",function(d) { return d.y + 6;})
			.text(function(d){ return d.lab;})
			.style("font", function(d){ return d.l;})
			.attr("font-size","10px")
			.filter(function(d) { return isNaN(d.x); }).remove()
			.filter(function(d) { return isNaN(d.y); }).remove();
			
			// add axis names
			dr = node.selectAll("text.axesname").data(axesNamesData);
			dr.enter().append("text").attr('class', 'axesname');
			node.selectAll("text.axesname").attr("x",function(d,i) { return ((tickPos[i*2+1][0]+tickPos[i*2+1][3])+((tickPos[i*2][0]-tickPos[i*2+1][0])/2));})
			.attr("y",function(d,i) { return (tickPos[i*2+1][1]+tickPos[i*2+1][4]+((tickPos[i*2][1]-tickPos[i*2+1][1])/2));})
			.text(function(d){ return d;})
			.style("font", "bold 11px arial")
		};

		this.setTurtable = function(yaw, pitch)
		{
			var cosA = Math.cos(pitch);
			var sinA = Math.sin(pitch);
			var cosB = Math.cos(yaw);
			var sinB = Math.sin(yaw);
			transformPrecalc[0] = cosB;
			transformPrecalc[1] = 0;
			transformPrecalc[2] = sinB;
			transformPrecalc[3] = sinA*sinB;
			transformPrecalc[4] = cosA;
			transformPrecalc[5] = -sinA*cosB;
			transformPrecalc[6] = -sinB*cosA;
			transformPrecalc[7] = sinA;
			transformPrecalc[8] = cosA*cosB;
			if(timer) clearTimeout(timer);
			timer = setTimeout(renderSurface);
			return this;
		};

		this.setTurtable(displayYaw,displayPitch);

		this.surfaceColor = function(callback)
		{
			colorFunction = callback;
			if(timer) clearTimeout(timer);
			timer = setTimeout(renderSurface);
			return this;
		};

	};

	d3.selection.prototype.surface3D = function()
	{
		if(!this.node().__surface__) this.node().__surface__ = new Surface(this);
		var surface = this.node().__surface__;
		this.turntable = surface.setTurtable;
		this.surfaceColor = surface.surfaceColor;
		this.zoom = surface.setZoom;
		return this;
	};
})();