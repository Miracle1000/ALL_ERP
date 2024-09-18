window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!="")
	{
		$("#searchitemsbutton2").click();
	}
}

function selectall(box) {
	var ck = box.checked;
	var boxs = document.getElementsByName("sys_lvw_ckbox");
	for (var i = 0 ; i < boxs.length; i++ )
	{
		boxs[i].checked = ck;
	}
}

function batDel() {	//批量删除
	var selectid = "";
	for(i=0;i<document.getElementsByName("sys_lvw_ckbox").length;i++){
		if(document.getElementsByName("sys_lvw_ckbox")[i].checked==true){
			selectid += document.getElementsByName("sys_lvw_ckbox")[i].value+",";
		}
	}
	if(selectid == ""){
		app.Alert("您没有选择任何文档，请选择后再删除！");
//		app.Alert("您没有选择任何文档，请选择后再删除！");
	}else{		
		if(confirm("确定要删除吗？")){
			ajax.regEvent("","delete.asp");
			ajax.addParam("ord", selectid);
			LoadSearchAttrs(ajax);
			var r = ajax.send();
			var arr_res = r.split("|");
			if(arr_res[0]=="-1"){	//没有删除权限
				app.Alert("您没有删除权限，不允许删除！");
				//app.Alert("您没有删除权限，不允许删除！");
			}else if(arr_res[0]=="2"){
				
				lvw_refresh("mlistvw");	//刷新列表
				var noDel = arr_res[1];				
				var arr_noDel = "";
				if(noDel!=""){
					arr_noDel = noDel.split(",");
					for(var i=0;i<arr_noDel.length; i++){
						$ID("wd_tip_"+arr_noDel[i]).innerHTML = "&nbsp;不允许删除！"
					}
				}
			}else if(arr_res[0]=="0"){
				app.Alert("您没有选择任何文档，请选择后再删除！");
				//app.Alert("您没有选择任何文档，请选择后再删除！");
			}else if(arr_res[0]=="1"){
				lvw_refresh("mlistvw");	//刷新列表
			}
		}
	}
}

//删除文档
function delWD(wdord){
	if(wdord!=""){
		if(confirm("确定删除?")){
			ajax.regEvent("","delete.asp");
			ajax.addParam("ord", wdord);
			LoadSearchAttrs(ajax);
			var r = ajax.send();			
			var arr_res = r.split("|");
			if(arr_res[0]=="-1"){	//没有删除权限
				app.Alert("您没有删除权限，不允许删除！");
				//app.Alert("您没有删除权限，不允许删除！");
			}else if(arr_res[0]=="2"){
				app.Alert("不允许删除！");
//				app.Alert("不允许删除！");
			}else if(arr_res[0]=="0"){
				app.Alert("您没有选择任何文档，请选择后再删除！");

//				app.Alert("您没有选择任何文档，请选择后再删除！");
			}else if(arr_res[0]=="1"){
				lvw_refresh("mlistvw");	//刷新列表
			}
		}
	}
}


function batArch() {	//批量归档
	var selectid = "";
	for(i=0;i<document.getElementsByName("sys_lvw_ckbox").length;i++){
		if(document.getElementsByName("sys_lvw_ckbox")[i].checked==true){
			selectid += document.getElementsByName("sys_lvw_ckbox")[i].value+",";
		}
	}	
	if(selectid == ""){
				app.Alert("您没有选择任何文档，请选择后再归档！");

//app.Alert("您没有选择任何文档，请选择后再归档！");
	}else{		
		if(confirm("确定要归档吗？")){
			ajax.regEvent("","archive.asp");
			ajax.addParam("ty", "document");
			ajax.addParam("ord", selectid);
			ajax.addParam("act", 1);
			LoadSearchAttrs(ajax);
			var r = ajax.send();
//			if (r.length > 0)
//			{
//				app.msgbox("链接过程出现错误", "<div>" + r + "</div>");
//				return;
//			}
			var arr_res = r.split("|");
			if(arr_res[0]=="-1"){	//没有归档权限
				app.Alert("您没有归档权限，不允许归档！");
			}else if(arr_res[0]=="2"){
				lvw_refresh("mlistvw");	//刷新列表				
				var noArch = arr_res[1];
				var arr_noArch = "";
				if(noArch!=""){
					arr_noArch = noArch.split(",");
					for(var i=0;i<arr_noArch.length; i++){
						$ID("wd_tip_"+arr_noArch[i]).innerHTML = "&nbsp;不允许归档！"
					}
				}
			}else if(arr_res[0]=="0"){
				app.Alert("您没有选择任何文档，请选择后再归档！");
			}else if(arr_res[0]=="1"){
				lvw_refresh("mlistvw");	//刷新列表
			}
		}
	}
}


function toArchive(ty,fileId,act){		//归档文档
	if(fileId==""){
		app.Alert("您没有选择任何文档，请选择后再归档！");
	}else{
		var gdStr = "确认归档？";
		if(act==0){
			gdStr = "确认取消归档？";
		}
		if(confirm(gdStr)){
			ajax.regEvent("","archive.asp");
			if(ty=="document"){
				ajax.addParam("ty", "document");
				ajax.addParam("ord", fileId);
			}else if(ty=="documentlist"){
				ajax.addParam("ty", "documentlist");
				ajax.addParam("id", fileId);
			}
			ajax.addParam("act", act);
			LoadSearchAttrs(ajax);
			var r = ajax.send();			
			var arr_res = r.split("|");
			if(arr_res[0]=="-1"){	//没有归档权限
				if(act==1){
					app.Alert("您没有归档权限，不允许归档！");
				}else if(act==0){
					app.Alert("您没有归档权限，不允许取消归档！");
				}
			}else if(arr_res[0]=="2"){
				if(act==1){
					app.Alert("不允许归档！");
				}else if(act==0){
					app.Alert("不允许取消归档！");
				}
			}else if(arr_res[0]=="0"){
				if(act==1){
					app.Alert("您没有选择任何文档，请选择后再归档！");
				}else if(act==0){
					app.Alert("您没有选择任何文档，请选择后再取消归档！");
				}
			}else if(arr_res[0]=="1"){
				lvw_refresh("mlistvw");	//刷新列表
			}
		}
	}
}

