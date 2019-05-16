function [C,sigma] = corrcov(X)
	
	% converts covariance matrix(X) to correlation matrix(C)
	% X must be a square, symmetric, positive semidefinite matrix.
	[rows cols] = size(X)
	if rows ~= cols
		error('matrix not square')
	end
	tol = 10*eps(max(abs(diag(X))))
	if ~all(all(abs(X - X') < tol))
		tol = 10*eps(max(abs(diag(X))))
		error('matrix not symmetric')
	else
		try
			[~,d] = ldl(X)
		catch e
			error('matrix not semi-definite positive')
		end
		
		if any(any(d<0))			
			error('matrix not semi-definite positive')
		end
		
	end
  
	sigma = sqrt(diag(X))
	% inverted vols
	sigmainv = 1 ./ sigma

	% calculate the correlation matrix
	C = sigmainv' .* X .* sigmainv
  
end