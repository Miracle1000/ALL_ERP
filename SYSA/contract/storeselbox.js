//2012.10.16.tan 明细编辑页仓库选择对话框通用函数。
function showStoreDlg(txtid, productid, unit)
{
	var div = document.getElementById("div_ckidstate")
	if(!div){
		div = document.createElement("div")
		div.id = "div_ckidstate";
		div.style.cssText = "border:1px solid #000;width:200px;height:490px;position:absolute;display:none;background-color:white;z-index:100000"
		document.body.appendChild(div)
	}
	div.style.left = event.x-200+document.body.scrollLeft;
	div.style.top = event.y+document.body.scrollTop;
	if(!productid)
	{
		div.innerHTML = "<iframe src='../store/StoreDlg.asp' frameborder='0' scrolling='no' style='width:100%;height:100%'></iframe>"
	}
	else
	{
		div.innerHTML = "<iframe src='../store/StoreDlg.asp?pid=" + productid  + "&unit=" +  unit +"' frameborder='0' scrolling='no' style='width:100%;height:100%'></iframe>"
	}
	div.style.display = "block";
	showBG(1);
	window.currStore = {
		text : "" ,
		value : "",
		eventid : txtid,
		change : function(){
			document.getElementById("div_ckidstate").style.display = "none";
			document.getElementById("bgdiv").style.display = "none";
			var obj = document.getElementById(this.eventid);
			if(!obj){alert("仓库选择：ID为" + this.eventid + "的对象不存在。"); return ;}
			if(document.getElementById("for_" + this.eventid)){
				document.getElementById("for_" + this.eventid).style.cssText="width:80px;height:20px;overflow:hidden;float:left;white-space:nowrap;text-overflow:ellipsis;";
				document.getElementById("for_" + this.eventid).title = this.text;
				//document.getElementById("for_" + this.eventid).innerText = this.text;
				$(document.getElementById("for_" + this.eventid)).val(this.text);
			}
			
			obj.value = this.value;
			obj.setAttribute("text",this.text);
			if(obj.onchange) {
				$(obj).trigger("change");
			}
		}
	}
	return false
}

function showBG(flg)
{
	var bgdiv=document.getElementById("bgdiv");
	if(!bgdiv) {
		bgdiv = document.createElement("div");
		bgdiv.id = "bgdiv";
		bgdiv.style.cssText = "display:none;position:absolute;top:0%;left:0%;width:100%;height:100%;background-color:#B9C5DD;z-index:10000;filter:alpha(opacity=50);-moz-opacity:0.7;opacity:.70"
		document.body.appendChild(bgdiv);
	}
	bgdiv.style.height=document.body.scrollHeight;
	bgdiv.style.display=flg?"block":"none";
}

window.adClose = function()
{
	document.getElementById("div_ckidstate").style.display = "none";
	showBG(0);
}