var lvw  = { //listview基本操作
	NextKeyAdd : true , //是否按下一个键自动添加行
	sBoxSpr : "^tag~" , //用于分隔下拉框
	lvwsort : "" ,
	deleteRow : function(span){
		var tr = span.parentElement.parentElement
		var tb = tr.parentElement.parentElement;
		var div = tb.parentElement;
		lvw.TryCreateHiddenPageDataToArray(div)
		var autoindex = (div.autoindex == "1"); 
		var checkbox = (div.checkbox == "1");
		var autosum = (div.autosum == "1");
		var delalert = (div.delalert == "1");
		if (delalert)
		{
			if(!window.confirm("您确定要删除该行数据吗？")){
				return false;
			}
		}
		var rIndex = lvw.getDataRowIndexByTR(tr)
		div.hdataArray.splice(rIndex,1)
		if(div.autosum=="1"){
			var hRow = tb.rows[0];
			for (var i=0;i<hRow.cells.length ;i++ )
			{
				if(hRow.cells[i].dtype=="number" && hRow.cells[i].selid.length ==0)
				{
					lvw.updateColSum(div,i);
				}
			}
		}
		lvw.Refresh(div)
		lvw.UpdateScrollBar(div);
		lvw.updateRowCountText(div);
        if(lvw.ondeleteRow) {lvw.ondeleteRow(div);}
	}
	,
	RowMouseOut : function(row){
		row.style.backgroundColor = "transparent";
	}
	,
	RowMouseOver : function(row){
		row.style.backgroundColor = "#EFEFEF";
	}
	,
	setcheckvalue : function (cBox) {
		var tr = window.getParent(cBox,3)
		var div = window.getParent(tr,3)
		lvw.TryCreateHiddenPageDataToArray(div)
		var sIndex = div.getAttribute("PageStartIndex")*1 + tr.rowIndex - 2 //起点位置
		div.hdataArray[sIndex][1] =  cBox.checked?1:0;
	}
	,
	deleteSelectRow : function (div){ //删除选中行
		lvw.TryCreateHiddenPageDataToArray(div)
		var ii = 0
		var nArray = new Array()
		for (var i = 0; i < div.hdataArray.length ; i++)
		{
			if (div.hdataArray[i][1]!="1")
			{
				nArray[ii] = div.hdataArray[i] 
				ii = ii + 1
		
			}
		}
		div.hdataArray = nArray;
		lvw.Refresh(div);
		lvw.UpdateScrollBar(div);
        lvw.Refresh(div);
        if(lvw.ondeleteRow) {lvw.ondeleteRow(div);}
	}
	,
	getCellselBoxValueByText : function(cell, v) {	//根据界面输入的值（注意，不是内部传递的），获取对的选择形式值 "xx" + lvw.sBoxSpr + "xxx" 的形式
		var defname = v , defvalue = "";
		var cIndex = lvw.cellIndex(cell)
		var tb = window.getParent(cell,3)
		var head = tb.rows[0].cells[cIndex]
		if(!head.sboxArrays && head.sboxArray){ //数组变量,js对象
			if(head.sboxArray.length>0)  //数组文本 ,服务端输出
			{
				head.sboxArrays = head.sboxArray.split("|")
				for (var i=0;i<head.sboxArrays.length;i++ )
				{
					head.sboxArrays[i] = head.sboxArrays[i].split("=")
				}
			}
		}
		if(head.sboxArrays){
			for (var i=0;i<head.sboxArrays.length;i++)
			{
				if(v==head.sboxArrays[i][0]){
					defvalue =  head.sboxArrays[i][1]
					defname = v
					break;
				}
			}
		}
		return {name:defname,value:defvalue}
		
	} 
	,
	getCellselBoxValue : function(cell, v) {	//根据界面输入的值（注意，不是内部传递的），获取对的选择形式值 "xx" + lvw.sBoxSpr + "xxx" 的形式
		var defname = v , defvalue = "";
		var cIndex = lvw.cellIndex(cell)
		var tb = window.getParent(cell,3)
		var head = tb.rows[0].cells[cIndex]
		if(!head.sboxArrays && head.sboxArray){ //数组变量,js对象
			if(head.sboxArray.length>0)  //数组文本 ,服务端输出
			{
				head.sboxArrays = head.sboxArray.split("|")
				for (var i=0;i<head.sboxArrays.length;i++ )
				{
					head.sboxArrays[i] = head.sboxArrays[i].split("=")
				}
			}
		}
		if(head.sboxArrays){
			for (var i=0;i<head.sboxArrays.length;i++)
			{
				if(v==head.sboxArrays[i][1]){
					defvalue = v
					defname = head.sboxArrays[i][0]
					break;
				}
			}
		}
		return {name:defname,value:defvalue}
	} 
	,
	setCellValue : function(cell,value){
		if(!value && isNaN(value)) { value = "" ; }

		value = (value + "").split(lvw.sBoxSpr)
		if(cell.children.length>0){
			if( cell.children[0].tagName=="TABLE"){  //checkbox
				var cellBody  = cell.children[0].rows[0].cells[0]
				if(cellBody.children.length>0 && (cellBody.children[0].tagName=="INPUT" || cellBody.children[0].tagName=="TEXTAREA")){
					var nv = value[0];
					var oldv = cellBody.children[0].value;
					var nodiff = false;
					if(!isNaN(nv) && !isNaN(oldv)) {
						if(nv*1==oldv*1) {
							nodiff = true;
						}
					}
					if(nodiff==false) {
						cellBody.children[0].value = value[0];
					}
					if(value.length>1) { cellBody.children[0].title = value[1] }
					else{cellBody.children[0].title = ""}
			
				}
				else{
					cellBody.innerHTML = value[0].replace(/#；/g,";");
					if(value.length>1) { cellBody.title = value[1] }
					else{cellBody.title = ""}
				}
			}
			else{
				
				var inputs = cell.getElementsByTagName("INPUT")
				if(inputs.length==1){
					if(inputs[0].type=="checkbox") {
						inputs[0].checked = (value[0]*1 > 0 )? true : false;
						return;
					}
				}
				cell.innerHTML = value[0];
			}
		}
	}
	,
	IsRepeatRow : function(div,TestRowIndex){ //比较查看是否有重复的列,并删除
		if(!TestRowIndex) {TestRowIndex = div.hdataArray.length - 1;}
		var testRow = div.hdataArray[TestRowIndex]
		for (var i=0;i<div.hdataArray.length ; i++)
		{
			if(i!=TestRowIndex && testRow.toString()==div.hdataArray[i].toString()){
				
				return i+1;
			}
		}
		return 0;
	}
	,
	setRowValue : function(row,datArray,repeat) {
		var tb = row.parentElement.parentElement;
		var head = tb.rows[0];
		var  ii = 0
		for (var i = 0; i < row.cells.length ; i ++ )
		{
			if(head.cells[i].dtype?true:false){
				lvw.setCellValue(row.cells[i],datArray[ii])
				ii ++
			}
		}

		var div = tb.parentElement;
		var autoindex = div.autoindex=="1"?1:0
		var autosum = div.autosum == "1" ? 1 : 0
		lvw.TryCreateHiddenPageDataToArray(div)
		var sindex = div.getAttribute("PageStartIndex")*1 + row.rowIndex * 1 - 2;
		if(!div.hdataArray[sindex]){
			div.hdataArray[sindex] = new Array()
			for (var i= autoindex ; i < row.cells.length-1. ; i ++ )
			{
				div.hdataArray[sindex][i+1-autoindex] = lvw.getCellValue(row.cells[i])
			}
		}
	}
	,
	TryCreateHiddenPageDataToArray : function(div, mustdo){ //创建隐藏数据的数组,所有操作针对数据，然后根据页数定义显示
		if(!div){
			//alert(" 实现 TryCreateHiddenPageDataToArray 方法 ，需要传递正确的 div 值。")
			return;
		}
		
		if(!div.hdataArray || (mustdo == true && div.hdataArray.length==0)) {
			var id = div.id.replace("listview_","ctl_listview_spd_")
			var hInput = document.getElementById(id)
			if(!hInput) {return false}
			if (mustdo == true && hInput.value.length==0)
			{
				//在非编辑模式下获取数据，提交服务器，用编辑模式，返回隐藏数据 2013.09.12 binary
				ajax.regEvent("sys_ListView_CallBack");
				ajax.addParam("orderid",$("#orderid").val());
				ajax.addParam("State",div.state);
				ajax.addParam("cmdtxt","GetHiddeData");
				var r = ajax.send();
				hInput.value = r;
			}
			div.hdataArray = hInput.value.replace(/\$＜/g,"<").replace(/\$＞/g,">").split("|")
			for (var i= div.hdataArray.length-1 ;i>=0 ;i-- )
			{
				if(div.hdataArray[i].length==0){
					div.hdataArray.splice(i,1)
				}
				else{
					div.hdataArray[i] = div.hdataArray[i].split(";")
				}
			}
		}
		
		if(!div.getAttribute("PageStartIndex")){
			div.setAttribute("PageStartIndex", 1)  //默认起点为1
			div.PageEndIndex = div.hdataArray.length > div.getAttribute("PageSize") ? div.getAttribute("PageSize") : div.hdataArray.length 
		}
	}
	,
	getcelldata : function(td){
		var v = this.getCellValue(td).split(lvw.sBoxSpr);
		if(v.length==1) {return v[0]}
		else if(v.length==2){return v[1].length>0 ? v[1] : v[0];}
		else{return "";}
	}
	,
	getCellValue : function(td){ //返回一个单元格的值
		if (td.innerHTML.indexOf(">删除<")>0 && td.innerHTML.toLowerCase().indexOf("nowrap")>0)
		{
			return "";
		}
		if(td.children.length>0 && td.children[0].tagName =="TABLE") {
			var cellBody = td.children[0].rows[0].cells[0]
			var element = cellBody.children[0];
			if(cellBody.children.length>0 && (element.tagName=="INPUT" ||  element.tagName=="TEXTAREA" )) {
				return  element.value + ( element.title.length > 0 ?  (lvw.sBoxSpr + element.title) : "")
			}
			else{
				return cellBody.innerHTML + (cellBody.title.length > 0 ?  (lvw.sBoxSpr + cellBody.title) : "")
			}
		}
		else{
			if(td.children.length>0 && td.children[0].tagName=="SPAN") {
				var span = td.children[0]
				if(span.children.length>0  && span.children[0].tagName=="INPUT" && span.children[0].type=="checkbox"){
					return span.children[0].checked*1
				}
				else{
					return td.innerHTML;
				}
			}
			else{
				return td.innerHTML;
			}
		}
	}
	,
	getnewRowDataFromNullData : function(div){ //获取空行数据
		var arr = new Array()
		var nullRowDiv = div.children[2]
		if(!nullRowDiv){
			//不允许添加
			return false
		}
		var lastRow = nullRowDiv.children[0].rows[0].cloneNode(true)
		var sIndex = 0
		if(div.autoindex){sIndex ++}
		var ii = 0
		for (var i=sIndex;i<lastRow.children.length ;i++ )
		{
			
			arr[ii] = lvw.getCellValue(lastRow.children[ii])
			ii = ii + 1
		}
		return arr
	}
	,
	MoveRowShow : function(div,sIndex,eIndex,callback){
		var aindex = div.autoindex == "1"
		var autosum = div.autosum == "1" ? true : false
		var iii , aiii = aindex? 1 : 0 , cdel = div.candel=="1" ? 1:0
		var tb = div.children[0]
		var ii = 0
		var willdelrow = new Array()
		var nullRowDiv = div.children[2]
		for (var i = sIndex; i<=eIndex; i ++)
		{
			ii= ii + 1
			var tr = tb.rows[ii]
			var cell = div.hdataArray[i-1];
			if(cell) {
					if(( !autosum && tr ) || (tr && tr.nextSibling)){
						if(aindex){tr.cells[0].innerText = i}
						for (var iii=aiii ; iii < tr.cells.length-cdel ; iii ++ )
						{
							lvw.setCellValue(tr.cells[iii],cell[iii-aiii+1]) //+1是应为数组第1列为空值
						} 
					}
					else
					{ //没有则创建行以显示
					    tr = nullRowDiv.children[0].rows[0].cloneNode(true);
					    tr.id = "";
							tb.tBodies[0].appendChild(tr);
							if(autosum) { //如果有合计，则需要和合计调换位置
								tr.swapNode(tb.rows[tb.rows.length-2]);
							}
							if(aindex){tr.cells[0].innerText = i}
							for (var iii=aiii ; iii < tr.cells.length-cdel ; iii ++ )
							{
								lvw.setCellValue(tr.cells[iii],cell[iii-aiii+1]) //+1是应为数组第1列为空值
							}
								
					}
					
			}
			else{
				if(tr && tr.cells[0].innerText !="合计"){
					willdelrow[willdelrow.length] = tr.rowIndex
				}
			}

		}
		

		for (var i=ii*1 + 1;i< tb.rows.length - autosum ; i ++ ) // 删除多余的
		{
			willdelrow[willdelrow.length] = i
		}
		if(willdelrow.length>0){
			for (var i = willdelrow.length; i > 0; i -- )
			{
				tb.deleteRow(willdelrow[i-1])
			}
			div.setAttribute("PageStartIndex", 1)
			div.PageEndIndex = willdelrow[0] - 1
			if(div.getAttribute("PageStartIndex") - div.PageEndIndex  >0 ) {
				div.setAttribute("PageStartIndex", 0);
			}
			if(!callback){
				return lvw.MoveRowShow(div,sIndex,eIndex,true) //重新生成一次
			}
		}
			//alert(tr.innerText)
		return tr
	}
	,
	addRowPageHand : function(div){ //向数组中添加一行数据

		var tb = div.children[0]
		if(tb.canadd=="0"){
			return null
		}
		lvw.TryCreateHiddenPageDataToArray(div);//尝试创建隐藏数据的数组
		var dSize = div.hdataArray.length
		if(window.event && window.event.srcElement && window.event.srcElement.innerText == "添加新行")
		{
			//当点击添加行时，直接往最尾部移动
			var eIndex = dSize + 1;				//截止位置
			var sIndex = eIndex - div.getAttribute("PageSize") + 1	//起点位置
			if(sIndex<1) {sIndex = 1}
			var ShowRow = eIndex - sIndex + 1	//要显示的行数
		}
		else
		{
			var eIndex = div.PageEndIndex*1 + 1; //截止位置
			var sIndex = div.getAttribute("PageStartIndex")*1 + 1*1 //起点位置
			var ShowRow = eIndex - sIndex + 1 //要显示的行数
			if(  ShowRow < div.getAttribute("PageSize")*1 ) {sIndex = sIndex - 1;}
			
		}
		//alert("B--" + sIndex + "--" + eIndex + '--' + div.getAttribute("PageSize"))

		if (ShowRow> div.getAttribute("PageSize")*1)
		{eIndex = sIndex*1 + div.getAttribute("PageSize")*1 - 1;}

		div.setAttribute("PageStartIndex", sIndex);
		div.PageEndIndex = eIndex;
		for (var i=dSize ; i < eIndex ; i ++){ //如果没有超出范围，则进行分页下移
			div.hdataArray[i] = lvw.getnewRowDataFromNullData(div); //添加新行数据
		}
		return lvw.MoveRowShow(div,sIndex,eIndex)
		
	}
	,
	updateRowCountText : function(div){
		var id = div.id.replace("listview_","lvw_RowCount_B")			//显示行数
		document.getElementById(id).innerText = div.hdataArray.length
	}
	,
	addRow : function(tb,focusindex,onlyadd){ //插入新行
		var basediv = tb.parentElement;

		var lastRow =  lvw.addRowPageHand(basediv) //尝试移动

		if(!lastRow){return null}
		if(onlyadd){
			return lastRow ; 
		}
		if(!lastRow) { return false; }
		if (!focusindex) {
			var Heads = tb.rows[0]
			for(var i = 0 ; i < Heads.cells.length ; i ++) {
				if (Heads.cells[i].edit == "1"){focusindex = i;break;}
			}
		}
		var td = lastRow.cells[focusindex];
		lvw.editfocus(td);
		if(tb.currFocusInput) {
			tb.currFocusInput.focus();
			tb.currFocusInput.select();
		}
		lvw.updateRowCountText(basediv);
		//var  row = basediv.children[0].rows.length - basediv.autosum*1 - 1
		return lastRow;
	}
	,
	mousedown : function(tb) { //鼠标事件
		var em = window.event.srcElement;
		if(window.event.button<=1){
			switch(em.tagName)
			{
				case "TD":
						lvw.editfocus(em);
					break;
				default:
					break;
			}
		}
	}
	,//---------------------------------------------------------------------------
	Sum : function(div){	//求和
		if(div.autosum=="1"){
			var HRow = div.children[0].rows[0];
			for(var i=1;i<HRow.cells.length;i++){
				var td= HRow.cells[i]
				if(td.dtype=="number" && td.selid.length==0 && td.innerText.indexOf("单价")<0 ){
					lvw.updateColSum(div,i)
				}
			}
		}	
	}
	,
	clear : function(div){
		div.setAttribute("PageStartIndex", 1);
		div.PageEndIndex  = 1;
		div.hdataArray = new Array();
		lvw.Refresh(div);
		lvw.UpdateScrollBar(div);
	}
	,
	Refresh : function(div) // 刷新整个表格
	{

		lvw.TryCreateHiddenPageDataToArray(div);
		var tb = div.children[0];
		var autosum = (div.autosum == "1") ? 1 : 0;
		var pageSize = div.getAttribute("PageSize");		 //页面显示大小
		var pageStart = div.getAttribute("PageStartIndex");  //显示起点
		var ArrayLen = div.hdataArray.length;//数组行数
		var MaxRow = pageStart*1 + pageSize*1 - 1;
		var nullRowDiv = div.children[2]
		var rIndex = 0
		var visCount =  0 
		var visCount2 = div.PageEndIndex - div.getAttribute("PageStartIndex") + 1 ;

		MaxRow = MaxRow > ArrayLen ?  ArrayLen : MaxRow ;
		if((MaxRow - pageStart + 1) < pageSize &&  pageStart*1 > 1) { //在删除的情况下，可能是行数不够显示,此处判断,自动移动起点位置
			pageStart =  MaxRow- pageSize  + 1
			pageStart =  pageStart < 1 ? 1 : pageStart
			div.setAttribute("PageStartIndex",pageStart);
		}

		
		for (var i = pageStart; i <= MaxRow ; i ++ )
		{
			rIndex = i- pageStart + 1; 
			var tr = tb.rows[rIndex];
			//------需要显示的情况下则创建新行-------------------
			if(!tr){
				tr = nullRowDiv.children[0].rows[0].cloneNode(true)
				tb.tBodies[0].appendChild(tr);
				visCount2 ++
				
			}
			else{
				if(tr.className=="lvwautosum") { //如果是求和行
					tr = nullRowDiv.children[0].rows[0].cloneNode(true)
					tb.tBodies[0].appendChild(tr);
					tr.swapNode(tb.rows[tb.rows.length-2]);
					visCount2 ++
				}	
			}
		
			lvw.RefreshRow (tr)
			lvw.setBgColorApply(tb,tr);
			
			visCount ++ ;
		}
		
		var showRow =  rIndex*1 + 1 + autosum*1; //应该显示的行
		while (tb.rows.length >showRow){tb.deleteRow(tb.rows.length-autosum-1);visCount --;visCount2--} //删除多余行
		lvw.Sum(div);
		try{
			document.getElementById(div.id.replace("listview_","ctl_listview_spd_")).value = div.hdataArray.length;
			document.getElementById(div.id.replace("listview_","lvw_RowCount_B")).innerText = div.hdataArray.length;
		}catch(e){}
		div.PageEndIndex = pageStart*1 + visCount2 -1; 
		if(div.PageEndIndex<0){
			div.PageEndIndex = 0;
		}

	}
	,
	RefreshRow : function(TRow) {// 刷新行
		var div = window.getParent(TRow,3)
		var autoindex = (div.getAttribute("autoindex") == "1") ? 1 : 0;
		var rIndex = lvw.getDataRowIndexByTR(TRow);
		var DataRow = div.hdataArray[rIndex];
		if(typeof(DataRow)=="undefined"){DataRow = new Array()}
		if(autoindex>0) {TRow.cells[0].innerText = rIndex*1+1;}
		for (var i=autoindex;i<  TRow.cells.length ; i ++ )
		{
			lvw.RefreshCell(TRow.cells[i],DataRow[i-autoindex+1])
		}
	}
	,
	RefreshCell : function (TCell, DCell) { //刷新单元格
		if(TCell.getAttribute("Const")=="1"){ return;}
		if(TCell.className.indexOf("checkboxcell")>0) {TCell.children[0].children[0].checked = (DCell=="1") ;return;}
		var cellBody = TCell.children[0]?TCell.children[0].rows[0].cells[0]:TCell;
		if(typeof(DCell)=="undefined") {DCell =""; }
		var c = DCell
		DCell = (DCell+"").split(lvw.sBoxSpr)
		if(cellBody.children.length > 0 && (cellBody.children[0].tagName=="INPUT" || cellBody.children[0].tagName=="TEXTAREA")) {
			cellBody.children[0].value = DCell[0];
			if(DCell.length>1){cellBody.children[0].title = DCell[1]}
			else{cellBody.children[0].title = ""}
		}
		else{
			cellBody.innerHTML = DCell[0].replace(/#；/g,";");
			if(DCell.length>1){cellBody.title = DCell[1]}
			else{cellBody.title = ""}
		}
	}
	,
	getDataRowDataByTR  : function (TRow) { //根据表中的行获取其数组对应的数组
		if(TRow){
			var div = window.getParent(TRow,3)
			lvw.TryCreateHiddenPageDataToArray(div);
			return div.hdataArray[div.getAttribute("PageStartIndex") * 1 + TRow.rowIndex - 2]; 
		}
		else{
			return null;
		}
	}
	,
	getDataRowIndexByTR  : function (TRow) { //根据表中的行获取其数组对应的位置
		if(TRow){
			var div = window.getParent(TRow,3)
			lvw.TryCreateHiddenPageDataToArray(div);
			return div.getAttribute("PageStartIndex") * 1 + TRow.rowIndex - 2; 
		}
		else{
			return 0;
		}
	}
	,
	getDataCellIndexByTD : function(TD) { //根据表格单元获取对应的数组单元序号
	    var div = window.getParent(TD, 4);
	    if (!div) return;
		var autoIndex = (div.checkbox == "1") ? 1 : 0;
		if (window.GetDataCellIndexByTD) autoIndex = window.GetDataCellIndexByTD(TD);
		return lvw.cellIndex(TD) - autoIndex + 1 ;
	}
	,
	addDataRow : function (div,dataRow, sindexv) { //添加一个数据行
		lvw.TryCreateHiddenPageDataToArray(div);//尝试创建隐藏数据的数组
		var len = div.hdataArray.length;
		var sIndex = sindexv || 0;
		var nullrow = document.getElementById( div.id.replace("listview_","listviewnullrow_"))
		div.hdataArray[len] = new Array();
		var celllen = nullrow.cells.length - 1 - sIndex
		if(div.checkbox=="1"){sIndex ++;} 
		for (var i=0;i< celllen ; i ++ )
		{
			if(dataRow[i] && dataRow[i]!="$0x-null"){
				div.hdataArray[len][i+1+sIndex] = dataRow[i];
			}
			else{
				var td = nullrow.cells[i+1+sIndex];
				if(td){
					div.hdataArray[len][i+1+sIndex] = lvw.getCellValue(nullrow.cells[i+1+sIndex]);
				}
			}
		}
	} 
	,
	updateDataRow : function(TRow,NewRowArray,sIndex) { //给指定数据行赋新值
		if(!NewRowArray) {return }
		if(!sIndex) {sIndex = 1 } //默认从第一行开始更新
		if(!TRow){alert("要更新的行已经无效");return false;}
		var div = window.getParent(TRow,3);
		lvw.TryCreateHiddenPageDataToArray(div);
		if(!div.hdataArray) {return}
		var rIndex = lvw.getDataRowIndexByTR(TRow); 
		if (!div.hdataArray[rIndex]){div.hdataArray[rIndex] = new Array()} //数组不存在则创建数组
		for (var i=0; i < NewRowArray.length; i++ )
		{
			if(NewRowArray[i]!="$0x-null" && NewRowArray[i]) {
				div.hdataArray[rIndex][i+sIndex] = NewRowArray[i]
			}
		}
	}
	,
	RegChange : function(div, dbname) { 
		var s = div.getAttribute("ColsUpdate");
		if(s) {
			var ls =  s.split("|||");
			var hs = false;
			for (var i = 0; i < ls.length ; i ++ )
			{
				if(ls[i].indexOf(dbname+"=")==0) {
					ls[i] = dbname+"=" + (new Date()).getTime();
					hs = true;
					break;
				} 
			}
			if(hs==false) { ls[ls.length] = dbname+"=" + (new Date()).getTime(); }
			s = ls.join("|||")
		} else {
			s =  (dbname+"=" + (new Date()).getTime());
		}
		div.setAttribute("colUpdateTimes", s);
	}
	,
	updateDataCell : function(TCell , newData) { //给指定数据单元赋新值
		var div = window.getParent(TCell,4);
		var TRow = TCell.parentElement;
		lvw.TryCreateHiddenPageDataToArray(div);
		var rIndex = lvw.getDataRowIndexByTR(TRow);
		var cIndex = lvw.getDataCellIndexByTD(TCell);
		//alert("A." + lvw.GetSaveDetailData())
		if (!div.hdataArray[rIndex]){div.hdataArray[rIndex] = new Array();} //数组不存在则创建数组
		if( newData!="$0x-null") {
			    ///alert("B." + lvw.GetSaveDetailData())
				//alert( newData)
				div.hdataArray[rIndex][cIndex] = newData + ""
				//alert("C." + lvw.GetSaveDetailData())
		}
	}
	,
	getTRowByInput : function(currInputBox) { //根据当前文本框获取所在行
		return window.getParent(currInputBox,6);
	}
	,
	getTDByInput : function(currInputBox) { //根据当前文本框获取所在单元格
		return window.getParent(currInputBox,5);
	}
	,
	updateRowByInput : function(input, isnumber){ // 当输入框的内容改变时更新当前行内容
		var tr = window.getParent(input,6);
		var div = window.getParent(tr, 3);
		var v = "";
		if(isnumber) {
			//BUG.3280.binary
			if (input.ltype=="number")
			{
				input.value = (input.value*1).toFixed(window.MoneyNumber);
			}else{
				input.value = (input.value*1).format();
			}
		}
		var InputCellIndex = lvw.getDataCellIndexByTD(window.getParent(input, 5));
		if (!InputCellIndex) return;
		if (window.getParent(input, 7).rows[0].cells[InputCellIndex].oywname)
		{
		    window.InputDBName = window.getParent(input, 7).rows[0].cells[InputCellIndex].oywname;
		}
		lvw.TryCreateHiddenPageDataToArray(div);
		if (!div){ return false}
		var aindex = div.autoindex=="1" ? 1 : 0;
		if(div.tagName!="DIV") {return false}
		var sIndex =lvw.getDataRowIndexByTR(tr) ;
		var ii = 1
		div.hdataArray[sIndex][0] = ""
		for (var i =aindex ; i < tr.cells.length ; i ++ )
		{
			var cell = tr.cells[i];
			 v = lvw.getCellValue(cell) + "" ;
			 if (v.indexOf(lvw.sBoxSpr)<0)
			 {	
				 v = lvw.getCellselBoxValueByText(cell,v);
				 if(v.value.length>0){
				
					v = v.name + lvw.sBoxSpr + v.value
				 }
				else{
					v = v.name
				}
			 }
			div.hdataArray[sIndex][ii] = v
			ii ++;
		}
		var tb = div.children[0];
		lvw.formulaApply(tb,tr)
		lvw.setBgColorApply(tb,tr);
		if(lvw.onformulaApply) {
            lvw.onformulaApply(div, input);
		}
		// 检测公式
		
		
	} //------------------------------------------------------------------------------------------
	,
	setBgColorApply : function (tb,tr) {
		var headers = tb.rows[0].cells;
		for (var i = 0; i < headers.length ; i ++)
		{
			var bccode = headers[i].getAttribute("bgcolorExp");
			if(bccode && bccode!="") {
				lvw.setItemColbgColor(tb, tr, bccode, tr.cells[i]);
			}
		}
	}
	,
	setItemColbgColor :function(tb, tr, bccode, td) {
		bccode = bccode.replace(/【/g,"lvw.getCellValueByName(tb,tr,\"").replace(/】/g,"\")")
		var bgcolor = eval(bccode);
		td.style.backgroundColor = bgcolor;
	}
	,
	formulaApplyAll: function (div) {
		var tb = div.children[0]
		if(tb.formula.length==0){return false}
		lvw.TryCreateHiddenPageDataToArray(div);
		var fArray =  tb.formulaScript;
		if(true){
			var aIndex = div.autoindex*1==1 ? 1 : 0;
			var sText = tb.formula.replace(/\$‘/g,"'").replace(/\$“/g,"\"").split(";");
			for (i = 0; i < sText.length ; i++ )
			{
				sText[i] =  sText[i].replace(/【/g,"@【").replace(/】/g,"】@")
                sText[i] =  sText[i].replace(/〖/g,"@〖").replace(/〗/g,"〗@")
				sText[i] =  sText[i].split("@");
				for (var ii=0;ii<sText[i].length ;ii++ )
				{
					var txt = sText[i][ii]
					if (txt.indexOf("【")>=0 && txt.indexOf("】")>0)
					{
						var head = txt.replace("【","").replace("】","");
						for (var iii = aIndex; iii<tb.rows[0].cells.length ; iii++ )
						{
							if(tb.rows[0].cells[iii].getAttribute("oywname")==head){
								sText[i][ii] = "【" + (iii) + "】";
							}
						}
					}
                    if (txt.indexOf("〖")>=0 && txt.indexOf("〗")>0)
					{
						var head = txt.replace("〖","").replace("〗","");
						for (var iii = aIndex; iii<tb.rows[0].cells.length ; iii++ )
						{
							if(tb.rows[0].cells[iii].getAttribute("oywname")==head){
								sText[i][ii] = "〖" + (iii) + "〗";
							}
						}
					}
				}
				sText[i] = sText[i].join("");
			
			}
			for (var i = 0; i < div.hdataArray.length ; i ++ )
			{
				for (var ii=0 ; ii < sText.length;  ii ++ )
				{
					var fCode = sText[ii]
                    //按下标来生成公式与约束
                     if(fCode.indexOf("〖")<0) 
                    {
					    fCode = fCode.replace("【","div.hdataArray[" + i + "][").replace("】=","]=");
					    fCode = fCode.replace(/【/g,"lvw.cellvalue(div.hdataArray[" + i + "][").replace(/】/g,"])");
                    }
                    else{
                        fCode = fCode.replace(/【/g,"div.hdataArray[" + i + "][").replace(/】[\s]*\=[\s]*\(/g,"]=(");
					    fCode = fCode.replace(/〖/g,"lvw.cellvalue(div.hdataArray[" + i + "][").replace(/〗/g,"])");
                    }
					eval(fCode);
					if(!isNaN(div.hdataArray[i])){
						div.hdataArray[i] = div.hdataArray[i].format();
					}
				}
			}
			if(lvw.onformulaApplyAll) {
				lvw.onformulaApplyAll(div);
			}
		}
	}
	,
	cellvalue : function(v) {
		var obj = (v + "").split(lvw.sBoxSpr);
		if(obj.length > 1 && obj[1].length>0 && obj[1]!="undefined") {
			return obj[1];
		}
		else{
			return obj[0];
		}
	}
	,
	formulaApply : function(tb,tr){ //公式应用
		if(tr){
			if(tb.formula.length==0){return false}
			var fArray =  tb.formulaScript
			if(!fArray){
				var sText = tb.formula.replace(/\$‘/g,"'").replace(/\$“/g,"\"").split(";");
				for (var i=0;i<sText.length ;i++)
				{	
                    //按名称来生成公式与约束
                    if(sText[i].length > 0 ) {
						
                        if(sText[i].indexOf("〖")<0) 
                        {
					        sText[i] = sText[i].replace("【","lvw.setformula(tb,tr,\"").replace("】=","\",")
					        sText[i] = sText[i].replace(/【/g,"lvw.getCellValueByName(tb,tr,\"").replace(/】/g,"\")")
					        sText[i] = sText[i] + ")"
				        }
                        else{
                            sText[i] = sText[i].replace(/【/g,"lvw.setformula(tb,tr,\"").replace(/】[\s]*\=[\s]*\(/g,"\",")
					        sText[i] = sText[i].replace(/〖/g,"lvw.getCellValueByName(tb,tr,\"").replace(/〗/g,"\")")
                        }
						
                    }
                }
				tb.formulaScript = sText.join(";\n");
				fArray =  tb.formulaScript;
			}
			eval(fArray);
		}
	}
	,
	setformula: function (tb, tr, colname, value) { //按照公式跟新值
	    if (window.checkDBNname) {
	        if (!window.checkDBNname(colname, window.InputDBName)) return;
	    }
		var TRow = tb.rows[0];
		var div = tb.parentElement;
		if (!isNaN(value))
		{
		    if (colname.indexOf("价") > -1) {
		        value = checkDot(value, window.StorePriceNumber)
			} else if (colname.indexOf("金额") > -1) {
				value = FormatNumber(value, window.MoneyNumber)
			} else if (colname.indexOf("实盘数量") > -1) {
				//BUG 65262 2022-07-04 实盘数量整数位与小数位控制
				value = checkNumDot(value, 13, window.floatnumber)				
			}else {
		        value = value.format();
		    }
		}
		for (var i=0;i<TRow.cells.length ;i++ )
		{
		    if (TRow.cells[i].getAttribute("oywname") && TRow.cells[i].getAttribute("oywname").replace(/\s/g, "").toLowerCase() == colname.toLowerCase()) {
				var  td = tr.cells[i];
				if(lvw.IsLockRow(td)==false)
				{
					lvw.updateDataCell(td,value);
					lvw.setCellValue(td,value);
					lvw.updateColSum(div,i);
				}
				return false
			}
		}
	}
	,
	getCellIndexByName : function(tb,tr,colname){ //根据列名获取值
		if(tb==""){tb = tr.parentElement.parentElement;}
		var TRow = tb.rows[0]
		for (var i=0;i<TRow.cells.length ;i++ )
		{
			if(TRow.cells[i].oywname==colname){
				return i
			}
		}
		return -1;
	}
	,
	getDataValueByName : function(div, rowIndex, colname) { //根据表格单元获取对应的数组单元序号
		var vindex = 0;
		var tb = div.children[0];
		var head = tb.rows[0]
		for (var i=0;i<head.cells.length ;i++ )
		{
			if(head.cells[i].oywname && head.cells[i].oywname.replace(/\s/g,"").toLowerCase()==colname.toLowerCase()){
				var vs = (div.hdataArray[rowIndex][i] + "").split(lvw.sBoxSpr);
				if(vs.length>1) {
					if(vs[1] && vs[1].length > 0)
					{
							return  vs[1];
					}
				}
				return vs[0];
			}
		}
		return "";
	}
	,
	getCellValueByName : function(tb,tr,colname){ //根据列名获取值
		var vindex = 0;
		if(tb==""){tb = tr.parentElement.parentElement;}
		var TRow = tb.rows[0]
		for (var i=0;i<TRow.cells.length ;i++ )
		{
			if(TRow.cells[i].getAttribute("oywname") && TRow.cells[i].getAttribute("oywname").replace(/\s/g,"").toLowerCase()==colname.toLowerCase()){
				var vs = lvw.getCellValue(tr.cells[i]).split(lvw.sBoxSpr);
				if(vs.length>1) {
					if(vs[1] && vs[1].length > 0)
					{
							return  vs[1];
					}
				}
				return vs[0];
			}
		}
		return "";
	}
	,
	movepreRow : function (tr, defcellIndex) { //移动到上一行
		var  pRow = tr.previousSibling;
		if(pRow.previousSibling){ //.previousSibling是为了除去标头
			lvw.editfocus(pRow.cells[defcellIndex])
		}
		else{//调动数据，移动到上一行
			var tb = tr.parentElement.parentElement;
			var div = tb.parentElement;
			lvw.TryCreateHiddenPageDataToArray(div);//尝试创建隐藏数据的数组
			var dSize = div.hdataArray.length
			var sIndex = div.getAttribute("PageStartIndex")*1 - 1 //起点位置
			var eIndex = div.getAttribute("PageSize")*1 + sIndex*1-1; //截止位置
			if(eIndex > dSize) {eIndex = dSize-1}
			div.setAttribute("PageStartIndex", sIndex);
			if(sIndex> 0){ //如果没有超出范围，则进行分页下移
			    lvw.MoveRowShow(div,sIndex,eIndex)
				var pRow = tb.rows[1]
				if(pRow){
					lvw.editfocus(pRow.cells[defcellIndex])
					input= div.children[0].currFocusInput;
					input.focus();
					input.select();
				}
			}
			lvw.UpdateScrollBar(div) //滚动条滚动
		}
	}
	,
	movenextRow  : function (tr,defcellIndex) {  //移动到下一行
		var  nRow = tr.nextSibling;
		var tb = window.getParent(tr,2);
		if(nRow){
			if(!lvw.editfocus(nRow.cells[defcellIndex])){
				if(!lvw.NextKeyAdd){return;}//没有默认不自动添加
				lvw.addRow(tr.parentElement.parentElement,defcellIndex);
				lvw.UpdateScrollBar(tb.parentElement) //滚动条滚动
				return;
			}
		}
		else {
			if(!lvw.NextKeyAdd){return;}//没有默认不自动添加
			lvw.addRow(tr.parentElement.parentElement,defcellIndex);
			lvw.UpdateScrollBar(tb.parentElement) //滚动条滚动
		}
	}
	,
	isDate  : function (str) {
			var d = new Date(str.replace(/\-/g,"/").replace(/\./g,"/"));
			return !isNaN(d);
	}
	,
	updateColSum : function(div,colIndex){
		var sm = 0
		if(div.autosum*1==1){
			var dArray = div.hdataArray
			for(var i = 0 ; i < dArray.length ; i ++){
				var v = dArray[i][colIndex+1-div.autoindex]
				v = (v + "").split(lvw.sBoxSpr)[0];
				sm = v*1 + sm*1
			}
			var tb = div.children[0]
			try{
				var h = tb.rows[0].cells[colIndex];
				if(h.innerText.indexOf("单价")>-1 || h.innerText.indexOf("率")>-1) 
				{
					tb.rows[tb.rows.length-1].cells[colIndex].innerText = "";
					return true;
				}
			}catch(e){}
			
			if (isNaN(sm))
			{
				tb.rows[tb.rows.length-1].cells[colIndex].innerText = "";
			}
			else{
				sm = ((sm*1).toFixed(12))*1;
				if(h.innerText.indexOf("工资")>-1 || h.innerText.indexOf("价")>-1 || h.innerText.indexOf("率")>-1 || h.innerText.indexOf("成本")>-1 || h.innerText.indexOf("额")>-1)
				{
					tb.rows[tb.rows.length-1].cells[colIndex].innerText = sm.toFixed(window.MoneyNumber);
				}else
				{
					tb.rows[tb.rows.length-1].cells[colIndex].innerText = sm.format();
				}
			}
		}
	}
	,
	ValueTest : function(em) {
		var tb = em.tb;
		var tr = em.tr;
		var td = em.td;
		var v =  em.value;
		if(em.title.length>0){
			v = em.title
		}
		var heads = tb.rows[0];
		var hCell =  heads.cells[lvw.cellIndex(td)];
		var notnull = (hCell.notnull == "1")
		var maxsize = hCell.getAttribute("maxsize");
		switch(heads.cells[lvw.cellIndex(td)].dtype){
			case "number":
				if (isNaN(v))
				{
					try{v=eval(v)}catch(e){}
					if (isNaN(v)){v=0;}
					em.value = v; //alert(" 内容 \" " + v + " \" 不是一个有效的数字 。 \n\n 此处要求输入正确的数字。")
					return false;
				}
				if(heads.cells[lvw.cellIndex(td)].selid.length==0)
				{
					var fm = tb.getAttribute("formula");
					lvw.updateColSum(tb.parentElement,lvw.cellIndex(td))
					for (var i = 0; i < heads.cells.length; i ++ )
					{
						var h = heads.cells[i];
						if(h.getAttribute("dtype")=="number" && h.getAttribute("edit")=="0" && fm.indexOf("【" + h.innerText.replace(/\s/g,"") + "】") >= 0) {
							//对于公式计算的列求和
							lvw.updateColSum(tb.parentElement,lvw.cellIndex(h))
						}
					}
				};
				return true;
			case "date":
				if (!lvw.isDate(v) && (v + "").length > 0)
				{
					var bn = em.parentElement;
					if(em.parentElement && em.parentElement.nextSibling){
						var bn = em.parentElement.nextSibling.children[0];
						if(bn && bn.selid=="10002" && bn.selid=="10003" ){
							bn.click();
						}
						else{
							alert(" 内容 \" " + v + " \" 不是一个有效的日期 。 \n\n 此处要求输入正确的日期 ，系统可识别日期格式为：  yy-mm-dd 或 yy/mm/dd 。")
						}
					}
					else{
						alert(" 内容 \" " + v + " \" 不是一个有效的日期 。 \n\n 此处要求输入正确的日期 ，系统可识别日期格式为：  yy-mm-dd 或 yy/mm/dd 。")
					}
					
					return false;
				}
				em.value = em.value.replace(/\//g,"-").replace(/\./g,"-") 
				return true;
			default:
                if(!isNaN(maxsize)) {
					//bug.7013 字段长度问题  by 常明 at 20150119 由于字段类型都已改为nvarchar，所以非ASC字符不必按2个字符来计算长度
                    //if(em.value.replace(/[^\x00-\xff]/g,"xx").length > maxsize) 
					if(em.value.length > maxsize) 
                    {
                        alert("提示您：内容超长。\n\n列【" +  hCell.innerText + "】的长度不允许超过" + maxsize + "。")
                        return false;
                    }
                }
				return true;
		}
		//添加汇总
	}
	,
	movenextCell : function (td) {  //移动到下一个单元格
		var next = td.nextSibling;
		if(next){
			if(!lvw.editfocus(next)){
				lvw.movenextCell(next)
			}
		}
		else{
			var nexttr = td.parentElement.nextSibling;
			if(nexttr) {
				var td = nexttr.cells[0];
				if(!lvw.editfocus(td)){
					lvw.movenextCell(td)
				}
			}
			else{
				lvw.addRow(td.parentElement.parentElement.parentElement)
			}
		}
	}
	,
	cellinputkeyup : function(){ //输入框按键
		var obj = window.ProxykeyselectboxSrc || window.event.srcElement;
		//BUG.3096.KILLER.2013.12.09 库间调拨选择仓库，保存移货没有判断仓库的有效性 
		if(obj.getAttribute("oncechange")=="1") {
			obj.setAttribute("oncechange",  null);
		}
		else{
			if(obj.title && obj.title.length>0 && !window.ProxykeyselectboxSrc){
				obj.title = "invalid";
			}
		}
		window.ProxykeyselectboxSrc = null;
		//BUG 6817 Sword 2015-1-6 用人申请数量能输入小数 
		if(obj.isEidtNumber==true || obj.isEidtNumber==1){
			if(!isNaN(obj.value))
			{
				var  vi = (obj.value  + "").split(".") ;
				if(obj.ltype=="number" && vi.length>1 && vi[1].length>window.MoneyNumber){
					obj.value = obj.oldvalue;
				}
				else if (obj.ltype=="int" && vi.length>1 && vi[1].length>window.floatnumber){
					obj.value = obj.oldvalue;
				}
			}
			else
			{
				obj.value = obj.oldvalue;
			}
		}
		switch(window.event.keyCode){
			case 13: //回车 , 移动到下一个
				return false;
			case 40:  //移动到下一行
				return false;
			case 38:  //移动到上一行
				return false;
			default:
				if (obj.value.indexOf("#oc")>= 0){obj.value=obj.value.replace("#oc",""); return false}  //置换特殊分隔符号
				if (obj.value.indexOf("#or")>= 0){obj.value=obj.value.replace("#or",""); return false}
				if (obj.value.indexOf("#ot")>= 0){obj.value=obj.value.replace("#ot",""); return false}
				break;
		}
		if (!obj.parentElement.nextSibling)
		{
			obj.oldvalue = obj.value;
			return false;
		}
		var sel  = obj.parentElement.nextSibling.children[0]
		if(sel){
			if(window.ItemKeyUpHwnd>0) {
				window.clearTimeout(window.ItemKeyUpHwnd);
				window.ItemKeyUpHwnd = 0;
			}
			window.ItemKeyUpHwnd = window.setTimeout(function() { lvw.ItemKeyUpDoSearch(sel); }, 300);
		}
		if(obj.ztlr=="1"){
			//alert(obj.outerHTML)
			obj.oldvalue = obj.value;
			return;
		}  //整体录入的文本框做多余判断
		lvw.updateRowByInput(obj);
		lvw.autoSumRow(obj);
		obj.oldvalue = obj.value;
	}
	,
	ItemKeyUpDoSearch : function(sel) {
		sel.isKey = true;
		sel.setAttribute("selPageIndex",1);
		sel.click();  //触发查询功能
		sel.isKey = false;
	} 
	,
	autoSumRow : function(txt){ //更新一列的和
		if(txt){
			var div = txt.tb.parentElement;
			var tr = txt.tr;
			var td = txt.td;
			var heads = txt.tb.rows[0];
			var hCell = heads.cells[lvw.cellIndex(td)]
			if(hCell.dtype=="number" && (!hCell.selid || hCell.selid.length==0)){
				lvw.updateColSum(div,lvw.cellIndex(td))
			}
		}
	}
	,
	cellinputkeydown : function(){ //输入框按键
		var em = window.event.srcElement;
		
		if(menu.oPopup.isOpen){ //正在执行自动完成
			return true;
		}
 		switch(window.event.keyCode){
			case 9:
			case 13: //回车 , 移动到下一个
				window.event.keyCode = 0;
				lvw.movenextCell(em.td)
				return false;
				window.event.returnValue = false;
				break;
			case 40:  //移动到下一行
				window.event.keyCode = 0;
				lvw.movenextRow(em.tr,lvw.cellIndex(em.td));
				window.event.returnValue = false;
				return false;
				break;
			case 38:  //移动到上一行
				window.event.keyCode = 0;
				lvw.movepreRow(em.tr,lvw.cellIndex(em.td));
				window.event.returnValue = false;
				return false;
				break;
			case 8:
				window.event.keyCode = 0;
				break;
			default:
				return true;
				break;
		}
	}
	,
	slist : function(sButton) {
		//alert(sButton.selid)
	}
	,
	cellIndex : function(td){
		var tr = td.parentElement.cells;
		for (var i = 0; i < tr.length ; i ++ )
		{
			if(tr[i]==td){
				return i;
			}
		}
	}
	,
	IsLockRow : function(obj)
	{
		//判断当前列是否是锁定行
		var td = obj.tagName=="TD" ? obj : window.getParent(obj,5);
		var tr = td.parentElement;
		var tb = tr.parentElement.parentElement;
		var head = tb.rows[0];
		var cIndex = lvw.cellIndex(td);
		var frmtext = head.cells[cIndex].getAttribute("lockExp");
	    if(frmtext && frmtext.length>0)
		{
			var code = frmtext.replace(/【/g,"lvw.getCellValueByName(tb,tr,\"").replace(/】/g,"\")");
			return eval(code);
		}
		else{
			return false;
		}
		
	},
	focusEditCell: function(childobj){
		var obj = $(childobj).parents("td[class='lvcr edt1']");
		if(obj[0]){
			lvw.editfocus(obj[0]);
		}
	}
	,
	editfocus : function(td){ //根据td获取编辑的方格
		if(!td){return false}
		var cellBody = td

		if (td.className.length==0){return false}
		
		if(td.className!="full" && td.className!="full2"){
			if(td.children.length==0){return false;}
			if(td.children[0].tagName!="TABLE"){return false;}
			var cellBody = td.children[0].rows[0].cells[0];
		}

		var td = cellBody.parentElement.parentElement.parentElement.parentElement;
		var tr = td.parentElement;
		var tb = tr.parentElement.parentElement;
		var head = tb.rows[0]
		if(tb.currFocusCell==td){
			return true;
		}
		var cIndex = lvw.cellIndex(td);
		if(head.cells[cIndex].edit=="1" && lvw.IsLockRow(td)==false){
			if(!tb.currFocusInput || !tb.currFocusCell || tb.currFocusCell.children.length == 0){	//初始化编辑状态
				tb.currFocusInput = document.createElement("Input") 
				tb.currFocusInput.type = "text";
				tb.currFocusInput.className = "ctllvwCurrInput";
				tb.currFocusInput.value = cellBody.innerText;
				tb.currFocusInput.oldvalue = tb.currFocusInput.value;
				tb.currFocusInput.title = cellBody.title;
				tb.currFocusInput.tb = tb;
				tb.currFocusInput.tr = tr;
				tb.currFocusInput.td = td;
				tb.currFocusInput.onkeydown = lvw.cellinputkeydown;
				tb.currFocusInput.onkeyup = lvw.cellinputkeyup;
				$(tb.currFocusInput).unbind("change").bind("change", lvw.cellinputchange);
				if(tb.rows[0].cells[lvw.cellIndex(td)].dtype=="text"){
					tb.currFocusInput.style.textAlign = "left";
				}
				else{
					tb.currFocusInput.style.textAlign = "right";
				}
				cellBody.innerHTML = "";
				cellBody.appendChild(tb.currFocusInput);
				if (tb.rows.length>1)
				{
					var fRow = tb.rows[1];
					for(var i = 0 ; i < fRow.cells.length ; i ++ ){
						var cell = fRow.cells[i]
						if (cell.className.indexOf("edtfocus")>0)
						{
							cell.className=cell.className.replace("edtfocus","edt1");
						}
					}
				}
				td.className = td.className.replace("edt1","edtfocus");
				window.lvwcurrFocusInputFocus = function(){
					try{
						tb.currFocusInput.focus();
						tb.currFocusInput.select();
					}catch(e){}
				}
				window.setTimeout("window.lvwcurrFocusInputFocus()",30)
				tb.currFocusCell = td;
			}
			else{
				var html = tb.currFocusInput.outerHTML;
				var currcellBody = tb.currFocusCell.children[0].rows[0].cells[0];
				var currtd  = tb.currFocusInput.td;
				var head = tb.rows[0].cells[lvw.cellIndex(currtd)];
				var numType = (head.dtype=="number" && (head.selid=="" || head.selid=="0"));
				lvw.updateRowByInput(tb.currFocusInput, numType);
				if (!lvw.ValueTest(tb.currFocusInput)){
					window.lvwcurrFocusInputFocus = function(){
					try{
							tb.currFocusInput.focus();
							tb.currFocusInput.select();
						}catch(e){}
					}
					window.setTimeout("window.lvwcurrFocusInputFocus()",30)
					return true;
				}
				currcellBody.innerHTML = tb.currFocusInput.value;
				currcellBody.title = tb.currFocusInput.title;
				currtd.className = currtd.className.replace("edtfocus","edt1");
				td.className = td.className.replace("edt1","edtfocus");
				var inputdiv = document.createElement("div")
				inputdiv.innerHTML = html;
				tb.currFocusInput = inputdiv.children[0];
				if(tb.rows[0].cells[lvw.cellIndex(td)].dtype=="text"){
					tb.currFocusInput.style.textAlign = "left";
				}
				else{
					tb.currFocusInput.style.textAlign = "right";
				}
				tb.currFocusInput.value = cellBody.innerText;
				tb.currFocusInput.oldvalue = tb.currFocusInput.value;
				tb.currFocusInput.title = cellBody.title;
				tb.currFocusInput.tb = tb;
				tb.currFocusInput.tr = tr;
				tb.currFocusInput.td = td;
				cellBody.innerHTML = "";
				cellBody.appendChild(tb.currFocusInput);
				window.lvwcurrFocusInputFocus = function(){
					try{
						tb.currFocusInput.focus();
						tb.currFocusInput.select();
					}catch(e){}
				}
				window.setTimeout("window.lvwcurrFocusInputFocus()",30)
				tb.currFocusCell = td;
				tb.currFocusInput.onkeydown = lvw.cellinputkeydown;
				tb.currFocusInput.onkeyup = lvw.cellinputkeyup;
				$(tb.currFocusInput).unbind("change").bind("change", lvw.cellinputchange);
			}

			var heads = tb.rows[0];
			var hCell = heads.cells[lvw.cellIndex(td)]
			if(hCell.dtype=="number" && (!hCell.selid || hCell.selid.length==0)){
				if (hCell.innerHTML.indexOf("工资")>-1 || hCell.innerHTML.indexOf("额")>-1 || hCell.innerHTML.indexOf("率")>-1 || hCell.innerHTML.indexOf("价")>-1 || hCell.innerHTML.indexOf("成本")>-1)
				{
					tb.currFocusInput.ltype = hCell.dtype;
				}else{
					tb.currFocusInput.ltype = hCell.ltype;
				}
				tb.currFocusInput.isEidtNumber = true;
			}
			else{
				tb.currFocusInput.isEidtNumber = false;
				tb.currFocusInput.ltype = "";
			}
			return true;
		}
		else{
			return false;
		}

	}
	,
	cellinputchange : function(input){
		if (input && input.srcElement && input.srcElement.tagName) {
			//非ie下，input传的是event对象，所以特殊处理
			input = input.srcElement;
		}
		if(input && input.target &&  input.target.tagName)  {
			//JQuery模式下，input传的是JQuery event对象，所以特殊处理
			input = input.target;
		}
		if(input){
			var td = window.getParent(input,5);
			lvw.updateDataCell(td,input.value);
		}
	}
	,
	cellvaluechange : function(){

	}
	,
	JsPageSizeChange : function(selObj) { //改变页面大小
		var pSize = selObj
		var div = window.getParent(selObj,10)
		lvw.TryCreateHiddenPageDataToArray(div);//尝试创建隐藏数据的数组
		var pSize = div.hdataArray.length
		div.setAttribute("PageSize") = selObj.value;
		var eIndex  = div.getAttribute("PageStartIndex")*1 + selObj.value *1 -1 
		if (eIndex> pSize)
		{eIndex = pSize;}
		div.PageEndIndex = eIndex
		lvw.Refresh(div);
		lvw.UpdateScrollBar(div);
	}
	,
	UpdateListByArray : function(div){  //更新当前列表
		var eIndex = div.PageEndIndex*1; //截止位置
		var sIndex = div.getAttribute("PageStartIndex")*1; //起点位置
		lvw.MoveRowShow(div,sIndex,eIndex);
	}
	,
	CheckAll : function(div) {  //全选
		if(div){
			lvw.TryCreateHiddenPageDataToArray(div);
			for (var i=0; i < div.hdataArray.length ; i ++)
			{
					div.hdataArray[i][1] = 1;
			}
			lvw.Refresh(div);
		}
	}
	,
	unCheckAll : function(div) {  //全选
		if(div){
			lvw.TryCreateHiddenPageDataToArray(div);
			for (var i=0; i < div.hdataArray.length ; i ++)
			{
					div.hdataArray[i][1] = 0;
			}
			lvw.UpdateListByArray(div)
		}
	}
	,
	checkItemClick : function(button){
		return function(txt,tag){
			var div = window.getParent(button,5)
			switch(txt){
				case "全选":
					lvw.CheckAll(div)
					break;
				case "全消选":
					lvw.unCheckAll(div)
					break;
				case "删除选择行":
					lvw.deleteSelectRow(div)
					lvw.UpdateScrollBar(div);
					break;
				case "整体录入":
					lvw.showAllInputDlg(div,true)
					break;
				case "行位置调整":
					lvw.showMovePos(div);
					break;
				case  "导出Excel":
					document.body.focus()
					lvw.CreateExcel(div);
					break;
				case "显示隐藏字段":
					lvw.showhiddenfields(div);
					break;
				default:
			}
		}
	
	}
	,
	showhiddenfields : function(div){
		var  td = div.getElementsByTagName("td")
		for (var i=0;i< td.length ; i++ )
		{
			if(td[i].className.indexOf("lvc")>=0 && td[i].style.display == "none"){
				td[i].style.display = "";
				td[i].style.width = "100px"
			}
		}
		var  td = div.getElementsByTagName("th")
		for (var i=0;i< td.length ; i++ )
		{
			if(td[i].className.indexOf("lvc")>=0 && td[i].style.display == "none"){
				td[i].style.display = "";
				td[i].style.width = "100px"
				td[i].style.color = "red"
			}
		}
	}
	,
	showAllCheckMenu : function(rButton,lvwdiv){
		var m = new window.contextmenu(lvw.checkItemClick(rButton));
		m.additem("全选","../../images/smico/ok.gif");
		m.additem("全消选","../../images/smico/del.gif");
		m.addsplit();
		if(lvwdiv.candel=="1"){m.additem("删除选择行","../../images/smico/dele_1.gif");}
		m.additem("行位置调整","../../images/smico/jt6.gif");
		m.additem("导出Excel","../../images/smico/excel.gif");
		m.addsplit();
		m.additem("整体录入","../../images/smico/gzjh.gif");
		if (location.href.indexOf("127.0.0.1")>0)
		{m.additem("显示隐藏字段","");}
		m.show(rButton);
		
	}
	,
	ShowReplaceColList : function(rButton) {
		if(window.contextmenu){ //office风格菜单{
			var  tb = rButton.parentElement.parentElement.parentElement.parentElement
			if(rButton.title=="全选或取消全选"){
				lvw.showAllCheckMenu(rButton,tb.parentElement);
				return false;
			}
			var hcol = tb.getAttribute("hideCol");
			if(hcol){
				var hlist = hcol.split(";")
				if(hlist){
					var mlist =  new contextmenu(lvw.ReplaceCol(rButton));
					for (var  i= 0; i < hlist.length ; i ++ )
					{
						if(hlist[i].replace(/\s/g,"").length>0){
							mlist.additem(hlist[i],"../../images/smico/dot_1.gif",hlist[i])
						}
					}
					mlist.show(rButton);
				}
				else{
					alert("没有隐藏列可供替换。")
				}
			}
		}
		else{
			var sc = document.createElement("script")
			sc.language = "javascript"
			sc.src = "ContextMenu.js"
			document.appendChild(sc);
			if(window.contextmenu){
				lvw.ShowReplaceColList(rButton);
			}
			else{
				alert("在没有引用ContextMenu.js文件的情况下无法实现右键菜单。")
			}
		}
	}
	,
	focusSelButton : function(){
		var button = window.event.srcElement;
		var td = window.getParent(button,5);
		if(td.tagName=="TABLE") {td=td.parentNode;}
		lvw.editfocus(td);
	}
	,
	toPage : function(input){
		var pIndex = input.value;
		var tb = window.getParent(input,4);
		if (isNaN(pIndex) || pIndex.length==0)
		{pIndex = 1};
		pIndex =parseInt(pIndex);
		lvw.toPageIndex(tb,pIndex)
	}
	,
	prePage : function(button, commuimode){
		var tb  = window.getParent(button,4);
		var sIndex = 0;
		if (commuimode==true)
		{
			sIndex = tb.getElementsByTagName("input")[0].value
		}
		else{
			sIndex = tb.rows[0].cells[2].children[0].value
		}
		if(isNaN(sIndex) || sIndex.length==0){
			sIndex = 1
		}
		if(sIndex*1 < 2 ) {return false;}
		sIndex = sIndex - 1;
		lvw.toPageIndex(tb,sIndex)
	}
	,
	nextPage : function(button, commuimode) {
		var tb  = window.getParent(button,4);
		var sIndex = 0;
		var rCount = 0;
		if (commuimode==true)
		{
			sIndex = tb.getElementsByTagName("input")[0].value;
			rCount = button.getAttribute("tag");
		}
		else {
			sIndex = tb.rows[0].cells[2].children[0].value;
			rCount = tb.rows[0].cells[3].innerText.replace("/","");
		}
		if(isNaN(sIndex) || sIndex.length==0){
			sIndex = 1
		}
		if(rCount*1 <= sIndex*1) {return false;}
		sIndex = sIndex*1 + 1;
		lvw.toPageIndex(tb,sIndex)
	}
	,
	firstPage : function(button){
		var tb  = window.getParent(button,4);
		lvw.toPageIndex(tb,1)
	}
	,
	lastPage : function(button, commuimode){
		var tb  = window.getParent(button,4);
		if (commuimode==true)
		{
			lvw.toPageIndex(tb,button.getAttribute("tag"));
		}
		else{
			lvw.toPageIndex(tb,tb.rows[0].cells[3].innerText.replace("/",""));
		}
	}
	,
	ReplaceCol : function(button){
		return function(txt,tag){ //替换列
			var ii = 0
			var vCol = new Array() 
			var td = button.parentElement
			var tr = td.parentElement
			var tb = tr.parentElement.parentElement;
			var autoindex = (tb.parentElement.autoindex=="1"?1:0); //是否生成自动编号
			var checkbox = (tb.parentElement.checkbox=="1"?1:0);   //复选框
			for (var i = autoindex + checkbox ; i < tr.cells.length ; i ++ )
			{
				if(tr.cells[i]!=td){
				
					ti = tr.cells[i].getAttribute("dbname");
				}
				else{
					ti = txt;
				}
				if(ti && ti!="") {
					vCol[vCol.length] = ti;
				}
				ii ++ ;
			}
			var div = tb.parentElement;
			ajax.regEvent("sys_ListView_CallBack")
			ajax.addParam("orderid",$("#orderid").val());
			ajax.addParam("State",div.state)
			ajax.addParam("VisibleCol",vCol.join(","))
			r = ajax.send()
			var id = div.id;
			var bgid = id.replace("listview_","ctl_llvwframe_")
			var lvwFrame = document.getElementById(bgid)
			lvwFrame.innerHTML = r
			div = document.getElementById(id)
			lvw.AutoToolAreaSize(div.children[0]);
			lvw.UpdateScrollBar(div);
			if(lvw.oncallback) {lvw.oncallback(div);}
		}
	}
	,
	dbPageSizeChange : function(sel){
		if(sel.value == "") {return;}
		var id = (sel.id + "\1").replace("_psize\1", "");
		var div = document.getElementById("listview_" + id);
		ajax.regEvent("sys_ListView_CallBack")
		ajax.addParam("orderid",$("#orderid").val());
		ajax.addParam("State",div.state)
		ajax.addParam("PageSize",sel.value)
		ajax.addParam("VisibleCol",lvw.GetVsbCol(div))
		r = ajax.send()
		var id = div.id;
		var bgid = id.replace("listview_","ctl_llvwframe_")
		var lvwFrame = document.getElementById(bgid)
		lvwFrame.innerHTML = r
		div = document.getElementById(id)
		lvw.AutoToolAreaSize(div.children[0]);
		lvw.UpdateScrollBar(div);
		if(lvw.oncallback) {lvw.oncallback(div);}
	}
	,
	GetVsbCol : function(div) {
		var ii = 0 , tr = div.children[0].rows[0]
		var autoindex = (div.autoindex=="1"?1:0); //是否生成自动编号
		var checkbox = (div.checkbox=="1"?1:0);   //复选框
		var vCol = new Array();
		for (var i = autoindex + checkbox ; i < tr.cells.length ; i ++ )
		{
				vCol[ii] = tr.cells[i].getAttribute("dbname")
				ii ++ ;
		}
		return vCol.join(",");
	}
	,
	ReloadDataFormServer : function(div, obj){ //重新刷新数据
		ajax.regEvent("sys_ListView_CallBack");
		ajax.addParam("orderid",$("#orderid").val());
		ajax.addParam("State",div.state);
		if(obj) {
			ajax.addParam(obj.name, obj.value);
		}
		ajax.addParam("VisibleCol",lvw.GetVsbCol(div));
		r = ajax.send()
		id = div.id
		var bgid = id.replace("listview_","ctl_llvwframe_")
		var lvwFrame = document.getElementById(bgid);
		lvwFrame.innerHTML = r;
		div = document.getElementById(id);
		lvw.AutoToolAreaSize(div.children[0]);
		lvw.UpdateScrollBar(div);
		if(lvw.oncallback) {lvw.oncallback(div);}
		
	}
	,
	toPageIndex : function(tb,PageIndex){
		var div = window.getParent(tb,6)
		ajax.regEvent("sys_ListView_CallBack")
		ajax.addParam("orderid",$("#orderid").val());
		ajax.addParam("State", div.state.replace(/\n/, "").replace(/\r/, ""))
		ajax.addParam("PageIndex",PageIndex)
		ajax.addParam("VisibleCol",lvw.GetVsbCol(div))
		r = ajax.send()
		id = div.id
		var bgid = id.replace("listview_","ctl_llvwframe_")
		var lvwFrame = document.getElementById(bgid)
		lvw.savecurrColWidth(id);
		lvwFrame.innerHTML = r
		div = document.getElementById(id)
		lvw.AutoToolAreaSize(div.children[0]);
		lvw.UpdateScrollBar(div);
		if(lvw.oncallback) {lvw.oncallback(div);}
		lvw.setcurrColWidth(id);
	}
	,
	GetSaveDetailData : function (div) { // tb表示获取哪张表的明细 
		if(!div){
			var r = new Array();
			var ii = 0 ;
			var divs = document.getElementsByTagName("div")
			for(var i = 0 ; i< divs.length ;i ++ ) {
				if( divs[i].id.indexOf("listview_") >=0 &&  divs[i].hdataArray ) {
					if(!divs[i].disSave){
						r[ii] = lvw.GetSaveDetailData(divs[i]);
						ii ++ ;
					}
				}
			}
			
			return r.join("#ot");
		}
		else{
			lvw.TryCreateHiddenPageDataToArray(div);//尝试创建隐藏数据的数组
			if (lvw.onGetSaveData){lvw.onGetSaveData(div);}
			var savecol = new Array()
			var autosum = (div.getAttribute("autosum") == "1");
			var aindex = (div.getAttribute("autoindex") == "1")?0:1
			var tb = div.children[0];
			var heads = tb.rows[0];
			var ii = 0 ;
			for (var i=0; i < heads.cells.length ; i ++ )
			{
				var cell = heads.cells[i];
				if(cell.getAttribute("save")=="1"  ){
					savecol.push(i);
				}
			}
			for (var i=0; i < heads.cells.length ; i ++ )
			{	//保存产品自定义明细
				var cell = heads.cells[i];
				if(cell.getAttribute("dbname") && cell.getAttribute("dbname").indexOf("{us999999}")>=0 ){
					savecol.push(i);
				}
			}
			var dat = new Array()
			for (var  ii=0; ii< div.hdataArray.length; ii ++ )
			{
				var  rDat = new Array()
				var  tr = div.hdataArray[ii]
				if (tr.length>0)
				{
					if(tr[tr.length-1].toString().indexOf("nowrap>删除") > 0){
						tr.splice(tr.length-1,1)
					}
					for (var i=0; i < savecol.length ; i ++)
					{
						try{
							var itemv = (tr[savecol[i] + aindex]+"").split(lvw.sBoxSpr)
							if(itemv.length>1 && itemv[1].replace(/(\s*$)/g,"").length>0){ 
								rDat[i] = itemv[1]
							}
							else{
								rDat[i] = itemv[0]
							}
						}
						catch(e){}
					}
				}
				dat[ii] = rDat.join("#oc")
			}
			if(lvw.GetSaveDetailDataHook){
				return lvw.GetSaveDetailDataHook(dat,div.id)
			}
			else{
				return dat.join("#or")
			}
		}
	}
	,
	AutoToolAreaSize : function(tb){ //调整一些其他区域的宽度，使他们显示一致
		return false ; // 该方法作废
		//var wtb = window.getParent(tb,5)
		//wtb.parentElement.style.width = (wtb.offsetWidth)  + "px";
		//var div = tb.parentElement;
		//var tooldiv = document.getElementById(div.id.replace("listview_","listtoolbar_"));
		//tooldiv.style.width = wtb.parentElement.style.width;
	}
	,
	mousewheel : function(tb){
		var div = tb.parentElement;
		var sIndex = div.getAttribute("PageStartIndex")
		var dtWheel = 1
		var len = div.hdataArray.length*1;

		if (len-div.getAttribute("PageSize")>0)
		{
			window.event.returnValue = false;
		}
		if(window.event.wheelDelta>0)
		{
			if(sIndex=="1"){return false;}
			if(sIndex>dtWheel){
				div.setAttribute("PageStartIndex", sIndex-dtWheel);
			}
			else{
				div.setAttribute("PageStartIndex", 1);
			}
		}
		else{
			var eIndex = sIndex*1 + div.getAttribute("PageSize")*1;
			if (len>=eIndex)
			{
				if (len-eIndex>dtWheel){div.setAttribute("PageStartIndex",sIndex*1 + dtWheel);}
				else{div.setAttribute("PageStartIndex", sIndex*1 + (len-eIndex)+1);}
			}
			else{return false;}
		}
		lvw.Refresh(div);
		lvw.UpdateScrollBar(div);
		
		return false;
	}
	,
	UpdateScrollBar : function(div) { //跟新滚动条显示问题
		
		lvw.TryCreateHiddenPageDataToArray(div)
		if(!div.hdataArray) {return false}
		var pSize = parseInt(div.getAttribute("PageSize"))				//显示数==10
		var pCount = parseInt(div.hdataArray.length)	//总数量==15 
		var pStart = parseInt(div.getAttribute("PageStartIndex")-1);	//起点显示数 == 0 
		var barbg = document.getElementById(div.id.replace("listview_","lvwscrollbgbar"));
		if(barbg){
			var dHeight = parseInt(barbg.offsetHeight-34);		//显示区域像素==20
		}else{
			var dHeight = 20
			barbg  = document.createElement("span")
			barbg.innerHTML = "<table><tr><td></td><td></td><td></td></tr></table>"
		}
		if(pSize - pCount >= 0 || div.getAttribute("PageType") == "database"){
			barbg.children[0].style.display = "none";
			barbg.style.width = "0px"
			//barbg.style.display = "none";
			//div.style.borderRightWidth = "1px;"
		}
		else{
		
			var dt  = dHeight/pCount;
			var barTop    =  pStart*dt		//bar 已滚过高度
			var BarHeight = (pSize*dt-5)    //bar高度
			if(BarHeight< 6 ) {BarHeight = 6}
			bar = barbg.children[0]

			barbg.children[0].style.display = "";
			barbg.style.width = "15px"
			bar.style.marginTop = barTop + "px";
			div.style.borderRightWidth = "0px;"
			//bar.style.height = (BarHeight*1+10) + "px"; //加一个位置调整，让其自动刷新位置
			bar.style.height = (BarHeight) + "px";
			bar.maxTop = dHeight - BarHeight-4;
			bar.div = div;
			bar.mvindex = -1;
			//var list = window.getParent(div,4)
			//	alert("b")
			//list为listview区域
			//var ViewWidth = list.parentElement.offsetWidth;
			//var ListWidth = list.offsetWidth;
			//var ScrollLeft = list.parentElement.scrollLeft;
			///if(ListWidth - ScrollLeft - ViewWidth - 20>  0){
			//	bar.style.display = "none";
			//}
			//bar.style.left = "-" + parseInt(scrollbg.scrollLeft/2) + "px"
		}
	}
	,
	scrollbarmsdown : function(bar) { //模拟滚动条
		document.onselectstart = function(){return false}
		if(parseInt(bar.mvindex)>=0){
			mousemoveevents.del(bar.mvindex);
			mouseupevents.del(bar.upindex);
		}
		bar.mvindex =  mousemoveevents.add(lvw.scrollbarmove(bar))
		bar.upindex =  mouseupevents.add(lvw.scrollbarmsup(bar))
		bar.y = window.event.clientY;
		bar.t = bar.style.marginTop.replace("px","");
	}
	,
	scrollbarmove : function(bar){ //滚动条移动时候触发
		return function(){
			var nTop = bar.t*1 + (window.event.clientY - bar.y*1)
			if(nTop<0){nTop = 0}
			if(nTop>bar.maxTop){nTop = bar.maxTop;}
			bar.style.marginTop = nTop + "px";
			if(isNaN(bar.div.PageSize)){bar.div.PageSize=0}
			if(parseInt(bar.PageSize)<21){
				var currTop = parseInt(bar.style.marginTop.replace("px",""))
				var maxTop = parseInt(bar.maxTop);
				var barHeight = parseInt(bar.offsetHeight);
				var sIndex = bar.div.hdataArray.length * currTop / (maxTop+barHeight);
				bar.div.setAttribute("PageStartIndex", parseInt(sIndex) + 1);
				lvw.Refresh(bar.div);

			}
		}
	}
	,
	scrollbarmsup : function(bar){
		return function(){
			var currTop = parseInt(bar.style.marginTop.replace("px",""))
			var maxTop = parseInt(bar.maxTop);
			var barHeight = parseInt(bar.offsetHeight);
			var sIndex = bar.div.hdataArray.length * currTop / (maxTop+barHeight);
			mousemoveevents.del(bar.mvindex);
			mouseupevents.del(bar.upindex);
			bar.mvindex = -1;
			if(currTop==maxTop){
				sIndex = bar.div.hdataArray.length - bar.div.PageSize;
			}
			document.onselectstart = function(){return true}
			bar.div.setAttribute("PageStartIndex", parseInt(sIndex) + 1);
			lvw.Refresh(bar.div);
		}
	}
	,
	toolbarmove : function(button,cssName){
		if(!cssName){
			cssName = "mv"
		}
		button.parentElement.className = cssName;
	}
	,
	toolbarout : function(button){
		button.parentElement.className=""
	}
	,
	CreateExcel : function(button){//导出excel
		var t = new Date()
		var div = null
		if(button.tagName=="DIV"){div = button;}
		else{div = window.getParent(button,8).rows[1].cells[0].children[0]}
		var form = document.getElementById("lvw_excel_sendform") 
		if (!form)
		{
			var bllbox = document.getElementById("Bill_Info_id");
			var bid = bllbox ? bllbox.value : "0";
			form =  document.createElement("form");
			form.method = "post"
			form.target = "tmp_lvw_112_frame"
			form.action = ajax.defUrl();
			form.id = "lvw_excel_sendform"
			form.style.cssText = "display:inline"
			form.innerHTML = "<input type='hidden' name='__msgId' value='sys_ListView_CreateExcel'>"
							 + "<input type='hidden' id='lvw_excel_State'  name='State' value='" + div.state + "'>"
							 + "<input type='hidden' name='sendtime' value='" + t.getTime() + "'>"
							 + "<input type='hidden' name='sorttext' value='" + lvw.lvwsort + "'>"
							 + "<input type='hidden' name='bill_id' value='" + bid + "'>"
							 + "<iframe name='tmp_lvw_112_frame' borderframe=0 width=0 height=0></iframe>";
			document.body.appendChild(form);
		}
		else{
			form["sorttext"].value = lvw.lvwsort ;
			document.getElementById("lvw_excel_State").value = div.state;
		}
		form.submit();
	}
	,
	showMovePos : function(div) {
		var dlg = window.DivOpen("lvwrowpos","行位置调整",300, 150 ,'a','b',true,20);
		dlg.innerHTML = "<div style='margin:10px;margin-top:20px'><center><button class='button' onclick='lvw.rowmovePos(\"" + div.id + "\",-1)'>↑上移选中行</button><br><br><button class='button' onclick='lvw.rowmovePos(\"" + div.id + "\",1)'>↓下移选中行</button> </div>";
	}
	,
	rowmovePos : function (divid, pos) {
		var div =  document.getElementById(divid);
		lvw.TryCreateHiddenPageDataToArray(div)
		var ii = 0
		var nArray = new Array()
			var hs =  false;
		if (pos > 0)
		{
			
			//下移动
			for (var i = div.hdataArray.length - 2; i >=0  ; i--)
			{
				var p = div.hdataArray[i+1];
				if (div.hdataArray[i][1]=="1" &&  p[1]!=1)
				{
					div.hdataArray[i+1] = div.hdataArray[i];
					div.hdataArray[i] = p;
					hs = true;
				}
			}
		}
		else {
			//上移动
			for (var i = 1 ; i < div.hdataArray.length ; i++)
			{
				var p = div.hdataArray[i-1];
				if (div.hdataArray[i][1]=="1" &&  p[1]!=1)
				{
					div.hdataArray[i-1] = div.hdataArray[i];
					div.hdataArray[i] = p;
					hs = true;
				}
			}
		}
		if(hs == true ) {
			lvw.Refresh(div);
		}
		else {
			if(pos>0) {
				alert("已移到底部。")
			}
			else {
				alert("已移到顶部。")
			}
		}
	}
	,
	changeztlrselBox : function(box){  //当前整体录入的值有改动的时候，改变应用范围的默认状态为所有行
		if(event.propertyName!="value") { return false; }
		var td = window.getParent(box,5);
		var nexttd = td.nextSibling;
		var selbox = nexttd.getElementsByTagName("select")[0];
		if(!selbox.getAttribute("changedef")) {
			selbox.value = 1;
			selbox.setAttribute("changedef",1);
		}
	}
	,
	showAllInputDlg : function (button,isdiv) {  //整体录入功能
		var editcols = new Array()
		var html = ""
		var selhtml = ""
		var hsCol = false
		var div = null
		var hsxlh = false;
		if(isdiv){div=button}
		else{ div = window.getParent(button,8).rows[1].cells[0].children[0]}
		for (var i=0;i<div.children[0].rows[0].cells.length ; i++ )
		{
			var td = div.children[0].rows[0].cells[i];
			if ((td.edit == "1" || td.selid > 0) && td.getAttribute("disztlr") != "1" && td.getAttribute("htmlvisible")!="0") {
				 hsCol = true
				editcols[editcols.length] = td.innerText;
				selhtml = ""
				
				//Task.1232.binary.2013.12.20 增加整体录入递增的功能
				var isxlh = td.innerText.indexOf("序列号")>=0
				if(isxlh) {hsxlh = true;}
				if (!isNaN(td.selid) && td.selid.length>0){
						
					selhtml = "<button style='height:18px;' tabindex=999999999 ztlrbtn=1 ztlr=1 class=InselButton selid='" + td.selid + "' onfocus='this.blur()' onclick='if(this.selid!=\"10002\"){this.isKey=true;}try{lvw.focusSelButton();menu.showbtnlist(this)}catch(e){}'><img src='../../images/11645.png'></button>"
					html  = html + "<tr><td style='text-align:right;height:30px;width:100px'>" + td.innerText + "：</td><td style='width:180px;padding-left:10px;text-align:left;padding-right:10px'>" + 
						"<table><tr><td><input class=text type=text style='width:150px;border-right:0px' onkeyup = 'lvw.cellinputkeyup()' onchange='lvw.changeztlrselBox(this)' onpropertychange='lvw.changeztlrselBox(this)' ztlr=1 dtype='" + td.dtype + "' cellindex='" + i + "'></td>" + 
						"<td>" + selhtml  +  "</td></tr></table>" + 
						"</td><td><select onchange='this.setAttribute(\"changedef\",1)'><option value=1>所有行</option><option value=2>选中行</option><option value=3 selected>无</option></select></td>" + 
						"<td style='" + (isxlh ? "" : "display:none") + "'>&nbsp;<select><option>无</option><option value='1'>1</option><option value='-1'>-1</option></select></td></tr>"
				}
				else{
					html  = html + "<tr><td style='text-align:right;height:30px;width:100px'>" + td.innerText + "：</td><td style='width:180px;padding-left:10px;text-align:left;padding-right:10px'>" + 
						"<table><tr><td colspan=2><input class=text type=text style='width:168px' onkeyup = 'lvw.cellinputkeyup();'  onpropertychange='lvw.changeztlrselBox(this)' oldvalue=0 isEidtNumber=" + (td.dtype=="number" ? "1" : "0")  + " ztlr=1 dtype='" + td.dtype + "' cellindex='" + i + "'></td>" + 
						"</tr></table>" + 
						"</td><td><select onchange='this.setAttribute(\"changedef\",1)'><option value=1>所有行</option><option value=2>选中行</option><option value=3 selected>无</option></select></td>" + 
						"<td style='" + (isxlh ? "" : "display:none") + "'>&nbsp;<select><option>无</option><option value='1'>1</option><option value='-1'>-1</option></select></td></tr>"
				}
			}
		}
		var h = editcols.length*30+145
		var w = 500
		if (hsCol){html  =  "<tr><th>项目</th><th>新值</th><th>应用范围</th><th style='" + (hsxlh ? "" : "display:none") + "'>&nbsp;递增</th></tr>" + html;}
		else {
			h = h + 20;
			w = 400
			html  =  "<tr><td colspan=3 style='width:320px;height:30px;color:red;text-align:center'>该表格不允许用户编辑。</td></tr>"
		}
		
		if (h>560){h=560}
		var  dlg = window.DivOpen("lvwztlr","整体输入数据",w, h ,'a','b',true,20)
		
		
		dlg.innerHTML = "<div class=full style='text-align:center;overflow:auto'>" +
						"<div  style='border:1px solid #cccccc;border-left:1px solid #eeeeee;border-top:1px solid #eeeeee;margin:10px;background-color:#eeeef0;padding:10px'>" + 
						"<table forList='" + div.id + "'>" + html + "<tr><td colspan=3 style='text-align:center;height:30px'>" + 
						"<button class=button style='width:60px' onclick='if(lvw.setztlrvalue(this)){window.getParent(this,10).rows[0].cells[1].children[0].click()}'>确定</button>&nbsp;&nbsp;" + 
						"<button class=button style='width:60px' onclick='window.getParent(this,10).rows[0].cells[1].children[0].click()'>取消</button></td></table>" + 
						"</div></div>"
		dlg.children[0].listview = div;
	}
	,
    setztlrvalue: function (saveButton) { //保存整体录入的值
		var v = "" , vv = "" , tv = ""
		var tbody = window.getParent(saveButton,3)
		var div = window.getParent(tbody,3).listview
		
		if(!div) {alert("关联不到数据表");return false;}
		for (var i=1;i<tbody.rows.length-1;i++)
		{
			var tr = tbody.rows[i];
			var yy = tr.cells[2].children[0].value;
			var xlv = tr.cells[3].children[0].value;
			if(yy<3){
				var txtbox = tr.cells[1].children[0].rows[0].cells[0].children[0]
				v = txtbox.value
				vv = v ;
				tv = ""; //input 的 title 值
				if(txtbox.title.length>0) {v = txtbox.title ; tv = v }
				if(txtbox.dtype=="number" && v.length > 0 && isNaN(v))
				{alert("【" + tr.cells[0].innerHTML.replace("：","") + "】需要输入正确的数字") ; return false;}  
				if (txtbox.dtype=="date" && v.length > 0 && !lvw.isDate(v))
				{alert("【" + tr.cells[0].innerHTML.replace("：","") + "】需要输入正确的日期") ; return false;}
                lvw.ztlrsetcolvalue(div, txtbox.getAttribute("cellindex"), vv, tv, yy == '1', txtbox, xlv) //更新listview的一列值
                if (parent.window.ZtlrSetColValue) parent.window.ZtlrSetColValue(div,lvw,txtbox, v);
			}
		}
		lvw.formulaApplyAll(div);  //应用公式
		lvw.Refresh(div);
		return true;
	}
	,
	ztlrsetcolvalue : function(div,colindex,v,tv,all,tBox, xlvalue){ //更新listview的一列值
		var tb = div.children[0];
		var head = tb.rows[0];
		var basev = v;
		var numv = 0;
		var numvlen = 0;
		var hsxlh = false;
		if (xlvalue && xlvalue.length>0 && !isNaN(xlvalue))
		{
			var strl = v.length-1
			for (var i = strl; i >=0 ; i -- )
			{
				if(isNaN(v.substring(i)) || v.substring(i,1)=="." || v.substring(i,1)=="-") {;
					break;
				}
			}
			basev = v.substring(0,i+1);
			numv = v.replace(basev, "");
			numvlen = numv.length;
			hsxlh = true;
		}
		var lock = head.cells[colindex].getAttribute("lockExp");
		for (var i=0;i < div.hdataArray.length;i++)
		{
			if(all || div.hdataArray[i][1]==1){
				var r = false;
				if(lock && lock.length>0)
				{
					var code = lock.replace(/【/g,"lvw.getDataValueByName(div,i,\"").replace(/】/g,"\")");
					r = eval(code);
				}
				if(r==false) {
					if(hsxlh) {
						
						var currv = numv;
						if((currv + "").length < numvlen) {
							currv = ("A00000000000000000000000" + currv)
							currv = currv.substr(currv.length-numvlen);
						}
						v = basev + "" + currv;
						numv = numv*1 + xlvalue*1
						if(numv*1 < 0 ){
							numv = 0;
						}
					}
					var rv = v + lvw.sBoxSpr + tv;
					if(window.onztlrsetcol) {
						rv = window.onztlrsetcol(div.id, rv, i , colindex);
					}
					div.hdataArray[i][colindex] = rv ;
					if(tBox.JoinList){
						for (var ii = 1 ;ii < tBox.JoinList.length; ii++ )
						{
							var jv =  tBox.JoinList[ii];
							if(jv!="$0x-null") {
								div.hdataArray[i][colindex*1+ii] = tBox.JoinList[ii];
							}
						}
					}
				}
			}
		}
	}
	,
	showEditFindDlg : function(button){
		var div = window.getParent(button,8).rows[1].cells[0].children[0]
		var  dlg = window.DivOpen("lvweditfind","查找",450, 146 ,'a','b',true,20)
		dlg.innerHTML = "<div class='dlgbackdiv' style='width:407px;height:90px;padding:10px;border-right:1px solid white;'>" + 
						"<table><tr><td valign=b>查找(<u>I</u>):&nbsp;<input findex=0 type=input style='width:230px;height:18px;border:1px solid #ccc;'" +
						"class=text onkeydown='if(window.event.keyCode==13){ return lvw.editPageFind(this,0, event)}else{this.setAttribute(\"findex\",0)}'></td>" + 
						"<td style='padding-left:0px;padding-right:5px'><button style='font-family:Webdings;border:1px solid #ccc;border-left:1px solid white;width:17px;margin:0;margin-left:-1px;' onfocus='this.blur()' class=button><img src='../../images/i10.gif'></button>" +
						"</td><td><button class=button style='width:70px' onclick='return lvw.editPageFind(this.keytext,0, event)'>查找(<u>F</u>)</td></tr>" + 
						"<tr><td></td></tr>" +	
						"</table></div>"

		var keytext = dlg.children[0].children[0].rows[0].cells[0].children[1]
		keytext.listview = div
		dlg.children[0].children[0].rows[0].cells[2].children[0].keytext = keytext;
		
		//dlg.children[0].listview = div;
	}
	,
	editPageFind : function(keytext,  findtype, ev) { //查找对话框
		try{
					window.top.onkeySearching = 1;
					setTimeout(function(){	window.top.onkeySearching = 0;}, 200);
					var key = keytext.value
					var findCount = 0
					var rows = keytext.listview.hdataArray;
					if (findtype==0)  //查找
					{
						ev.stopPropagation ? ev.stopPropagation(): ev.cancelBubble=true;
						ev.keyCode = 0;
						ev.returnValue = false;
						if (key.length==0)
						{return false;}
						for (var i = 0;i < rows.length ; i ++ )
						{
							var  cells  = rows[i]
							for (var ii = 0 ; ii < cells.length ; ii++ )
							{
								if(cells[ii]){
									v = cells[ii].toString().split(lvw.sBoxSpr)[0]
									if (v.indexOf(key)>=0)
									{
										findCount = findCount + 1
										if(findCount > keytext.getAttribute("findex")){
											keytext.setAttribute("findex",findCount);
											var div = keytext.listview;
											div.setAttribute("PageStartIndex", 1*i+1);
											lvw.Refresh(div)
											lvw.UpdateScrollBar(div)
											var cell = div.children[0].rows[i-div.getAttribute("PageStartIndex")+2].cells[0]
											cell.innerText = "★" + cell.innerText
											
											lvw.editfocus(div.children[0].rows[i-div.getAttribute("PageStartIndex")+2].cells[ii])
											return false;
										}
									}
								}
							}
						}
						alert("未找到字符串\"" + key + "\"");
						return false;
					}
		}catch(e){}
	}
	,
	delsptwhereRow : function(delButton) {
		var tr = delButton.parentElement.parentElement
		var tb = tr.parentElement.parentElement
		var rIndex = tr.rowIndex
		tb.deleteRow(rIndex)
		tb.deleteRow(rIndex-1)
		var nHeight = tb.rows.length*24 + 90 
		nHeight = nHeight > 500 ? 500 : nHeight
		tb.parentElement.style.height = (nHeight - 90)  + "px" 
		window.DivUpdate(tb.lvwId,"","a",nHeight)
	}
	,
	selectboxchangePKList : function(tp) {
		if(tp + ""=="1") {
			return "<select style='margin-right:5px'><option value='>' title='大于'>＞</option>" + 
				 "<option value='>=' title='大于等于' >≥</option>" +
				 "<option value='<' title='小于'>＜</option>" + 
				 "<option value='<=' title='小于等于'>≤</option>" +
				 "<option value='<>' title='不等于'>≠</option>" +
				 "<option value=' like ' title='相似'>≈</option>" + 
				 "<option value='=' title='等于'>＝</option></select>"
		}
		else{
			return "<select><option value=' like ' title='相似'>≈</option></select>"
		}
	}
	,
	selectboxchange : function(box) {
		var opt = box.options[box.selectedIndex];
		var currp = box.getAttribute("currp") + "";
		var newrp = opt.getAttribute("csrc") + "";
		if (newrp != currp)
		{
			if(newrp=="1") {
				box.parentNode.parentNode.cells[2].innerHTML  = lvw.selectboxchangePKList(1) + "&nbsp;"
			}
			else{
				box.parentNode.parentNode.cells[2].innerHTML  = lvw.selectboxchangePKList(0) + "&nbsp;"
			}
			box.setAttribute("currp", newrp);
		}
	}
	,
	showFilterDlg  : function(button) {  //显示过滤对话框
		var div = window.getParent(button,8).rows[1].cells[0].children[0]
		var h =  110
		var dlg = window.DivOpen("lvwfilter_" +  div.getAttribute("FieldAttrSaveKey") ,"多条件数据筛选",480, h ,'a','b')
		dlg.innerHTML = "<table class=full><tr><td style='height:16px;color:#006600;text-align:left;padding-top:4px'><div style='width:100%;height:28px;overflow:auto'><b></b></div></td></tr>" + 
						"<tr><td style='text-align:right'>" + 
						"<table align=right class=lvwtoolbartable><tr>" + 
						"<td><button title='添加筛选条件' onmouseover='lvw.toolbarmove(this)' onmouseout='lvw.toolbarout(this)'><div style='height:20px;width:20px;background:url(../../images/smico/3.gif) no-repeat center center;overflow:hidden'>&nbsp;</div></button></td>" + 
						"<td><button title='执行条件' onmouseover='lvw.toolbarmove(this)' onmouseout='lvw.toolbarout(this)'><div style='height:20px;width:20px;background:url(../../images/smico/35.gif) no-repeat center center;overflow:hidden'>&nbsp;</div></button></td>" + 
						"<td><button title='清除当前表格中的查询条件' onmouseover='lvw.toolbarmove(this)' onmouseout='lvw.toolbarout(this)'><div style='height:20px;width:20px;background:url(../../images/smico/dele_1.gif) no-repeat center center;overflow:hidden'>&nbsp;</div></button></td>" + 
						"<td><button title='关闭' onmouseover='lvw.toolbarmove(this)' onmouseout='lvw.toolbarout(this)' onclick='window.getParent(this,12).rows[0].cells[1].children[0].click()'><div style='height:20px;width:20px;background:url(../../images/smico/1.gif) no-repeat center center;overflow:hidden'>&nbsp;</div></button></td>" + 
						"</tr></table></td></tr></table>"
		dlg.style.overflow = "auto"
		var addbutton = dlg.children[0].rows[1].cells[0].children[0].rows[0].cells[0].children[0];
		addbutton.listview = div;
		addbutton.td = dlg.children[0].rows[0].cells[0]; //添加条件按钮
		addbutton.onclick = function(){ 
			var tb = addbutton.td.children[0].children[0]
			tb.lvwId = "lvwfilter_" + div.getAttribute("FieldAttrSaveKey")
			if(tb.tagName!="TABLE"){
				var tr = addbutton.listview.children[0].rows[0]
				var fArray = ""
				for (var i =  0; i < tr.cells.length ; i ++ )
				{
					var cell = tr.cells[i]
					if(cell.oywname && cell.style.display!="none") {
						if(cell.innerText!=="查看" && cell.innerText!="操作" && cell.innerText.replace(/\s/g,"")!="下级关联单") {
							//fArray = fArray + "<option value='" + cell.oywname + "' dtype='" + cell.dtype + "'>" + cell.innerText + "</option>"
							fArray = fArray + "<option value='[" + cell.dbname + "]' ishtmlv='" + cell.getAttribute("ishtmlv") + "' csrc='" + cell.getAttribute("csrc") + "' dtype='" + cell.dtype + "'>" + cell.innerText + "</option>"
						}
					}
				}
				//binary.备注字段不能进行非like查询，所以通过选字段时联动运算符
				addbutton.td.children[0].innerHTML = "<table><tr><td style='width:80px;text-align:right;color:#000;height:24px'>条件1：&nbsp;</td><td>" +
										 "<select style='width:100px;margin:1px 5px 0 0' currp='1' onchange='lvw.selectboxchange(this)'>" + fArray + "</select></td><td>" + 
										  lvw.selectboxchangePKList(1) + "" +
										 "</td><td><input type=text class=text style='width:160px'></td><td style='width:60px'></td></tr></table>"
			}
			else{
				var t = new Date()
				var rndId = "A" + t.getTime().toString().replace(".","")
				var tr = tb.insertRow(-1)
				var td = tr.insertCell(-1)
				td.colSpan = 5
				td.style.cssText = "width:350px;padding-left:75px;height:24px"
				td.innerHTML = "<input type='radio' checked name='" +  rndId  + "'><label>并且</label>&nbsp;<input type='radio' name='" +  rndId  + "'><label>或者</label> " 
				var tr = tb.rows[0].cloneNode(true);
				tb.tBodies[0].appendChild(tr);
				tr.cells[4].innerHTML = "&nbsp;<input type='image' src='../../images/smico/del.gif' height='12px' title='删除该条件' onclick='lvw.delsptwhereRow(this)'>"
				var nHeight = tb.rows.length*24 + 90 
				nHeight = nHeight > 500 ? 500 : nHeight;
				tb.parentNode.style.height = (nHeight - 90)  + "px" 
				window.DivUpdate("lvwfilter_" +  div.getAttribute("FieldAttrSaveKey"),"","a",nHeight)
				for (var i=1;i<tb.rows.length ;i=i+2 )
				{
					var td = tb.rows[i].cells[0]
					td.children[0].id = "lvwfilter_ck_" + i + "_0"
					td.children[0].name = "lvwfilter_ck_" + i
					td.children[1].htmlFor = "lvwfilter_ck_" + i + "_0"
					td.children[2].id = "lvwfilter_ck_" + i + "_1"
					td.children[2].name = "lvwfilter_ck_" + i
					td.children[3].htmlFor = "lvwfilter_ck_" + i + "_1"
 				}
				
			}
		}
		var runbutton = dlg.children[0].rows[1].cells[0].children[0].rows[0].cells[1].children[0]; //执行按钮
		runbutton.onclick = function(){
			var tb = addbutton.td.children[0].children[0];
			var wherecode = new Array();
			var isnumber = false;
			for (var i=0; i<tb.rows.length ; i++ )
			{
				var tr = tb.rows[i];
				if(tr.cells.length>2){
					var sbox = tr.cells[1].children[0]; //onchange='this.dtype=this.options[this.selectedIndex].dtype
					switch(sbox.options[sbox.selectedIndex].dtype){
						case "number":
							if(isNaN(tr.cells[3].children[0].value) || tr.cells[3].children[0].value.length==0){
								alert("【" + sbox.value.replace("[#Fixed_","").replace("]","") + "】列需以数字作筛选条件。")
								tr.cells[3].children[0].focus();
								tr.cells[3].children[0].select();
								return false;
							}
							isnumber = true;
							break;
						case "date":
							if(!lvw.isDate(tr.cells[3].children[0].value) || tr.cells[3].children[0].value.length==0){
								alert("【" + sbox.value + "】列需以日期作筛选条件。")
								tr.cells[3].children[0].focus();
								tr.cells[3].children[0].select();
								return false;
							}
							break;
						default:
							break;
					}
					var sky = tr.cells[2].children[0].value;
					var skv = tr.cells[3].children[0].value;
	
					if(sky=="=") {
						if(sbox.options[sbox.selectedIndex].getAttribute("ishtmlv")=="1") {
							sky = " like ";
							skv = ">" + skv + "<";
						}
					}
					if (sky==" like ")
					{
						var sqlfiltermodel = div.getAttribute("sqlfiltermodel");
						if(sqlfiltermodel==1) {
							wherecode[i] = tr.cells[1].children[0].value +  sky + ("'%" + skv.replace(/\'/g,"''") + "%'").replace("%%%","%%");	
						}
						else{
							wherecode[i] = tr.cells[1].children[0].value +  sky + ("'*" + skv.replace(/\'/g,"''") + "*'").replace("***","**");
						}
					}
					else{
						if(isnumber==false || isNaN(skv)) {
							wherecode[i] = tr.cells[1].children[0].value +  sky + "'" + skv.replace(/\'/g,"''") + "'"
						}
						else{
							wherecode[i] = tr.cells[1].children[0].value +  sky + " " + skv + " "
						}
					}
					
				}
				else{
					wherecode[i] = tr.cells[0].children[0].checked ? "and" : ") or ("
				}
			}
			wherecode = '(' + wherecode.join(" ") + ')'
			ajax.regEvent("sys_ListView_CallBack")
			ajax.addParam("orderid",$("#orderid").val());
			ajax.addParam("State",div.state)
			ajax.addParam("filtertext",wherecode)
			r = ajax.send()
			if (r.indexOf("无法设置过滤条件")>0)
			{
				alert("过滤条件设置不正确。")
				return false;
			}
			var id = div.id;
			var bgid = id.replace("listview_","ctl_llvwframe_")
			var lvwFrame = document.getElementById(bgid)
			if(r.indexOf("errorinfos.asp")>0 && r.indexOf("work.zbintel.com")>0 ) {
				document.write(r);
				return;
			}
			lvwFrame.innerHTML = r
			div = document.getElementById(id)
			lvw.AutoToolAreaSize(div.children[0]);
			lvw.UpdateScrollBar(div);
			if(lvw.oncallback) {lvw.oncallback(div);}
		}

		var clearbutton = dlg.children[0].rows[1].cells[0].children[0].rows[0].cells[2].children[0];
		clearbutton.onclick = function(){
			ajax.regEvent("sys_ListView_CallBack")
			ajax.addParam("orderid",$("#orderid").val());
			ajax.addParam("State",div.state)
			ajax.addParam("filtertext","null")
			r = ajax.send()
			var id = div.id;
			var bgid = id.replace("listview_","ctl_llvwframe_")
			var lvwFrame = document.getElementById(bgid)
			lvwFrame.innerHTML = r
			div = document.getElementById(id)
			lvw.AutoToolAreaSize(div.children[0]);
			lvw.UpdateScrollBar(div);
			if(lvw.oncallback) {lvw.oncallback(div);}
		} 
		addbutton.onclick();
	}
	, 
	showColAttrDlg : function(button){  //用户自定义列的显示与隐藏以及别名
		var html = ""
		var selhtml = ""
		var div = window.getParent(button,8).rows[1].cells[0].children[0]
		var heads = div.children[0].rows[0].cells;
		
		var i=div.checkbox*1 + div.autoindex*1
		var ii = 0
		celllen = div.children[0].rows[0].cells.length
		while (i<celllen)
		{	
			
			var td = div.children[0].rows[0].cells[i]
			if (heads[i].oywname && heads[i].syshide.length==0)
			{		
					var currTitle = td.innerText;
					if(currTitle.indexOf("↑")==0 || currTitle.indexOf("↓")==0) {
						currTitle = currTitle.substring(1);
					}
					currTitle = currTitle.replace(/(^\s*)|(\s*$)/g, "") ;
					if (ii%2==0 && ii > 0){html = html + "<tr>"}
					var ck = heads[i].style.display=="none";
					var ywname = heads[i].oywname.replace(/\{us.+\}/g,"")
					var edit = heads[i].edit == "1" || (heads[i].selid && heads[i].selid.length > 0 && div.getAttribute("PageType")!="database");
					var ufsign = "" 
					if(ywname!=heads[i].oywname){ ufsign = heads[i].oywname.replace(ywname,"") }
					html  = html + 
					"<td style='text-align:right;height:35px;'><input ufsign=\"" + ufsign  + "\" type=text value='" + ywname + "' class=text readonly style='width:126px;height:20px;background-color:transparent;border:0px'></td>" +
					"<td style='text-align:right;height:35px;width:130px'><input type=text value='" + (currTitle== ywname?"":currTitle) + "' class=text style='width:120px;'></td>" +
					"<td style='width:40px;'><div style='padding:0px;line-height:40px;text-align:center;width:40px;height:40px;" + (ck ? "background-color:#FFF" : "") + "'><input style='' onfocus='this.blur()' " + (edit?"disabled":"") + " onclick='this.parentElement.style.backgroundColor=this.checked?\"#FFF\":\"transparent\";' type=checkbox " + (ck ? "checked" : "")  + "></div></td>"
					ii ++
					if (ii%2==0 && ii > 0){html = html + "</tr>"}
			}
			i++
			
		}
	
		if(ii%2!=0) { html = html + "</tr>" }
		var rowCount = parseInt(ii/2)
		if ((ii/2)!=parseInt(ii/2)){rowCount ++}
		h = rowCount *34 + 180
		var sptheight = (h-190) 
		sptheight = sptheight < 0 ? 1 : sptheight;

		html  =  "<tr><th style='height:35px'>内部名称</th><th>显示别名</th><th nowarop>隐藏</th><td style='width:2px;text-align:center;' align=center rowspan='" + (rowCount+1)  + "'>" + 
				"<div style='display:inline-block;width:2px;height:" + sptheight + "px;border-left:1px solid #aaa;background-color:#fff'></div>" + 
				"</td><th>内部名称</th><th>显示别名</th><th nowarop>隐藏</th></tr><tr>" + html

		if (h>560){h=560}
		var  dlg = window.DivOpen("lvwdefcol_" +  div.getAttribute("FieldAttrSaveKey") ,"列设置",700, h ,'a','b')
		
		
		dlg.innerHTML = "<div class=full style='text-align:center;overflow:auto;width:658px;'>" +
						"<div  style='margin:10px;background-color:#FFF;padding:10px'>" + 
						"<table>" + html + "<tr class='gray_button_tr' style='line-height:68px;'><td colspan=6 style='text-align:center;height:30px'>" + 
						"<button class=button style='width:60px'>确定</button>&nbsp;&nbsp;<button class=button style='width:60px'>还原</button>&nbsp;&nbsp;" + 
						"<button class=button style='width:60px' onclick='window.getParent(this,10).rows[0].cells[1].children[0].click()'>取消</button></td></table>" + 
						"</div></div>"
		var tb = dlg.children[0].children[0].children[0]
		var svbutton = tb.rows[tb.rows.length-1].cells[0].children[0]
		var debutton = tb.rows[tb.rows.length-1].cells[0].children[1]
		svbutton.onclick = function()
		{
			var dat = lvw.getcolattrconfig(tb);
			if(dat.length==0){return false}
			ajax.regEvent("sys_lvw_listviewcolattr");
			ajax.addParam("savekey",div.getAttribute("FieldAttrSaveKey"));
			ajax.addParam("savedata",dat)
			ajax.exec();
			window.getParent(svbutton,10).rows[0].cells[1].children[0].click();
			lvw.ReloadDataFormServer(div, {name:"sethtmlvisible",value:"1"});

		}
		debutton.onclick = function()
		{
			if(window.confirm("确定要清除设置吗？")){
				ajax.regEvent("sys_lvw_listviewcolattr_del");
				ajax.addParam("savekey",div.getAttribute("FieldAttrSaveKey"));
				ajax.exec();
				window.getParent(debutton,10).rows[0].cells[1].children[0].click();
			}

		}
		dlg.children[0].listview = div;
	
	}
	,
	WriteVar : function(varName) {
		try{return eval("var " + varName + " = true;" + varName);}
		catch(e){return false;}
	}
	,
	getcolattrconfig : function(tb) {  //获取listview列的用户定义属性
		var dat = new Array;
		var vName = ""; nv = ""
		for (var i=1;i<tb.rows.length -1; i++ )
		{
			var tr = tb.rows[i]
			if(tr.cells.length>=3){
				vName = tr.cells[1].children[0].value;
				nv = vName.replace("(","").replace(")","")
				if (vName.length > 0 && !lvw.WriteVar(nv)){alert("请为【" + tr.cells[0].children[0].value + "】字段定义正确的别名。\n\n说明：别名中不能包含标点符号、空格、特殊字符；不能以数字开始。");return "";}
				dat[dat.length] = tr.cells[0].children[0].value + "#" + tr.cells[1].children[0].value + "#" + tr.cells[2].children[0].children[0].checked*1
			}
			if (tr.cells.length > 4)
			{
				vName = tr.cells[1].children[0].value;
				nv = vName.replace("(","").replace(")","")
				if (vName.length > 0 && !lvw.WriteVar(nv)){alert("请为【" + tr.cells[3].children[0].value + "】字段定义正确的别名。\n\n说明：别名中不能包含标点符号、空格、特殊字符；不能以数字开始。");return "";}
				dat[dat.length] = tr.cells[3].children[0].value + "#" + tr.cells[4].children[0].value + "#" + tr.cells[5].children[0].children[0].checked*1
			}
		}
		return dat.join("$$")
	}
	,
	GroupToolUpdate : function(sBox) {
		var tr = sBox.parentElement.parentElement;
		var gItemBox = tr.cells[2].children[0];		//分组项目  
		var gTypeBox = tr.cells[5].children[0];		//分组
		gItemBox.dtype = gItemBox.options(gItemBox.selectedIndex).dtype
		gTypeBox.dtype = gTypeBox.options(gTypeBox.selectedIndex).dtype
		for(var i=0 ; i< gTypeBox.options.length ;i++){
			   if(gTypeBox.options(i).dtype != gItemBox.dtype && gTypeBox.options(i).dtype.length>0){
					 gTypeBox.options(i).disabled = true;
					 gTypeBox.options(i).style.backgroundColor = "#eee";
					 if(gTypeBox.selectedIndex==i){
						gTypeBox.selectedIndex = 0; 
					 }
			   }
			   else{
					gTypeBox.options(i).disabled = false;
					gTypeBox.options(i).style.backgroundColor = "#fff";
			   }
		}
		var id = tr.id.substr(0,tr.id.length-8)
		var defPan = document.getElementById(id + "_groupdefpanbg")
		defPan.style.display = (gTypeBox.value=="def"?"":"none");
		var defBody = document.getElementById(id + "_groupdefpan");
		if(defBody.innerHTML.length == 0){
			defBody.innerHTML = "<div style='margin-left:4px;;width:96%;height:87%;background-color:white;overflow-y:auto;overflow-x:hidden;border:1px solid #dededf'>"
							+ "<table id='" + id + "_gprdefTable' style='margin:1%;width:94%;background-color:#ffffff' cellSpacing=4>" 
							+ "<tr><td style='width:60px'>组名称</td><td>分组方式</td><td>临界值</td><th>&nbsp;</th></tr>"
							+ "</table></div>" 
							+ "<div style='width:100%;height:13%;text-align:center;padding-top:2%'><button class=button>添加</button>&nbsp;<button class=button>隐藏</button></div>"
			defBody.children[1].children[0].onclick = function(){
				var tb = defBody.children[0].children[0]
				if(tb.rows.length>=31){alert("目前暂时只支持最多30组自定义分类") ; return false}
				var tr = tb.insertRow(tb.rows.length)
				var cell = tr.insertCell(-1)
				cell.align = "center"
				cell.innerHTML = "<input type=text class=text style='width:60px'>"
				cell = tr.insertCell(-1)
				cell.align = "center"
				cell.innerHTML = "<span style='width:36px;height:16px;overflow:hidden;display:inline-block;border:1px solid #ccccee'><select style='width:40px;margin:-2px'><option value='='>=</option><option value='<'><</option><option value='>'>></option></select></span>"
				cell = tr.insertCell(-1)
				cell.align = "center"
				cell.innerHTML = "<input type=text class=text style='width:40px'>"
				cell = tr.insertCell(-1)
				cell.align = "center"
				cell.innerHTML = "<input type=image src='../../images/smico/del.gif' height='9px' title='删除该分组'>"
				cell.children[0].onclick = function(){
					tb.deleteRow(cell.parentElement.rowIndex);
				}
			}
			defBody.children[1].children[1].onclick = function(){
				defPan.style.display = "none"
			}
		}

		var tItemBox = tr.cells[8].children[0];		//统计项目  
		var tTypeBox = tr.cells[11].children[0];		//统计方式
		var tItype = tItemBox.options(tItemBox.selectedIndex).dtype
		var tTtype = tTypeBox.options(tTypeBox.selectedIndex).dtype
		if(tItype != tTtype && tTtype.length>0){
			tTypeBox.selectedIndex = 0
		}
		for (var i = 0; i < tTypeBox.options.length ; i++ )
		{
			var it = tTypeBox.options(i).dtype
			if(it.length>0 && it != tItype) {
				tTypeBox.options(i).disabled = true
			}
			else{
				tTypeBox.options(i).disabled = false
			}
		}
	}
	,
	showGroupImage : function(button){ //生成统计图
		var div = window.getParent(button,8).rows[1].cells[0].children[0];
		var fHeight = document.documentElement.offsetHeight;
		var FieldOptions = ""
		//此处w=body.offsetWidth会与document.body.onresize冲突，造成死循环，所以增加50偏移量
		var w = document.body.offsetWidth-50, h = fHeight-50 , t = 15 , l = 25
		var  dlg = window.DivOpen("groupimage" ,"统计分析图",w, h , t , l)
		document.body.onresize = function(){
			var mHeight = document.documentElement.offsetHeight;
			var w = document.body.offsetWidth-50, h = mHeight-50 , t = 15 , l = 25
			window.DivUpdate("groupimage","" ,w, h,t , l )
			dlg.style.padding = "0px"
			dlg.style.width = (dlg.style.width.replace("px","")*1 + 8) + "px"
			dlg.style.height = (dlg.style.height.replace("px","")*1 + 8) + "px"
		}

		dlg.style.padding = "0px"
		dlg.style.width = (dlg.style.width.replace("px","")*1 + 8) + "px"
		dlg.style.height = (dlg.style.height.replace("px","")*1 + 8) + "px"

		var  HRow = div.children[0].rows[0]
		for (var i=0 ; i< HRow.cells.length  ; i++)
		{
			var td = HRow.cells[i];
			if(td.oywname && td.style.display == "" && td.cangroup == "1"){
				FieldOptions = FieldOptions + "<option value='" + td.oywname + "' dtype='" + td.dtype + "'>" + td.innerText + "</option>"
			}
		}
		dlg.style.backgroundColor = "#efeff2";
		dlg.style.backgroundImage = "url(../../images/smico/gpbg1.jpg)";
		dlg.style.backgroundRepeat = "repeat-x"
		dlg.innerHTML = "<table style='width:100%;height:90%'>"
						+"<tr>"
						+"	<td height='24px' style='padding:0px;border-bottom:1px solid #bbb;border-top:1px solid white;border-left:1px solid white'>"
						+"		<div onselectstart='return false' style='width:100%;background-color:#eeeef2;padding:0px'>" 
						+"		<table style='margin:4px;'>"
						+"		<tr id='" + div.id + "_toolrow'><td style='width:20px'><img src='../../images/smico/41.gif'></td>"
						+"		<td nowrop><pre style='display:inline'>分组项目：</pre></td>"
						+"		<td><select onchange='lvw.GroupToolUpdate(this)'>" + FieldOptions + "</select></td>"
						+"		<td style='width:20px;height:20px' align=center><div style='width:1px;border-left:1px solid #ccc;background:white'></div></td>"
						+"		<td nowrop><pre style='display:inline'>分组方式：</pre></td>"
						+"		<td>"
						+"			<select onchange='lvw.GroupToolUpdate(this)' name='' style='font-family:宋体' title='默认为常规，对日期项目可按年月日分组'>"
						+"				<option value='' selected dtype=''>常规</option>"
						+"				<option value='def' dtype=''>自定义</option>"
						+"				<option value='year' dtype='date'>按年</option>"
						+"				<option value='month' dtype='date'>按月</option>"
						+"				<option value='day' dtype='date'>按天</option>"
						+"			</select>"
						+"		<td style='width:20px;height:20px' align=center><div style='width:1px;border-left:1px solid #ccc;background:white'></div></td>"
						+"		<td nowrop><pre style='display:inline'>统计项目：</pre></td>"
						+"		<td><select onchange='lvw.GroupToolUpdate(this)'>" + FieldOptions + "</select></td>"
						+"		<td style='width:20px;height:20px' align=center><div style='width:1px;border-left:1px solid #ccc;background:white'></div></td>"
						+"		<td><pre style='display:inline'>统计方式：</pre></td>"
						+"		<td>"
						+"			<select onchange='lvw.GroupToolUpdate(this)'>"
						+"				<option value='count' selected dtype=''>计数</option>"
						+"				<option value='sum' dtype='number'>求和</option>"
						+"				<option value='max' dtype='number'>最大值</option>"
						+"				<option value='min' dtype='number'>最小值</option>"
						+"				<option value='avg' dtype='number'>平均值</option>"
						+"				<option value='var' dtype='number'>方差</option>"
						+"				<option value='stdev' dtype='number'>标准偏差</option>"
						+"				<option value='stdevp' dtype='number'>总体标准偏差</option>"
						+"			</select>"
						+"		</td><td><button class=button  title='刷新图表' onclick='lvw.DrawGroupImage(\"" + div.id + "\")' style='height:19px;margin-left:3px'><img src='../../images/smico/22.gif' height=12></button></td><td>&nbsp;</td>"
						+"		</tr>"
						+"		</table></div>"
						+"	</td>"
						+"</tr>"
						+"<tr>"
						+"	<td style='height:95%;padding:1%;display:inline-block' align=center valign=top>"
						+"		<div style='left:16px;position:absolute;z-index:5000;height:80%;margin:0px;width:223px;border:1px solid white;border-right:1px solid #999;border-bottom:1px solid #999;float:left;background-image:url(../../images/smico/divbg.jpg);' id='" + div.id + "_groupdefpanbg'>"
						+"		<fieldset style='border:0px;padding-top:5px;height:98%;width:98%;margin:1%'><legend style='height:20px'><b>分组设置</b></legend><div style='text-align:center' class=full id='" + div.id + "_groupdefpan'></div></fieldset>"
						+"		</div>"
						+"		<div style='width:200px;height:22px;border:1px dotted orange;float:right;background-color:white;position:relative;top:-4px'>"
						+"		<input type='radio' name='gpimagetype' id='" + div.id + "_gpimagetype1'  onclick='lvw.DrawGroupImage(\"" + div.id + "\")'><label for='" + div.id + "_gpimagetype1'>柱形图</label>&nbsp;"
						+"		<input type='radio' name='gpimagetype' id='" + div.id + "_gpimagetype2'  onclick='lvw.DrawGroupImage(\"" + div.id + "\")'><label for='" + div.id + "_gpimagetype2'>扇形图</label>&nbsp;"
						+"		<input type='radio' name='gpimagetype' id='" + div.id + "_gpimagetype3'  onclick='lvw.DrawGroupImage(\"" + div.id + "\")'><label for='" + div.id + "_gpimagetype3'>折线图</label>&nbsp;"
						+"		</div><div id='" + div.id + "_ImageBody' style='overflow:auto;position:relative;border:1px solid #aaaaaf;top:10px;width:97%;height:90%;background-color:white;padding-top:10px;'>&nbsp;</div>"
						+"	</td>"
						+"</tr>"
						+"</table>"
						
						
		dlg.children[0].rows[0].cells[0].children[0].children[0].rows[0].cells[2].children[0].fireEvent("onchange");
	}
	,
	gpImageGrpDef : function(id){
		var tb = document.getElementById(id + "_gprdefTable")
		if(tb.rows.length==1){
			alert("没有设置分组");
			return "";
		}
		var defCode = new Array()
		for (var i=1;i<tb.rows.length ;i++ )
		{
			var tr = tb.rows[i]
			if(tr.cells[0].children[0].value.length==0){alert("分组设置中第" + i + "行需要输入组名称。");return "";}
			var v = tr.cells[2].children[0].value
			if (tr.cells[1].children[0].children[0].value != "=" && (v.length == 0 ||  (isNaN(v) && !lvw.isDate(v))))
			{alert("分组设置中第" + i + "行需要输入正确的临界值。\n\n如果是选择了“> 大于”或“< 小于”的方式分组，临界值需是数字或日期。" ); return "";}
			defCode[defCode.length] = tr.cells[0].children[0].value + "#spc$" + tr.cells[1].children[0].children[0].value + "#spc$" + v
 		}
		return defCode.join("#spt$")
	}
	,
	DrawGroupImage : function (id) {  //开始获取图像
		if (!document.namespaces['v']) {
			document.namespaces.add('v', 'urn:schemas-microsoft-com:vml', "#default#VML");
		}
		if (!document.namespaces['o']) {
			document.namespaces.add('o', 'urn:schemas-microsoft-com:office:office', "#default#VML");
		}
		var tbar = document.getElementById(id + "_toolrow")
		var mType = 0
		mType = document.getElementById(id + "_gpimagetype1").checked ? 1 : mType
		mType = document.getElementById(id + "_gpimagetype2").checked ? 2 : mType
		mType = document.getElementById(id + "_gpimagetype3").checked ? 3 : mType
		if(mType==0) { alert("请选择要生成的统计图类型【柱形图、扇形图、折线图】") ; return false }
		ajax.regEvent("Sys_lvw_GetGroupImageData")
		ajax.addParam("State",document.getElementById(id).state)	//回调状态值
		ajax.addParam("GroupByName", tbar.cells[2].children[0].value)	//分组项目
		ajax.addParam("GroupCode",   tbar.cells[5].children[0].value)	//分组方式
		ajax.addParam("mType",   mType)	//分组方式
		if(tbar.cells[5].children[0].value=="def"){
			var def = lvw.gpImageGrpDef(id)
			if (def.length == 0) {return false}
			ajax.addParam("GroupCodeDef",	def) //自定义分组值
		}
		ajax.addParam("CountItem",   tbar.cells[8].children[0].value)	//分组方式
		ajax.addParam("CountType",   tbar.cells[11].children[0].value)	//分组方式
		var  r = ajax.send()
		document.getElementById(id + "_ImageBody").innerHTML = r;
	}
	,
	toolbarclick : function(index,key){ //点击按钮导出
		var button = window.event.srcElement
		switch(key){
			case "excel": //导出excel
				lvw.CreateExcel(button)
				break; 
			case "ztlr":  //整体录入
				lvw.showAllInputDlg(button)
				break;
			case "find":  //在编辑页面查找
				lvw.showEditFindDlg(button)
				break;
			case "colattr"://设置列的显示属性
				lvw.showColAttrDlg(button) 
				break;
			case "filter"://设置数据筛选属性
				lvw.showFilterDlg(button);
				break;
			case "grouppic": //
				lvw.showGroupImage(button);
				break;
			case "drexcel":
				lvw.showexceldr(button);
				break;
			default:
				if (lvw.ontoolbarclick)
				{
					lvw.ontoolbarclick(index,key);
				}
				break;
		}
		window.returnValue = false;
		window.event.cancelBubble = true;
	}
	,
	showexceldr : function(button)
	{
		window.lvwexceldrdiv = window.getParent(button,8).rows[1].cells[0].children[0]
		var div = window.DivOpen("lvw_drExcel","导入资料",640,430,100,'a',true,20,true)
		var url = location.href;
		if(url.indexOf("?")>0) {url = url.split("?")[0];}
		if(url.indexOf("#")>0) {url = url.split("#")[0];}
		url = escape(url);
		var u = window.sys_verPath.replace("manufacture/inc/","load/newload/lvwdr.asp?url=" + url);
		if (window.location.href.toLowerCase().indexOf("manufacture/inc/bill.asp")>0)
		{
			var boid = (document.getElementById("bill_info_type")||document.getElementById("Bill_Info_type")).value;
			u = "../../load/newload/lvwdr.asp?url=" + url + "&sys_bid=" + boid;
			if(boid==12){
				u = u + "&__tagdataInit=1&__tagdata=" + (document.getElementsByName("MT4_MFRadio")[0].checked?"1":"2");
				u = u + "|" + document.getElementsByName("MT6")[0].value;
			}
		}
		div.innerHTML ="<iframe frameborder=0 scrolling='auto' src='" + u + "' style='width:100%;height:98%'></iframe>"
	}
	,
	HeaderMouseDown : function(THead) { //鼠标在标头上移动时候触发
		if(!window.ActiveXObject) {return true;}
		var w = THead.offsetWidth;
		var x = window.event.offsetX;
		var th = window.event.srcElement.tagName =="TH"
		var dw = 6
		var mHeader = null
		if(!th){return;}
		if (x<dw){if(THead.previousSibling && THead.previousSibling.resize == "1"){ mHeader=THead.previousSibling; }}
		if ((w-x)<dw){if(THead.resize == "1"){ mHeader=THead}}
		if(!mHeader) {return false}
		THead.style.cursor = "default";
		mHeader.style.cursor = "w-resize";
		lvw.setHeaderColBorder(mHeader,true)
		
		var TRow = mHeader.parentElement;
		for(var i=0;i<TRow.cells.length;i++){
			if(TRow.cells[i].style.width.length==0){
				try{TRow.cells[i].style.width = (TRow.cells[i].offsetWidth-2) + "px";}
				catch(e){}
			}
		}
		mHeader.mouseDownX   = window.event.clientX;
		mHeader.pareneTdW    = mHeader.offsetWidth;
		mHeader.pareneTableW = mHeader.parentElement.parentElement.offsetWidth;
		mHeader.resizeing = true;
		mHeader.setCapture();
		var t = new Date()
		mHeader.currTime = t.getTime();
	} 
	,
	setHeaderColBorder : function(mHeader,isBold){
		var tb = mHeader.parentElement.parentElement;
		var cellIndex = lvw.cellIndex(mHeader);
		var b = isBold ? "3px solid #0000aa" : "1px solid #ccccee" ;
		for (var i=0;i<tb.rows.length ; i ++ )
		{
			try{tb.rows[i].cells[cellIndex].style.borderRight = b;}catch(e){}
		}
	}
	,
	HeaderMouseMove : function(THead,update) { //鼠标在标头上移动时候触发 * 实现表格宽度调整
		if(!window.ActiveXObject) {
			$(THead).TableColResize(function(e){
				//lvw.saveColSizeData(e.data.tb);  还有问题，暂时放过
			});
			return true;
		}
		if(THead.resizeing!=true){
			var w = THead.offsetWidth;
			var x = window.event.offsetX;
			var th = window.event.srcElement.tagName =="TH"
			var dw = 6
			if(!th){return;}
			if (x<dw){if(THead.previousSibling && THead.previousSibling.resize == "1"){THead.style.cursor = "w-resize";return}}
			if ((w-x)<dw){if(THead.resize == "1"){THead.style.cursor = "w-resize";return;}}
			THead.style.cursor = "default";
		}
		else{
			var t = new Date();
			t = t.getTime();
			var currt = THead.currTime;
			if(t - currt < 100 && !update){return false;} //加个时间间隔判断，降低消耗
			else{THead.currTime = t;}  
			if(!THead.mouseDownX) return false;
			var newWidth=THead.pareneTdW*1+window.event.clientX*1-THead.mouseDownX;
			if(newWidth > 0)
			{
				THead.style.display = "block"
				THead.style.width = newWidth;
				var tb = window.getParent(THead,3);
				lvw.AutoToolAreaSize(tb)
			}	
		}
	}
	,
	saveColSizeData : function(tb) {
		//**********保存调整***************
		 var key = ""
		 var url = window.location.pathname.toLowerCase().replace(".asp","").replace(/\//g,"x#").replace(/\./g,"d#")
		 var tr = tb.rows[0]
		 var hdtext = ""
		 var wLen = new Array();
		 for (var i=0;i<tr.cells.length ;i++ )
		 {
			if(tr.cells[i].resize=="1"){
				hdtext = hdtext +  tr.cells[i].innerText.replace(/\s/g,"")
				wLen[wLen.length] = tr.cells[i].offsetWidth
			}
		 }
		
		 if(hdtext.length>10){
			key = url + hdtext.substr(5,5) + hdtext.length;
		 }
		 else{
			key = url + hdtext  +  hdtext.length;
		 }
	
		 ajax.regEvent("sys_lvw_savecolwidth");
		 ajax.addParam("cookieName","LvwColWidth_" + key)
		 ajax.addParam("cookieValue",wLen.join("|"))
		 ajax.exec()
		 //*********************************
	}
	,
	HeaderMouseUp : function(THead) { //鼠标在标头上移动时候触发
		if(!window.ActiveXObject) {return true;}
		if(THead.resizeing==true){
			 lvw.HeaderMouseMove(THead,true);
			 THead.releaseCapture();
			 THead.mouseDownX=0;
			 lvw.setHeaderColBorder(THead,false)
			 THead.style.cursor = "default";
			 THead.resizeing = false
			 var div = window.getParent(THead,4)
			 lvw.UpdateScrollBar(div) ;//更新滚动条
			 lvw.saveColSizeData(div.children[0]);
		}
	}
	,
	ColDataSort : function(span, st) {
			//Task.1121.binary.2013.12.10.提交排序
			var div = window.getParent(span,5);
			var th = span.parentNode;
			var sorttext = (st==1 ? "[" + th.getAttribute("dbname") + "]" : "[" + th.getAttribute("dbname") + "] desc");
			ajax.regEvent("sys_ListView_CallBack")
			ajax.addParam("orderid",$("#orderid").val());
			ajax.addParam("State",div.state);
			ajax.addParam("SortText", sorttext);
			lvw.lvwsort = sorttext;
			r = ajax.send()
			var id = div.id;
			var bgid = id.replace("listview_","ctl_llvwframe_")
			var lvwFrame = document.getElementById(bgid);
			lvw.savecurrColWidth(id);
			if (r.indexOf("<div")==0)
			{
				lvwFrame.innerHTML = r;
			}
			else{
				document.write(r);
			}
			div = document.getElementById(id);
			lvw.AutoToolAreaSize(div.children[0]);
			lvw.UpdateScrollBar(div);
			if(lvw.oncallback) {lvw.oncallback(div);}
			lvw.setcurrColWidth(id);
	}
	,
	savecurrColWidth : function (id) {
		//Task.1121.binary.2013.12.10.保存当前列的宽度，用于服务端刷新
		var bgid = id.replace("listview_","ctl_llvwframe_");
		var lvwFrame = document.getElementById(bgid);
		var div = document.getElementById(id);
		var tb = div.children[0];
		var cells = tb.rows[0].cells;
		var cellinfos = new Array();
		for (var i = 0; i < cells.length ; i ++ )
		{
			var th = cells[i];
			cellinfos[cellinfos.length] = [th.getAttribute("dbname") , th.style.width  ];
		}
		lvwFrame.setAttribute("cellinfos", cellinfos);
	}
	,
	setcurrColWidth : function (id) {
		//应用当前列的宽度，用于服务端刷新
		var bgid = id.replace("listview_","ctl_llvwframe_");
		var lvwFrame = document.getElementById(bgid);
		var cellinfos = lvwFrame.getAttribute("cellinfos");
		var div = document.getElementById(id);
		var tb = div.children[0];
		var cells = tb.rows[0].cells;
		try
		{
			for (var i = 0; i < cells.length ; i ++ )
			{
				var th = cells[i];
				th.style.width = cellinfos[i][1];
			}
		}
		catch (e){}
		
	}
	,
	UpdateAllScroll : function(){ //更新所有滚动条显示状态
		var divs = document.getElementsByTagName("div");
		for (var i=0;i<divs.length;i++)
		{
			var dv = divs[i]
			if(dv.id.indexOf("listview_")>=0){
			
				lvw.UpdateScrollBar(dv)
			}
		}
	}
	,
	dbcheck : function(ckbox,id){
		var ck = true , ibox = null
		var div = document.getElementById("listview_" + id);
		var tb = div.children[0];
		for (var i = 1; i < tb.rows.length ; i++ )
		{
			ibox = tb.rows[i].cells[0].getElementsByTagName("input")
			if(ibox.length>0){
				if(ibox[0].type=="checkbox"){
					if(ibox[0].checked == false){
						ck = false
						break;
					}
				}
			}
		}
		
		ibox = tb.rows[0].cells[0].getElementsByTagName("input")
		if(ibox.length>0){
			ibox[0].checked = ck;
		}
		
	}
	,
	dbcheckall : function(ck,id){
		var div = document.getElementById("listview_" + id);
		var tb = div.children[0];
		for (var i = 1; i < tb.rows.length ; i++ )
		{
			var ibox = tb.rows[i].cells[0].getElementsByTagName("input")
			if(ibox.length>0){
				if(ibox[0].type=="checkbox"){
					ibox[0].checked = ck
				}
			}
		}
	}
	,
	expNode : function(imgObj,nodetype){ //nodetype=0 表示根节点 ， 1表示子节点 
		if(!imgObj.getAttribute("expType")){ imgObj.setAttribute("expType","0");}
		var oexptype =  imgObj.getAttribute("expType");
		if( imgObj.getAttribute("expType") == "0") {
			imgObj.setAttribute("expType","1");
			if(nodetype==0) {
				imgObj.src = imgObj.src.replace("7.gif","8.gif")
			}
			else{
				imgObj.src = imgObj.src.replace("4.gif","9.gif").replace("10.gif","11.gif");
			}
		}
		else{
			imgObj.setAttribute("expType","0");
			if(nodetype==0) {
				imgObj.src = imgObj.src.replace("8.gif","7.gif")
			}
			else{
				imgObj.src = imgObj.src.replace("9.gif","4.gif").replace("11.gif","10.gif");
			}
		}
	
		var dpy   = imgObj.getAttribute("expType") == "1" ? "none" : ""
		var hide  = imgObj.getAttribute("expType") == "1" ? true : false
		var tb = window.getParent(imgObj,4)
		var deep = tb.deep;
		var td = window.getParent(tb,5);
		var cIndex = td.cellIndex;
		var tr = td.parentElement;
		var rows = tr.parentElement.rows;
		var nftd= imgObj.parentElement.nextSibling;
		nftd.className = hide ? "lvwtreenode2" : "lvwtreenode3"

		for (var i = tr.rowIndex + 1; i< rows.length ;i++)
		{
			td = rows[i].cells[cIndex];
			var tbs = td.getElementsByTagName("table");
			for(var ii = 0 ; ii < tbs.length ; ii++ ){
				if(tbs[ii].className=="lvwtreenode"){
					if((tbs[ii].deep*1-deep)<=0){
						return;
					}
					if((tbs[ii].deep*1-deep)==1 || dpy.length>0){
						rows[i].style.display = dpy; 
					}
					if(tbs[ii].getAttribute("hschild")=="1"){
						var img = tbs[ii].getElementsByTagName("img")[0];
						if(hide){
							img.setAttribute("oldexpType",img.getAttribute("expType"));
							img.setAttribute("expType","0");
							//lvw.expNode(img,1);
						}
						else{
							if(img.getAttribute("oldexpType")=="0"){ //子要被展开
								img.setAttribute("expType","1");
							}else{
								img.setAttribute("expType","0");
							}
							lvw.expNode(img,1);
						}
					}
					ii = tbs.length
				}
			}
		}
	}
}

lvw.items = function(index){
	var divs = document.getElementsByTagName("DIV");
	var x = 0
	for (var i = 0; i < divs.length ; i++ )
	{
		if(divs[i].getAttribute("PageType") && divs[i].getAttribute("FieldAttrSaveKey")){
			if(index==x){
				return divs[i]
			}
			x ++
		}
	}
	return null
}

lvw.getTreeNodes = function(tr){ //根据当前行，获取tree模式下的节点序列。
	var r = new Array()
	r[0] = tr
	var rows = tr.parentElement.rows; 
	var cindex =  lvw.getCellIndexByName("",tr,"lvw_treenodedeep");
	var deep = lvw.getCellValue(tr.cells[cindex])
	for (var i = tr.rowIndex-1;i>0 ;i-- )
	{
		var newdeep =  lvw.getCellValue(rows[i].cells[cindex])
		if(deep-newdeep>0){
			r[r.length] = rows[i];
			deep = newdeep;
		}
			
	}
	return r;
}



function ListViewInit(){ //出事化listview 包括滚动条 ， 隐藏数据
	var divarr = new Array() //id重名检测数据
	var divs = document.getElementsByTagName("div")
	for(var i = 0 ; i< divs.length ;i ++ ) {
		var id = divs[i].id
		if( id.indexOf("listview_") >=0 ) {
			var hs = false
			for (var ii = 0 ; ii < divarr.length ;ii++ )
			{
				if (id == divarr[ii]){
					hs = true
					alert("设计检测提示：\n\nListView有漏洞,出现同名表格" + id + "。		\n\n该情况可能导致界面显示不正确(如滚动条等效果)")
				}
			}
			if(!hs){divarr[divarr.length] = id;}
			if (divs[i].getAttribute("bgcolorExp")*1>0)
			{
				lvw.Refresh(divs[i]);
			}
			lvw.UpdateScrollBar(divs[i]);
		}
	}
}



initevents.add(ListViewInit);

if(document.body) {
	var cphandel  = null;
	if(document.body.oncopy) {
		cphandel = document.body.oncopy;

	}
	document.body.oncopy = function() {
		if(cphandel) {
			var a = cphandel();
			if(a==false) {
				return false;
			}
		}
		try{
			disCopyHideData();
		}catch(e){}
	}
}

function disCopyHideData() {
	var cells = new Array();
	var tbs = document.getElementsByTagName("table");
	for(var i = 0 ; i < tbs.length; i++) {
		if(tbs[i].className=="listviewframe") {
			var ths = tbs[i].getElementsByTagName("th");
			for (var ii = 0; ii < ths.length ; ii++)
			{
				var th = ths[ii];
				if(th.style.display == "none") {
					cells[cells.length] = [th , th.innerHTML];
					th.innerHTML = "";
				}
			}

			var tds = tbs[i].getElementsByTagName("td");
			for (var ii = 0; ii < tds.length ; ii++)
			{
				var td = tds[ii];
				if(td.style.display == "none") {
					cells[cells.length] = [td , td.innerHTML];
					td.innerHTML = "";
				}
			}
		}
	}
	setTimeout(function() {
		for (var i = 0; i < cells.length ; i ++ )
		{
			cells[i][0].innerHTML = cells[i][1];
			cells[i][0] =  null;
		}
		cells = null;
	
	},500);
}

function _lvw_pageindex_maxnumcheck(box) {
	var maxv = parseInt(box.getAttribute("maxvalue"));
	var currv = parseInt(isNaN(box.value) ?  1 : box.value);
	if(currv>maxv) { box.value = maxv ; return; }
	if(currv<1) { box.value = 1 ; return; }
	box.value = currv;
}
function FormatNumber(srcStr, nAfterDot)        //nAfterDot表示小数位数
{
    var srcStr, nAfterDot;
    var resultStr, nTen;
    srcStr = "" + srcStr + "";
    strLen = srcStr.length;
    dotPos = srcStr.indexOf(".", 0);
    if (dotPos == -1) return resultStr = srcStr + "." + Array(nAfterDot + 1).join("0");
    else {
        if ((strLen - dotPos - 1) >= nAfterDot) {
            nAfter = dotPos + nAfterDot + 1;
            nTen = 1;
            for (j = 0; j < nAfterDot; j++) {
                nTen = nTen * 10;
            }
            resultStr = (Math.round(parseFloat(srcStr) * nTen) / nTen) + "";
            strLen = resultStr.length;
        }
        else {
            resultStr = srcStr;
        }
        if (resultStr.indexOf(".", 0) == -1) {
            resultStr = resultStr + ".";
            strLen += 1;
        }
        return resultStr + Array(nAfterDot - strLen + dotPos + 1 + 1).join("0");;
    }
}
function checkDot(value, num_dot) {
    var txtvalue = ""+value;//正则获取的是数字
    if (txtvalue.indexOf('.') > 0) {
        var txt1, txt2, txt3;
        txt1 = txtvalue.split('.');
        txt2 = txt1[0];
        txt3 = txt1[1];
        if (txt2.length > 12) {//整数部分不能大于12位
            txt2 = txt2.substr(0, 12);
        }
        if (txt3.length > num_dot) {//小数部分不能大于8位
            txt3 = txt3.substr(0, num_dot);
        }
        txtvalue = txt2 + "." + txt3;
    }
    else if (txtvalue.length > 12) {//整数不能超过12位
        txtvalue = txtvalue.substr(0, 12);
    }
    return txtvalue
}
function checkNumDot(value, num_int,num_dot) {
	var txtvalue = "" + value;//正则获取的是数字
	if (txtvalue.indexOf('.') > 0) {
		var txt1, txt2, txt3;
		txt1 = txtvalue.split('.');
		txt2 = txt1[0];
		txt3 = txt1[1];
		if (txt2.length > num_int) {//整数部分不能大于num_int位
			txt2 = txt2.substr(0, num_int);
		}
		if (txt3.length > num_dot) {//小数部分不能大于num_dot位
			txt3 = txt3.substr(0, num_dot);
		}
		txtvalue = txt2 + "." + txt3;
	}
	else if (txtvalue.length > num_int) {//整数不能超过num_int位
		txtvalue = txtvalue.substr(0, num_int);
	}
	return txtvalue
}