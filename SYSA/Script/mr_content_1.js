
        function trim(str){return str.replace(/(^\s*)|(\s*$)/g, "");}
        
        function loadBinding(show){	//加载或隐藏添加移动绑定列表
			var mactr = document.getElementById("mactr");
            var macBinding = document.getElementById("macBinding");
			var url = "../Mobile/Macbind.asp";
			var postStr = "";
            if(show==1){
                postStr = "act=list&userid="+window.userid+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100); 
            }else if(show==0){
                postStr = "act=noUse&userid="+window.userid+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
            }
			//xmlHttp.open("GET", url, false);
			xmlHttp.open("POST", url, true);  
			xmlHttp.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
			xmlHttp.send(postStr);
			xmlHttp.onreadystatechange = function(){
				if (xmlHttp.readyState < 4) {
					macBinding.innerHTML="loading...";
				}
				if (xmlHttp.readyState == 4) {
					var response = xmlHttp.responseText;
					if(response=="20"){
						//mactr.style.display = "none";							
						alert("请输入数字签名!");
						document.getElementById("bindMobile0").checked = true;
						return;
					}else if(response=="21"){
						//mactr.style.display = "none";
						alert("您的账号还不支持移动端绑定!");
						document.getElementById("bindMobile0").checked = true;
						return;
					}else if(response=="22"){
						//mactr.style.display = "none";
						alert("移动端用户数已到最大限制");
						document.getElementById("bindMobile0").checked = true;
						return;
					}else{
						macBinding.innerHTML=response;
					} 
					if (parent.frameResize)
					{
						parent.frameResize();
					}
					xmlHttp.abort();
					AddGPS(show);
				}
			};
			xmlHttp.send(null);
        }
		
		
		function addBinding(bindord){		//加载添加移动绑定			
			var editBind = "";
			editBind = document.getElementById("editBind");
			var url = "";
			if(bindord == ""){		//如果bdNum为空则 添加
				url = "../Mobile/Macbind.asp?act=add&userid="+window.userid+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			}else if(bindord != ""){	//如果bdNum不为空则 修改
				url = "../Mobile/Macbind.asp?act=add2&userid="+window.userid+"&ord="+bindord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			}
			$("#w").window("open");
			document.getElementById("w").style.display = "block";
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
				if (xmlHttp.readyState < 4) {
					editBind.innerHTML="loading...";
				}
				if (xmlHttp.readyState == 4) {
					var response = xmlHttp.responseText;
					editBind.innerHTML=response;
					xmlHttp.abort();
					OpenMobile();
				}
			};
			xmlHttp.send(null); 
		}
		
		function saveBind(frm,bindord){
			if(bindord!=""){
				saveBindEdit(frm,bindord);
			}else{
				saveBindAdd(frm)
			}
		}
		
		function saveBindAdd(frm){		//添加修改的绑定信息
			var bindNum = 0;	//手机绑定数量
			var useBind = 1;
			var macsn = "";		//手机串号
			var phone = ""
			var actStr = "";
			var userid = "";			
			bindNum = Number(document.getElementById("bindNum").value);			
			if(bindNum>=3){
				alert("您为该账号绑定的手机数已达上限");
				return;
			}
			var myDate = new Date();
			var addTime = myDate.getFullYear() + "-" + (myDate.getMonth()+1) + "-" + myDate.getDate() + " " + myDate.getHours() + ":" + myDate.getMinutes() + ":" + myDate.getSeconds();
			if(frm.useBind[1].checked){
				useBind = 0;
			}
			macsn = trim(frm.macsn.value);
			phone = trim(frm.phone.value);
			userid = trim(frm.userid.value);
			url = "../Mobile/Macbind.asp?act=save&userid="+userid+"&useBind="+useBind+"&macsn="+macsn+"&phone="+phone+"&addTime="+addTime+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
				if (xmlHttp.readyState == 4) {
					var response = xmlHttp.responseText;
					var arr_res = response.split("|");
					if(arr_res[0]=="20"){
						alert("请输入数字签名!");
						return;
					}else if(arr_res[0]=="21"){
						alert("您的账号还不支持移动端绑定!");				
						return;
					}else if(arr_res[0]=="22"){
						alert("移动端用户数已到最大限制");				
						return;
					}else if(arr_res[0]=="3"){
						alert("您为该账号绑定的手机数已达上限");
						return;
					}else if(arr_res[0]=="4"){
						if (arr_res[1]=="{-/-自己-/-}") {	 //对是否是对当前账号添加的手机串号重复的判断提示
							alert("您已添加手机串号【"+macsn+"】，请不要重复绑定");
						}else{
							alert("该手机串号已给【"+arr_res[1]+"】绑定，请不要重复绑定");
						}						
						return;
					}else if(arr_res[0]=="1"){
						bindNum += 1;
						var bindord = arr_res[1];
						var countCell=bdlist.rows.item(0).cells.length; 
						var countCell2=bdlist.rows.item(1).cells.length;
						if(countCell2==1){
							bdlist.deleteRow(1);
						}
						var newtr = bdlist.insertRow(1);
						newtr.id = "tr"+bindord;
						newtr.className = "blue2";
						newtr.style.textAlign = "center";
						for(i=0;i<countCell;i++){
							var cell = newtr.insertCell(i);
							cell.height = 27;
							if(i==0){
								cell.innerHTML=addTime;
							}else if(i==1){
								cell.innerHTML=macsn;
							}else if(i==2){
								if(useBind==1){
									cell.innerHTML="启用";
								}else{
									cell.innerHTML="停用";
								}
							}else if(i==3){
								cell.innerHTML=window.adminor;
							}else if(i==4){
								cell.innerHTML=addTime;
							}else if(i==7){
								cell.innerHTML=phone;
							}else if(i==8){
								actStr = "";
								if(useBind==1){
									actStr += "<input type='button' value='停用' class='anybutton' onClick='bindUse("+bindord+",0)'>";
								}else{
									actStr += "<input type='button' value='启用' class='anybutton' onClick='bindUse("+bindord+",1)'>";
								}
								actStr += "<input type='button' value='修改' class='anybutton' onClick='addBinding("+bindord+")'>";
								if(window.isSupperAdminor == 1){
								actStr += "<input type='button' value='删除' class='anybutton' onClick='delBind("+bindord+")'>";
								}
								cell.innerHTML=actStr;
							}
						}
						$('#w').window('close');						
						document.getElementById("bindNum").value = bindNum;
					}else{
						alert("数据保存异常");
						return;
					}
					xmlHttp.abort();
					OpenMobile();
				}
			};
			xmlHttp.send(null); 	
		}
		
		function saveBindEdit(frm,bindord){		//保存修改的绑定信息
			var bindNum = 0;	//手机绑定数量
			var useBind = 1;
			var macsn = "";		//手机串号
			var phone = ""
			var userid = trim(frm.userid.value);
			bindNum = document.getElementById("bindNum").value;
			var bdtr = document.getElementById("tr"+bindord)
			var editindex = bdtr.rowIndex;
			if(frm.useBind[1].checked){
				useBind = 0;
			}
			macsn = trim(frm.macsn.value);
			phone = trim(frm.phone.value);
			url = "../Mobile/Macbind.asp?act=save&userid="+userid+"&ord="+bindord+"&useBind="+useBind+"&macsn="+macsn+"&phone="+phone+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
				if (xmlHttp.readyState == 4) {
					var response = xmlHttp.responseText;
					var arr_res = response.split("|");
					if(arr_res[0]=="20"){
						alert("请输入数字签名!");
						return;
					}else if(arr_res[0]=="21"){
						alert("您的账号还不支持移动端绑定!");				
						return;
					}else if(arr_res[0]=="22"){
						alert("移动端用户数已到最大限制");
						frm.useBind[1].checked = true;
						return;
					}else if(arr_res[0]=="3"){
						alert("您为该账号绑定的手机数已达上限");
						return;
					}else if(arr_res[0]=="4"){
						if (arr_res[1]=="{-/-自己-/-}") {	 //对是否是对当前账号添加的手机串号重复的判断提示
							alert("您已添加手机串号【"+macsn+"】，请不要重复绑定");
						}else{
							alert("该手机串号已给【"+arr_res[1]+"】绑定，请不要重复绑定");
						}
						return;
					}if(arr_res[0]=="4"){
						alert("该手机串号已绑定，请不要重复绑定");
						return;
					}else if(arr_res[0]=="1"){
						var td0 = bdtr.cells[0].innerHTML;
						var td1 = bdtr.cells[1].innerHTML;
						var td2 = bdtr.cells[2].innerHTML;
						var td7 = bdtr.cells[7].innerHTML;
						var td8 = bdtr.cells[8].innerHTML;
						if(useBind==0){
							bdtr.cells[2].innerHTML = td2.replace("启用","停用");
							bdtr.cells[8].innerHTML = td8.replace("停用","启用").replace("bindUse("+bindord+",0)","bindUse("+bindord+",1)");
							if(arr_res[1]!=""){bdtr.cells[0].innerHTML = td0.replace(td0,arr_res[1]);}
							bdtr.cells[1].innerHTML = td1.replace(td1,macsn);
							bdtr.cells[7].innerHTML = td7.replace(td7,phone);
						}else if(useBind==1){
							bdtr.cells[2].innerHTML = td2.replace("停用","启用");
							bdtr.cells[8].innerHTML = td8.replace("启用","停用").replace("bindUse("+bindord+",1)","bindUse("+bindord+",0)");
							if(arr_res[1]!=""){bdtr.cells[0].innerHTML = td0.replace(td0,arr_res[1]);}
							bdtr.cells[1].innerHTML = td1.replace(td1,macsn);
							bdtr.cells[7].innerHTML = td7.replace(td7,phone);
						}else{
							alert("数据保存异常，请刷新后重试");	
							return;
						}
						$('#w').window('close');						
					}
					xmlHttp.abort();
					OpenMobile();
				}
			};
			xmlHttp.send(null); 	
		}
		
		
		function bindUse(bindord,use){		//启用或停用
			var useBind = 1;
			if(use == 0){
				if(confirm("确定要停用吗？")){
					useBind = 0;
				}else{
					return;
				}
			}else if(use == 1){
				if(confirm("确定要启用吗？")){
					useBind = 1;
				}else{
					return;
				}
			}
			var bdtr = document.getElementById("tr"+bindord)
			url = "../Mobile/Macbind.asp?act=bindUse&ord="+bindord+"&useBind="+useBind+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
				if (xmlHttp.readyState == 4) {
					var response = xmlHttp.responseText;
					var arr_res = response.split("|");
					if(arr_res[0]=="20"){
						alert("请输入数字签名!");
						return;
					}else if(arr_res[0]=="21"){
						alert("您的账号还不支持移动端绑定!");				
						return;
					}else if(arr_res[0]=="22"){
						alert("移动端用户数已到最大限制");
						return;
					}if(arr_res[0]=="0"){
						alert("没有这条绑定记录，请刷新后重试");
						return;
					}else if(arr_res[0]=="1"){
						var td0 = bdtr.cells[0].innerHTML;
						var td2 = bdtr.cells[2].innerHTML;
						var td8 = bdtr.cells[8].innerHTML;
						if(useBind==0){
							bdtr.cells[2].innerHTML = td2.replace("启用","停用");
							bdtr.cells[8].innerHTML = td8.replace("停用","启用").replace("bindUse("+bindord+",0)","bindUse("+bindord+",1)");
							if(arr_res[1]!=""){bdtr.cells[0].innerHTML = td0.replace(td0,arr_res[1]);}
						}else if(useBind==1){
							bdtr.cells[2].innerHTML = td2.replace("停用","启用");
							bdtr.cells[8].innerHTML = td8.replace("启用","停用").replace("bindUse("+bindord+",1)","bindUse("+bindord+",0)");
							if(arr_res[1]!=""){bdtr.cells[0].innerHTML = td0.replace(td0,arr_res[1]);}
						}
					}
					xmlHttp.abort();
					OpenMobile();
				}
			};
			xmlHttp.send(null); 	
		}
		
		
		function delBind(bindord){	//删除指定的手机绑定
			var bindNum = 0;	//手机绑定数量
			bindNum = Number(document.getElementById("bindNum").value);	
			bindord = Number(bindord);
			if(bindord>0){
				if(confirm("确定要删除吗？")){
					url = "../Mobile/Macbind.asp?act=del&ord="+bindord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
					xmlHttp.open("GET", url, false);
					xmlHttp.onreadystatechange = function(){
						if (xmlHttp.readyState == 4) {
							var response = xmlHttp.responseText;
							if(response=="0"){
								alert("没有这条绑定记录，请刷新后重试");
								return;
							}else if(response=="1"){
								var delindex = document.getElementById("tr"+bindord).rowIndex;
								bdlist.deleteRow(delindex);								
								bindNum -= 1;
								document.getElementById("bindNum").value = bindNum;
								if(bindNum <= 0){
									var newtr = bdlist.insertRow(1);
									newtr.className = "blue2";
									var cell = newtr.insertCell(0);
									cell.colSpan = 9;
									cell.height = 27
									cell.align = "center";
									cell.innerHTML="暂无绑定";
								}
							}
							xmlHttp.abort();
							OpenMobile();
						}
					};
					xmlHttp.send(null); 	
				}
			}
		}
		
//--自动切换移动登录是否启用
function OpenMobile(){
	var tb = document.getElementById("bdlist");
	var open = 0;
	if (tb)
	{
		for (var i = 1; i < tb.rows.length; i++)
		{
			if (tb.rows[i].cells[2] && tb.rows[i].cells[2].innerHTML == "启用")
			{
				open = 1;
			}
		}
	}
	if (open == 0)
	{
		document.getElementById("bindMobile0").checked = true;
		document.getElementById("bindMobile1").checked = false;
	}
	else
	{
		document.getElementById("bindMobile0").checked = false;
		document.getElementById("bindMobile1").checked = true;
	}
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
function saveOnlineOpen(ord, isOpen) {
	$.ajax({
		url: '../../SYSN/json/comm/AccountCommonApi.ashx?actionName=ChangeOnlineStatus&ord=' + ord + '&isopen=' + isOpen,
		success: function (r) {
			r = eval('(' + r + ')');
			if (r != 1) {
				$('#onlinesvr0').click();
				alert('当前开启在线客服账号数已达到最大限制,不允许保存');
			}
		}
	});
}