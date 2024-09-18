

function pro_type1(val)
{
	url="getDate.asp?tp=1&Sid="+val;
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			var test=xmlHttp.responseText;
			var re1=test.indexOf('</noscript>');
			var re2=test.length;
			ajaxhtml=test.substring(re1+11,re2);
			document.getElementById('test2').innerHTML="("+ajaxhtml+")";
		}
	}
	xmlHttp.send(null);	
}

function ask1(a)
{
	var bl=1;
	car_code=document.getElementById('car_code').value
	car_fdjh=document.getElementById('car_fdjh').value
	url="Car_Valid.asp?car_code="+car_code+"&car_fdjh="+car_fdjh+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			bl=xmlHttp.responseText;
		}
	}
	xmlHttp.send(null);	
	if (bl==parseInt(2))
	{
		alert('车牌号/发动机号已经存在!')
		return false;
	}
	document.getElementById('demo').action = "Save_carData.asp?tp=" + a;
}
function openupload()
{
$('#w').window('open');
document.getElementById('msg').style.display='none';
document.getElementById("loading").innerHTML="上传状态：未上传";
document.getElementById('f_file').value="";
document.getElementById('imgurl').value="";
document.getElementById("loading").style.display='';
}
