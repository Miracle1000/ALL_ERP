
function trim(str){ //删除左右两端的空格
	return str.replace(/(^\s*)|(\s*$)/g,"");
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
