/*业务类 对话框 2012.04.01 谭*/

//----人员多选对话框----。
function __dlg_showGate(title, selgate , allgate)
{
	var div = app.createWindow("gateMenu" , title , 'gate.gif' , '', '', 600, 490);
	ajax.regEvent("showGatePerson",window.virpath + "sdk/commdlg.asp");
	ajax.addParam("gateList", selgate);
	ajax.addParam("allPerson", allgate); //是否加载档案中的人员
	var r = ajax.send();
	div.innerHTML= r;
}

var gatePerson={
/*弹出选择用户框*/
		showGatePersonDiv:function(gateList,all)
		{
			var parentDiv=window.DivOpen("gateMune" ,"人员选择", 600,490,"50","dd",false,2,false,1);
			ajax.regEvent("showGatePerson");
			ajax.addParam("gateList",gateList);
			ajax.addParam("allPerson", all); //是否加载档案中的人员
			parentDiv.innerHTML= ajax.send();
		},
		getGateList:function()
		{
			var input = document.getElementsByTagName("input");
			var r=document.getElementsByName("gatePerson"); 
			var valList="",strList="";
			for(var i = 0; i < input.length; i ++)
			{
				if(input[i].type == "checkbox" && input[i].id.indexOf("gateItem") != -1)
				{
					if (input[i].checked)
					{
						if (valList=="")
						{
							valList=input[i].value;
							strList=input[i].title;
							}
						else
						{
							valList=valList+","+input[i].value;
							strList=strList+"+"+input[i].title;
							}
						}
				}	
			}
			if(app.dlg.onselectgate)
			{
				app.dlg.onselectgate(valList,strList);
				
			}
		},
		selectGateAll:function()
		{
			var input = document.getElementsByTagName("input");
			var r=document.getElementsByName("gatePerson"); 
			var valList="",strList="";
			for(var i = 0; i < input.length; i ++)
			{
				if(input[i].type == "checkbox" && input[i].id.indexOf("gateItem") != -1)
				{
					input[i].checked=true;
				}	
			}
		},
		selectGateSorce:function(cid)
		{
			var input = document.getElementsByTagName("input");
			var r=document.getElementsByName("gatePerson"); 
			var valList="",strList="";
			for(var i = 0; i < input.length; i ++)
			{
				if(input[i].type == "checkbox" && input[i].id.indexOf("gateItem") != -1&& input[i].id.indexOf("gateItem"+cid+"_") != -1)
				{
					if(input[i].checked)
					{
						input[i].checked=false;
						}
					else
					{
						input[i].checked=true;
						}
				}	
			}
		},
		selectGateSorce2:function(cid)
		{
			var input = document.getElementsByTagName("input");
			var r=document.getElementsByName("gatePerson"); 
			var valList="",strList="";
			for(var i = 0; i < input.length; i ++)
			{
				if(input[i].type == "checkbox" && input[i].id.indexOf("gateItem") != -1&& input[i].id.indexOf("_"+cid+"_") != -1)
				{
					if(input[i].checked)
					{
						input[i].checked=false;
						}
					else
					{
						input[i].checked=true;
						}
				}	
			}
		},
		selectGateUn:function()
		{
			var input = document.getElementsByTagName("input");
			var r=document.getElementsByName("gatePerson"); 
			var valList="",strList="";
			for(var i = 0; i < input.length; i ++)
			{
				if(input[i].type == "checkbox" && input[i].id.indexOf("gateItem") != -1)
				{
					if(input[i].checked)
					{
						input[i].checked=false;
						}
					else
					{
						input[i].checked=true;
						}
				}	
			}
		},
		showGateRadioDiv:function (obj,val,all)
		{
			var parentDiv=window.DivOpen("Select_div" ,"人员选择", 600,500,"dd","dd",false);
			ajax.regEvent("showGateRadio");
			ajax.addParam("gateRadio",val);
			ajax.addParam("DivID",obj.name);
			ajax.addParam("allPerson",all==1 ? 1 : 0); //是否显示所有人
			parentDiv.innerHTML= ajax.send();
		},

		getGateRadio:function (obj,DivID)
		{

			var valList="",strList="";
			valList=obj.value;
			strList=obj.title;
			var hbox = document.getElementsByName(DivID)[0];
			var tbutton = hbox.parentElement.children[0];
			if(valList==""||strList=="")
			{
				valList=0;
				strList="点击选择";
				}
				hbox.value = strList;
				tbutton.value =valList;

			if(document.getElementById("divdlg_Select_div")){		document.getElementById("divdlg_Select_div").style.display="none";}
		}
};
