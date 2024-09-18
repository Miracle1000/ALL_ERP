function todohiden() {
	var lnks = document.getElementsByTagName("a");
	for (var i = 0; i < lnks.length ; i ++ )
	{
		var item = lnks[i];
		var txt = item.innerText.replace(" ","");
		if(txt.indexOf("添加") >= 0 || txt.indexOf("编辑") >= 0 || txt.indexOf("导入")>= 0 || txt.indexOf("修改")>= 0 || txt.indexOf("设置")==0  || txt.indexOf("取消") ==0 ) {
			item.style.display = "none";
			var imgs = item.parentNode.getElementsByTagName("img");
			for (var ii = 0 ; ii<imgs.length ; ii++ )
			{
				imgs[ii].style.display = "none";
			}
		}
	}
}
todohiden();
