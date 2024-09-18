window.ck1 = 0;
window.oldlvw;
//--仓库选择扩展事件
window.currStore = {
	text : "" ,
	value : "",
	eventid : "",
	change : function(){
		document.getElementById("div_ckidstate").style.display = "none";
		document.getElementById("bgdiv").style.display = "none";
		var obj = document.getElementById(this.eventid);
		if(!obj){alert("仓库选择：ID为" + this.eventid + "的对象不存在。"); return ;}
		if (this.eventid == "p_ck1_0")
		{
			var id1 = "p_ck1_h_0";
			if (document.getElementById(id1))
			{
				document.getElementById(id1).value = this.value;
			}
		}
        obj.value = this.text;
		obj.setAttribute("ckord",this.value);
		app.fireChange(obj);
	}
}

function showTree(){
	var currTree = document.getElementById("currTree_0").value;
	var treetype = document.getElementById("treetype_0").value;
	window.open('bom_trees_frame.asp?treetype=' + treetype + '&currTree=' + currTree,'packaging_add_top','width=1300,height=750,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=20');
}
//--产品选择保存后局部刷新
window.refreshBomInfo = function(){
	var json = {};
	json.__msgid = "getBomInfo";
	var aj = $.ajax({
		type:'post',
		url:'../packaging/add.asp',
		cache:false,  
		dataType:'html', 
		data:json,
		success: function(data){
			//eval(data);
			if (setParentProInfo(data))
			{
			    lvw_refresh("packing_proList");
			    var lvw = eval("window.lvw_JsonData_packing_proList");
			    lvw.selposX = 12;
			    ___lvw_je_ztlrCHtml(lvw);
			}
		},
		error:function(data){
			
		}
	});
}

//--刷新父产品信息
function setParentProInfo(data){
	if (data == "false")
	{
		app.Alert("数据异常，请刷新页面！" + data);
		return false;
	}
	else if (data.indexOf("true:") != 0)
	{
		app.Alert("数据异常，请刷联系管理员！" + data);
		return false;
	}
	else
	{
		data = data.substr(5);//confirm("var o = " + data + ";o")
		var info = eval("var o = " + data + ";o");
		var treeord = document.getElementById("currTree_0");
		var title = document.getElementById("p_title_0");
		var proord = document.getElementById("p_title_h_0");
		var unitall = document.getElementById("p_unitall_0");
        var assistUnit = document.getElementById("p_AssistUnit_0");
        var assistNumDom = document.getElementById("p_AssistNum_0");
        var p_ProductAttr1 = document.getElementById("p_ProductAttr1_0");
        var p_ProductAttr2 = document.getElementById("p_ProductAttr2_0");
        var p_ProductAttr1_h = document.getElementById("p_ProductAttr1_h_0");
        var p_ProductAttr2_h = document.getElementById("p_ProductAttr2_h_0");
        var price1 = document.getElementById("p_price1_0");
		var order1 = document.getElementById("p_order1_0");
		var type1 = document.getElementById("p_type1_0");
		var num1 = document.getElementById("p_num1_0");
		var total1 = document.getElementById("p_total1_0");
		var zdy1 = document.getElementById("p_zdy1_0");
		var zdy2 = document.getElementById("p_zdy2_0");
		var zdy3 = document.getElementById("p_zdy3_0");
		var zdy4 = document.getElementById("p_zdy4_0");
		var zdy5 = document.getElementById("p_zdy5_0");
		var zdy6 = document.getElementById("p_zdy6_0");

		treeord.value = info.treeord;
		title.value = info.title;
		proord.value = info.proOrd;
		price1.value = parseFloat(info.price1).toFixed(window.sysConfig.StorePriceDotNum);
		order1.innerText = info.order1;
		type1.innerText = info.type1;
		num1.value = (1).toFixed(window.sysConfig.floatnumber);
		total1.value = parseFloat(info.price1).toFixed(window.sysConfig.moneynumber);
		var phManage = info.phManage;
		var xlhManage = info.xlhManage;
		var cpyxqHours = info.cpyxqHours;
		var phtd = document.getElementById("p_ph1_cel");
		var phdiv = document.getElementById("p_ph1_div");
		var xlhtd = document.getElementById("p_xlh1_cel");
		var xlhdiv = document.getElementById("p_xlh1_div");
		var phnull = 0;
		var xlhnull = 0;
		if(phManage=="1"){
			if(jQuery(phtd).attr("nu")=="1"){phnull = 1;}
			if(phnull == 0){
				jQuery(phdiv).append(" <input class='notnull' title='必填' type='button' value='*'>")
				jQuery(phtd).attr("nu","1");
			}
		}else{
			if(jQuery(phtd).attr("nu")=="1"){phnull = 1;}
			if(phnull == 1){
				jQuery("#p_ph1_div input.notnull").remove();
				jQuery(phtd).attr("nu","0");
				try{jQuery("#p_ph1_div span.bill_valid_msg").remove();}catch(e){}
			}
		}
		if(xlhManage=="1"){
			if(jQuery(xlhtd).attr("nu")=="1"){xlhnull = 1;}
			if(xlhnull == 0){
				jQuery(xlhtd).attr("ui","text");
				jQuery(xlhtd).attr("nu","1");
				jQuery("#p_xlh1_div input.notnull").show();
			}
		}else{
			if(jQuery(xlhtd).attr("nu")=="1"){xlhnull = 1;}
			if(xlhnull == 1){
				jQuery(xlhtd).attr("ui","html");
				jQuery("#p_xlh1_div input.notnull").hide();
				jQuery(xlhtd).attr("nu","0");
				try{jQuery("#p_xlh1_div span.bill_valid_msg").remove();}catch(e){}
			}
		}
		jQuery("#p_scrq1_0").attr("cpyxqHours",cpyxqHours);
		document.getElementById("p_scrq1_0").onchange = function(){
			dateYxqSet("datesc","p_scrq1_0","p_yxrq1_0");
		};
		jQuery("#p_yxrq1_0").attr("cpyxqHours",cpyxqHours);
		document.getElementById("p_yxrq1_0").onchange = function(){
			dateYxqSet("dateyx","p_scrq1_0","p_yxrq1_0");
		};
		if (zdy1)
		{
			zdy1.value = info.zdy1;
		}
		if (zdy2)
		{
			zdy2.value = info.zdy2;
		}
		if (zdy3)
		{
			zdy3.value = info.zdy3;
		}
		if (zdy4)
		{
			zdy4.value = info.zdy4;
		}
		if (zdy5)
		{
			zdy5.value = info.zdy5;
		}
		if (zdy6)
		{
			zdy6.value = info.zdy6;
		}

		var opt = document.createElement("option");
		opt.value = info.unitall;
		opt.innerHTML = info.unitText;
		try
		{
			unitall.children[0].removeNode(true);			
		}
		catch (e)
		{
			unitall.children[0].parentNode.removeChild(unitall.children[0]);
		}
        unitall.appendChild(opt);

        if (assistUnit) {
            try {
                assistUnit.children[0].removeNode(true);
            }
            catch (e) {
                if (assistUnit.children[0].parentNode) assistUnit.children[0].parentNode.removeChild(assistUnit.children[0]);
            }
            var assistUnits = info.AssistUnit.split("_");
            var assistUnitsTexts = info.AssistUnitText.split("___");
            var assistUnitChose = info.AssistUnitChose;
            var assistNum = info.AssistNum;
            $("#p_AssistNum_0").attr("readonly", "readonly"); 
            for (var i = 0; i < assistUnits.length; i++) {
                var opt = document.createElement("option");

                opt.value = assistUnits[i];
                opt.innerHTML = assistUnitsTexts[i];
                if (opt.value == assistUnitChose) {
                    opt.selected = true;
                    assistNumDom.value = assistNum;
                    if (!window.isFixAssRat && assistUnitChose) { $("#p_AssistNum_0").removeAttr("readonly", "readonly") }
                }
                assistUnit.appendChild(opt);
            }
        }
        if (p_ProductAttr1) { if (p_ProductAttr2.tagName&&p_ProductAttr1.tagName.toLocaleLowerCase() == "input") { p_ProductAttr1.value = info.ProductAttr1ChooseName; } else { p_ProductAttr1.innerHTML = info.ProductAttr1ChooseName; } }
        if (p_ProductAttr2) { if (p_ProductAttr2.tagName&&p_ProductAttr2.tagName.toLocaleLowerCase() == "input") { p_ProductAttr2.value = info.ProductAttr1ChooseName; } else { p_ProductAttr2.innerHTML = info.ProductAttr2ChooseName; } }
        if (p_ProductAttr1 || p_ProductAttr2) {
            var productAttrNames = info.ProductAttrNames.split("___");
            $("#p_ProductAttr1_tit").text(productAttrNames[0]+"：");
            $("#p_ProductAttr2_tit").text(productAttrNames[1]+"：");
        }
        if (p_ProductAttr1_h) { p_ProductAttr1_h.value = info.ProductAttr1ChooseId; }
        if (p_ProductAttr2_h) { p_ProductAttr2_h.value = info.ProductAttr2ChooseId; }
    }
	return true;
}

//--单元格数据变更回调事件
window.onlvwUpdateCellValue = function(id, rowindex, cellindex, v, isztlr)
{
    if (isztlr) {
        if (rowindex == 0) {
            ckChanges(id, cellindex);
            return true;
        }
    } else {
        var lvw = eval("window.lvw_JsonData_" + id);
        var h = lvw.headers;
        var hTitle = h[cellindex].dbname;
        var rows = lvw.rows;//confirm(hTitle)
        switch (hTitle)
        {
            case "ck1":
                //confirm(222)	
                ckChange(id, rowindex, cellindex, v);
                break;
            //case "ckfs1":
            //changeCkfs(id, rowindex, cellindex, v);
            //break;

        }
    }
}

//-- (批量) 切换仓库触发事件
function ckChanges(id, cellindex) {
    var lvw = eval("window.lvw_JsonData_" + id);
    var h = lvw.headers;
    var ck1Index = -1;
    var ck1ordIndex = -1;
    var proordIndex = -1;
    var num1Index = -1;
    var unitIndex = -1;
    var snordIndex = -1;
    var kcxx1Index = -1;
    var ckfs1Index = -1;
    var ckfs2Index = -1;
    var ckfs3Index = -1;
    var ckfs4Index = -1;
    var productAttr1Index = -1;
    var productAttr2Index = -1;
    for (var i = 0; i < h.length; i++) {
        if (h[i].dbname == "ck1Ord") {
            ck1ordIndex = i;
        }
        if (h[i].dbname == "ck1") {
            ck1Index = i;
        }
        if (h[i].dbname == "proOrd") {
            proordIndex = i;
        }
        if (h[i].dbname == "unit") {
            unitIndex = i;
        }
        if (h[i].dbname == "num1") {
            num1Index = i;
        }
        if (h[i].dbname == "snOrd") {
            snordIndex = i;
        }
        if (h[i].dbname == "kcxx1") {
            kcxx1Index = i;
        }
        if (h[i].dbname == "ckfs1") {
            ckfs1Index = i;
        }
        if (h[i].dbname == "ckfs2") {
            ckfs2Index = i;
        }
        if (h[i].dbname == "ckfs3") {
            ckfs3Index = i;
        }
        if (h[i].dbname == "ckfs4") {
            ckfs4Index = i;
        }
        if (h[i].dbname == "ProductAttr1") {
            productAttr1Index = i;
        }
        if (h[i].dbname == "ProductAttr2") {
            productAttr2Index = i;
        }
    }

    var json = {};
    json.__msgid = "getBatchKCInfo";
    var submitData = "";

    for (var i = 0; i < lvw.rows.length; i++) {
        var id1 = id + "_jec_-1_" + cellindex;
        if (document.getElementById(id1)) {
            var v1 = lvw.rows[i][ck1ordIndex];
            if (document.getElementById(id1).getAttribute("ckord")) {
                var ckord = document.getElementById(id1).getAttribute("ckord");
            }
            else {
                var ckord = lvw.rows[i][ck1ordIndex];
            }
            if (!ckord) return;
            var proord = lvw.rows[i][proordIndex];
            var unit = lvw.rows[i][unitIndex];
            var productAttr1 = lvw.rows[i][productAttr1Index];
            var productAttr2 = lvw.rows[i][productAttr2Index];
            if (i == 0) { submitData += ckord + "_" + proord + "_" + unit + "_" + productAttr1 + "_" + productAttr2; }
            else { submitData += "|" + ckord + "_" + proord + "_" + unit + "_" + productAttr1 + "_" + productAttr2; };
        }
    }
    json.dataText = submitData;
    var rows = lvw.rows
    var aj = $.ajax({
        type: 'post',
        url: '../packaging/add.asp',
        cache: false,
        dataType: 'html',
        data: json,
        success: function (arrData) {
            arrStr = arrData.split("|");
            for (var i = 0; i < lvw.rows.length; i++) {
                data = arrStr[i];
                var snord = rows[i][snordIndex];
                var rowindex = i;
                rows[rowindex][ckfs1Index] = "<input id='packing_proList_jec_" + snord + "_13_0' value='1'"
                + " onclick=\"changeCkfs('" + id + "',13,this)\""
                + " type='radio' name='packing_proList_jec_" + snord + "_13' checked>"
                + "<label for='packing_proList_jec_" + snord + "_13_0'>随机</label>"
                + "<input id='packing_proList_jec_" + snord + "_13_1' value='2'"
                + " onclick=\"changeCkfs('" + id + "',13,this)\""
                + " type='radio' name='packing_proList_jec_" + snord + "_13'>"
                + "<label for='packing_proList_jec_" + snord + "_13_1'>指定</label>";

                if (data&&data.indexOf("true:") == 0) {
                    var d = data.substr(5);
                    var n = d.indexOf(":");
                    var partData = d.substr(0, n);
                    var num1 = partData.split("_")[0];
                    var ck1ord = partData.split("_")[1];
                    var ckName = partData.split("_")[2];
                    //c.innerHTML = d.substr(n + 1);
                    rows[rowindex][kcxx1Index] = d.substr(n + 1);
                    rows[rowindex][cellindex] = ckName;
                    rows[rowindex][ckfs2Index] = "1";
                    rows[rowindex][ckfs3Index] = "0";
                    rows[rowindex][ckfs4Index] = num1;
                    rows[rowindex][ck1ordIndex] = ck1ord;
                    ___RefreshListViewByJson(lvw);
                }
                else if (data.indexOf("false:") == 0) {
                    if (window.oldlvw) {
                        oldRows = window.oldlvw.rows
                        rows[rowindex][ck1ordIndex] = oldRows[rowindex][ck1ordIndex];
                        rows[rowindex][cellindex] = oldRows[rowindex][cellindex];
                        rows[rowindex][kcxx1Index] = oldRows[rowindex][kcxx1Index];
                        rows[rowindex][ckfs2Index] = oldRows[rowindex][ckfs2Index];
                        rows[rowindex][ckfs3Index] = oldRows[rowindex][ckfs3Index];
                        rows[rowindex][ckfs4Index] = oldRows[rowindex][ckfs4Index];
                        ___RefreshListViewByJson(lvw);
                    } else {
                        rows[rowindex][cellindex] = "";
                        rows[rowindex][ck1ordIndex] = 0;
                        ___RefreshListViewByJson(lvw);
                    }
                }
                else {
                    app.Alert("数据异常，请联系管理员！")
                }
                var sendData = "";
                sendData = sendData + "0##"+ rows[i][unitIndex]+ "##"+ rows[i][num1Index] + "##"+rows[i][ck1ordIndex]+ "##"
               + 0 + "##"
               + rows[i][productAttr1Index] + "##"
               + rows[i][productAttr2Index]
               + "||";
               get_zz_priceinfo(sendData, rowindex, lvw, lvw.rows[i][proordIndex])
            }
            window.oldlvw = JSON.parse(JSON.stringify(lvw));
        },
        error: function (data) {

        }
    });
}
function ChageTotal()
{
    var lvw = eval("window.lvw_JsonData_packing_proList");
    var h = lvw.headers;
    var rows = lvw.rows;
    var total1Index = -1;//总价
    for (var i = 0; i < h.length; i++) {
        if (h[i].dbname == "total1") {
            total1Index = i;
        }
    }

    var sums = lvw.sums;
    if (sums) {
        sums[total1Index] = 0;
        for (var i = 0; i < rows.length; i++) {
            sums[total1Index] = sums[total1Index] + rows[i][total1Index];
        }
    }
    var total1 = document.getElementById("p_total1_0");
    var price1 = document.getElementById("p_price1_0");
    var num1 = document.getElementById("p_num1_0").value;
    if (num1 == "0") {
        total1.value = parseFloat(sums[total1Index]).toFixed(window.sysConfig.moneynumber);
        price1.value = (0).toFixed(window.sysConfig.moneynumber);
    }
    else {
        total1.value = parseFloat(sums[total1Index]).toFixed(window.sysConfig.moneynumber);
        price1.value = (sums[total1Index] / num1).toFixed(window.sysConfig.SalesPriceDotNum);
    }
}
function get_zz_priceinfo(str, rowindex, lvw, ord)
{
    var rows = lvw.rows
    var h = lvw.headers;
    var num1Index = -1;//数量
    var price1Index = -1;//单价
    var total1Index = -1;//总价
    var proordIndex = -1;//产品ord
    for (var i = 0; i < h.length; i++) {
        if (h[i].dbname == "num1") {
            num1Index = i;
        }
        else if (h[i].dbname == "price1") {
            price1Index = i;
        }
        else if (h[i].dbname == "total1") {
            total1Index = i;
        }
    }
    var num1 = rows[rowindex][num1Index]//数量
    var json = {};
    json.__msgid = "handleMakePrice";
    json.data = str;
    json.IsMode = 1;
    json.proord = ord;
    var aj = $.ajax({
        type: 'post',
        url: '../store/get_zz_priceinfo.asp',
        cache: false,
        dataType: 'html',
        data: json,
        success: function (arrData) {
            datas = arrData.split("\2");
            if (datas == "") return;
            for (var i = 0 ; i < datas.length ; i++) {
                if (datas[i].length > 0) {
                    var item = datas[i].split("\1");
                    //单价
                    rows[rowindex][price1Index] = item[2].toString();
                    //总价
                    rows[rowindex][total1Index] = item[2] * num1;
                    var money1= rows[rowindex][total1Index] 
                    rows[rowindex][price1Index] = money1 / num1;
                }
            }
            ChageTotal();//更新合计
            ___RefreshListViewByJson(lvw);
        },
        error: function (data) {

        }
    });
}

//--切换仓库触发事件
function ckChange(id, rowindex, cellindex, v)
{
	var lvw = eval("window.lvw_JsonData_" + id);
	var h = lvw.headers;
	var ck1Index = -1;
	var ck1ordIndex = -1;
	var proordIndex = -1;
	var num1Index = -1;
	var unitIndex = -1;
	var snordIndex = -1;
	var kcxx1Index = -1;
	var ckfs1Index = -1;
	var ckfs2Index = -1;
	var ckfs3Index = -1;
	var ckfs4Index = -1;
    var productAttr1Index = -1;
    var productAttr2Index = -1;
	for (var i = 0; i < h.length; i++)
	{
		if (h[i].dbname == "ck1Ord")
		{
			ck1ordIndex = i;
		}
		if (h[i].dbname == "ck1")
		{
			ck1Index = i;
		}
		if (h[i].dbname == "proOrd")
		{
			proordIndex = i;
		}
		if (h[i].dbname == "unit")
		{
			unitIndex = i;
		}
		if (h[i].dbname == "num1")
		{
			num1Index = i;
		}
		if (h[i].dbname == "snOrd")
		{
			snordIndex = i;
		}
		if (h[i].dbname == "kcxx1")
		{
			kcxx1Index = i;
		}
		if (h[i].dbname == "ckfs1")
		{
			ckfs1Index = i;
		}
		if (h[i].dbname == "ckfs2")
		{
			ckfs2Index = i;
		}
		if (h[i].dbname == "ckfs3")
		{
			ckfs3Index = i;
		}
		if (h[i].dbname == "ckfs4")
		{
			ckfs4Index = i;
        }
        if (h[i].dbname == "ProductAttr1") {
            productAttr1Index = i;
        }
        if (h[i].dbname == "ProductAttr2") {
            productAttr2Index = i;
        }
	}
	cellindex = ck1Index;
	var hTitle = h[cellindex].dbname;
	var id1 = id + "_jec_" + rowindex + "_" + cellindex;
	if (document.getElementById(id1))
	{
		var rows = lvw.rows;
		//var ckordInput = document.getElementById(id2);
		//var v1 = ckordInput.value;
		var v1 = rows[rowindex][ck1ordIndex];
		if (document.getElementById(id1).getAttribute("ckord"))
		{
			var ckord = document.getElementById(id1).getAttribute("ckord");
		}
		else
		{
			var ckord = rows[rowindex][ck1ordIndex];
		}
		if (v1 != ckord)
		{
			if (window.ck1 > 0 && ckord == 0)
			{
				rows[rowindex][ck1ordIndex] = window.ck1;
				window.ck1 = 0;
			}
			else
			{
				rows[rowindex][ck1ordIndex] = ckord;
			}
			//ckordInput.value = ckord;
			var snord = rows[rowindex][snordIndex]
			var proord = rows[rowindex][proordIndex];
			var unit = rows[rowindex][unitIndex];
			var num1 = rows[rowindex][num1Index];
            var productAttr1 = rows[rowindex][productAttr1Index];
            var productAttr2 = rows[rowindex][productAttr2Index];
			var json = {};
			json.__msgid = "getKCInfo";
			json.proord = proord;
			json.unit = unit;
			json.ckord = ckord;
            json.ProductAttr1 = productAttr1;
            json.ProductAttr2 = productAttr2;
			var aj = $.ajax({
				type:'post',
				url:'../packaging/add.asp',
				cache:false,  
				dataType:'html', 
				data:json,
				success: function(data){//confirm(data)
					rows[rowindex][ckfs1Index] = "<input id='packing_proList_jec_" + snord + "_13_0' value='1'"
								+ " onclick=\"changeCkfs('" + id + "',13,this)\""
								+ " type='radio' name='packing_proList_jec_" + snord + "_13' checked>"
								+ "<label for='packing_proList_jec_" + snord + "_13_0'>随机</label>"
								+ "<input id='packing_proList_jec_" + snord + "_13_1' value='2'"
								+ " onclick=\"changeCkfs('" + id + "',13,this)\""
								+ " type='radio' name='packing_proList_jec_" + snord + "_13'>"
								+ "<label for='packing_proList_jec_" + snord + "_13_1'>指定</label>";
					if (data.indexOf("true:") == 0)
					{
                        var d = data.substr(5);
						var n = d.indexOf(":");
						//c.innerHTML = d.substr(n + 1);
						rows[rowindex][kcxx1Index] = d.substr(n + 1);
						rows[rowindex][ckfs2Index] = "1";
						rows[rowindex][ckfs3Index] = "0";
						rows[rowindex][ckfs4Index] = d.substr(0,n);
                        oldlvw = JSON.parse(JSON.stringify(lvw));
                        ___RefreshListViewByJson(lvw);
					}
					else if (data.indexOf("false:") == 0)
					{
						//c.innerHTML = data.substr(6);
						rows[rowindex][kcxx1Index] = data.substr(6);
						rows[rowindex][ckfs2Index] = "1";
						rows[rowindex][ckfs3Index] = "0";
						rows[rowindex][ckfs4Index] = "0";
                        oldlvw = JSON.parse(JSON.stringify(lvw));
                        ___RefreshListViewByJson(lvw);
					}
					else
					{
						app.Alert("数据异常，请联系管理员！")
					}
					var sendData = "";
					sendData = sendData + "0##"
                   + unit + "##"
                   + num1 + "##"
                   + ckord + "##"
                   + 0+ "##"
                   + productAttr1 + "##"
                   + productAttr2 
                   + "||";
					get_zz_priceinfo(sendData, rowindex, lvw, proord);
				},
				error:function(data){
					
				}
			});
		}
	}
}
//--切换出库方式
function changeCkfs(id, cellindex, obj){
	var tr = obj.parentElement.parentElement;
	var rowindex = tr.getAttribute("pos")*1;
	var lvw = eval("window.lvw_JsonData_" + id);
	var h = lvw.headers;
	var rows = lvw.rows;
	var ck1ordIndex = -1;
	var ck1Index = -1;
	var proordIndex = -1;
	var num1Index = -1;
	var price1Index = -1;
	var total1Index = -1;
	var price2Index = -1;
	var unitIndex = -1;
	var snordIndex = -1;
	var kcxx1Index = -1;
	var ckfs1Index = -1;
	var ckfs2Index = -1;
	var ckfs3Index = -1;
	var ckfs4Index = -1;
	var AssinumIndex = -1;
    var productAttr1Index = -1;
    var productAttr1Index = -1;
    for (var i = 0; i < h.length; i++)
	{
		if (h[i].dbname == "ck1Ord")
		{
			ck1ordIndex = i;
		}
		if (h[i].dbname == "ck1")
		{
			ck1Index = i;
		}
		if (h[i].dbname == "proOrd")
		{
			proordIndex = i;
		}
		if (h[i].dbname == "unit")
		{
			unitIndex = i;
		}
		if (h[i].dbname == "num1")
		{
			num1Index = i;
		}
		if (h[i].dbname == "snOrd")
		{
			snordIndex = i;
		}
		if (h[i].dbname == "kcxx1")
		{
			kcxx1Index = i;
		}
		if (h[i].dbname == "ckfs1")
		{
			ckfs1Index = i;
		}
		if (h[i].dbname == "ckfs2")
		{
			ckfs2Index = i;
		}
		if (h[i].dbname == "ckfs3")
		{
			ckfs3Index = i;
		}
		if (h[i].dbname == "Assinum") {
		    AssinumIndex = i;
		}
		if (h[i].dbname == "ckfs4")
		{
			ckfs4Index = i;
		}
		if (h[i].dbname == "price1")
		{
			price1Index = i;
		}
		if (h[i].dbname == "price2")
		{
			price2Index = i;
		}
		if (h[i].dbname == "total1")
		{
			total1Index = i;
        }
        if (h[i].dbname == "ProductAttr1") {
            productAttr1Index = i;
        }
        if (h[i].dbname == "ProductAttr2") {
            productAttr2Index = i;
        }
	}
	cellindex = ckfs1Index;
	var hTitle = h[cellindex].dbname;
	var v = obj.value;
	var id1 = obj.id;
	//var ckfs2Index = cellindex * 1 + 1;
	//var ckfs3Index = cellindex * 1 + 2;
	//var ckfs4Index = cellindex * 1 + 3;
	var snord = rows[rowindex][snordIndex];
	if (id1.substr(id1.lastIndexOf("_") + 1) == "1")
	{
		var ck1Ord = rows[rowindex][ck1ordIndex];
		if (ck1Ord == 0 || ck1Ord == '')
		{
			//document.getElementById(id1.substr(0,id1.lastIndexOf("_") + 1) + "0").checked = "checked";
			app.Alert("请先选择仓库！");
			return false;
        }
        rows[rowindex][ckfs2Index] = v;
		window.klistEventHandle = {
		    fznum: rows[rowindex][AssinumIndex],
			hsnum : rows[rowindex][ckfs4Index],
			data : rows[rowindex][ckfs3Index],
			change: function () {
			    rows[rowindex][AssinumIndex] = this.fznum
				rows[rowindex][ckfs3Index] = this.data;
				rows[rowindex][ckfs4Index] = this.hsnum;
				//lv.RefreshRow(lv.EditRow);
				rows[rowindex][cellindex] = "<input id='packing_proList_jec_" + snord + "_13_0' value='1'"
					+ " onclick=\"changeCkfs('" + id + "',13,this)\""
					+ " type='radio' name='packing_proList_jec_" + snord + "_13'>"
					+ "<label for='packing_proList_jec_" + snord + "_13_0'>随机</label>"
					+ "<input id='packing_proList_jec_" + snord + "_13_1' value='2'"
					+ " onclick=\"changeCkfs('" + id + "',13,this)\""
					+ " checked type='radio' name='packing_proList_jec_" + snord + "_13'>"
					+ "<label for='packing_proList_jec_" + snord + "_13_1'>指定</label>";
				if (this.hsnum > 0)
				{
					rows[rowindex][cellindex] = rows[rowindex][cellindex] + "<div style='color:red'>已指定：" + this.hsnum + "</div>";
				}
				___RefreshListViewByJson(lvw);
				var json = {};
				json.__msgid = "getAvgPrice";
				json.data = this.data;
				var aj = $.ajax({
					type:'post',
					url:'../packaging/add.asp',
					cache:false,  
					dataType:'html',  
					data:json,
					success: function(data){
						//confirm(data.indexOf("true:"));return;
						if (data.indexOf("true:") == 0)
						{
							data = data.replace("true:","");
							var num1 = rows[rowindex][num1Index];
							rows[rowindex][price1Index] = data;
							rows[rowindex][total1Index] = data * num1;
						}
						else if (data.indexOf("false:") == 0)
						{
							var num1 = rows[rowindex][num1Index];
							rows[rowindex][price1Index] = rows[rowindex][price2Index];
							rows[rowindex][total1Index] = rows[rowindex][price2Index] * num1;
						}
						var sums = lvw.sums;
						if (sums)
						{
							sums[total1Index] = 0;
							for (var i = 0; i < rows.length; i++)
							{
								sums[total1Index] = sums[total1Index] + rows[i][total1Index];
							}
						}
						var total1 = document.getElementById("p_total1_0");
						var price1 = document.getElementById("p_price1_0");
						var num1 = document.getElementById("p_num1_0").value;
						if (num1 == "0")
						{
							total1.value = parseFloat(sums[total1Index]).toFixed(window.sysConfig.moneynumber);
							price1.value = (0).toFixed(window.sysConfig.moneynumber);
						}
						else
						{
							total1.value = parseFloat(sums[total1Index]).toFixed(window.sysConfig.moneynumber);
							price1.value = (sums[total1Index] / num1).toFixed(window.sysConfig.moneynumber);
						}
						//var price1 = rows[rowindex][8];
						//var total1 = rows[rowindex][9];
						___RefreshListViewByJson(lvw);
					},
					error:function(data){
						
					}
				});

			}
		}
		
		var div = window.DivOpen("asdas","指定出库");
        div.innerHTML = "<iframe src='../store/ku_select_ck2.asp?ord=" + rows[rowindex][proordIndex] + "&unit=" + rows[rowindex][unitIndex] + "&ck=" + rows[rowindex][ck1ordIndex] + "&num1=" + rows[rowindex][num1Index]
            + "&ProductAttr1=" + rows[rowindex][productAttr1Index] + "&ProductAttr2=" + rows[rowindex][productAttr2Index]+"' style='width:100%;height:100%' frameborder=0></iframe>";
		div.style.padding = "0px";
	}
	else
    {
        rows[rowindex][AssinumIndex] = 0;
        rows[rowindex][ckfs2Index] = v;
        rows[rowindex][ckfs3Index] = 0;
        rows[rowindex][ckfs4Index] = 0;
        window.ck1 = rows[rowindex][ck1ordIndex];
        window.onlvwUpdateCellValue(id, rowindex, ck1Index, rows[rowindex][ck1Index]);
        //rows[rowindex][ck1ordIndex] = ck1;
        rows[rowindex][cellindex] = "<input id='packing_proList_jec_" + snord + "_13_0' value='1'"
            + " onclick=\"changeCkfs('" + id + "',13,this)\""
            + " checked type='radio' name='packing_proList_jec_" + snord + "_13'>"
            + "<label for='packing_proList_jec_" + snord + "_13_0'>随机</label>"
            + "<input id='packing_proList_jec_" + snord + "_13_1' value='2'"
            + " onclick=\"changeCkfs('" + id + "',13,this)\""
            + " type='radio' name='packing_proList_jec_" + snord + "_13'>"
            + "<label for='packing_proList_jec_" + snord + "_13_1'>指定</label>";
        var num1 = rows[rowindex][num1Index];
        //rows[rowindex][price1Index] = rows[rowindex][price2Index];
        //rows[rowindex][total1Index] = rows[rowindex][price2Index] * num1;
        //var sums = lvw.sums;
        //if (sums) {
        //    sums[total1Index] = 0;
        //    for (var i = 0; i < rows.length; i++) {
        //        sums[total1Index] = sums[total1Index] + rows[i][total1Index];
        //    }
        //}
        //var total1 = document.getElementById("p_total1_0");
        //var price1 = document.getElementById("p_price1_0");
        //var num1 = document.getElementById("p_num1_0").value;
        //if (num1 == "0") {
        //    total1.value = parseFloat(sums[total1Index]).toFixed(window.sysConfig.moneynumber);
        //    price1.value = (0).toFixed(window.sysConfig.moneynumber);
        //}
        //else {
        //    total1.value = parseFloat(sums[total1Index]).toFixed(window.sysConfig.moneynumber);
        //    price1.value = (sums[total1Index] / num1).toFixed(window.sysConfig.moneynumber);
        //}
        //___RefreshListViewByJson(lvw);
        var productAttr1 = rows[rowindex][productAttr1Index];
        var productAttr2 = rows[rowindex][productAttr2Index];
        if (document.getElementById(id1).getAttribute("ckord")) {
            var ckord = document.getElementById(id1).getAttribute("ckord");
        }
        else {
            var ckord = rows[rowindex][ck1ordIndex];
        }

        var proord = rows[rowindex][proordIndex];
        var unit = rows[rowindex][unitIndex];
        var json = {};
        json.__msgid = "getKCInfo";
        json.proord = proord;
        json.unit = unit;
        json.ckord = ckord;
        var aj = $.ajax({
            type: 'post',
            url: '../packaging/add.asp',
            cache: false,
            dataType: 'html',
            data: json,
            success: function (data) {//confirm(data)
                if (data.indexOf("true:") == 0) {
                    var d = data.substr(5);
                    var n = d.indexOf(":");
                    rows[rowindex][ckfs4Index] = d.substr(0, n);
                    oldlvw = JSON.parse(JSON.stringify(lvw));
                    ___RefreshListViewByJson(lvw);
                }
                else if (data.indexOf("false:") == 0) {
                    rows[rowindex][ckfs4Index] = "0";
                    oldlvw = JSON.parse(JSON.stringify(lvw));
                    ___RefreshListViewByJson(lvw);
                }
                else {
                    app.Alert("数据异常，请联系管理员！")
                }
                var sendData = "";
                sendData = sendData + "0##"
               + unit + "##"
               + num1 + "##"
               + ckord + "##"
               + 0 + "##"
               + productAttr1 + "##"
               + productAttr2
               + "||";
                get_zz_priceinfo(sendData, rowindex, lvw, proord);
            },
            error: function (data) {

            }
        });



	}
}
//--仓库选择
function showStoreDlg1(id){
	var lvw = window.lvw_JsonData_packing_proList;
	var h = lvw.headers;
	var rows = lvw.rows;
	if (rows.length == 0)
	{
		app.Alert("请选择子件！")
		return false;
	}
	//--获取列index
	var proordIndex = -1;
	var unitIndex = -1;
	for (var i = 0; i < h.length; i++)
	{
		if (h[i].dbname == "proOrd")
		{
			proordIndex = i;
		}
		if (h[i].dbname == "unit")
		{
			unitIndex = i;
		}
	}
	var id1 = id.replace("packing_proList_jec_","").replace(/_\d+/g,"");//--packing_proList_jec_0_9
	//confirm(id1)
    if (id1 != "-1") {
        var proord = rows[id1][proordIndex];
        var unit = rows[id1][unitIndex];
        showStoreDlg(id, proord, unit);
    } else {
        showStoreDlg(id);
    }
}

//--父件仓库选择
function showStoreDlg2(id){
	var proord = document.getElementById("p_title_h_0").value;
	var unit = document.getElementById("p_unitall_0").value;
	if (proord.length == 0 || isNaN(proord))
	{
		app.Alert("请选择父件！")
		return false;
	}
	if (unit.length == 0 || isNaN(unit))
	{
		app.Alert("请选择单位！")
		return false;
	}
	showStoreDlg(id,proord,unit);
}

//--指定库存弹窗显示
window.DivOpen = function(id, t, w, h){
	var div = document.getElementById("test-window-" + id);
	if (!div)
	{
		var div = document.createElement("div");
		div.id = "test-window-" + id;
		//div.style.display = "none";
		document.body.appendChild(div);
	}
	var $win;
	$win = $('#test-window-' + id).window({
		title: t,
		width: 780,
		height: 360,
		//top: ($(window).height() - 820) * 0.5,
		//left: ($(window).width() - 450) * 0.5,
		shadow: true,
		modal: true,
		//iconCls: 'icon-add',
		closed: true,
		minimizable: false,
		maximizable: false,
		collapsible: false
	});

	$win.window('open');
	return div;
}

//--页面验证回调函数
window.onbillTbValid = function(){
	return __beforeSave();
}
//--子件数据验证
function __beforeSave(){
	var id = "packing_proList";
	var lvw = window.lvw_JsonData_packing_proList;
	var h = lvw.headers;
	var rows = lvw.rows;
	if (rows.length == 0)
	{
		app.Alert("请选择子件！")
		return false;
	}
	//--获取列index
	var proordIndex = -1;
	var unitIndex = -1;
	var num1Index = -1;
	var price1Index = -1;
	var ck1ordIndex = -1;
	var ckfs2Index = -1;
	var ckfs3Index = -1;
	var ckfs4Index = -1;
	var bz1Index = -1;
	var js1Index = -1;
	var introIndex = -1;
	var zdy1Index = -1;
	var zdy2Index = -1;
	var zdy3Index = -1;
	var zdy4Index = -1;
	var zdy5Index = -1;
	var zdy6Index = -1;
	var AssinumIndex = -1;
    var ProductAttr1Index = -1;
    var ProductAttr2Index = -1;
    for (var i = 0; i < h.length; i++)
	{
		if (h[i].dbname == "ck1Ord")
		{
			ck1ordIndex = i;
		}
		if (h[i].dbname == "proOrd")
		{
			proordIndex = i;
		}
		if (h[i].dbname == "unit")
		{
			unitIndex = i;
		}
		if (h[i].dbname == "num1")
		{
			num1Index = i;
		}
		if (h[i].dbname == "price1")
		{
			price1Index = i;
		}
		if (h[i].dbname == "ckfs2")
		{
			ckfs2Index = i;
		}
		if (h[i].dbname == "ckfs3")
		{
			ckfs3Index = i;
		}
		if (h[i].dbname == "Assinum") {
		    AssinumIndex = i;
		}
		if (h[i].dbname == "ckfs4")
		{
			ckfs4Index = i;
		}
		if (h[i].dbname == "bz1")
		{
			bz1Index = i;
		}
		if (h[i].dbname == "js1")
		{
			js1Index = i;
		}
		if (h[i].dbname == "intro")
		{
			introIndex = i;
		}
		if (h[i].dbname == "zdy1")
		{
			zdy1Index = i;
		}
		if (h[i].dbname == "zdy2")
		{
			zdy2Index = i;
		}
		if (h[i].dbname == "zdy3")
		{
			zdy3Index = i;
		}
		if (h[i].dbname == "zdy4")
		{
			zdy4Index = i;
		}
		if (h[i].dbname == "zdy5")
		{
			zdy5Index = i;
		}
		if (h[i].dbname == "zdy6")
		{
			zdy6Index = i;
        }
        if (h[i].dbname == "ProductAttr1") {
            ProductAttr1Index = i;
        }
        if (h[i].dbname == "ProductAttr2") {
            ProductAttr2Index = i;
        }
	}

	var vals = {};
	for (var i = 0; i < rows.length; i++)
	{
		if (rows[i][ck1ordIndex] == "" || rows[i][ck1ordIndex] == "0")
		{
			lvw.selpos = i; ___RefreshListViewselPos(lvw);
			app.Alert("有子件产品没有选择仓库，请选择仓库！");
			return false;
			break;
		}else if (rows[i][ckfs2Index] == "2" && rows[i][num1Index] * 1 != rows[i][ckfs4Index] * 1)
		{
			lvw.selpos = i; ___RefreshListViewselPos(lvw);
			app.Alert("指定出库数量不足！");
			return false;
			break;
		}else if (rows[i][ckfs2Index] == "1" && rows[i][num1Index] * 1 > rows[i][ckfs4Index] * 1)
		{
			lvw.selpos = i; ___RefreshListViewselPos(lvw);
			app.Alert("有子件产品的库存不足！");
			return false;
			break;
		}
		
		var xlh = jQuery.trim(jQuery("#p_xlh1_0").val());
		var num1 = Number(jQuery("#p_num1_0").val());
		var xlhMin = jQuery("#p_xlh1_cel").attr("nu")
		if(xlh!=""){
			var arr_xlh = xlh.split("\1");
			if(xlhMin == "1"){
				if(num1 != arr_xlh.length){           
					app.Alert("序列号个数["+ arr_xlh.length +"]与数量["+ num1 +"]不一致，请重新录入");
					return false;
					break;
				}
			}else{
				if(num1 < arr_xlh.length){
					app.Alert("序列号个数["+ arr_xlh.length +"]大于数量["+ num1 +"]，请重新录入");
					return false;
					break;
				}
			}
		}

		if (!vals["proord"])
		{
			vals["proord"] = [];
		}
		vals["proord"].push(rows[i][proordIndex]);

		if (!vals["unit"])
		{
			vals["unit"] = [];
		}
		vals["unit"].push(rows[i][unitIndex]);

		if (!vals["num1"])
		{
			vals["num1"] = [];
		}
		vals["num1"].push(String(rows[i][num1Index]).replace(/,/g,""));

		if (!vals["price1"])
		{
			vals["price1"] = [];
		}
		vals["price1"].push(String(rows[i][price1Index]).replace(/,/g,""));

		if (!vals["ck1ord"])
		{
			vals["ck1ord"] = [];
		}
		vals["ck1ord"].push(rows[i][ck1ordIndex]);

		if (!vals["ckfs2"])
		{
			vals["ckfs2"] = [];
		}
		vals["ckfs2"].push(String(rows[i][ckfs2Index]).replace(/,/g,""));

		if (!vals["ckfs3"])
		{
			vals["ckfs3"] = [];
		}
		vals["ckfs3"].push(rows[i][ckfs3Index]);

		if (!vals["Assinum"]) {
		    vals["Assinum"] = [];
		}
		vals["Assinum"].push(rows[i][AssinumIndex]);

		if (!vals["bz1"])
		{
			vals["bz1"] = [];
		}
		vals["bz1"].push(rows[i][bz1Index]);

		if (!vals["js1"])
		{
			vals["js1"] = [];
		}
		vals["js1"].push(rows[i][js1Index]);

		if (!vals["intro"])
		{
			vals["intro"] = [];
		}
		vals["intro"].push(rows[i][introIndex]);

		if (!vals["zdy1"])
		{
			vals["zdy1"] = [];
		}
		vals["zdy1"].push(rows[i][zdy1Index]);

		if (!vals["zdy2"])
		{
			vals["zdy2"] = [];
		}
		vals["zdy2"].push(rows[i][zdy2Index]);
		
		if (!vals["zdy3"])
		{
			vals["zdy3"] = [];
		}
		vals["zdy3"].push(rows[i][zdy3Index]);

		if (!vals["zdy4"])
		{
			vals["zdy4"] = [];
		}
		vals["zdy4"].push(rows[i][zdy4Index]);

		if (!vals["zdy5"])
		{
			vals["zdy5"] = [];
		}
		vals["zdy5"].push(rows[i][zdy5Index]);

		if (!vals["zdy6"])
		{
			vals["zdy6"] = [];
		}
        vals["zdy6"].push(rows[i][zdy6Index]);

        if (!vals["ProductAttr1"]) {
            vals["ProductAttr1"] = [];
        }
        vals["ProductAttr1"].push(rows[i][ProductAttr1Index]);

        if (!vals["ProductAttr2"]) {
            vals["ProductAttr2"] = [];
        }
        vals["ProductAttr2"].push(rows[i][ProductAttr2Index]);
	}
	var c = String.fromCharCode(1);
	for (var i in vals)
	{
		var input = document.getElementById("s_" + i + "_0");
		if (input)
		{
			input.value = vals[i].join(c);
		}
	}
	return true;
}

function getAssistNum() {

    var json = {};
    json.__msgid = "getNum";
    json.pord = $("#p_title_h_0").val();
    json.unit = $("#p_unitall_0").val();
    json.AssistUnit = $("#p_AssistUnit_0").val();
    json.Num = $("#p_num1_0").val();
    if (json.AssistUnit == "NULL" || json.AssistUnit == "" || json.AssistUnit == "0") {
        $("#p_AssistNum_0").val("");
        $("#p_AssistNum_0").attr("readonly","readonly");
    } else {
        if (!window.isFixAssRat) $("#p_AssistNum_0").removeAttr("readonly", "readonly");
       

        var aj = $.ajax({
            type: 'post',
            url: '../packaging/add.asp',
            cache: false,
            dataType: 'html',
            data: json,
            success: function (data) { //confirm(data)
                $("#p_AssistNum_0").val((data * 1).toFixed(window.sysConfig.floatnumber));;
            },
            error: function (data) {

            }
        });
    }


}

$(document).ready(function () {
    $("#p_num1_0").keydown(function (e) {
        var event = e || window.event;
        if (event.keyCode == 13 || event.which == 13) { $(this).blur(); }
    })
    $("#p_num1_0").focus(function(){$(this).attr("data-oval",$(this).val())}).blur(function () {
        var oldVal = $(this).attr("data-oval");
        var newVal = $(this).val();
        if (oldVal == newVal) { return; }
		var id = "packing_proList";
		var lvw = window.lvw_JsonData_packing_proList;
		var h = lvw.headers;
		var rows = lvw.rows;
		if (rows.length == 0)
		{
			this.value = 1;
			return;
		}
		this.value = this.value.replace(/[^\d\.]/g,'');
		var total1 = document.getElementById("p_total1_0");
		var price1 = document.getElementById("p_price1_0");
		total1.value = (price1.value * this.value).toFixed(window.sysConfig.moneynumber);
		checkDot(total1.id, window.sysConfig.moneynumber);
		var num1Index = -1;
		var num2Index = -1;
		var total1Index = -1;
		var total2Index = -1;
		var pric1Index = -1;
		var ProductAttr1Index = -1;
		var ProductAttr2Index = -1;
		var unitIndex = -1;
		var ck1ordIndex = -1;
		for (var i = 0; i < h.length; i++)
		{
			if (h[i].dbname == "num1")
			{
				num1Index = i;
			}
			if (h[i].dbname == "total1")
			{
				total1Index = i;
			}
			if (h[i].dbname == "total2")
			{
				total2Index = i;
			}
			if (h[i].dbname == "price1")
			{
				pric1Index = i;
			}
			if (h[i].dbname == "num2")
			{
				num2Index = i;
			}
			if (h[i].dbname == "ProductAttr1") {
			    ProductAttr1Index = i;
			}
			if (h[i].dbname == "ProductAttr2") {
			    ProductAttr2Index = i;
			}
			if (h[i].dbname == "ck1Ord") {
			    ck1ordIndex = i;
			}
			if (h[i].dbname == "proOrd") {
			    proordIndex = i;
			}

			if (h[i].dbname == "unit") {
			    unitIndex = i;
			}
		}
		for (var i = 0; i < rows.length; i++)
		{		  
			rows[i][num1Index] = rows[i][num2Index] * this.value;
			rows[i][total1Index] = parseFloat(rows[i][num2Index]) * parseFloat(rows[i][pric1Index].toString().replace(/\,/g, "")) * parseFloat(this.value);
		}
		var sums = lvw.sums;
		if (sums)
		{
			sums[total1Index] = 0;
			sums[num1Index] = 0;
			for (var i = 0; i < rows.length; i++)
			{
				sums[total1Index] = sums[total1Index] + rows[i][total1Index];
				sums[num1Index] = sums[num1Index] + rows[i][num1Index];
			}
		}
		total1.value = (sums[total1Index]).toFixed(window.sysConfig.moneynumber);
		price1.value = (sums[total1Index] / this.value).toFixed(window.sysConfig.StorePriceDotNum);
        getAssistNum();
        ___RefreshListViewByJson(lvw);      
	});
	$("#p_price1_0").change(function(){
		this.value = this.value.replace(/[^\d\.]/g,'');
		var total1 = document.getElementById("p_total1_0");
		var num1 = document.getElementById("p_num1_0");
		total1.value = (num1.value * this.value).toFixed(window.sysConfig.moneynumber);
		//checkDot(total1.id, window.sysConfig.moneynumber);
	});
	$("#p_total1_0").keydown(
		function(){return false}
    );
    if (window.location.href.indexOf("add_CK.ASP") > -1) {
        var lvw = eval("window.lvw_JsonData_packing_proList");
        lvw.selposX = 12;
        ___lvw_je_ztlrCHtml(lvw);
    }

    $("#p_AssistUnit_0").change(getAssistNum);
    getAssistNum();

});
