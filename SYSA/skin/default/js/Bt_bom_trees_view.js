var bomTree ={};
//--切换节点版本，获取节点数据，刷新树
bomTree.changeVer = function (obj, rowindex, proord, protype, tType, treeord, mark) {
    var id = obj.getAttribute("treeid");
	var lvw = eval("window.lvw_JsonData_" + id);
	var cellindex = 7, textindex, rows, row;
	var h = lvw.headers;
	for (var i = 0; i < h.length; i++) {
		if (h[i].dbname == "num1") {
			cellindex = i;
		}
		if (h[i].dbname == "text") { textindex = i; }
	}
	rows = lvw.rows;
	var currDeepLen = rows[rowindex][textindex].deeps.length;
	for (var i = rowindex; i < lvw.rows.length; i++) {
		row = rows[i];
		if (i > rowindex && rows[i][textindex].deeps.length <= currDeepLen) { break; }
		if (row[textindex].expand == 0) {
			lvw_je_Expnode(id, i, 1, true)
		}
	}
    var v = lvw.rows[rowindex][cellindex];
	_lvw_je_RefreshListTreeNode(id, rowindex, true, function(){
		ajax.addParam("proord",proord);
		ajax.addParam("bomord",obj.value);
		ajax.addParam("protype",protype);
		ajax.addParam("currCode",obj.getAttribute("currCode"));
		ajax.addParam("tType",tType);
		ajax.addParam("treeord", treeord);
		var pricetype = 0;
	    try {
	        pricetype = $("input[name='EstimationPriceType']:checked").val();
	        if (!pricetype) pricetype = 0;
	    } catch (e) { pricetype = 0; }
		ajax.addParam("pricetype", pricetype);
		ajax.addParam("mark", mark);
	});
	lvw.rows[rowindex][cellindex] = v;
	__lvw_je_redrawCell(lvw, lvw.headers[cellindex], rowindex, cellindex - 1);
	window.onlvwUpdateCellValue(id, rowindex, cellindex, v, 0, true);
}

//--单选框点击事件
bomTree.radioClick = function(obj){
	var ck = obj.getAttribute("ck");
	var name = obj.getAttribute("name");
	$("input[type='radio'][name='" + name + "']").attr("ck","0");
	if (ck == "1")
	{
		obj.checked = false;
		obj.setAttribute("ck","0");
	}
	else
	{
		obj.checked = true;
		obj.setAttribute("ck","1");
	}
	if(!obj.onpropertychange){ bomTree.radioChange(obj);}
	return false;
}
//--更新选中值
var lastradio = {}
bomTree.radioChange = function(obj){
    var rowindex = obj.getAttribute("rowindex");
    var name = obj.getAttribute("name");
    var type = obj.getAttribute("type");  
	var id = obj.getAttribute("treeid");
	var lvw = eval("window.lvw_JsonData_" + id);
	var rows = lvw.rows;
	var h = lvw.headers;
	var sindex = -1;
	var SLIndex = -1;
	for (var i = 0; i < h.length; i++)
	{
	    if (h[i].dbname == "SL") SLIndex = i
		if (h[i].dbname == "selected") sindex = i;	 
	}
	if (type == "radio") {
		if (!lastradio.isinit) { bomTree.radioObjInit(lvw) }
		var lasto = lastradio[name];
		if (lasto) {
			rows[lasto.r][lasto.c] = 0;
		}
	}
	rows[rowindex][sindex] = (obj.checked) ? 1 : 0;
	lastradio[name] = { r: rowindex, c: sindex }
	window.onlvwUpdateCellValue(id, rowindex, SLIndex, rows[rowindex][SLIndex], 0, true);
}
bomTree.radioObjInit = function (lvw) {
	var rows = lvw.rows;
	if (!rows || !rows.length) { return; }
	var treecode2, mxid, name, stype, selected, row, h, hs = lvw.headers, c = 0;
	for (var i = 0; i < hs.length; i++) {
		h = hs[i];
		if (h.dbname == "treecode2") { treecode2 = i; c++ }
		if (h.dbname == "mxid") { mxid = i; c++ }
		if (h.dbname == "stype") { stype = i; c++ }
		if (h.dbname == "selected") { selected = i; c++ }
		if (c >= 4) { break }
	}
	for (var i = 0; i < rows.length; i++) {
		row = rows[i];
		if (row[stype] == 1 && row[selected] == 1) {
			name = "radio_" + row[treecode2] + "_" + row[mxid];
			lastradio[name] = { r: i, c: selected };
		}
	}
	lastradio.isinit = true;
}
//--复选框点击事件
bomTree.checkboxClick = function(obj){
	if(!obj.onpropertychange){ bomTree.radioChange(obj);}
}

function handleVer(proord, protype, treecode, rowindex, treeid, tType, bomord, treeord, mark){
	var p = "opts_" + proord + "_" + protype;
	var s = "";
	if (bomOpts[p])
	{
		var lvw = eval("window.lvw_JsonData_" + treeid);
		var h = lvw.headers;
		var unitIndex = -1;
		for (var i = 0; i < h.length; i++)
		{
			if (h[i].dbname == "unit")
			{
				unitIndex = i;
			}
		}
		var rows = lvw.rows;
		var deeps = rows[rowindex][1].deeps;
		var unit = rows[rowindex][unitIndex];
		if (deeps.length == 0)			//--根节点可以选择所有单位的版本
		{
			var s = "<select currCode='" + treecode + "' treeid='" + treeid + "' onchange='bomTree.changeVer(this," + rowindex + "," + proord + "," + protype + "," + tType + "," + treeord + ",\"" + mark + "\")'>";
			var o = bomOpts[p];
			for (var i = 0; i < o.length; i++)
			{
				var opt = [];
				opt.push("<option ");
				if (bomord == o[i].v)
				{
					opt.push(" selected='selected' ");
				}
				opt.push(" value='" + o[i].v + "'>");
				opt.push(o[i].t);
				opt.push("</option>");
				s = s + opt.join(" ");
			}
			s = s + "</select>";
		}else{							//--子节点只可以选对应单位的版本
			var n = 0;
			var s = "<select currCode='" + treecode + "' treeid='" + treeid + "' onchange='bomTree.changeVer(this," + rowindex + "," + proord + "," + protype + "," + tType + "," + treeord + ",\"" + mark + "\")'>";
			var o = bomOpts[p];
			for (var i = 0; i < o.length; i++)
			{
				if (o[i].u == unit)
				{
					var opt = [];
					opt.push("<option ");
					if (bomord == o[i].v)
					{
						opt.push(" selected='selected' ");
					}
					opt.push(" value='" + o[i].v + "'>");
					opt.push(o[i].t);
					opt.push("</option>");
					s = s + opt.join(" ");
					n += 1;
				}
			}
			s = s + "</select>";
			if (n <= 1)
			{
				s = "";
			}
		}
	}
	return s;
}

function handleCaoZuo(ismain,bomord,rowindex,treeord,treecode,treetype,id){
	if (!window.treetype) window.treetype = treetype;
	if (ismain != "1") return "";
	return "<a onclick='openSubWindow(\"" + bomord + "\",\"" + rowindex + "\",\"" + treeord + "\",\"" + treecode + "\",\"" + id+"\""+ ")' href='javascript:void(0)' title='添加子件'>添加</a>";
}

function openSubWindow(bomord,rowindex,treeord,treecode,lvwid){
	if (!window.subWin)
	{
		window.subWin = {};
	}
	if (!window.treetype) window.treetype = 0;
	window.currRowindex = rowindex;
	//展开树节点
	var textindex, rows, row, id = lvwid;
	var lvw = eval("window.lvw_JsonData_" + id);
	var h = lvw.headers;
	for (var i = 0; i < h.length; i++) {
		if (h[i].dbname == "text") { textindex = i; break }
	}
	rows = lvw.rows;
	for (var i = rowindex * 1; i < lvw.rows.length; i++) {
		row = rows[i];
		if (row[textindex].expand == 0) {
			lvw_je_Expnode(id, i, 1, true)
		}
	}
	document.body.onunload = function(){closeSubWindow()}
	window.TeLiAddSaveCurrTreeCode = treecode;
	window.subWin[bomord] = window.open('../bomList/add1_top.asp?treetype=' + window.treetype + '&bomord=' + bomord + '&treeord=' + treeord, 'bom_list_add_top', 'width=1300,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=100')
}

//--关闭子窗口
function closeSubWindow() 
{ 
	var subWin = window.subWin;
	for (var i in subWin)
	{
		var winID = subWin[i];
		if(winID && winID.open && !winID.closed) 
		{ 
			winID.close(); 
		}
	} 
} 



function handleText(text, stype, code, notNull, rowindex, treeid)
{
	var lvw = eval("window.lvw_JsonData_" + treeid);
	var h = lvw.headers;
	var ckindex = -1;
	for (var i = 0; i < h.length; i++)
	{
		if (h[i].dbname == "selected")
		{
			ckindex = i;
		}
	}
	var ck = lvw.rows[rowindex][ckindex];
	if (ck == "1")
	{
		var ckText = " checked='checked' ";
	}
	else
	{
		var ckText = " ";
	}
	var space = "";
	code = code + "";
	stype = stype + "";
	notNull = notNull + "";
	if (code.lastIndexOf("_") > 0)
	{
		var preCode = code.substr(0,code.lastIndexOf("_"));
		switch (stype)
		{
			case "1":
				space += "<input type='radio' id='' ck='" + ck + "' " + ckText + " name='radio_" + preCode + "' value='1' rowindex='" + rowindex + "' notnull='" + notNull + "' treeid='" + treeid + "' onclick='bomTree.radioClick(this)' onpropertychange='bomTree.radioChange(this)' />";
				break;
			case "2":
				space += "<input type='checkbox' id='' ck='" + ck + "' " + ckText + " name='checkbox_" + preCode + "' value='1' rowindex='" + rowindex + "' notnull='" + notNull + "' treeid='" + treeid + "' onclick='bomTree.checkboxClick(this)' onpropertychange='bomTree.radioChange(this)' />";
				break;
		}
	}
	var notnull = "";
	if (stype !=0 && notNull == "1")
	{
		notnull = '<input title="必填" style="color:red;border:0px;background-color:transparent;padding-left:0px;padding-right:0px;" type="button" value="*"/>';
	}
	//notnull = '<input title="必填" onclick="showRowsData(\'' + treeid + '\',' + rowindex + ')" style="color:red;border:0px;background-color:transparent;padding-left:0px;padding-right:0px;" type="button" value="*"/>';
	return (space + text + notnull);
}

//--数量变更联动改变下级节点数量
window.onlvwUpdateCellValue = function(id, rowindex, cellindex, v, isztlr, islength)
{
	var lvw = eval("window.lvw_JsonData_" + id);
	var h = lvw.headers;
	var hTitle = h[cellindex].dbname;
	var rows = lvw.rows;
	var SLIndex = -1;
	var codeIndex = -1;
	var code2Index = -1;
	var numIndex = -1;
	var num1Index = -1;
	var num2Index = -1;
	var ZJIndex = -1;
	var DJIndex = -1;
	var BZIndex = -1;
	var StyleIndex = -1;
	var SelectIndex = -1;
	var mxidIndex = -1;
	var TitleIndex = -1;
	for (var i = 0; i < h.length; i++)
	{
		if (h[i].dbname == "SL") SLIndex = i
		if (h[i].dbname == "treecode") codeIndex = i;
		if (h[i].dbname == "treecode2") code2Index = i;
		if (h[i].dbname == "num") numIndex = i;
		if (h[i].dbname == "num1") num1Index = i;
		if (h[i].dbname == "num2") num2Index = i;
		if (h[i].dbname == "ZJ") ZJIndex = i;
		if (h[i].dbname == "DJ") DJIndex = i;
		if (h[i].dbname == "BZDJ") BZIndex = i;
		if (h[i].dbname == "stype") StyleIndex = i;
		if (h[i].dbname == "selected") SelectIndex = i;
		if (h[i].dbname == "mxid") mxidIndex = i;
		if (h[i].dbname == "text") TitleIndex = i;
	}
	var attrOffset = 0;
	if (!window.isOpenProductAttr) { attrOffset = 2; }
	var code = rows[rowindex][codeIndex];
	var code2 = rows[rowindex][code2Index];
	var currNodeDeep = rows[rowindex][TitleIndex].deeps.length;
	var LastInx = rowindex;//更新金额最后行
	switch (hTitle){
        case "num1":  
		    if (codeIndex >= 0)
		    {
                //当前行数量
			    var currNum = rows[rowindex][SLIndex];
			    if (code2.length > 0) {
			        for (var i = rowindex * 1 - 1 ; i>=0; i--) {
			            if (rows[i][codeIndex] == code2) {
			                var pn = rows[i][SLIndex];
			                var pbli = rows[i][num1Index] ? rows[i][num1Index] : 1;
			                currNum = FormatNumber(pn * v/pbli, window.sysConfig.floatnumber);
			                rows[rowindex][SLIndex] = currNum;
			                break;
			            }
			        }
			    } else {
			        currNum = FormatNumber(v, window.sysConfig.floatnumber);
			        rows[rowindex][SLIndex] = currNum;
			    }
			    __lvw_je_redrawCell(lvw, h[SLIndex], rowindex, SLIndex-1);

			    var bNum = currNum;
			    for (var i = (rowindex * 1 + 1); i < rows.length; i++)
				{
					if (!currNodeDeep&&rows[i][TitleIndex].deeps.length == currNodeDeep) { break; }
				    LastInx = i;
				    if (rows[i][codeIndex].indexOf(code) != 0) break;
				    var bli = 1, orignBli;
				    code2 = rows[i][code2Index];
				    for (var ii = i * 1 - 1 ; ii >= 0; ii--) {
				        if (rows[ii][codeIndex] == code2) {
				            bNum = rows[ii][SLIndex];
				            bli = rows[ii][num1Index] * 1
				            bli = bli ? bli : 1;
				            orignBli = rows[ii][num2Index];
				            rows[i][num1Index] = rows[ii][num1Index] * 1 / (orignBli ? orignBli : 1) * rows[i][num2Index];
				            __lvw_je_redrawCell(lvw, h[num1Index], i, num1Index - 1 - attrOffset);
				            break;
				        }
				    }
				    rows[i][SLIndex] = FormatNumber(rows[i][cellindex] * bNum/bli, window.sysConfig.floatnumber);
				    __lvw_je_redrawCell(lvw, h[SLIndex], i, SLIndex-1);	
			    }
		    }
		    break;
	    case "SL":
	        var bNum = v;
			for (var i = (rowindex * 1 + 1); i < rows.length; i++) {
				if (!currNodeDeep && rows[i][TitleIndex].deeps.length == currNodeDeep) { break; }
	            LastInx = i;
	            if (rows[i][codeIndex].indexOf(code) != 0) break;
	            var bli = 1;
	            code2 = rows[i][code2Index];
	            for (var ii = i * 1 - 1 ; ii >= 0; ii--) {
	                if (rows[ii][codeIndex] == code2) {
	                    bNum = rows[ii][SLIndex];
	                    bli = rows[ii][num1Index] * 1 ? rows[ii][num1Index] : 1;
	                    break;
	                }
	            }
	            rows[i][SLIndex] = FormatNumber(rows[i][num1Index] * bNum / bli, window.sysConfig.floatnumber);
	            __lvw_je_redrawCell(lvw, h[SLIndex], i, SLIndex - 1);
	        }
	        break;
	}
    //金额的计算
	for (var i = LastInx * 1 ; i >= 0; i--) {
	    code = rows[i][codeIndex];
	    var arr = code.split("|");
	    var price = (rows[i][DJIndex] + "").replace(/,/g, "");//单价
		var num = (rows[i][SLIndex] + "").replace(/,/g, "");//数量
		var mxid = rows[i][mxidIndex];
	    if (arr[arr.length - 1].indexOf("_") > 0) {
	        //叶子节点 单价*数量
	        rows[i][ZJIndex] = formatNumDot(price * num, window.sysConfig.moneynumber);
	    } else {
	        var allMoney = 0;
			var bzAllPrice = 0;
			var mxid1 = 0;
			var bzBli_p = rows[i][num1Index] ? rows[i][num1Index] : 1, bzBli_c;
			for (var ii = (i * 1 + 1); ii < rows.length; ii++) {
				mxid1 = rows[ii][mxidIndex];
				if (rows[ii][code2Index] + "_" + mxid1 == code + "_" + mxid) {//code需要相同并且是同一产品下的才可以进行累加
					if (rows[ii][StyleIndex] == "0" || rows[ii][StyleIndex] == "" || rows[ii][SelectIndex] == "1") {
						bzBli_c = rows[ii][num1Index];
						allMoney += parseFloat((rows[ii][ZJIndex] + "").replace(/,/g, ""));
						bzAllPrice += parseFloat((rows[ii][BZIndex] * bzBli_c / bzBli_p + "").replace(/,/g, ""));
					}
				}
			}
	        rows[i][ZJIndex] = FormatNumber(allMoney, window.sysConfig.moneynumber);
			rows[i][DJIndex] = FormatNumber(allMoney / num, h[DJIndex].dbtype == "storeprice" ? window.sysConfig.StorePriceDotNum : window.sysConfig.SalesPriceDotNum);
			rows[i][BZIndex] = FormatNumber(bzAllPrice, h[DJIndex].dbtype == "storeprice" ? window.sysConfig.StorePriceDotNum : window.sysConfig.SalesPriceDotNum);
			__lvw_je_redrawCell(lvw, h[DJIndex], i, DJIndex - 1);
			__lvw_je_redrawCell(lvw, h[BZIndex], i, BZIndex - 1 - attrOffset);
	    }
	    __lvw_je_redrawCell(lvw, h[ZJIndex], i, ZJIndex - 1);
	}

    try {
        var money = rows[0][ZJIndex];
        $("#moneyAll").text(money);
        var bl = $("#allbl").val();
        if (bl.length == 0) bl = 100;
        $('#newmoney').text(FormatNumber(money * bl * 0.01, window.sysConfig.moneynumber));
    } catch (e) { }
}
//--树保存
bomTree.saveTree = function(id){
	if (bomTree.beforeSaveTree(id))
	{
		var lvw = eval("window.lvw_JsonData_" + id);
		var h = lvw.headers;
		var rows = lvw.rows;//confirm(rows.join("\n"))
		//--获取对应列下标
		var nnIndex = -1;			//--notnull
		var stypeIndex = -1;		//--stype
		var codeIndex = -1;			//--treecode
		var selectedIndex = -1;		//--selected
		var mainIndex = -1;			//--ismain
		var blordIndex = -1;		//--bl_ord
		var num2Index = -1;			//--num2
		var num1Index = -1;			//--num1
		var tordIndex = -1;			//--treeord
		var markIndex = -1;
		for (var i = 0; i < h.length; i++)
		{
			if (h[i].dbname == "notnull")
			{
				nnIndex = i;
			}
			if (h[i].dbname == "stype")
			{
				stypeIndex = i;
			}
			if (h[i].dbname == "treecode")
			{
				codeIndex = i;
			}
			if (h[i].dbname == "selected")
			{
				selectedIndex = i;
			}
			if (h[i].dbname == "ismain")
			{
				mainIndex = i;
			}
			if (h[i].dbname == "bl_ord")
			{
				blordIndex = i;
			}
			if (h[i].dbname == "num2")
			{
				num2Index = i;
			}
			if (h[i].dbname == "num1")
			{
				num1Index = i;
			}
			if (h[i].dbname == "treeord")
			{
				tordIndex = i;
            }
            if (h[i].dbname == "treeord") {
                tordIndex = i;
			}
			if (h[i].dbname == "mark") {
				markIndex = i;
			}
		}
		var mark = "";
		var saveLvw = {};
		saveLvw.headers = h;
		saveLvw.rows = [];
		nodeSelected = {};
		var selected = [];		//--被选中的必选节点【前面有复选框或单选框且被选中的】
		var finnal = [];		//--被选定的最终产品数组
		var treeord = 0;		//--当前树ORD
		var changedNum = [];	//--变化的产品数量
		for (var i = 0; i < rows.length; i++)
		{
			if (mark == "") {
				mark = rows[i][markIndex];
			}
			if (treeord == 0)
			{
				treeord = rows[i][tordIndex];
			}
			//confirm("["+String(rows[i][num1Index]).replace(/,/g,"")+"]["+String(rows[i][num2Index]).replace(/,/g,"")+"]")
			if (String(rows[i][num1Index]).replace(/,/g,"") != String(rows[i][num2Index]).replace(/,/g,""))
			{
				changedNum.push(String(rows[i][blordIndex]).replace(/,/g, "") + "," + String(rows[i][num1Index]).replace(/,/g, "") + "," + rows[i][codeIndex]);
			}
			if (rows[i][selectedIndex] == "1")
			{
				selected.push(rows[i][blordIndex] + "#$9527$#" + rows[i][codeIndex]);
			}
			var code = rows[i][codeIndex] + "";
			if (i == 0)
			{
				rows[i][nnIndex] = "1";
				rows[i][stypeIndex] = "0";
				rows[i][selectedIndex] = "1";
				nodeSelected[code] = rows[i][selectedIndex];
			}
			else
			{
				var preCode = code.substr(0,code.lastIndexOf("_"));
				//console.log("i="+(i+1) +"   text="+rows[i][1].txt+"   rows[i][selectedIndex]="+rows[i][selectedIndex]+"    stypeIndex="+rows[i][stypeIndex]+"    mainIndex="+rows[i][mainIndex]+"    blordIndex="+rows[i][blordIndex]);
				if (nodeSelected[preCode] == "1")
				{
					if (rows[i][stypeIndex] == "" || rows[i][stypeIndex] == "0")
					{
						nodeSelected[code] = "1";
					}
					else
					{
						nodeSelected[code] = rows[i][selectedIndex];
					}
				}
				else
				{
					nodeSelected[code] = "0";
				}
				if (nodeSelected[code] == "1" && rows[i][mainIndex] == "0")
				{
					// saveLvw.rows.push(rows[i]);
					finnal.push(rows[i][blordIndex] + "#$9527$#" + rows[i][codeIndex]);
				}

			}
			saveLvw.rows.push(rows[i]);
			// finnal.push(rows[i][blordIndex]);
		}
		//confirm(saveLvw.rows.length);
		//confirm(changedNum.join("\n"));return;
		//confirm(treeord);
		//confirm(finnal);
		//confirm(selected);return;
		//console.log(finnal)
		//return;
		var json = {};
		json.__msgid = "saveTree";
		json.treeord = treeord;
		json.finnal = finnal.join(",");
		json.selected = selected.join(",");
		json.changedNum = changedNum.join("^&*9527*&^");
		json.mark = mark;
		var aj = $.ajax({
			type:'post',
			url:'../bomlist/Bom_Trees_View.asp',
			cache:false,  
			dataType:'html', 
			data:json,
			success: function(data){
				//eval(data);
				if (data == "true")
				{
					try
					{
						refreshOpener();
						setTimeout(function(){parent.window.close();},100);
					}
					catch (e)
					{
						app.Alert("A.保存失败：" + e.message);
					}
				}
			},
			error:function(data){
				app.Alert("B.保存失败：\n\n" + data)
			}
		});
	}
}
//--必填的单选或复选产品验证
bomTree.beforeSaveTree = function(id){
	var lvw = eval("window.lvw_JsonData_" + id);
	var h = lvw.headers;
	var rows = lvw.rows;
	var nnIndex = -1;
	var stypeIndex = -1;
	var codeIndex = -1;
	var selectedIndex = -1;
	var numIndex = -1;
	for (var i = 0; i < h.length; i++)
	{
		if (h[i].dbname == "notnull")
		{
			nnIndex = i;
		}
		if (h[i].dbname == "stype")
		{
			stypeIndex = i;
		}
		if (h[i].dbname == "treecode")
		{
			codeIndex = i;
		}
		if (h[i].dbname == "selected")
		{
			selectedIndex = i;
		}
		if (h[i].dbname == "num1")
		{
			numIndex = i;
		}
	}
	//confirm("["+nnIndex+"]["+stypeIndex+"]["+codeIndex+"]["+selectedIndex+"]")
	var notnull = {};
	for (var i = 0; i < rows.length; i++)
	{
		var num = rows[i][numIndex];
		if (num <= 0 || num > 999999999)
		{
			lvw.selpos = i;
			___RefreshListViewselPos(lvw);
			app.Alert("产品数量必须在0~99999999之间！")
			return false;
			break;
		}
		var code = rows[i][codeIndex] + "";
		if (rows[i][nnIndex] == "1" && rows[i][stypeIndex] != "0" && code.lastIndexOf("_") > 0)
		{
			var preCode = code.substr(0,code.lastIndexOf("_"));
			preCode = preCode + '_' + rows[i][stypeIndex];
			if (!notnull[preCode])
			{
				notnull[preCode] = {};
				notnull[preCode].title = [];
				notnull[preCode].checked = rows[i][selectedIndex];
				notnull[preCode].title.push(rows[i][1].txt);
				notnull[preCode].stype = rows[i][stypeIndex];
				notnull[preCode].index = i;
			}
			else
			{
				notnull[preCode].title.push(rows[i][1].txt);
				if (notnull[preCode].checked != "1")
				{
					notnull[preCode].checked = rows[i][selectedIndex];
				}
			}
		}
	}
	for (var i in notnull)
	{
		if (notnull[i].checked == "0")
		{
			var stype = notnull[preCode].stype + "";
			switch (stype)
			{
				case "0":
					var typetext = "固定";
					break;
				case "1":
					var typetext = "单选";
					break;
				case "2":
					var typetext = "复选";
					break;
			}
			lvw.selpos = notnull[i].index;
			___RefreshListViewselPos(lvw);
			app.Alert(notnull[i].title.join(",") + "为必选产品，请至少选择其中之一！");
			return false;
		}
	}
	return true;
}

function showRowsData(id,rowindex){
	var lvw = eval("window.lvw_JsonData_" + id);
	var rows = lvw.rows;
	confirm(rows[rowindex]);
}

function refreshOpener(){
	if (parent && parent.opener)
	{
		if (parent.opener.window.refreshBomInfo)
		{
			parent.opener.window.refreshBomInfo();
		}
	}
}

//--特例添加保存后，页面关闭的回调事件
window.onTeLiAddSave = function (treeord, bomord) {
    
	var json = {};
	json.__msgid = "TreeListCallBack";
	json.treeord = treeord;
	json.bomord = bomord;
	json.currCode = window.TeLiAddSaveCurrTreeCode;
	json.tType = window.treetype;
	var rowindex = window.currRowindex;
    var cellindex = 7;
    var lvw = eval("window.lvw_JsonData_Bomtree");
    var v = lvw.rows[rowindex][cellindex];

	_lvw_je_RefreshListTreeNode("Bomtree", rowindex, true, function(){
		ajax.addParam("bomord",json.bomord);
		ajax.addParam("currCode",json.currCode);
		ajax.addParam("tType",json.tType);
		ajax.addParam("treeord", json.treeord);
		var pricetype = 0;
	    try {
	        pricetype = $("input[name='EstimationPriceType']:checked").val();
	        if (!pricetype) pricetype = 0;
	    } catch (e) { }
		ajax.addParam("pricetype", pricetype);
	});
	lvw.rows[rowindex][cellindex] = v;
	__lvw_je_redrawCell(lvw, lvw.headers[cellindex], rowindex, cellindex - 1);
	window.onlvwUpdateCellValue("Bomtree", rowindex, cellindex, v, 0, true);
}