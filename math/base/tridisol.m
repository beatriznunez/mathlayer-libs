function x = tridisol(a,b,c,D)
  % This function implements the Thomas algorithm to provide
  % a fast solution to a linear system A*x=D
  % where A is a tridiagonal matrix that can be described by
  % the three vectors a, b and c. For more infor visit:
  % https://en.wikipedia.org/wiki/Tridiagonal_matrix_algorithm
  %
  % The original algorithm has been slightly modified so that
  % D can be either a column vector or a matrix where each
  % column a defines a different linear system for the same matrix A.

  x = zeros(size(D))
  
  % get size
  [N,~] = size(D)
  
  c(1) = c(1)/b(1)
  for i = 2:N-1
    c(i) = c(i) / (b(i) - a(i) * c(i-1))
  end

  D(1,:) = D(1,:)./b(1)
  for i = 2:N
    D(i,:) = (D(i,:) - a(i)*D(i-1,:))/(b(i) - a(i)*c(i-1))
  end
  
  x(N,:) = D(N,:)
  for i = N-1:-1:1
    x(i,:) = D(i,:) - c(i)*x(i+1,:)
  end

end