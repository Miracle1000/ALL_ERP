var tempdiv =$ID("dhtml");
//function hidelabel(){tempdiv.style.display='none';}
function xmldata(ord , obj , serviceProc)
{
	if(!tempdiv) {
		tempdiv = document.createElement("div");
		tempdiv.id =  "dhtml";
		tempdiv.style.cssText="position: absolute; display:none;width: 500px;border: 0px;padding: 1px;z-index: 100;";
		document.body.appendChild(tempdiv);
	}
	ajax.regEvent(serviceProc)
	ajax.addParam("ord", ord);
	var r = ajax.send();
	updatepage(r,obj);
}

function updatepage(r,obj)
{
    tempdiv.innerHTML = r;
    $(tempdiv).children("table#content").css("border-top", "1px solid #c0ccdd")//弹框样式受css影响，上边框消失，在此加上上边框；财务-费用管理-使用明细页；
	var position = GetObjectPos(obj);
	tempdiv.style.top=position.top+"px";
	tempdiv.style.left=(position.left-500)+"px";
	tempdiv.style.display='';
}

window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!="")
	{
		$("#searchitemsbutton2").click();
	}
}