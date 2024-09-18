
function openwin()
{
window.open("../search/result4.asp","","height=250,width=450,resizable=yes,scrollbars=yes,status=no,toolbar=no,menubar=yes,location=no");
}

function check_kh(ord) {
  //document.getElementById("companyord").value=ord;
  var url = "../event/search_kh.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2();
  };
  xmlHttp.send(null);
}

function updatePage2() {
  if (xmlHttp.readyState < 4) {
	khmc.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	khmc.innerHTML=response;
	xmlHttp.abort();
  }
}

//检测编号是否存在
function autocodeEable()
{
	var box = document.getElementsByName("shid")[0];
	xmlHttp.open("GET", "../inc/autocodetest.asp?data="+escape("42#tousu#shid#date1#") + box.value, false);
	xmlHttp.send();
	var r = xmlHttp.responseText;
	if(r=="ok") {return true;}
	if(r.indexOf("失败")>0 || r.length>50) {alert(r);return false;}
	//if(confirm("当前售后编号已经别他人录入使用，是否重新自动获取售后编号？")) 
	//{
		box.value = r;
		return true;
	//}
	//return false
}

function check_person(ord){	//查看关联联系信息
	var resTxt, arr_res
	var url = "../Repair/addsl.asp?__msgId=getPersonInfo&ord="+ord;
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			var r = xmlHttp.responseText;
			if(r != ""){
				resTxt = r
				arr_res = resTxt.split("{|}");
				if(arr_res[0]=="0"){
					Alert("没有关联的联系人，请重新选择");
					return;
				}else if(arr_res[0]=="1"){
					document.getElementById("personOrd").value = ord
					document.getElementById("telmc").value = arr_res[1];
					document.getElementById("phone").value = arr_res[2];
					document.getElementById("mobile").value = arr_res[3];
				}else{
					Alert("未知错误，请重试");
					return;
				}
			}
		}
	};
	xmlHttp.send(null);
}

function companychange(ord){
	var url = "session_ajax.asp?company="+ord;
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			var r = xmlHttp.responseText;
		}
	};
	xmlHttp.send(null);
}

function serviceTemplateChange(){	
	var addtype = $("input[name='addtype']").val();
	var main = $("select[name='main']").val();	
	var id = $("select[name='main']").find("option:selected").attr("curid");
	$("input[name='curid']").val(id);
	$("input[name='id']").val(id);
	jQuery.ajax({
		url:'../service/add.asp?msgid=serviceTemplateChange',
		data:{id:id, addtype:addtype},
		type:'post',
		success:function(r){
			var arr_res = r.split("\1\2\1");
			if(arr_res.length>0){
				try{
					var num1 = Number(arr_res[0]);
					if(num1>0){
						$("select[name='lead']").attr("min","1");
						$("#leadDiv").show();
					}else{
						$("select[name='lead']").attr("min","0");
						$("#leadDiv").hide();
					}
					$("#serviceTemplate").html(arr_res[1]);
				}catch(e){}
			}						
		},error:function(XMLHttpRequest, textStatus, errorThrown){
			alert(errorThrown);
		}
	});
}

function setPerspon(ord, strvalue, phone, mobile) {
    document.getElementById("personOrd").value = ord;
    document.getElementById("telmc").value = strvalue;
    document.getElementById("phone").value = phone;
    document.getElementById("mobile").value = mobile;
}