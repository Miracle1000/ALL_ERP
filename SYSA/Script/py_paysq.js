
function test()
{
  if(!confirm('确认删除吗？')) return false;
}
 
function mm()
{
   var a = document.getElementsByTagName("input");
   var b=document.getElementById("chkall");
   if(b.checked==true)
	{
   		for (var i=0; i<a.length; i++)
		{
      		if (a[i].type == "checkbox")
			{ a[i].checked = true;}
		}
   }
   else
   {
   		for (var i=0; i<a.length; i++)
		{
      		if (a[i].type == "checkbox")
			{a[i].checked = false;}
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
	divID.style.top=20;
}
