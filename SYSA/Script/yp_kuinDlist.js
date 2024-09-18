
//高级检索
var xmlHttp = GetIE10SafeXmlHttp(); 
function callServer2() {
  var url = "liebiao_tj.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
function openDiv(val)
{
	//
	var inttop=(150+document.documentElement.scrollTop+document.body.scrollTop)+"px";
	$('#ccc').dialog('open');
	$('#ccc').dialog('move',{left:300,top:inttop});
	var temp1=document.getElementById('a1_'+val).value;
	var temp2=document.getElementById('a2_'+val).value;
	var temp3=document.getElementById('a3_'+val).value;
	var temp4=document.getElementById('a4_'+val).value;
	document.getElementById('date2').innerHTML=temp3;
	document.getElementById('date3').innerHTML=temp4;
	document.getElementById('txt_ph').innerHTML=temp1;
	document.getElementById('txt_xlh').innerHTML=temp2;
}

function Myopen(divID){ //根据传递的参数确定显示的层
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=300;
	divID.style.top=0;
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

