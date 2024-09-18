
function test()
{
  if(!confirm('确认删除吗？')) return false;
}
 
function mm(form) 
{
	for (var i=0;i<form.elements.length;i++)
	{
		var e = form.elements[i]; 
		if (e.name != 'chkall') 
		e.checked = form.chkall.checked; 
	} 
}

function trim(str){return str.replace(/(^\s*)|(\s*$)/g, "");}

function addBinding(bindord,userid){		//加载添加移动绑定
	$('#w').window('open');
	var editBind = document.getElementById("editBind");
	var url = "";
	if(bindord == ""){		//如果bdNum为空则 添加
		url = "../Mobile/Macbind.asp?act=add&user=need&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	}else if(bindord != ""){	//如果bdNum不为空则 修改
		url = "../Mobile/Macbind.asp?act=add2&user=need&userid="+userid+"&ord="+bindord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	}
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
	var url = "../Mobile/Macbind.asp?act=save&userid="+userid+"&useBind="+useBind+"&macsn="+macsn+"&phone="+phone+"&addTime="+addTime+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
				window.location.reload();
			}else{
				alert("数据保存异常");	
				return;
			}
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null); 	
}

function checkBindNum(userid){
	if(userid==""){
		document.getElementById("bindNum").value = 0;
	}else{
		url = "../Mobile/Macbind.asp?act=getBindNum&userid="+userid+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function(){
			if (xmlHttp.readyState == 4) {
				var response = Number(xmlHttp.responseText);
				if(response>=0){
					document.getElementById("bindNum").value = response;
				}else{
					document.getElementById("bindNum").value = 0;
				}
				xmlHttp.abort();
			}
		};
		xmlHttp.send(null); 	
	}
}

function saveBindEdit(frm,bindord){		//保存修改的绑定信息
	var bindNum = 0;	//手机绑定数量
	var useBind = 1;
	var macsn = "";		//手机串号
	var phone = ""
	var userid = trim(frm.userid.value);
	if(frm.useBind[1].checked){
		useBind = 0;
	}
	macsn = trim(frm.macsn.value);
	phone = trim(frm.phone.value);
	var url = "../Mobile/Macbind.asp?act=save&userid="+userid+"&ord="+bindord+"&useBind="+useBind+"&macsn="+macsn+"&phone="+phone+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
			}else if(arr_res[0]=="1"){
				window.location.reload();	
			}else{
				alert("绑定记录不存在，请刷新后重试");	
				return;
			}
			xmlHttp.abort();
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
				window.location.reload();
			}
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null); 	
}

function delBind(bindord){	//删除指定的手机绑定
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
						window.location.reload();
					}
					xmlHttp.abort();
				}
			};
			xmlHttp.send(null); 	
		}
	}
}

function delBind_bat(){	//批量删除指定的手机绑定
	var selectid = "";
	if(typeof(document.form1.selectid.length)=="undefined"){
		if(document.form1.selectid.checked==true){
			selectid = document.form1.selectid.value;
		}
	}else{
		for(i=0;i<document.form1.selectid.length;i++){
			if(document.form1.selectid[i].checked==true){
				selectid += document.form1.selectid[i].value+",";
			}
		}
	}
	if(selectid == ""){
		alert("请选择需删除的绑定记录");
		return false;
	}else{		
		if(confirm("确定要删除吗？")){
			if(selectid.indexOf(",")==-1){
				selectid = selectid;
			}else{
				selectid = selectid.substr(0,selectid.length-1);
			}
			if(selectid!=""){
				url = "../Mobile/Macbind.asp?act=del&ord="+selectid+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
				xmlHttp.open("GET", url, false);
				xmlHttp.onreadystatechange = function(){
					if (xmlHttp.readyState == 4) {
						var response = xmlHttp.responseText;
						if(response=="0"){
							alert("所选绑定记录不存在，请刷新后重试");
							return;
						}else if(response=="1"){
							window.location.reload();
						}
						xmlHttp.abort();
					}
				};
				xmlHttp.send(null); 
			}
		}else{
			return false;
		}
	}
}

function selectUser(){
	var bindUser = document.getElementById("bindUser");
	$('#w2').window('open');
	document.getElementById("w2").style.display = "block";
	url = "../Mobile/Macbind.asp?act=selectUser&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState < 4) {
			bindUser.innerHTML="loading...";
		}
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			bindUser.innerHTML=response;
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null); 
}

function chanceR(){
	var frm = document.secuser;
	var member2 = "";
	var userid = "";
	if(typeof(frm.member2.length)=="undefined"){
		if(frm.member2.checked==true){
			member2 = frm.member2.value;
			userid = frm.member2.id;
			userid = userid.replace("member2_","");
		}
	}else{
		for(i=0;i<frm.member2.length;i++){
			if(frm.member2[i].checked==true){
				member2 = frm.member2[i].value;
				userid = frm.member2[i].id;
				userid = userid.replace("member2_","");
				break;
			}
		}
	}
	if(userid == ""){
		alert("请选择需绑定的用户");
		return false;
	}else{		
		document.getElementById("bduser").value = member2;
		document.getElementById("userid").value = userid;
		checkBindNum(userid);
		$('#w2').window('close');
	}
}

