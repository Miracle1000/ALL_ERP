
function SelectAll()
 { 
 var checkboxs=document.getElementsByName("selectid"); 
 for (var i=0;i<checkboxs.length;i++) 
 { 
  var e=checkboxs[i];
    e.checked=!e.checked; 
	}
}

function batdel()
{
	var selectid=document.getElementsByName("selectid");
	var value="";
	var url;
	for (var i=0;i<selectid.length;i++ ){
		if(selectid[i].checked){ //判断复选框是否选中
		    value=value+selectid[i].value + ","; //值的拼凑 .. 具体处理看你的需要,
	    }
	}
	var reg=/,$/gi;
	str=value.replace(reg,"");
	if (str=="")
	{
		alert("您没有选择任何客户，请选择后再删除!");
		}
	else
	{
//		url="batdel_jf.asp?batid="+str;
//		document.getElementById("main").src = url;
		window.open('set_jf2.asp?ord='+str+'','newwincor','width=' + 600 + ',height=' + 400 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')
	}
}
