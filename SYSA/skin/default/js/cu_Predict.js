function resetClick(){
	var tagname=document.getElementsByTagName("input");
	for(var i=0;i<tagname.length;i++){
		tagname[i].value=tagname[i].defaultValue;
	}
}