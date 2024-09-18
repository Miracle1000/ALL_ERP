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
			//非IE兼容
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

function content_bntClick(md5_ord,typ){
	switch (typ)
	{
	case 1:
		window.location.href = "tempadd.asp?ord=" + md5_ord ;
		break;
	case 2 :
		OperateDelete(md5_ord)
		break;
	case 3 :
		OperateStopOpen(1,md5_ord)
		break;
	case 4 : 
		OperateStopOpen(0,md5_ord)
		break;
	}
	
}

function OperateDelete(ord) {
	var ordlist="";
	if (ord==0)
	{
		$(".lvcbox").each(
			function(){
				if($(this).attr("checked")==true)
				{
					if (ordlist.length!="")
					{
						ordlist = ordlist + ",";
					}
					ordlist = ordlist + $(this).val();
				}
			}
		)
		if (ordlist.length=="")
		{
			app.Alert("您没有选择任何模板,请选择后再删除！");
			return ;
		}
	}
	else 
	{
		ordlist = ord;
	}
	if(confirm('确认删除？')){
		ajax.regEvent("doDel")
		ajax.addParam('ordlist', ordlist);
		ajax.send(function(r){
			 if (r == "1") {
				opener.lvw_refresh('mlistvw');
				window.close();
			 }
			 else
			 {
				if (r=="0")
				{		
					app.Alert("没有选择可删除的模板,请重新选择后再删除！");
				}
			 }
		});
	}
}


function OperateStopOpen(typ,ord)
{
	var status = "停用";
	if (typ == 0)
	{
		status = "启用"
	}
	var ordlist="";
	if (ord==0)
	{
		$(".lvcbox").each(
			function(){
				if($(this).attr("checked")==true)
				{
					if (ordlist.length!="")
					{
						ordlist = ordlist + ",";
					}
					ordlist = ordlist + $(this).val();
				}
			}
		)
		if (ordlist.length=="")
		{
			app.Alert("您没有选择任何模板,请选择后再"+status+"！");
			return ;
		}
	}
	else 
	{
		ordlist = ord;
	}
	if(confirm('确认'+status+'？')){
		ajax.regEvent("doSet")
		ajax.addParam('ordlist', ordlist);
		ajax.addParam('status', typ);
		ajax.send(function(r){
			 if (r == "1") {
				opener.lvw_refresh('mlistvw');
				window.location.reload();
			 }
			 else
			 {
				if (r=="0")
				{		
					app.Alert("没有选择可"+status+"的模板,请重新选择后再"+status+"！");
				}
			 }
		});
	}
}