
//高级检索

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

function Myopen(divID){ //根据传递的参数确定显示的层
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=300;
	divID.style.top=10;
}

function detail(sid)
{
	window.open('tongxldetail.asp?sid='+sid,'txldetail','width=' + 1000 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=100,top=100')
}
function edit(sid)
{
	window.open('tongxlupdate.asp?ord='+sid,'txldetail','width=' + 1000 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=100,top=100')
}

function submit3()
{
 	document.getElementById('data').action="../message/sendPersonAll2.asp?type=1";
	document.getElementById('data').submit();
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

