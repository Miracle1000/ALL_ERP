
//高级检索

function callServer2(sort) {
  var url = "liebiao_tj.asp?sort="+sort+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
function test()
{
	if(!confirm('确认删除吗？')) return false;
	var fom=document.getElementById("deleteFor");
	if(fom){
		fom.submit()
	}

}

function mm(form)
{
for (var i=0;i<form.elements.length;i++)
{
var e = form.elements[i];
if (e.name != 'chkall')
e.checked = form.chkall.checked;
}
}

function Myopen(divID){
	if(divID.style.display=="")
	{
		divID.style.display="none"
	}
	else
	{
		divID.style.display=""
	}
	divID.style.zIndex=2;
	divID.style.left=310;
	divID.style.top=document.body.scrollTop;
}
