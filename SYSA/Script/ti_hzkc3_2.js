
function test()
{
  if(!confirm('确认删除吗？')) return false;
}

function mm()
{
   var a = document.getElementsByTagName("input");
   if(a[0].checked==true){
   for (var i=0; i<a.length; i++)
      if (a[i].type == "checkbox") a[i].checked = false;
   }
   else
   {
   for (var i=0; i<a.length; i++)
      if (a[i].type == "checkbox") a[i].checked = true;
   }
}

function Myopen_px(divID){ //根据传递的参数确定显示的层
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=300;
	divID.style.top=0;
}


var	adsIF = document.createElement("input");
adsIF.type="hidden";adsIF.id="adsIF";
document.body.appendChild(adsIF);
window.adClose = function()
{
	document.getElementById("div_ckidstate").style.display = "none"
}

function selectCK(imgobj,batflg)
{
	var div = document.getElementById("div_ckidstate")
	if(!div){
		div = document.createElement("div")
		div.id = "div_ckidstate";
		div.style.cssText = "border:1px solid #000;width:200px;height:490px;position:absolute;display:none;background-color:white"
		document.body.appendChild(div)
	}
	div.style.left = event.x-200+document.body.scrollLeft;
	div.style.top = event.y+document.body.scrollTop;
	var mi=imgobj.getAttribute("mi");
	var mid=imgobj.getAttribute("mid");

	if(batflg==true)
	{
		div.innerHTML = "<iframe src='../store/storeDlg.asp' frameborder='0' scrolling='no' style='width:100%;height:100%'></iframe>"
	}
	else
	{
		var pid=document.getElementById('ord_'+mi).value;
		var uid=document.getElementById('unit'+mi).value;
		div.innerHTML = "<iframe src='../store/storeDlg.asp?pid=" + pid  + "&unit=" +  uid +"' frameborder='0' scrolling='no' style='width:100%;height:100%'></iframe>"
	}
	div.style.display = "block";
	window.currStore =
	{
		text : "" , value : "" , change : function()
		{
			var cktext = window.currStore.text;
			var ckvalue = window.currStore.value;
			imgobj.parentElement.getElementsByTagName("label")[0].innerHTML=cktext;
			document.getElementById("ck"+mi).value=ckvalue;
			//document.getElementById("ck"+mi).fireEvent("onchange");
			$("ck"+mi).trigger("change");
			showBG(0);
		}
	}
	div.style.zIndex = 10001;
	showBG(1);
	return false
}

function showBG(flg)
{
	var bg=document.getElementById("bgdiv");
	bgdiv.style.height=document.body.scrollHeight;
	bgdiv.style.display=flg?"block":"none";
}
