
 function phoneCall(phoneNum) 
{ 
if (phoneNum!="")
{//window.open('../china/bh.asp?phone='+ phoneNum +'','newwin2','width=' + 400 + ',height=' + 300 + ',fullscreen =no,scrollbars=0,toolbar=0,resizable=0,left=200,top=200');
getCall('../china/bh.asp?phone='+ phoneNum +'');
return false;
}
else
{
alert("号码不能为空！");
}
} 


function callServer(m,name1) {
  var u_name = document.getElementById(name1).value;
  var w2  = "test"+m;
   w2=document.all[w2]
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?name=" + escape(u_name)+"&ord="+escape(m)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage(w2);
  };
  xmlHttp.send(null);  
}

function updatePage(w) {
var test6=w
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test6.innerHTML=response;
  }

}

$(document).ready(function(){
getBirthYear(1);
//	getBirthMonth(1);
//	getBirthDay(1);
});
function delfile(str)
{
if(str!="")
{ 
	$.get("delimg.asp",{action:"get",fileUrl:escape(str),date1:Math.round(Math.random()*100)},
function(data,html){
$("#delImg").html(data.split("</noscript>")[1]);
$('#imgurl1').val('');
});
}
else
{
alert("已删除！");
}
}
function inselect()
{

document.data.sorce2.length=0;
if(document.data.sorce.value=="0"||document.data.sorce.value==null)
document.data.sorce2.options[0]=new Option('--所属3地区--','0');
else
{
for(i=0;i<ListUserId[document.data.sorce.value].length;i++)
{
document.data.sorce2.options[i]=new Option(ListUserName[document.data.sorce.value][i],ListUserId[document.data.sorce.value][i]);
}
}
var index=document.data.sorce.selectedIndex;
//sname.innerHTML=document.data.sorce.options[index].text
}


function addEduList()
{
	var date=new Date();
	var trID=date.getHours()+"-"+date.getMinutes()+"-"+date.getSeconds();
	var tempStr="<tr class='"+trID+" top'><td colspan='6' >&nbsp;</td></tr><tr class='"+trID+"'><td ><div align='right'>起始日期：</div></td>"
							+"<td class='gray'><input name='edu_StartTime"+trID+"' type='text' Class='DatePick'  onclick='datedlg.show();' readonly='readonly' size='15' dataType='Limit' min='0' max='50'  >"
							+"<div id=s_daysOfMonth"+trID+" style='position: absolute'></div></td>"
							+"<td><div align='right'>结束日期：</div></td>"
							+"<td class='gray'><input name='edu_EndTime"+trID+"' type='text' Class='DatePick'  onclick='datedlg.show();' readonly='readonly'  size='15' dataType='Limit' min='0' max='50'  >"
							+"<div id=e_daysOfMonth"+trID+" style='position: absolute'></div></td>"
							+"<td ><div align='right'>毕业院校：</div></td>"
							+"<td  ><input name='edu_college' type='text' size='15' dataType='Limit' min='0' max='50'  >"
							+"</td>"
							+"</tr>"
							+"<tr class='"+trID+"'><td ><div align='right'>学历：</div></td>"
							+"<td class='gray'><input type='hidden' name='edu_id' value='0'><input name='edu_Name' type='text'  size='15' dataType='Limit' min='0' max='50'  ></td>"
							+"<td><div align='right'>专业：</div></td>"
							+"<td class='gray'><input name='edu_prof' type='text' size='15' dataType='Limit' min='0' max='50'  ></td>"
							+"<td><div align='right'>备注：</div></td>"
							+"<td class='gray' ><input name='edu_remark' type='text' size='15' dataType='Limit' min='0' max='50'  >&nbsp;&nbsp;<span ><img src='../images/smico/icon_del.gif' width='19' height='17' style='vertical-align:middle' alt='删除' onClick='delListItem(this,0,\"\")'></span></td></tr>";
	$("#eduList").append(tempStr);
}
function delClassItem(parid,cid,tb)
{
	if(cid!=0 && tb!="")
	{
		$.get("delPersonListItem.asp?ord="+cid+"&table="+tb+"",{date1:Math.round(Math.random()*100)});
	}
		$("."+parid.parentElement.parentElement.parentElement.className).remove();
}
function delListItem(parid,cid,tb)
{
	if(cid!=0 && tb!="")
	{
		$.get("delPersonListItem.asp?ord="+cid+"&table="+tb+"",{date1:Math.round(Math.random()*100)});
	}
	$("#"+parid.parentElement.parentElement.parentElement.id).remove();
}
function addLanguaList()
{
	var date=new Date();
	var trID=date.getHours()+"-"+date.getMinutes()+"-"+date.getSeconds();
	var tempStr="<tr class='"+trID+" top'><td ><div align='right'>语言种类：</div></td>"
							+"<td class='gray'><input type='hidden' name='lang_id' value='0'><input name='lang_name' type='text' size='15' dataType='Limit' min='0' max='50'  ></td>"
							+"<td><div align='right'>语言水平：</div></td>"
							+"<td class='gray'><input name='lang_lv' type='text' size='15' dataType='Limit' min='0' max='50'  ></td>"
							+"<td><div align='right'>获得证书：</div></td>"
							+"<td class='gray' ><input name='lang_zhengshu' type='text' size='15' dataType='Limit' min='0' max='50'  ></td></tr>"
							+"<tr class='"+trID+"'><td ><div align='right'>颁发时间：</div></td>"
							+"<td class='gray'><input name='lang_bfdate"+trID+"' type='text' Class='DatePick'  onclick='datedlg.show();' readonly='readonly' size='15' dataType='Limit' min='0' max='50'  >"
							+"</td>"
							+"<td><div align='right'>颁发机构：</div></td>"
							+"<td class='gray'><input name='lang_jigou' type='text' size='15' dataType='Limit' min='0' max='50'  ></td>"
							+"<td><div align='right'>备注：</div></td>"
							+"<td class='gray' ><input name='lang_content' type='text' size='15' dataType='Limit' min='0' max='50'  >&nbsp;&nbsp;<span ><img src='../images/smico/icon_del.gif' width='19' height='17' style='vertical-align:middle' alt='删除' onClick='delClassItem(this,0,\"\")'></span></td></tr>";
	$("#languaList").append(tempStr);
}

function addRelatList()
{
	var date=new Date();
	var trID=date.getHours()+"-"+date.getMinutes()+"-"+date.getSeconds();
	var tempStr="<tr  class='"+trID+" top'>"
								+"<td><div align='right'>姓名：</div></td>"
								+"<td class='gray'><input type='hidden' name='relat_id' value='0'><input name='relat_name' type='text'   size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'></td>"
								+"<td><div align='right'>出生日期：</div></td>"
								+"<td class='gray'><input name='relat_birth"+trID+"' type='text' Class='DatePick'  onclick='datedlg.show();' readonly='readonly'  size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'>"
								+"</td>"
								+"<td><div align='right'>与本人关系：</div></td>"
								+"<td class='gray'><input name='relat_ship' type='text'  size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'></td>"
								+"</tr>"
								+"<tr  class='"+trID+"'>"
								+"<td><div align='right'>工作单位：</div></td>"
								+"<td class='gray'><input name='relat_work' type='text'  size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'></td>"
								+"<td><div align='right'>联系方式：</div></td>"
								+"<td class='gray'><input name='relat_tel' type='text'  size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'></td>"
								+"<td><div align='right'>政治面貌：</div></td>"
								+"<td class='gray'><input name='relat_polit' type='text'  size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'>&nbsp;&nbsp;<span ><img src='../images/smico/icon_del.gif' width='19' height='17' style='vertical-align:middle' alt='删除' onClick='delClassItem(this,0,\"\")'></span></td></tr>";
	$("#relationList").append(tempStr);
}
function addHealthList()
{
	var date=new Date();
	var trID=date.getHours()+"-"+date.getMinutes()+"-"+date.getSeconds();
	var tempStr="<tr  class='"+trID+" top'>"
							+"<td><div align='right'>健康状况：</div></td>"
							+"<td class='gray'><input type='hidden' name='health_id' value='0'><input name='health_State' type='text'   size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'></td>"
							+"<td><div align='right'>有无传染病：</div></td>"
							+"<td class='gray'><input name='health_isDisease"+trID+"' type='radio' value='0' checked>"
							+"无"
							+"<input type='radio' name='health_isDisease"+trID+"' value='1'>"
							+"有</td>"
							+"<td><div align='right'>有无大病史：</div></td>"
							+"<td  class='gray'><input name='health_serious"+trID+"' type='radio' value='0' checked>"
							+"无"
							+"<input type='radio' name='health_serious"+trID+"' value='1'>"
							+"有 </td>"
							+"</tr>"
							+"<tr class='"+trID+"'>"
							+"<td><div align='right'>上次体检日期：</div></td>"
							+"<td class='gray'><input name='health_lastdate"+trID+"' type='text' Class='DatePick'  onclick='datedlg.show();' readonly='readonly'   size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'>"
							+"</td>"
							+"<td><div align='right'>体检周期：</div></td>"
								+"<td class='gray'><input name='health_cycle' type='text'  onKeyUp=\"value=value.replace(/[^\\d]/g,'')\" size='8' dataType='Limit' min='0' max='50'  msg='0~50字符'>"
							+"<select name='health_unit' >"
							+"<option value='1' selected>年</option>"
							+"<option value='2'>季</option>"
							+"<option value='3'>月</option>"
							+"<option value='4'>周</option>"
							+"<option value='5'>日</option>"
							+"</select></td>"
							+"<td><div align='right'>备注：</div></td>"
							+"<td  class='gray'><input name='health_content' type='text'  size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'>&nbsp;&nbsp;<span ><img src='../images/smico/icon_del.gif' width='19' height='17' style='vertical-align:middle' alt='删除' onClick='delClassItem(this,0,\"\")'></span></td></tr>";
	$("#HealthList").append(tempStr);
}
function addCertList()
{
	var date=new Date();
	var trID=date.getHours()+"-"+date.getMinutes()+"-"+date.getSeconds();
	var tempStr="<tr  class='"+trID+" top'>"
								+"<td><div align='right'>资格证书：</div></td>"
								+"<td class='gray'><input type='hidden' name='cert_id' value='0'><input name='cert_title' type='text'   size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'></td>"
								+"<td><div align='right'>颁发时间：</div></td>"
								+"<td class='gray'><input name='cert_hasDate"+trID+"' type='text' Class='DatePick'  onclick='datedlg.show();' readonly='readonly'  size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'>"
								+"</td>"
								+"<td><div align='right'>颁发机构：</div></td>"
								+"<td class='gray'><input name='cert_agency' type='text'  size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'></td>"
								+"</tr>"
								+"<tr  class='"+trID+"'>"
								+"<td><div align='right'>备注：</div></td>"
								+"<td  colspan='5' class='gray'><textarea name='cert_remark' cols='80' rows='6'  id='cert'  dataType='Limit' max='4000'  msg='最多4000个字'></textarea>&nbsp;&nbsp;<span ><img src='../images/smico/icon_del.gif' width='19' height='17' style='vertical-align:middle' alt='删除' onClick='delClassItem(this)'></span></td></tr>";
	$("#CertList").append(tempStr);
		try
	{ parent.frameResize();}
	catch(e){}
}

function TrToggle(ClassName)
{
	$("."+ClassName+"").toggle();
	}


//--比较入职如期和转正日期、合同起始日期和合同终止日期，并弹出提示信息
function __CheckDate(){
	var Entrydate = document.getElementById("Entrydate").value;
	var pubReguldate = document.getElementById("pubReguldate").value;
	var contractStart = document.getElementById("contractStart").value;
	var contractEnd = document.getElementById("contractEnd").value;
	var dateDiff1 = 0;
	var dateDiff2 = 0;
	var msg = ""
	try
	{
		dateDiff1 = daysBetween(pubReguldate,Entrydate);
		dateDiff2 = daysBetween(contractEnd,contractStart);
	}
	catch (e){}
	if (dateDiff1 < 0)
	{
		msg = msg + "入职日期不能大于转正日期！";
		document.getElementById("Entrydate").style.color = "red";
		document.getElementById("pubReguldate").style.color = "red"
	}
	else
	{
		document.getElementById("Entrydate").style.color = "";
		document.getElementById("pubReguldate").style.color = ""
	}
	if (dateDiff2 < 0)
	{
		if (msg.length > 0)
		{
			msg = msg + "\n";
		}
		msg = msg + "\n合同起始日期不能大于合同终止日期！";
		document.getElementById("contractStart").style.color = "red";
		document.getElementById("contractEnd").style.color = "red";
	}
	else
	{	
		document.getElementById("contractStart").style.color = "";
		document.getElementById("contractEnd").style.color = "";
	}
	if (msg.length > 0)
	{
		alert(msg);
		return false;
	}
	else
	{
		return true;
	}
}

//--计算日期差，结果 DateOne - DateTwo 天数
function daysBetween(DateOne,DateTwo)
{
	var OneMonth = DateOne.substring(5,DateOne.lastIndexOf ('-'));
	var OneDay = DateOne.substring(DateOne.length,DateOne.lastIndexOf ('-')+1);
	var OneYear = DateOne.substring(0,DateOne.indexOf ('-'));
	
	var TwoMonth = DateTwo.substring(5,DateTwo.lastIndexOf ('-'));
	var TwoDay = DateTwo.substring(DateTwo.length,DateTwo.lastIndexOf ('-')+1);
	var TwoYear = DateTwo.substring(0,DateTwo.indexOf ('-'));
	
	var cha=((Date.parse(OneMonth+'/'+OneDay+'/'+OneYear)- Date.parse(TwoMonth+'/'+TwoDay+'/'+TwoYear))/86400000);
	return cha;
}

// KILLER.2015.10.19 获取职位下拉菜单
function getPosition(){
	var $p = $("#positionList");
	var pid = $p.find("select[name='PostionID']").val();
	$.post("../hrm/getPosition.asp",{act:"ajax",pid:pid},function(data){
		$p.html(data);
	})
}
