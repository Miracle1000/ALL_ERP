$(function () {
    if (window.SysConfig.SystemType==3) {$("#lstbody_plansearch").css("background", "#f5f5f5") }    
})
function removeByValue(arr, val) {
  for(var i=0; i<arr.length; i++) {
    if(arr[i] == val) {
      arr.splice(i, 1);
      break;
    }
  }
}

window.AnalysisMessages = [];

window.LoadParentMasId = function (masid) {
	$("input[type='checkbox'][v='" + masid +"']").click();
}

window.ShowInfoMessages = function(){
		var div = app.createWindow("DoAnalysisMsgInfo", "提示信息", {width:600,height:400,bgShadow:8, closeButton: true,maxButton:true});
		div.innerHTML  = "<div style='padding:4px'>" + window.AnalysisMessages.join("<hr style='border:0px; border-bottom:1px solid #ddd;'>") + "</div>";
}

window.OnBillLoad = function () {
  if(Bill.Data.uistate!="add" ){ return; }
	$ID("lstbody_plansearch").style.cssText = "width:100%;";
	$ID("msglistDiv").innerHTML  = "";
    $("#fxbutton").click(function () {
		window.AnalysisMessages = [];  //显示消息
		if($ID("SelfData").value.length>0) {
			$ID("hybutton").disabled = false;
		} else {
			$ID("hybutton").disabled = true;
		}
		Bill.CallBackParams ("一键分析", "APS_DoAnalysis", false);
		var div = app.createWindow("DoAnalysisMsgInfo", "", {width:400,height:100,bgShadow:8,toolbar:false,bgcolor:"#f3f3f3"});
		if(app.IeVer!=7)div.style.paddingTop = "20px";
		div.style.textAlign = "center";
		function showProcMessage(pv, pmsg){
			var msghtml = "";
			if(pv>=0) {
					div.innerHTML = "<div style='margin:0 auto;width:300px;height:16px;padding-top:0px;border:1px solid #aaa;background-color:white;*margin-top:20px;'><div style='background-color:#2d8dd9;height:98%;overflow:hidden;width:" + pv + "px'>&nbsp;</div></div>"
										+ "<div style='margin:0 auto;width:300px;text-align:left;padding-top:6px'>" + pmsg + "</div>";
			} else {
					//错误信息
					div.innerHTML = "<div style='margin:0 auto;width:300px;text-align:left;margin-top:-5px;*margin-top:20px;'>" + pmsg + "</div>"
					+ "<div style='text-align:center;padding-top:10px'><button class='zb-button' onclick='app.closeWindow(\"DoAnalysisMsgInfo\")'>关闭</button></div>";
			}
		}
		$ID("msglistDiv").innerHTML = "";
		app.ajax.send(
			function(okmsg){
				okmsg = okmsg.replace("Status:10.","");
				if(okmsg.replace(" ","")=="OK") {
					showProcMessage(300,  "计算完毕 (100%)，准备加载结果表......");
					window.ShowResultReport();
				} else {
					showProcMessage(-1,  "<span style='color:red'>" + okmsg + "</span>");
				}
			},
			function(procmsg){
				if(procmsg.indexOf("Message:")==0) {
					var msgs = procmsg.replace("Message:","").split(";");
					for (var i =0; i<msgs.length ; i++ )
					{
						if(msgs[i].length>=2) { window.AnalysisMessages.push(msgs[i]); }
					}
					$ID("msglistDiv").innerHTML = "&nbsp;&nbsp;<a href='javascript:void(0)'  style='color:red' onclick='window.ShowInfoMessages()'><u style='color:red'>【分析过程中有" 
						+ window.AnalysisMessages.length + "条提示信息】</u></a>";
					return;
				}
				if(procmsg.indexOf("Status: ")>=0) {
					var msg = procmsg.split("Status: ")[1].replace(/\s/g,"").split(".");
				    var pv = parseInt(msg[0]);
					var pmsg =  msg[1];
					if(pv<8) {
							pv = parseInt(pv*0.2*300/7);
							pmsg = "正在进行核算，时间可能较长，请稍后 (" + parseInt(pv/3) + "%) ......"
					} else if(pv==8){
							var pvs = pmsg.replace("Speed(","").replace(")","").split(",");
							pv = parseInt(  ( 0.2 + (pvs[1]/pvs[0])*0.78 ) * 300  );
							pmsg = "正在进行核算，时间可能较长，请稍后 (" + parseInt(pv/3) + "%) ......"
					}else {
							pv = 290;
							pmsg = "正在进行核算，时间可能较长，请稍后 (" + parseInt(pv/3) + "%) ......"
					}
					showProcMessage(pv,  pmsg);
				} 
				else{ 
					showProcMessage(-1,  procmsg);
				}
			},
			function(failmsg){ }
		);
   });
    $("#hybutton").click(function(){
		window.SelfFixedData = "";
		$ID("SelfData").value =  "";
		$("#fxbutton").click();
    });
}

window.listBodyDivDom=null;
//显示表格
window.ShowResultReport = function(cindex) {
	if(window.listBodyDivDom==null) {
		window.listBodyDivDom = $ID("lvw_sstabReport").parentNode;
	}
	if(cindex==undefined) { 
		cindex =  $(".sstab_sle").attr("v");
	};
	app.ajax.regEvent("ShowResultTable");
	app.ajax.addParam("ResultType",  cindex);
	app.ajax.addParam("d1",  $ID("lstbody_plansearchdate0").value);
	app.ajax.addParam("d2",  $ID("lstbody_plansearchdate1").value);
	app.ajax.addParam("stype", $ID("lstbody_plansearchtype_0").value);
	app.ajax.addParam("skeytext", $ID("lstbody_plansearchtext_0").value);
	app.ajax.addParam("cx", $ID("cx").value);
	app.ajax.addParam("__billord", Bill.Data.ord);
	app.ajax.send(function(result){
			var signHtml = "";
			window.CurrDaysLvw = eval("(" + result + ")");
			switch(cindex*1) {
				case 0:
						if(window.CurrDaysLvw.rows.length>0 && cindex==0) {
								signHtml = "<div  style='padding:6px;border-top:1px solid #c0ccDD;'><table><tr>"
										+ "<td><button style='width:12px;height:12px;border:1px solid #c2c2c2;background-color:#f2f2f2'></button></td><td>代表无可利用能力&nbsp;&nbsp;</td>"
										+ "<td><button style='width:12px;height:12px;border:1px solid #eeaa00;background-color:#ffcc00'></button></td><td>代表历史排产占用&nbsp;&nbsp;</td>"
										+ "<td><button style='width:12px;height:12px;border:1px solid #007000;background-color:#009900'></button></td><td>代表本次排产占用</td>"
										+ "</tr></div>";
						 }
				case 2:
					  if(window.CurrDaysLvw.rows.length>0 && cindex==2) {
								signHtml = "<div  style='padding:6px;border-top:1px solid #c0ccDD;'><table><tr>"
										+ "<td><button style='width:12px;height:12px;border:1px solid #c2c2c2;background-color:#f2f2f2'></button></td><td>代表无可利用能力&nbsp;&nbsp;</td>"
										+ "<td><button style='width:12px;height:12px;border:1px solid #007000;background-color:#009900'></button></td><td>代表不超过工序的定额能力&nbsp;&nbsp;</td>"
										+ "<td><button style='width:12px;height:12px;border:1px solid #eeaa00;background-color:#ffcc00'></button></td><td>代表等于工序的定额能力&nbsp;&nbsp;</td>"
										+ "<td><button style='width:12px;height:12px;border:1px solid #990000;background-color:#ff0000'></button></td><td>代表已超过工序的定额能力&nbsp;&nbsp;</td>"
										+ "</tr></div>";
						 }
				case 3:
					var lvwfc = ListView.Create("ApsResult_0" , window.CurrDaysLvw);
					window.listBodyDivDom.innerHTML =  lvwfc.GetHtml() + signHtml;
					window.listBodyDivDom.children[0].style.cssText = "width:100%;overflow:auto";
					break;
			}
			app.closeWindow("DoAnalysisMsgInfo");
	});
}

window.RefreshLineHeight = function(){
	if(window.CurrDaysLvw) { ___RefreshListViewByJson(window.CurrDaysLvw); }
}


window.delItemMNode = function(id){
	window.UpdateMatLinks({addlinks:[],deletedlinks:[id]});
}

window.showWLFXPage = function(id) {
    app.OpenUrl(window.SysConfig.VirPath + "SYSN/view/produceV2/MaterialAnalysis/MaterialAnalysisList.ashx?ord=" + app.pwurl(id) + "&view=details")
}

window.UpdateMatLinks = function(obj){
	var  fd = Bill.GetField("selectedMlList");
	var defv = ((fd.value || fd.defvalue) + "").length>0 ? ((fd.value || fd.defvalue) + "").split(",") : [];
	if(defv.length==0) {  fd.links = []; }
	for (var i = 0; i< obj.addlinks.length; i++)
	{
		var oi = obj.addlinks[i];
		defv.push(oi.id);
		fd.links.push( {
			title: (oi.title 
				+ " <span title='点击打开2' class='open' onclick='window.showWLFXPage(" + oi.id + ");' style='cursor:pointer;height:14px;width:14px;text-valign:middle;position:relative;top:2px;display:inline-block'  src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/file/txt.gif'></span>" 
				+ "<span title='点击删除' class='del' onclick='window.delItemMNode(" + oi.id + ");'  style='cursor:pointer;height:14px;width:14px;text-valign:middle;margin-left:3px;position:relative;top:2px;display:inline-block'  src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/cross.gif'></span>"
			), 
			url:"",
			id:oi.id} 
		);
	}
	for (var i = 0; i< obj.deletedlinks.length; i++)
	{
		var id = obj.deletedlinks[i];
		for (var ii=defv.length-1; ii>=0 ; ii-- )  { removeByValue(defv, id); }
		for (var ii=fd.links.length-1; ii>=0; ii--) { if(fd.links[ii].id==id){ fd.links.splice(ii,1); } }
	}
	fd.defvalue = defv;
	fd.value = defv;
	fd.remark = fd.links.length < 1 ? "进行排产分析之前，请选择左侧导航中要进行排产分析的物料分析结果" : "";
	$ID("fxbutton").disabled = fd.links.length < 1 ? true : false;
	$ID("selectedMlListcc").children[0].children[0].innerHTML = Bill.CLinkBarHtml(fd);
}

window.GetCXList = function (win) {
    var cxtype = "";
    var cxnodes = "";
    win.Bill.getBillData(function (key, value) {
        if (key == "cxtype") { cxtype = value; }
    });
    var fd = Bill.GetField("cx");
	var tvw = win.TreeView.objects[0];
    if (cxtype == 1) { 
		//全部车间，模拟全选
		win.TreeView.CheckAll(tvw, true);
    } 
	//获取选中节点
	var ids = [];
	fd.links = [];
	var tvw = win.TreeView.objects[0];
	var nodes = window.TreeView.GetCheckedNodes(tvw);
	for (var i = 0; i < nodes.length; i++) {
		if (nodes[i].value*1 > 0) {
			fd.links.push({ title: nodes[i].text, url: "" });
			ids.push(nodes[i].value);
		}
	}
	fd.defvalue = ids.join(",");
	fd.value = ids.join(",");

    var td = $ID("cx").parentNode.parentNode;
    td.innerHTML = Bill.CLinkBarHtml(fd);
    win.close();
}

window.SetCXList = function(win) {
	var values = $ID("cx_tit").getAttribute("true_value");
	var tvw2 = win.PageInitParams[0].groups[0].fields[1];
	setTimeout(function(){
		win.TreeView.SetNodesChecked(tvw2.tree, values, true);
	},10);
}

var lineheightbox = null;

window.GetPvCellHtml = function(v){
	if(lineheightbox==null) { lineheightbox = $ID("lstbody_lvwlineheight_0"); }
	var h = lineheightbox.value;
	var padd = parseInt((h - 18) /2)
	switch(v) {
		case '1':  return "<div  style='height:" + h + "px;width:100%;overflow:hidden;'><div  class='r1bar0' style='margin-top:" + padd + "px'>&nbsp;</div></div>"
		//暂不支持单个拖动	case '2':  return "<div   isDrag=1 onmouseover='window.CDragDisplay(this,1)'  onmouseout='window.CDragDisplay(this,0)' style='height:" + h + "px;width:100%;overflow:hidden;'><div  class='r1bar1' style='margin-top:" + padd + "px'>&nbsp;</div></div>"
		case '2':  return "<div   isDrag=1  style='height:" + h + "px;width:100%;overflow:hidden;'><div  class='r1bar1' style='margin-top:" + padd + "px'>&nbsp;</div></div>"
		default: return "<div style='height:" + h + "px;width:100%;overflow:hidden;'><div  class='r1bar2' style='margin-top:" + padd + "px'>&nbsp;</div></div>"
	}
}

function GetDateCellHtml(lvw,  rowindex, v) {
	var title = lvw.rows[rowindex][0];
	var isNotAsign = title.indexOf("ASign=1>")==-1;
	var vs = v.split("|");
	var html = "<div style='padding:3px;line-height:16px;padding-left:6px;'>"
	if(vs[0]=="1") {
			html += "开工：" + vs[1] + ( ($ID("sortType_0check").checked && isNotAsign) ? "  <a href='javascript:void(0)'  onclick='ShowDateChangeDlg(this,1,\"" + vs[1] + "\")'>【调整】</a>" : "")   + "<br>";
			html += "完工：" + vs[2] + ( ($ID("sortType_1check").checked && isNotAsign) ? "  <a href='javascript:void(0)'  onclick='ShowDateChangeDlg(this,2,\"" + vs[2] + "\")'>【调整】</a>" : "")   + "<br>";
			html += "交货：<span style='color:red' class='jhrqdate'>" + vs[3] + "</span>";
	} else {
			html += "开工：" + vs[1] + "<br>";
			html += "完工：" + vs[2] + "";
	}
	return html + "</div>";
}

function ShowDateChangeDlg(box,  changetype, dvalue) {
	var td = box.parentNode.parentNode;
	var tr = td.parentNode;
	var bomlistid = tr.cells[0].getElementsByTagName("span")[0].getAttribute("planbomlistid");
	var div = app.createWindow("dateSettingdlg",  (changetype==1?"调整日期":"调整日期"), {width:400, height:140, closeButton:true,bgShadow:20,canMove:true});
	div.innerHTML = "<table style='width:100%;height:100%'><tr><td align=center style='height:50px'> "  +  (changetype==1?"新开工日期":"新完工日期") + "："
								+ "<span><input class='billfieldbox'  id='dchagebox'  dateui='date'  value='' uitype='datetime' type=text onclick='datedlg.show()' maxlength=10 size=13></span>"
								+ " <button class='zb-button'  onclick='doDateChange(" + bomlistid + "," + changetype + ",$ID(\"dchagebox\").value)'>确定</button><button onclick='app.closeWindow(\"dateSettingdlg\")'  class='zb-button'>取消</button>"
								+ "</td></tr></table>";
	 $(div).find("input.billfieldbox[dateui='date']").unbind("blur focus input propertychange", app.InputCheckDate).bind("blur focus  input propertychange", app.InputCheckDate);
}

function doDateChange(bomlistid,  changetype,  newdt ){
	if(!window.SelfFixedData) {  window.SelfFixedData = [];  }
	var has = false;
	for (var i = 0; i<window.SelfFixedData.length ;  i++)
	{
		if(window.SelfFixedData[i][0]==bomlistid ) {
			window.SelfFixedData[i][1] = changetype;
			window.SelfFixedData[i][2] = newdt;
			has = true;
			break;
		}
	}
	if(has==false) {  window.SelfFixedData.push( [bomlistid, changetype, newdt] ); }
	var selfhtml = [];
	for (var i=0; i<window.SelfFixedData.length ; i++ )
	{
		selfhtml[i]=window.SelfFixedData[i].join(",");
	}
	app.closeWindow("dateSettingdlg");
	$ID("SelfData").value =  selfhtml.join(";");
	$("#fxbutton").click();
}

function GetDragPosDiv(){
	var div = $ID("DragPosDiv1");
	if(!div) { 
		div = document.createElement("div");
		div.id = "DragPosDiv1";
		document.body.appendChild(div);
		div.style.cssText = "cursor:pointer;border:0px solid red;position:absolute;width:20px;height:20px;overflow:hidden;background:transparent url(" + window.SysConfig.VirPath + "SYSN/skin/default/img/aaa1.gif) no-repeat center center";
	}
	return div;
}


//拽动滑块
window.beginMoveoutExec = 0;
window.OnCellDraging = 0;
window.CurrActiveDragCells = [];
window.CurrCellXYPos = [];
window.GetCurrActiveDragCells = function(currindex, tr, td){
	var cells = [td];
	for (var i =currindex-1; i>0; i-- )
	{
		var td  = tr.cells[i];
		var cdiv = td.children[0];
		if(cdiv && cdiv.getAttribute("isDrag")==1) { cells.unshift(td); } 
		else { break; }
	}
	for (var i =currindex+1; i<tr.cells.length; i++)
	{
		var td  = tr.cells[i];
		var cdiv = td.children[0];
		if(cdiv && cdiv.getAttribute("isDrag")==1) { cells.push(td); } 
		else { break; }
	}
	window.CurrActiveDragCells = cells;
	return cells;
}


window.GetFocusCellUI = function(x){
	//var scleft  =  $ID("lvw_ApsResult_0").scrollLeft*1;
	for (var i = 0; i<window.CurrCellXYPos.length ;  i++)
	{
		var o =  window.CurrCellXYPos[i];
		var x1 =  o.left ;
		var x2 =  x1 + o.width ;
		if(x1<x && x<x2) {
			return i; 
		}
	}
	return -1;
}

window.DragCKMsEvent = function(ev){
	if(ev.type=="mousedown") {
		window.OnCellDraging = 1;
		var div = ev.target;
         var l=div.offsetLeft, t=div.offsetTop,  x = ev.clientX,  y = ev.clientY;
		 var tr = window.CurrActiveDragCells[0].parentNode;
		 window.CurrCellXYPos = [];
		 for (var i=0; i<tr.cells.length ;  i++) {
				var dompos = tr.cells[i].getBoundingClientRect();
				window.CurrCellXYPos.push( {left: dompos.left,  width: tr.cells[i].offsetWidth} );
		 }
         app.beginMoveElement(div, 
         function(ev){
            var nx =  (((ev.clientX) - x) + l) + "px";
			var celli = window.GetFocusCellUI(ev.clientX);
			if(celli>=1) {
				if(window.LastiposBox) {
					LastiposBox.style.borderRight = "";
					window.LastiposBox = null;
				} 
				var dtr = window.CurrActiveDragCells[0].parentNode;
				var iposBox =  dtr.cells[celli].children[0].children[0];
				if(iposBox.style.borderRight=="") {
					iposBox.style.borderRight = "2px solid red";
					window.LastiposBox = iposBox;
				}
				$("#DragPosDiv1").css({left: nx});
			}
         }, function (ev) {
			if(window.LastiposBox) {
				var dtr =  window.CurrActiveDragCells[0].parentNode;
				var I1 =  window.CurrActiveDragCells[window.CurrActiveDragCells.length-1].cellIndex;
				var I2 = window.LastiposBox.parentNode.parentNode.cellIndex;
				if(I2*1!=I1*1) {
					if(window.confirm("确定要调整排产吗？")) {
						var bomid = dtr.cells[0].getElementsByTagName("span")[0].getAttribute("planbomlistid");
						var headers = window["lvw_JsonData_ApsResult_0"].headers;
						var d1 = headers[I1].title.split("<br>")[0].replace("年","-").replace("月","-").replace("_","");
						var d2 = headers[I2].title.split("<br>")[0].replace("年","-").replace("月","-").replace("_","");
						app.ajax.regEvent("DoItemChange");
						app.ajax.addParam("d1",d1);
						app.ajax.addParam("d2",d2);
						app.ajax.send(function(r) {
							
						});
					}
				}
				LastiposBox.style.borderRight = "";
				window.LastiposBox = null;
			} 
			window.OnCellDraging = 0;
			window.beginMoveoutExec = 1;
			window.CDragDisplayMouseOut();
		 });
	}
}

window.DragPDMsEvent = function(ev){
	if(window.OnCellDraging==1) { return; }
	if(ev.type=="mouseover") {
		window.beginMoveoutExec = 0;
	} else 
	{
		window.beginMoveoutExec = 1;
		setTimeout(window.CDragDisplayMouseOut, 100);
	}
}

window.CDragDisplay = function(box, displayType) {
	if(window.OnCellDraging==1) { return; }
	var td= box.parentNode;
	var tr = td.parentNode;
	var currindex = td.cellIndex;
	if( displayType==1 ) {
		if(window.beginMoveoutExec==1) {
			window.CDragDisplayMouseOut();
		}
		var cells = window.GetCurrActiveDragCells(currindex,tr, td);
		for (var i = 0; i<cells.length ; i++ )
		{
			var nbox = cells[i].children[0].children[0]; 
			nbox.style.borderTop = "2px solid red";
			nbox.style.borderBottom = "2px solid red";
			if(i==0) { nbox.style.borderLeft = "2px solid red"; }
			if(i==cells.length-1) { nbox.style.borderRight= "2px solid red"; }
		}
		var div = GetDragPosDiv();
		var pos = app.GetObjectPos( cells[cells.length-1] );
		div.style.left = (pos.left+pos.width*1-8) - $ID("lvw_ApsResult_0").scrollLeft  + "px";
		div.style.top = (pos.top + 36) + "px";
		$(div).unbind("mouseover").bind("mouseover",DragPDMsEvent).unbind("mouseout").bind("mouseout",DragPDMsEvent);
		$(div).unbind("mousedown").bind("mousedown",DragCKMsEvent);
	} else {
		window.beginMoveoutExec = 1;
		setTimeout(window.CDragDisplayMouseOut, 100);
	}
}

window.CDragDisplayMouseOut = function(){
	if(window.OnCellDraging==1) { return; }
	if(window.beginMoveoutExec==0) {return;}
	for (var i = 0;  i<window.CurrActiveDragCells.length; i++ )
	{
		var cell =  window.CurrActiveDragCells[i];
		var nbox = cell.children[0].children[0]; 
		nbox.style.border = "";
	}
	$("#DragPosDiv1").remove();
	window.beginMoveoutExec = 0;
}

window.GetPeevCellHtml = function(lvw, ri,  ci){
	if(lineheightbox==null) { lineheightbox = $ID("lstbody_lvwlineheight_0"); }
	var h = lineheightbox.value;
	var v = lvw.rows[ri][ci] || "";
	if(v.length==0) {  //无数据
		return "<div style='height:" + h + "px;width:100%;overflow:hidden;'><div  class='r1bar2' style='height:100%'>&nbsp;</div></div>";
	}
	var ns = v.split("|"); //  工序ID | 额定 | 超额 | 已占用
	var hasn = ns[3]*1;
	var maxnum = ns[1]*1;
	var maxnum2 = ns[2]*1;
	if(hasn==0 && maxnum==0) {  return "<div style='height:" + h + "px;width:100%;overflow:hidden;'><div  class='r1bar2' style='height:100%'>&nbsp;</div></div>"; } 
	if(maxnum==0) { return "<div style='text-shadow:0 0 2px #000;height:" + h + "px;width:100%;overflow:hidden;'><div  style='background-color:red;height:100%'>100%</div></div>";  }
	if(hasn>0) {
		var bl = parseInt(hasn*100/maxnum);
		var sh =  (bl>100?100:bl);
		var color = hasn<maxnum ? "#009900" : (hasn>=maxnum && hasn<maxnum2 ? "orange" : "red");
		var ih = parseInt(sh*h/100);
		var lh = ih>12 ? ih : 12;
		return "<div style='height:" + h + "px;width:100%;overflow:hidden;'><div  style='text-shadow:0 0 2px #000;margin-top:" + (parseInt(h*(100-sh)/100))+ "px;background-color:" + color + ";height:" + ih+ "px;line-height:" + ih+ "px'>"
				+ "<a href='javascript:void(0)' onclick='showZTFHTLinkDiv(this," +  ns[0] + ",\"" + lvw.headers[ci].dbname.split("<br>")[0] + "\")'><b style='font-family:arial;color:#f2f2f2;" +  (bl*1<30?"position:relative;top:-5px": "") + "'>" + bl + "%</b></a></div></div>";
	}
	return "";
}

//显示资源负荷图明细
window.showZTFHTLinkDiv = function(box,  WFPID, date1) {
	date1 =  date1.replace("年","-").replace("月","-").replace("_","");
	app.ajax.regEvent("ShowZYFHTItem");
	app.ajax.addParam("WFPID",   WFPID);
	app.ajax.addParam("date1",   date1);
	app.ajax.addParam("crash",  ($ID("Crash_0check").checked?1:0))
	var r = app.ajax.send();
	if(r.indexOf("{")>0) {  
		var obj = eval("(" + r + ")");
		var htmls = [];
		htmls.push("<div style='padding:15px;'>")
		htmls.push("<div>工序名称： " + obj[4] + "  <div style='float:right;width:120px;font-family:微软雅黑'>【" + date1 + "】</div></div>");
		htmls.push("<div style='height:1px;overflow:hidden;width:300px;margin:5px 0px'>&nbsp;</div>");
		htmls.push("<div>已占用/总工时： "  + (obj[2]*1).toFixed( window.SysConfig.NumberBit)  + "/" + (obj[0]*1).toFixed( window.SysConfig.NumberBit)+ " (最大: " +   (obj[1]*1).toFixed( window.SysConfig.NumberBit) + ") <div style='float:right;width:120px;font-family:微软雅黑'>【占用率：" +  parseInt((obj[2]*1/obj[0]*1)*100) + "%】</div></div>");
		var tb = obj[3];
		htmls.push("<div>")
		htmls.push("<table border=1 cellpadding=7 style='min-width:500px;background-color:#ffffff;margin:10px 0px 0px  0px;border-collapse:collapse' bordercolor='#aaaaaa'>")
		htmls.push("<tr>");
		htmls.push("<th>生产计划</th><th>产品编号</th><th>产品名称</th><th>型号</th><th>单位</th><th>占用能力</th><th>数量</th>");
		htmls.push("</tr>");
		for (var i = 0; i<tb.rows.length ; i++ )
		{
			var row = tb.rows[i];
			htmls.push("<tr>");
			htmls.push("<td>" +  row[1]  + " (" +  row[0] + ")</td>");
			htmls.push("<td>" +  row[3]  + "</td>");
			htmls.push("<td>" +  row[2]  + "</td>");
			htmls.push("<td>" +  row[4]  + "</td>");
			htmls.push("<td>" +  row[6]  + "</td>");
			htmls.push("<td>" +  (row[5]*1).toFixed(window.SysConfig.NumberBit)  + " h</td>");
			htmls.push("<td>" +  (row[7]*1).toFixed(window.SysConfig.NumberBit)  + "/" +  (row[8]*1).toFixed(window.SysConfig.NumberBit)  + "</td>");
			htmls.push("</tr>");
		}
		htmls.push("</table>");
		htmls.push("</div><br>")
		htmls.push("</div>");
		var div = app.createFloatDiv("HTLinkDiv", {
			title: "占用详情",
			html :  htmls.join(""),
			bindobj:  box
		});
	} else { alert(r); }
}

window.OpenAnalysisGTT = function(){
	app.OpenUrl("?ord=" + app.pwurl(Bill.Data.ord) + "&view=details&ResultTypeV=GTT");
}
window.OpenAnalysisFHB = function(){
	app.OpenUrl("?ord=" + app.pwurl(Bill.Data.ord) + "&view=details&ResultTypeV=FHT");
}
window.OpenAnalysisJGB = function(){
	app.OpenUrl("?ord=" + app.pwurl(Bill.Data.ord) + "&view=details&ResultTypeV=JGB");
}
window.OpenAnalysisList = function(){
	app.OpenUrl("AnalysisMxList.ashx?APSOrd=" + app.pwurl(Bill.Data.ord));
}
window.OpenManOrderPage = function(){
	app.OpenUrl("../ManuOrders/ManuOrdersAdd.ashx?fromType=3&fromid=" + app.pwurl(Bill.Data.ord));
}
