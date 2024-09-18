
	function selectall(box) {
		var ck = box.checked;
		var boxs = document.getElementsByName("ord");
		for (var i = 0 ; i < boxs.length; i++ )
		{
			boxs[i].checked = ck;
		}
	}
	function dosubmit() {
		var boxs = document.getElementsByName("ord");
		var v = new Array();
		for (var i = 0 ; i < boxs.length; i++ )
		{
			if(boxs[i].checked == true) {
				v[v.length] = boxs[i].value;
			}
		}
		if(v.length==0) {
			app.Alert("您没有选择要删除的行。");
			return;
		}
		document.getElementById("selectid").value = v.join(",");
		ajax.regEvent('persondelete');
		ajax.addParam('pord',document.getElementById("selectid").value);
		ajax.exec();
	}
	function onReportRefresh() {
		var w = document.getElementById("lvwbody").style.width.replace("px","");
		if(w*1 < document.body.offsetWidth) {
			w = document.body.offsetWidth;
		}
		document.getElementById("zdiv").style.width = w + "px";
		document.getElementById("toparea").style.width = w + "px";
	}
	
	function dfbtnsClick(itembuttons) {
		var btns = document.getElementsByName("dfbtns");
		for (var  i  = 0; i < btns.length ; i ++ )
		{
			if(btns[i]==itembuttons) {
				btns[i].style.fontWeight = "bold";
			}
			else {
				btns[i].style.fontWeight = "normal";
			}
		}
		document.getElementById("dateTypeV").value = itembuttons.getAttribute("tag");
		ReportSubmit();
	}

	document.body.onresize = function() {
		onReportRefresh();
	}
