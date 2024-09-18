var objCur=null;
function showSubjectDiv(typ,obj){
	objCur = obj;
	var substr = "searchSubject" ; 
	if (typ ==2 ){substr = "searchFlow" ; }
	bill.easyui.CAjaxWindow(substr, function() {
		ajax.addParam("subject", obj.value);
	});
}

function clickSearch(){
	var searchtext = $("#searchtext").val();
	var src = $("#subjectFrame").attr("src").split("&")[0] + "&searchtext="+escape(searchtext);
	$("#subjectFrame").attr("src",src);
}

function clearSearch(){
	if (objCur!=null)
	{
		objCur.value = "";
		objCur.parentNode.children[0].value = "";
	}
}

function checkSubject(typ,ord)
{
	if (objCur!= null )
	{
		objCur.parentNode.children[0].value = ord;
		ajax.regEvent("searchSubject")
		ajax.addParam('typ', typ); //typ == 1 选择会计科目 typ==2 选择现金流量项目
		ajax.addParam('ord', ord);
		var r = ajax.send();
		objCur.value = r ;
		objCur.title = r ;
		objCur.style.color="#000";
	}
	objCur = null;
	var substr = "searchSubject" ; 
	if (typ ==2 ){substr = "searchFlow" ; }
	bill.easyui.closeWindow(substr);
}

function showSaveInfo(html){
	var win = bill.easyui.createWindow("abutmentSetReport", "对接设置报告", {collapsible:false,minimizable:false,maximizable:false,resizable:false,width:600, height:400} );
	var chtml = "<table id='content' style='width:100%;table-layout:fixed'><tr class='top'><th align='center' width='8%'>序号</th><th align='center' width='70%'>内容</th><th align='center'>说明</th></tr>";
	var ehtml = "</table>"
	win.innerHTML  =chtml + html + ehtml
}