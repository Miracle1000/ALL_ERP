
function test()
{
  if(!confirm('确认取消提醒吗？')) return false;
}
 
function mm(form)
{
	for (var i=0;i<form.elements.length;i++)
	{
		var e = form.elements[i];
		if ((e.name != 'chkall')&&(e.type=='checkbox'))
		e.checked = document.getElementById("checkbox2").checked;
	}
}
