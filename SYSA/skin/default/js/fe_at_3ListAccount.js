function showSubjectDiv(obj){
	$('#w').html("<iframe src='../../finance/config/setaccountsubject.asp?sort=3&needstop=1' frameborder=0  style='border:0px;width:100%;height:98%'></iframe>").window({
		title:'明细科目选择',
		width:670,
		height:420,
		closeable:true,
		collapsible:false,
		minimizable:false,
		maximizable:false
	}).window('open');
}

function checkSubject(typ,ord)
{
	$("#sfields_subject").children("input").val(ord) ;
	ajax.regEvent("searchSubject")
	ajax.addParam('ord', ord);
	var r = ajax.send();
	$("#subjectstr").css("color","");
	$("#subjectstr").val(r);
	$('#w').window('close');
}