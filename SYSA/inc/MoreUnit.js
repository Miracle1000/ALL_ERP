function AjaxRequest(url ,fun){
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = fun;
	xmlHttp.send(null);
}
function AjaxHandleUnit(act , urlAttrs , fun){
	var url1 = "../inc/moreunit.asp?act="+ act + (urlAttrs.length>0 ? "&"+urlAttrs : "") + "&timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
	AjaxRequest(url1 ,fun)
}

//选单位
function ConvertUnit(ProductID, OldUnit, NewUnit, Num , UnitAttrInputName , NumInputName , rowindex) {
	AjaxHandleUnit("GetMoreUnitNumber" ,"ProductID="+ProductID + "&OldUnit="+OldUnit+"&NewUnit="+NewUnit+"&Num="+ Num,function(){
		ReloadProductConvertUnit(ProductID, OldUnit, NewUnit, Num , UnitAttrInputName,NumInputName , rowindex);
	});
}
function ReloadProductConvertUnit(ProductID, OldUnit, NewUnit, Num , UnitAttrInputName,NumInputName , rowindex) {
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		document.getElementById(NumInputName).value=response;
		//加载单位组属性
		AjaxHandleUnit("ConvertUnit" , "ProductID="+ProductID + "&OldUnit="+OldUnit+"&NewUnit="+NewUnit+"&Num="+ Num + "&rowindex="+rowindex ,function(){
			ReloadProductUnitAttr(UnitAttrInputName);
		});
	}
}
//加载单位组属性
function ReloadProductUnitAttr(UnitAttrInputName) {
	if (xmlHttp.readyState == 4){
		var response = xmlHttp.responseText;
		document.getElementById(UnitAttrInputName).innerHTML=response;	
		xmlHttp.abort();
	}
}

function LoadMoreUnit(commUnitAttr,rowindex){
	   //请前端设计字段固定字段UI 存储为json
    if(commUnitAttr.length=="") return "";
    var r = "";
    //value = "{formula:'123',v:{'长_1_a':'G100','宽1_b':'G200','高1_c':'300'}}";
    var s = eval("(" + commUnitAttr + ")");
    var formula = s.formula;
    var o = s.v
    var canEditAttr = "";
    var editDefV = "0";
    for (var k in o) {
        var v = o[k] + "";
        var s = k.replace(/_/g, ",");
        var ss = s.split(",");
        var attrName = ss[ss.length - 1];
        var formulaAttr = ss.splice(0, ss.length - 1).join("_");
        var canEdit = v.indexOf("G") < 0;
        var defv = v.replace("G", "")*1;
		var defv = defv.toFixed(window.sysConfig.floatnumber);
		//字段固定字段commUnitAttr 存储为json
		r +=  "<div style='padding-bottom:1px;padding-top:1px'>";
		r +=  formulaAttr + "：<input uitype='numberbox' class='cell_" + rowindex + "' ";
		r +=  " formula='" + formula + "' vttk='" + k + "'  vttn='" + attrName + "'  " + (canEdit ? "  vttr='' " : " readonly vttr='G' ");
		r +=  " style='width:55%;" + (canEdit ? " " : "color:#aaa;");
		r +=  " ' name='UnitFormula_"+ attrName + "_" + rowindex +"' id='UnitFormula_" + attrName + "_" + rowindex +"' ";
		if (canEdit) { r += " onfocus=\"if(this.value==this.defaultValue){this.value='';this.style.color='#000'}\" "; }
		r +=  " onkeyup=\"formatData(this,'number');checkDot('UnitFormula_" + attrName + "_" + rowindex +"','"+ window.sysConfig.floatnumber + "')\" "
		r +=  " onblur=\"if(!this.value){this.value=this.defaultValue;this.style.color='#000'};GetCurrFormulaInfoValue(this," + rowindex + ");\" "
		r +=  " onpropertychange=\"formatData(this,'number');GetCurrFormulaInfoValue(this," + rowindex + ");\" "
		r +=  " dataType='Limit' min='1' max='100'  msg='不能为空' value='" + defv + "' type='text'>"
		r +=  "</div>"
	}
    return r;
}


var rowsi = "0";
function ReSetCode(){
	window.setTimeout(function(){rowsi = "";} , 100);
}


//计算公式 π = 3.14
function GetCurrFormulaInfoValue(box, rowindex) {
	if(window.ActiveXObject && event){
	    if (event.type == "propertychange" && event.propertyName != "value") return;
	    if (box.value.length == 0) return;
	}
	if((","+rowsi+",").indexOf(","+rowindex+",")>-1) return;

    var formulAttrs = $(".cell_" + rowindex);
    var canEditID = "";//最后一个可编辑ID
    var formula = "";
    formulAttrs.each(function () {    
        var vttr = this.getAttribute("vttr");
        if (vttr != "G") {
            canEditID = this.id;
        }
        if (formula.length == 0) {
            formula = this.getAttribute("formula");
        }
    });

    var tmpformula = formula.replace("π", "3.140000");
    tmpformula = tmpformula.split("=")[1];

	var NumberValue = 0;
	//如果当前是最后可编辑属性 则变化数量
	if (box.id == canEditID) {
		formulAttrs.each(function () {
			var vttn = this.getAttribute("vttn");
			var mv = this.value;
			mv = mv.length == 0 || parseFloat(mv) == 0 ? "1" : mv;
			tmpformula = tmpformula.replace(new RegExp(vttn , "g"), mv);
		});
		NumberValue = eval(tmpformula);
		NumberValue = NumberValue.toFixed(window.sysConfig.floatnumber);
		
		if(window.SetRowInfoValue){
			window.SetRowInfoValue(rowindex , "num", NumberValue)
		}else{		
			var numbox = $("#num"+rowindex);
			if (numbox.size()==0){ numbox = $("#num_"+rowindex);}

			rowsi += "," + rowindex;

			numbox.val(NumberValue);
			//非IE兼容
			if(!window.ActiveXObject){ numbox.trigger("blur");}
			ReSetCode();
		}
	} else {
		var mvttn = "";
		if(window.GetRowInfoValue){
			NumberValue = window.GetRowInfoValue(rowindex,"num")
		}else{		
			var numbox = $("#num"+rowindex);
			if (numbox.size()==0){ numbox = $("#num_"+rowindex);}
			NumberValue = numbox.val();
		}
		formulAttrs.each(function () {
			var vttn = this.getAttribute("vttn");
			if (this.id != canEditID) {             
				var mv = this.value;
				mv = mv.length == 0 || parseFloat(mv) == 0 ? "1" : mv;
				tmpformula = tmpformula.replace(new RegExp(vttn , "g"), mv);
			}else{
				mvttn =  vttn;
			}
		});
		var ev = GetFormulaAttrValue(formula ,mvttn , tmpformula, NumberValue);
		$("#" + canEditID).val(ev);
		if(window.SetRowFormulaAttrInfoValue){
			window.SetRowFormulaAttrInfoValue(rowindex ,canEditID, ev , null , true);
		}
	}
	
}

function GetFormulaAttrValue(formula,mvttn, tmpformula, NumberValue) {
	var num = 0;
	tmpformula = tmpformula.replace(new RegExp(mvttn,'g'), function(){ num++ ; return "1"});
    var r =eval(tmpformula);
    var mv = parseFloat(r) == 0 ? 0 : parseFloat(NumberValue) / parseFloat(r);
	if(num>0){mv = Math.pow(mv, 1/num);}
    return mv.toFixed(window.sysConfig.floatnumber);
    /*
    15=1*b*3
    V=π*r*r*h
    V=s*h
    V=s*h/3
    S=a*b
    S=a*h/2
    S=π*r
    */
}

function getFormulaAttrJson(rowindex , fieldname , mv){
	var formulAttrs = $(".cell_" + rowindex);
	var v = "";
	var formula = "";
    formulAttrs.each(function () {
        var vttr = this.getAttribute("vttr");
        v += v.length > 0 ? "," : "";
		var sv = this.value;
		if (fieldname.length>0 && fieldname == this.id){sv = mv;}
        v += "'" + this.getAttribute("vttk") + "':'" + vttr + sv + "'";
		if (formula.length == 0) { formula = this.getAttribute("formula");}
    });
    if (v.length > 0) {
        v = "{'formula':'" + formula + "','v':{" + v + "}}";
    }
	return v;
}

function SetCurrFormulaInfoValue(rowindex, NumberValue, rowobj) {
	if((","+rowsi+",").indexOf(","+rowindex+",")>-1) return;
    var formulAttrs = $(".cell_" + rowindex);
    if (formulAttrs.length == 0) { return; }

    var canEditID = "";//最后一个可编辑ID
    var formula = "";
    formulAttrs.each(function () {
        var vttr = this.getAttribute("vttr");
        if (vttr != "G") {
            canEditID = this.id;
        }
        if (formula.length == 0) {
            formula = this.getAttribute("formula");
        }
    });
    
    var tmpformula = formula.replace("π", "3.140000");
    tmpformula = tmpformula.split("=")[1];
    var mvttn = "";
    formulAttrs.each(function () {
        var vttn = this.getAttribute("vttn");
        if (this.id != canEditID) {
            var mv = this.value;
            mv = mv.length == 0 || parseFloat(mv) == 0 ? "1" : mv;
            tmpformula = tmpformula.replace(new RegExp(vttn , "g"), mv);
        } else {
            mvttn = vttn;
        }
    });
	if(NumberValue.length==0){NumberValue=0;}
    var ev = GetFormulaAttrValue(formula, mvttn, tmpformula, NumberValue);
	if(window.SetRowFormulaAttrInfoValue){
	    window.SetRowFormulaAttrInfoValue(rowindex, canEditID, ev, rowobj);
	}else{
		rowsi += "," + rowindex;
		$("#" + canEditID).val(ev);
		ReSetCode();
	}
}

function SetCurrProductAttrValue(rowindex, NumInputName) {
    var productAttrs = $(".productattr_" + rowindex);
    if (productAttrs.length == 0) { return; }
    var NumberValue = 0;
    var unCost = false;
    productAttrs.each(function () {
        var mv = this.value;
        if (mv.length > 0) unCost = true;
        mv = mv.length == 0 || parseFloat(mv) == 0 || isNaN(mv) ? 0 : mv;
        NumberValue += mv * 1;
    });
    if (unCost == false) return;
    var numbox = $("#" + NumInputName);
    if (numbox.size() == 0) { numbox = $("#num_" + rowindex); }
    NumberValue = NumberValue.toFixed(window.sysConfig.floatnumber);
    numbox.val(NumberValue);
    //非IE兼容
    if (!window.ActiveXObject) { numbox.trigger("blur"); }
}