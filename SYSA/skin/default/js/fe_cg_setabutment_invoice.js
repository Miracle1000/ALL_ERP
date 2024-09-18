var objCur=null;
function showSubjectDiv(typ,obj){
	objCur = obj;
	var substr = "searchSubject" ; 
	if (typ ==2 ){substr = "searchFlow" ; }
	bill.easyui.CAjaxWindow(substr, function() {
		ajax.addParam("subject", obj.value);
	});
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
	}
	objCur = null;
	var substr = "searchSubject" ; 
	if (typ ==2 ){substr = "searchFlow" ; }
	bill.easyui.closeWindow(substr);
}