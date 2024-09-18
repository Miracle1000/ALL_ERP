
function test()
{
  if(!confirm('确认删除吗？')) return false;
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
