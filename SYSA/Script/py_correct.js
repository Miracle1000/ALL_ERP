
function frameResize(){
document.getElementById("mxlist").style.height=I3.document.body.scrollHeight+0+"px";
}

function inselect()
{
	try
	{
		document.date.sorce2.length=0;
		if(document.date.sorce.value=="0"||document.date.sorce.value==null)
		{
			document.date.sorce2.options[0]=new Option('--所属地区--','0');
		}
		else
		{
			for(i=0;i<ListUserId[document.date.sorce.value].length;i++)
			{
				document.date.sorce2.options[i]=new Option(ListUserName[document.date.sorce.value][i],ListUserId[document.date.sorce.value][i]);
			}
		}
		var index=document.date.sorce.selectedIndex;
		//sname.innerHTML=document.date.sorce.options[index].text
	}
	catch(e1){}
} 

function inselect2()
{
	try
	{
		document.date.sorce3.length=0;
		if(document.date.sorce2.value=="0"||document.date.sorce2.value==null)
		{
			document.date.sorce3.options[0]=new Option('--所属地区--','0');
		}
		else
		{
			for(i=0;i<ListUserId2[document.date.sorce2.value].length;i++)
			{
				document.date.sorce3.options[i]=new Option(ListUserName2[document.date.sorce2.value][i],ListUserId2[document.date.sorce2.value][i]);
			}
		}
		var index=document.date.sorce2.selectedIndex2;
		//sname.innerHTML=document.date.sorce2.options[index].text
	}
	catch(e1){}
} 

