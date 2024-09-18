function selectall(box) {
	var ck = box.checked;
	var boxs = document.getElementsByName("mxid");
	for (var i = 0 ; i < boxs.length; i++ )
	{
		boxs[i].checked = ck;
	}
}

function dosubmit() {
	var boxs = document.getElementsByName("mxid");
	var v = new Array();
	for (var i = 0 ; i < boxs.length; i++ )
	{
		if(boxs[i].checked == true) {
			v[v.length] = boxs[i].value;
		}
	}
	if(v.length==0) {
		app.Alert("您没有选择要派工的行。");
		return;
	}
	document.getElementById("selectid").value = v.join(",");
	var frm = document.getElementById("mfrm");
	frm.submit();
}