

function ShowSlaveStore(lkobj,pid,uid)
{
	if(!pid||!uid) return;
	var url="../store/CommonReturn.asp?act=getSlaveStore&pid="+pid+"&uid="+uid+"&stam="+Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.send(null);
  var response = xmlHttp.responseText;

	var divobj=document.getElementById("ssdiv");
	var contentobj=document.getElementById("sscontentdiv");
	contentobj.innerHTML=response;
	var divobjWidth = divobj.style.width.replace("px","");
	var x = lkobj.getBoundingClientRect().left + 25;
	var winsowWidth = document.documentElement.clientWidth;
	var y = lkobj.offsetTop;
	var obj2=lkobj;
	while(obj2=obj2.offsetParent)
	{
		y+=obj2.offsetTop;
	}
	var distance = winsowWidth - x;
	if (distance <= divobjWidth) {
	    x = x - divobjWidth
	}

	divobj.style.display="block";
	divobj.style.left=x+"px";
	divobj.style.top=y+20+"px";
}
var app={};
app.PageOpen=function(url,mWidth,mHeight,wName){
	var w=860 ,h=640;
	if(mWidth){w=mWidth;}
	if(mHeight){h=mHeight;}
	var l=(screen.availWidth-w) / 2
	var t=(screen.availHeight-h) / 2
	var opener1,opener2;
	if(wName&&wName.length>0)
	{opener2=window.open(url ,wName,"height="+h+",width="+w+",left="+l+",top="+t+",z-look=yes,status=no,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes");}
	else
	{opener1=window.open(url,"_blank","height="+h+",width="+w+",left="+l+",top="+t+",z-look=yes,status=no,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes");}
	return wName?opener2:opener1;
}

function showHelpExplan(type) {
    window.event.cancelBubble = true
    if (type == 1) {
        document.getElementById("bill_help_expaln_text").style.display = "block";
    } else { document.getElementById("bill_help_expaln_text1").style.display = "block"; }
}
function closediv(type) {

    window.event.cancelBubble = true
    if (type == 1) {
        document.getElementById("bill_help_expaln_text").style.display = "none";
    } else { document.getElementById("bill_help_expaln_text1").style.display = "none"; }
}