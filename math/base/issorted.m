function y = issorted(x)

	y = all(all(x(2:end) - x(1:end-1) >= 0))

end