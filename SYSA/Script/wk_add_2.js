
		function showLikeCompany(telname,pgnum)
		{
			var telobj=document.getElementById(telname);
			if(telobj.value.length>0)
			{
			var url = "cuShowLike.asp?name="+telname+"&t=" + escape(telobj.value)+"&cp="+pgnum+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
			var sobj=document.getElementById("tel_namediv");
			var target=telobj;
			for(var y=0,x=0; target!=null; y+=target.offsetTop, x+=target.offsetLeft, target=target.offsetParent);
			sobj.style.top=(y+telobj.offsetHeight)+"px";
			sobj.style.left=x+"px";
			sobj.style.display="block";
			if (xmlHttp.readyState < 4)
			{
				sobj.innerHTML="读取中，请稍候...";
			}
			else if (xmlHttp.readyState == 4)
			{
				var tmpname=xmlHttp.responseText;
				sobj.innerHTML=tmpname;
			}
			};
			xmlHttp.send(null);
			}
			else
			{
			hideLikeCompany();
			}
		}

		function hideLikeCompany()
		{
		document.getElementById("tel_namediv").style.display="none";
		document.getElementById("tel_namediv").innerHTML="";
		}

		function tu(obj){
		obj.className = "toolitem"
		}

		function tm(obj){
		obj.className = "toolitem_hover"
		}
		document.body.onmouseover=hideLikeCompany;
	