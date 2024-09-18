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
	var src = $("#subjectFrame").attr("src").split("&")[0] + "&searchtext="+searchtext;
	$("#subjectFrame").attr("src",src);
}

function checkSubject(typ,ord)
{
	if (objCur!= null )
	{	
		if (typ == 1)//选择会计科目
		{
			objCur.parentNode.children[0].value =  ord;
			if(!window.ActiveXObject){app.lvweditor.__U_C(objCur.parentNode.children[0]);}
		}
		else if (typ==2) //选择现金流量项目
		{
			objCur.parentNode.children[0].value = ord;
			ajax.regEvent("searchFlowSubject")
			ajax.addParam('ord', ord);
			var r = ajax.send();
			objCur.value = r ;
		}
		objCur.style.color="#000";
	}
	objCur = null;
	var substr = "searchSubject" ; 
	if (typ ==2 ){substr = "searchFlow" ; }
	bill.easyui.closeWindow(substr);
}