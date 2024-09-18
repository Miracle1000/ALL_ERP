
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

function getBirthYear(){
	var val=$("#birthdayType").val();
	var s = "";
	$.ajax({
       url:"../person/getBirthJson.asp?v=getYear&birthType="+val+"&r="+ Math.random(),
       type:"post",
	   dataType:"json",
	   success:function(json){
	   	  for(var i=0;i<json.length;i++){
			 s = s + "<option value="+json[i].yValue;
			 if(yearBirth==json[i].yValue){
			 	s = s + " selected";
			 }
			 s = s + ">"+json[i].yName+"</option>";
		  };
		  $("#birthYear").html(s);
	   },complete:function(){
	   	  getBirthMonth();
	   }
   });
}
function getBirthMonth(){
	var val=$("#birthdayType").val();
	var birthYear=$("#birthYear").val();
	var s = "";
    var t = "";
	$.ajax({
       url:"../person/getBirthJson.asp?v=getMonth&birthType="+val+"&birthYear="+birthYear+"&r="+ Math.random(),
       type:"post",
	   dataType:"json",
	   success:function(json){
	   	  for(var i=0;i<json.length;i++){
			 s = s + "<option value="+json[i].mValue;
 		if(monthBirth+"-0"==json[i].mValue){
						s = s + " selected";
					 }
			 s = s + ">"+json[i].mName+"</option>";
		  };
		  $("#birthMonth").html(s);
	   },complete:function(){
	   	  getBirthDay();
	   }

   });
}
function getBirthDay(){
	var val=$("#birthdayType").val();
	var birthYear=$("#birthYear").val();
	var birthMonth=$("#birthMonth").val();
	var s = "";
	$.ajax({
       url:"../person/getBirthJson.asp?v=getDay&birthType="+val+"&birthYear="+birthYear+"&birthMonth="+birthMonth+"&r="+ Math.random(),
       type:"post",
	   dataType:"json",
	   success:function(json){
	   	  for(var i=0;i<json.length;i++){
			 s = s + "<option value="+json[i].dValue;
		if(dayBirth==json[i].dValue){
						s = s + " selected";
					 }
			 s = s + ">"+json[i].dName+"</option>";
		  };
		  $("#birthDay").html(s);
	   }
   });
}
$(document).ready(function(){
	getBirthYear();
});
function getNewPerson(id){
	if(id==0 && id!=""){
		$("#newpersondiv").css('display','inline');
	}else if(id!=""){
		window.location.href="personAdd.asp?gateid="+id+"&action=gate";
	}
}

function cateSelect(data){
	$("#sorce").length=0;
	$("#sorce").empty();
	$("<option value=''>--所属部门--</option>").appendTo("#sorce");
	$("#sorce2").length=0;
	$("#sorce2").empty();
	$("<option value=''>--所属小组--</option>").appendTo("#sorce2");
	
	if(data=="1"||data=="0"||data==null){		
		$("#sorce").css("display","none");
		$("#sorce").attr("value","0");
		$("#sorce2").css("display","none");
		$("#sorce2").attr("value","0");
	}else{
		for(i=1;i<ListUserGroup[data].length;i++){
			$("<option value='"+ListUserGroup[data][i]+"'>"+ListUserCate[data][i]+"</option>").appendTo("#sorce");//
		}
		$("#sorce").unbind();
		$("#sorce").css("display","inline");
		if(data == "2"){
			$("#sorce2").css("display","none");
			$("#sorce2").attr("value","0");
		}
		if(data == "3" || data == "4"){
			$("#sorce2").css("display","inline");
			$("#sorce").attr("min","1");
			$("#sorce2").attr("min","1");
			$("#sorce").bind("change",function(){
				inselect($("#sorce").val());				
			});
		}
	}
}

function inselect(data){
	$("#sorce2").length=0;
	if(data=="0"||data==""||data==null){
		$("#sorce2").empty();
		$("<option value='0'>--所属小组--</option>").appendTo("#sorce2");//
	}else{
		$("#sorce2").empty();
		for(i=0;i<ListUserId[data].length;i++){
			$("<option value='"+ListUserId[data][i]+"'>"+ListUserName[data][i]+"</option>").appendTo("#sorce2");//
		}
	}
}

function addEduList()
{
	var date=new Date();
	var trID=date.getHours()+"-"+date.getMinutes()+"-"+date.getSeconds();
	var tempStr="<tr class='"+trID+" top'><td colspan='6' >&nbsp;</td></tr><tr class='"+trID+"'><td ><div align='right'>起始日期：</div></td>"
							+"<td class='gray'><input name='edu_StartTime"+trID+"' type='text'  Class='DatePick'  onclick='datedlg.show();' readonly='readonly' size='15' dataType='Limit' min='0' max='50'  >"
							+"</td>"
							+"<td><div align='right'>结束日期：</div></td>"
							+"<td class='gray'><input name='edu_EndTime"+trID+"' type='text' Class='DatePick'  onclick='datedlg.show();' readonly='readonly'  size='15' dataType='Limit' min='0' max='50'  >"
							+"</td>"
							+"<td ><div align='right'>毕业院校：</div></td>"
							+"<td  ><input name='edu_college' type='text' size='15' dataType='Limit' min='0' max='50'  >"
							+"</td>"
							+"</tr>"
							+"<tr class='"+trID+"'><td ><div align='right'>学历：</div></td>"
							+"<td class='gray'><input name='edu_Name' type='text'  size='15' dataType='Limit' min='0' max='50'  ></td>"
							+"<td><div align='right'>专业：</div></td>"
							+"<td class='gray'><input name='edu_prof' type='text' size='15' dataType='Limit' min='0' max='50'  ></td>"
							+"<td><div align='right'>备注：</div></td>"
							+"<td class='gray' ><input name='edu_remark' type='text'  size='15' id='edu_remark'   dataType='Limit' min='0' max='50' msg='0~50字符' >&nbsp;&nbsp;<span ><img src='../images/smico/icon_del.gif' width='19' height='17' style='vertical-align:middle' alt='删除' onClick='delClassItem(this)'></span></td></tr>";
	$("#eduList").append(tempStr);
		try
	{ parent.frameResize();}
	catch(e){}
}
function delListItem(cid)
{
	$("#"+cid.parentElement.parentElement.parentElement.id).remove();
		try
	{ parent.frameResize();}
	catch(e){}
}
function delClassItem(cid)
{
	$("."+cid.parentElement.parentElement.parentElement.className).remove();

		try
	{ parent.frameResize();}
	catch(e){}
}
function addLanguaList()
{
	var date=new Date();
	var trID=date.getHours()+"-"+date.getMinutes()+"-"+date.getSeconds();
	var tempStr="<tr class='"+trID+" top'><td ><div align='right'>语言种类：</div></td>"
							+"<td class='gray'><input name='lang_name' type='text' size='15' dataType='Limit' min='0' max='50'  ></td>"
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
							+"<td class='gray' ><input name='lang_content' type='text' size='15' dataType='Limit' min='0' max='50'  >&nbsp;&nbsp;<span ><img src='../images/smico/icon_del.gif' width='19' height='17' style='vertical-align:middle' alt='删除' onClick='delClassItem(this)'></span></td></tr>";
	$("#languaList").append(tempStr);
		try
	{ parent.frameResize();}
	catch(e){}
}

function addRelatList()
{
	var date=new Date();
	var trID=date.getHours()+"-"+date.getMinutes()+"-"+date.getSeconds();
	var tempStr="<tr  class='"+trID+" top'>"
								+"<td><div align='right'>姓名：</div></td>"
								+"<td class='gray'><input name='relat_name' type='text'   size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'></td>"
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
								+"<td class='gray'><input name='relat_polit' type='text'  size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'>&nbsp;&nbsp;<span ><img src='../images/smico/icon_del.gif' width='19' height='17' style='vertical-align:middle' alt='删除' onClick='delClassItem(this)'></span></td></tr>";
	$("#relationList").append(tempStr);
		try
	{ parent.frameResize();}
	catch(e){}
}
function addHealthList()
{
	var date=new Date();
	var trID=date.getHours()+"-"+date.getMinutes()+"-"+date.getSeconds();
	var tempStr="<tr  class='"+trID+" top'>"
							+"<td><div align='right'>健康状况：</div></td>"
							+"<td class='gray'><input name='health_State' type='text'   size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'></td>"
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
							+"<td class='gray'><input name='health_cycle' type='text'  onKeyUp=\"value=value.replace(/[^\\d]/g,'')\" size='8' dataType='Limit' min='0' max='50'  msg='0~50字符'> "
							+"<select name='health_unit' >"
							+"<option value='1' selected>年</option>"
							+"<option value='2'>季</option>"
							+"<option value='3'>月</option>"
							+"<option value='4'>周</option>"
							+"<option value='5'>日</option>"
							+"</select></td>"
							+"<td><div align='right'>备注：</div></td>"
							+"<td  class='gray'><input name='health_content' type='text'  size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'>&nbsp;&nbsp;<span ><img src='../images/smico/icon_del.gif' width='19' height='17' style='vertical-align:middle' alt='删除' onClick='delClassItem(this)'></span></td></tr>";
	$("#HealthList").append(tempStr);
		try
	{ parent.frameResize();}
	catch(e){}
}

function addCertList()
{
	var date=new Date();
	var trID=date.getHours()+"-"+date.getMinutes()+"-"+date.getSeconds();
	var tempStr="<tr  class='"+trID+" top'>"
								+"<td><div align='right'>资格证书：</div></td>"
								+"<td class='gray'><input name='cert_title' type='text'   size='15' dataType='Limit' min='0' max='50'  msg='0~50字符'></td>"
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

function checkSC()
{
	if (document.getElementById("salaryClass_old"))
	{
		if (document.getElementById("salaryClass_old").value!=document.getElementById("salaryClass").value)
		{
			if (!confirm("是否确定更改此员工所在的工资帐套"))
			{	
				return false;
			}
		}
	}
	return true;
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