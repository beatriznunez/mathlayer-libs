function [navbar navbarid script closeanim] = chartAnimate(options)

	script = ''
	navbar = ''
	navbarid = ''
	closeanim = ''
	strglobalyp = '' % global yaw pitch string
	tag = ['a' options.tag]
	
	if strcmp(options.type, 'animate')
		
		if isfield(options,'tags'), strglobalyp = sprintf('%s.turntable(gyaw,gpitch);',cast(options.tags,'string array')); end
	
		if options.navbar
			w = ['max-width:' num2str(options.width,0) 'px']
			h = ['max-height:' num2str(options.height,0) 'px']
			wg = num2str(options.navbarWidth)
			
			if isfield(options,'nameFrame')
				navbar = ['
	<div id="navbar_' tag '" style="max-width:' wg 'px">
		<div id="buttons" style="margin: 0 auto; ">
			<input id="input_id" style="background-color:#d9d9d9;" type="text" list="frames" onblur="opt()">
				<datalist id="frames">']
				names = options.nameFrame
				no = numel(names)
				for i = 1:no
					navbar = [navbar '
					<option id="' num2str(i) '" value="' names{i} '"></option>']
				end
				navbar = [navbar '
				</datalist>']
			else
					navbar = ['
	<div id="navbar_' tag '" style="max-width:' wg 'px">
		<div id="progress_bar_' tag '" style="background-color:#d9d9d9; height:10px; max-width:' wg 'px; border: 1px solid black; margin-bottom: 10px;">
			<div id="progress_' tag '" style="background-color:#8c8c8c; height:10px; max-width:' wg 'px;"></div>
		</div>
		<div id="buttons" style="width:350px; margin: 0 auto; ">']
			end
			navbar = [navbar '
			<button id="start_' tag '" onclick="start_' tag '();">&#10073&#10094;</button>
			<button id="fastbackward_' tag '" onclick="fastbackward_' tag '();">&#10094&#10094;</button>
			<button id="backward_' tag '"  onclick="backward_' tag '();">&#10094;</button>
			<button style="height:22.5px;" id="playpause_' tag '" onclick="playpause_' tag '();">&#10073&#10073;</button>
			<button id="forward_' tag '" onclick="forward_' tag '();">&#10095;</button>  
			<button id="fastforward_' tag '" onclick="fastforward_' tag '();">&#10095&#10095;</button>
			<button id="end_' tag '" onclick="end_' tag '();">&#10095&#10073;</button>
			<input id="input_' tag '" type="text" onfocus="input_' tag '()" style="width:29px; height:17px; background-color:#d9d9d9;"/>
			<button id="total_' tag '" style="background-color:#d9d9d9; width:41px;border: 0.5px solid #b3b3b3; font-family: Open Sans, Verdana, Trebuchet MS, Lucida Sans Unicode, Arial, sans-serif;font-size:12px; padding-top:3px; "></button>
		</div>']
			if isfield(options,'nameFrame')
			navbar = [navbar '
		<div id="progress_bar_' tag '" style="background-color:#d9d9d9; height:10px; width:' wg 'px; border: 1px solid black; margin-bottom: 10px;">
			<div id="progress_' tag '" style="background-color:#8c8c8c; height:10px; max-width:' wg 'px;"></div>
		</div>
	</div>']
			else
			navbar = [navbar '
	</div>']
			end
		navbarid = ['
	<div style="' w '; ' h '">
	<div id="' tag '" style="' w '">
	']
			closeanim = '	</div></div>'
		end
	
		script = ['
<script>
var paused_' tag ' = false;
var divs_' tag '=$("#' tag '").children("div");
var fast_' tag ' = ' num2str(options.timelapse) ';
var rewind_' tag ' = false;
var number_' tag ' = 1;
var total_' tag ' = divs_' tag '.length; 
var rsizwid_' tag ' = ' wg ';
var width_' tag ' = number_' tag '*rsizwid_' tag '/(total_' tag '-1);
var timeDrag_' tag ' = false;
var objs_' tag '=[];
var objs2_' tag '=[];

divs_' tag '.each(function(e) {
	if (e != 0)
	$(this).hide();
});

interval_' tag ' = setInterval(Divs_' tag ', fast_' tag ');

if (animPaused === true) {
	var paused_' tag ' = true;
	$("#playpause_' tag '").html("&#9658");
	clearInterval(interval_' tag ');
};

$("#input_' tag '").val(number_' tag ');

$("#total_' tag '").html("&nbsp;/" + total_' tag ');

$("#progress_' tag '").width(0);

$( window ).resize(function() {resizebar_' tag '()});
$( window ).load(resizebar_' tag '());

function resizebar_' tag '() {
	rsizwid_' tag ' = $("#progress_bar_' tag '").width();
	console.log(rsizwid_' tag ')
	$("#progress_' tag '").width(rsizwid_' tag '*($("#input_' tag '").val()-1)/(total_' tag '-1));
}

for (var e = 0; e < total_' tag '; e++) {
	width_' tag ' = (e)*rsizwid_' tag '/total_' tag ';
	var divs_widths = {
		"div": divs_' tag '[e],
		"width_' tag '": width_' tag '
	}
	objs_' tag '.push(divs_widths);
}

$("#progress_bar_' tag '").mousedown(function(e) {
    timeDrag_' tag ' = true;
	$("#playpause_' tag '").html("&#9658");
	clearInterval(interval_' tag ');
	paused_' tag ' = true;
});

$(document).mouseup(function(e) {
    if(timeDrag_' tag ') {
        timeDrag_' tag ' = false;
        updatebar_' tag '(e.pageX);
    }
});

$(document).mousemove(function(e) {
    if(timeDrag_' tag ') {
        updatebar_' tag '(e.pageX);
    }
});

var updatebar_' tag ' = function(x) {
    var progress = $("#progress_bar_' tag '");
    width_' tag ' = x - progress.offset().left;

    $("#progress_' tag '").width(width_' tag '+"px");
    
	for (var e = 0; e < total_' tag '; e++) {
		if (objs_' tag '[e].width_' tag ' <= width_' tag '){
			objs2_' tag '.push(objs_' tag '[e]);
		}
	}
	now = divs_' tag '.filter(":visible");
	next = divs_' tag '.filter(objs2_' tag '[objs2_' tag '.length-1].div);
	number_' tag ' = objs2_' tag '.length;
	now.hide();
	next.show();
	$("#input_' tag '").val(number_' tag ');
	objs2_' tag '=[];
};

function updateYawPitch_' tag '(){
	' strglobalyp '
}

function input_' tag '(x) {
    $("#playpause_' tag '").html("&#9658");
	paused_' tag ' = true;	
	clearInterval(interval_' tag ');
	$("#input_' tag '").val('' '');
}

(function($) {
    $.fn.onEnter = function(func) {
        this.bind("keypress", function(e) {
            if (e.keyCode == 13) func.apply(this, [e]);    
        });               
        return this; 
     };
})(jQuery);
']
		if isfield(options,'nameFrame')
			nameFrames = sprintf('"%s",',cast(options.nameFrame,'string array'))
			script = [script '
var list = [' nameFrames(1:end-1) ']

function opt(){
	$("#input_id").val("select frame");
}

$("#input_id").val("select frame");

$("#input_id").on("click", function () {
	$(this).val("");
	paused_' tag ' = true;	
	clearInterval(interval_' tag ');
});

$("#input_id").on("input", function () {
    var val = this.value;
    var endval = $(''option[value="''+$(this).val()+''"]'').attr("id");
    if($("#frames option").filter(function(){
        return this.value === val;        
    }).length) {
		var input_' tag ' = endval;
        newFrame(input_' tag ')
		$("#input_' tag '").val(number_' tag ');
		$(this).val(list[number_' tag '-1]);
    }
});
']
		end
		script = [script '
$( function () {
    $("#input_' tag '").onEnter( function() {
		var input_' tag ' = $( "#input_' tag '" ).val();
		newFrame(input_' tag ')
		$("#input_' tag '").val(number_' tag ');
		$(this).select();
    });
}); 

function newFrame(x) {
	if (x <= total_' tag ' && x > 0){
		number_' tag ' = x;
		width_' tag ' = ((number_' tag '-1)*rsizwid_' tag ')/(total_' tag '-1);
		$("#input_' tag '").val(number_' tag ');
		$("#playpause_' tag '").html("&#9658");
		$("#progress_' tag '").width(width_' tag ' + "px");
		paused_' tag ' = true;	
		clearInterval(interval_' tag ');
		for (var e = 0; e < total_' tag '; e++) {
			if (objs_' tag '[e].width_' tag ' <= width_' tag '){
				objs2_' tag '.push(objs_' tag '[e]);
			}
		}
		now = divs_' tag '.filter(":visible");
		next = divs_' tag '.filter(objs2_' tag '[objs2_' tag '.length-1].div);
		now.hide();
		next.show();
		objs2_' tag '=[];
	}
};

function Divs_' tag '() {
	if(!paused_' tag ') {
		now = divs_' tag '.filter(":visible");
		if (rewind_' tag ') {
			if(now.prev("div").length) {
				number_' tag '--;
				$("#input_' tag '").val(number_' tag ');
				width_' tag ' = ((number_' tag '-1)*rsizwid_' tag ')/(total_' tag '-1);
				$("#progress_' tag '").width(width_' tag ' + "px");
				next = now.prev();
				now.hide();
				next.show();
			}
			else {
				clearInterval(interval_' tag ');
				$("#playpause_' tag '").html("&#9658");
				paused_' tag ' = true;
				rewind_' tag ' = false;
			}
		}
		else {
			if(now.next("div").length) {
				number_' tag '++;
				width_' tag ' = ((number_' tag '-1)*rsizwid_' tag ')/(total_' tag '-1);
				$("#input_' tag '").val(number_' tag ');
				$("#progress_' tag '").width(width_' tag ' + "px");
				next = now.next();
				now.hide();
				next.show();
			}
			else {
				clearInterval(interval_' tag ');
				$("#playpause_' tag '").html("&#9658");
				paused_' tag ' = true;
			};
		}
	}
};

function playpause_' tag '() {
now = divs_' tag '.filter(":visible");
rewind_' tag ' = false;
	if(paused_' tag ') {
		updateYawPitch_' tag '();
		if(objs2_' tag '.length){
			number_' tag ' = objs2_' tag '.length;
		}
		$("#playpause_' tag '").html(" &#10073&#10073");
		fast_' tag ' = ' num2str(options.timelapse) ';
		interval_' tag ' = setInterval(Divs_' tag ', fast_' tag ');
		paused_' tag ' = false;
		if(!now.next("div").length) {
			now = divs_' tag '.filter(":visible");
			next = divs_' tag '.filter(":first");
			now.hide();
			next.show();
			number_' tag ' = 1;
			$("#input_' tag '").val(number_' tag ');
			$("#progress_' tag '").width(0);
		}
	}
	else {
		$("#playpause_' tag '").html("&#9658");
		clearInterval(interval_' tag ');
		paused_' tag ' = true;
	}
};

$("body").keydown(function(e) {
  if(e.keyCode == 37) { // left
    backward_' tag '()
  }
  else if(e.keyCode == 39) { // right
    forward_' tag '()
  }
});

function forward_' tag '() {
	updateYawPitch_' tag '();
	$("#playpause_' tag '").html("&#9658");
	number_' tag '++;
	if (number_' tag ' > total_' tag ') {
		number_' tag ' = 1;
	}
	$("#input_' tag '").val(number_' tag ');
	width_' tag ' = ((number_' tag '-1)*rsizwid_' tag ')/(total_' tag '-1);
	$("#progress_' tag '").width(width_' tag ' + "px");
	clearInterval(interval_' tag ');
	paused_' tag ' = true;
	now = divs_' tag '.filter(":visible");
	next = now.next("div").length ? now.next() : divs_' tag '.first();
	now.hide();
	next.show();
};

function backward_' tag '() {
	updateYawPitch_' tag '();
	$("#playpause_' tag '").html("&#9658");
	number_' tag '--;
	if (number_' tag ' < 1) {
		number_' tag ' = total_' tag ';
	}
	$("#input_' tag '").val(number_' tag ');
	width_' tag ' = ((number_' tag '-1)*rsizwid_' tag ')/(total_' tag '-1);
	$("#progress_' tag '").width(width_' tag ' + "px");
	clearInterval(interval_' tag ');
	paused_' tag ' = true;
	now = divs_' tag '.filter(":visible");
	prev = now.prev("div").length ? now.prev() : divs_' tag '.last();
	now.hide();
	prev.show();
};

function end_' tag '(){
	updateYawPitch_' tag '();
	$("#playpause_' tag '").html("&#9658");
	number_' tag ' = total_' tag ';
	$("#input_' tag '").val(number_' tag ');
	width_' tag ' = ((number_' tag '-1)*rsizwid_' tag ')/(total_' tag '-1);
	$("#progress_' tag '").width(width_' tag ' + "px");
	clearInterval(interval_' tag ');
	paused_' tag ' = true;
	now = divs_' tag '.filter(":visible");
	next = divs_' tag '.filter(":last");
	now.hide();
	next.show();
};

function start_' tag '(){
	updateYawPitch_' tag '();
	$("#playpause_' tag '").html("&#9658");
	number_' tag ' = 1;
	$("#input_' tag '").val(number_' tag ');
	width_' tag ' = ((number_' tag '-1)*rsizwid_' tag ')/(total_' tag '-1);
	$("#progress_' tag '").width(0);
	clearInterval(interval_' tag ');
	paused_' tag ' = true;
	fast_' tag ' = ' num2str(options.timelapse) ';
	now = divs_' tag '.filter(":visible");
	next = divs_' tag '.filter(":first");
	now.hide();
	next.show();
};

function fastbackward_' tag '() {
	updateYawPitch_' tag '();
	clearInterval(interval_' tag ');
	if(!paused_' tag '){
		rewind_' tag ' = true;
		fast_' tag ' = fast_' tag '/2;
		if (fast_' tag ' < 40) {
			fast_' tag ' = 40;
		};
		interval_' tag ' = setInterval(Divs_' tag ', fast_' tag ');	
	};
};

function fastforward_' tag '() {
	updateYawPitch_' tag '();
	clearInterval(interval_' tag ');
	if(!paused_' tag '){
		fast_' tag ' = fast_' tag '/2;
		if (fast_' tag ' < 40) {
			fast_' tag ' = 40;
		};
		interval_' tag ' = setInterval(Divs_' tag ', fast_' tag ');	
	};
};

</script>']
	end
	
end