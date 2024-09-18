Tabs.ItemClick = function(index,id,tag){
	switch(index){
		case 0:
			document.getElementById("groupPanel").style.display = "none";
			document.getElementById("rpt_info_GroupID").value = "0";
			document.getElementById("rpt_info_newfilterText").value = "";
			UpdateList();
			break;
		case 1:
			document.getElementById("rpt_info_newfilterText").value = "";
			document.getElementById("groupPanel").style.display = "block";
			if(document.getElementById("GroupID").value != "0"){
				document.getElementById("rpt_info_GroupID").value = document.getElementById("GroupID").value;
				UpdateList();
			} 
			break;
		case 2:
			document.getElementById("rpt_info_newfilterText").value = "";
			document.getElementById("groupPanel").style.display = "block";
			break;
	}
}

function GroupChange(v){
	document.getElementById("rpt_info_GroupID").value = document.getElementById("GroupID").value;
	UpdateList();
}

window.DivUpdate =  function(id ,title, mWidth,mHeight,mTop,mLeft){
	var div = document.getElementById("divdlg_" + id)

	if(isNaN(mWidth)) {mWidth  = undefined;}
	if(isNaN(mHeight)){mHeight = undefined;}
	if(isNaN(mTop))   {mTop    = undefined;}
	if(isNaN(mLeft))  {mLeft   = undefined;}
	if(div){
		var hf = document.getElementById(id + "_hideFrame")
		if(title.length>0){div.children[0].rows[0].cells[0].children[0].innerText = title}
		if(mWidth) {
			div.style.width = mWidth + "px";
			div.children[0].style.width = (mWidth-4) + "px";
			div.children[0].rows[0].cells[0].style.width = (mWidth-44) + "px";
			div.children[0].rows[1].cells[0].children[0].style.width = (mWidth-34) + "px"
			if(hf){hf.style.width =(mWidth-40) + "px"}
		}
		if(mHeight) {
			div.style.height = mHeight + "px";
			div.children[0].style.height = (mHeight-7) + "px";
			div.children[0].rows[1].cells[0].style.height = (mHeight-54) + "px"
			div.children[0].rows[1].cells[0].children[0].style.height = (mHeight-68) + "px"
			if(hf){hf.style.height =(mHeight - 56) + "px"}
		}
		if(mTop) {
			div.style.top = mTop + "px";
		}
		if(mLeft) {
			div.style.left = mLeft + "px";
		}
	}

}

document.body.onload = function(){
	var items = document.getElementsByTagName("DIV");
	for(var i = 0 ; i < items.length ; i ++){
		if(items[i].className=="toolitem"){
			var context = items[i].children[0]
			if(context && context.tagName=="DIV")
			{context.className = "toolcontext";	}
			items[i].onclick = toolbaritemclick;
		}
	}
}

function disableToolButton(id,v){
	var box = document.getElementById(id)
	var img = box.children[0].children[0]
	box.disabled = v;
	if (v==false)
	{	
		if(img.src.indexOf("disabled.gif")>0){
			img.src=img.src.replace("disabled.gif",".gif");
		}
	}
	else
	{
		if(img.src.indexOf("disabled.gif")<0)
		{
			img.src=img.src.replace(".gif","disabled.gif");
		}
		box.className = "toolitem";
	}
	
}

function UpdatePageIndex(){
	var indexCount = document.getElementById("rpt_info_PageCount").value;
	var indexBox = document.getElementById("PageIndex");
	if(indexBox.options.length < indexCount){
		for (var i =indexBox.options.length + 1 ; i < indexCount*1+1 ; i ++ )
		{
			var opt = document.createElement("option");
			opt.value = i;
			opt.innerText = i;
			indexBox.appendChild(opt)
		}
	}
	else if(indexBox.options.length > indexCount){
		for (var i = indexBox.options.length-1 ; i >= indexCount ; i -- )
		{
			indexBox.options.remove(i);
		}
	}
}

function UpdateField(txt){
	var id = txt.id.replace("f_","rpt_info_fld_")
	document.getElementById(id).value = txt.value;
	UpdateList();
}

function UpdateListDataArrive(r){
	var indexBox = document.getElementById("PageIndex");
	document.getElementById("PageTable").innerHTML = r;
	UpdatePageIndex(); //更新pageindex列表
	disableToolButton("firstpage",indexBox.selectedIndex==0);
	disableToolButton("prepage",indexBox.selectedIndex==0);
	disableToolButton("nextpage",indexBox.selectedIndex==(indexBox.options.length-1));
	disableToolButton("lastpage",indexBox.selectedIndex==(indexBox.options.length-1));
	document.getElementById("PageIndex").value = document.getElementById("rpt_info_PageIndex").value;
	document.getElementById("jlCount").innerText = document.getElementById("rpt_info_recordCount").value;
	document.getElementById("PageTitleSpan").innerHTML = document.getElementById("rpt_info_title").value
	document.getElementById("PageHeader").innerHTML = document.getElementById("rpt_info_header").value
	document.getElementById("PageFooter").innerHTML = document.getElementById("rpt_info_footer").value
	try{autoFrameHeight()}catch(e){}
	window.clearTimeout(window.showProcTimer);
	window.showProcTimer = 0;
	document.getElementById("xxx_proc").style.display = "none";
	try{
		var spans = document.getElementById("PageTable").getElementsByTagName("span")
		for (var i=0;i<spans.length; i++)
		{
			if(spans[i].className=="link"){
				spans[i].onmouseover = ListLinkMouseOver;
				spans[i].onmouseout = ListLinkMouseOut;
			}
		}
	}catch(e){}
}

function ListLinkMouseOver(){this.className = "overlink";}
function ListLinkMouseOut(){this.className = "link";}

function UpdateList(attr,value){
	var indexBox = document.getElementById("PageIndex");
	ajax.url = window.location.href
	ajax.regEvent("DataListCallBack");
	var frm = document.getElementById("rpt_into_frm")
	var  inputs = frm.getElementsByTagName("INPUT");
	for (var i = 4; i < inputs.length ; i ++ )
	{
		if(inputs[i].id.indexOf("rpt_info_fld_")==0){
			ajax.addParam(inputs[i].id,inputs[i].value);
		}
	}
	ajax.addParam("GroupID",document.getElementById("rpt_info_GroupID").value);
	ajax.addParam("ReportId",document.getElementById("ReportId").value)
	ajax.addParam("PageSize",document.getElementById("PageSize").value)
	ajax.addParam("PageIndex",indexBox.value);
	ajax.addParam("newfilterText",document.getElementById("rpt_info_newfilterText").value);
	ajax.addParam("basefilterText",document.getElementById("rpt_info_basefilterText").value);
	if(attr){ajax.addParam(attr,value);}
	ajax.send(UpdateListDataArrive);
	window.showProcTimer = window.setTimeout("if(window.showProcTimer>0){document.getElementById('xxx_proc').style.display = 'block';}",500);
}

function toolitemEvent(id){ //工具栏点击事件处理分支
	var pIndex = document.getElementById("PageIndex");
	switch(id){
		case "tjconfig":
			gotoConfig();
			break;
		case "nextpage":
			pIndex.selectedIndex ++;
			UpdateList();
			break;
		case "lastpage":
			pIndex.selectedIndex = pIndex.options.length-1;
			UpdateList();
			break;
		case "prepage":
			pIndex.selectedIndex --;
			UpdateList();
			break;
		case "firstpage":
			pIndex.selectedIndex = 0;
			UpdateList();
			break;
		case "sxbutton":
			showFilterDlg();
			break;
		case "msbutton": //报表呈现模式切换
			readmodelChange();
			break;
		case "cexcel":
			document.getElementById("__msgId").value = "CExcel";
			document.getElementById("rpt_into_frm").submit();
			break;
	}
}

function readmodelChange()
{
	var mbox = document.getElementById("msbutton");
	var img = mbox.children[0].children[0];
	var listmode = img.src.indexOf("_s.gif") > 0;
	img.src = listmode ? img.src.replace("_s.gif",".gif") : img.src.replace(".gif","_s.gif");
	mbox.title = listmode ? "报表模式" : "列表模式";
	document.getElementById("PageBody").className = listmode ? "listmodel" : "rptmodel";
}

function toolbaritemclick(){
	obj = window.event.srcElement;
	if(obj.tagName=="IMG"){obj=obj.parentElement.parentElement;}
	if(obj.tagName=="DIV" && obj.className == "toolitem_hover") {
		toolitemEvent(obj.id)
	}
}

function tu(obj){
	obj.className = "toolitem"
}

function tm(obj){
	obj.className = "toolitem_hover"
}


function gotoConfig(){ //配置
	var div= window.DivOpen("gjyz","高级验证",450,150);
	div.innerHTML = "<center><br>密码：<input type=password style='font-size:12px;border:1px solid #aaaaaf' class=textbox onkeydown='if(window.event.keyCode==13)showConfigWindow(this.value)'></center>"
}

function OpenConfig(url){
	//window.showModalDialog(url + "?id=" + document.getElementById("ReportId").value,null,'status:off;resizable:0;dialogHeight:600px;dialogWidth:860px;')
	var div= window.PageOpen(url + "?Id=" + document.getElementById("ReportId").value);
}

function showConfigWindow(v){
	ajax.regEvent("showconfig")
	ajax.addParam("key",v)
	ajax.exec()
}

function autoFrameHeight(){
	try{
	var h = document.getElementById("PageTable").offsetHeight*1 + 200;
	if(!window.ParentFrame){
		var p = window.parent;
		if(p!=window){
			var fm = p.document.getElementsByTagName("iframe")
			for (var i = 0 ; i < fm.length ; i++)
			{
				if(fm[i].contentWindow==window){
					window.ParentFrame = fm[i];
					break;
				}
			}
		}
	}
	if(window.ParentFrame){
		if(window.ParentFrame.offsetHeight<h){
			window.ParentFrame.style.height = h + "px"
		}
		
	}}
		catch(e){
			alert(e.message)
		}
}

//数据筛选///////////////////
lvw.delsptwhereRow = function(delButton) {
		var tr = delButton.parentElement.parentElement
		var tb = tr.parentElement.parentElement
		var rIndex = tr.rowIndex
		tb.deleteRow(rIndex)
		tb.deleteRow(rIndex-1)
		var nHeight = tb.rows.length*24 + 90 
		nHeight = nHeight > 500 ? 500 : nHeight
		tb.parentElement.style.height = (nHeight - 90)  + "px" 
		window.DivUpdate(tb.lvwId,"","a",nHeight+10)
}

function showFilterDlg() {  //显示过滤对话框
		var dtb = document.getElementById("datatable");
		var h =  140
		var dlg = window.DivOpen("lvwfilter_1" ,"多条件数据筛选",480, h ,'a','b')
		dlg.innerHTML = "<table class=full style='display:block'><tr><td style='display:block;color:#006600;text-align:left;padding-top:4px'><div style='width:100%;overflow:auto;'><b></b></div></td></tr>" + 
						"<tr><td style='text-align:right'>" + 
						"<table class=lvwtoolbartable><tr>" + 
						"<td><button title='添加筛选条件' onmouseover='lvw.toolbarmove(this)' onmouseout='lvw.toolbarout(this)'><img src='../../images/smico/3.gif'></button></td>" + 
						"<td><button title='执行条件' onmouseover='lvw.toolbarmove(this)' onmouseout='lvw.toolbarout(this)'><img src='../../images/smico/35.gif'></button></td>" + 
						"<td><button title='清除当前表格中的查询条件' onmouseover='lvw.toolbarmove(this)' onmouseout='lvw.toolbarout(this)'><img src='../../images/smico/dele_1.gif'></button></td>" + 
						"<td><button title='关闭' onmouseover='lvw.toolbarmove(this)' onmouseout='lvw.toolbarout(this)' onclick='window.getParent(this,12).rows[0].cells[1].children[0].click()'><img src='../../images/smico/1.gif'></button></td>" + 
						"</tr></table></td></tr></table>"
		dlg.style.overflow = "auto"
		var addbutton = dlg.children[0].rows[1].cells[0].children[0].rows[0].cells[0].children[0];
		addbutton.listview = dtb.parentElement;
		addbutton.td = dlg.children[0].rows[0].cells[0] //添加条件按钮
		addbutton.onclick = function(){ 
			var tb = addbutton.td.children[0].children[0]
			tb.lvwId = "lvwfilter_1"
			if(tb.tagName!="TABLE"){
				var tr = dtb.rows[0]
				var fArray = ""
				var currItem = ""
				var fdsArray = (document.getElementById("rpt_info_cols").value).split("][") 
				for (var i =  0; i <  fdsArray.length ; i ++ )
				{
					var cell = fdsArray[i].replace("[","").replace("]","")
					var cellywname = cell.replace(/\{.+\}/g,"")
					if(cellywname && cell.indexOf("visible")<0) {
						fArray = fArray + "<option value='" + cell + "' dtype='" + cellywname + "'>" + cellywname.replace("-") + "</option>"
					}
				}
				addbutton.td.children[0].innerHTML = "<table class=spTable style='padding:0px;margin:0px'><tr><td style='width:80px;text-align:right;color:#000;height:16px'>条件1：&nbsp;</td><td><select style='width:100px' >" + fArray + "</select></td><td>" + 
										 "<select><option value='>' title='大于'>＞</option>" + 
										 "<option value='>=' title='大于等于' >≥</option>" +
										 "<option value='<' title='小于'>＜</option>" + 
										 "<option value='<=' title='小于等于'>≤</option>" +
										 "<option value='<>' title='不等于'>≠</option>" +
										 "<option value=' like ' title='相似'>≈</option>" + 
										 "<option value='=' title='等于'>＝</option></select>" +
										 "</td><td><input type=text class=text style='width:140px'></td><td style='width:60px'></td></tr></table>"
			}
			else{
				var t = new Date()
				var rndId = "A" + t.getTime().toString().replace(".","")
				var tr = tb.insertRow(-1)
				var td = tr.insertCell(-1)
				td.colSpan = 5
				td.style.cssText = "width:350px;padding-left:75px;height:18px"
				td.innerHTML = "<input type='radio' checked name='" +  rndId  + "'><label>并且</label>&nbsp;<input type='radio' name='" +  rndId  + "'><label>或者</label> " 
				var tr = tb.rows[0].cloneNode(true);
				tb.tBodies[0].appendChild(tr);
				tr.cells[4].innerHTML = "&nbsp;<input type='image' src='../../images/smico/del.gif' height='12px' title='删除该条件' onclick='lvw.delsptwhereRow(this)'>"
				var nHeight = tb.rows.length*24 + 90
				nHeight = nHeight > 500 ? 500 : nHeight
				tb.parentElement.style.height = (nHeight - 90)  + "px" 
				window.DivUpdate("lvwfilter_1","","a",nHeight+10)
				for (var i=1;i<tb.rows.length ;i=i+2 )
				{
					var td = tb.rows[i].cells[0]
					td.children[0].id = "lvwfilter_ck_" + i + "_0"
					td.children[0].name = "lvwfilter_ck_" + i
					td.children[1].htmlFor = "lvwfilter_ck_" + i + "_0"
					td.children[2].id = "lvwfilter_ck_" + i + "_1"
					td.children[2].name = "lvwfilter_ck_" + i
					td.children[3].htmlFor = "lvwfilter_ck_" + i + "_1"
 				}
				
			}
		}
		var runbutton = dlg.children[0].rows[1].cells[0].children[0].rows[0].cells[1].children[0]; //执行按钮
		runbutton.onclick = function(){
			var tb = addbutton.td.children[0].children[0]
			var wherecode = new Array()
			for (var i=0; i<tb.rows.length ; i++ )
			{
				var tr = tb.rows[i]
				if(tr.cells.length>2){
					var sbox = tr.cells[1].children[0] //onchange='this.dtype=this.options[this.selectedIndex].dtype
					switch(sbox.options[sbox.selectedIndex].dtype){
						case "number":
							if(isNaN(tr.cells[3].children[0].value) || tr.cells[3].children[0].value.length==0){
								alert("【" + sbox.value + "】列需以数字作筛选条件。")
								tr.cells[3].children[0].focus();
								tr.cells[3].children[0].select();
								return false;
							}
							break;
						case "date":
							if(!lvw.isDate(tr.cells[3].children[0].value) || tr.cells[3].children[0].value.length==0){
								alert("【" + sbox.value + "】列需以日期作筛选条件。")
								tr.cells[3].children[0].focus();
								tr.cells[3].children[0].select();
								return false;
							}
							break;
						default:
							break;
					}
					if (tr.cells[2].children[0].value==" like ")
					{
						wherecode[i] = "[" + tr.cells[1].children[0].value + "]" +  tr.cells[2].children[0].value + ("'*" + tr.cells[3].children[0].value.replace(/\'/g,"''") + "*'").replace("***","**")
					}
					else{
						wherecode[i] = "[" + tr.cells[1].children[0].value + "]" +  tr.cells[2].children[0].value + "'" + tr.cells[3].children[0].value.replace(/\'/g,"''") + "'"
					}			
				}
				else{
					wherecode[i] = tr.cells[0].children[0].checked ? "and" : ") or ("
				}
			}
			wherecode = '(' + wherecode.join(" ") + ')'
			document.getElementById("rpt_info_newfilterText").value = wherecode;
			UpdateList();
		}

		var clearbutton = dlg.children[0].rows[1].cells[0].children[0].rows[0].cells[2].children[0];
		clearbutton.onclick = function(){
			document.getElementById("rpt_info_newfilterText").value = "---";
			UpdateList();
		} 
		addbutton.onclick();
}

function OpenReport(url){
	window.PageOpen(url,1000)
}

var Bill = {
	 showunderline: function (obj, c) {
        obj.style.textDecoration = "underline";
        if (c) {
			obj.style.color = c
            //obj.style.color = "#2F49a1";
        }
    }
	,
    hideunderline: function (obj, c) {
        obj.style.textDecoration = "none";
        if (c) {
            c = c.toLowerCase();
			if (c=="blue" || c == "#0000ff") {
				c = "#2F496E";
			}
			obj.style.color = c
        }
    }
	,
	BillTree : function(oid,bid){
		var div = window.DivOpen("jsdifhsfa","子单集合","800","570",'30',"b",1,20,1,1)
		 div.innerHTML = "<iframe style='width:100%;height:100%' frameborder=0 src='../../manufacture/inc/billpage.asp?__msgId=getChildBillTree&oid=" + oid + "&bid=" + bid + "'></iframe>"
	}
}

var ck = {
	SpShowList : function(OrId,BlId,logId,wName) { //审批页面调用明细
	var t = new Date()
	var opener = window.PageOpen("Readbill.asp?orderid=" + OrId + "&ID=" + BlId + "&SplogId=" + logId + "&vTime=" + t.getTime(),1000,700,wName);
	}
}

function headerMouseDown(header) { //鼠标在标头上移动时候触发
	
} 

function hdrmover(header)
{
	
}

function relshmove(header) {
	$(header).TableColResize(function(e){});
}

if(top==window) {
	document.body.style.overflow = "auto";
}