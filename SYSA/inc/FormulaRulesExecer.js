window.__ASPFExecuter = new Object();
__ASPFExecuter.GetCurrRow = function (srcobj) {
	var tr = $(srcobj).closest("tr")[0];
	if (tr.parentNode.parentNode.className.indexOf("productattrstable") >= 0) {
		tr = $(tr.parentNode.parentNode).closest("tr")[0];
	}
	return tr; 
}
__ASPFExecuter.GetExecuteRows = function (range, srcobj) {
	var rows = [];
	for (var firstfkey in window.CurrFormulaConfig.FieldsMap) {
		break;
	}
	if (range == "row") {
		rows.push(__ASPFExecuter.GetCurrRow(srcobj));
	} else {
		var objs = $("input[id^=" + firstfkey.split("[")[0].replace("%d", "") + "]");
		for (var i = 0; i < objs.length; i++) {
			rows.push(__ASPFExecuter.GetCurrRow(objs[i]));
		}
	}
	return rows;
}

__ASPFExecuter.CurrInitObject = null;
__ASPFExecuter.DoExecute = function (initobj) {
	__ASPFExecuter.CurrInitObject = initobj;
	var rows = __ASPFExecuter.GetExecuteRows(initobj.range, initobj.tiggerobj);
	for (var i = 0; i < rows.length; i++) {
		__ASPFExecuter.DoExecuteRow(rows[i])
	}
}

__ASPFExecuter.DoExecuteRow = function (currRow) {
	var tiggerkey = __ASPFExecuter.CurrInitObject.tiggerkey || "";
	__ASPFExecuter.CurrInitObject.CurrRow = currRow;
	var gps = window.CurrFormulaConfig.FormulaGroups;
	for (var i = 0; i < gps.length; i++) {
		var okkey = gps[i].tigger == tiggerkey;
		var okfilter = !gps[i].filtercode || __ASPFExecuter.IsFilterCodeOK(currRow, gps[i].filtercode);
		if (okkey && okfilter) {
			__ASPFExecuter.DoExecuteRowCore(currRow, gps[i]);
		}
	}
}

__ASPFExecuter.DoExecuteRowCore = function (row, g) {
	if (!g.TempFuns) {
		g.TempFuns = [];
		for (var i = 0; i < g.Formulas.length; i++) {
			var f = g.Formulas[i];
			if (f.indexOf("=@@手动录入") > 0 || f.indexOf("=@@不变") > 0) { continue; }
			try {
				g.TempFuns.push(eval("var r=(function(){" + __ASPFExecuter.VarHandle(f) + " });r"));
			} catch (ex) {
				console.log("生成公式失败: f=" + __ASPFExecuter.VarHandle(f) + "; e=" + ex.message);
			}
		}
	}
	for (var i = 0; i < g.TempFuns.length; i++) {
		var oldjson = __ASPFExecuter.GetExecuteRowJSON(row);
		var newjson = jQuery.extend({}, oldjson);
		g.TempFuns[i].call(newjson);
		__ASPFExecuter.SetRowByExecuteJSON(row, oldjson, newjson)
	}
}

__ASPFExecuter.SetRowByExecuteJSON = function (currRow, oldjson, newjson) {
	var boxs = [];
	var boxs1 = currRow.getElementsByTagName("input");
	var boxs2 = currRow.getElementsByTagName("select");
	for(var i = 0; i<boxs1.length; i++) { boxs.push(boxs1[i]); }
	for(var i = 0; i<boxs2.length; i++) { boxs.push(boxs2[i]); }
	for (var n in oldjson) {
		if (oldjson[n] !== newjson[n]) {
			__ASPFExecuter.SetRowFieldValue(boxs, __ASPFExecuter.GetFieldKey(n), newjson[n]);
		}
	}
}

__ASPFExecuter.GetFieldKey = function (keyv) {
	for (var n in CurrFormulaConfig.FieldsMap) {
		if (CurrFormulaConfig.FieldsMap[n] == keyv) { return n; }
	}
	return "";
}

__ASPFExecuter.GetExecuteRowJSON = function (currRow) {
	var obj = new Object();
	var mps = window.CurrFormulaConfig.FieldsMap;
	var boxs = [];
	var boxs1 = currRow.getElementsByTagName("input");
	var boxs2 = currRow.getElementsByTagName("select");
	for(var i = 0; i<boxs1.length; i++) { boxs.push(boxs1[i]); }
	for(var i = 0; i<boxs2.length; i++) { boxs.push(boxs2[i]); }
	for (var n in mps) {
		obj[mps[n]] = __ASPFExecuter.GetRowFieldValue(boxs, n);
	}
	return obj;
}

__ASPFExecuter.GetRowFieldValue = function (boxs,  fv) {
	var fids = fv.split("[");
	var pv = fids[0].replace("%d", "[0-9]+");
	var reg = new RegExp(pv, "g");
	for (var i = 0; i < boxs.length; i++) {
		var boxid = boxs[i].id;
		if (reg.test(boxid)) {
			if (!fids[1]) { return boxs[i].value }
			else {
				return boxs[i].getAttribute(fids[1].replace("]",""));
			}
		}
	}
}

__ASPFExecuter.GetFormatBit = function (type) {
	switch (type) {
		case "float": return -1;
		case "CommPrice": return window.sysConfig.CommPriceDotNum;
		case "SalesPrice": return window.sysConfig.SalesPriceDotNum;
		case "StorePrice": return window.sysConfig.StorePriceDotNum;
		case "FinancePrice": return window.sysConfig.FinancePriceDotNum;
		case "money": return window.sysConfig.moneynumber;
		case "number": return window.sysConfig.floatnumber;
		case "number2": return 2;
		case "number4": return 4;
		case "discount": return window.sysConfig.discountDotNum;
		case "int": return 0;
		default: return -2;
	}
}

window.FormatRound = function (num, nAfterDot) {
	var d = nAfterDot || 0;
	var m = Math.pow(10, d);
	var n = +(d ? num * m : num).toFixed(12);
	var i = Math.floor(n), f = n - i;
	var e = 1e-8;
	var r = (f > 0.5 - e && f < 0.5 + e) ?
				((i % 2 == 0) ? i : i + 1) : Math.round(n);
	var v = d ? r / m : r;
	return FormatNumber(v, nAfterDot);
}

__ASPFExecuter.SetRowFieldValue = function (boxs, key, value) {
	var fids = key.split("[");
	var pv = fids[0].replace("%d", "[0-9]+");
	var reg = new RegExp(pv, "g");
	for (var i = 0; i < boxs.length; i++) {
		var boxid = boxs[i].id;
		if (reg.test(boxid)) {
			var ibox = boxs[i];
			if (!fids[1]) {
				if (isNaN(value)) { value = 0; }
				value = value.toFixed(10) * 1;  //防止误差
				var bit = __ASPFExecuter.GetFormatBit(ibox.getAttribute("dataformat"));
				var minv = ibox.getAttribute("min");
				var maxv = ibox.getAttribute("max");
				switch (bit) {
					case -1: value = FormatRound((value * 1), 10) * 1; break;  //说明： FormatRound 是四舍六入五成双算法
					case -2: break;
					default: value = FormatRound((value * 1), bit); break;
				}
				ibox.value = value;
				var showid = ibox.getAttribute("showid");
				if (showid) {
					document.getElementById(showid).innerHTML = ibox.value;
				}
			}
			else {
				ibox.setAttribute(fids[1].replace("]",""), value);
			}
		}
	}
}

	//过滤条件判断
__ASPFExecuter.IsFilterCodeOK = function (currRow, filtercode) {
	var json = __ASPFExecuter.GetExecuteRowJSON(currRow);
	var fun  = __ASPFExecuter.GetCacheFuns(filtercode);
	if (!fun) { fun = __ASPFExecuter.SetCacheFuns(filtercode, eval("var r=(function(){ return " + __ASPFExecuter.VarHandle(filtercode) + " });r")); }
	return fun.call(json);
}

	__ASPFExecuter.VarHandle = function (code) {
		if (!CurrFormulaConfig.FieldsKeys) {
			CurrFormulaConfig.FieldsKeys = [];
			for (var n in window.CurrFormulaConfig.FieldsMap) {
				CurrFormulaConfig.FieldsKeys.push(window.CurrFormulaConfig.FieldsMap[n]);
			}
		}
		for (var i = 0; i < CurrFormulaConfig.FieldsKeys.length; i++) {
			var n = CurrFormulaConfig.FieldsKeys[i];
			code = code.replace(new RegExp(n, "gi"), "this." + n);
		}
		return code;
	}

__ASPFExecuter.SetCacheFuns =   function(key, fun){
	if(!window.CurrFormulaConfig.TempFuns) {
		window.CurrFormulaConfig.TempFuns = {};
	}
	window.CurrFormulaConfig.TempFuns[key] = fun;
	return fun;
}

__ASPFExecuter.GetCacheFuns =   function(key){
	if(!window.CurrFormulaConfig.TempFuns) {
		window.CurrFormulaConfig.TempFuns = {};
	}
	return window.CurrFormulaConfig.TempFuns[key];
}

__ASPFExecuter.GeTiggerObject = function (id) {
	for (var key in window.CurrFormulaConfig.FieldsMap) {
		var p = key.split("[")[0].replace("%d", "[0-9]+");
		var reg = new RegExp(p, "g");
		if (reg.test(id)) {
			return {
				domobj: document.getElementById(id),
				keyname: window.CurrFormulaConfig.FieldsMap[key]
			};
		}
	}
	return null;
}

__ASPFExecuter.GetTiggerDBName = function (dbname) {
	var gs = window.CurrFormulaConfig.FormulaGroups;
	for (var i = 0; i < gs.length; i++) {
		if (gs[i].tigger == dbname) {
			return gs[i].tigger;
		}
	}
	return null;
}

//事件监听
__ASPFExecuter.EventLister = function (e) {
	var obj = __ASPFExecuter.GeTiggerObject(e.target.id);
	if (!obj) { return;}
	var domobj = obj.domobj;
	if (!domobj || domobj.type == "hidden" || (domobj.readOnly && domobj.getAttribute("isattrsumbox")!="1") ) { return; }
	var currvalue = e.target.value;
	if (e.type == "focusin") {
		e.target.setAttribute("FormulaFocusValue", currvalue);
		return;
	} else {
		var lastv = e.target.getAttribute("FormulaFocusValue");
		if (lastv == currvalue) {
			return;
		}
		e.target.setAttribute("FormulaFocusValue", currvalue);
	}
	var tiggerkey = __ASPFExecuter.GetTiggerDBName(obj.keyname);
	if (tiggerkey) {
		window.__ASPFExecuter.DoExecute({
			tiggerobj: obj.domobj,
			tiggerkey: tiggerkey,
			range : "row"
		});
	}
}

$(function () {
	if (!window.CurrFormulaConfig) {
		alert("缺少公式配置对象 window.CurrFormulaConfig.");
		return;
	}
	window.__ASPFExecuter.DoExecute({
		tiggerobj: null,
		tiggerkey: "@@init",
		range: "page"
	} );
	$(document).bind("keyup", window.__ASPFExecuter.EventLister);
	$(document).bind("mousedown", window.__ASPFExecuter.EventLister);
	$(document).bind("focusin", window.__ASPFExecuter.EventLister);
	$(document).bind("focusout", window.__ASPFExecuter.EventLister);
});
