function Setbh(args)
{
	var url="../asset/Search_All.asp?tplink=1&id="+args+"&s="+new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		if (xmlHttp.readyState == 4)
		{
			document.getElementById("ass_bh").value=xmlHttp.responseText;
		}
	};
	xmlHttp.send(null);
	var url="../asset/Search_All.asp?tplink=3&id="+args+"&s="+new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
				{Href = "<div align=\"left\"><input type=\"text\" name='zdy_"+idlist[i]+"' id='zdy_"+idlist[i]+"' "+bttest+" Class=\"DateTimePick\" onclick=\"datedlg.showDateTime();\" readonly=\"readonly\">"+btspan+"</div>";}
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
	var text="";
	var url="../asset/Search_All.asp?tplink=4&id="+args+"&s="+new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		if (xmlHttp.readyState == 4)
		{
			text=xmlHttp.responseText;
		}
	};
	xmlHttp.send(null);
	return text;
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
function SetAsset(args)
{
	var url="../asset/Search_All.asp?tplink=2&id="+args+"&s="+new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		if (xmlHttp.readyState == 4)
		{
			var test=xmlHttp.responseText;
			testarr=test.split(',-,');
			try
			{
				document.getElementById('ass_statename').value=testarr[0];
				document.getElementById('ass_statename').style.color="black";
				document.getElementById('ass_state').value=testarr[1];
				document.getElementById('ass_method').value=testarr[2];
				document.getElementById('ass_jczl').value=testarr[3];
				document.getElementById('ass_cycle').value=testarr[4];
				document.getElementById('ass_cycle1').value=testarr[5];
			}
			catch(e)
			{}
		}
	};
	xmlHttp.send(null);
}

jQuery(function(){
	jQuery.getScript("../inc/formatnumber.js");
});

function ask1(ord,spid)
{
	var test=0;
	var bh=document.getElementById('ass_bh').value;
	if (bh!="")
	{
		var bhid=bh.substring(bh.length-1,bh.length);
		var url="../asset/Search_All.asp?tplink=5&tp=1&id="+ord+"&bh="+bh+"&s="+new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function()
		{
			if (xmlHttp.readyState == 4)
			{
				test=xmlHttp.responseText;
			}
		};
		xmlHttp.send(null);
	}
	if (test=="1")	{
		alert('编号重复，请重新录入!');
		return false;
	}else{
		//检验有效性
		var jtCycle = $('#ass_cycle').val().length == 0 ? 0 : parseFloat($('#ass_cycle').val());
		var ytCycle = $('#ass_ycycle').val().length == 0 ? 0 : parseFloat($('#ass_ycycle').val());
		var ytMoney = $('#ass_money2').val().length == 0 ? 0 : parseFloat($('#ass_money2').val());
		var buyMoney = $('#ass_money').val().length == 0 ? 0 : parseFloat($('#ass_money').val());
		var jcz = $('#ass_jcz').val().length == 0 ? 0 : parseFloat($('#ass_jcz').val());
		var moneyLeft = parseFloat(FormatNumber(buyMoney - jcz, window.sysConfig.moneynumber));
		if (ytCycle > jtCycle) { alert('已提周期须小于等于计提周期!'); return false; }
		if (ytMoney > moneyLeft) { alert('已提金额须小于等于资产购价-净残值!'); return false; }
		if (ytCycle == jtCycle && ytMoney != moneyLeft) { alert('已提周期须等于计提周期时，已提金额应等于资产购价-净残值!'); return false; }
		if (ytCycle != jtCycle && ytMoney == moneyLeft) { alert('已提金额等于资产购价-净残值时，已提周期须应等于计提周期!'); return false; }
		var minMoney = ytMoney + jcz + (jtCycle - ytCycle) * 0.01;
		if (buyMoney < minMoney) { alert('资产购价不应小于' + minMoney + '！'); return false; }
		var fromobj = document.getElementById("demo");
		check_SP(fromobj, 22, spid, 0, 0, window.nowTime, 0, window.currUser);
		return false;
	}
}

function adSearch(obj,sel_type)
{
	
	var tleft=obj.offsetLeft;
	var ttop=obj.offsetTop;
	var theight=obj.clientHeight;
	while (obj = obj.offsetParent){ttop+=obj.offsetTop; tleft+=obj.offsetLeft;}
	var sdivobj=document.getElementById("adsDiv");
	sdivobj.style.display="none";
	sdivobj.style.left=tleft+"px";
	sdivobj.style.top=ttop+theight+"px";
	document.getElementById("ssIFForm").action="../asset/Select_All.asp?sel_type="+sel_type;
	document.getElementById("ssIFForm").target="adsIF";
	document.getElementById("ssIFForm").submit();
	sdivobj.style.display="inline";
}

function adClose()
{
	document.getElementById('adsDiv').style.display="none";
}
function contJt(args)
{
	var y=document.getElementById('ass_ycycle');
	var m=document.getElementById('ass_money2');
	if(args==0)
	{
        $("#showAss").hide();
        y.value = "";
        m.value = "";
	}
	else
	{
        $("#showAss").show();
	}
}
function setjcz()
{
	var y=document.getElementById('ass_jczl').value;
	var m=document.getElementById('ass_money').value;
	if(y=="" || isNaN(y))
	{y=0;}
	if(m=="" || isNaN(m))
	{m=0;}
	document.getElementById('ass_jcz').value=parseFloat(y)*parseFloat(m);
}
