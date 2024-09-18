//生产订单脚本
var me = new Object();
me.ckCount = 0;
me.http = Bill.ScriptHttp();
me.showrowseting = function(a){
	var div = window.DivOpen("asdasdscv","参数设置 - 核定产量运算",800,500,'a','b',1,15);
	var tr = window.getParent(a,7);
	var disref = lvw.getCellValueByName("",tr,"disrefku")
	if (disref !=0 && disref!=1){disref = 0}
	var html = "<table style='width:750px;margin-left:5px;background-color:f0f0f0;line-height:24px;color:#2f496e;margin-top:10px'><tr><td align='right'  width='100'>产品名称：</td><td colspan=5>" + tr.cells[3].innerText + "</td><td colSpan=2 align='center' rowSpan=2><button onclick='me.RefreshProductNum()' class='wavbutton' style='line-height:18px'>刷新数据</button></td></tr>";
	html = html + "<tr><td align='right' width='100'>核定产量：</td><td colspan=5><input type=text readonly style='border:0px' class=text value='" + lvw.getCellValueByName("",tr,"核定产量") + "'> （当前设置的数量）</td></tr>" + 
				  "<tr><td align='right'  width='100'>采购未入库数：</td><td id='ac_num1' width='110'></td><td align='right'  width='100'>已申请未入库：</td><td width='110' id='ac_num2'></td>" + 
				  "<td align='right'  width='100'>合同未出库：</td><td id='ac_num3' width='110'></td><td align='right' width='100'>已申请未出库：</td><td id='ac_num4' width='110'></td></tr>" + 
				  "</table>"

	var btype = lvw.getCellValueByName("",tr,"可用库存计算方式");  //可用库存计算方式
	html = html + "<div style='background-color:white;padding:10px;padding-left:4px;'><b>可用库存</b></div>"
	html = html + "<fieldSet style='display:block;margin-left:5px;margin-right:15px;border:0px;background-color:#f0f0f0;padding:5px;'><legend style='background-color:white'>计算规则：</legend><div style='margin:5px;'>可用库存 = 现有库存 + <select id='btype1'><option value=0>无</option><option value=100 " + (parseInt(btype/100)==1 ? "selected" : "") + ">已申请未入库</option><option value=200 " + (parseInt(btype/100)==2 ? "selected" : "") + ">已采购未入库</option></select> - <select id='btype2'><option value=0>无</option><option value=10 " + (btype%100==10 ? "selected" : "") + ">已申请未出库</option><option value=20 " + (btype%100==20 ? "selected" : "") + ">合同未出库</option></select>&nbsp;应用范围：<input type=radio name=aflists id=afw_0001 checked><label for=afw_0001>当前行</label>&nbsp;<input type=radio name=aflists id=afw_0002><label for=afw_0002>勾选行</label><input type=radio name=aflists id=afw_0003><label for=afw_0003>整个清单</label></div></fieldSet>"

	html = html + "<div style='background-color:white;padding:10px;padding-left:4px;padding-bottom:4px;'><b>现有库存参考仓库</b><br>&nbsp;&nbsp;&nbsp;&nbsp;<span style=color:red>说明：需求数量减去当前参考仓库中的库存总数是计算产品核定产量的一个步骤。</span><br>"

    
	me.currRowNewCk  = lvw.getCellValueByName("",tr,"参考仓库");
	var ckck = "|" + me.currRowNewCk + "|";  //获取当前行的仓库
	html  = html + "<div style='position:relative;width:370px;top:5px;left:20px;background-color:white;z-index:100;'><input style='display:none' type=checkbox " + ( ckck=="|-1|" ? "checked" : "") + " id=cckall onclick='me.ckselectall(this)'><label for=cckall style='display:none'>全选</label>&nbsp;" +
	"&nbsp;生产清单应用范围：<input type=radio name=awlists id=awl_0001 checked><label for=awl_0001>当前行</label>&nbsp;<input type=radio name=awlists id=awl_0002><label for=awl_0002>勾选行</label>" + 
	"&nbsp;<input type=radio name=awlists id=awl_0003><label for=awl_0003>整个清单</label></div>" +
	"<div id='kunumlist' style='position:relative;top:-10px;margin:6px;border:1px dashed #aaa;padding:5px;height:120px;overflow:auto;padding-top:10px;'></div>"
	html = html + "</div><center><button class=wavbutton style='width:60px;margin-top:2px' onclick='me.applyck(this)'>确定</button>&nbsp;<button class=wavbutton style='width:60px;margin-top:2px' onclick='window.DivClose(this)'>取消</button></center>"
	div.innerHTML = html;
	div.soureObject = a;
	me.currRow = tr;
	me.UpdateStoreBindType(btype) ; //根据仓库计算类型，获取仓库库存
	me.RefreshProductNum(); //获取产品的相关运算数据
}

me.RefreshProductNum = function() {
	//获取产品相关数量：已采购未入库、已申请未入库等等
	var tr = me.currRow;
	var p = lvw.getCellValueByName("",tr,"productID");
	var u = lvw.getCellValueByName("",tr,"单位ID");
	me.http.regEvent("B2_RefreshProductNum");
	me.http.addParam("product",p);
	me.http.addParam("unit",u);
	var r = me.http.send()
	var n = r.split("|")
	if(n.length==4) {
		document.getElementById("ac_num1").innerHTML = "<a href='javascript:void(0)' class='link' onclick='window.PageOpen(\"bScript/B2_ProductNumList.asp?btype=1&product=" + p + "&unit=" + u +"\",860,640,\"sdffc\")'>" + n[0] + "</a>";
		document.getElementById("ac_num2").innerHTML = "<a href='javascript:void(0)' class='link' onclick='window.PageOpen(\"bScript/B2_ProductNumList.asp?btype=2&product=" + p + "&unit=" + u +"\",860,640,\"sdffc\")'>" + n[1] + "</a>";
		document.getElementById("ac_num3").innerHTML = "<a href='javascript:void(0)' class='link' onclick='window.PageOpen(\"bScript/B2_ProductNumList.asp?btype=3&product=" + p + "&unit=" + u +"\",860,640,\"sdffc\")'>" + n[2] + "</a>";
		document.getElementById("ac_num4").innerHTML = "<a href='javascript:void(0)' class='link' onclick='window.PageOpen(\"bScript/B2_ProductNumList.asp?btype=4&product=" + p + "&unit=" + u +"\",860,640,\"sdffc\")'>" + n[3] + "</a>";
	}
	else {
		alert(r);
	}
}

me.UpdateStoreBindType = function(bType) {
	if(!bType) { //bType更改事件中调用该方法则不传递该参数过来，需要直接通过html元素获取
		bType = document.getElementById("btype1").value*1 + document.getElementById("btype2").value*1
	} 
	var tr = me.currRow;
	me.http.regEvent("B2_GPSL");
	me.http.addParam("product",lvw.getCellValueByName("",tr,"productID"));
	me.http.addParam("unit",lvw.getCellValueByName("",tr,"单位ID"));
	me.http.addParam("btype",bType);
	var r = me.http.send()
	var ckck = "|" + me.currRowNewCk + "|";  //获取当前行的仓库
	var html = "<table style='display:block;width:100%'>"
	if(r.length>0){
	
		var row = r.split("#tr#");
		for (var i = 0 ; i<row.length ; i++ )
		{
			if(i%4==0) { if(i>0){html = html + "</tr>"} html = html + "<tr>";}
			var cell = row[i].split("#td#");
			var ck = (ckck=="|-1|"||ckck.indexOf("|" +cell[1] + "|") >=0) ? "checked" : ""
			var bc = ck == "checked" ? "bgcolor=#ffff66" : ""
			if(cell[2]>0){
				html  = html + "<td " + bc + "><input onclick='me.ckselect(this)' tag='" + cell[1] + "' name='stcki' type=radio " + ck + " id='stcki_" + i + "'><label for='stcki_" + i + "' style='display:inline'>" + cell[0] + "(<b style='color:red'>" + cell[2] + "</b>)</label></td>"
			}else{
				html  = html + "<td " + bc + "><input onclick='me.ckselect(this)' tag='" + cell[1] + "' name='stcki' type=radio " + ck + " id='stcki_" + i + "'><label for='stcki_" + i + "' style='display:inline'>" + cell[0] + "(" + cell[2] +  ")</label></td>"
			}
		}
		me.ckCount  = row.length
	}
	else{
		html = html + "<tr><td><span style=color:blue>所有仓库都没有库存</span></td></tr>"
	}
	html = html + "</tr></table>"
	document.getElementById("kunumlist").innerHTML = html;
}

me.setWLList = function(){
	var index = lvw.getCellIndexByName("",me.currRow,"bomid");
	var index2 = lvw.getCellIndexByName("",me.currRow,"核定产量");
	var planbom = lvw.getCellValue(me.currRow.cells[index]);
	var initnum = lvw.getCellValue(me.currRow.cells[index2]);
	var opener = window.open("bill.asp?orderid=26&parentID=" + planbom + "&initNum=" + initnum,"abccc","width=900px,height=600px,left=" + ((screen.availWidth-900)/2) + "px,top=" + ((screen.availHeight-600)/2) + "px,resizable=1")
	opener.focus();
}

me.updateRow = function(tr,div, rs ,eventRow, updateType){
	var sDat = ""
	var index = new Array()
	index[1] = lvw.getCellIndexByName("",tr,"bomid")
	index[2] = lvw.getCellIndexByName("",tr,"planlistid")
	index[3] = lvw.getCellIndexByName("",tr,"参考仓库")
	index[4] = lvw.getCellIndexByName("",tr,"核定产量")
	index[5] = lvw.getCellIndexByName("",tr,"ordfield")
	index[6] = lvw.getCellIndexByName("",tr,"开工期")
	index[7] = lvw.getCellIndexByName("",tr,"完工期")
	index[8] = lvw.getCellIndexByName("",tr,"可用库存计算方式")
	index[9] = lvw.getCellIndexByName("",tr,"本次计划")
	index[10] = lvw.getCellIndexByName("",tr,"已生产")
	eventRow = '|' + eventRow.join("|") + '|'
	for (var i = 1; i <rs.length-1 ; i ++ )
	{	
		for (ii=1;ii<index.length ;ii++ )
		{
			sDat = sDat + lvw.getCellValue(rs[i].cells[index[ii]]) + '--'
		}
		sDat = sDat + (eventRow.indexOf('|' + i + '|') >=0 ? 1 : 0) + "==" 
	}
	if(window.event.srcElement){
		var input = window.event.srcElement;
		
		var $td = $(input).parentsUntil('table').last().parent().parent();
		var $mainth = $td.parentsUntil('table').last().children().first().children();
		var tdidx = $td.parent().children('td').index($td);
		var headerText = $mainth.eq(tdidx).text();

		if(input.tagName == "INPUT"){
			switch(headerText){
				case "本次计划":updateType = 5;break;
				case "开工期":updateType = 3;break;
				case "完工期":updateType = 4;break;
				default : break;
			}
		}
	}
	me.http.regEvent("B2_UpRow");
	me.http.addParam("currdata",sDat)
	me.http.addParam("updateType",updateType);
	me.http.addParam("ddno",document.getElementById("Bill_Info_id").value);
	me.http.addParam("planid",Bill.getInputByDBName("MPSID").value) //M_Field_16_1=生产计划ID
	r = me.http.send()
	//返回的数据格式： 行 #td# 核定产量  #td#  开工期  #td#  完工期  #td#  现有库存 #td# 已采购未入库 #td# 已申请未入库 #td# 已合同未出库 #td# 已申请未出库 #td#   #tr# 
	index[1] = lvw.getCellIndexByName("",tr,"核定产量")
	index[2] = lvw.getCellIndexByName("",tr,"开工期")
	index[3] = lvw.getCellIndexByName("",tr,"完工期")
	index[4] = lvw.getCellIndexByName("",tr,"currck")  //当前库存
	index[5] = lvw.getCellIndexByName("",tr,"ckdelnum")  //当前占用库存
	index[6] = lvw.getCellIndexByName("",tr,"ckkallnum")
	index[7] = lvw.getCellIndexByName("",tr,"库存消耗")
	index[8] = lvw.getCellIndexByName("",tr,"realneed")
	index[9] = lvw.getCellIndexByName("",tr,"当前库存")
	index[10] = lvw.getCellIndexByName("",tr,"已采购未入库")
	index[11] = lvw.getCellIndexByName("",tr,"已申请未入库")
	index[12] = lvw.getCellIndexByName("",tr,"已合同未出库")
	index[13] = lvw.getCellIndexByName("",tr,"已申请未出库")
	index[14] = lvw.getCellIndexByName("",tr,"可用库存")
	index[15] = lvw.getCellIndexByName("",tr,"本次计划")

	var rows = r.split("#tr#")
	for (var i = 0;i < rows.length ;i++ )
	{
		var cells = rows[i].split("#td#");
		if(cells.length!=14){
			if(cells[0].length>0){
				var div = window.DivOpen("sad","调式过程数据");
				div.innerHTML = cells[0];
			}
			return;
		}
		//注意，下标不一定都按顺序，看一下表头

		for (var ii = 1 ; ii<9 ; ii ++ )
		{
			div.hdataArray[cells[0]-1][index[ii]] = cells[ii]
		}

		div.hdataArray[cells[0]-1][index[15]] = cells[13];
		div.hdataArray[cells[0]-1][index[10]] = cells[4];
		div.hdataArray[cells[0]-1][index[14]] = "<span class=link onclick='showcurrckLog(this)'>" + cells[4] + "</a>";
		for (var ii = 10 ; ii<14 ; ii ++ )
		{
			div.hdataArray[cells[0]-1][index[ii]] = cells[ii-1]
		}
	}

}

me.applyck = function(ck){  //应用仓库更改
	var yyfws = document.getElementsByName("awlists");
	var aflist = document.getElementsByName("aflists");
	var cklist = ""
	var tr = me.currRow;
	var cIndex = lvw.getCellIndexByName("",tr,"参考仓库")
	var cIndex1 = lvw.getCellIndexByName("",tr,"可用库存计算方式")

	var btype = document.getElementById("btype1").value*1 + document.getElementById("btype2").value*1
	//if(document.getElementById("cckall").checked ==true) {   //
	//	cklist  = "-1";
	//}else
	//{
		for (var i = 0; i < me.ckCount  ; i++ )
		{
			var m = document.getElementById("stcki_" + i);
			if(m.checked == true){
				cklist = m.tag
			}
		}
	//}

	//cIndex = lvw.getCellIndexByName("",tr,"disrefku")


	var div = window.getParent(tr,3);
	lvw.TryCreateHiddenPageDataToArray(div);
	

	
	var eventRow = new Array()
    var rs = tr.parentElement.rows;
	
	if(yyfws[0].checked==true){ //更新当前行
		div.hdataArray[tr.rowIndex-1][cIndex] = cklist;
		lvw.RefreshCell(tr.cells[cIndex],cklist);
		eventRow[0] = tr.rowIndex;
	}
	else{ //跟新选中行
		for (var i = 1; i < rs.length-1 ; i++)
		{
			var cbox = rs[i].cells[1].getElementsByTagName("input")[0];
			if(cbox.checked==true || yyfws[2].checked==true){
				div.hdataArray[i-1][cIndex] = cklist;
				lvw.RefreshCell(rs[i].cells[cIndex],cklist);
				eventRow[eventRow.length] = i
			}
			
		}	
	}
	
	if(aflist[0].checked==true){ //更新当前行
		div.hdataArray[tr.rowIndex-1][cIndex1] = btype
		lvw.RefreshCell(tr.cells[cIndex1],btype);
		eventRow[0] = tr.rowIndex;
	}
	else{ //跟新选中行
		for (var i = 1; i < rs.length-1 ; i++)
		{
			var cbox = rs[i].cells[1].getElementsByTagName("input")[0];
			if(cbox.checked==true || aflist[2].checked==true){
				div.hdataArray[i-1][cIndex1] = btype
				lvw.RefreshCell(rs[i].cells[cIndex1],btype);
				eventRow[eventRow.length] = i
			}
			
		}	
	}

	me.updateRow(tr, div, rs , eventRow, 1);
	lvw.Refresh(div);
	window.DivClose(ck);
}

me.ckselectall = function(ck){
	for (var i = 0; i < me.ckCount  ; i++ )
	{
		var m = document.getElementById("stcki_" + i);
		m.checked = ck.checked;
		me.ckselect(m,1);
	}
}

//选择仓库
me.ckselect = function (ck,a){
	if(a==1){return;}
	if(ck.checked==false){
		document.getElementById("cckall").checked = false;
	}
	else{
		for (var i = 0; i < me.ckCount  ; i++ )
		{
			var cbox = document.getElementById("stcki_" + i);
			cbox.parentElement.bgColor = cbox.checked ? "#ffff66" : ""
			if(cbox.checked) {
				me.currRowNewCk = cbox.getAttribute("tag");
			}
			//document.getElementById("cckall").checked = true;
		}
	}
	
}

Tabs.ddxqTabs_ItemClick = function(index){
	if(index==0){ //工作时段
		me.showrowdetial(me.currDetialLink);
	}
	else{ //数量
		me.showrowdetial_num(me.currDetialLink);
	}
}

me.showrowdetial_num = function(a){
	var tr = window.getParent(a,7);
	var nodes = lvw.getTreeNodes(tr);
	var dat = ""
	var index = new Array()
	index[1] = lvw.getCellIndexByName("",tr,"bomid")
	index[2] = lvw.getCellIndexByName("",tr,"planlistid")
	index[3] = lvw.getCellIndexByName("",tr,"currck")
	index[4] = lvw.getCellIndexByName("",tr,"核定产量")
	index[5] = lvw.getCellIndexByName("",tr,"开工期")
	index[6] = lvw.getCellIndexByName("",tr,"完工期")
	index[7] = lvw.getCellIndexByName("",tr,"核定计划")
	index[8] = lvw.getCellIndexByName("",tr,"已生产")
	var btype = lvw.getCellValueByName("",tr,"可用库存计算方式");
	var  deep = 1
	for (var i = nodes.length -1 ; i >=0 ; i-- )
	{
		for (ii = 1 ; ii < index.length ; ii ++ )
		{
			dat = dat + lvw.getCellValue(nodes[i].cells[index[ii]]) + "--"
		}
		dat = dat + deep + "=="
		deep ++
	}
	me.http.regEvent("B2_GetDetial_num");
	me.http.addParam("currdata",dat);
	me.http.addParam("btype",btype);
	me.http.addParam("planid",Bill.getInputByDBName("MPSID").value) //M_Field_16_1=生产计划ID
	document.getElementById("ddxqtabslistpanel").innerHTML  = me.http.send()
	lvw.UpdateScrollBar(document.getElementById("listview_yusgclist"));
	document.getElementById("listview_yusgclist").children[1].style.display = "none"
	//tr.rows[].style.display = "none"
}

me.showrowdetial = function(a){
	me.currDetialLink = a
	var div = window.DivOpen("aasas","详情页",800,540,'a','b',1,5)
	var tr = window.getParent(a,7);
	var nodes = lvw.getTreeNodes(tr);
	var dat = ""
	var index = new Array()
	index[1] = lvw.getCellIndexByName("",tr,"bomid")
	index[2] = lvw.getCellIndexByName("",tr,"planlistid")
	index[3] = lvw.getCellIndexByName("",tr,"参考仓库")
	index[4] = lvw.getCellIndexByName("",tr,"核定产量")
	index[5] = lvw.getCellIndexByName("",tr,"开工期")
	index[6] = lvw.getCellIndexByName("",tr,"完工期")
	index[7] = lvw.getCellIndexByName("",tr,"核定计划")
	index[8] = lvw.getCellIndexByName("",tr,"已生产")
	var btype = lvw.getCellValueByName("",tr,"可用库存计算方式");
	var  deep = 1
	for (var i = nodes.length -1 ; i >=0 ; i-- )
	{
		for (ii = 1 ; ii < index.length ; ii ++ )
		{
			dat = dat + lvw.getCellValue(nodes[i].cells[index[ii]]) + "--"
		}
		dat = dat + deep + "=="
		deep ++
	}
	me.http.regEvent("B2_GetDetial_date");
	me.http.addParam("currdata",dat);
	me.http.addParam("btype",btype);
	me.http.addParam("planid",Bill.getInputByDBName("MPSID").value) //M_Field_16_1=生产计划ID
	div.innerHTML  = me.http.send();
	lvw.UpdateScrollBar(document.getElementById("listview_yusgclist"));
}

me.oldlistviewkeydown = lvw.cellinputkeydown

lvw.cellinputkeydown = function(){
	var input = window.event.srcElement;
	var td = window.getParent(input,5);
	var tr = td.parentElement;
	var htxt = tr.parentNode.rows[0].innerHTML;
	if(htxt.indexOf(">物料清单<")>=0) { 
		me.oldlistviewkeydown();
		return; 
	}
	var cellindex = lvw.cellIndex(td);
	var header = tr.parentNode.rows[0].cells[cellindex];
	if(header.getAttribute("dbname")=="本次计划") {
		var deep = lvw.getCellValueByName("",tr,"lvw_treenodedeep");
		if(deep*1>0) {
			window.event.returnValue= false ;
			return false;
		}
	}
	if(window.event.keyCode==13){
		var eventRow = new Array()
		eventRow[0] =  tr.rowIndex + ""
		var div = window.getParent(tr,3);
		me.updateRow(tr ,div, tr.parentElement.rows ,eventRow , 2);
		lvw.Refresh(div);
	}
	me.oldlistviewkeydown();
}

function showzynum(xq,sh,num,safe){  //显示库存消耗计算过程
	var div = window.DivOpen("xssd","库存消耗计算参数",440,240)
	div.innerHTML = "<div style='background-color:#f6f7f9;width:100%;height:100%'><div style='padding-top:12px;padding-bottom:8px;font-weight:bold;color:#000;text-align:center'>当前产品信息</div>" + 
					"<table border=1 bordercolor='#ccccdd' height=100 cellspacing=0 width=310 align=center><tr><td align=right width='50%'>实际需求：</td><td>&nbsp;" + xq 
					+ "</td></tr><tr><td  align=right>损耗率：</td><td>&nbsp;" + sh + "</td></tr><tr><td  align=right>实际生产：</td><td>&nbsp;" 
					+ num + "</td></tr><tr><td  align=right>安全库存：</td><td>&nbsp;" + safe + "</td></tr></table>"
					+ "<br><center style='color:#000;'>库存消耗 = 实际需求 + 安全库存 - 实际生产*(1-损耗率)</center></div>"
}


function showcurrckLog(a) {//显示现有库存的计算公式
	var tr = window.getParent(a,6);
	var div = window.getParent(tr,3);
	var nodes = lvw.getTreeNodes(tr);
	var index = new Array();
	var nodes = lvw.getTreeNodes(tr);
	var ID = document.getElementsByName("MT1")[0].value
	var pid = lvw.getCellValueByName("",tr,"productID");
	var unit = lvw.getCellValueByName("",tr,"单位ID");
	var ck = lvw.getCellValueByName("",tr,"参考仓库");
	var bomid = lvw.getCellValueByName("",tr,"bomid");
	var btype = lvw.getCellValueByName("",tr,"可用库存计算方式");
	var cankcgnum = lvw.getCellValueByName("",tr,"已采购未入库");
	var cankrknum = lvw.getCellValueByName("",tr,"已申请未入库");
	var cankhtnum = lvw.getCellValueByName("",tr,"已合同未出库");
	var cankcknum = lvw.getCellValueByName("",tr,"已申请未出库");
	var currcknum = lvw.getCellValueByName("",tr,"currck");

	var I1 = lvw.getCellIndexByName("",tr,"bomid");
	var I2 = lvw.getCellIndexByName("",tr,"参考仓库");
	var I3 = lvw.getCellIndexByName("",tr,"单位ID");
	var I4 = lvw.getCellIndexByName("",tr,"productID");
	var I5 = lvw.getCellIndexByName("",tr,"ckdelnum");

	
	var dat = new Array();
	for (var i = 0 ; i < div.hdataArray.length ; i ++ )
	{
		if (div.hdataArray[i].length > 2)
		{
			var d1 = div.hdataArray[i][I1]; //bomID
			var d2 = div.hdataArray[i][I2]; //参考仓库
			var d3 = div.hdataArray[i][I3];	//单位
			var d4 = div.hdataArray[i][I4]; //产品ID
			var d5 = div.hdataArray[i][I5]; //库存消耗
			if(bomid == d1){
				break;
			}
			if(d2==ck && d3==unit && pid==d4)
			{
				dat[dat.length] = d1 + "," + d5;
			}
		}
	}
	
	var div =  window.DivOpen("fgfgdfh","现有库存推算记录",700,500);
	me.http.regEvent("B2_GetMRPcurrckLog");
	me.http.addParam("ddno",document.getElementById("Bill_Info_id").value);
	me.http.addParam("currdddata",dat.join(";"));
	me.http.addParam("bomid",bomid);
	me.http.addParam("cp",pid);
	me.http.addParam("unit",unit);
	me.http.addParam("ck",ck);
	me.http.addParam("btype",btype);
	me.http.addParam("cankcgnum",cankcgnum);
	me.http.addParam("cankrknum",cankrknum);
	me.http.addParam("cankhtnum",cankhtnum);
	me.http.addParam("cankcknum",cankcknum);
	me.http.addParam("currcknum",currcknum);
	div.innerHTML  = me.http.send();
	lvw.UpdateScrollBar(document.getElementById("listview_MRPckLog"));
	//lvw.Refresh(document.getElementById("listview_MRPckLog"));
}

window.hasProductList = 0;
window.bill_onLoad = function() {
	var sbox = Bill.getInputByDBName("CreateFrom");
	if(sbox && sbox.type=="hidden") { return; }
	window.hasProductList = 1;
	if(!sbox) {
		//只读模式下
		var td = $ID("M_Field_24_1");
		if(td.innerHTML.indexOf("手动添加")>0) {
			var tr = td.parentNode;
			tr.cells[2].style.visibility = "hidden";
			tr.cells[3].style.visibility = "hidden";
		}
		return;
	}
	window.bindEvent(sbox, "change", function(){
		updateBoxState(sbox);
	});
	updateBoxState(sbox, 1);
}

function updateBoxState(sbox, fst) {
	var tr = sbox.parentNode.parentNode;
	var db = Bill.getInputByDBName("FromID");
	if(fst!=1) {
		db.value = "";
		db.title = "0";
		$(db).trigger("change");
	} else {
		if(sbox.value==4) {
			if(db && db.title=="") {
				db.value = "";
				db.title = "0";
			}
		}
	}
	if(sbox.value==4) {
		tr.cells[2].style.visibility = "hidden";
		tr.cells[3].style.visibility = "hidden";
		db.value = "";
		db.title = "0";
		if($ID("lvw_add_53_tb")) { $ID("lvw_add_53_tb").style.display  =  "block"; }
	} else {
		tr.cells[2].style.visibility = "visible";
		tr.cells[3].style.visibility = "visible";
		if($ID("lvw_add_53_tb")) { $ID("lvw_add_53_tb").style.display  =  "none"; }
	}
	if(db && db.readOnly) {
		//说明是修改模式，不允许修改来源
		if(db.parentNode.tagName=="TD"){
			var imgs = db.parentNode.parentNode.getElementsByTagName("Img");
			if(imgs[0]) { imgs[0].style.display = "none"; }
		}
	}
}

$(document).bind("mousedown",function(e) {
	if(window.hasProductList==1) {
		var hs = false;
		var src = $(e.target).parents("div.xDiatelScroll")[0];
		if(!src) {
			var tg = e.target;
			if(tg.id=="calendardiv") {return;}
			while(tg && tg.id!="calendardiv"){
				tg = tg.parentNode;
				if(tg && tg.tagName=="BODY") {break;}
				if(tg && tg.id=="calendardiv") { return; }
				if(tg && tg.id=="__AutoMenu_div") {return;}
				if(!tg) {return;}
			}
		}
		if(src) {
			if(src.id == "xDiatelScroll3") {
				hs = true;
			}
		}
		if(hs) {
			$ID("xDiatelScroll3").style.cssText = "border:0px solid blue;"; 
			window.DiatelScroll3Select = true;
		}
		else {
			if(window.DiatelScroll3Select) {
				$ID("xDiatelScroll3").style.cssText = "";
				tempSavePlan();
				window.DiatelScroll3Select = false;
			}
		}
	}
});

function tempSavePlan() {  //暂存生产计划
	var cfrm = Bill.getInputByDBName("CreateFrom");
	if(!cfrm) {return;} //只读模式下，直接对推
	if(cfrm.tagName=="INPUT" && cfrm.type=="hidden") {return;} 
	//if(Bill.getInputByDBName("FromId").readOnly) {return ;} //修改模式也}
	var ax = new xmlHttp();
	var frmobj = Bill.getInputByDBName("FromID");
	ax.url = "bscript/callback_savetmpplan.asp"
	ax.regEvent("tempSavePlan");
	ax.addParam("bid", $ID("Bill_Info_id").value);
	ax.addParam("CreateFrom",Bill.getInputByDBName("CreateFrom").value);
	ax.addParam("FromID", frmobj.title?frmobj.title:frmobj.value);
	ax.addParam("planlistData", lvw.GetSaveDetailData().split("#ot")[0]);
	var r = ax.send();
	if (r.indexOf("haschange=")>=0)
	{
		Bill.getInputByDBName("MPSID").setAttribute("RefreshChild",0);
		Bill.getInputByDBName("MPSID").value = r.replace("haschange=","");
		Bill.RefreshDetail(true,71); //刷订单产品树结构明细
	}else if(r.indexOf("nochange=")>=0) {
	}else if(r.indexOf("fails=")>=0) {
		alert("提示您：产品清单第" + ((r.replace("fails=","")*1+1)) + "行资料不正确或不完整");
	}
	else { alert(r) }
}

//关联设计单
window.currMenusSelectData = function(id , result , exid1, exid2 ){
	var ajaxHttp = Bill.ScriptHttp();
	var DesignIDs = "0";
	for (var i = 0; i<result.length ; i++ ){
		DesignIDs += "," + (""+result[i]).split(",")[1] ; 
	}
	ajaxHttp.regEvent("B3_SelectDesignID");
	ajaxHttp.addParam("id",id);
	ajaxHttp.addParam("oid",exid1);
	ajaxHttp.addParam("bid",exid2);
	ajaxHttp.addParam("DesignID",DesignIDs);
	var r = ajaxHttp.send();
	if (r=="1"){
		window.open('../../notice/add.asp?datatype='+ exid1 +'&fromid='+exid2,'newwinAddNotice','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
	}
	$("#design_psize").trigger("change");
}

window.oncmdButtonClick = function() {
	tempSavePlan();
}