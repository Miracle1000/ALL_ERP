<html> 
<head> 
<title>无刷新</title> 

<script language="javascript" type="text/javascript"> 
function GetData(url) 
{ 
url="diaoyong2.asp";//调用页面 
try 
{ 
DataLoad.src = url; 
} 
catch(e) 
{ 
return false; 
} 
{ 
var timeoutid = setTimeout("GetData()",1000) 
} 
} 
</script> 
<script id="DataLoad" language="javascript" type="text/javascript" defer></script> 
</head>
<body onLoad="javascript:GetData();"> 
<span id=loadcontent>数据载入中……</span> 
</body> 
</html>
