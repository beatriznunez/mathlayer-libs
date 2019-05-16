function out = table2html(t,options)
	
	if nargin == 0, error('not enough input arguments'), end
	if strcmp(class(t), 'table') == 0, error('input must be a table'), end
	if nargin < 2, options = struct(); end
	
	o = chartOptions(options)
	out.type = 'table'
	out.subtype = 'table'
	variablenames = t.variablenames	
	if ~isfield(o,'tableid'), o.tableid = ''; end
	
	html = ['
<div style="width:' num2str(o.width) 'px">
	<table id="' o.tableid '" style="' o.styleTable '">']
	
	% add rownames
	if o.tableRN
		rownames = table(t.rownames)
		t = [rownames t]
		variablenames = t.variablenames
		variablenames(1) = {''}
	end
	
	[nr nc] = size(t)
	
	% add variablenames
	if o.tableVN
		html = [html,'
		<thead>
			<tr style="' o.styleTabletr '">']
		for i = 1: nc % read by rows
			html = [html, '
				<th align="' o.tdAlign '" style="' o.styleTableth '">' , char(variablenames{i}), '</th>'] 
		end
		html = [html,'
			</tr>
		</thead>']
	end
	
	% convert double into strings
	aux = find(strcmp(t.variabletypes, 'double'))
	n = numel(aux)
	for i=1:n
		j = aux(i)
		t(:,j) = num2str(t{:,j})
	end

	c = cell(nr,1)
	td = ['
				<td align="' o.tdAlign '" style="' o.styleTabletd '">']
	tr = ['
			<tr style="' o.styleTabletr '">']
	h2 = cell(nc,1)
	for i = 1: nr % read by rows
		h2 = t{i,:}
		if nc == 1, h2 = sprintf([td '%s</td>'], h2)
		else, h2 = sprintf([td '%s</td>'], h2{:}); end
		c{i} = [tr, h2, '
			</tr>']
	end

	html = [html,'
		<tbody>',[c{:}],'
		</tbody>
	</table>
</div>']
			
	out.jsFrame = ''
	out.jsData = ''
	out.dataSet = ''
	out.legend = ''
	out.image = ''
	out.options = o
	out.divTag = html
	out.css = html
	
	if o.save 
		filePath = [o.folder '\' o.name '.html']	
		fid = fopen(filePath,'w+')
		fprintf(fid,'%s',html)
		fclose(fid)
	end
	if o.show 
		sh(filePath)
	end

end