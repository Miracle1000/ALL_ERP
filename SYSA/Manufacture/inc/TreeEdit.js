window.currNodeId = 0 //当前单据的编号
if(!window.currTreeNode){window.currTreeNode  = null;}
window.TEditInit = function() {
	var topRow = document.getElementById('billtopbar');
	var tCell = topRow.children[0].rows[0].cells[0];
	tCell.innerText = "";
	document.getElementById("billtitle").style.backgroundImage = "url(../../images/m_mpbg.gif)";
	topRow.style.border = "0px"
	topRow.children[0].style.cssText = "border:0px solid red;border-collapse:collapse;height:16px;"
	topRow.children[0].cells[0].style.cssText = "border:0px;background-image:url()"
	topRow.children[0].cells[1].style.cssText = "border:0px;background-image:url()"


	if(document.getElementById("bcButton2")){document.getElementById("bcButton2").style.display = "none"}
	if(document.getElementById("bcButton5")){document.getElementById("bcButton5").style.display = "none"}
	if(document.getElementById("bcButton6")){document.getElementById("bcButton6").style.display = "none"}
	try{
		var td = document.getElementById("bcButton4").parentElement;
		var tr = td.parentElement;
		tr.deleteCell(td.cellIndex)
	}
	catch(e){}
	try{
		var td = document.getElementById("bcButton2").parentElement;
		var tr = td.parentElement;
		tr.deleteCell(td.cellIndex)
	}
	catch(e){}
	try{
		var td = document.getElementById("bcButton6").parentElement;
		var tr = td.parentElement;
		tr.deleteCell(td.cellIndex)
	}
	catch(e){}
	try{
		var td = document.getElementById("bcButton3").parentElement;
		var tr = td.parentElement;
		tr.deleteCell(td.cellIndex)
	}
	catch(e){}
	try{
		var td = document.getElementById("bcButton1").parentElement;
		var tr = td.parentElement;
		tr.deleteCell(td.cellIndex)
	}
	catch(e){}
	document.getElementById("refreshdetailtd").innerHTML = "";
	var tool = document.getElementById("billtopbardiv")
	var pan = document.getElementById("billtitle");
	pan.style.paddingLeft = "5px"
	pan.style.width = "600px"
	var read = window.location.href.indexOf("PowerReadOnly=1")>0 || window.location.href.indexOf("readmode=1") > 0;
	if(!read){
		pan.innerHTML = "<table class=lvwtoolbartable id='treepagetoolbar'><tr>" 
					+ "<td>" + GetToolItemHTML("../../images/smico/5.gif","添加子级",77,null,"AddChildNode()") + "</td>"
					+ "<td id='delnodetd'>" + GetToolItemHTML("../../images/smico/del3.gif","删除节点",77,"","DeleteNode()") + "</td>"
					+ "<td id='savenodetd'>" + GetToolItemHTML("../../images/smico/save.gif","保存节点",77,null,"SaveNode()") + "</td>"
					+ "<td style='padding-left:3px;padding-right:3px'><div style='border-left:2px dotted #e0e0ee;border-right:2px solid #e0e0ee;width:1px;height:18px'></div></td>"
					+ "<td>" + GetToolItemHTML("../../images/smico/inexcel.gif","",20, "导入Excel","SaveDataFromExcel()") + "</td>"
					+ "<td>&nbsp;</td>"
					+ "<td>" + GetToolItemHTML("../../images/smico/tofull.gif","",20, "扩展界面","FrameMax(this)") + "</td>"
					+ "<tr></table>"
	}
	else{
		pan.innerHTML = "<table class=lvwtoolbartable ><tr>" 
					+ "<td>" + GetToolItemHTML("../../images/smico/tofull.gif","",20, "扩展界面","FrameMax(this)") + "</td>"
					+ "<tr></table>"
	}
	pan.style.backgroundImage = "url(about:blank)";
	tool.style.backgroundImage = "url(../../images/smico/gpbg5.jpg)";
	tool.style.borderTop = "1px solid #acaccc";
	tool.style.borderBottom = "1px solid #e0e4ef";
	document.getElementById("billBodyDiv").style.borderTop = "0px"
	var lis = document.getElementsByTagName("li");
	for (var i=0; i < lis.length ; i ++ )
	{
		if(lis[i].className=="tvw_item tvw_selitem") {
			window.currTreeNode = lis[i];
			break;
		}
	}
}

window.GetToolItemHTML = function( img , text, width , title , eventHook){
	if(!eventHook){	eventHook = "" ; }
	if(text.length>0){
		return "<button title='" + (title?title:"") + "' onclick='this.blur();" + eventHook + "' style='cursor:pointer;width:" + width + "px;height:22px;padding-top:2px' class=wavbutton onmouseover='lvw.toolbarmove(this,\"bommvbutton\");this.style.backgroundColor=\"#fcfcff\"' onmouseout='lvw.toolbarout(this);this.style.backgroundColor=\"transparent\"'>" + 
			"<table class=full><tr><td style='width:18px;padding-left:2px' valign=top><img src='" + img + "'></td><td valign=top style='padding-top:3px;width:100%;padding-right:3px'>" + text + "</td></tr></table></button>"
	}
	else{
		return "<button title='" + (title?title:"") + "' onclick='this.blur();" + eventHook + "' onmouseover='lvw.toolbarmove(this);' onmouseout='lvw.toolbarout(this);'><img src='" + img + "'></button>"
	}
}

TEditInit()

function SaveDataFromExcel(){
	var url = "";
	var drtitle = ""
	switch(Bill.OrderId){
		case "6":
			url = "../../load/newload/bomdr.asp?bom=" + document.getElementById("Bill_Info_pid").value + "&currId=" + document.getElementById("Bill_Info_id").value;
			drtitle = "物料清单导入"
			break;
		default:
			return;
	}
	var div = window.parent.DivOpen("excelindlg",drtitle,650,370,120,'a',true,15,1);
	div.innerHTML = "<iframe src='" + url + "' style='width:100%;height:100%' frameborder=0></iframe>"
	var czButton = window.getParent(div,4).rows[0].cells[1].children[0]
	czButton.afterclick = function()
	{
		window.location.href = 	window.location.href;
	}
}

function FrameMax(button){
	var  frms  = window.parent.document.getElementsByTagName("iframe")
	for (var i=0;i<frms.length;i++){
		if(frms[i].contentWindow==window){
			var  frm = frms[i]
			if(frm.style.position!="absolute"){
				frm.style.position="absolute"
				frm.style.height="100%"
			
				if(window.navigator.userAgent.indexOf("MSIE 6.0") > 0) {
					frm.style.height= parent.document.documentElement.offsetHeight + "px";
					frm.style.width = parent.document.documentElement.offsetWidth + "px";
				}
				
				button.title = "正常界面"
				button.children[0].src="../../images/smico/tonol.gif"
			}
			else{
				frm.style.position="static"
				frm.style.height="550px"
				button.title = "扩展界面"
				button.children[0].src="../../images/smico/tofull.gif"
			}
			return false;
		}
	}
}

function AddChildNode(){
	if(window.currTreeNode){
		addTreeChild(window.currTreeNode)
	}
	else{
		SaveNode()
	}
}
function SaveNode(){
	var button = document.createElement("button")
	button.innerText = "保存"
	Bill.cmdButtonClick(button)
	var button = null;
}
function DeleteNode(){
	var button = document.createElement("button")
	button.innerText = "删除"
	Bill.cmdButtonClick(button,"treenodedelete")
	var button = null
}

tvw.itemClick = function (li) {}

tvw.NodeClick = function(li) {
	if (window.event.button!=2)
	{
		var id = li.tag
		ajax.regEvent("");
		ajax.addParam("OrderId",Bill.OrderId);
		ajax.addParam("ID",id);
		ajax.addParam("ParentNodeId",id)
		ajax.addParam("ParentID",Bill.ParentID);
		try{
			ajax.addParam("PowerReadOnly",document.getElementById("Bill_Info_readonly").value); //只读状态
			ajax.addParam("readmode",document.getElementById("Bill_Info_readbillmode").value);  //是否通过billRead调用
        }catch(e){}
		var r = ajax.send();
		var sIndex = r.indexOf("<!--单据编" + "辑区域开始-->") //此处用加号隔开，是防止回调时以此处作为提取数据的切入点。
		var eIndex = r.indexOf("<!--单据编" + "辑区域结束-->")
		if(sIndex<0 || eIndex<0 ){
			
			var mdiv = document.createElement("div")
			mdiv.innerHTML = r;
			//document.body.innerText = r
			if(mdiv.innerText.length>0 && (mdiv.innerText.indexOf("问题")>0 || mdiv.innerText.indexOf("错误")>0 || mdiv.innerText.indexOf("异常")>0  )  ){
				var div = window.DivOpen("billgeterr","获取数据失败",600,400);
				div.innerHTML  ="<span class=c_r style='margin:4px'>" + mdiv.innerText.replace(/。/g,"<br>").replace(/\n/g,"<br>") + "</span>";
			}
			return false;
		}
		var signLen = ("<!--单据编辑" + "区域结束-->").length;
		r = r.substring(sIndex+signLen , eIndex)
		var cPan =  document.getElementById("BillMainInfo");
		cPan.innerHTML = r;
		var script = cPan.getElementsByTagName("script")
        for (var i = 0; i < script.length; i++) {
            window.eval("(function(){" + script[i].innerHTML + "})()")
        }
		lvw.UpdateAllScroll();
		window.BillSpManTest();
		window.currNodeId = document.getElementById("Bill_Info_id").value;
		window.currTreeNode = li;
		setFrameSize();
	}
	//else{
	//	var ml = new  contextmenu(window.ContextMenuClick(li))
	//	var cItem = ml.add();
	//	cItem.text = "添加子件"
	//
	//	var cItem = ml.add();
	//	cItem.text = "删除"
	//	
	//	var cItem = ml.add();
	//	cItem.text = "复制"
	//	
	//	var cItem = ml.add();
	//	cItem.text = "剪切"
//
//		var cItem = ml.add();
//		cItem.text = "粘贴"
//		ml.show()
//		return true;
	//}
}

window.ContextMenuClick = function(li){
	return function(text,tag){
		confirm(text)
		switch(text){
			case "添加子件":
				window.addTreeChild(li)
				break
			case "删除":
				break
			case "复制":
				break
			case "剪切":
				break
			case "粘贴":
				break
		}
		return true;
	}
}


window.addTreeChild = function(li){ //添加子元素
	var  id = li.tag
	if(id.length==0 || isNaN(id)) {
		id = 0
	}
	ajax.regEvent("addChild")
	tvw.ongetChildren()
	ajax.addParam("ParentNodeId",id)
	window.UpdateNode(li,ajax.send())
	if (id==0)
	{
		window.location.reload();
	}
	
}

window.UpdateNode = function(li,html){
	var r = html
	if (r.indexOf("tvwChild=")==0)
	{
		r = r.replace("tvwChild=","")
		var imgs = li.getElementsByTagName("img")
		imgs[imgs.length-1].src = "../../images/icon_file_c.gif"
		var nextli = li.nextSibling
		//alert(nextli.children[0].getElementsByTagName("li").length)
		//alert(r)
		nextli.children[0].innerHTML = nextli.children[0].innerHTML  + r;
		nextli.style.display = "";
		li.children[0].innerHTML = "<img src='../../images/smico/minus.gif' onmousedown='tvw.expNode(this)'>"
	}
	else{
		var div = document.createElement("div")
		div.innerHTML = r
		r = div.innerText
		var div = window.DivOpen("edittreeerr","创建子节点失败",500,300);
		div.innerText = r
		
	}
}

window.teBoxLeft_mv = function(mv){

}