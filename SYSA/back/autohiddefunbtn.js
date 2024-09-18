function onBackPageload() {
	var hrefs = document.getElementsByTagName("a");
	for (var i = 0; i < hrefs.length ; i ++ )
	{
		var item = hrefs[i];
		if(item.href==window.location.href + "#" || item.href.indexOf("void(0)")>0 ) {
			item.href = "javascript:void(0)";
			item.onclick = eval("var o = " + item.onclick.toString().replace("?","?__fReclst=1&") + ";o");
		}
	}
}
onBackPageload();