function test()
{
  if(!confirm('您选择的是彻底删除，删除后不能再恢复，确认删除？')) return false;
}
 
function mm()
{
   var a = document.all("checkbox2");
   var c = document.getElementsByName("selectid")
	if(a.checked==true)
	{
   		for(var i=0;i<c.length;i++)
		c[i].checked=true;
   	}
	else
	{
		for(var i=0;i<c.length;i++)
		c[i].checked=false
	}
}
function ask2() { 
	if (!confirm("确认要批量恢复选中的信息？")) {
				window.event.returnValue = false;
			}
	else
	{
	document.all.form1.action = window.currask2Url; 
	document.all.form1.submit(); 
	}
}