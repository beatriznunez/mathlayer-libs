function yy = ppval(x,y,xq,s,rowsy,endslopes)

	N = numel(x)
  
	changedxq = false
	if iscolumn(xq)
		xq = xq(:)'
		changedxq = true
	end
	
	[rxq cxq] = size(xq)
	
	xqmatrix = false	
	if rxq > 1 & cxq > 1
		xq = xq(:)
		xqmatrix = true
	end
				  
	multi = false
	[ry cy] = size(y)
	if ry > 1 & rxq > 1
		multi = true
	end
  
	if ( size(s,2) == 2 | size(s,2) == 3 ) & isempty(endslopes)	
	
		if xqmatrix
			xq = xq'
			xq = xq(:)'
		end
	
		xq = repmat(xq,rowsy,1)
		
		if size(s,2) == 2 
			yy = s(:,1).*xq + s(:,2) 
		elseif size(s,2) == 3
			yy = xq.*( s(:,1).*xq + s(:,2) ) + s(:,3)
		end
		
		% reshape the output
		if multi
			yy = reshape(yy,rowsy,rxq,cxq)
		elseif xqmatrix
			yy = reshape(yy,rxq,cxq)
		elseif changedxq & ry == 1
			yy = yy'
		end
    
	else 
  
		i = ones(size(xq))
		for j = 2:N-1
			i(x(j) <= xq) = j
		end
		
		if xqmatrix
			i = i'
			i = i(:)'
		end
	
		if rowsy > 1
			i = repmat(i,rowsy,1)
			i = i + linspace(0,(N-1)*(rowsy-1),rowsy)'
			i = i'
			i = i(:)'
		end
	
		if xqmatrix
			xq = xq'
			xq = xq(:)'
		end
	
		xq = repmat(xq,1,rowsy)
		x = repmat(x(1:N-1),1,rowsy)  

		u = (xq - x(i))
   
		yy = s(i,4)' + u .* ( s(i,3)' + u .* ( s(i,2)' + u .* s(i,1)' ) )  
	
		if multi 
	
			temp = reshape(yy,rxq,rowsy*cxq)'
		
			yy = zeros(rowsy,rxq,cxq)
		
			% reshape the output
			i = 1
			for j = 1:rowsy
				for k = 1:cxq
					yy(j,:,k) = temp(i,:)
					i = i+1
				end 
			end
		
		else
	
			% reshape the output
			if xqmatrix
				yy = reshape(yy,rxq,cxq)
			else	
				yy = reshape(yy,cxq,rowsy)'			
			end				
			if ~isempty(endslopes) & changedxq & ry == 1
				yy = yy'
			end
		
		end   
    
end