function SetLogo(tag,url){
	var img = document.getElementById(tag);
	img.src = url
}
function setimgValue(box) {
	var v = box.value;
	var vbox = $ID("codelogo_0");
	v = v.toLowerCase();
	var id = v.replace("../sdk/bill.upload.asp?v", "");
	if (v.indexOf("http:")==-1 && id==(vbox.getAttribute("rsaid") + "").toLowerCase()){return; }
	vbox.value =  v;
	vbox.setAttribute("rsaid","");
}