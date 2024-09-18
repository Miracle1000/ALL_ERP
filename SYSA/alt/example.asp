<HTML> 
<head> 
<title>无刷新</title> 

<script language="javascript"> 
function GetData() 
{ 
url="diaoyong.asp";//调用页面 

var http = new ActiveXObject("Microsoft.XMLHTTP"); 
http.open("POST",url,false); 
http.send(); 
var str = http.responseText; 
loadcontent.innerHTML=str; 
setTimeout("GetData()",1000); 
} 
</script> 

</head> 
<BODY onload="javascript:GetData();"> 
<span id="loadcontent">数据载入中……</span> 
</BODY> 
</HTML> 
