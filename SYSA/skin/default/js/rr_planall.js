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
	var noDelID = 0;
	for(i=0;i<document.getElementsByName("sys_lvw_ckbox").length;i++){
		if(document.getElementsByName("sys_lvw_ckbox")[i].checked==true){
			selectid += document.getElementsByName("sys_lvw_ckbox")[i].value+",";
		}
	}
	if(selectid == ""){
		app.Alert("您没有选择任何维修受理单，请选择后再删除！");
	}else{		
		if(confirm("确定要删除吗？")){
			ajax.regEvent("delSLOrders");
			ajax.addParam("ord", selectid);
			var r = ajax.send();
			var arr_res = r.split("|");
			if(arr_res[0]=="-1"){	//没有删除权限
				app.Alert("您没有删除权限，不允许删除！");
			}else if(arr_res[0]=="2"){				
				lvw_refresh("mlistvw");	//刷新列表
				var noDel = arr_res[1];				
				var arr_noDel = "";
				if(noDel!=""){
					arr_noDel = noDel.split(",");
					for(var i=0;i<arr_noDel.length; i++){
						noDelID = Number(arr_noDel[i]);
						if(noDelID>0){
							$ID("tip_"+noDelID).innerHTML = "&nbsp;不允许删除！"
						}else if(noDelID<0){
							$ID("tip_"+Math.abs(noDelID)).innerHTML = "&nbsp;有关联维修单，不允许删除！"
						}
					}
				}
			}else if(arr_res[0]=="0"){
				app.Alert("您没有选择任何维修受理单，请选择后再删除！");
			}else if(arr_res[0]=="1"){
				lvw_refresh("mlistvw");	//刷新列表
			}
		}
	}
}

//删除受理单
function delSLOrders(slord,ly){
	if(slord!=""){
		if(confirm("确定删除?")){
			ajax.regEvent("delSLOrders","planall.asp");
			ajax.addParam("ord", slord);			
			var r = ajax.send();		
			var arr_res = r.split("|");
			if(arr_res[0]=="-1"){	//没有删除权限
				app.Alert("您没有删除权限，不允许删除！");
			}else if(arr_res[0]=="0"){
				app.Alert("您没有选择任何维修受理单，请选择后再删除！");
			}else if(arr_res[0]=="2"){				
				var noDel = arr_res[1];				
				var arr_noDel = "";
				if(noDel!=""){
					arr_noDel = noDel.split(",");
					for(var i=0;i<arr_noDel.length; i++){
						noDelID = Number(arr_noDel[i]);
						if(noDelID>0){
							try{
								$ID("tip_"+noDelID).innerHTML = "&nbsp;不允许删除！"
							}catch(e){}
							app.Alert("不允许删除！");
						}else if(noDelID<0){
							try{
								$ID("tip_"+Math.abs(noDelID)).innerHTML = "&nbsp;有关联维修单，不允许删除！"
							}catch(e){}
							app.Alert("有关联维修单，不允许删除！");
						}
					}
				}
			}else if(arr_res[0]=="3"){
				app.Alert("您选择的受理单已删除！");
			}else if(arr_res[0]=="1"){
				if (ly == 'list'){
					lvw_refresh("mlistvw");	//刷新列表
				}else if (ly == 'content'){
					 var openHref = window.opener.location.href;
					if(openHref.indexOf("/repair/planall.asp")>0){
						window.opener.lvw_refresh("mlistvw")
					}
					window.opener=null;window.open('','_self');window.close();
				}
			}
		}
	}
}



