//为个性网址添加限制条件
function checkHttps(id)  
{
	var intro = document.getElementById(id).value;
	if(intro != '')
	{
	    if (intro.indexOf("http://") < 0 && intro.indexOf("https://")<0)
		{
			alert("友情提示:请以http(或https)://开头!");
			return false;
		}
	}
	return true;
}
//
function checkSelectInfo(id)
{
	var boxs =  document.getElementsByName(id);
	for(var i = 0; i <boxs.length;i++ )
	{
		if(boxs[i].value == 0)
		{
			alert('友情提示：请您选择单位信息!');
			return false;
		}
	}
	return true;
}