function SendCon()
{
 	var contents=document.all("contents").value;
 	var state=document.all("state").value;
 	var level=document.all("level").value;
	var ret=document.all("daysOfMonthPos").value;
	var ret2=document.all("daysOfMonth2Pos").value;
 	var url="plan.asp?contents="+escape(contents)+"&state="+escape(state)+"&level="+escape(level)+"&ret="+escape(ret)+"&ret2="+escape(ret2);
	window.location=url;
}
function ABC()
{
	var contents=document.all("contents").value;
 	var state=document.all("state").value;
 	var level=document.all("level").value;
	var ret=document.all("daysOfMonthPos").value;
	var ret2=document.all("daysOfMonth2Pos").value;
	var Currpage=document.all("CurrPage").value;
 	var url="plan.asp?CurrPage="+escape(Currpage)+"&contents="+escape(contents)+"&state="+escape(state)+"&level="+escape(level)+"&ret="+escape(ret)+"&ret2="+escape(ret2);
	window.location=url;
}
function __ImgFormat(){
	var imgs = document.getElementsByTagName("img");
	for (var i = 0; i < imgs.length; i++)
	{
		if (imgs[i].src.indexOf('/edit/upimages/') >= 0)
		{
			var w = imgs[i].offsetWidth;
			if (w > 300)
			{
				imgs[i].style.width = "100px";
				imgs[i].style.cursor = "pointer";
			}
		}
	}
}
$(document).ready(function(){
	try
	{
		__ImgFormat();
	}
	catch (err)
	{
	}
});