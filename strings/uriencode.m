function str = uriencode(str)

	% uriencode encodes a Uniform Resource Identifier (URI) code 
	%%%%%%%%%%%%%%%%%%%%%%
	% inputs:
	% str: string to encode
	%%%%%%%%%%%%%%%%%%%%%%
	% outputs:
	% str: encoded string
	%%%%%%%%%%%%%%%%%%%%%%
	% e.g.:
    % str = uriencode('x = 1#')
    % urlread(['localhost:50000/', str])#

    str = strrep(str, '%', '%25')
	str = strrep(str, ' ', '%20')
	str = strrep(str, '""', '%22')
	str = strrep(str, '#', '%23')
	str = strrep(str, '$', '%24')
end