


/*弹出选择用户框*/
		function showGatePersonDiv(obj,val)
		{
			var parentDiv=window.DivOpen("Select_div" ,"人员选择", 600,500,"dd","dd",false,2);
			ajax.regEvent("showGatePerson");
			ajax.addParam("gateList",val);
			ajax.addParam("DivID",obj.name);
			parentDiv.innerHTML= ajax.send();
		}
		function getGateList(DivID)
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
			var hbox = document.getElementsByName(DivID)[0];
			if(valList==""||strList=="")
			{
				valList=0;
				$("#"+hbox.id+"").css("color","#999999");
				strList="点击选择";
				}
			else
			{
				$("#"+hbox.id+"").css("color","#000000");
				}
				hbox.value = strList;
				var tbutton = hbox.parentElement.children[0]
				tbutton.value = valList;

			if(document.getElementById("divdlg_Select_div")){		document.getElementById("divdlg_Select_div").style.display="none";}
		}
		function selectGateAll()
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
		}
		function selectGateSorce(cid)
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
		}
		function selectGateSorce2(cid)
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
		}
		function selectGateUn()
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
		}
		function showGateRadioDiv(obj,val)
		{
			var parentDiv=window.DivOpen("Select_div" ,"人员选择", 600,500,"dd","dd",false,2);
			ajax.regEvent("showGateRadio");
			ajax.addParam("gateRadio",val);
			ajax.addParam("DivID",obj.name);
			parentDiv.innerHTML= ajax.send();
		}
	function getGateRadio(obj,DivID)
	{

			var valList="",strList="";
			valList=obj.value;
			strList=obj.title;
			var hbox = document.getElementsByName(DivID)[0];
			if(valList==""||strList=="")
			{
				valList=0;
				$("#"+hbox.id+"").css("color","#999999");
				strList="点击选择";
				}
			else
			{
				$("#"+hbox.id+"").css("color","#000000");
				}
				hbox.value = strList;
				var tbutton = hbox.parentElement.children[0]
				tbutton.value = valList;

			if(document.getElementById("divdlg_Select_div")){		document.getElementById("divdlg_Select_div").style.display="none";}
		}

function showGetLinkNum(obj,val,Ord)
{
			var parentDiv=window.DivOpen("div_LinkNum" ,"单据选择", 600,500,"dd","dd",false,2);
			ajax.regEvent("ShowLinkNum");
			ajax.addParam("Val",val);
			ajax.addParam("Ord",Ord);
			ajax.addParam("DivID",obj.name);
			parentDiv.innerHTML= ajax.send();
}
function getLinkNum(Ord,Title,DivID)
{
			var valList="",strList="";
			var hbox = document.getElementsByName(DivID)[0];
			if(valList==""||strList=="")
			{
						valList=0;
						$("#"+hbox.id+"").css("color","#999999");
						strList="点击选择";
				}
			else
			{
						$("#"+hbox.id+"").css("color","#000000");
				}
				hbox.value = Title;
				var tbutton = hbox.parentElement.children[0]
				tbutton.value = Ord;

			if(document.getElementById("divdlg_div_LinkNum")){		document.getElementById("divdlg_div_LinkNum").style.display="none";}
}

