//生产订单脚本
var me = new Object();
me.ckCount = 0;
me.http = Bill.ScriptHttp();
me.showrowseting = function(a){
	var div = window.DivOpen("asdasdscv","参数设置 - 核定产量运算",800,500,'a','b',1,15);
	var tr = window.getParent(a,7);
	var disref = lvw.getCellValueByName("",tr,"disrefku")
	if (disref !=0 && disref!=1){disref = 0}
	var html = "<table style='width:750px;margin-left:5px;background-color:f0f0f0;line-height:24px;color:#2f496e;margin-top:10px'><tr><td align='right'  width='100'>产品名称：</td><td colspan=5>" + tr.cells[3].innerText + "</td><td colSpan=2 align='center' rowSpan=2><button onclick='me.RefreshProductNum()' class='wavbutton' style='line-height:18px'>刷新数据</button></td></tr>";
	html = html + "<tr><td align='right' width='100'>核定产量：</td><td colspan=5><input type=text readonly style='border:0px' class=text value='" + lvw.getCellValueByName("",tr,"核定产量") + "'> （当前设置的数量）</td></tr>" + 
				  "<tr><td align='right'  width='100'>采购未入库数：</td><td id='ac_num1' width='110'></td><td align='right'  width='100'>已申请未入库：</td><td width='110' id='ac_num2'></td>" + 
				  "<td align='right'  width='100'>合同未出库：</td><td id='ac_num3' width='110'></td><td align='right' width='100'>已申请未出库：</td><td id='ac_num4' width='110'></td></tr>" + 
				  "</table>"

	var btype = lvw.getCellValueByName("",tr,"可用库存计算方式");  //可用库存计算方式
	html = html + "<div style='background-color:white;padding:10px;padding-left:4px;'><b>可用库存</b></div>"
	html = html + "<fieldSet style='display:block;margin-left:5px;margin-right:15px;border:0px;background-color:#f0f0f0;padding:5px;'><legend style='background-color:white'>计算规则：</legend><div style='margin:5px;'>可用库存 = 现有库存 + <select id='btype1'><option value=0>无</option><option value=100 " + (parseInt(btype/100)==1 ? "selected" : "") + ">已申请未入库</option><option value=200 " + (parseInt(btype/100)==2 ? "selected" : "") + ">已采购未入库</option></select> - <select id='btype2'><option value=0>无</option><option value=10 " + (btype%100==10 ? "selected" : "") + ">已申请未出库</option><option value=20 " + (btype%100==20 ? "selected" : "") + ">合同未出库</option></select>&nbsp;应用范围：<input type=radio name=aflists id=afw_0001 checked><label for=afw_0001>当前行</label>&nbsp;<input type=radio name=aflists id=afw_0002><label for=afw_0002>勾选行</label><input type=radio name=aflists id=afw_0003><label for=afw_0003>整个清单</label></div></fieldSet>"

	html = html + "<div style='background-color:white;padding:10px;padding-left:4px;padding-bottom:4px;'><b>现有库存参考仓库</b><br>&nbsp;&nbsp;&nbsp;&nbsp;<span style=color:red>说明：需求数量减去当前参考仓库中的库存总数是计算产品核定产量的一个步骤。</span><br>"

    
	me.currRowNewCk  = lvw.getCellValueByName("",tr,"参考仓库");
	var ckck = "|" + me.currRowNewCk + "|";  //获取当前行的仓库
	html  = html + "<div style='position:relative;width:370px;top:5px;left:20px;background-color:white;z-index:100;'><input style='display:none' type=checkbox " + ( ckck=="|-1|" ? "checked" : "") + " id=cckall onclick='me.ckselectall(this)'><label for=cckall style='display:none'>全选</label>&nbsp;" +
	"&nbsp;生产清单应用范围：<input type=radio name=awlists id=awl_0001 checked><label for=awl_0001>当前行</label>&nbsp;<input type=radio name=awlists id=awl_0002><label for=awl_0002>勾选行</label>" + 
	"&nbsp;<input type=radio name=awlists id=awl_0003><label for=awl_0003>整个清单</label></div>" +
	"<div id='kunumlist' style='position:relative;top:-10px;margin:6px;border:1px dashed #aaa;padding:5px;height:120px;overflow:auto;padding-top:10px;'></div>"
	html = html + "</div><center><button class=wavbutton style='width:60px;margin-top:2px' onclick='me.applyck(this)'>确定</button>&nbsp;<button class=wavbutton style='width:60px;margin-top:2px' onclick='window.DivClose(this)'>取消</button></center>"
	div.innerHTML = html;
	div.soureObject = a;
	me.currRow = tr;
	me.UpdateStoreBindType(btype) ; //根据仓库计算类型，获取仓库库存
	me.RefreshProductNum(); //获取产品的相关运算数据
}

me.RefreshProductNum = function() {
	//获取产品相关数量：已采购未入库、已申请未入库等等
	var tr = me.currRow;
	var p = lvw.getCellValueByName("",tr,"productID");
	var u = lvw.getCellValueByName("",tr,"单位ID");
	me.http.regEvent("B2_RefreshProductNum");
	me.http.addParam("product",p);
	me.http.addParam("unit",u);
	var r = me.http.send()
	var n = r.split("|")
	if(n.length==4) {
		document.getElementById("ac_num1").innerHTML = "<a href='javascript:void(0)' class='link' onclick='window.PageOpen(\"bScript/B2_ProductNumList.asp?btype=1&product=" + p + "&unit=" + u +"\",860,640,\"sdffc\")'>" + n[0] + "</a>";
		document.getElementById("ac_num2").innerHTML = "<a href='javascript:void(0)' class='link' onclick='window.PageOpen(\"bScript/B2_ProductNumList.asp?btype=2&product=" + p + "&unit=" + u +"\",860,640,\"sdffc\")'>" + n[1] + "</a>";
		document.getElementById("ac_num3").innerHTML = "<a href='javascript:void(0)' class='link' onclick='window.PageOpen(\"bScript/B2_ProductNumList.asp?btype=3&product=" + p + "&unit=" + u +"\",860,640,\"sdffc\")'>" + n[2] + "</a>";
		document.getElementById("ac_num4").innerHTML = "<a href='javascript:void(0)' class='link' onclick='window.PageOpen(\"bScript/B2_ProductNumList.asp?btype=4&product=" + p + "&unit=" + u +"\",860,640,\"sdffc\")'>" + n[3] + "</a>";
	}
	else {
		alert(r);
	}
}



function showzynum(xq,sh,num,safe){  //显示库存消耗计算过程
	var div = window.DivOpen("xssd","库存消耗计算参数",440,240)
	div.innerHTML = "<div style='background-color:#f6f7f9;width:100%;height:100%'><div style='padding-top:12px;padding-bottom:8px;font-weight:bold;color:#000;text-align:center'>当前产品信息</div>" + 
					"<table border=1 bordercolor='#ccccdd' height=100 cellspacing=0 width=310 align=center><tr><td align=right width='50%'>实际需求：</td><td>&nbsp;" + xq 
					+ "</td></tr><tr><td  align=right>损耗率：</td><td>&nbsp;" + sh + "</td></tr><tr><td  align=right>实际生产：</td><td>&nbsp;" 
					+ num + "</td></tr><tr><td  align=right>安全库存：</td><td>&nbsp;" + safe + "</td></tr></table>"
					+ "<br><center style='color:#000;'>库存消耗 = 实际需求 + 安全库存 - 实际生产*(1-损耗率)</center></div>"
}
function showcurrckLog(a) {//显示现有库存的计算公式
	var tr = window.getParent(a,6);
	var div = window.getParent(tr,3);
	var ID = document.getElementsByName("MT1")[0].value
	var pid = lvw.getCellValueByName("",tr,"物料ID");
	var unit = lvw.getCellValueByName("",tr,"单位ID");
	var ck = lvw.getCellValueByName("",tr,"ck");
	var bomid = lvw.getCellValueByName("",tr,"plbomlistid");
	var btype = lvw.getCellValueByName("",tr,"可用库存计算方式ID");
	var cankcgnum = lvw.getCellValueByName("",tr,"采购未入库参考");
	var cankrknum = lvw.getCellValueByName("",tr,"申请未入库参考");
	var cankhtnum = lvw.getCellValueByName("",tr,"合同未出库参考");
	var cankcknum = lvw.getCellValueByName("",tr,"申请未出库参考");
	var currcknum = lvw.getCellValueByName("",tr,"可用库存ID");
	var I1 = lvw.getCellIndexByName("",tr,"plbomlistid");
	var I2 = lvw.getCellIndexByName("",tr,"ck");
	var I3 = lvw.getCellIndexByName("",tr,"单位ID");
	var I4 = lvw.getCellIndexByName("",tr,"物料ID");
	var I5 = lvw.getCellIndexByName("",tr,"ckdelnum");	
	var dat = new Array();
	lvw.TryCreateHiddenPageDataToArray(div, true);
	for (var i = 0 ; i < div.hdataArray.length ; i ++ )
	{
		if (div.hdataArray[i].length > 2)
		{
			var d1 = div.hdataArray[i][I1]; //bomID
			var d2 = div.hdataArray[i][I2]; //参考仓库
			var d3 = div.hdataArray[i][I3];	//单位
			var d4 = div.hdataArray[i][I4]; //产品ID
			var d5 = div.hdataArray[i][I5]; //库存消耗
			if(bomid == d1){
				break;
			}
			if(d2==ck && d3==unit && pid==d4)
			{
				dat[dat.length] = d1 + "," + d5;
			}
		}
	}
	var div =  window.DivOpen("fgfgdfh","可用库存推算记录",700,500);
	me.http.regEvent("B2_GetMRPcurrckLog");
	me.http.addParam("ddno",document.getElementById("Bill_Info_id").value);
	me.http.addParam("currdddata",dat.join(";"));
	me.http.addParam("bomid",bomid);
	me.http.addParam("cp",pid);
	me.http.addParam("unit",unit);
	me.http.addParam("ck",ck);
	me.http.addParam("btype",btype);
	me.http.addParam("cankcgnum",cankcgnum);
	me.http.addParam("cankrknum",cankrknum);
	me.http.addParam("cankhtnum",cankhtnum);
	me.http.addParam("cankcknum",cankcknum);
	me.http.addParam("currcknum",currcknum);
	div.innerHTML  = me.http.send();
	lvw.UpdateScrollBar(document.getElementById("listview_MRPckLog"));
	//lvw.Refresh(document.getElementById("listview_MRPckLog"));
}