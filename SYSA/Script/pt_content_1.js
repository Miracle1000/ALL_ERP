
function changeForm(sindex)
{
	if(sindex==1)
	{//ROP
		document.getElementById("MRPSetupPanel").style.display="block";
		objLock("M_MRPTitle",false,'1','50');//批量规则
		objLock("M_NumRequest",false,'1','');//日需求量
		objLock("M_DayProvide",false,'1','');//保证供应天数
		objLock("M_ReorderPoint",false,'1','');//订货点数量
		objLock("M_TimeInAdvance",false,'1','');//提前期
		objLock("M_BatchRules",true,'1','');//批量规则
		objLock("M_BatNum",true,'1','');//固定批量
		objLock("M_SaveNum",true,'1','');//安全库存量
		objLock("M_AttritionRate",false,'0.00','99.99');//产品损耗率
		objLock("M_Costs",false,'1','');//单位成本
		objLock("property1",false,'1','');//产品属性
		objLock("property2",false,'1','');//产品属性
		objLock("property3",false,'1','');//产品属性
		objLock("property4",false,'1','');//产品属性
		objLock("property5",false,'1','');//产品属性
	}
	else if(sindex==0)
	{//MRP
		document.getElementById("MRPSetupPanel").style.display="block";
		objLock("M_MRPTitle",false,'1','50');//批量规则
		objLock("M_BatchRules",false,'1','');//批量规则
		objLock("M_BatNum",(document.getElementById("M_BatchRules").value!='2'),'1','');//固定批量
		objLock("M_NumRequest",true,'1','');//日需求量
		objLock("M_DayProvide",true,'1','');//保证供应天数
		objLock("M_TimeInAdvance",false,'1','');//提前期
		objLock("M_SaveNum",false,'1','');//安全库存量
		objLock("M_ReorderPoint",true,'1','');//订货点数量
		objLock("M_AttritionRate",false,'0.00','99.99');//产品损耗率
		objLock("M_Costs",false,'1','');//单位成本
		objLock("property1",false,'1','');//产品属性
		objLock("property2",false,'1','');//产品属性
		objLock("property3",false,'1','');//产品属性
		objLock("property4",false,'1','');//产品属性
		objLock("property5",false,'1','');//产品属性
	}
}

function objLock(objid,locktype,minvalue,maxvalue)
{
	var obj=document.getElementById(objid);
	if(locktype)
	{
		obj.style.backgroundColor="#e0e0e0"
		obj.removeAttribute("dataType");
		obj.removeAttribute("Min");
		obj.removeAttribute("MSG");
		if(maxvalue!='') obj.removeAttribute("Max");
		obj.disabled=true;
	}
	else
	{
		obj.style.backgroundColor="#ffffff";
		if("M_MRPTitle".indexOf(objid)==0)
		{
			obj.setAttribute("dataType","Limit");
			obj.setAttribute("MSG","主题字数必须在"+minvalue+"-"+maxvalue+"之间");
			obj.setAttribute("min",minvalue);
			obj.setAttribute("max",maxvalue);
		}
		else if("property".indexOf(objid)<0)
		{
			if(maxvalue!='')
			{
				obj.setAttribute("dataType","Range");
				obj.setAttribute("max",maxvalue);
				obj.setAttribute("MSG","超出范围("+minvalue+"-"+maxvalue+")");
			}
			else
			{
				obj.setAttribute("dataType","Limit");
				obj.setAttribute("MSG","必填");
			}
			obj.setAttribute("min",minvalue);
		}
		obj.disabled=false;
	}

	if(document.getElementById("__ErrorMessagePanel")||document.getElementById("PropertyPanel"))
	{
		var tempc=obj.parentElement.parentElement.parentElement;
		var ObjArray=tempc.getElementsByTagName("span");
		for(var i=0;i<ObjArray.length;i++)
		{
			if(ObjArray[i].id&&("__ErrorMessagePanel,PropertyPanel".indexOf(ObjArray[i].id)>=0)) ObjArray[i].innerHTML="";
		}
	}
}

function MRPModify(obj,mrpid,showflg)
{
	var x=obj.offsetLeft,y=obj.offsetTop;
	var obj2=obj;
	var offsetx=25;
	while(obj2=obj2.offsetParent)
	{
		x+=obj2.offsetLeft;
		y+=obj2.offsetTop;
	}
	var showobj=document.getElementById("showhc");
	var hcdivobj=document.getElementById("hcdiv");
	hcdivobj.style.display="block";
	showobj.innerHTML="";
	hcdivobj.style.left=offsetx+x+"px";
	hcdivobj.style.top=y-5+"px";

  var url = "getMRP.asp?ord="+mrpid+"&showflg="+(showflg?"1":"")+"&stamp=" + (Math.random()*10).toString().replace(".","");
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
	  if (xmlHttp.readyState < 4)
	  {
			showobj.innerHTML="loading...";
	  }
	  if (xmlHttp.readyState == 4)
	  {
	    var response = xmlHttp.responseText;
			showobj.innerHTML=response;
			xmlHttp.abort();
	  }
  };
  xmlHttp.send(null);
  if(!showflg)
  {
  	changeForm(document.getElementById("M_Tactics").selectedIndex);
	}
	addEvent(document.body,"mousedown",clickOther)
}

function addEvent(obj,eventType,func){
	if(obj.attachEvent){obj.attachEvent("on" + eventType,func);}
	else{obj.addEventListener(eventType,func,false)}
	}
function delEvent(obj,eventType,func){
	if(obj.detachEvent){obj.detachEvent("on" + eventType,func)}
	else{obj.removeEventListener(eventType,func,false)}
	}
function clickOther(el){
	try
	{
		thisObj = el.target?el.target:event.srcElement;
		do
		{
			if(thisObj.id == "hcdiv") return;
			if(thisObj.tagName == "BODY")
			{
				hidemenu();
				return;
			};
			thisObj = thisObj.parentNode;
		}
		while(thisObj.parentNode);
	}
	catch(e1){}
}

function hidemenu(){
 var obj=document.getElementById("hcdiv");
 delEvent(document.body,"mousedown",MRPModify);
 obj.style.display='none';
}

function checkSelection()
{
	var i=1;
	var result=false;
	for(i=1;i<=7;i++)
	{
		var obj=document.getElementById("property"+i);
		if(obj.checked)
		{
			result=true;
			break;
		}
	}
	if(result)
	{
		return result;
	}
	else
	{
		document.getElementById("property1").parentElement.getElementsByTagName("span")[0].innerHTML="至少选择一个属性"
		return false;
	}
}

function MRPajaxSave()
{
	var formobj=document.getElementById("formMRP");
	if(Validator.Validate(formobj,2)&&checkSelection())
	{
		var ajaxurl="";
		var cpord = window.cpord;
		if(typeof(cpord)=="undefined"){
			alert("产品不存在，保存失败！");
			return;
		}
		if(cpord+""==""){
			alert("产品不存在，保存失败！");
			return;
		}
		for(var i=0;i<formobj.length;i++)
		{
			var objname=formobj[i].name;
			if(objname!="savebtn"&&objname!="closebtn"&&!(formobj[i].disabled)&&(formobj[i].type!='checkbox'||formobj[i].checked))
			{
				ajaxurl+=ajaxurl==""?objname+"="+formobj[i].value:"&"+objname+"="+formobj[i].value;
			}
		}
		ajaxurl="MRPajaxSave.asp?"+ajaxurl+"&ProductID="+cpord+"&stamp=" + (Math.random()*10).toString().replace(".","");
		var showobj=document.getElementById("MRPListShow");
	  xmlHttp.open("GET", ajaxurl, false);
	  xmlHttp.onreadystatechange = function(){
		  if (xmlHttp.readyState < 4)
		  {
				showobj.innerHTML="loading...";
		  }
		  if (xmlHttp.readyState == 4)
		  {
		    var response = xmlHttp.responseText;
			if (response.indexOf("=err=")>=0)
			{
				alert(response.replace("=err=",""));
			}else{
				showobj.innerHTML=response;
				document.getElementById('hcdiv').style.display='none';
			}
			xmlHttp.abort();
		  }
	  };
	  xmlHttp.send(null);
	
	}
}

function MRPDelete(delid)
{
	ajaxurl="MRPajaxSave.asp?delflg=1&ProductID="+window.cpord+"&MRPID="+delid+"&stamp=" + (Math.random()*10).toString().replace(".","");
	var showobj=document.getElementById("MRPListShow");
	xmlHttp.open("GET", ajaxurl, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState < 4)
		{
			showobj.innerHTML="loading...";
		}
		if (xmlHttp.readyState == 4)
		{
			var response = xmlHttp.responseText;
			if (response.indexOf("=err=")>=0)
			{
				alert(response.replace("=err=",""));
			}else{
				showobj.innerHTML=response;
			}
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);
}

function checkNumeric(obj)
{
	if(obj.value!='')
	{
		if(!isNaN(obj.value))
		{
			obj.oldvalue=obj.value;
		}
		else
		{
			obj.value=obj.oldvalue?obj.oldvalue:obj.defaultValue;
		}
	}
}
