
Date.firstDayOfWeek = 0;
Date.format = 'yyyy-mm-dd';
function showGatePersonDiv(InputName,InputId,defaultval,strUrl,width,height)
{
	if(strUrl.indexOf("?")>=0)
	{
		strUrl=strUrl+"&InputName="+InputName+"&InputId="+InputId+"&W3="+defaultval;
		}
	else
	{
		strUrl=strUrl+"?InputName="+InputName+"&InputId="+InputId+"&W3="+defaultval;
		}
	var w = 960 , h = 640 ;
	window.open( strUrl ,'newwin_','width=' + w + ',height=' + h + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
}
function GetUserVal(inputId,val,username)
{
	$("#"+inputId+"").val(username);
	$("#gate_ord_1").val(val);
}

function check_kh(ord){
	$.ajax({
		url:"alt_hy.asp?msgid=getCompany&ord="+ord,
		success:function(r){			
			$('#company').val(ord);
			$('#telName').val(r);
		}
	});
}

