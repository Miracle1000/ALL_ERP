function SetAsset(args)
{
	var url="../asset/Search_All.asp?tplink=6&id="+args+"&s="+new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		if (xmlHttp.readyState == 4)
		{
			var test=xmlHttp.responseText;
			testarr=test.split(',-,');
			try
			{
				document.getElementById('W_code').innerText=testarr[0];
				document.getElementById('W_method').innerText=testarr[1];
				document.getElementById('W_note').innerText=testarr[2];
				document.getElementById('W_pz').innerText=testarr[3];
				document.getElementById('W_zy').innerText=testarr[4];
				Setbh(args);
			}
			catch(e)
			{}
		}
	};
	xmlHttp.send(null);
}
function Setbh(args)
{
	var url="../asset/Search_All.asp?tplink=7&id="+args+"&s="+new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		if (xmlHttp.readyState == 4)
		{
			var Tbody=document.getElementById('Tbody');
			for (i=0;i<Tbody.rows.length;i++)
			{
				Tbody.deleteRow(i);
			}
			if (xmlHttp.responseText!="")
			{
				Addtrtype(xmlHttp.responseText);
			}
			
		}
	};
	xmlHttp.send(null);	
}
function Addtrtype(args)
{
	try
	{
		argslist=args.split('^|^');
		var idslist=argslist[0];
		var nameslist=argslist[1];
		var styleslist=argslist[2];
		var btslist=argslist[3];
		var idlist=idslist.split('-,-');
		var namelist=nameslist.split('-,-');
		var stylelist=styleslist.split('-,-');
		var btlist=btslist.split('-,-');
		var Tbody=document.getElementById('Tbody');
		for (i=0;i<Tbody.rows.length;i++)
		{
			Tbody.deleteRow(i);
		}
		trnum=NumFormat(idlist.length);
		var rownum=0
		for(j=0;j<trnum;j++)
		{
			var tr=document.createElement("tr");
			tr.id="tr_"+j;
			tr.name="table_tr";
			Tbody.appendChild(tr);
			for(i=rownum;i<idlist.length;i++)
			{
				var td = document.createElement('td');
				td.height="30px";
				tr.appendChild(td);
				var Href = "<div align=\"right\">"+namelist[rownum]+"：</div>";
				td.innerHTML=Href;
				var td1 = document.createElement('td');
				tr.appendChild(td1);
				var Href=""
				if(btlist[i]==1)
				{
					bttest="dataType='Limit'  min='1' max='9000' msg='必填'";
					btspan="&nbsp;<span class='red'>*</span>"
				}
				else
				{
					bttest="";
					btspan="";
				}
				if(stylelist[i]==1)
				{Href = "<div align=\"left\"><input type='text' name='zdy_"+idlist[i]+"' id='zdy_"+idlist[i]+"' "+bttest+" maxlength='200'>"+btspan+"</div>";}
				else if(stylelist[i]==2)
				{Href = "<div align=\"left\"><textarea name='zdy_"+idlist[i]+"' id='zdy_"+idlist[i]+"' "+bttest+" cols='25' rows='2'></textarea>"+btspan+"</div>";}
				else if(stylelist[i]==3)
				{Href = "<div align=\"left\"><input type=\"text\" "+bttest+" Class=\"DatePick\"  onclick=\"datedlg.show();\" readonly=\"readonly\" name='zdy_"+idlist[i]+"' id='zdy_"+idlist[i]+"'>"+btspan+"</div>";}
				else if(stylelist[i]==4)
				{Href = "<div align=\"left\"><input type='text' name='zdy_"+idlist[i]+"' id='zdy_"+idlist[i]+"' "+bttest+" maxlength='12' size='12' onKeyUp=\"value=value.replace(/[^\\d*|\\.]/g,'')\">"+btspan+"</div></div>";}
				else if(stylelist[i]==6)
				{Href = "<div align=\"left\"><input type='radio' name='zdy_"+idlist[i]+"' id='zdy_"+idlist[i]+"' value='1' checked>是<input type='radio' name='zdy_"+idlist[i]+"' id='zdy_"+idlist[i]+"' value='0'>否</div>";}
				else if(stylelist[i]==7)
				{
					values=gridlist(idlist[i]);
					Href = "<div align=\"left\">"+values+"</div>";
				}
				td1.innerHTML=Href;
				rownum=rownum+1
				if(rownum%3==0)
				{
					break;
				}
				if(rownum%3!=0 && rownum==idlist.length)
				{
					if(idlist.length%3==1)
					{
						td1.colSpan=5;
					}
					else
					{
						td1.colSpan=3;
					}
				}
			}
		}
		
	}
	catch(e)
	{}
}
function gridlist(args)
{
	var aa=""
	var url="../asset/Search_All.asp?tplink=4&id="+args+"&s="+new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		if (xmlHttp.readyState == 4)
		{
			if (xmlHttp.responseText!="")
			{
				aa=xmlHttp.responseText;
			}
			
		}
	};
	xmlHttp.send(null);	
	return aa;
}
function NumFormat(args)
{
	var v3=0
	var v1=parseFloat(parseInt(args)/3);
	var v2=parseInt(parseInt(args)/3);
	if (v1>v2)
	{
		v3=v2+1
	}
	else
	{
		v3=v2
	}
	return v3
}

function ask1(spid)
{
	var fromobj=document.getElementById("demo");
	if(Validator.Validate(fromobj,2)==false)	{
		return;
	}	else	{
		check_SP(fromobj,24,spid,0,0,window.nowTime,0,window.currUser);
	}	
}


function ChooseAsset()
{
	var args=document.getElementById('H_type').value;
	if (args!="")
	{
		window.open('../search/search_asset1.asp?name1=H_assname&id=H_assID&args='+args+'','neww27win','width=' + 800 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
	}
	else
	{
		alert('请选择变动类型');
		return;
	}
}
