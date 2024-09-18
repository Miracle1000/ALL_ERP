
function changeForm(sindex)
{
	if(sindex==0)
	{
		document.getElementById("MRPSetupPanel").style.display="none";
		objLock("M_MRPTitle",true,'1','50');//MRP主题
		objLock("M_BatchRules",true,'1','');
		objLock("M_BatNum",true,'1','');
		objLock("M_NumRequest",true,'1','');
		objLock("M_DayProvide",true,'1','');
		objLock("M_TimeInAdvance",true,'1','');
		objLock("M_SaveNum",true,'1','');
		objLock("M_ReorderPoint",true,'1','');
		objLock("M_AttritionRate",true,'0.00','99.99');
		objLock("M_Costs",true,'1','');
		objLock("property1",true,'1','');
		objLock("property2",true,'1','');
		objLock("property3",true,'1','');
		objLock("property4",true,'1','');
		objLock("property5",true,'1','');
		objLock("property6",true,'1','');
		objLock("property7",true,'1','');
	}
	else if(sindex==2)
	{//ROP
		document.getElementById("MRPSetupPanel").style.display="block";
		objLock("M_MRPTitle",false,'1','50');//MRP主题
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
	else if(sindex==1)
	{//MRP
		document.getElementById("MRPSetupPanel").style.display="block";
		objLock("M_MRPTitle",false,'1','50');//MRP主题
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
		objLock("property6",false,'1','');//产品属性
		objLock("property7",false,'1','');//产品属性
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

function checkSelection2()
{
	if(document.getElementById("M_Tactics").selectedIndex==0) return true;
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
