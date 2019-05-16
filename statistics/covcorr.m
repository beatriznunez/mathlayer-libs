function X = covcorr(C, sigma)
	
	if nargin < 2
		error('two input arguments are expected')
	end
	if size(C,1) ~= length(sigma)
		error('dimensions mismatch')
	end
	
	% C must be a square, symmetric, diagonal elements equal to 1,
	% off diagonal elements must be in [-1,1],  positive semidefinite
	[rows cols] = size(C)
	if rows ~= cols
		error('matrix not square')
	end
	tol = 10*eps(max(abs(diag(corrX))))
	if ~all(all(abs(C - C') < tol))
		error('matrix not symmetric')
	elseif ~isequal(diag(C), ones(size(C,1),1))
		error('elements in the diagonal of the input matrix must be 1')	
	elseif any(any(C < -1 | C > 1))
		error('input matrix is not a correlation matrix')
	else
		try
			chol(C)
		catch e
			if any(eig(C)<0)
				error('matrix not semi-definite positive')
			end
		end
	end
	
	%force to be column vector
	sigma = sigma(:)

	% calculate the covariance matrix.
	X = C .* (sigma * sigma')

end