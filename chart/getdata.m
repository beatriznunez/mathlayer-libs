function [data o] = getdata(x,y,o)
	
	% number of points control
	try
		dataX = sprintf('%f,',x')
		dataX = strrep(dataX,'Inf','Infinity')
	catch e
		error('Maximum number of points exceeded. Reduce "x" dimensions.')
	end
	try
		dataY = sprintf('%f,',y')
		dataY = strrep(dataY,'Inf','Infinity')
	catch e
		error('Maximum number of points exceeded. Reduce "y" dimensions.')
	end
	
	% take options to generate the javascript variable with the needed options for the graph (op)
	auxop = getGraphOpt(o)
	opnames = fieldnames(auxop)
	op = struct
	for i = 1:size(auxop,1)
		name = opnames{i}
		if ischar(auxop(name))
			op(name) = cast(auxop(name),'cell')
		else 
			op(name) = auxop(name)
		end
	end
	
	% prepare options depending on markerFill and markerStroke value or values
	% markerFill or markerStroke as vecotrs - gradient color scale
	if ((~ischar(o.markerStroke) && ~iscell(o.markerStroke)) || (~ischar(o.markerFill) && ~iscell(o.markerFill)))% colors of each marker defined in a vector of doubles
		if (~ischar(o.markerStroke) && ~iscell(o.markerStroke))
			minCo = min(o.markerStroke)
			maxCo = max(o.markerStroke)
		end
		if (~ischar(o.markerFill) && ~iscell(o.markerFill))
			minCo = min(o.markerFill)
			maxCo = max(o.markerFill)
		end
		o.showLegend = true
		o.legendType = 'gradient'
		for i=1:length(o.colorScale)
			color = [color '"' o.colorScale{i} '",']
		end
		data = [data '
var colorScale = d3.scaleLinear().domain([' num2str(minCo) ',' num2str(minCo+(maxCo-minCo)/3) ',' num2str(minCo+(maxCo-minCo)*2/3) ',' num2str(maxCo) ']).range([' color(1:end-1) ']);
']
	end
	
	% prepare options depending on markerSize value or values
	% bubble chart and copyData option
	if max(o.markerSize) > 0 
		o.maxRange = num2str(o.markerSize)
		o.minRange = num2str(o.markerSize)
		if isempty(o.copyData)
			op.hov = 'copyData.html("X:"+xf(d.x)+"<br>"+"Y:"+yf(d.y));'
			op.cop = '$temp.val("["+xf(d.x)+","+yf(d.y)+"]").select();'
		else
			[lines board content] = chartCopyData(o)
			data = [data content]
			op.hov = lines
			op.cop = board
		end
		if numel(o.markerSize)>1
			if max(o.markerSize) > 100
				o.maxRange = num2str(100)
			else
				o.maxRange = num2str(max(o.markerSize))
			end
			o.minRange = num2str(3)
			o.showLegend = true
			o.legendType = 'buble'
		end
	end
	
	% prepare options for add points labels
	if ~isempty(op.labels)
		lab = op.labels
		if isfield(lab,'loc'), op.labX = lab.loc(:,1)', op.labY = lab.loc(:,2)';
		elseif isfield(lab,'abs')
			op.labX = o.xAxisMax-((o.width-o.paddingRight-lab.abs(:,1))*(o.xAxisMax-o.xAxisMin)/(o.width-o.paddingLeft-o.paddingRight))
			op.labY = o.yAxisMax-((lab.abs(:,2)-o.paddingTop)*(o.yAxisMax-o.yAxisMin)/(o.height-o.paddingBottom-o.paddingTop))
			op.labX = op.labX'
			op.labY = op.labY'
		else 
			if strcmp('timeline',o.type)
				op.labX = x-0.06, op.labY = (y+op.barBase)/2;
			else
				op.labX = x, op.labY = y;
			end
		end
		op.labels = lab
	end
	
	data = [data '
var datasetX = [' dataX(1:end-1) '];
var datasetY = [' dataY(1:end-1) '];

function coordinate(x,y) { this.x = x; this.y = y; };

var ii = 0;
var dat = new Array();
for (i = 0; i < datasetY.length; i++) {
	if (ii == datasetX.length) { ii=0; }
	dat.push(new coordinate(datasetX[ii],datasetY[i]));
	ii++;
};

var sizeX = [' num2str(size(x,1)) ',' num2str(size(x,2)) '];
var sizeY = [' num2str(size(y,1)) ',' num2str(size(y,2)) '];

var op = ' struct2json(op) ';

var opnam = Object.keys(op);
for (i = 0; i < opnam.length; i++) {
	if (!isNaN(parseFloat(op[opnam[i]])) && isFinite(op[opnam[i]])) {
		var a = new Array();
		a[0] = new Array();
		a[0][0] = op[opnam[i]];
		op[opnam[i]] = a;
	}
};
']
	
	if strcmp(o.type,'heatmap')
		data = [data '
var dx = sizeX[1];
var dy = sizeX[0];

var xScale = d3.scaleLinear().domain([0, dx]).range([pl, w - pr]);
var yScale = d3.scaleLinear().domain([0, dy]).range([h - pb, pt]);	

var xAxis = d3.axis' o.xAxisPos '(xScale).ticks(dx);
var yAxis = d3.axis' o.yAxisPos '(yScale).ticks(dy);
']
	end
	
	if strcmp(o.type,'pie')
		explodeData = sprintf('%.0f,',o.explode)
		color = sprintf('"%s",',cast(o.colors,'string array'))
		data = [data '
var explode = [' explodeData(1:end-1) '];

var colorPie = d3.scaleOrdinal()
	.range([' color(1:end-1) ']);
']
	end

	if strcmp(o.type,'treemap')
		data = ['
var op = ' struct2json(op) ';		
var treeData = ' struct2json(x) ';
plottree(treeData,op);']
	end

end