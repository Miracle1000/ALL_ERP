
function test()
{
if(!confirm('确认删除吗？')) return false;
}

function mm()
{
var a = document.getElementsByTagName("input");
if(a[0].checked==true){
for (var i=0; i<a.length; i++)
if (a[i].type == "checkbox") a[i].checked = false;
}
else
{
for (var i=0; i<a.length; i++)
if (a[i].type == "checkbox") a[i].checked = true;
}
}
function check_radio(ord,sptype){
document.location.href="edit.asp?ord="+ord+"&sptype="+sptype;
}
function open1()
{
document.getElementById('dd').style.display="block";
$("#dd").dialog("open");
if(top!=window)
{
var lpos=(document.body.clientWidth-document.getElementById('dd').offsetWidth)/2;
$('#dd').dialog('move',{left:lpos,top:100});
if(parent.document.getElementById('cFF'))
{
parent.document.getElementById('cFF').style.height=(document.getElementById('dd').offsetHeight+document.getElementById('dd').offsetTop+130)+"px";
}
}
}
