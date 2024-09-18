
function Myopen(divID){ //根据传递的参数确定显示的层
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=300;
	divID.style.top=0;
}

function mm(form){
	for (var i=0;i<form.elements.length;i++)
	{
		var e = form.elements[i];
		if ((e.name != 'chkall')&&(e.type=='checkbox'))
		e.checked = document.getElementById("checkbox2").checked;
	}
}
