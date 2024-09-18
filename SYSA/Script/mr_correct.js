

function checkLoginName(name,ord){
	if (!document.getElementById("user"))
	{
		return true;
	}
	var oldname=document.getElementById("olduser").value.replace(/(^\s*)|(\s*$)/g,"");
	var name=document.getElementById("user").value.replace(/(^\s*)|(\s*$)/g,"");
	var result=false;
	var url = "cu_loginname.asp?timestamp=" + new Date().getTime() + "&loginName="+escape(name)+ "&ord="+ord;
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			document.getElementById("flag").value=response;
			if(response=="0"){
				document.getElementById("checkflag").innerHTML="";
				result= true;
			}
			else if (oldname==name)
			{
				document.getElementById("checkflag").innerHTML="";
				result= true;
			}
			else{
				document.getElementById("checkflag").innerHTML="用户名已存在";
				}
		}
	};
	xmlHttp.send(null);
	return result;
}
function inselect()
{

document.date.sorce2.length=0;
if(document.date.sorce.value=="0"||document.date.sorce.value==null)
document.date.sorce2.options[0]=new Option('--所属3地区--','0');
else {
    if (document.date.sorce.value != -1) {
        for (i = 0; i < ListUserId[document.date.sorce.value].length; i++) {
            document.date.sorce2.options[i] = new Option(ListUserName[document.date.sorce.value][i], ListUserId[document.date.sorce.value][i]);
        }
    }
}
var index=document.date.sorce.selectedIndex;
//sname.innerHTML=document.date.sorce.options[index].text
}

//-->

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
	var psd = document.getElementById("psd");
	if (psd)
	    if (psd.value.length != 0 && (psd.value.length < 6 || psd.value.length > 50))
	    {
	        alert("密码长度必须在6—50位之间");
	        return false;
	    }
	return true;
}

function callServer_addmb(e,ord,sort1,sort2) {
  if(e.checked==true){
  		var del=1;
  }else{
		var del=0;
  }
  var url = "add_applymb.asp?ord="+escape(ord)+"&del=" + escape(del) + "&sort1="+escape(sort1)+"&sort2="+escape(sort2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.send(null);
}
function call_personmb(ord) {
  var u_name = document.getElementById("person_mb").value;
  if ((u_name == null) || (u_name == "")) return;
  var url = "person_applymb.asp?u_name=" + escape(u_name)+"&ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){

  update_personmb();
  };

  xmlHttp.send(null);
}
function update_personmb() {
  if (xmlHttp.readyState < 4) {
	document.getElementById("content_mb").innerHTML="<br>&nbsp;&nbsp;&nbsp;&nbsp;正在配置账号领用范围，请稍后...<br><br>";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	document.getElementById("content_mb").innerHTML=response;
	xmlHttp.abort();
	parent.frameResize();
  }
}
