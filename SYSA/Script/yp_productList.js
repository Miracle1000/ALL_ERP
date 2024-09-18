
//高级检索
var xmlHttp = GetIE10SafeXmlHttp(); 
function callServer2() {
  var url = "liebiao_tj_kuin.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2();
  };
  xmlHttp.send(null);  
}
function updatePage2() {
var test7="ht1"
  if (xmlHttp.readyState < 4) {
	ht1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	ht1.innerHTML=response;
	xmlHttp.abort();
  }
}
//function set_del(area)
//{
//	var url = "set_del?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
//	xmlHttp.open("GET", url, false);
//	xmlHttp.send(null);
//}

function ask()
{
	var reg=/^([+-]?)((\d{1,3}(,\d{3})*)|(\d+))(\.\d{2})?$/;
	if(document.getElementById('L1').value != "" || document.getElementById('L2').value != "")
	{
		
		if(!reg.exec(document.getElementById('L1').value) || !reg.exec(document.getElementById('L2').value))
		{
			document.getElementById('L_1').innerHTML="请输入数字"
			document.getElementById('L1').value = "";
			document.getElementById('L2').value = "";
			return false
		}
	}
	if(document.getElementById('L3').value != "" || document.getElementById('L4').value != "")
	{
		if(!reg.exec(document.getElementById('L3').value) || !reg.exec(document.getElementById('L4').value))
		{
			document.getElementById('L_2').innerHTML="请输入数字"
			document.getElementById('L3').value = "";
			document.getElementById('L4').value = "";
			return false
		}
	}
}

function Myopen(divID){ //根据传递的参数确定显示的层
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=300;
	divID.style.top=10;
}

function mm(form)
{
for (var i=0;i<form.elements.length;i++)
///循环,form.elements.length得到表单里的控件个数
{
///把表单里的内容依付给e这个变量 
var e = form.elements[i]; 
if (e.name != 'chkall') 
e.checked = form.chkall.checked; 
}
}

