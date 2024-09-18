function ArrayExist(arr, v) {
	for (var i = 0 ; i < arr.length ; i++)
	{
		if(arr[i]==v) { return true; }
	}
	return false;
}

function ReportView() {
	ReportSave(true);
}

function showReportView(id) {
	window.open("index.asp?view=1","ReportView", "width=940,height=560,fullscreen =no,scrollbars=1,resizable=1,toolbar=0,left=80,top=80");
}

function ReportReset() {

}

function getTelClsData(div) {
	var d1 = new Array()
	var d2 = new Array()
	var ckboxs = div.getElementsByTagName("input");
	for (var i = 0; i < ckboxs.length ; i ++ )
	{
		var box = ckboxs[i];
		if(box.checked==true) {
			switch(box.name.toLowerCase()) {
				case "e" : d1[d1.length] = box.value; break;
				case "f" : d2[d2.length] = box.value; break;
			}
		} 
	}
	return d1.join(",") + "|" + d2.join(",")
}

function getFieldGatesData(div) {
	var w1 = new Array();
	var w2 = new Array();
	var w3 = new Array();
	var ckboxs = div.getElementsByTagName("input");
	for (var i = 0; i < ckboxs.length ; i ++ )
	{
		var box = ckboxs[i];
		if(box.checked==true) {
			switch(box.name.toLowerCase()) {
				case "w1" : w1[w1.length] = box.value; break;
				case "w2" : w2[w2.length] = box.value; break;
				case "w3" : w3[w3.length] = box.value; break;
			}
		} 
	}
	return w1.join(",") + "|" + w2.join(",") + "|" + w3.join(",") 
}

function getFieldChecksData(div) {
	var w = new Array();
	var ckboxs = div.getElementsByTagName("input");
	for (var i = 0; i < ckboxs.length ; i ++ )
	{
		var box = ckboxs[i];
		if(box.checked==true) {
			w[w.length] = box.value;
		} 
	}
	return w.join(",");
}

function getfield(id) {
	var obj = new Object();
	var box = $ID(id);
	obj.fkey = box.value;
	obj.ftype = box.getAttribute("ftype");
	obj.fsort = "";
	var div = $ID(id + "data");
	var sbox = div.getElementsByTagName("select");
	for(var i = 0 ; i < sbox.length ; i++) {
		if(sbox[i].className=="fieldsort") {
			obj.fsort = sbox[i].value;
			break;
		}
	}
	switch(obj.ftype) {
		case "gates":
			obj.data = getFieldGatesData(div);
			break;
		case "gategroup":
			obj.data = getFieldGatesData(div);
			break;
		case "telcls":
			obj.data = getTelClsData(div);
			break;
		default:
			obj.data = getFieldChecksData(div);
			break;
	}
	return obj
}

function ReportSave(isTemp) {
	var col = getfield("colfields");
	var row = getfield("rowfields");
	var cks = new Array();
	var boxs = document.getElementsByName("csf");
	for (var i=0; i<boxs.length; i++)
	{
		var box = boxs[i];
		if(box.checked) { cks[cks.length] = box.value; }
	}
	var cansearch = cks.join("|");
	var boxs = document.getElementsByName("adcsf");
	cks = new Array();
	for (var i=0; i<boxs.length; i++)
	{
		var box = boxs[i];
		if(box.checked) { cks[cks.length] = box.value; }
	}
	var adcansearch = cks.join("|");
	var fail = false;
	if($ID("fromid").value=="") { $ID("fromid_msg").innerHTML ="请选择要继承的报表模板"; fail = true; } else{ $ID("fromid_msg").innerHTML =""; }
	if($ID("title").value.trim()=="") { $ID("title_msg").innerHTML ="请输入报表名称"; fail = true; } else{ $ID("title_msg").innerHTML =""; }
	if($ID("colfields").value=="") { $ID("colfields_msg").innerHTML ="请选择横坐标"; fail = true; } else{ $ID("colfields_msg").innerHTML =""; }
	if($ID("rowfields").value=="") { $ID("rowfields_msg").innerHTML ="请选择纵坐标"; fail = true; } else{ $ID("rowfields_msg").innerHTML =""; }

	if( fail==true ) { return ; }

	ajax.regEvent("dosave");
	ajax.addParam("title", $ID("title").value);
	ajax.addParam("menuid", $ID("menuid").value);
	ajax.addParam("addtype",($ID("rtype1").checked ? "1" : "0"));
	ajax.addParam("fromid", $ID("fromid").value);
	ajax.addParam("basefromid",$ID("basefromid").value);
	ajax.addParam("pagecount",$ID("pagecount").value);
	ajax.addParam("canprint",$ID("canprint").checked ? "1" : "0");
	ajax.addParam("canexcel",$ID("canexcel").checked ? "1" : "0");
	ajax.addParam("colkey",col.fkey);
	ajax.addParam("coltype",col.ftype);
	ajax.addParam("colsort",col.fsort);
	ajax.addParam("coldata",col.data);
	ajax.addParam("rowkey",row.fkey);
	ajax.addParam("rowtype",row.ftype);
	ajax.addParam("rowsort",row.fsort);
	ajax.addParam("rowdata",row.data);
	ajax.addParam("cansearch", cansearch);
	ajax.addParam("canadsearch", adcansearch);
	ajax.addParam("isTemp", isTemp ? "1" : "0");
	ajax.exec();
}

//设置报表的继承模版
function setReportModel(id) {
	if(id=="") {return;}
	if(id < 0) {
		$ID("rtype1").checked = true;
		$ID("rtype1").disabled = true;
		$ID("rtype2").disabled = true;
	}
	else{
		$ID("rtype1").disabled = false;
		$ID("rtype2").disabled = false;
	}
	$ID("title").value = $ID("fromid").options[ $ID("fromid").selectedIndex].text;
	ajax.regEvent("setReportModel");
	ajax.addParam("ModelId", id);
	var r = ajax.send();
	try
	{
		window.currModelObject = eval("var o = " + r + ";o");
		var obj  = window.currModelObject;
	}
	catch (e)
	{
		alert(r);
		return;
	}

	var colkey = obj.colfields;
	var rowkey = obj.rowfields;
	var clscolkey = obj.clscolfields;
	var clsrowkey = obj.clsrowfields;
	var ftcol = "";
	var ftrow = "";
	var colhtml = "<select onchange='fieldschange(this, 0)' id='colfields'><option value=''>==选择横坐标==</option>"
	for (var i = 0; i < obj.basecols.length ; i ++ )
	{
		var c = obj.basecols[i];
		if(c.cx==1 && c.k!=clsrowkey && c.clsk !=clsrowkey) {
			colhtml = colhtml + "<option value='" + c.k + "'>" + c.n + "</option>";
		}
		
		if(c.k==rowkey) { ftrow = c.ft; }
		if(c.k==colkey) { ftcol = c.ft; }
	}
	colhtml = colhtml + "</select>"
	
	var rowhtml = "<select onchange='fieldschange(this, 1)' id='rowfields'><option value=''>==选择纵坐标==</option>"
	for (var i = 0; i < obj.basecols.length ; i ++ )
	{
		var c = obj.basecols[i];
		if(c.cy==1 && c.k!=clscolkey && c.clsk!=clscolkey) {
			rowhtml = rowhtml + "<option value='" + c.k + "'>" + c.n + "</option>";
		}
	}
	rowhtml = rowhtml + "</select>"
	document.getElementById("pagecount").value = obj.pagecount;
	document.getElementById("canprintdiv").style.display = obj.printpower ? "" : "none";
	document.getElementById("canexceldiv").style.display = obj.excelpower ? "" : "none";
	document.getElementById("canprint").checked = (obj.canprint == 1);
	document.getElementById("canexcel").checked = (obj.canexcel == 1);
	document.getElementById("basefromid").value = obj.basefromid;
	document.getElementById("colfieldsdiv").innerHTML = colhtml;
	document.getElementById("rowfieldsdiv").innerHTML = rowhtml;

	var colbox = document.getElementById("colfields");
	var rowbox = document.getElementById("rowfields");
	colbox.setAttribute("clskey", clscolkey);
	rowbox.setAttribute("clskey", clsrowkey);
	colbox.setAttribute("ftype", ftcol);
	rowbox.setAttribute("ftype", ftrow);
	colbox.value = colkey;
	rowbox.value = rowkey;

	app.fireEvent(document.getElementById("colfields"),"onchange");
	app.fireEvent(document.getElementById("rowfields"),"onchange");
	
	setTimeout(function() {
		loadFieldInitData("colfields", ftcol, obj.coldata);
		obj.coldata = "";
		loadFieldInitData("rowfields", ftrow, obj.rowdata);
		obj.rowdata = "";
	},100);
	//createSearchField();
}

function fieldschange(sbox, t) {
	var skey = sbox.value;
	var clsskey = skey;
	var id = (t == 0 ? "rowfields" : "colfields"); //0表示横坐标改变， 1表示纵坐标改变
	var box = document.getElementById(id);
	var currkey = box.value;  
	var currft = box.getAttribute("ftype");
	var currclskey = box.getAttribute("clskey");
	var obj = window.currModelObject;
	var ft = "";
	var html = "<select onchange='fieldschange(this," + (t==0 ? "1" : "0") + ")' id='" + id + "'><option value=''>==选择" + (t==0 ? "纵" : "横") + "坐标==</option>"
	for (var i = 0; i < obj.basecols.length ; i ++ )
	{
		var c = obj.basecols[i];
		if(c.k == skey) {
			clsskey = c.clsk;
			ft = c.ft;
			break;
		}
	}
	box = document.getElementById((t != 0 ? "rowfields" : "colfields"));
	box.setAttribute("clskey", clsskey);
	box.setAttribute("ftype", ft);
	for (var i = 0; i < obj.basecols.length ; i ++ )
	{
		var c = obj.basecols[i];
		if(t==0) {  //当横坐标改变，则生成纵坐标
			if(c.cy==1 && c.k!=clsskey && c.clsk!=clsskey) {
				html = html + "<option value='" + c.k + "'>" + c.n + "</option>";
			}
		}
		else{
			if(c.cx==1 && c.k!=clsskey && c.clsk!=clsskey) {
				html = html + "<option value='" + c.k + "'>" + c.n + "</option>";
			}
		}
	}
	html = html + "</select>"
	document.getElementById(id + "div").innerHTML = html;
	document.getElementById(id).value = currkey;
	box = document.getElementById((t == 0 ? "rowfields" : "colfields"));
	box.setAttribute("clskey", currclskey);
	box.setAttribute("ftype", currft);

	ajax.regEvent("showFieldData");
	ajax.addParam("basefromid", obj.basefromid);
	ajax.addParam("fkey", skey);
	var r = ajax.send();
	document.getElementById(sbox.id + "data").innerHTML = r;
	createSearchField();
}

//初始化字段数据
function loadFieldInitData(id, ftype, fdata) {
	var div = document.getElementById(id + "data");
	switch(ftype){
		case "gates":
			loadgateinitdata(div, fdata);
			break;
		case "gategroup":
			loadgateinitdata(div, fdata);
			break;
		case "telcls":
			loadtelclsinitdata(div, fdata);
			break;
		default:
			loadcheckdata(div, fdata)
			break;
	}
}

function loadcheckdata(div, fdata) { 
	var d1 = fdata.split(",")
	var im = div.getElementsByTagName("input");
	for (var i = 0; i < im.length ; i ++ )
	{
		var box = im[i];
		var nm = box.type.toLowerCase();
		if(nm=="checkbox") {
			box.checked = ArrayExist(d1, box.value);
		}
	}
}

function loadtelclsinitdata(div, fdata) {
	var dat = (fdata + "||").split("|");
	var d1 = dat[0].split(",");
	var d2 = dat[1].split(",");
	var im = div.getElementsByTagName("input");
	for (var i = 0; i < im.length ; i ++ )
	{
		var box = im[i];
		var nm = box.name.toLowerCase();
		switch(nm) {
			case "e":
				box.checked = ArrayExist(d1, box.value);
				break;
			case "f":
				box.checked = ArrayExist(d2, box.value);
				break;
		}
	}
}

function loadgateinitdata(div, fdata) {
	var dat = (fdata + "|||").split("|");
	var d1 = dat[0].split(",");
	var d2 = dat[1].split(",");
	var d3 = dat[2].split(",");
	var im = div.getElementsByTagName("input");
	for (var i = 0; i < im.length ; i ++ )
	{
		var box = im[i];
		var nm = box.name.toLowerCase();
		switch(nm) {
			case "w1":
				box.checked = ArrayExist(d1, box.value);
				break;
			case "w2":
				box.checked = ArrayExist(d2, box.value);
				break;
			case "w3":
				box.checked = ArrayExist(d3, box.value);
				break;
		}
	}
}

function createSearchField() {
	var obj = window.currModelObject;
	var csearch =  obj.cansearch.split("|");
	var cadsearch = obj.canadsearch.split("|");
	var rowkey = document.getElementById("rowfields").value;
	var colkey = document.getElementById("colfields").value;
	var htmlcs = "";
	var adhtmlcs = "";
	var cked = ""
	for (var i = 0; i < obj.basecols.length ; i++ )
	{
		var c = obj.basecols[i];
		if(c.cs==1 && c.k!=colkey && !ArrayExist(cadsearch, c.k)) {
			 cked = ArrayExist(csearch, c.k) ? "checked" : "";
			 htmlcs =  htmlcs + "<input onclick='searchfChecked()' type=checkbox name='csf' " + cked + " id='csf" + i + "' value='" + c.k + "'><label for='csf" + i + "'>" + c.n + "</label>&nbsp;"
		}
	}
	for (var i = 0; i < obj.basecols.length ; i++ )
	{
		var c = obj.basecols[i];
		if(c.cas==1 && c.k!=colkey && !ArrayExist(csearch, c.k)) {
			 cked = ArrayExist(cadsearch, c.k) ? "checked" : "";
			 adhtmlcs =  adhtmlcs + "<input onclick='searchfChecked()' type=checkbox name='adcsf' " + cked + " id='adcsf" + i + "' value='" + c.k + "'><label for='adcsf" + i + "'>" + c.n + "</label>&nbsp;"
		}
	}
	document.getElementById("searchfields").innerHTML = htmlcs;
	document.getElementById("adsearchfields").innerHTML = adhtmlcs;
}

function searchfChecked() 
{
	var elms = document.getElementsByName("csf");
	var vs1 = new Array();
	for (var i = 0; i < elms.length ; i ++ )
	{
		if(elms[i].checked==true) {
			vs1[vs1.length] = elms[i].value;
		}
	}
	
	elms = document.getElementsByName("adcsf");
	var vs2 = new Array();
	for (var i = 0; i < elms.length ; i ++ )
	{
		if(elms[i].checked==true) {
			vs2[vs2.length] = elms[i].value;
		}
	}
	var obj = window.currModelObject;
	obj.cansearch = vs1.join("|");
	obj.canadsearch = vs2.join("|");
	createSearchField()
}