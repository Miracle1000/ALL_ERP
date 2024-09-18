
function pro_type1(val)
{
	url="getDate.asp?tp=1&Sid="+val;
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			var test=xmlHttp.responseText;
			var re1=test.indexOf('</noscript>');
			var re2=test.length;
			ajaxhtml=test.substring(re1+11,re2);
			document.getElementById('test2').innerHTML="("+ajaxhtml+")";
		}
	}
	xmlHttp.send(null);	
}
function searchMe(obj,pgnum)
{
	var reg = /^([+-]?)((\d{1,3}(,\d{3})*)|(\d+))(\.\d{2})?$/;
	if(pgnum != "")
	{
		if(!reg.exec(pgnum))
		{
			alert("请输入数字");
			return false
		}
	}
	
	var u_name="";
	try{ u_name=document.getElementById('u_name').value;}
	catch(e){}
	var u_select="";
	try{ u_select=document.getElementById('u_select').value;} catch(e){}	
	var u_xlh='hhe'
	var tdobj=document.getElementById("searchdiv");
	var url = "ajax_yp.asp?a=" + escape(u_name)+"&b=" + escape(u_select)+"&c=" + escape(u_xlh)+"&cp="+pgnum+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send(null);
	tdobj.innerHTML=xmlHttp.responseText;
}
function tu(obj){
	obj.className = "toolitem"
}
function tm(obj){
	obj.className = "toolitem_hover"
}

function openDiv(val)
{
	//
	$('#ddd').dialog('open');
	$('#ddd').dialog('move',{left:100,top:150});
	var temp1=document.getElementById('prod_ph'+val).value;
	var temp2=document.getElementById('prod_xlh'+val).value;
	var temp3=document.getElementById('prod_sctime'+val).value;
	var temp4=document.getElementById('prod_ystime'+val).value;
	document.getElementById('ydaysOfMonthPosy').value=temp3;
	document.getElementById('zdaysOfMonthPosz').value=temp4;
	document.getElementById('aa').value=temp1;
	document.getElementById('bb').value=temp2;
	document.getElementById('setID').value=val;
}
function Savetr()
{
	var val=document.getElementById('setID').value;
	var temp1=document.getElementById('aa').value;
	var temp2=document.getElementById('bb').value;
	var temp3=document.getElementById('ydaysOfMonthPosy').value;
	var temp4=document.getElementById('zdaysOfMonthPosz').value;
	document.getElementById('prod_ph'+val).value=temp1;
	document.getElementById('prod_xlh'+val).value=temp2;
	document.getElementById('prod_sctime'+val).value=temp3;
	document.getElementById('prod_ystime'+val).value=temp4;	
	document.getElementById('setID').value="";
	$('#ddd').dialog('close');
}
function openDiv1()
{
	$('#ccc').dialog('open');
	$('#ccc').dialog('move',{left:100,top:150});
}
function del_TR(id)
{
	var tr=document.getElementById(id);
	tr.parentNode.removeChild(tr);
	setSortList();
}
function setSortList()
{
	var sortlist=document.getElementsByName('sortlist');
	for (i=0;i<sortlist.length;i++)
	{
		sortlist[i].innerHTML=i+1;
	}
	a=a-1;
}
function chaValue(val,decNum)
{
	var num="prod_num"+val
	var price="prod_price"+val
	var num1=document.getElementById(num).value;
	var price1=document.getElementById(price).value;
	if (num1!="" && price1!="")
	{
        if((num1!="0")&&(price1!="0"))
        {
            var allmoney=parseFloat(num1)*parseFloat(price1);
            var dot=window,dotNum1;
            dot=parseInt(dot);
            allmoney = allmoney.toString();
            var dotloc = allmoney.indexOf('.');
            var mlength = allmoney.length;
            if (dotloc > 0) {
                if ((dotloc + dot + 1) < mlength) {
                    var allmoney = allmoney.substring(0, dotloc + dot + 1);
                }
            }
        }
        else
        {
            allmoney=0;
        }
        document.getElementById("prod_allmoney" + val).value = parseFloat(allmoney).toFixed(decNum)
	}
}
function batch(name,value)
{
	var obj=document.getElementsByName(name)[0];
	var tgname=obj?obj.tagName:"input";
	var arrlist=document.getElementsByTagName(tgname);
	for(i=0;i<arrlist.length;i++)
	{
		if(arrlist[i].name.indexOf(name)==0)
		{
			arrlist[i].value=value;
		}
	}
}
function ask1()
{
	//var objdiv=document.createElement('div');
//	objdiv.className='bgdiv';
//	objdiv.innerHTML='正在保存请稍等！！！'
//	document.body.appendChild(objdiv)
	var sto_idarr=document.getElementsByName('sto_id');
	if(sto_idarr.length==0)
	{
		alert('请添加入库明细')
		return false;
	}
	for(i=0;i<sto_idarr.length;i++)
	{
		if (sto_idarr[i].value=="")
		{
			alert('入库仓库不能为空');
			return false;
		}
	}
	var arrlist=document.getElementsByTagName("input");
	for(i=0;i<arrlist.length;i++)
	{
		if (arrlist[i].type=="text" || arrlist[i].type=="hidden")
		{
			if(arrlist[i].value.indexOf(", ")>=0 && (!arrlist[i].onpropertychange))
			{ 
				arrlist[i].value=arrlist[i].value.replace(/,\s/g,"^#$6a");
			}
		}
	}
	return true;
}
