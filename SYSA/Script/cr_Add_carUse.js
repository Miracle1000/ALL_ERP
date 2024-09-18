
function Ajax(){
	var xH,xA="",fun=arguments[1];
	for (i=2;i<arguments.length;i++) xA+=",'"+arguments[i]+"'";
	this.Ajax_sced=function(){ if(xH.readyState==4||xH.readyState=="complete") eval("fun(xH.responseText"+xA+");");}
	this.Ajax_gxho=function(handler){ var oXH=false;
		if(window.XMLHttpRequest) { oXH = new XMLHttpRequest(); if(oXH.overrideMimeType) oXH.overrideMimeType('text/xml');
		}else if(window.ActiveXObject) {
			var versions=['Microsoft.XMLHTTP','MSXML.XMLHTTP','Microsoft.XMLHTTP','Msxml2.XMLHTTP.7.0','Msxml2.XMLHTTP.6.0','Msxml2.XMLHTTP.5.0','Msxml2.XMLHTTP.4.0','MSXML2.XMLHTTP.3.0','MSXML2.XMLHTTP'];	for(var i=0;i<versions.length;i++) {try {oXH=new ActiveXObject(versions[i]);if(oXH) break;	} catch(e) {}};
		} try{oXH.onreadystatechange=handler; return oXH;} catch(e){ alert("AJAX环境错误"); return ;} 
	}
	if (arguments[0].length>0){ xH=this.Ajax_gxho(this.Ajax_sced); xH.open("POST",arguments[0],true); xH.send(" ");}else{ eval("fun(''"+xA+");");}
}

function set_dvr(id,num){
	Ajax("get_driver_ajax.asp?id="+id,function show(str){document.getElementById("div_dvr_"+id+"_"+num).innerHTML=str;});
}

function addtr(id,name,driver)
{
	var Table=document.getElementById('add_tr');
	var tr=document.createElement("tr");
	tr.id="tr_"+id+"_"+a;
	tr.name="table_tr";
	Table.appendChild(tr);
	tr.onmouseover=function(){this.style.backgroundColor='efefef';}
	tr.onmouseout=function(){this.style.backgroundColor='';}
	var td1 = document.createElement('td');
	tr.appendChild(td1);
	var Href = "<div align=\"left\"><pre>"+name+"<input type='hidden' name='use_carid' id=\"use_carid_"+id+"\" value='"+id+"'>&nbsp;<a href=\"###\" onclick=\"del_TR('"+tr.id+"')\"><img src=\"../images/del2.gif\"/></a>&nbsp;<span id='sortlist'>"+a+"</span></div>";
	td1.innerHTML=Href;
	var td2 = document.createElement('td');
	tr.appendChild(td2);
	var Href = "<div align=\"center\" id=\"div_dvr_"+id+"_"+a+"\"><select name=\"use_driver\"><option value=\'\'>请选择司机</option></select></div>";
	td2.innerHTML=Href;
	var td3 = document.createElement('td');
	tr.appendChild(td3);
	var Href = "<div align=\"center\"><select name=\"use_catetype\">"
	Href = Href+"<option value=\"1\" selected>公用</option>"
	Href = Href+"<option value=\"2\">私用</option>"
	Href = Href+"</select></div>";
	td3.innerHTML=Href;
	var td4 = document.createElement('td');
	tr.appendChild(td4);
	var Href = "<div align=\"center\"><input type=\"text\" name=\"use_pctime\" id=\"use_pctime\" Class=\"DateTimePick\" onclick=\"datedlg.showDateTime();\" readonly=\"readonly\"></div>"
	td4.innerHTML=Href;
	var td5 = document.createElement('td');
	tr.appendChild(td5);
	var Href = "<div align=\"center\"><input type=\"text\" name=\"use_startime\" id=\"use_startime_"+id+"\" Class=\"DateTimePick\" onclick=\"datedlg.showDateTime();\" readonly=\"readonly\"></div>"
	td5.innerHTML=Href;
	var td6 = document.createElement('td');
	tr.appendChild(td6);
	var Href = "<div align=\"center\"><input type=\"text\" name=\"use_endtime\" id=\"use_endtime"+id+"\" Class=\"DateTimePick\" onclick=\"datedlg.showDateTime();\" readonly=\"readonly\"></div>"
	td6.innerHTML=Href;
	var td7 = document.createElement('td');
	tr.appendChild(td7);
	var Href = "<div align=\"center\"><input type='text' name='use_mdd' size='12' maxlength=\"1000\"></div>";
	td7.innerHTML=Href;
	var td8 = document.createElement('td');
	tr.appendChild(td8);
	var Href = "<div align=\"center\"><input type='text' name='use_lc' size='9' maxlength=\"1000\"></div>";
	td8.innerHTML=Href;
	var td9 = document.createElement('td');
	tr.appendChild(td9);
	var Href = "<div align=\"center\"><input type='text' name='use_thing' size='12' maxlength=\"1000\"></div>";
	td9.innerHTML=Href;
	var td10 = document.createElement('td');
	tr.appendChild(td10);
	var Href = "<div align=\"center\"><input type='text' name='use_notes' size='12' maxlength=\"500\"></div>";
	td10.innerHTML=Href;
	set_dvr(id,a);
	a=a+1;
}

function batch(parse1)
{
	var pvalue=document.getElementById(parse1).value;
	if (parse1=='usecatetype')
	{parse1='use_catetype';}
	else if (parse1=='usenotes')
	{parse1='use_notes';}
	else if (parse1=='usemdd')
	{parse1='use_mdd';}
	else if (parse1=='uselc')
	{parse1='use_lc';}
	else if (parse1=='usething')
	{parse1='use_thing';}
	var plist=document.getElementsByName(parse1);
	for (i=0;i<plist.length;i++)
	{
		plist[i].value=pvalue;
	}
}
function chkuname(args)
{
	document.getElementById('uname').innerHTML=args;
}


$(function(){
	$("#usePersonnel").trigger("click");
		
	var $p = $("#personnelList").find("input[name=member2][value="+window.currUse+"]");
	if($p.size() > 0){
		var uname = $p.attr("username");
		$("#uname").text(uname);
		$p.attr("checked","checked")
	}

});

