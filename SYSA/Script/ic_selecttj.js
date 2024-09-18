var $$=function(id){return document.getElementById(id);}
for(var i=0;i<ListGate1.length;i++){$$("W1").options.add(new Option(ListGate1[i][1],ListGate1[i][0]));}
for(var i=0;i<ListUsers.length;i++){$$("W3").options.add(new Option(ListUsers[i][1],ListUsers[i][0]));}

function chgOthers(f)
{
	var sobj1=$$("W1");
	var sobj2=$$("W2");
	var sobj3=$$("W3");
	if(f==1)
	{
		RemoveAll(sobj2);
		OptionAdd(sobj2,"所属小组","");
		for(var i=0;i<ListGate2.length;i++){if(ListGate2[i][2]==sobj1.value)OptionAdd(sobj2,ListGate2[i][1],ListGate2[i][0]);}
		RemoveAll(sobj3);
		OptionAdd(sobj3,"所属人员","");
		for(var i=0;i<ListUsers.length;i++){if(ListUsers[i][2]==sobj1.value||sobj1.value=='')OptionAdd(sobj3,ListUsers[i][1],ListUsers[i][0]);}
	}
	else if(f==2)
	{
		RemoveAll(sobj3);
		OptionAdd(sobj3,"所属人员","");
		for(var i=0;i<ListUsers.length;i++){if(ListUsers[i][2]==sobj1.value&&(sobj2.value==''||ListUsers[i][3]==sobj2.value))OptionAdd(sobj3,ListUsers[i][1],ListUsers[i][0]);}
	}
	else if(f==3)
	{
		var tmp;
		if(sobj3.value=="")
		{
			RemoveAll(sobj1);
			RemoveAll(sobj2);
			OptionAdd(sobj1,"所属部门","");
			OptionAdd(sobj2,"所属小组","");
			for(var i=0;i<ListGate1.length;i++){$$("W1").options.add(new Option(ListGate1[i][1],ListGate1[i][0]));}
			RemoveAll(sobj3);
			OptionAdd(sobj3,"所属人员","");
			for(var i=0;i<ListUsers.length;i++){$$("W3").options.add(new Option(ListUsers[i][1],ListUsers[i][0]));}
		}
		else
		{
			for(var tmp=0;tmp<ListUsers.length;tmp++){if(ListUsers[tmp][0]==sobj3.value) break;}
			RemoveAll(sobj2);
			OptionAdd(sobj2,"所属小组","")
			for(var i=0;i<ListGate2.length;i++){
				if(ListGate2[i][0]==ListUsers[tmp][3]){
					OptionAdd(sobj2,ListGate2[i][1],ListGate2[i][0]);
				}
			}
			if(sobj2.length==0) OptionAdd(sobj2,"所属小组","");
			sobj2.value=ListUsers[tmp][3]=='0'?'':ListUsers[tmp][3];
			RemoveAll(sobj1);
			OptionAdd(sobj1,"所属部门","")
			for(var i=0;i<ListGate1.length;i++)
			{
				if(ListGate1[i][0]==ListUsers[tmp][2])
				{
					OptionAdd(sobj1,ListGate1[i][1],ListGate1[i][0]);
				}
			}
			if(sobj1.length==0) OptionAdd(sobj1,"所属部门","");
			sobj1.value=ListUsers[tmp][2]=='0'?'':ListUsers[tmp][2];
		}
	}
}

function RemoveAll(obj){while(obj.options[0]){obj.options.remove(0);}}
function OptionAdd(obj,skey,svalue){obj.options.add(new Option(skey,svalue));}