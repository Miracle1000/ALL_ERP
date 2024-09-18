$(function(){
	$('.bindRadio:checked').trigger('click');
});


function loadBinding(show){	//加载或隐藏添加移动绑定列表
	var tb = document.getElementById("bdlist");
	var trs = tb.rows;
	if (trs[1].cells[0].innerHTML != "暂无绑定")
	{
		for (var i = 1; i < trs.length; i++)
		{
			id = trs[i].id.replace("tr","");
			bindUse(id,show + 2);
		}
	}

	$('.bindAddBtn').attr('disabled',show!=1);
	AddGPS(show);
}

function addBinding(bdNum){		//加载添加移动绑定
	$('#w').window('open');
	document.getElementById("w").style.display = "block";
	var editBind = document.getElementById("editBind");
	var url = "";
	if(bdNum == ""){		//如果bdNum为空则 添加
		url = "../Mobile/Macbind.asp?act=add&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	}else if(bdNum != ""){	//如果bdNum不为空则 修改
		var isExit = 0;
		bdNum = Number(bdNum);
		var bindList = document.getElementById("bindList").value;
		var bindInfo = "";
		var arr_bdInfo = "";
		if(bindList!=""){
			var arr_bind = bindList.split("{^}");
			for(i=1;i<arr_bind.length;i++){
				if(i == bdNum){
					isExit = i;
					break;
				}
			}
			if(isExit>0){
				var editindex = document.getElementById("tr"+bdNum).rowIndex;
				bindInfo = arr_bind[editindex-1];
				arr_bdInfo = bindInfo.split("[|]");
				var useBind = "";
				var macsn = "";
				var phone = "";
				useBind = arr_bdInfo[0];
				macsn = arr_bdInfo[1];
				phone = arr_bdInfo[2];
				url = "../Mobile/Macbind.asp?act=add2&bdNum="+bdNum+"&useBind="+useBind+"&macsn="+macsn+"&phone="+phone+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			}else{
				alert("请选择正确的行");
				return;
			}
		}
		
	}
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState < 4) {
			editBind.innerHTML="loading...";
		}
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			editBind.innerHTML=response;
			xmlHttp.abort();
			OpenMobile()
		}
	};
	xmlHttp.send(null); 
}

var bindNum = 0;
function saveBind(frm,bdNum){
	if(bdNum!=""){
		saveBindEdit(frm,bdNum);
	}else{
		saveBindAdd(frm)
	}
}

function saveBindAdd(frm){		//添加修改的绑定信息
	var bindList = "";	//手机绑定信息
	var useBind = 1;
	var macsn = "";		//手机串号
	var phone = ""
	var actStr = "";
	var arr_bind = "";
	bindList = document.getElementById("bindList").value;
	if(bindList!=""){
		arr_bind = bindList.split("{^}");
		if(arr_bind.length>3){
			alert("您为该账号绑定的手机数已达上限");
			return;
		}
	}
	var myDate = new Date();
	var addTime = myDate.getFullYear() + "-" + (myDate.getMonth()+1) + "-" + myDate.getDate() + " " + myDate.getHours() + ":" + myDate.getMinutes() + ":" + myDate.getSeconds();
	if(frm.useBind[1].checked){
		useBind = 0;
	}
	macsn = trim(frm.macsn.value);
	phone = trim(frm.phone.value);
	var arr_bdlist
	for (var i=0;i<arr_bind.length ;i++ )
	{
		arr_bdlist = arr_bind[i].split("[|]");
		if (arr_bdlist[1]!="" && arr_bdlist[1]==macsn)
		{
			alert("您已添加手机串号【"+macsn+"】，请不要重复绑定");
			return;
		}
	}
	
	if(checkmacsn(macsn)){
				bindList = useBind +"[|]"+ macsn +"[|]"+ phone +"[|]"+ addTime +"{^}" + bindList;
				document.getElementById("bindList").value = bindList;
				bindNum += 1;
				var bdlist = document.getElementById("bdlist");
				var countCell=bdlist.rows.item(0).cells.length; 
				var countCell2=bdlist.rows.item(1).cells.length;
				if(countCell2==1){
					bdlist.deleteRow(1);
				}
				var newtr = bdlist.insertRow(1);
				newtr.id = "tr"+bindNum;
				newtr.className = "blue2";
				newtr.style.textAlign = "center";
				for (i = 0; i < countCell; i++) {
					var h = bdlist.rows[0].cells[i].innerText.replace(/\s/,"");
					var cell = newtr.insertCell(i);
					cell.height = 27;
					switch (h) {
						case "手机串号": cell.innerHTML = macsn; break;
						case "状态":
							if (useBind == 1) {
								cell.innerHTML = "启用";
							} else {
								cell.innerHTML = "停用";
							}
							break;
						case "备注":
							cell.innerHTML = phone;
							break;
						case "添加人员":
							cell.innerHTML = window.adminor;
							break;
						case "添加时间": cell.innerHTML = addTime;
							break;
						case "操作":
							actStr = "";
							if (useBind == 1) {
								actStr += "<input type='button' value='停用' class='anybutton' onClick='bindUse(" + bindNum + ",0)'>";
							} else {
								actStr += "<input type='button' value='启用' class='anybutton' onClick='bindUse(" + bindNum + ",1)'>";
							}
							actStr += "<input type='button' value='修改' class='anybutton' onClick='addBinding(" + bindNum + ")'>";
							actStr += "<input type='button' value='删除' class='anybutton' onClick='delBind(" + bindNum + ")'>";
							cell.innerHTML = actStr;
							break;
					}
				}
				$('#w').window('close');
	}	
	OpenMobile();
}

function checkmacsn(macsn){
	var url = "../Mobile/Macbind.asp?act=checkmacsn&macsn="+ macsn +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send(null);
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		var arr_res = "";
		if (response!=""){
			arr_res = response.split("|");
			if(arr_res[0]=="2"){
				alert("该手机串号已给【"+arr_res[1]+"】绑定，请不要重复绑定");
				return false;
			}else if(arr_res[0]=="1"){
				return true;
			}else{
				alert("数据查询异常，请刷新后重试");
				return false;
			}
		}else{
			alert("数据查询异常，请刷新后重试");
			return false;
		}
		xmlHttp.abort();
		OpenMobile();
	}
}

function getMobileBindCell(tr, colname) {
	var headers = tr.parentNode.parentNode.rows[0].cells;
	for (var i = 0; i < headers.length; i++) {
		var h = headers[i].innerText.replace(/\s/g, "");
		if (colname == h) {
			return tr.cells[i];
		}
	}
	return null;
}

function saveBindEdit(frm,bdNum){		//保存修改的绑定信息
	var bindList = "";	//手机绑定信息
	var useBind = 1;
	var macsn = "";		//手机串号
	var phone = ""
	var actStr = "";
	var newList = "";
	var bindInfo = "";
	var arr_bdInfo = "";
	bindList = document.getElementById("bindList").value;
	var bdtr = document.getElementById("tr"+bdNum)
	var editindex = bdtr.rowIndex;
	var arr_bind = bindList.split("{^}");	
	if(frm.useBind[1].checked){
		useBind = 0;
	}
	macsn = trim(frm.macsn.value);
	phone = trim(frm.phone.value);
	for(i=1;i<arr_bind.length;i++){
		if(i == editindex){
			bindInfo = arr_bind[i-1];
			arr_bdInfo = bindInfo.split("[|]");
			arr_bdInfo[0] = arr_bdInfo[0].replace(arr_bdInfo[0],useBind);
			arr_bdInfo[1] = arr_bdInfo[1].replace(arr_bdInfo[1],macsn);
			arr_bdInfo[2] = arr_bdInfo[2].replace(arr_bdInfo[2],phone);
			newList = newList + arr_bdInfo.join("[|]");
		}else{
			newList = newList + arr_bind[i-1];
		}
		newList += "{^}";
	}
	bindList = newList;
	document.getElementById("bindList").value = bindList;
	var td0 = getMobileBindCell(bdtr, "手机串号");
	var td1 = getMobileBindCell(bdtr, "状态");
	var td2 = getMobileBindCell(bdtr, "备注");
	var td5 = getMobileBindCell(bdtr, "操作");
	if(useBind==0){
		td1.innerHTML = td1.innerHTML.replace("启用", "停用");
		td5.innerHTML = td5.innerHTML.replace("停用", "启用").replace("bindUse(" + bdNum + ",0)", "bindUse(" + bdNum + ",1)");
	} else if (useBind == 1) {
		td1.innerHTML = td1.innerHTML.replace("停用", "启用");
		td5.innerHTML = td5.innerHTML.replace("启用", "停用").replace("bindUse(" + bdNum + ",1)", "bindUse(" + bdNum + ",0)");
	}
	td0.innerHTML = macsn;
	td2.innerHTML = phone;
	$('#w').window('close');
	OpenMobile();
}


function bindUse(bdNum,use){		//启用或停用
	var toUse = 1;
	var myDate = new Date();
	var editTime = myDate.getFullYear() + "-" + (myDate.getMonth()+1) + "-" + myDate.getDate() + " " + myDate.getHours() + ":" + myDate.getMinutes() + ":" + myDate.getSeconds();
	if(use == 0){
		if(confirm("确定要停用吗？")){
			toUse = 0;
		}else{
			return;
		}
	}else if(use == 1){
		if(confirm("确定要启用吗？")){
			toUse = 1;
		}else{
			return;
		}
	}else if(use == 2){
		toUse = 0;
	}else if(use == 3){
		toUse = 1;
	}

	bdNum = Number(bdNum);
	var bindInfo = "";
	var arr_bdInfo = "";
	var newList = "";
	var bindList = document.getElementById("bindList").value;
	if(bindList!=""){
		var arr_bind = bindList.split("{^}");
		for(i=1;i<arr_bind.length;i++){
			if(i == bdNum){
				bindInfo = arr_bind[i-1];
				arr_bdInfo = bindInfo.split("[|]");
				arr_bdInfo.shift(); 
				arr_bdInfo.unshift(toUse);
				newList = newList + arr_bdInfo.join("[|]");
			}else{
				newList = newList + arr_bind[i-1];
			}
			newList += "{^}";
		}
	}
	document.getElementById("bindList").value = newList;
	var bdtr = document.getElementById("tr" + bdNum);


	var td1 = bdtr.cells[1].innerHTML;
	var td5 = bdtr.cells[5].innerHTML;
	if(toUse==0){
		bdtr.cells[1].innerHTML = td1.replace("启用","停用");
		bdtr.cells[5].innerHTML = td5.replace("停用","启用").replace("bindUse("+bdNum+",0)","bindUse("+bdNum+",1)");
	}else if(toUse==1){
		bdtr.cells[1].innerHTML = td1.replace("停用","启用");
		bdtr.cells[5].innerHTML = td5.replace("启用","停用").replace("bindUse("+bdNum+",1)","bindUse("+bdNum+",0)");
	}
	//bdtr.cells[5].children[0].disabled = toUse==0;
	//bdtr.cells[5].children[1].disabled = toUse==0;
	OpenMobile();
}

function delBind(bdNum){	//删除指定的手机绑定
	var newList = "";
	bdNum = Number(bdNum);
	if(bdNum>0){
		if(confirm("确定要删除吗？")){
			var bdlist = document.getElementById("bdlist");
			var delindex = document.getElementById("tr"+bdNum).rowIndex;
			bdlist.deleteRow(delindex);
			var bindList = document.getElementById("bindList").value;			
			if(bindList!=""){
				var arr_bind = bindList.split("{^}");
				arr_bind.remove((delindex-1));	//删除指定位置的数组元素
				newList = arr_bind.join("{^}");
			}
			document.getElementById("bindList").value = newList;
			//bindNum -= 1;
		}
		var arr_bind = bindList.split("{^}");
		if(arr_bind.length == 2){
			var newtr = bdlist.insertRow(1);
			newtr.className = "blue2";
			var cell = newtr.insertCell(0);
			cell.colSpan = 6;
			cell.height = 27
			cell.align = "center";
			cell.innerHTML="暂无绑定";
		}
	}
	OpenMobile();
}

//--自动切换移动登录是否启用
function OpenMobile(){
	var open = $('#bindMobile1').attr('checked') ? 1 : 0;
	AddGPS(open);
}

//--显示或隐藏GPS设置
function AddGPS(open){
	if (document.getElementById("spn_OpenGPS"))
	{
		if (open == 0)
		{
			document.getElementById("spn_OpenGPS").style.display = "none";
		}
		else
		{
			document.getElementById("spn_OpenGPS").style.display = "inline";
		}
	}
}

function SaveGPS(userid,open){
	url = "../Mobile/Macbind.asp?act=SaveGPS&userid="+userid+"&open="+open+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send(null); 
}	

function saveBindingOpen(ord,isOpen){
	$.ajax({
		url:'../Mobile/Macbind.asp?act=openBinding&ord=' + ord + '&isopen=' + isOpen,
		success:function(r){
			r = eval('(' + r + ')');
			if (!r.success){
				AddGPS(0);
				$('#bindMobile0').trigger('click');
				alert(r.msg);
			}
		}
	});
}

function saveOnlineOpen(ord, isOpen) {
	$.ajax({
		url: '../../SYSN/json/comm/AccountCommonApi.ashx?actionName=ChangeOnlineStatus&ord=' + ord + '&isopen=' + isOpen,
		success: function (r) {
			r = eval('(' + r + ')');
			if (r!=1) {
				$('#onlinesvr0').attr("checked", "checked");
				$("#onlinesvr1").attr("checked", false);
				alert('当前开启在线客服账号数已达到最大限制,不允许保存');
			}
		}
	});
}