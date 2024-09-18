function chgStat(lobj,flag,statonly,ord,intype)
{
	if (document.getElementById("arealisthave"))
	{
		searchMe("",2,ord,intype);
	}
	trobj=document.getElementById("treeArea").getElementsByTagName("tr");

	for(var i=0;i<trobj.length;i++)
	{
		if(trobj[i].id)
		{
			var tdobj=trobj[i].cells[0];
			if(tdobj.className!="menu1"&&tdobj.className!="menu2")
			{
				trobj[i].style.display=(flag==1?"":"none");
			}
		}
	}

	if(!statonly)
	{
		if(flag==1)
		{
			lobj.innerHTML="<font class='red'><u>全部收缩</u></font>";
			lobj.onclick=function(){
				chgStat(this,2,false,ord,intype);
			};
		}
		else
		{
			lobj.innerHTML="<font class='red'><u>全部展开</u></font>";
			lobj.onclick=function(){
				chgStat(this,1,false,ord,intype);
			};
		}
	}//onchange="searchAREA(this.value)"
}
function searchMe(valueStr,sort,ord,intype)
{
	if(valueStr.length>=0)
	{
		var tdobj=document.getElementById("treeArea");
		var url = "correctarealist.asp?t=" + escape(valueStr)+"&sort="+sort+"&ord=" + ord + "&intype=" + intype + "&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.send(null);
		tdobj.innerHTML=xmlHttp.responseText;
	}
}