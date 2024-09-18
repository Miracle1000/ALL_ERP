var hwndcq;

if(window.Tabs){
	Tabs.ItemClick = function(index,id){
		var r = eval("Tabs." + id +  "_ItemClick ? Tabs." + id +  "_ItemClick(" + index + ") : true")
		if( r!=true ){ return }
		if(id == "topMenu"){
			ck.toSpPageBySpType(index,document.getElementById("orderid").value)
		}
		else{
			//if(id=="spdlgTabs"){
				var dFrame = document.getElementById("SPDlgTab").cells
				dFrame[index].style.display = "";
				dFrame[1-index].style.display = "none";
			//}
		}
	}
}

var ck = new Object()

ck.toSpPageBySpType = function(index,oid){
		var keytxt = "";
		if(document.getElementById("UserKeyText")) {
			keytxt = document.getElementById("UserKeyText").value;
			keytxt = keytxt.replace(/(^\s*)|(\s*$)/g, "");
		}
		var url = ajax.url;
		ajax.url = window.location.href;
		ajax.regEvent("");
		ajax.addParam("sType",index);
		ajax.addParam("orderid",oid);
		ajax.addParam("UserKeyText", keytxt);
		if(document.getElementById("spmain_pindex")){
			ajax.addParam("lvw_PageIndex",document.getElementById("spmain_pindex").value)
			ajax.addParam("lvw_PageSize",document.getElementById("spmain_psize").value)
		}
		var khObj = document.getElementById("kh");
		if (khObj)
		{
			if(khObj.style.display=="none")
			{
				ajax.addParam("GJ_Search", 2);
				var adbox = document.getElementById("searchitemspanel")
				if(adbox) //存在高级检索
				{
					var tds = adbox.getElementsByTagName("td")
					for (var i = 0 ; i < tds.length ; i ++ )
					{
						var ibox = tds[i];
						if(ibox.className=="asearchdatatd") 
						{
							var id =  ibox.id.replace("sfields_","");
							if(id.length > 0)
							{
								var v1 = getAFieldValue(ibox);
								if(v1.indexOf("'")>=0){ 
									alert("请不要使用特殊字符检索!");
									return false;
								}
								ajax.addParam(id, v1);
							}
						}
					}
				}
				khObj.style.display="";
				try{
					document.getElementById("as_ing").value=0;
					document.getElementById("searchitemsbutton").style.display="block";
					document.getElementById("searchitemspanel").style.display="none";
				}catch(e){}		
			}
			else
			{
				var box = khObj.children[0].children[0].children[0];
				ajax.addParam("GJ_Search", 1);
				for (var i = 0 ; i < box.children.length ; i ++ )
				{
					var ibox = box.children[i];
					if(ibox.tagName=="SPAN" && ibox.id.indexOf("sfields_")==0) 
					{
						if (ibox.id.indexOf("_date_")>0)
						{
							var id = ibox.id.replace("sfields_date_","");
							ajax.addParam(id, getFieldValue(ibox,id+"_1",0)+"\1"+getFieldValue(ibox,id+"_2",0));
						}
						else if (ibox.id.indexOf("_textlist_")>0)
						{
							var id = ibox.id.replace("sfields_textlist_","");
							var v2 = getFieldValue(ibox,id+"_v",0);
							if(v2.indexOf("'")>=0){ 
								alert("请不要使用特殊字符检索!");
								return false;
							}
							ajax.addParam(getFieldValue(ibox,id,0), v2);
						}
						else
						{
							var id =  ibox.id.replace("sfields_","");
							ajax.addParam(id, getFieldValue(ibox,id,0));
						}
					}
				}
			}
		}
		r = ajax.send()
		var sIndex = r.indexOf("<!--审批主表格-->")
		var eIndex = r.indexOf("<!--主表格结束-->")
		if(eIndex<0 || sIndex < 0){
			var div = window.DivOpen("spgeterr","获取数据失败",500,320,50,120);
			var mdiv = document.createElement("div")
			mdiv.innerHTML = r;
			div.innerHTML  ="<span class=c_r style='margin:4px'>" + mdiv.innerText.replace(/。/g,"<br>").replace(/\n/g,"<br>") + "</span>";
			return false;
		}
		var signLen = "<!--主表格结束-->".length;
		r = r.substring(sIndex+signLen , eIndex)
		var cPan = document.getElementById("billbody")
		cPan.innerHTML = r;
		var script = cPan.getElementsByTagName("script")
		for(var i=0;i<script.length;i++){
			window.eval("(function(){" + script[i].innerHTML + "})()");
		}
		lvw.UpdateAllScroll()
		ajax.url = url;
		lvw.oncallback(); 
}

ck.ShowSpdlg = function(OrId,BlId,spid,logId,creator) //显示审批界面
{
		var spHeight=400;
		var spWidth=640;
		if (OrId==1034){spHeight=500;spWidth=740;}
		var div = window.DivOpen("sphand","审批处理",640,spHeight,'a','a',true,18)
		ajax.regEvent("CreateSpDailog");	//创建对话框
		ajax.addParam("orderid",OrId);
		ajax.addParam("billid",BlId);
		ajax.addParam("spid",spid);
		ajax.addParam("logId",logId);
		div.innerHTML = ajax.send();
		lvw.UpdateAllScroll();
		var spResults = document.getElementsByName("spResult");
		var spResult = 0;
		for (var i=0;i< spResults.length; i++ )
		{
			if(spResults[i].checked){
				spResult = spResults[i].value;
				break;
			}
		}
		ck.spResultChange(spResult,creator);  //默认审批状态
}

ck.ShowZpdlg = function(OrId,BlId) //显示指派界面
{
	var idlist = new Array
	var id_c = 0
	var tb = document.getElementById("listview_spmain").children[0]
	for(var i = 0 ; i< tb.rows[0].cells.length;i++){
		if(tb.rows[0].cells[i].oywname=="ID"){
			id_c = i
			break
		}
	}
	if(id_c>0){
		for(var i = 1 ; i< tb.rows.length;i++){
			var row = tb.rows[i]
			var cks = row.cells[0].getElementsByTagName("input")
			if(cks.length > 0 && cks[0].checked==true){
				idlist[idlist.length] = row.cells[id_c].innerText + "#t*d#" +  row.cells[id_c+1].innerText
			}
		}
	}
	if(idlist.length>0){
		var spHeight=150;
		var spWidth=240;
		var div = window.DivOpen("sphand","客户批量指派",spWidth,spHeight,'a','a',true,18)
		ajax.regEvent("CreateZpDailog");	//创建对话框
		ajax.addParam("orderid",OrId);
		ajax.addParam("billid",BlId);
		div.innerHTML = ajax.send();
		lvw.UpdateAllScroll();
	}
	else{
		window.alert("请选择您要指派的单据");
	}
}

ck.cancelRemind = function(cfgId){
	if (!confirm('确定要取消提醒吗？')) return;
	var ids = [];
	var idIdx = 0;
	var tb = document.getElementById("listview_spmain").children[0]
	for(var i = 0 ; i< tb.rows[0].cells.length;i++){
		if(tb.rows[0].cells[i].oywname=="ID"){
			idIdx = i;
			break;
		}
	}

	if(idIdx>0){
		for(var i = 1 ; i< tb.rows.length;i++){
			var row = tb.rows[i]
			var cks = row.cells[0].getElementsByTagName("input")
			if(cks.length > 0 && cks[0].checked==true){
				ids.push(row.cells[idIdx].innerText);
			}
		}
	}else{
		alert("由于没有ID字段，无法进行批量操作");
		return;
	}

	if (ids.length==0){
		alert("请选择您要取消提醒的单据");
		return;
	}

	jQuery.ajax({
		url:'../../inc/ReminderCall.asp?act=cancelByOid',
		data:{oid:ids.join(','),cfgId:cfgId},
		cache:false,
		success:function(r){
			if (r.length>0){
				var div = window.DivOpen("hdgsd","取消操作结果",400,100,'a','b',20)
				jQuery(div).empty().css({overflowY:'auto',overflowX:'auto'});
				var json = eval('('+r+')');
				for (var i=0;i<json.length ;i++ ){
					jQuery("<li style='color:#6666aa" + (i%2==0?";background-color:white":";background-color:#f5f5f5") + "'>"+
						"【" + json[i].name + '】提醒'+(json[i].success?'已被取消':'无法取消，原因是：待审批提醒不能取消')+
						"</li>").appendTo(div);
				}
			}
			ck.currRefresh();
		},
		error:function(rep){
			var $div = jQuery('<div style="position:absolute;left:0px;top:0px;width:50%;height:50%;z-index:9999" ondblclick="jQuery(this).remove();"></div>');
			$div.html(rep.responseText).appendTo(document.body);
		}
	});
}

ck.SpShowList = function(OrId,BlId,logId,wName) { //审批页面调用明细
    var t = new Date()
	var opener = window.PageOpen("Readbill.asp?orderid=" + OrId + "&ID=" + BlId + "&SplogId=" + logId + "&vTime=" + t.getTime(),1100,600,wName);
}
//调用修改
ck.ShowEdit = function(OrId,BlId,logId,wName) { 
	var t = new Date()
	var opener = window.PageOpen("Bill.asp?orderid=" + OrId + "&ID=" + BlId + "&SplogId=" + logId + "&vTime=" + t.getTime(),1100,600,wName);
}
//调用删除
ck.DelID = function(OrId,BlId,logId,wName) { 
var idlist = new Array
	var id_c = 0
	var tb = document.getElementById("listview_spmain").children[0]
	for(var i = 0 ; i< tb.rows[0].cells.length;i++){
		if(tb.rows[0].cells[i].oywname=="ID"){
			id_c = i
			break
		}
	}
	if(id_c>0){
		for(var i = 1 ; i< tb.rows.length;i++){
			var row = tb.rows[i]
			var cks = row.cells[0].getElementsByTagName("input")
			if(cks.length > 0 && row.cells[id_c].innerText==BlId){
				idlist[idlist.length] = row.cells[id_c].innerText + "#t*d#" +  row.cells[id_c+1].innerText
			}
		}
	}

		if(window.confirm("您确定要删除该单据吗？" )){
			ajax.regEvent("deleteBillList");
			ajax.addParam("billlist",idlist.join("#t*r#"));
			ajax.addParam("oid",document.getElementById("orderid").value);
			var r = ajax.send();
			var div = window.DivOpen("hdgsd","删除结果",400,100,'a','b',20)
			div.innerHTML = "<div style='width:620px;height:382px;overflow:auto;'><ul style='line-height:23px'>"  +  r  + "</ul></div>"
			div.setCloseEvent(
				function (){
					ck.currRefresh();
				}	
			)
		}
}
ck.hiddenItemButton = function(){	//隐藏
	return false;
	var tb = document.getElementById("TabCtl_topMenu")
	for (var i=1; i < tb.rows[0].cells.length-1 ; i ++ )
	{
		tb.rows[0].cells[i].style.display = ""
	}
}

ck.spResultChange = function(rStatus,creator)
{
	var bkRow = document.getElementById("backtoselect").parentElement.parentElement;
	var nmRow = document.getElementById("nextspman").parentElement.parentElement
	switch(rStatus){
		case 1:		//通过
			bkRow.style.visibility  = "hidden";
			nmRow.style.visibility  = "visible" 
			break;
		case 2:		//退回
			bkRow.style.visibility  = "visible";
			nmRow.style.visibility  = "visible" 
			break;
		case 3:		//终止
			bkRow.style.visibility  = "hidden";
			nmRow.style.visibility  = "hidden" 
			break;
	}
	ck.updateNextSpManList(creator);
	if (rStatus==2)
	{
		if(document.getElementById("backtoselect").selectedIndex==0){
			document.getElementById("xxnextsplistrow").style.visibility = "hidden"
		}
		else{
			document.getElementById("xxnextsplistrow").style.visibility = "visible"
		}
	}
}

ck.updateNextSpManList = function(creator){ //更新下一审批人选择框
	if(creator){ck.currspcreator = creator;}
	else{
		if(ck.currspcreator){
			creator = ck.currspcreator
		}
	}
	if(!creator) {creator=0} 
	var spResults = document.getElementsByName("spResult");
	var spResult = 0;
	for (var i=0;i< spResults.length; i++ )
	{
		if(spResults[i].checked){
			spResult = spResults[i].value;
			break;
		}
	}
	var ax = new xmlHttp()
	ax.url = "check.asp"
	ax.regEvent("GetNextSpMan");
	ax.addParam("spResult",spResult);
	ax.addParam("rank",document.getElementById("backtoselect").value);
	ax.addParam("sign",document.getElementById("SPDlgTab").getAttribute("sign"));
	ax.addParam("spid",document.getElementById("SPDlgTab").getAttribute("spid"));
	ax.addParam("creator",creator);
	var r = ax.send();
	ax = null
	var lb = document.getElementById("nextspmanlb")
	var opt = document.getElementById("nextspman")
	if(r.length==0){ //没有审批人可供选择
		opt.style.display = "none"
		lb.style.display = "";
		lb.innerText = "您目前有权限完成该单的所有审批流程。"
	}
	else{
		lb.style.display = "none";
		opt.style.display = ""
		var mlist = r.split("|");
		for (var i=0;i<mlist.length ;i++)
		{mlist[i] = mlist[i].split("=");}
		//从select中删除不存在的。
		for (var i=opt.options.length-1; i>=0;i--)
		{
			var hs = false;
			var item = opt.options[i].value;
			for (var ii=1;ii<mlist.length;ii++)
			{
				if(mlist[ii][0]==item){
					hs = true;
					ii=mlist.length;
				}
			}
			if(!hs){
				opt.options.remove(i);
			}
		}
		//从清单中添加selectbox中不存在的
		for (var i = 1; i < mlist.length ; i ++ )
		{
			var hs = false;
			var item = mlist[i]
			for (var ii=0;ii< opt.options.length ; ii++)
			{
				if(opt.options[ii].value==item[0]){
					hs = true;
					ii = opt.options.length;
				}
			}
			if(!hs){
				var oOption = document.createElement("OPTION");
				opt.options.add(oOption);
				oOption.innerText = item[1].length==0  ?  '用户[' + item[0] + ']' : item[1];
				oOption.value = item[0];

			}
		}


	}
}

ck.savebutton_click = function(bn){ //保存按钮点击事件
	var r = ck.save()
	window.DivClose(bn);
	document.body.style.overflow=""
}

ck.savezp_click = function(bn){ //保存按钮点击事件
	var r = ck.appointalllist()
	window.DivClose(bn);
	document.body.style.overflow=""
}

ck.delbutton_click = function(bn){
	var r = ck.del()
	window.DivClose(bn);
	document.body.style.overflow=""
}

ck.del = function(){
	var url = ajax.url
	var dlg = document.getElementById("SPDlgTab");
	ajax.url = "../../Manufacture/inc/checkpage.asp"
	ajax.regEvent("SpDelete");
	ajax.addParam("logid",document.getElementById("SPDlgTab").logid);
	ajax.exec();
	ck.currRefresh();
	ajax.url = url;
}

ck.currRefresh = function(timeout){ //刷新当前页
	if (timeout && timeout>0)
	{
		setTimeout(function(){
			//通过定时器延缓刷新，防止卡住调用者所在线程。
			if(document.getElementById("spmain_pindex")){ lvw.toPage(document.getElementById("spmain_pindex")); }
		}, timeout)
	}
	else{
		if(document.getElementById("spmain_pindex")){ lvw.toPage(document.getElementById("spmain_pindex")); }
	}
	return;
}

ck.save = function(){
	var spResults = document.getElementsByName("spResult");
	var spResult = 0;
	var dlg = document.getElementById("SPDlgTab");
	for (var i=0;i< spResults.length; i++ )
	{
		if(spResults[i].checked){
			spResult = spResults[i].value;
			break;
		}
	}
	ajax.url = "check.asp"
	ajax.regEvent("SpSave");
	ajax.addParam("currSpId",dlg.getAttribute("spid"));      //当前处理的审批流程编号
	ajax.addParam("billid",dlg.getAttribute("billid"));		 //单据单号
	ajax.addParam("orderid",dlg.getAttribute("orderid"));	 //单据类型号
	ajax.addParam("sign",dlg.getAttribute("sign"));			 //单据标识符
	ajax.addParam("logid",document.getElementById("SPDlgTab").getAttribute("logid"));
	ajax.addParam("backRank",document.getElementById("backtoselect").value); //回调到流程
	ajax.addParam("result",spResult);		//审批结果
	ajax.addParam("nextsp",document.getElementById("nextspman").value); //下一位审批人
	ajax.addParam("remarks",document.getElementById("remarks").value); //审批意见
if(document.getElementById("content"))
{
	ajax.addParam("content",document.getElementById("content").value); //审批内容(by:snihaps,人资面试内容)
}
	ajax.exec();
	ck.currRefresh();
	ajax.url =  ajax.defUrl();
}

ck.doSearch = function(keyBox){
	var index = 0;
	var boxs = document.getElementsByName("rado");
	for (var i = 0 ; i < boxs.length ; i ++)
	{
		if(boxs[i].checked) {
			index = i;
			break;
		}
	}
	if(document.getElementById("spmain_pindex")) {
		document.getElementById("spmain_pindex").value = 1;
	}
	ck.toSpPageBySpType(index,document.getElementById("orderid").value);
}
ck.addnew = function(orderid){
	var dlg = document.getElementById("SPDlgTab");
	window.location.href="Bill.asp?orderid="+orderid +"";
}
ck.deletealllist = function(){
	var idlist = new Array
	var id_c = 0
	var tb = document.getElementById("listview_spmain").children[0]
	for(var i = 0 ; i< tb.rows[0].cells.length;i++){
		var cell = tb.rows[0].cells[i];
		if(cell && cell.oywname && cell.oywname.toLowerCase()=="id"){
			id_c = i
			break
		}
	}
	if(id_c>0){
		for(var i = 1 ; i< tb.rows.length;i++){
			var row = tb.rows[i]
			var cks = row.cells[0].getElementsByTagName("input")
			if(cks.length > 0 && cks[0].checked==true){
				idlist[idlist.length] = row.cells[id_c].innerText + "#t*d#" +  row.cells[id_c+1].innerText
			}
		}
	}
	if(idlist.length>0){
		if(window.confirm("您确定要批量删除勾选中的单据吗？" )){
			ajax.regEvent("deleteBillList")
			ajax.addParam("billlist",idlist.join("#t*r#"))
			ajax.addParam("oid",document.getElementById("orderid").value)
			var r = ajax.send()
			var div = window.DivOpen("hdgsd","批量删除结果",650,440,'a','b',20)
			div.innerHTML = "<div style='width:620px;height:382px;overflow:auto;'><ul style='line-height:23px'>"  +  r  + "</ul></div>"
			div.setCloseEvent(
				function (){
					ck.currRefresh();
				}	
			)
		}
	} else {
		window.confirm("您没有选择任何内容，请选择后再操作！"); return;
    }

}
ck.appointalllist = function(){
	var idlist = new Array
	var id_c = 0
	var tb = document.getElementById("listview_spmain").children[0]
	for(var i = 0 ; i< tb.rows[0].cells.length;i++){
		if(tb.rows[0].cells[i].oywname=="ID"){
			id_c = i
			break
		}
	}
	if(id_c>0){
		for(var i = 1 ; i< tb.rows.length;i++){
			var row = tb.rows[i]
			var cks = row.cells[0].getElementsByTagName("input")
			if(cks.length > 0 && cks[0].checked==true){
				idlist[idlist.length] = row.cells[id_c].innerText + "#t*d#" +  row.cells[id_c+1].innerText
			}
		}
	}
	if(idlist.length>0){
		ajax.regEvent("appointBillList")
		ajax.addParam("billlist",idlist.join("#t*r#"))
		ajax.addParam("oid",document.getElementById("orderid").value)
		ajax.addParam("zpPerson",document.getElementById("zpPerson").value)
		var r = ajax.send()
		var div = window.DivOpen("hdgsd","批量指派结果",650,440,'a','b',20)
		div.innerHTML = "<div style='width:620px;height:382px;overflow:auto;'><ul style='line-height:23px'>"  +  r  + "</ul></div>"
		div.setCloseEvent(
			function (){
				ck.currRefresh();
			}	
		)
	}

}


lvw.oncallback = function (div) {  //加载下级单据
    var id = new Array();
    var cs = new Array();
    var ctds = new Array();
    var divs = document.getElementsByTagName("div");
    for (var i = 0; i < divs.length; i++) {
        //如果有关联下级单据列，异步显示获取该列信息，并且判断审批按钮是否应该显示
        if (divs[i].className == "nextbill") {
            var x = id.length;
            id[x] = divs[i].getAttribute("bid");
            cs[x] = divs[i];
        }
    }
    if (cs.length == 0) {
        //没有关联下级单据列，这只判断是否显示审批按钮
		if (document.getElementById("listview_spmain"))
		{
			var cells = document.getElementById("listview_spmain").getElementsByTagName("span");
			for (var i = 0; i < cells.length; i++) {
				if (cells[i].className == "link splink") {
					x = id.length;
					id[x] = cells[i].getAttribute("bid");
					cs[x] = cells[i];
				}
			}
		}
    }
    if (id.length > 0) {
        ajax.regEvent("getnextbilllist");
        ajax.addParam("bid", id.join(","));
        ajax.addParam("oid", document.getElementById("orderid").value);
        ajax.send(
			function (r) {
			    var r = r.split("\2")
			    for (var i = 0; i < cs.length; i++) {
			        if (r[i].length > 0) {
			            var dat = r[i].split("\3");   //data结构: oid,bid,title,bname , PowerID,Creator, canOpen , del
			            if (dat.length > 0) {
			                var items = dat[0].split("\1");
			                if (cs[i].tagName == "SPAN") {
			                    //只作审批按钮是否显示判断
			                    var p = cs[i].parentNode;
			                    p.innerHTML = p.innerHTML.replace(cs[i].outerHTML + "&nbsp;", "")
			                }
			                else {
			                    //显示下级单据，审批按钮是否显示判断
			                    cs[i].innerHTML = items[3].replace("生产", "") + ":" + items[2] + "&nbsp;<span class='link' style='color:red;' onclick='showChildBill(" + document.getElementById("orderid").value + "," + id[i] + ")'>详情(" + (dat.length - 1) + ")</span>"
			                    var p = window.getParent(cs[i], 6);
			                    var lk = p.getElementsByTagName("span");  //有子单据不显示改批按钮
			                    for (var ii = 0; ii < lk.length; ii++) {
			                        if (lk[ii].className == "link splink" && lk[ii].title == "修改审批记录") {
			                            var p = lk[ii].parentNode;
			                            p.innerHTML = p.innerHTML.replace(lk[ii].outerHTML + "&nbsp;", "")
			                        }
			                    }
			                }
			            }
			        }
			        else {
			            if (cs[i].tagName == "SPAN") {
			                cs[i].innerHTML = "改批";
                        }
                        else{
                            //只作审批按钮是否显示判断
			                cs[i].innerHTML = r[i];  //没有子单据不显示改批按钮
			                var p = window.getParent(cs[i], 6);
			                var lk = p.getElementsByTagName("span");
			                for (var ii = 0; ii < lk.length; ii++) {
			                    if (lk[ii].className == "link splink" && lk[ii].title == "修改审批记录") {
			                        lk[ii].innerHTML = "改批";
			                    }
			                } 
			            }
			        }
			    }
			}
		)
    }
}

function showChildBill(oid,bid)
{
	var div = window.DivOpen("jsdifhsfa","子单集合","800","570",'30',"b",1,20,'assa',1)
    div.innerHTML = "<iframe style='width:100%;height:100%' frameborder=0 src='../../manufacture/inc/billpage.asp?__msgId=getChildBillTree&oid=" + oid + "&bid=" + bid + "'></iframe>"
}

function resetClick()
{
	var tagname=document.getElementsByTagName("input");
	for(var i=0;i<tagname.length;i++){
		tagname[i].value=tagname[i].defaultValue;
	}
}

function searchClick()
{
	var index = 0;
	var topMenu = $("input[name=rado]:checked");
	if (topMenu.length>0)
	{
		index = topMenu[0].value;
	}
	var url = ajax.url;
	ajax.url = window.location.href;
	ajax.regEvent("");
	ajax.addParam("sType",index);
	ajax.addParam("orderid",document.getElementById("orderid").value)
	if(document.getElementById("spmain_pindex")){
		ajax.addParam("lvw_PageIndex",document.getElementById("spmain_pindex").value)
		ajax.addParam("lvw_PageSize",document.getElementById("spmain_psize").value)
	}
	var khObj = document.getElementById("kh");
	if(khObj && khObj.style.display=="none")
	{
		ajax.addParam("GJ_Search", 2);
		var adbox = document.getElementById("searchitemspanel")
		if(adbox) //存在高级检索
		{
			var tds = adbox.getElementsByTagName("td")
			for (var i = 0 ; i < tds.length ; i ++ )
			{
				var ibox = tds[i];
				if(ibox.className=="asearchdatatd") 
				{
					var id =  ibox.id.replace("sfields_","");
					if(id.length > 0)
					{	
						var v1 = getAFieldValue(ibox);
						if(v1.indexOf("'")>=0){ 
							alert("请不要使用特殊字符检索!");
							return false;
						}
						ajax.addParam(id, v1);
					}
				}
			}
		}
		khObj.style.display="";
		try{
			document.getElementById("as_ing").value=0;
			document.getElementById("searchitemsbutton").style.display="block";
			document.getElementById("searchitemspanel").style.display="none";
		}catch(e){}		
	}
	else
	{
		var box = khObj.children[0].children[0].children[0];
		ajax.addParam("GJ_Search", 1);
		for (var i = 0 ; i < box.children.length ; i ++ )
		{
			var ibox = box.children[i];
			if(ibox.tagName=="SPAN" && ibox.id.indexOf("sfields_")==0) 
			{
				if (ibox.id.indexOf("_date_")>0)
				{
					var id = ibox.id.replace("sfields_date_","");
					ajax.addParam(id, getFieldValue(ibox,id+"_1",0)+"\1"+getFieldValue(ibox,id+"_2",0));
				}
				else if (ibox.id.indexOf("_textlist_")>0)
				{
					var id = ibox.id.replace("sfields_textlist_","");
					var v2 = getFieldValue(ibox,id+"_v",0);
					if(v2.indexOf("'")>=0){ 
						alert("请不要使用特殊字符检索!");
						return false;
					}
					ajax.addParam(getFieldValue(ibox,id,0), v2);	
				}
				else
				{
					var id =  ibox.id.replace("sfields_","");
					ajax.addParam(id, getFieldValue(ibox,id,0));
				}
			}
		}
	}
	r = ajax.send()
	var sIndex = r.indexOf("<!--审批主表格-->")
	var eIndex = r.indexOf("<!--主表格结束-->")
	if(eIndex<0 || sIndex < 0){
		var div = window.DivOpen("spgeterr","获取数据失败",500,320,50,120);
		var mdiv = document.createElement("div")
		mdiv.innerHTML = r;
		div.innerHTML  ="<span class=c_r style='margin:4px'>" + mdiv.innerText.replace(/。/g,"<br>").replace(/\n/g,"<br>") + "</span>";
		return false;
	}
	var signLen = "<!--主表格结束-->".length;
	r = r.substring(sIndex+signLen , eIndex)
	var cPan = document.getElementById("billbody")
	cPan.innerHTML = r ;//+  "<div class='blistbottomarea'></div>";
	var script = cPan.getElementsByTagName("script")
	for(var i=0;i<script.length;i++){
		window.eval("(function(){" + script[i].innerHTML + "})()");
	}
	lvw.UpdateAllScroll()
	ajax.url = url;
	lvw.oncallback(); 
}

//获取某个字段的值
function getFieldValue(ibox,id, K)
{
	if (K==0)
	{
		return document.getElementById(id).value;	
	}
	else if (K==1)
	{//checked //radio
		var s = document.getElementsByName(id);
		var v="";
		for (var i=0;i<s.length ;i++ )
		{
			if (s[i].checked==true )
			{
				if (v=="")
				{
					v = s[i].value; 
				}
				else
				{
					v = v + "," + s[i].value; 	
				}
			}
		}
		return v 
	}
	else
	{
		return "" ;
	}
}

//获取高级检索字段的值
function getAFieldValue(ibox)
{
	var t = ibox.getAttribute("ftype");
	switch(t)
	{
		case "text": return ibox.getElementsByTagName("input")[0].value;
		case "moneys": return ibox.getElementsByTagName("input")[0].value + "\1" + ibox.getElementsByTagName("input")[1].value;
		case "cpfl": return getcpflList(ibox);
		case "checks": return getchecks(ibox);
		case "gates": return getgates(ibox,"gates");
		case "gates2": return getgates(ibox,"gates2");
		case "gates3": return getgates(ibox,"gates3");
		case "gates4": return getgates(ibox,"gates4");
		case "gategroup": return getgates(ibox,"gategroup");
		case "gategroup2": return getgates(ibox,"gategroup2");
		case "gategroup3": return getgates(ibox,"gategroup3");
		case "gategroup4": return getgates(ibox,"gategroup4");
		case "dates": return ibox.getElementsByTagName("input")[0].value + "\1" + ibox.getElementsByTagName("input")[1].value;
		case "datetime": return ibox.getElementsByTagName("input")[0].value + "\1" + ibox.getElementsByTagName("input")[1].value;
		case "select": return ibox.getElementsByTagName("select")[0].value;
		case "sortonehy": return getchecks(ibox);
		case "telcls": return gettelcls(ibox);
		case "khqy" : return "@area=" + getchecks(ibox); //BUG.2558.Binary.2013.10.12 区域数据特殊处理
		default:
			 return window.confirm("高级检索getAFieldValue函数.未定义类型【" + t + "】");
	}
}

//人员选择清单
function getgates(ibox, gt) {
	var w1 = new Array();
	var w2 = new Array();
	var w3 = new Array();
	var boxs = ibox.getElementsByTagName("input")
	for (var i = 0; i<boxs.length ; i ++ )
	{
		var bx = boxs[i];
		if(bx.checked)
		{
			switch(bx.name.toLowerCase()) {
				case "w1": w1[w1.length] = bx.value; break;
 				case "w2": w2[w2.length] = bx.value; break;
				case "w3": w3[w3.length] = bx.value; break;
			}
		}
	}
	if (gt.indexOf("gategroup")==-1)
	{
		return "@sysgt=" + gt + "|" + w1.join(",") + "|" + w2.join(",") + "|" + w3.join(",");
	}
	else{
		return  w1.join(",") + "\1" + w2.join(",");
	}
}

//人员选择清单
function gettelcls(ibox) {
	var w1 = new Array();
	var w2 = new Array();
	var w3 = new Array();
	var boxs = ibox.getElementsByTagName("input")
	for (var i = 0; i<boxs.length ; i ++ )
	{
		var bx = boxs[i];
		if(bx.checked)
		{
			switch(bx.name.toLowerCase()) {
				case "e": w1[w1.length] = bx.value;
 				case "f": w2[w2.length] = bx.value;
			}
		}
	}
	return w1.join(",") + "\1" + w2.join(",");
}

//勾选框清单
function getchecks(ibox) {
	var s = new Array();
	var boxs = ibox.getElementsByTagName("input")
	for (var i = 0; i<boxs.length ; i ++ )
	{
		if(boxs[i].checked)
		{
			s[s.length] = boxs[i].value;
		}
	}
	return s.join(",");
}

//产品分类清单
function getcpflList(box)
{
	var s = new Array();
	var boxs = box.getElementsByTagName("input")
	for (var i = 0; i<boxs.length ; i ++ )
	{
		if(boxs[i].checked)
		{
			s[s.length] = boxs[i].value;
		}
	}
	return s.join(",");
}

function clearinput(obj,divid)
{if(!obj.checked)
{var divobj=$ID(divid);if(!divobj) {return}
var chkobj=divobj.getElementsByTagName("input");
for(var i=0;i<chkobj.length;i++)
{if(chkobj[i].type=="checkbox"&&chkobj[i].checked&&(chkobj[i].name=="W3"||chkobj[i].name=="W2"))
{if(chkobj[i].name=="W2"&&chkobj[i].checked)
{chkobj[i].click();}
else{chkobj[i].checked=false;}}}}}

function handleClick(url,setType,id)
{
	var oldurl = ajax.url;
	ajax.url =url;
	ajax.regEvent("");
	ajax.addParam("orderid",document.getElementById("orderid").value)
	ajax.addParam("setType",setType)
	ajax.addParam("id",id)
	ajax.send();
	ajax.url = oldurl;
	ck.currRefresh();
}

//取消提醒
function cancleAlt(id){
	if(confirm("确认取消提醒？")){
		var oid = document.getElementById("orderid").value;
		if(oid == "1019"){
			var oldurl = ajax.url;
			ajax.url ="setalt.asp";
			ajax.regEvent("");
			ajax.addParam("orderid",oid)
			ajax.addParam("id",id)
			ajax.send();
			ajax.url = oldurl;
			ck.currRefresh();
		}
	}
}

function onbodyclick() {
	var sbox = window.event.srcElement;
	if(sbox.tagName=="IMG") {
		//if(sbox.offsetWidth==50) { //bug.6561.2014-12-10.ljh.给所有图片都加上点击弹出窗口显示完整图片
			window.open(sbox.src,'neww678img','width=' + 1100 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')
		//}
	}
}

function loadBillPage(page){
	var defWidth = 200;	 var defHeight = 150; 
	var divClass = "td.billfieldright";
	try{
		$(divClass+" img").each(function (index, element) {
			var w  = $(this).width();	//实际宽度
			var h  = $(this).height(); //实际高度
			//缩放后的高度 =（默认宽度*实际高度）/ 实际宽度
			if(w > defWidth){
				var thumbH = (defWidth * h) / w;
				$(this).attr({ width: defWidth, height: thumbH });				
			}
			//缩放后的宽度 =（默认高度*实际宽度）/ 实际高度
			else if(h > defHeight){
				var thumbW = (defHeight * w) / h;	
				$(this).attr({ width: thumbW, height: defHeight });	
			}
			
				//缩放后的图片可点击，弹出窗口显示原图
				if(w > defWidth || h > defHeight){
					$(this).css({ margin: '5px', cursor: 'pointer' });	
					var url = $(this).attr("src");						
					$(this).click(function () {
					    var newPage = window.open("about:blank");//解决相对路径加密之后无法预览图片的问题
					    newPage.document.write("<img src='" + url + "'>");
					});
				}
			
		});
	
	}catch(e){
		
	}
}
//编辑器预览弹层控制start---
function FilePreviewAndDownload() {
    var FILETYPE = ['txt', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'pdf']
    $(document).find(".ewebeditorImg a").bind("mouseover", function (e) {
        var type = e.target.innerText.split(".");
        if (type[type.length - 1] && (FILETYPE.join(",").indexOf(type[type.length - 1]) >= 0 || type[type.length - 1].indexOf("预览下载") >= 0) && e.target.getAttribute("href")) {
            window.paramLinkAdress = e.target.href.substr(e.target.href.indexOf("pf="));
            window.EDITORLOADLINK = e.target;
            if (!e.target.children.length) {
                var div = document.createElement("span");
                div.onclick = function () { return false; }
                div.innerHTML = '<span class="darrow"></span><span class="blank"></span><span title="" onclick="window.open(\'../\'+window.sysCurrPath +\'sysn/view/comm/UpLoaderFilePreview.ashx?\' + paramLinkAdress,\'newwin80\',\'width=1000,height=820,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100\')" class="preview">预览</span><span title="" onclick="FireEvent1(window.EDITORLOADLINK,\'click\')" class="downloadL">下载</span>'
                $(this).append($(div).addClass("viewAndLoad"))
            }
        }
    })
}

function FireEvent1(obj, eventName) {
    try {
        obj.attachEvent('on' + eventName.toLowerCase().replace("on", ""), function (event) {
            window.open(obj.href, '_self')
        });
    }
    catch (e) {
        var event = document.createEvent('MouseEvents');
        event.initEvent(eventName.toLowerCase().replace("on", ""), true, true);
        obj.dispatchEvent(event);
    }
}

//编辑器预览弹层控制end---
