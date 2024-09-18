var bill = new Object();
var __bodyHtml = "";
bill.groupvisible = function(dbname, visible) {
	var tb = $ID("editbody");
	var dbname = dbname.toLowerCase();
	for (var i = 0; i< tb.rows.length ; i++)
	{
		var row = tb.rows[i];
		var db = row.getAttribute("dbname").toLowerCase();
		if(db==dbname) {
			row.style.display = visible ? "" : "none";
		}
	}
}

bill.doSaveAdd = function(box) {
	$ID("eventName").value = "__sys_dosave";
	$ID("evtbtnname").value = box ? box.value : ""; //扩展保存方法，区分保存模式
	$ID("sys_ad_model").value = 1;
	if (bill.ClientDataValid() == true) {
		var userAgent = navigator.userAgent
		if (userAgent.indexOf("Firefox") > -1) {
			var bgbox = box.parentNode;
			var submitbtn = document.createElement("INPUT");
			submitbtn.type = "submit";
			bgbox.appendChild(submitbtn);
			submitbtn.click();
			bgbox.removeChild(submitbtn);
		} else {
			$ID("mainform").submit();
		}
	    //[BUG:42069] 增强组装清单添加，子件明细包含父件，点击保存失败后重新编辑子件明细。删除子件明细的父件产品。点击增删上下按钮触发弹窗
	    $ID("eventName").value = "";
	} else {
	    $ID("eventName").value = "";
	}
}

window.OnDoSaveHack = [];
window.AddDoSaveHack = function (fun) {
    window.OnDoSaveHack.push(fun);
}
bill.doSave = function (box) {
	$ID("eventName").value = "__sys_dosave";
	$ID("sys_ad_model").value = 0;
	$ID("evtbtnname").value = box ? box.value : "";  //扩展保存方法，区分保存模式
	for (var i = 0; i < window.OnDoSaveHack.length; i++) {
	    try { window.OnDoSaveHack[i](); } catch (ex) { }  
	}
	if (bill.ClientDataValid() == true) {
		var userAgent = navigator.userAgent
		if (userAgent.indexOf("Firefox") > -1) {
			var bgbox = box.parentNode;
			var submitbtn = document.createElement("INPUT");
			submitbtn.type = "submit";
			bgbox.appendChild(submitbtn);
			submitbtn.click();
			bgbox.removeChild(submitbtn);
		} else {
			$ID("mainform").submit();
		}
	    $ID("eventName").value = "";
	} else {
	    $ID("eventName").value = "";
	}
}


bill.showValidMsg = function(cell, msg, color) {
	try {
			var spans = cell.getElementsByTagName("span");
			var span = null;
			for (var i = 0; i < spans.length ; i++ )
			{
				if(spans[i].className=="bill_valid_msg") {
					span = spans[i];
					break;
				}
			}
			if(!span) {
				span = document.createElement("span");
				span.className = "bill_valid_msg";
				try{(cell.getAttribute("ldb") || cell.children[0].tagName=="INPUT" ? cell : cell.children[0]).appendChild(span);}catch(e){}
			}
			if(msg.length>0) {
				span.innerHTML = "&nbsp;" + msg;
			}
			else
			{
				span.innerHTML = "";
			}
			span.style.color = color;
	}catch(e){}
}

bill.ClientDataValid = function() {
	var tb = $ID("editbody");
	var r = true;
	var cells = tb.getElementsByTagName("td");
	for (var i = 0; i < cells.length ; i++)
	{
		var cell = cells[i];
		var hs = true;
		if(cell.getAttribute("ei")=="1") {
			var uitype = cell.getAttribute("ui");
			var notnull = cell.getAttribute("nu");
			var maxlen = cell.getAttribute("max");
			var value = bill.getCellValue(cell);
			if(notnull=="1") {
				if(value.replace(/\s/g,"").length==0) {
					bill.showValidMsg(cell, "必填", "red");
					r = false;
					hs  = false
				}
				else{
					bill.showValidMsg(cell, "", "red");
					hs = true
				}
			}else{
				bill.showValidMsg(cell, "", "red");
			}
			if(uitype=="text" || uitype=="textarea") {
				if(maxlen!=null && value.length > maxlen) {//'BUG 6578 Sword 2014-12-10 凭证字相关bug 
					bill.showValidMsg(cell, (notnull=="1" ? "必须在1至" +  maxlen + "个字之间" : "必须在" + maxlen + "个字以内"), "red");
					r = false;
					hs  = false
				}
			}

			if(uitype=="number" || uitype=="money") {
				var fn = ( uitype == "number" ? "数字" : "金额");
				var disvonhide = ((cell.getAttribute("disvalonhide") + "") == "1"); //元素隐藏是否验证有效性，默认false, 表示需要验证
				if(value.length > 0 && !(disvonhide==true && (cell.style.display=="none" || cell.style.visibility=="hidden"))) {//'BUG 6578 Sword 2014-12-10 凭证字相关bug 
					if(isNaN(value)) {
						r = false;
						hs  = false
						bill.showValidMsg(cell, "请输入有效的数字", "red");
					}
					else
					{
						var maxv = cell.getAttribute("max");
						var minv = cell.getAttribute("min");
						var msg1 = fn + "不能超过" + maxv;
						var msg2 = fn + "不能小于" + minv;
						var msg3 = fn + "必须在" + minv + "到" + maxv + "之间";
						if(maxv !=null && maxv.length>0) { if(maxv*1 < value*1) { bill.showValidMsg(cell, (minv==null?msg1:msg3), "red"); r = false;  hs=false; }}
						if(minv !=null && minv.length>0) { if(minv*1 > value*1) { bill.showValidMsg(cell, (maxv==null?msg2:msg3), "red"); r = false;  hs=false; }}
					}
				}
			}
			var js = cell.getAttribute("validcode");
			if(hs == true && js && js!="") {
				window.tmp_b_tmp_vvv =  value;
				js = "var value = window.tmp_b_tmp_vvv;" + js;
				if(!eval(js)) {
					var msg = cell.getAttribute("validtext");
					msg = (!msg || msg=="") ? "内容不正确" : msg; 
					bill.showValidMsg(cell, msg, "red");
					r = false;
					hs  = false
				}
				else{
					bill.showValidMsg(cell, "", "red");
					hs = true;
				}
			}
		}
		if(cell.getAttribute("ui") && hs==true) {
			if(window.onbillcellValid) {
				hs = window.onbillcellValid(cell);
				if(hs==false) {
					r = false;
				}
			}
		}
	}
	if (r)
	{
		if(window.onbillTbValid) {
			hs = window.onbillTbValid();
			if(hs==false) {
				r = false;
			}
		}
	}
	return r;
}

bill.getlistcellv = function(cell, ustyle) {
	switch(ustyle) {
		case 0 : return cell.getElementsByTagName("input")[0].value;
		case 1 : return cell.getElementsByTagName("select")[0].value;
		case 2 : return cell.getElementsByTagName("textarea")[0].value;
		default: return cell.getElementsByTagName("input")[0].value;
	}
}

bill.getCellValue = function(cell, uicheck, isText) {
	//isText=true表示获取select、radio等对应的文本值
	var notnull = cell.getAttribute("nu");
	var uitype = cell.getAttribute("ui");
	var ldb = cell.getAttribute("ldb") ? true : false; //是否是列表单元格
	var dboxid = "";
	if(!ldb) {
		if(cell.getAttribute("for")) {
			dboxid = cell.getAttribute("for");
		}
		else{
			dboxid = (cell.id + "\1").replace("_cel\1","_0");
			if(!$ID(dboxid)) {
				dboxid = (cell.id + "\1").replace("_cel\1","");
			}
		}
	}
	var nm = (cell.id + "\1").replace("_cel\1","");
	switch(uitype) {
		case "text":		return ldb ? bill.getlistcellv(cell,0,isText) : $ID(dboxid).value;
		case "money":		return ldb ? bill.getlistcellv(cell,0,isText) : $ID(dboxid).value;
		case "hl":			return ldb ? bill.getlistcellv(cell,0,isText) : $ID(dboxid).value;
		case "number":		return ldb ? bill.getlistcellv(cell,0,isText) : $ID(dboxid).value;
		case "date":		return ldb ? bill.getlistcellv(cell,0,isText) : $ID(dboxid).value;
		case "datetime":	return ldb ? bill.getlistcellv(cell,0,isText) : $ID(dboxid).value;
		case "time":		return ldb ? bill.getlistcellv(cell,0,isText) : $ID(dboxid).value;
		case "select":		return ldb ? bill.getlistcellv(cell,1,isText) : (isText ? $ID(dboxid).options[$ID(dboxid).selectedIndex].text : $ID(dboxid).value);
		case "textarea":	return ldb ? bill.getlistcellv(cell,2,isText) : $ID(dboxid).value;
		case "area":		return $ID(dboxid).value;
		case "gate":		return $ID(dboxid).value;
		case "gates" :		return ""; //可完善判断必填
		case "image":		return $ID(dboxid).value;
		case "images":
			var boxs = document.getElementsByName(nm+"_n");
			var  bv = new Array()
			for(var i = 0 ; i < boxs.length; i++ ) {
				if($(boxs[i]).attr("cid") && $(boxs[i]).attr("cid").length>0 ) {
					bv[bv.length] = $(boxs[i]).attr("cid");
				}
			}
			$ID(dboxid).value =  bv.join(",");
			return bv.join(",");
		case "picture":		return $ID(dboxid).value;
		case "colorpicker": return ldb ? bill.getlistcellv(cell,0,isText) : $ID(dboxid).value;
		case "boolbox" :    return $ID(dboxid).checked?1:0;
		case "checkbox":
			var boxs = document.getElementsByName(nm);
			var  bv = new Array()
			for(var i = 0 ; i < boxs.length; i++ ) {
				if(boxs[i].checked) {
					bv[bv.length] = isText ? $ID( boxs[i].id + "_lb").innerText : boxs[i].value;
				}
			}
			return bv.join(",");
		case "radio":
			var boxs = document.getElementsByName(nm);
			var cvalue = ""
			for(var i = 0 ; i < boxs.length; i++ ) {
				if(boxs[i].checked) {
					cvalue = isText ? $ID( boxs[i].id + "_lb").innerText : boxs[i].value;
				}
			}
			return cvalue;
		case "html": return cell.innerHTML;
		case "editor": 
			var wFrame = cell.getElementsByTagName("iframe")[0];
			var html = wFrame.contentWindow.getHtmlValue()
            cell.getElementsByTagName("textarea")[0].value=html ;
			return html;
		case "listview":
			try{
				var lvw = eval("window.lvw_JsonData_bllst_" + nm);
				if (lvw){ 
					if ($("#listviewjson").length==0){
						$("#mainform").append("<input type='hidden' id='listviewjson' name='listviewjson'>")
					}
					$("#listviewjson").val(JSON.stringify(lvw));
				}
			}catch(e){}
			return "";
		case "listtree":
			try{
				var lvw = eval("window.lvw_JsonData_bllst_" + nm);
				if (lvw){ 
					if ($("#listtreejson").length==0){
						$("#mainform").append("<input type='hidden' id='listtreejson' name='listtreejson'>")
					}
					$("#listtreejson").val(JSON.stringify(lvw));
				}
			}catch(e){}
			return "";
		default:
			if (uicheck==true){
				return cell.innerText;
			}else{
				window.confirm("未定义类型[" + uitype + "]的取值方式。");
			}
		
	}
}

bill.doReset = function () {
	//BUG.6404.ZYF 售后知识库管理添加和修改时先点击“重填”按钮，再点击“保存”按钮，页面报错 
	//--出现原因：editor对submit事件进行了绑定，innerHTML后失效；代码位置：edit/include/editor.js  228行
	if(navigator.userAgent.indexOf("Firefox")>0){
		location.href = "";
	}else{
		window.location.reload();
	}
	//$ID("mainform").innerHTML = __bodyHtml;
}

//刷新底部窗口
bill.RefreshOpener = function(url) {
	if(window.opener) {
		if(url=="") {
			if(window.opener.DoRefresh) { //ReportCtl框架页面，可Ajax刷新。
				window.opener.DoRefresh(true);
			}
			else{
				window.opener.location.reload();
			}
		}
		else{
			window.opener.location.href = url;
		}
	}
}

//保持处理结果后续动作函数 opener、self、none、new、空字符串
bill.showSaveResultEx = function(message, closeWindow, RefreshTarget, newUrl) {
	if(RefreshTarget=="") { RefreshTarget = "self"; }
	if(message.length > 0 ) {
		app.Alert(message);
	}
	switch(RefreshTarget.toLowerCase()) {
		case "opener":
			bill.RefreshOpener(newUrl); //刷新父页面
			break;
		case "self":
			if(newUrl=="") {
				window.location.reload();
			}
			else{
				window.location.href = newUrl;
			}
			break;
		default:
			if(RefreshTarget && RefreshTarget!="none") {
				var win = bill.GetWindowTarget(window.top, RefreshTarget);
				if(win) {
					if(newUrl=="") { win.location.reload(); }
					else{ win.location.href = newUrl; }
				}
			}
	}
	if (closeWindow == true && RefreshTarget != "self") {
	    window.close();
	}
}

bill.GetWindowTarget = function(pWindow, frmName) {
	var frms = pWindow.document.getElementsByTagName("IFRAME");
	for (var i = 0; i < frms.length ; i++ )
	{
		if(frms[i].name==frmName) { return frms[i].contentWindow; }
		var win = 	bill.GetWindowTarget(frms[i].contentWindow, frmName);
		if(win) { return win; }
	}
	return null;
}

//更新区域字段值
window.updateAreaSel = function(dbname, txt, value) {
	$ID(dbname + "_0").value = value;
	$ID(dbname + "_nv_0").value = txt;
}

bill.print = function() {
	window.print();
}

function __bill__onload() {
	if(bill.onPageLoad) {bill.onPageLoad()};
	if(window.onBillLoad) {window.onBillLoad()};
	__bodyHtml = $ID("mainform").innerHTML;
	if (window.__ShowImgBigToSmall== true)
	{
		window.__ImgBigToSmall();
	}
}

bill.easyui = new Object();
bill.easyui.createWindow = app.easyui.createWindow
bill.easyui.CAjaxWindow = app.easyui.CAjaxWindow
bill.easyui.closeWindow = app.easyui.closeWindow

//刷新单据列表
bill.refreshList = function(lvwid, cmdEvent, fun) {
	var l = "bllst_" + lvwid;
	var vstate = $ID("__viewstate_lvw_" + l);
	if(!vstate){
		l = "bllst_@" + lvwid;
		vstate = $ID("__viewstate_lvw_" + l); 
	}
	if(!vstate){ alert("无法获取列表的状态数据"); return; }
	ajax.regEvent("billpage_lvw_callback");
	ajax.addParam2("backdata",vstate.value);
	$ap("fname", l.replace("bllst_",""));
	$ap("cmd", cmdEvent);
	$ap("billid", $ID("__ord").value);
	if(fun) { fun(); }
	$ID("bll_lvwbg_" + l.replace("bllst_","")).innerHTML=ajax.send();
	if(window.onlistviewRefresh){window.onlistviewRefresh("lvw_" + l);}
	__lvw_autoListWidth(l);
}

bill.showVmlImage = function(dbname , cmdEvent, lvwid, fun){
	ajax.regEvent("billpage_lvw_onCreateVML");
	if (lvwid && lvwid.length>0){
		var vstate = $ID("__viewstate_lvw_" + lvwid);
		if(!vstate){
			l = "bllst_@" + lvwid;
			vstate = $ID("__viewstate_lvw_" + l); 
		}
		if(!vstate){ alert("无法获取列表的状态数据"); return; }
		ajax.addParam2("backdata",vstate.value);
		$ap("fname", lvwid);
		$ap("billid", $ID("__ord").value);
	}
	$ap("cmd", cmdEvent);
	if(fun) { fun(); }
	$ID("vml_" + dbname).innerHTML=ajax.PreScript(ajax.send());
}

bill.editBodyKeyUp = function() {
	var box = window.event.srcElement;
	if(box.tagName=="TEXTAREA") {
		box.style.height =  box.scrollHeight + "px";
	}
}

bill.createRoundWindow = function(id, o) {
	var div = $ID("RoundWin_" + id);
	var Round = o.Round ? o.Round :4;
	var html1 = "";
	var html2 = "";
	if(!div) {
		var div = document.createElement("div");
		div.id = "RoundWin_" + id;
		document.body.appendChild(div);
	}
	div.style.cssText = "position:absolute;width:" + o.width + "px;height:" + o.height + "px; left:" + o.left + "px; top:" + o.top + "px";
	for (var i = 1; i <= Round; i++ )
	{
		var x = Round - i;
		var p1 = Round < 6 ? x: Round-Math.sqrt(Round*Round-Round-x*x)
		var p2 = Round < 6 ? i: Round - Math.sqrt(Round*Round-i*i) ;
		html1 = html1 + "<B style='display:block;height:1px;overflow:hidden;border-right:1px solid " + o.bordercolor + ";border-left:1px solid " + o.bordercolor + ";background-color:" + (i==1 ? o.bordercolor : o.bgcolor) + ";margin-left:" + p1 + ";margin-right:" + p1 + "'></b>";
		html2 = html2 + "<B style='display:block;height:1px;overflow:hidden;border-right:1px solid " + o.bordercolor + ";border-left:1px solid " + o.bordercolor + ";background-color:" + (i==Round ? o.bordercolor : o.bgcolor) + ";margin-left:" + p2 + ";margin-right:" + p2 + "'></b>"
	}
	div.innerHTML = html1 + "<div id='rondWinBody_" +  id + "' style='height:" + (o.height-Round*2) +"px;background-color:" + o.bgcolor + ";padding:0px;border-right:1px solid " + o.bordercolor + ";border-left:1px solid " + o.bordercolor + ";'>aaaa</div>" + html2;
	div.style.display  = "block";
	return $ID("rondWinBody_" + id);
}

bill.closeRoundWindow = function(id) {
	$ID("RoundWin_" + id).style.display = "none";
}

bill.showUploadDlg = function(ebox, vboxid, source, id1, id2, id3, filter , isopenproc) {
	var pos = GetObjectPos(ebox);
	var bodyw = document.body.offsetWidth;
	l = pos.left;
	t = pos.top + ebox.offsetHeight + 3;
	if (l + 500 > bodyw)
	{
		l = pos.left+ebox.offsetWidth-400;
	}
	var win = bill.createRoundWindow("bll_uploadRes_" + vboxid, {width:400, height:112,left:l,top:t,bordercolor:"#AAA",bgcolor:"#DAEAFA"});
	win.innerHTML = "<div class='resetTableBg reseetTextColor' style='padding-left:10px;color:#5b7cae;padding-top:5px;cursor:default''><div><div style='float:right;padding-right:13px'>"
					+ "<a href='javascript:void(0)' onclick='bill.closeRoundWindow(\"bll_uploadRes_" + vboxid+"\")'>关闭</a></div><b >文件上传</b></div>"
					+ "<div style='height:5px;overflow:hidden'>&nbsp;</div>"
					+ "<form method=post target='frm_res_up_" + vboxid + "' id='frm_res_post_" + vboxid + "' style='display:inline' "
					+ " action='" + window.virpath + "sdk/bill.upload.asp' enctype=\"multipart/form-data\">"
					+ "<table style='height:56px;width:100%'><col style='width:80px'><col><col style='width:80px'>"
					+ "<tr><td>&nbsp;选择文件：</td><td><input id='b_up_" + vboxid + "_fpath' type='text' "
					+ " style='background-color:#dedede;border:1px solid #9496aa;height:17px;width:94%' readonly></td>"
					+ "<td><div style='height:20px;overflow:hidden;width:50px;position:relative'>"
					+ "<button class='oldbutton' id='b_up_" + vboxid + "_btn1' >浏览</button><br>"
					+ "<input type='file'  name='sys_res_fpath' onchange='$ID(\"b_up_" + vboxid + "_fpath\").value=this.value'  id='b_up_" + vboxid + "_btn' "
					+ " onmousedown='$ID(this.id+\"1\").style.paddingTop=2' onmouseup='$ID(this.id+\"1\").style.paddingTop=style.paddingTop;' "
					+ " style='position:absolute;top:0px;width:60px;left:-1px;filter: alpha(opacity=0);opacity:0;height:20px;overflow:hidden'>"
					+ "</div>"
					+ "</td></tr>"
					+ "<tr><td>&nbsp;文件描述：</td><td><input name='sys_res_remark' maxlength=200 type='text' "
					+ " style='background-color:#ffffff;border:1px solid #9496aa;height:17px;width:94%'></td>"
					+ "<td><button onclick='return bill.doResSubmit(\"" + vboxid + "\",\"" + filter + "\","+ isopenproc +")' class='oldbutton'>上传</button></td>"
					+ "</tr>"
					+ "</table>"
					+ "<input type='hidden' name='sys_res_source' value='" + source + "'>"
					+ "<input type='hidden' name='sys_res_id1' value='" + id1 + "'>"
					+ "<input type='hidden' name='sys_res_id2' value='" + id2 + "'>"
					+ "<input type='hidden' name='sys_res_id3' value='" + id3 + "'>"
					+ "</form><iframe name='frm_res_up_" + vboxid + "' style='width:1px;height:1px;overflow:hidden;' frameborder=0></iframe>"
					+ "</div>"
					+ "<div id='frm_res_progress' style='display:none;position:absolute;margin-top:-111px;width:400px;height:112px;BACKGROUND-COLOR:#9999aa;filter:alpha(Opacity=60);-moz-opacity:0.6;-khtml-opacity:0.6;opacity:0.6;'>"
					+ "<div id='imgs' style='position:absolute;margin:0 auto;'>"
					+ " <img src='"+window.virpath+"skin/default/images/proc.gif' style='width:20px;margin-top:12px;margin-left:90px;'/></div>"
					+ "<div style='position:absolute;margin:0 auto; margin-top:12px;margin-left:115px;'><span style='color:white;font-weight:bold;'> 正在上传,请等待......</span></div>"
					+ "</div>"
}

bill.doResSubmit = function(id, filter , isopenproc) {
	var path = $ID("b_up_" + id + "_fpath").value;
	if(path.length==0){
			app.Alert("请选择要上传的文件");
			return false;
	}
	var fs  = path.split(".");
	var ftype = fs[fs.length-1].toLowerCase();
	var filters = "|" + filter.toLowerCase().replace(/\,/, "|").replace(/\;/, "|").replace(/\./, "|") + "|";
	if(filters.indexOf("|" + ftype + "|")==-1){
			app.Alert("此处只支持上传" + filter.replace(/\|/g,"、") + "格式文件。");
			return false;
	}
	$ID("frm_res_post_" + id + "").submit();
	$("#frm_res_progress").show();
	return true;
}

bill.showDel = function(objli) {
	//app.Alert("newico_cle.gif \n 我要删除!!!!!!!\n\n 对不起,还不支持!")
	var cid = $(objli).attr("cid");
	if (cid && cid!="" && cid!="0"){
		if ($("#image_del_"+cid).length==0){
			//var html="<img id='image_del_"+cid+"' onclick='bill.deleteImg(event,this,"+ cid +")' class='delimg' src='"+window.virpath+"skin/default/images/imgico_cle.gif'>";
			var html="<div id='image_del_"+cid+"' onclick='bill.deleteImg(event,this,"+ cid +")' class='deloperate'><i>删除</i></div>"
			$(objli).append(html);
		}else{
			$("#image_del_"+cid).show();
		}
	}
}

bill.hideDel = function(objli){
	var cid = $(objli).attr("cid");
	if (cid && cid!="" && cid!="0"){
		$("#image_del_"+cid).hide();
	}
}

bill.showBigImage = function(objli){
	var cid = $(objli).attr("cid");
	if (cid && cid!="" && cid!="0"){
		if ($(objli).find(".showdiv").size()>0){
			ftype = $(objli).attr("ftype");
			var url = $(objli).find(".showdiv").eq(0).attr("src");
			if (ftype=="png" || ftype=="bmp" || ftype=="jpg" || ftype=="jpeg" || ftype=="gif"){	
				window.open(window.virpath + 'inc/img.asp?url='+ajax.UrlEncode(url));
			}else if(confirm("下载该文件？")){
				window.open(url);
			}
		}else{
			var url = $(objli).find("img").eq(0).attr("src");
			window.open(window.virpath + 'inc/img.asp?url='+ajax.UrlEncode(url));
		}
	}
}

bill.deleteImg=function(e,currObj, imgid){
	if (confirm("确定删除吗?")){
		ajax.regEvent("billpage_images_delete");
		ajax.addParam2("id",imgid);
		ajax.send();
		//var index = $(currObj).parent().index($(currObj).parent().parent().children());
		var num =$(currObj).parent().parent().children().size();
		if (num<=2){
			$(currObj).parent().attr("cid","0");
			var defsrc = window.virpath+"skin/default/images/u109.png";
			if ($(currObj).parent().find("img").size()==2){
				$(currObj).parent().find("img").first().attr("src", defsrc);
			}else{

				$(currObj).parent().find("div").eq(0).remove();
				$("<img src='"+ defsrc + "'>").insertBefore($(currObj));
				$(currObj).remove();
			}
		}else{
			$(currObj).parent().remove();
		}
	}
	if (e && e.stopPropagation) {
       //W3C取消冒泡事件
		e.stopPropagation();
    }else{
       //IE取消冒泡事件
      window.event.cancelBubble = true;
    }
}
//上传返回处理接口
window.onUploadFileComplete = function(source, id1, id2, id3, srcId, rsaid ,ftype ,fname) {
	var ks = source.split(".");
	var ui = $($ID(ks[1] + "_cel")).attr("ui");
	var src = window.virpath + "sdk/bill.upload.asp?__msgId=view&srcid=" + srcId;
	if (ui=="images"){
		var html = "";
		var arrExtra = fname.split(".");
		var extraName = arrExtra[arrExtra.length-1];//文件扩展名
		var furl = "skin/default/images/rar.png";
		switch(extraName){
			case "png"	:
			case "bmp"	: 
				furl = "skin/default/images/png.png";
				break;
			case "jpg"	:
			case "jpeg"	:
			case "gif"	:
			case "tiff" :
			case "jfif" :
			case "wmf"	:
			case "xmind":
			case "eps"	:
			case "exb"	:
			case "dwt"	:
			case "dwg": 
				furl = "skin/default/images/image.png";
				break;
			case "rar"	:
			case "zip"	: 
				furl = "skin/default/images/rar.png";
				break;
			default :
				furl = "skin/default/images/"+ extraName +".png";
				break;
		}
		if (ftype.indexOf("image")>=0 && 1==2){
			html = "<img src='"+ src + "'>"
		}else{
			html = "<div class='showdiv' src='" + src + "'><img src='"+ window.virpath + furl + "' style='height:1.0in;width:1.0in;margin-left:0.1in;border:0'>"
				+ "<div align='center' style='width:100%;margin-top:-0.08in'><a>"+ (fname.length>8? fname.substr(0,8)+"..." : fname) +"</a></div></div>" ;
		}
		var files = $("li[name='"+ks[1]+"_n']");
		var num = files.size(); //附件数量
		var cid = $(files[num-1]).attr("cid");
		//最后一个的cid不为0 说明存在文件 需要新增1个li放最新文件
		if (cid && cid!="" && cid!="0"){
			//创建元素
			var lihtml = "<li class='showli' name='"+ ks[1] +"_n' cid="+ srcId +" onmouseover='bill.showDel(this)' ftype='"+ extraName +"' "
						+ " onclick=\"bill.showBigImage(this);\" onmouseout='bill.hideDel(this)'></li>";
			var li = $(lihtml);
			li.append(html);
			li.insertBefore($($ID(ks[1]+"_add_n")));
			//$($ID(ks[1] + "_ul")).append(li)
		}else{
			//修改元素
			$(files[num-1]).attr("cid" , srcId);
			$(files[num-1]).attr("ftype" ,extraName);
			$(files[num-1]).empty();
			$(files[num-1]).append(html);
		}
		
	}else{
		$ID(ks[1] + "_0").value = srcId;
		$ID(ks[1] + "_0").setAttribute("rsaid", rsaid);
		if($ID(ks[1] + "_m")) { $ID(ks[1] + "_m").src = src };
	}
	bill.closeRoundWindow("bll_uploadRes_" + ks[1] + "_0");
	app.fireEvent($ID(ks[1] + "_0"), "onchange");
}
//人员单选弹出会话框
bill.showGateDlg = function(ebox, vboxid, sort1) {
	var pos = GetObjectPos(ebox);
	var bodyw = document.body.offsetWidth;
	l = pos.left;
	t = pos.top + ebox.offsetHeight + 3;
	if (l + 500 > bodyw){ l = pos.left+ebox.offsetWidth-400; }
	var v = $ID(vboxid + "_0").value;
	bill.easyui.CAjaxWindow("ShowGateDlg", function() {
		ajax.addParam("bid",vboxid);
		ajax.addParam("pord", v);
		ajax.addParam("sort", sort1);//团队管理的权限类型
	});
}

window.updateBoxSel = function(DlgID, dbname, txt, value) {
	window.updateAreaSel(dbname, txt, value);
	bill.easyui.closeWindow(DlgID);
}


bill.editBodyKeyUp = function() {
	var box = window.event.srcElement;
	if(box.tagName=="TEXTAREA") {
		while (box.scrollHeight < box.clientHeight){
			if (box.getAttribute("rows") > 4){box.setAttribute("rows",parseInt(box.getAttribute("rows"))-1)}else{break;}
		}
		while (box.scrollHeight > box.clientHeight){
			box.setAttribute("rows",parseInt(box.getAttribute("rows"))+1)
		}
	}
}

bill.foldGroup = function(box) {
	var c = 1;
	if(box.src.indexOf("r_down.png")>0) {
		box.src = box.src.replace("r_down.png","r_up.png");
		box.title = "点击展开";
		c = 1;
	} else {
		box.src = box.src.replace("r_up.png", "r_down.png");
		box.title = "点击折叠";
		c = 2;
	}
	var row = box.parentNode.parentNode.parentNode;
	var db = row.getAttribute("dbname");
	var rows = row.parentNode.rows;
	for (var i = 0; i < rows.length ; i++ )
	{
		var itemr = rows[i];
		if(itemr.getAttribute("dbname")==db && itemr!=row){
			if(c==1) {
				itemr.className = itemr.className.replace("s_f_d0","s_f_d1");
			} else {
				itemr.className = itemr.className.replace("s_f_d1","s_f_d0");
			}
		}
	}
}

//自动完成字段弹出会话框 showType 显示方式
bill.setAutoComplete = function(ebox, vboxid, title , datatype , url , showType) {
	if (datatype==""){
		window.open(window.virpath + url +",'" + vboxid + "_list','width=1000,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=200'");
	}else{
		var v = $ID(vboxid + "_nv_0").value;
		if (showType && showType=="1"){
			var pos = GetObjectPos(ebox);
			var bodyw = document.body.offsetWidth;
			l = pos.left;
			t = pos.top + ebox.offsetHeight + 3;
			if (l + 500 > bodyw){ l = pos.left+ebox.offsetWidth-400; }	
			bill.easyui.CAjaxWindow("setAutoComplete", function() {
				ajax.addParam("fid",vboxid);
				ajax.addParam("fv", v);
				ajax.addParam("title", title);
				ajax.addParam("datatype",datatype);
				if (url!=""){
					//动态传输数据参数
					var arrFields = url.split("{@");
					for (var i=1;i<arrFields.length ;i++ ){
						var boxid = arrFields[i].replace("}","");
						ajax.addParam(boxid, $ID(boxid + "_0").value);
					}
				}
			});
		}else{
			app.Alert("暂不支持该呈现方式! 【" + v + "】") ;
		}
	}
}

bill.TexTxmFocus = function(event){
	event = event? event: window.event
	if(!event) return;
	var obj = event.srcElement ? event.srcElement:event.target; 
	if(!obj) return ;
	if(obj.name==undefined){
		var eo = null;
		try{
			eo = document.getElementsByName("txm")[0];
			//eo.style.cssText = "overflow:hidden;font-size:1px;position:absolute;top:" + (document.body.scrollTop+2) + "px;left:" + (document.body.scrollLeft+2) + "px;border:0px;width:100px;height:100px;background-color:transparent";
			eo.focus();
		}catch(e1){
			try{
				eo = parent.document.getElementsByName("txm")[0];
				//eo.style.cssText = "overflow:hidden;font-size:1px;position:absolute;top:" + (document.body.scrollTop+2) + "px;left:" + (document.body.scrollLeft+2) + "px;border:0px;width:1px;height:1px;background-color:transparent";
				eo.focus();
			}catch(e1){}
		}
	}
}

bill.onScanComplete = null;

bill.txmAjaxSubmit = function(obj){
	var TxmText=obj.value;
	if (TxmText.length ==0){return;}
	if(bill.onScanComplete){
		bill.onScanComplete(TxmText);
	}else{
		app.Alert("开启了扫描录入功能，请定义bill.onScanComplete方法，详情见billpage.js");
	}
	obj.value = "";
}

setTimeout(function(){
	if(!window.Bill) {
		window.Bill = new Object();
		window.Bill.showunderline = function(){}
	}
	if (__ImgBigToSmall) { __ImgBigToSmall("","",100) }
	if(FilePreviewAndDownload){
	    FilePreviewAndDownload()
	}
},100);