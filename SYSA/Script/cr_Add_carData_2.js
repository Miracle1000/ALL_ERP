
function delimg(filename)
{
	filename=filename.replace(',','')
	url="Del_Image.asp?name="+escape(filename)+"&timestamp="+new Date().getTime()+"&date1="+Math.round(Math.random()*100);
	xmlHttp.open("GET",url,false)
	xmlHttp.send(null);
	var delforce=document.getElementById('imgurl1').value;
	delnow=delforce.replace(filename,'')
	delarr=delnow.split("/")
	document.getElementById("filetext").innerHTML=""
	for (i=0;i<delarr.length;i++)
	{
		delarr[i]=delarr[i].replace(',','')
		delarr[i]=delarr[i].replace(' ','')
		if (delarr[i]!="")
		document.getElementById("filetext").innerHTML=document.getElementById("filetext").innerHTML+delarr[i]+"&nbsp;<a href='###' onclick=delimg('"+delarr[i]+"')>删除</a>&nbsp;";
		
	}
	document.getElementById('imgurl1').value=delnow

}
