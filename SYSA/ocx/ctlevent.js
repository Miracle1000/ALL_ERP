window.status = "loadok"
function frmresize(){
	try {
		var bodysign = document.getElementById("bodysigndiv");
	var div1 = document.getElementById("Page1")
	var div2 = document.getElementById("Page2")
	var div3 = document.getElementById("Page3")
	div1.style.height = (document.body.offsetHeight - 40) + "px";
	div1.style.width = (bodysign.offsetWidth - 10) + "px";
	div2.style.height = (document.body.offsetHeight - 40) + "px";
	div2.style.width = (bodysign.offsetWidth - 10) + "px";
	div3.style.height = (document.body.offsetHeight-72) + "px"
	}catch(e){}
}
tabs.ItemClick = function(i){
	var t = i*1 + 1
	document.getElementById("Page" + t).style.display = "block";
	document.getElementById("Page" + (t==1 ? 2 : 1)).style.display = "none";
	return true;
}

function InitUI(){

}


function SelectFilePlay(){
	var url = player.OpenFileDialog();
	if(url.length>0){player.url = url;document.getElementById("lctext").value = url;}
}

var currRow =  null

function PlayId(id,isNet){
	var t = new Date()
	var url = "http://" + window.location.host + window.location.pathname + "?__msgId=OpenWavFile&id=" + id + "&__currUserId=1&t=" + t.getTime();
	player.url = url
	var tr = window.event.srcElement.parentElement.parentElement;
	if(currRow){
		currRow.style.cssText = ""
	}	
	tr.style.cssText = "background-color:#ff0000;color:white"
	currRow = tr;
}

function clist(){
	ajax.regEvent("clist");
	ajax.addParam("uid",document.getElementById("userid").value);
	ajax.addParam("__currUserID",document.getElementById("userid").value);
	ajax.addParam("jsType",document.getElementById("s1").checked*1);
	ajax.addParam("key",document.getElementById("keytext").value);
	ajax.addParam("t1",document.getElementById("t1").value);
	ajax.addParam("t2",document.getElementById("t2").value);
	ajax.send(clistdata);
}
function clistdata(v){
	document.getElementById("Page3").innerHTML  = v
}
