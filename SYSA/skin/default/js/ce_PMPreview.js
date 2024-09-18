function showdiv(box, id, pid, sign){
	var div = document.getElementById("__proflgcdiv");
	if(!div) {
		div = document.createElement("div");
		div.id = "__proflgcdiv";
		document.body.appendChild(div);
	}
	var pos =  $(box).offset();
	div.style.cssText = "overflow:hidden;color:#000;display:block;border:1px solid #8c8cac;position:absolute;left:" + (pos.left + box.offsetWidth+15) + "px;top:"+ (pos.top) + "px;z-index:1000;background-color:#ffffdd;padding:6px;padding-right:15px;";
	ajax.regEvent("getprocitem" + (sign ? "_chance" : "" ));
	ajax.addParam("id", id);
	ajax.addParam("pord", pid);
	div.innerHTML  = "正在加载...";
	ajax.send(function( html ) {
		div.innerHTML = html;
		window.__ImgBigToSmall(200,150,0);
	});
}

function clsdiv() {
	var div = document.getElementById("__proflgcdiv");
	if(div) {
		div.style.display = "none";
	}
}

function showchancediv(box, id, chance) {
	showdiv(box, id, chance, true);
}