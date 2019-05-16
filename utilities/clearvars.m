function [] = clearvars(str,varargin)

	if nargin == 0
		clear
	elseif ~strcmp(str, '-except')
		error('for the moment, only except flag is supported')
	end
	vars = whos('names', 'caller')
	vars = cast(vars,'cell')
	vars{end+1} = 'vars'
	vars = vars(~ismember(vars,varargin))
	clearin('caller', vars)
	
end