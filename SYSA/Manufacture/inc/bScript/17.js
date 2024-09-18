window.bill_onLoad = function(){
	var rbox = Bill.getInputByDBName("QTModel");
	if(rbox && rbox.type=="hidden") {
		
		var splitbox = Bill.getInputByDBName("qtMxSplit");
		var td = rbox.parentNode;

		if(td.innerHTML.indexOf("splitBox")==-1 && (document.getElementById("bill_info_readonly").value + "") != "1") {
			var tb = td.getElementsByTagName("table")[0];
			var td = tb.rows[0].insertCell(-1);
			td.innerHTML = "<span id='splitBoxSpan' " + (rbox.value==0 ? "style='display:none'" : "") + ">&nbsp;<input onblur='splitBoxChane(this);' onkeyup='this.value=this.value.replace(/[^(\\d|\\.)]/g,\"\")' onkeydown='if(window.event.keyCode==13){splitBoxChane(this);}' value='" + splitbox.value + "' size=4 maxlength='5' id='splitBox'>&nbsp;</span>"
						+ "<span style='color:red'>*</span>";
		}
	}
	Bill.onRefreshDetail(true);
}

function splitBoxChane(box) {
	if(isNaN(box.value)) {return;}
	var splitbox = Bill.getInputByDBName("qtMxSplit");
	var prevalue = box.getAttribute("prevalue");
	if(prevalue==box.value) {
		return;
	}
	else {
		box.setAttribute("prevalue", box.value);
	}
	splitbox.value = box.value;
	Bill.getInputByDBName("hgl").value = "";
	Bill.RefreshDetail(true);
}

Bill.onRadioFieldClick = function(box) {
	var rbox = Bill.getInputByDBName("QTModel");
	document.getElementById("splitBoxSpan").style.display = (rbox.value + "" == "1" ? "" : "none");
}

Bill.onRefreshDetail = function(onload) {
	try
	{
		var hs = false;
		var tb = document.getElementById("listview_71").children[0];
		var row = tb.rows[tb.rows.length-1];
		var cell = row.cells[row.cells.length-1];
		var v =  Bill.getInputByDBName("hgl").value;
		if(v.length > 0 ) {
			v = (v*100).format();
			hs = true;
		}
		var rbox = Bill.getInputByDBName("QTModel");
		cell.innerHTML = "<div id='mxhgldiv' style='display:" + (rbox.value + "" == "1" ? "" : "none") + ";text-align:left;padding-left:4px'>合格率：" +  v + "%</div>";
		if(rbox.value == 1) {
			SumNewValue();
		}
	}
	catch (e){}
}

function SumNewValue() {
	var div = document.getElementById("listview_71");
	lvw.Sum(div);
	if(document.getElementById("MT12_MFRadio1").checked) {
		var sumRow = document.getElementById("listviewsumRow_71");
		var tr = sumRow.parentNode.rows[0];
		var c1 = lvw.getCellIndexByName("",tr,"质检数量");
		var c2 = lvw.getCellIndexByName("",tr,"合格数量");
		var cv1 = sumRow.cells[c1].innerText.replace(/\s/g,"")*1;
		var cv2 = sumRow.cells[c2].innerText.replace(/\s/g,"")*1;
		Bill.getInputByDBName("hgl").value = (cv2*100/cv1).format();
		document.getElementById("mxhgldiv").innerHTML = "合格率：" + (cv2*100/cv1).format() + "%";
	}
}

var wink = null;
lvw.onformulaApply = function() {
	if(wink!=null) {
		window.clearTimeout(wink);
	}
	wink = window.setTimeout("SumNewValue();", 100);
}


lvw.onformulaApplyAll = function() {
	SumNewValue();
}