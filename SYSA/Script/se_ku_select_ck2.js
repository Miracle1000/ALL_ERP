function UpdateFznum(box) {
    var td = box.parentElement.parentElement;
    var tr = td.parentElement;
    var Ismode = $(tr).find("input[name='Ismode']").eq(0)[0].value;//数据来源标识
    var bl = $(tr).find("input[name='blnum']").eq(0)[0].value;//
    var obj = $(tr).find("input[name='fznum']").eq(0)[0];
    var fznum = obj ? obj.value : 0;//现有库存
    var bl1 = $(tr).find("input[name='blnum1']").eq(0)[0].value;//初始库存
    var zdnum = $(tr).find("input[name='zdkc']").eq(0)[0].value;
    if (obj) {
        if (parseFloat(bl1) > 0 && parseFloat(bl) > 0 && zdnum > 0) {
            if (Ismode == 1) {
                obj.value = FormatNumber(parseFloat(zdnum) * parseFloat(bl) / parseFloat(bl1), window.sysConfig.floatnumber);
            } else {
                obj.value = FormatNumber(parseFloat(zdnum) * parseFloat(bl1) / parseFloat(bl), window.sysConfig.floatnumber);
            }
        } else {
            obj.value = 0;
        }
    }
}

function fznumcheck(box)
{
    var td = box.parentElement.parentElement;
    var tr = td.parentElement;
    var Isopenfzunit = $(tr).find("input[name='fzunit']").eq(0)[0].value;//辅助单位
    var obj = $(tr).find("input[name='fznum']").eq(0)[0];
    var fznum = obj? obj.value : 0;//指定辅助数量
    var fzAssistNum = $(tr).find("input[name='fzAssistNum']").eq(0)[0].value;//现有库存
    var fzunit = $(box).attr("assunit");//辅助单位
    var zdkc=$(tr).find("input[name='zdkc']").eq(0)[0].value;//指定数量
    var rowMaxNum = $(tr).find("input[name='xynum2kucun']").eq(0)[0].value;//现有单位现有库存
    if (Isopenfzunit == 1 && fzunit * 1 > 0 && fznum * 1 == 0 && zdkc * 1 > 0) {

        alert("辅助数量不能为0！")
        $(tr).find("input[name='zdkc']").eq(0)[0].value = 0
        if (window.parent.klistEventHandle) {
            window.parent.klistEventHandle.fznum = '';
            window.parent.klistEventHandle.data = '';
            window.parent.klistEventHandle.hsnum = '';
            window.parent.klistEventHandle.change();
        }
        return;
    }
    if (parseFloat(fznum) > parseFloat(fzAssistNum.replace(",",""))) {
        alert("数量不能大于辅助库存" + fzAssistNum);
        if (obj) obj.value = "";
        $(tr).find("input[name='zdkc']").eq(0)[0].value = 0
        if (window.parent.klistEventHandle) {
            window.parent.klistEventHandle.fznum = '';
            window.parent.klistEventHandle.data = '';
            window.parent.klistEventHandle.hsnum = '';
            window.parent.klistEventHandle.change();
        }
        return;
    }

    if (Isopenfzunit == 1 && (Number(fznum) != Number(fzAssistNum) && Number(zdkc) == Number(rowMaxNum))) {

        alert("与剩余辅助数量不匹配！")
        if (obj) obj.value = "";
        $(tr).find("input[name='zdkc']").eq(0)[0].value = 0
        if (window.parent.klistEventHandle) {
            window.parent.klistEventHandle.fznum = '';
            window.parent.klistEventHandle.data = '';
            window.parent.klistEventHandle.hsnum = '';
            window.parent.klistEventHandle.change();
        }
        return;
    }
    if (Isopenfzunit == 1 && (Number(fznum) == Number(fzAssistNum) && Number(zdkc) != Number(rowMaxNum))) {
        alert("与剩余辅助数量不匹配！")
        if (obj) obj.value = "";
        $(tr).find("input[name='zdkc']").eq(0)[0].value = 0
        if (window.parent.klistEventHandle) {
            window.parent.klistEventHandle.fznum = '';
            window.parent.klistEventHandle.data = '';
            window.parent.klistEventHandle.hsnum = '';
            window.parent.klistEventHandle.change();
        }
        return;
    }

}

function Update(box){
    var txt = "";
    var fztxt = "";
	var td = box.parentElement.parentElement;
	var tr = td.parentElement;
	var tb = tr.parentElement.parentElement;
	var rowMaxNum = $(box).attr('max') * 1;
	if (isNaN(box.value)==true){
		alert("请输入正确的数字");
		box.value = "0";
		return ;
	}
	var obj = $(tr).find("input[name='fznum']").eq(0)[0];
	if(box.value*1 > rowMaxNum){
		alert("数量不能大于库存" + rowMaxNum);
		box.value = "0";
		if (obj) obj.value = "";
		return ;
	}

	var smnum = 0
	for(var i = 2;i< tb.rows.length;i++){
	    var elm = $(tb.rows[i]).find("input[name='zdkc']").eq(0)[0];
	    var v = $(tb.rows[i]).find("input[name='fznum']").eq(0)[0];
	    var vv = v ? v.value : "";
		smnum = accAdd(smnum*1,elm.value*1);
		txt = txt + (i > 2 ? "|" : "") + elm.id.replace("n_", "") + "=" + elm.value + "=" + (vv == "" ? 0 : vv) + "=" + $(elm).attr("zdunit") + "=" + $(elm).attr("zdxlh")
		fztxt = fztxt + (i > 2 ? "|" : "") + ( v ? v.id.replace("f_", "") + "=" + (vv == "" ? 0 : vv) + "=" + $(v).attr("assunit") : "==")
	}
	var mnum = parseFloat(1*tb.rows[0].cells[3].innerText);
	if(smnum > mnum){
		alert("数量不能大于总出库数" + mnum);
		box.value = "0";
		if (obj) obj.value = "";
		return;
	}
	box.defv = parseFloat(box.value);
	tb.rows[0].cells[5].innerHTML = "<center><font size=4 style='color:red'>" + FormatNumber(formatDot(accSub(mnum,smnum),window.sysConfig.floatnumber),window.sysConfig.floatnumber) + "</font></center>"
	if (window.parent.klistEventHandle) {
	    window.parent.klistEventHandle.fznum = fztxt;
		window.parent.klistEventHandle.data =  txt;
		window.parent.klistEventHandle.hsnum = FormatNumber(smnum,window.sysConfig.floatnumber);
		window.parent.klistEventHandle.change();
	} 
}
function FormatNumber(srcStr,nAfterDot){
　　var srcStr,nAfterDot;
　　var resultStr,nTen;
　　srcStr = ""+srcStr+"";
　　strLen = srcStr.length;
　　dotPos = srcStr.indexOf(".",0);
　　if (dotPos == -1){
　　　　resultStr = srcStr+".";
　　　　for (i=0;i<nAfterDot;i++){
　　　　　　resultStr = resultStr+"0";
　　　　}
　　　　return resultStr;
　　}
　　else{
　　　　if ((strLen - dotPos - 1) >= nAfterDot){
　　　　　　nAfter = dotPos + nAfterDot + 1;
　　　　　　nTen =1;
　　　　　　for(j=0;j<nAfterDot;j++){
　　　　　　　　nTen = nTen*10;
　　　　　　}
　　　　　　resultStr = Math.round(parseFloat(srcStr)*nTen)/nTen;
　　　　　　return resultStr;
　　　　}
　　　　else{
　　　　　　resultStr = srcStr;
　　　　　　for (i=0;i<(nAfterDot - strLen + dotPos + 1);i++){
　　　　　　　　resultStr = resultStr+"0";
　　　　　　}
　　　　　　return resultStr;
　　　　}
　　}
}


function loaddata(){
	if(window.parent.klistEventHandle){
		if(window.parent.klistEventHandle.data=="0"){
			return;
		}
		var box = null;
		var row = window.parent.klistEventHandle.data.split("|")
		for(var i = 0 ; i < row.length ; i ++){
			var cell = row[i].split("=")
			box = document.getElementById("n_" + cell[0])
			if(box){
				box.value = cell[1];
				box.defv = box.value;
			}
		}

		var fzrow = window.parent.klistEventHandle.fznum.split("|")
		for (var i = 0 ; i < fzrow.length ; i++) {
		    var cell = fzrow[i].split("=")
		    box = document.getElementById("f_" + cell[0])
		    if (box) {
		        box.value = FormatNumber(cell[1], window.sysConfig.floatnumber);
		        box.defv = FormatNumber(box.value, window.sysConfig.floatnumber);
		    }
		}
		if(box){
			Update(box);
		}
	} 
}

//flg表示是否在检索到结果后指定数量自动增加
var xlhLast="";
function PageSearch(obj,flg){
	if(event.keyCode!=13) return;
	var stxt=obj.value;
	var xlhfind=false;
	var tbobj = document.getElementById("content");
	for(var i=2;i<tbobj.rows.length;i++){
		//3序列号，6现有数量，7指定数量
		if(stxt.length>0){
			if($(tbobj.rows[i]).attr("tag").toLowerCase().indexOf(stxt.toLowerCase())>=0){
				tbobj.rows[i].style.display="";
				if(flg){
					var nowNum=parseFloat($(tbobj.rows[i]).find("input[name='xykc']").eq(0).val());
					var cobj=$(tbobj.rows[i]).find("input[name='zdkc']").eq(0)[0];
					var curNum=parseFloat(cobj.value);
					if(nowNum>curNum){
						if(!xlhfind){
							cobj.value=nowNum;//定制的用这句，通用版用上面那句
							cobj.onchange();
							xlhfind=true;
						}
					}
				}
			}
			else{
				tbobj.rows[i].style.display="none";
			}
		}
		else{
			tbobj.rows[i].style.display="";
		}
	}
	if(flg){obj.value="";}
}
