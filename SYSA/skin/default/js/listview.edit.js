
app.lvweditor = new Object();

//根据传递的对象获取html对象ID
app.lvweditor.getHtmlId = function(e) {
	if(typeof(e)=="string") { return e; }
	var pobj =  e.parentNode;
	while(pobj) {
		pobj = pobj.parentNode;
		if(pobj.tagName=="DIV") {
			if(pobj.className=="listview") {
				return pobj.id.replace("lvw_", "");
			}
		}
	}
	return null;
}

//根据传递对象，获取当前操作行
app.lvweditor.getCurrHtmlRow = function(e) {
	var pobj =  e.parentNode;
	while(pobj) {
		pobj = pobj.parentNode;
		if(pobj.tagName=="TR") {
			if(pobj.getAttribute("l_r")==1) {
				return pobj;
				break;
			}
		}
	}
	return null;
}

//根据传递对象，获取当前操作单元格
app.lvweditor.getCurrHtmlCell = function(e) {
	var pobj =  e.parentNode;
	while(pobj) {
		pobj = pobj.parentNode;
		if(pobj.tagName=="TD") {
			if(pobj.className.indexOf("lvw_cell")==0) {
				return pobj;
				break;
			}
		}
	}
	return null;
}

app.lvweditor.__U_Cing = false;
app.lvweditor.__U_C = function(e) {
	var ename = window.event?window.event.propertyName:"value";
	var exc = "";
	if(ename=="value" || ename =="checked") {
		if(app.lvweditor.__U_Cing == false) {
			app.lvweditor.__U_Cing = true;
		}
		else{
			return;
		}
		var lvwid = app.lvweditor.getHtmlId(e);
		var tb = $ID("lvw_dbtable_" + lvwid);
		var cols = app.lvweditor.getcoldatas(lvwid);
		var currRow = app.lvweditor.getCurrHtmlRow(e);
		var currCell =  app.lvweditor.getCurrHtmlCell(e);
		var lastheader = tb.getAttribute("maxheads")
		var HeaderRows = tb.rows[lastheader*1-1];
		var currvalues = new Array();
		for (var i = 0; i < currRow.cells.length ; i++)
		{
			var td = currRow.cells[i];
			var th = HeaderRows.cells[i];
			var tbs = td.getElementsByTagName("table");
			if(td==currCell) {
				exc = th.getAttribute("eonchange");
			}
			if(tbs.length>0) { 
				var cell = tbs[0].rows[0].cells[0]; 
				if(!bill.getCellValue) {
					app.Alert("列表onchange事件执行失败： 由于未引用billpage.js文件, 所以无法执行行动态更新操作。")
					return;
				}
				currvalues[currvalues.length] = th.getAttribute("dbname") + "\2\1"  + bill.getCellValue(cell, true);
			}
			else {
				currvalues[currvalues.length] = th.getAttribute("dbname") + "\2\1";
			}
		}
		var lvw = new Listview(lvwid);
		lvw.beginCallBack("EditRowOnChange");
		ajax.addParam("cols", cols);
		ajax.addParam("currvalues", currvalues.join("\1\4"));
		if(window.onListViewRowUpdate) {
			window.onListViewRowUpdate(lvwid)
		}
		ajax.addParam("value", e.value);
		ajax.addParam("exc", exc);
		var data = ajax.send();
		lvw = null;
		var div = document.createElement("div");
		div.innerHTML = "<table>" + data + "</table>";
		var tr = div.getElementsByTagName("tr")[0];
		var tbody = $ID("lvw_tby_" + lvwid);
		tbody.appendChild(tr);
		currRow.swapNode(tr);
		tbody.removeChild(currRow);
		app.lvweditor.__U_Cing = false;
		__lvw_editor_updateRefresh(lvwid);
	}
}

app.lvweditor.getcoldatas = function(lvwid, newData) {
	var cols = $ID("lvw_tby_" + lvwid).getAttribute("coldatas") ;
	if (newData != undefined)
	{
		if (newData.length>0)
		{
			var colsArr = cols.split("\1");
			var cellArr 
			var newDataArr = newData.split("\1\2");
			var newcols = "";
			for (var i = 0; i< colsArr.length && colsArr.length == newDataArr.length ; i ++  )
			{
				cellArr = colsArr[i].split("\2");
				if (cellArr.length = 2)
				{
					if (newDataArr[i].length>1)
					{
						cellArr[2] = newDataArr[i].substring(1,newDataArr[i].length-1);
					}
					else
					{
						cellArr[2] = newDataArr[i];
					}
					
				}
				if (newcols.length>0)
				{
					newcols = newcols + "\1" ;
				}
				newcols = newcols + cellArr.join("\2");
			}
			cols = newcols;
		}
	}
	return cols;
}

//添加或插入新行
app.lvweditor.insertRow = function(e, insertModel, newData) {
	var lvwid = app.lvweditor.getHtmlId(e);
	var cols = app.lvweditor.getcoldatas(lvwid, newData);
	var lvw = new Listview(lvwid);
	var tb = $ID("lvw_dbtable_" + lvwid);
	var tbody =  $ID("lvw_tby_" + lvwid);
	var sumr = tbody.getAttribute("sumr");
	var maxh = tb.getAttribute("maxheads");
	var rowindex = (e.tagName == "A" ? 
					tb.rows.length - sumr - maxh + 1 - (tb.rows[tb.rows.length-1].cells[0].className=="lvw_cell nulldata" ? 1 : 0)
					:app.lvweditor.getCurrHtmlRow(e).rowIndex - maxh + 1
					);
	lvw.beginCallBack("GetNullRowHTML");
	ajax.addParam("cols",cols);
	ajax.addParam("_insert_rowindex",rowindex);
	var data = ajax.send();
	lvw = null;
	var div = document.createElement("div");
	div.innerHTML = "<table>" + data + "</table>";
	var tr = div.getElementsByTagName("tr")[0];
	tbody = $ID("lvw_tby_" + lvwid);
	
	var sumr = tbody.innerHTML.indexOf("lvw_cell nulldata") ==-1 ? tbody.getAttribute("sumr") : 0;
	//删除空行
	try{
		var ntd = tbody.rows[1].cells[0]
		if (ntd !=undefined)
		{	
			if(ntd.className=="lvw_cell nulldata") {
				tbody.deleteRow(1);
			}
		}
	}catch(ex){}
	
	beforerow = null;

	if (insertModel==0)
	{	
		if(sumr>0) { beforerow = tbody.rows[tbody.rows.length-sumr]; } //结尾添加行
	}
	else{
		beforerow = app.lvweditor.getCurrHtmlRow(e); //中间插入行
	}
	if(beforerow==null)
	{
		tbody.appendChild(tr);
	}
	else{
		tbody.insertBefore(tr,beforerow);
	}
	//document.write (data);
	__lvw_editor_updateRefresh(lvwid);
}


//删除行
app.lvweditor.deleteRow = function(e) {
	var lvwid = app.lvweditor.getHtmlId(e);
	var row = app.lvweditor.getCurrHtmlRow(e);
	if(row) {
		row.parentNode.removeChild(row);
		__lvw_editor_updateRefresh(lvwid);
	}
}

//移动行
app.lvweditor.moveRow = function(e, movepos) {
	var lvwid = app.lvweditor.getHtmlId(e);
	var row = app.lvweditor.getCurrHtmlRow(e);
	var nextrow = (movepos==-1 ? row.previousSibling : row.nextSibling );
	if (nextrow!=null)
	{
		if(nextrow.getAttribute("l_r")==1) {
			nextrow.swapNode(row);
			__lvw_editor_updateRefresh(lvwid);
		}
	}
}

//刷新列表状态，如求和，维护序号，记录条数，翻页状态等等
function __lvw_editor_updateRefresh(lvwid) {
	//1.维护行号
	var tbody =  $ID("lvw_tby_" + lvwid);
	var startpos = tbody.getAttribute("startpos");
	var rowindex = startpos;
	if(tbody.getAttribute("indexbox")==1) {
		for (var i = 0 ; i < tbody.rows.length ; i++ )
		{
			var tr = tbody.rows[i];
			if(tr.getAttribute("l_r")==1) {
				tr.cells[0].innerHTML = rowindex;
				rowindex ++;
			}
		}
	}
}