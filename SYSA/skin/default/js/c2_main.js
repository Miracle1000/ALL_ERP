function cardvShowAdvDlg(bn, id) {
    //var div = top.app.createWindow("rpt_sadv_as", tbox.innerHTML + " - 高级检索", "", '', '', '700', '500', 0, 1, "#ffffff")
    var frmobj = document.getElementById("rptadvForm");
    if (!frmobj) {
        frmobj = document.createElement("form");
        frmobj.id = "rptadvForm";
        frmobj.style.cssText = "position:absolute;left:-100px;top:-100px";
        frmobj.target = "_blank";
        frmobj.action = "mReportSearch.asp";
        frmobj.method = "post"
        frmobj.innerHTML = "<input type='hidde' name='__msgId' value='showAdvWindow'>"
                         + "<input type='hidde' name='attr' id='advfrm_attr'>"
                         + "<input type='hidde' name='tit' id='advfrm_tit'>"
                         + "<input type='hidde' name='id' id='advfrm_id'>"
                         + "<input type='hidde' name='lvw_id' id='advfrm_lvw_id'>"
                         + "<input type='hidde' name='lvw_data' id='advfrm_lvw_data'>"
						 + "<input type='hidde' name='date1_id' id='date1_id'>"
                         + "<input type='hidde' name='date2_id' id='date2_id'>";
        document.body.appendChild(frmobj);
    }
    var tbox = document.getElementById("crd_" + id + "_tit")
    var divs = tbox.parentNode.parentNode.getElementsByTagName("div");
    var lvw = null;
    for (var i = 0; i < divs.length; i++) 
    {
        if (divs[i].className == "listview") {
            lvw = divs[i];
            break;
        }
    }
    var lvwId = lvw.id.replace("lvw_", "")
    var vstate = document.getElementById("__viewstate_lvw_" + lvwId)
    if (!vstate) { alert("无法获取列表的状态数据"); return }
	var data = tbox.getAttribute("tag");
	document.getElementById("advfrm_attr").value = data;
	var tboxText = tbox.innerText || tbox.textContent;
	document.getElementById("advfrm_tit").value = tboxText.replace(/\s/g, "");
	document.getElementById("advfrm_id").value = id;
	document.getElementById("advfrm_lvw_id").value = lvwId;
	ajax.regEvent("delUrl")
	ajax.addParam2("v",vstate.value)
	document.getElementById("advfrm_lvw_data").value = ajax.send();
	document.getElementById("date1_id").value = document.getElementById("crd_" + id + "_s_t1").value
	document.getElementById("date2_id").value = document.getElementById("crd_" + id + "_s_t2").value
    frmobj.submit();
}

function body_onreisze() {
	var divs = document.getElementsByTagName("div")
	for (var i = 0; i < divs.length ; i ++ )
	{
		var obj =  divs[i];
		if(obj.className == "controlpanelbody") {
			try{
				obj.style.width = (document.body.offsetWidth - 265) + "px";
		    }
			catch(e){}
			if (app.IeVer > 5) {  //IE6遮不住。所以不能出滚动条
		        var divs = obj.getElementsByTagName("div");
		        for (var ii = 0; ii < divs.length; ii++) {
		            if (divs[ii].name == "lvw_tablebgs") {
		                var id = divs[ii].id.replace("lvw_tablebg_", "");
		                __tvwcolresize(divs[ii], id);
		            }
		        }
		    }
		}
	}
}

window.addtipText = function () {
}
//if (app.IeVer <= 8) {
    window.oncardloadComplete = function (id) {
        window.setTimeout("body_onreisze();", 1000);
		setTimeout("window.addtipText();", 1000);
    }
    window.onsTabClick = function () {
        window.setTimeout("body_onreisze();", 10);
        setTimeout("window.addtipText()", 1000);
    }
    window.oncarditemrefresh = function() {
        body_onreisze();
        setTimeout("window.addtipText()", 1000);
    }
    window.onlistviewRefresh = function () {
        body_onreisze();
}
	window.onresize = function () {
		body_onreisze();
	}
//}

function __carditemSet(id) {
	if(id=="c_driverlist_item5")
	{	
		var formula=getformula();
		html = "<table id=content border=0 cellSpacing=1 cellPadding=6 align=center>"
			+"<tr><td align=center width=100%><input type=radio name=hsfs id=hsfs1 value=1"
		if (formula == 1 || (formula != 2 && formula!=3))
		{
			html=html+" checked ";
		}	
		html=html+">公式1: (利润=回款总额-费用金额-采购总额) (利润率=利润/回款总额)</td></tr>"
			+"<tr><td align=center width=100%><input type=radio name=hsfs id=hsfs2 value=2";
		if (formula==2)
		{
			html=html+" checked ";
		}	
		html = html + ">公式2: (利润=销售总额-费用金额-采购总额) (利润率=利润/销售总额)</td></tr>"
            + "<tr><td align=center width=100%><input type=radio name=hsfs id=hsfs3 value=3";
		if (formula == 3)
		{
		    html = html + " checked ";
		}
		html = html + ">公式3: (利润=销售总额-费用总额-成本总额) (利润率=利润/销售总额)<br/>注：销售总额 = 销售出库总额 - 销售退货总额<br/>成本总额 = 销售出库成本 - 销售退货入库成本</td></tr>"
			+"<tr><td align=center width=100%><input class=button  type=button value=确定 onclick=saveformula()>&nbsp;&nbsp;&nbsp;&nbsp;<input class=button  type=button value=取消 onclick=app.closeWindow('hsgs')></td></tr></table>"
		app.createWindow("hsgs", "核算利润公式设置", "").innerHTML= html;
	}
	else
	{
	window.location.href = "homeseting/index.asp?index=5";
	}
	return;
	//var div = document.getElementById(id);
	//var key = div.getAttribute("key");
	//var div = app.createWindow("id_hmsearch_dlg",key + " - 高级检索","","","","460","300",2,1,"")
}
function getformula(){
	ajax.regEvent("getformula");
	return ajax.send();
}
function saveformula(){
    var fs = document.getElementById("hsfs2").checked ? 2 : document.getElementById("hsfs3").checked ? 3 : 1;
	ajax.regEvent("saveformula");
	ajax.addParam("fs",fs);
	ajax.send(function(r){
		if (r==1)
		{
			window.location.reload();
			//alert("保存成功!");
		}
	    else{
			alert(r);
		}	
		app.closeWindow("hsgs");
	});
}
//显示人员的部门小组信息
function showGateInfo(gateid, nm) {
	var y = window.event.clientY;
	y = y + document.documentElement.scrollTop;
	var dv = app.createWindow("id_gtsch_dlg", nm, "", window.event.clientX + 10, y - 24, "360", "180", 2, "");
	ajax.regEvent("getGateInfo");
	ajax.addParam("ord",gateid);
	ajax.send(function(r){
	    dv.innerHTML = r;
	});
}
//获取报表的id号，从而去做无刷新
function getcurrCardItemId(obj) {
    var r;
    var i = 0;
    while (obj.parentNode) {
        i++;
        obj = obj.parentNode;
        if (obj.className == "listview") {
            r = obj.id;
            break;
        }
    }
    //var r = obj.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.id;
    return r.replace("lvw_","");
}

//重写全屏函数,使其调用高级检索
function __onlvwshowfull(eventFrm, id) {
    var obj = document.getElementById("lvw_" + id); //获取listview对象
    var obj = obj.parentNode.parentNode.parentNode;
    var buttons = obj.getElementsByTagName("button");
    for (var i = 0; i < buttons.length; i++) {
		var btnText = buttons[i].innerText || buttons[i].textContent;
        if (btnText == "高级") {
            buttons[i].click();
            return false;
        }
    }
    return false; //return false会屏蔽自带的全屏功能
}

//根据某个子元素，跳转到高级页面
function showAdvPage(childobj)
{
	event.cancelBubble = true;
	while (childobj.parentElement)
	{
		if (childobj.tagName == "DIV" && childobj.className=="ctlcarditem")
		{
			var buttons = childobj.getElementsByTagName("button");
			for (var i = 0; i < buttons.length; i++) {
				var btnText = buttons[i].innerText || buttons[i].textContent;
				if (btnText == "高级") {
					buttons[i].click();
					return false;
				}
			}
			
			return false;
		}
		childobj = childobj.parentElement
	}
	return false;
}



//判断是否可以拖拽
window.canCardviewItemDragEnd = function (srcElement, newElement) {
    if (srcElement == newElement) {
        return false;
    }
    else {
        var colspan1 = srcElement.getAttribute("colspan")
        var colspan2 = newElement.getAttribute("colspan")
        var pos1 = srcElement.getAttribute("tag3")
        var pos2 = newElement.getAttribute("tag3")

        if (colspan1 == "3" && pos2 == "right") { //左侧大栏目不能往右侧移动
            return false;
        }
        return true;
    }
}
//拖拽结束处理代码
window.onCardviewItemDragEnd = function (srcElement, newElement) {
    ajax.regEvent("onCardDrag")
    ajax.addParam("id1", srcElement.getAttribute("tag2"))
    ajax.addParam("id2", newElement.getAttribute("tag2"))
    ajax.addParam("isLast", newElement.getAttribute("isLast") == 1 ? 1 : 0);
    ajax.addParam("pos", newElement.getAttribute("tag3")) //新位置是左边还是右边
    var dds = document.getElementsByTagName("dd");
    ajax.send();
    //__stabRefresh("tb1");
    window.location.reload();
}


window.setTimeout("body_onreisze();", 10);

document.onmousedown = datedlg.autohide; //隐藏日期组件
function out(){
 app.closeWindow("id_gtsch_dlg")
}

//显示供应商与产品价格信息
function showSupplierList(ProductId) {
    var y = window.event.clientY;
    var x = window.event.clientX;
    x = x + document.documentElement.scrollLeft;
    y = y + document.documentElement.scrollTop;
    var dv = app.createWindow("id_supplierlist_dlg", "供应商产品价格详情", "", x - 545, y - 15, "540", "290", 2, 0, "","relative");
    ajax.regEvent("GetSupplierPriceList", "main.asp?sord=" + ProductId);
    ajax.addParam("pid", ProductId);
    ajax.send(function (r) {
        dv.innerHTML = r;
    });
}

window.old__stabClick = __stabClick;
function __stabClick(tbid, currobj, index) {
   window.location.href = "main.asp?index=" + index;
}
//('tb1',this,1)


document.onmouseover = function(){
	var obj = window.event.srcElement;
	if(obj.tagName == "A" && (obj.className=="rptlink" || obj.className=="power" || obj.className=="remind_detail_link") && obj.innerHTML.length>5)
	{
		var div = document.getElementById("tooltip");
		var x =  window.event.clientX ;
		var y =  window.event.clientY+document.documentElement.scrollTop ;
		if(!div){
			div = document.createElement("div");
			div.id = "tooltip"
			document.body.appendChild(div);
		}
		div.innerHTML = obj.innerHTML;
		div.style.cssText = "left:" + x + "px;top:" + y +  "px;display:block"
	}	
}
document.onmouseout = function(){
	var obj = window.event.srcElement;
	if(obj.tagName == "A" && (obj.className=="rptlink" || obj.className=="power" || obj.className=="remind_detail_link"))
	{
		var div = document.getElementById("tooltip");
		if(div){
			div.style.display = "none";
		}
	}	
}

var RemObj = {
	wList:[],
	getNewWinPos:function(winName){
		if(this.wList.length==0){
			var o = {name:winName,left:100,top:100}
			this.wList.push(o);
			return o;
		}

		for (var i=0;i<this.wList.length ;i++ ){
			if(this.wList[i].name==winName){
				return this.wList[i];
			}
		}
		
		var w = {name:winName,left:this.wList[this.wList.length-1].left+20,top:this.wList[this.wList.length-1].top+20}
		this.wList.push(w);
		return w;
	},
	openWin:function(url,winName){
		var pos = this.getNewWinPos(winName);
		var winStyle = 'width=900,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left='+(pos.left)+',top='+(pos.top)
		window.open(url,pos.name,winStyle);
	},
	cancel:function(oid,rid,cfgId,subId){
		if (!confirm('确定要取消该提醒吗？')){
			return;
		}
		var remObj = this;
		var img = event.srcElement;
		jQuery.ajax({
			url:'../inc/ReminderCall.asp?act=cancel',
			data:{oid:oid,rid:rid,cfgId:cfgId,subId:subId},
			cache:false,
			success:function(html){
				if (html.length>0){
					alert(html);
					return;
				}
				remObj.reLoad(img);
			},
			error:function(rep){
				alert(rep.responseText);
			}
		});
	},
	reLoad:function(obj){
		jQuery(obj).parentsUntil('.ctlcarditem').last().parent().find('.ctlcarditembtn2').click();
	}
}
