function str = strnormalize(str)
	str = strrep(str, '�', 'a')
	str = strrep(str, '�', 'A')
	str = strrep(str, '�', 'e')
	str = strrep(str, '�', 'E')
	str = strrep(str, '�', 'i')
	str = strrep(str, '�', 'I')
	str = strrep(str, '�', 'o')
	str = strrep(str, '�', 'O')
	str = strrep(str, '�', 'u')
	str = strrep(str, '�', 'U')
	str = strrep(str, '�', 'n')
end