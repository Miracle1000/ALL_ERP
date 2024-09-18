
function Myopen(divID){
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=300;
	divID.style.top=5;
}

function detail(sid)
{
	window.open('tongxldetail.asp?sid='+sid,'txldetail','width=' + 1000 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=100,top=100')
}
function edit(sid)
{
	window.open('tongxlupdate.asp?ord='+sid,'txldetail','width=' + 1050 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=100,top=100')
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

function submit3()
{
 	document.getElementById('data').action="../message/sendPersonAll2.asp?type=1";
	document.getElementById('data').submit();
}

function phoneCall(phoneNum) 
{ 
	if (phoneNum!="")
	{
		getCall('../china/bh.asp?ord=0&ordtype=txl&phone='+phoneNum)
		return false;
	}
	else
	{
		alert("号码不能为空！");
	}
} 

