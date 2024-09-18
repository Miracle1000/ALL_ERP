window.onReportRefresh=function(){
	try{$("#searchitemsbutton2").click();}catch (e){}
}

function alert_jg(id,ord,event) {
	var id  = "intro_msg";
	var w=document.getElementById(id);
	if(!w){w=document.createElement("DIV");document.body.appendChild(w);w.id=id;}
	var scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
	w.style.cssText = "position:absolute;left:" + event.clientX + "px;top:" + (event.clientY*1+scrollTop*1)+ "px;z-index:1000000;display:block;"
	ajax.regEvent("content_list")
	ajax.addParam('id', id);
	ajax.addParam('ord', ord);
	ajax.send(function(r){ w.innerHTML = r;});
}

function alert_jgclose(id,ord) {
	var id  = "intro_msg";
	var w=document.getElementById(id);
	w.style.cssText = "display:none";
	w.innerHTML="";
}