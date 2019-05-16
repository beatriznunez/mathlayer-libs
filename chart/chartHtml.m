function html = chartHtml(options, css, js, isCombine, web)

	if nargin < 5, web = false; end

	head = ['
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>' options.pageTitle '</title>' jsSource(web) '<style type="text/css">' css '</style>
	</head>
	<body>
	<div id="report">
']

	animPaused = 'true'
	if strcmp(options.type,'animate'), animPaused = options.animPaused; end
	head = [head '
		<script type="text/javascript">var animPaused=' animPaused ';
		var gyaw=' num2str(options.yaw) ';
		var gpitch=' num2str(options.pitch) ';</script>']
		
	foot = 	['
	</div>
	</body>
</html>']
	if ~isCombine | options.overlay
		html = [head '<div id="container">
		<div id="' options.tag '" style="max-width:' options.gw ';"></div>
		</div><script type="text/javascript">' js '</script>' foot]
	else % call is from chartCombine without overlay
%		[navbarbeg navbarend animscript] = chartAnimate(options)
%		html = [head navbarbeg '<div id="container">' js '</div>' navbarend animscript foot]
		html = [head '<div id="container" style="max-width:' options.gw ';">' js '</div>' foot]
	end
end