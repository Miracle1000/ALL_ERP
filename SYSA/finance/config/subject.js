//删除科目
function delSubject(subject, ord,typ){
	var title = ""; var url = "";
	if(subject == 'Account'){
		title = "会计科目"; url = "../config/setAccountSubject.asp"
	}else if(subject == 'flow'){
		title = "现金流量项目"; url = "../config/setFlowSubject.asp"
	}
	if(ord == ""){
		app.Alert("您没有选择任何"+title);
	}else{
		if(confirm("确定要删除吗？")){
			ajax.regEvent("delSubject",url);
			$ap("ord",ord);
			var r = ajax.send();
			if(r != ""){
				if(r == "0"){
					app.Alert("您没有选择任何"+title);
				}else if(r == "1"){
					if((window.opener)){
						window.opener.location.href=url+"?subject="+typ;
						window.close();
					}else{
						window.location.href=url+"?subject="+typ;
					}
				}else if(r == "2"){
					app.Alert(title+"有明细"+title.replace("会计","").replace("现金流量","")+"，不能删除！");
				}else if(r == "3"){
					if(subject == 'Account'){
						app.Alert(title+"有期初余额，不能删除！");
					}else if(subject == 'flow'){
						app.Alert(title+"主表项目有初始化金额，不能删除！");
					}
				}else if(r == "4"){
					app.Alert(title+"有发生额，不能删除！");
				}
			}
		}
	}
}

//停用/启用科目
function stopUseSubject(subject, ord,typ){
	var title = ""; var url = "";
	if(subject == 'Account'){
		title = "会计科目"; url = "../config/setAccountSubject.asp"
	}else if(subject == 'flow'){
		title = "现金流量项目"; url = "../config/setFlowSubject.asp"
	}
	if(ord == ""){
		app.Alert("您没有选择任何"+title);
	}else{
		var useStr = $("#use_"+ord).html();
		if(confirm("确定要"+useStr+"吗？")){
			ajax.regEvent("stopUseSubject",url);
			$ap("ord",ord);
			$ap("stop",(useStr == "停用"? 1 : 0));
			var r = ajax.send();
			if(r != ""){
				var arr_ret = r.split(",");
				if(arr_ret[0] == "0"){
					app.Alert("您没有选择任何"+title);
				}else if(arr_ret[0] == "1"){
					if(window.opener){
						window.opener.location.href=url+"?subject="+ord;
					}
					if (typ ==1)
					{
						window.location.href=url+"?subject="+ord;
					}
					else
					{
						window.location.reload();
					}
				}else if(arr_ret[0] == "1"){
					app.Alert(title+"有明细"+title.replace("会计","").replace("现金流量","")+"，不可以停用");
				}
			}
		}
	}
}

function selectParentSubject(parentID){
	if(window.opener){
		window.opener.selectParent(parentID);
		window.opener=null;window.open('','_self');window.close()
	}
}


function nodeShow(ord){
	var tye = $("#tye_"+ord);
	var tyeClass = tye.attr("class");
	if(tyeClass.indexOf("ty_1_e1")>0){
		tye.removeClass("ty_1_e1");
		tye.addClass("ty_1_e0")
	}else if(tyeClass.indexOf("ty_1_e0")>0){
		tye.removeClass("ty_1_e0");
		tye.addClass("ty_1_e1")
	}else if(tyeClass.indexOf("ty_2_e1")>0){
		tye.removeClass("ty_2_e1");
		tye.addClass("ty_2_e0")
	}else if(tyeClass.indexOf("ty_2_e0")>0){
		tye.removeClass("ty_2_e0");
		tye.addClass("ty_2_e1")
	}
	var subDiv = $("#subject_t_s_"+ord);
	var yshow = subDiv.css("display");
	var folderImg = $("#tvw_Storetree_"+ord+"_ico");
	if(yshow == "block"){
		subDiv.css("display","none");
		folderImg.attr("src",folderImg.attr("ico2"));
	}else{
		subDiv.css("display","block");
		folderImg.attr("src",folderImg.attr("ico1"));
	}
}

function kmOpenWin(act,args){
	switch(act){
	case "con":		
		window.open('subjectContent.asp?ord='+args+'','newwincon','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')	
		break;
	case "add":
		window.open('subjectAdd.asp?ord='+args+'&sort=0','newwincor','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')
		break;	
	case "edit":
		window.open('subjectAdd.asp?ord='+args+'&sort=1','newwincor','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')
		break;	
	}
}