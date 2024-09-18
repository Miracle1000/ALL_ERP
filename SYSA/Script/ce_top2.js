

// 一个简单的测试是否IE浏览器的表达式
isIE = (document.all ? true : false);

// 得到IE中各元素真正的位移量，即使这个元素在一个表格中
function getIEPosX(elt) { return getIEPos(elt,"Left"); }
function getIEPosY(elt) { return getIEPos(elt,"Top"); }
function getIEPos(elt,which) {
 iPos = 0
 while (elt!=null) {
  iPos += elt["offset" + which]
  elt = elt.offsetParent
 }
 return iPos
}
function ask() { 
document.all.date.action = "savelistadd13.asp"; 
} 

//BUG.4155.KILLER.2014.03.27 项目详情编辑产品明细问题  保存后删除mxpx，chancelist 表中的记录
function del(a,mxpxID){
	var o = event.srcElement;
	var $ = jQuery;
	
	//要删除的mxpx 集合
	var oldMxpxID = $("#delMxpxID").val();	
	if(typeof(oldMxpxID)=="undefined"){oldMxpxID="0";}
	if(oldMxpxID == ""){
		oldMxpxID = "0";
	}
	if(typeof(mxpxID)=="undefined"){mxpxID="0";}
	if(mxpxID+""==""){mxpxID="0"}
	$("#delMxpxID").val(oldMxpxID+","+mxpxID);
	
	//要删除的项目明细集合
	var oldChanceID = $("#delChanceID").val();
	var curChanceID = $(o).parent().siblings("input[name=oldchancelist_"+mxpxID+"]").val();
	if(oldChanceID == ""){
		oldChanceID = "0";	
	}
	//alert("oldChanceID="+oldChanceID +"    curChanceID="+curChanceID+"   oldMxpxID="+oldMxpxID +"      mxpxID="+mxpxID);
	if(typeof(oldChanceID)=="undefined"){oldChanceID="0";}
	if(typeof(curChanceID)=="undefined"){curChanceID="0";}
	if(curChanceID+""==""){curChanceID="0"}
	$("#delChanceID").val(oldChanceID+","+curChanceID);
	$(o).parentsUntil("tbody").last().parent().parent().parent().remove();
}

// -->
