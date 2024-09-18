
	function $ID(id) {
		return document.getElementById(id);
	}
	function body_resize(){
		$ID("listbody").style.width = $ID("listbodywidthproxy").offsetWidth + "px";
		var hasscroll = ($ID("content3").offsetWidth >  $ID("listbodywidthproxy").offsetWidth);
		$ID("listbody").style.paddingBottom = (hasscroll ? "18px" : "0px")
	}
	body_resize();
