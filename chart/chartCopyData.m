function [lines board jsData] = chartCopyData(options)

	for k = 1:size(options.copyData,1)
		difcases = [difcases;(~isempty(options.copyData(k))+size(regexp(options.copyData(k), '\n'),2))]	
	end
	[~,b,~] = unique(difcases)
	for k = 1:size(options.copyData,1)
		if ~ismember((~isempty(options.copyData(k))+size(regexp(options.copyData(k), '\n'),2)),difcase)
			if k == 1
				lines = [lines 'if']
				board = [board 'if']
			elseif k == max(b)
				lines = [lines 'else']
				board = [board 'else']
			else
				lines = [lines 'else if']
				board = [board 'else if']
			end
		end
		if isempty(options.copyData(k))
			tmp = sprintf('%f,',options.copyData(k,1))
			copy = [copy '['  tmp(1:end-1) '],']
			if ~ismember(0,difcase)
				if  k < max(b) || numel(unique(difcases)) == 1
					lines = [lines '  (content[i].length==0)']
					board = [board '  (content[i].length==0)']
				end
				lines = [lines '{copyData.html("X:"+xf(d.x)+"<br>"+"Y:"+yf(d.y));}']	
				board = [board '{$temp.val("["+xf(d.x)+","+yf(d.y)+"]").select();}']	
			end
			difcase = [difcase;0]
		elseif ~isempty(regexp(options.copyData(k), '\n')) 
			tmp = sprintf('%f,',options.copyData(k,1))
			a = regexp(options.copyData(k), '\n')
			copy = [copy '["' tmp(1:a(1)-2) '",']
			if ~ismember(size(regexp(options.copyData(k), '\n'),2)+1,difcase)
				clipboard = ['content[i][0]+']
				display = ['content[i][0]+']
			end
			for n = 1:size(a,2)-1
				if ~ismember(size(regexp(options.copyData(k), '\n'),2)+1,difcase)
					clipboard = [clipboard '"\\n"+content[i][' num2str(n) ']+']
					display = [display '"<br>"+content[i][' num2str(n) ']+']
				end
				copy = [copy '"' tmp(a(n)+1:a(n+1)-2) '",']
			end
			if ~ismember(size(regexp(options.copyData(k), '\n'),2)+1,difcase)
				clipboard = [clipboard '"\\n"+content[i][' num2str(size(a,2)) ']']
				display = [display '"<br>"+content[i][' num2str(size(a,2)) ']']
			end
			if ~ismember(size(a,2),numlines)
				if  k < max(b) || numel(unique(difcases)) == 1
					lines = [lines '  (content[i].length == ' num2str(size(a,2)+1) ')']
					board = [board '  (content[i].length == ' num2str(size(a,2)+1) ')']
				end
				lines = [lines ' {copyData.html(' display ');}']
				board = [board ' {$temp.val(' clipboard ').select();}']
			end
			board = [board ]
			copy = [copy '"' tmp(a(size(a,2))+1:end-1) '"],']
			numlines = [numlines;size(a,2)]
			difcase = [difcase;(size(regexp(options.copyData(k), '\n'),2)+1)]
		else
			tmp = sprintf('%f,',options.copyData(k,1))
			copy = [copy '["'  tmp(1:end-1) '"],']
			if ~ismember(1,difcase)
				if  k < max(b) || numel(unique(difcases)) == 1
					lines = [lines '  (content[i].length==1)']
					board = [board '  (content[i].length==1)']
				end
				lines = [lines '  {copyData.html(content[i]);}']
				board = [board '  {$temp.val(content[i]).select();}']
			end
			difcase = [difcase;1]
		end
	end
	jsData = ['var content = [' copy(1:end-1) '];']
end