$(function(){
	setTimeout(function(){
		var fms = document.getElementsByTagName("Form")
		for (var i=0; i<fms.length ; i++)
		{
			$(fms[i]).bind("submit",  window.UpdateProductAttrsFieldsInfo);
			$(fms[i])[0].setAttribute("bindmessage",  "注意：此form 通过Jquery绑定了 window.UpdateProductAttrsFieldsInfo事件，onsubmit时会执行， 参见 \SYSA\inc\ProductAttrhelper.js")
		}
		$(document).bind("keyup", window.watchProductAttrsCellKeyEvent);
	},100);
});

window.watchProductAttrsCellKeyEvent = function (e) {
	var obj = e.target;
	if (obj && obj.tagName=="INPUT") {
	    if (obj.id.indexOf("AttrsBatch_Attr1") > 0 && obj.readOnly == false) {
			UpdateAttrsSumNumber(obj);
		}
	}
}

window.UpdateAttrsSumNumber = function (box) {
	var tb = $(box).parents(".productattrstable")[0];
	var cellboxs = $(tb).find("input[IsAttrCellBox=1]");
	var sumbox = $(tb).find("input[IsAttrSumBox=1]")[0];
	var existv = false;
	var sumv = 0;
	for (var i = 0; i < cellboxs.length; i++) {
		var iv = cellboxs[i].value;
		if ((iv + "").length > 0) {
			existv = true;
			sumv = sumv * 1 + iv * 1;
		}
	}
	sumbox.value = FormatNumber(sumv, window.sysConfig.floatnumber);
	if (existv) {
		$(sumbox).parents("td[isattrcell=1]")[0].className = "attrreadsum"
		//sumbox.readonly = true;
		$(sumbox).attr("readonly","readonly");
	} else {
		$(sumbox).parents("td[isattrcell=1]")[0].className = ""
		$(sumbox).removeAttr("readonly");
	}
	$(sumbox).trigger("blur");
}

window.IsRightSame = function(s1, s2) {
	var s1=  s1.split("").reverse().join("");
	var s2=  s2.split("").reverse().join("");
	return s1.indexOf(s2)==0;
}

window.ArrayIndexOf = function (arr, v) {
	for (var i = 0; i < arr.length; i++) {
		if (arr[i] === v) { return i;}
	}
	return -1;
}

// 阻止浏览器行为的方法，用来解决扫描枪bug, 阻止回车键触发submit事件[BUG:53930] IE浏览器上合同添加明细页点击空白处然后按回车，这个页面就会刷新
window.PreventBrowserDefaultBehavior = function (e) {
	if (e && e.preventDefault) {
		//阻止默认浏览器动作(W3C)
		e.preventDefault();
	} else {
		//IE中阻止函数器默认动作的方式 
		window.event.returnValue = false;
		window.event.cancelBubble = true;
	}
	return false
}
window.UpdateProductAttrsFieldsInfo = function (e) {
		var boxs = document.getElementsByName("__sys_productattrs_batchid");
		for(var xx = 0; xx<boxs.length; xx++){
				var box = boxs[xx]
				var batid = box.value
				var spans =  $(box).parents("span[id]");
				var span =  null;
				for (var i =0; i<spans.length ; i++)
				{
					if(spans[i].id.indexOf("trpx")>=0) { span = spans[i]; break; }
				}
				var batidstr = batid + "";
				var batidstrlen = batidstr.length;
				var names = [];
				if(span!=null) {
					var inputs = span.getElementsByTagName("input");
					for(var i =0 ; i< inputs.length; i++){
						var n = inputs[i];
						var nm = n.name || "";
						if(nm=="") { continue; }
						var isnotattrdb = nm.indexOf("AttrsBatch_Attr1_") ==-1 ;
						isnotattrdb = isnotattrdb && nm.indexOf("AttrsBatch_Attr2_")==-1;
						isnotattrdb = isnotattrdb && nm.indexOf("__sys_productattrs_batchid")==-1;
						isnotattrdb = isnotattrdb && nm.indexOf("__sys_productattrs_fields_")==-1;
						if(isnotattrdb && IsRightSame(nm,  batidstr) ) {
							nm =  nm.substr(0, nm.length-batidstrlen);
							if (window.ArrayIndexOf(names,nm) == -1) { names.push(nm) }
						} 
					}
					var inputs = span.getElementsByTagName("textarea");
					for(var i =0 ; i< inputs.length; i++){
						var n = inputs[i];
						var nm = n.name || "";
						if(nm=="") { continue; }
						var isnotattrdb = nm.indexOf("AttrsBatch_Attr1_") ==-1 ;
						isnotattrdb = isnotattrdb && nm.indexOf("AttrsBatch_Attr2_")==-1;
						isnotattrdb = isnotattrdb && nm.indexOf("__sys_productattrs_batchid")==-1;
						isnotattrdb = isnotattrdb && nm.indexOf("__sys_productattrs_fields_")==-1;
						if(isnotattrdb && IsRightSame(nm,  batidstr) ) {
							nm =  nm.substr(0, nm.length-batidstrlen);
							if (window.ArrayIndexOf(names, nm) == -1) { names.push(nm) }
						} 
					}
					var inputs = span.getElementsByTagName("select");
					for(var i =0 ; i< inputs.length; i++){
						var n = inputs[i];
						var nm = n.name || "";
						if(nm=="") { continue; }
						var isnotattrdb = nm.indexOf("AttrsBatch_Attr1_") ==-1 ;
						isnotattrdb = isnotattrdb && nm.indexOf("AttrsBatch_Attr2_")==-1;
						isnotattrdb = isnotattrdb && nm.indexOf("__sys_productattrs_batchid")==-1;
						isnotattrdb = isnotattrdb && nm.indexOf("__sys_productattrs_fields_")==-1;
						if(isnotattrdb && IsRightSame(nm,  batidstr) ) {
							nm =  nm.substr(0, nm.length-batidstrlen);
							if (window.ArrayIndexOf(names, nm) == -1) { names.push(nm) }
						} 
					}
				}
				document.getElementById("__sy_pa_fs_" +batid).value =  names.join("|");
		}
		return;
}

window.GetCurrAttr2Value=function(id){
    try{
        return  document.getElementsByName("AttrsBatch_Attr2_"+id)[0].value;
    }catch(e){
        return 0;
    }
}