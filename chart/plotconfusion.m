function out = plotconfusion(act,pred,pos,thr,options)

	if isstruct(thr), options = thr, thr = []; end
	if isstruct(pos), options = pos, pos = []; end
	
	if numel(thr) > 1 && ~ischar(thr)
		for i = 1:numel(thr)
			op.show = false
			c{i} = plotconfusion(act,pred,pos,thr(i),op)
		end
		options.height = 250
		out = animate(c,options)
		return
	else
		options.height = 215
	end
	
	if ~isempty(thr), options.thr = thr; end
	
	% control if act has less than 2 different values
	a=1
	sortact = sort(act)
	for i=1:(size(sortact,1)-1)
		if ~isequal(sortact(i),sortact(i+1)), a = a + 1; end
	end
	if a>2, error('only two diferent values handled in act'); end

	% control if pred has more than 2 different values - vector of probabilities
	a=1
	sortpred = sort(pred)
	for i=1:(size(sortpred,1)-1)
		if ~isequal(sortpred(i),sortpred(i+1)), a = a + 1; end
	end
	if a>2 && isempty(thr), error('thr has to be defined'), elseif a<=2 && ~isempty(thr), error('thr has to be empty'); end
	
	[conf metrics] = confusion(act,pred,pos,thr) % calculate values from confusion.m
	
	if isempty(pos) | ~ischar(pos), pos = 'P', options.pos = 'P', else options.pos = pos; end
	if ~iscell(act), neg = 'N', options.neg = 'N', else options.neg = act{find(~strcmp(pos,act))}, if isempty(options.neg), options.neg = 'N', end; end
	
	% access to chartOptions
	minx = min(min(conf))
	maxx = max(max(conf))
	miny = min(min(conf))
	maxy = max(max(conf))
		
	options.type = 'confusionTable'
	options = chartOptions(options, minx, maxx, miny, maxy)
	
	tag = options.tag
	
	for k = 1:size(conf,1)
		tmp = sprintf('%f,',conf(k,:))
		matrixData = [matrixData '['  tmp(1:end-1) '],']
	end
	
	matrix = matrixData(1:end-1) % get the values of the confusion matrix to plot them in the table

	[css jsFrame xf yf] = chartFrame(options)	
			
	dataSet = ''
	jsFrame = ''
	jsData = ['
var w=' num2str(options.width) ',h=' num2str(options.height) ',pl=35,pb=70,pr=365,pt=30,as=0,xMin=1,xMax=4,yMin=0,yMax=0;

var xf=d3.format(".4f"); var yf=d3.format(".4f");
var cx=pl,cy=pt,cw=w-pr-pl,ch=h-pb-pt,colu=cw/5,row=40;

var svg = d3.select("#' tag '").append("svg")
	.attr("width","100%")
	.attr("height","100%")
	.attr("viewBox","0 0 " + w + " " + h);
	
var color = ["rgba(0, 128, 0, 0.2)","rgba(255, 133, 102, 0.2)","rgba(255, 133, 102,0.4)","rgba(0, 128, 0, 0.4)"];
var matrix = [' matrix '];	

for (var col = 0; col < matrix.length; col++){
	var newdataset = matrix[col];
	var table = svg.selectAll()
		.data(newdataset)
		.enter();
	table.append("rect")
		.attr("x",function(d,i) {return (w-pr+colu+i*((cw-colu)/matrix[0].length));})
		.attr("y",row+pt+col*(((ch)-row)/matrix.length))
		.attr("width",function(d) {return (cw-colu)/matrix[0].length } )
		.attr("height",function(d) {return ((ch)-row)/matrix.length; })
		.attr("stroke","black")
		.attr("fill", function(d,i) {
			return color[(i+2*col)];
		})
		.style("opacity",1)
		.style("shape-rendering","crispEdges")
		.html(function(d,i) { return newdataset[i]; });
	table.append("text") 
		.attr("text-anchor", "middle")
		.attr("dominant-baseline", "central")
		.attr("x",function(d,i) {return (w-pr+colu+(cw-colu)/4+i*((cw-colu)/2));})
		.attr("y",row+pt+((ch)-row)/4+col*(((ch)-row)/matrix.length))
		.text(function(d) { return d; })
		.style("font", "1em calibri");		
};	  

var act = svg.append("g");
act.append("rect")
	.attr("x",w-pr)
	.attr("y",pt+row)
	.attr("width",colu)
	.attr("height",(ch)-row)
	.attr("stroke","black")
	.style("fill","none")
	.style("shape-rendering","crispEdges");	
act.append("text")
	.style("font", "0.8em arial")
    .attr("x",-pt-ch+((ch)-row)/2)
	.attr("y",w-pr+colu/4)
	.attr("dominant-baseline", "central")
	.attr("text-anchor", "middle")
	.attr("transform", "rotate(-90)")
    .text("Actual Class");		

	
var actP = svg.append("g");	
actP.append("rect")
	.attr("x",w-pr+colu/2)
	.attr("y",pt+row)
	.attr("width",colu/2)
	.attr("height",((ch)-row)/2)
	.attr("stroke","black")
	.style("fill","none")
	.style("shape-rendering","crispEdges");
actP.append("text")
	.attr("text-anchor", "middle")
	.attr("dominant-baseline", "central")
    .attr("x",w-pr+colu*3/4)
	.attr("y",pt+row+((ch)-row)/4)
	.style("font", "0.8em arial")
    .text("' options.pos '");	
	
var actNP = svg.append("g");
actNP.append("rect")
	.attr("x",w-pr+colu/2)
	.attr("y",pt+row+((ch)-row)/2)
	.attr("width",colu/2)
	.attr("height",((ch)-row)/2)
	.attr("stroke","black")
	.style("fill","none")
	.style("shape-rendering","crispEdges");	
actNP.append("text")
	.attr("text-anchor", "middle")
	.attr("dominant-baseline", "central")
    .attr("x",w-pr+colu*3/4)
	.attr("y",pt+row+((ch)-row)*3/4)
	.style("font", "0.8em arial")
    .text("' options.neg '");	
	
var pred = svg.append("g");	
pred.append("rect")
	.attr("x",w-pr+colu)
	.attr("y",pt)
	.attr("width",cw-colu)
	.attr("height",row)
	.attr("stroke","black")
	.style("fill","none")
	.style("shape-rendering","crispEdges");	
pred.append("text")
	.attr("text-anchor", "middle")
	.attr("dominant-baseline", "central")
    .attr("x",w-pr+colu+(cw-colu)/2)
	.attr("y",pt+row/4)
	.style("font", "0.8em arial")
    .text("Predicted Class");	

var predP = svg.append("g");	
predP.append("rect")
	.attr("x",w-pr+colu)
	.attr("y",pt+row/2)
	.attr("width",(cw-colu)/2)
	.attr("height",row/2)
	.attr("stroke","black")
	.style("fill","none")
	.style("shape-rendering","crispEdges");	
predP.append("text")
	.attr("text-anchor", "middle")
	.attr("dominant-baseline", "central")
    .attr("x",w-pr+colu+(cw-colu)/4)   
	.attr("y",pt+row*3/4)
	.style("font", "0.8em arial")
    .text("' options.pos '");	
	
var predNP = svg.append("g");
predNP.append("rect")
	.attr("x",w-pr+colu+(cw-colu)/2)
	.attr("y",pt+row/2)
	.attr("width",(cw-colu)/2)
	.attr("height",row/2)
	.attr("stroke","black")
	.style("fill","none")
	.style("shape-rendering","crispEdges");	
predNP.append("text")
	.attr("text-anchor", "middle")
	.attr("dominant-baseline", "central")
    .attr("x",w-pr+colu+(cw-colu)*3/4)
	.attr("y",pt+row*3/4)
	.style("font", "0.8em arial")
    .text("' options.neg '");	
	']
legend = ''
	
	for k = 1:3
		tmp = sprintf('%f,',metrics(:,k))
		data = [data '['  tmp(1:end-1) '],']
	end
	
	values1 = data(1:end-1) % get the values for the Model Performance 'table'
	
	for k = 4:5
		tmp = sprintf('%f,',metrics(:,k))
		data2 = [data2 '['  tmp(1:end-1) '],']
	end
	
	values2 = data2(1:end-1) % get the values for the Model Performance 'table'
	
	jsData = [jsData '	
svg.append("text")
	.attr("text-anchor", "start")
    .attr("x",pl)
	.attr("y",pt+15)
	.style("font", "1.1em arial")
    .text("Model Performance");		
	
var values = [' values1 '];
var performance = ["Accuracy:","Precision:","F1 Score:"];

var legend1 = svg.selectAll("legend1")
	.data(values)
	.enter()
	.append("g")
	.attr("class", "legend1")
	.attr("transform", function(d, i) {
		var horz = pl;
		var vert = i * 24 + pt+30;
		return "translate(" + horz + "," + vert + ")";
	});

legend1.append("text") 
	.data(performance)
	.attr("x", 0)
	.attr("y", 15)
	.text(function(d) { return d; })
	.style("font", "1.1em calibri");

legend1.append("text") 
	.attr("x", 75)
	.attr("y", 15)
	.text(function(d) { return d3.format(",.2%")(d); })
	.style("font", "1.1em calibri");		

var values = [' values2 '];
var performance = ["TPR:","FPR:"];

var legend1 = svg.selectAll("legend1")
	.data(values)
	.enter()
	.append("g")
	.attr("class", "legend1")
	.attr("transform", function(d, i) {
		var horz = pl;
		var vert = i * 24 + pt+102;
		return "translate(" + horz + "," + vert + ")";
	});

legend1.append("text") 
	.data(performance)
	.attr("x", 0)
	.attr("y", 15)
	.text(function(d) { return d; })
	.style("font", "1.1em calibri");

legend1.append("text") 
	.attr("x", 75)
	.attr("y", 15)
	.text(function(d) { return d3.format(",.2")(d); })
	.style("font", "1.1em calibri");	
	
var dataset = ["True positive","False negative"];
var color = ["rgba(0, 128, 0, 0.2)","rgba(255, 133, 102, 0.2)"];

var legend = svg.selectAll("legend")
	.data(dataset)
	.enter()
	.append("g")
	.attr("class", "legend")
	.attr("transform", function(d, i) {
		var horz = w-pr;
		var vert = i * 24 + pt+(ch)+30;
		return "translate(" + horz + "," + vert + ")";
	});

legend.append("rect")
	.attr("width", 10)
	.attr("height", 10)
	.attr("fill", function(d,i) {
		return color[i];
	})
	.style("stroke", color);

legend.append("text") 
	.attr("x", 15)
	.attr("y", 7.5)
	.text(function(d) { return d; })
	.style("font", "0.8em calibri"); 
	
var dataset = ["True negative","False positive"];
var color = ["rgba(0, 128, 0, 0.4)","rgba(255, 133, 102, 0.4)"];

var legend = svg.selectAll("legend")
	.data(dataset)
	.enter()
	.append("g")
	.attr("class", "legend")
	.attr("transform", function(d, i) {
		var horz = w-pr+110;
		var vert = i * 24 + pt+(ch)+30;
		return "translate(" + horz + "," + vert + ")";
	});

legend.append("rect")
	.attr("width", 10)
	.attr("height", 10)
	.attr("fill", function(d,i) {
		return color[i];
	})
	.style("stroke", color);

legend.append("text") 
	.attr("x", 15)
	.attr("y", 7.5)
	.text(function(d) { return d; })
	.style("font", "0.8em calibri"); 
']
	if isfield(options,'thr')
		jsData = [jsData '
		
svg.append("text")
	.attr("text-anchor", "start")
    .attr("x",pl)
	.attr("y",24+pt+(ch)+30)
	.style("font", "1.1em arial")
    .text("Threshold: ' num2str(options.thr) ' ");	
		
		']
	end
	
	
	
	
	if options.save
		html = chartHtml(options,css,[dataSet jsFrame jsData legend],false,options.web)		
		filePath = [options.folder '\' options.name '.html']
		fid = fopen(filePath,'w+')
		fprintf(fid,'%s',html)
		fclose(fid)
	end
	if options.show
		sh(filePath)
	end

	out = struct(	'type',options.type,...
						'subtype','2d',...
						'css',css,...
						'dataSet',dataSet,...
						'jsFrame',jsFrame,...
						'jsData',jsData,...
						'legend',legend,...
						'image','',...
						'tag',options.tag,...
						'options',options,...
						'divTag',['<div id="' options.tag '"></div>'])

end