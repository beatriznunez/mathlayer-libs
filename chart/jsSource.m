function js = jsSource(web)

	path2chart = [ 'file:///' strrep(path('lib','chart'),'\','/')]	
	
	if web
		js = ['
		<script type="text/javascript" src="http://mathlayer.com/js/d3temp.min.js"></script>
		<script type="text/javascript" src="http://mathlayer.com/js/jquerytemp.min.js"></script>
		<script type="text/javascript" src="http://mathlayer.com/js3dFun.js"></script>
		<script type="text/javascript" src="http://mathlayer.com/js/jsfun/treeplot.js"></script>
']
	else
		js = ['
		<script type="text/javascript" src="' path2chart 'd3/d3.min.js"></script>
		<script type="text/javascript" src="' path2chart 'jquery/jquery.min.js"></script>
		<script type="text/javascript" src="' path2chart 'js3dFun.js"></script>
		<script type="text/javascript" src="' path2chart 'jsfun/treeplot.js"></script>
']
	end

end