
function xmldata1(ord, qttype)
{	
	var dhtml=document.getElementById('dhtml');
	var url = "../pay/selgl.asp?qttype=" + qttype + "&ord=" + ord + '&from=paybxcontent';
	xmlHttp.open("GET",url,false);
	xmlHttp.onreadystatechange=function()
	{
		if(xmlHttp.readyState==4)
		{

			var response = xmlHttp.responseText;
			//var re1=response.indexOf('</noscript>');
			//var re2=response.length;
			ajaxhtml=response ;//response.substring(re1+11,re2);
			dhtml.style.display='none';
			dhtml.innerHTML=ajaxhtml;
			var left= document.getElementById("a_"+ord).getBoundingClientRect().left- $("#dhtml").width();
			var top = document.getElementById("a_" + ord).getBoundingClientRect().top;//+document.body.scrollTop;
			var htmlheight = document.body.clientHeight; //所打开当前网页，办公区域的高度，网页的高度 可见高度
			var height = $("#dhtml").height() + 20;
			if (htmlheight - top < height) {
			    top = htmlheight - height + (document.documentElement ? document.documentElement.scrollTop : 0);
			} else {
			    top = top + (document.documentElement ? document.documentElement.scrollTop : 0);
			}

			dhtml.style.top=top+"px";
			dhtml.style.left=left+"px";
			dhtml.style.display='';
			updatePage3();

			//
			__ImgBigToSmall();
		}
	}
	xmlHttp.send(null);	
}
function updatePage3()
{
	xmlHttp.abort();
}
function hidelabel()
{	
	document.getElementById('dhtml').style.display='none';
}
