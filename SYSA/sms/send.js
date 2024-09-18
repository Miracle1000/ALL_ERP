var dohide  = false
function loadchancelInfo(){
	var sbox = document.getElementById("chancelList");
	if(sbox){
		ajax.regEvent("getchanceInfo");
		ajax.addParam("ord",sbox.value);
		ajax.exec();
		smsbodychange();
		if(document.getElementById("canlong").checked)
		{
			document.getElementById("smscharinfo").innerHTML = "<b class=r>" + document.getElementById("maxbits").value + "</b>字/长短信&nbsp;<b class=r>" + (document.getElementById("unitbits").value-document.getElementById("longsignbits").value) + "</b>字/短信&nbsp;"
		}
		else{
			document.getElementById("smscharinfo").innerHTML = "<b class=r>" + (document.getElementById("unitbits").value-document.getElementById("signbits").value) + "</b>字/条&nbsp;&nbsp;&nbsp;"
		}
	}
}
function SetSpInfo(nm,v){
	switch(nm){
		case "telnum":
			document.getElementById(nm).innerText = v;
			break;
		case "sendprice":
			document.getElementById(nm).innerText = v*1;
			break;
		case "canlong":
			document.getElementById(nm).checked = (v=="1");
			document.getElementById("usedlong").disabled =(v=="0");
			break;
		case "canrec":
			document.getElementById(nm).checked = (v=="1");
			break;
		case "maxbits":
			document.getElementById(nm).value = v;
			break;
		case "unitbits":
			document.getElementById(nm).value = v;
			break;
		case "signbits":
			document.getElementById(nm).value = v;
			break;
		case "longsignbits":
			document.getElementById(nm).value = v;
			break;
	}
}

parent.addItemPhone = function(tel, ndel){
	tel = tel.split(",")
	var v = document.getElementById("tels").value;
	var ts = "," + v + ","
	for(var i = 0 ; i< tel.length;i++)
	{	
		if(ts.indexOf("," + tel[i] + ",")<0)
		{
			v = v + (v.length>0 ? "," : "") + tel[i];
		}
		else{
			if(ndel!=1)
			{
				v = ("," + v + ",").replace("," + tel[i] + ",",",") 
			}
		}
	}
	document.getElementById("tels").value = ("|" + v + "|").replace("|,","").replace(",|","").replace(/\|/g,"");
}

function telsChange(newtels){
	var tbox = document.getElementById("tels");
	if(!tbox){return}
	if(tbox.lock==1) { return; }
	var new_tels = newtels.replace(/[^0123456789\;\,\.\s；，]/g,"").replace(/[\;\.\s；，]/g,",");
	var espchr = (new_tels.length > 1 && new_tels.substr(new_tels.length-1,1)==",")
	var arr = new_tels.split(",")
	var narr = new Array();
	for (var i=0;i< arr.length;i++ )
	{
		if(arr[i].length>0){
			narr[narr.length] = arr[i];
		}
	}
	new_tels = narr.join(",") + (espchr? "," : "")
	document.getElementById("telnummsg").innerText = "共" + narr.length + "个号码";
	if(parent.telstatuschange){
		if(new_tels!=parent.currtels){
			parent.currtels = new_tels;
			parent.telstatuschange();
		}
	}
	if(new_tels!=newtels){
		
		tbox.lock = 1;
		tbox.value = new_tels;
		tbox.lock = 0;
	}
}

function drlxr(){
	var div = window.DivOpen("lvw_drExcel","导入号码",450,160,100,'a',false,20,true)
	div.innerHTML ='<iframe name="I3" width="100%" id="mxlist" src="../load/UpLoad_mobil.asp" border="0" frameBorder="0" marginWidth="0" marginHeight="0" scrolling="no" style="height: 39px;" target="_self">'
}

window.abc = function(tel){
	parent.addItemPhone(tel)
}

function showmvpanel(){
	var mbn = document.getElementById("mbutton")
	mbn.style.borderRight= "0px"
	document.getElementById("mpanel").style.display = "block";
}

function delrepeat(){
	var v = document.getElementById("tels").value.split(",");
	var nv = new Array();
	v.sort();
	if(v[0].length>0) { nv[0] = v[0] };
	for(var i = 1 ; i < v.length;i++){
		if(v[i]!=v[i-1])
		{
			if(v[i].length>0)
			{
				nv[nv.length] = v[i];
			}
		}
	}
	document.getElementById("tels").value = nv.join(",");
}

function cleartels(){
	document.getElementById("tels").value = "";
}

function smsbodychange(){
	var svt = document.getElementById("surname1").checked ? "共" : "<b style='color:blue'>约</b>";
	var maxb = document.getElementById("maxbits").value;
	var txt = document.getElementById("smsbody").value;
	var canlong =document.getElementById("canlong").checked;
	var usedlong  =  document.getElementById("usedlong").checked;
	var unitbits = document.getElementById("unitbits").value;
	if(canlong && usedlong) {
		var lsBit = document.getElementById("longsignbits").value; //长短信占位符
		var ulbit = (unitbits - lsBit); // 长短信单位长度
		var ulsmscount = parseInt(maxb / ulbit) + (maxb % ulbit>0?1:0) ; //每条长短信含短信数量
		var lcount = parseInt(txt.length/maxb) + ((txt.length%maxb>0)?1:0); // 长短信的数量
		var sychar = txt.length - maxb*(lcount-1);
		var smscount = ulsmscount*(lcount-1) + parseInt(sychar/ulbit) + (sychar%ulbit>0?1:0); //合计短信数量
		document.getElementById("bodymsg").innerHTML = svt + "<b>" + txt.length + "</b>字,<b style='" + (lcount>1?"color:red":"") + "'>" + lcount + "</b>条长短信,折合<b  style='" + (smscount>1?"color:red":"") + "'>" + smscount + "</b>条短信费用。"
	}
	else{
		var splitBit = document.getElementById("signbits").value; //普通短信占位
		var ucbit = (unitbits - splitBit); // 短信单位长度
		var smscount = parseInt(txt.length/ucbit) + (txt.length%ucbit>0?1:0); //合计短信数量
		document.getElementById("bodymsg").innerHTML = svt +"共<b>" + txt.length + "</b>字,折合<b  style='" + (smscount>1?"color:red":"") + "'>" + smscount + "</b>条短信费用。"
	}
	
}

function clearsmsbody(){
	document.getElementById("smsbody").value = "";
}

function addmodelbody(a){
	var txt = document.getElementById("smsbody").value;
	var sign = "\r\n" + document.getElementById("csignvalue").value;
	if(document.getElementById("csign2").checked) //启用签名
	{
		var txt = (txt + "$$$#%$!")
		txt = (txt.replace(sign + "$$$#%$!","").replace("$$$#%$!","")) + a.innerText + sign;
		document.getElementById("smsbody").value = txt;
	}
	else
	{
		document.getElementById("smsbody").value = txt + a.innerText;
	}
}

function cmessagemodel(ord){
	ajax.regEvent("smsmodelchange");
	ajax.addParam("cls",ord);
	document.getElementById("mdlistbody").innerHTML = ajax.send();
	ListViewInit();
}

function surnamechange(v){ //尊称更改
	var box = document.getElementById("surnamevalue");
	box.value = v;
	var zc = ""
	switch(v){
		case 0 : document.getElementById("surnamesmp").innerText = "";break;
		case 1 : document.getElementById("surnamesmp").innerText = "例：尊敬的赵先生/小姐";zc = "尊敬的***：";break;
		case 2 : document.getElementById("surnamesmp").innerText = "例：尊敬的赵经理/主管";zc = "尊敬的***：";break;
		case 3 : document.getElementById("surnamesmp").innerText = "例：尊敬的赵XX";zc = "尊敬的***：";break;
		case 4 : document.getElementById("surnamesmp").innerText = "例：尊敬的赵XX经理/主管";zc = "尊敬的*****：";break;
	}
	var txt = document.getElementById("smsbody").value;
	txt = txt.replace("尊敬的*****：","");
	txt = txt.replace("尊敬的***：","");
	document.getElementById("smsbody").value = zc + txt;
	document.getElementById("surnamevalue").value = v;
}

function stimerchange(v){
	document.getElementById("sendtimerbg").style.display = (v==0 ? "none" : "inline");
}

function csignbodychange(){
	var sign = "\r\n" + document.getElementById("csignvalue").oldv;
	var txt = document.getElementById("smsbody").value;
	document.getElementById("smsbody").value = (txt + "$$$#%$!").replace(sign + "$$$#%$!","").replace("$$$#%$!","");
	document.getElementById("csignvalue").oldv = document.getElementById("csignvalue").value;
	csignchange(1);
}

function csignchange(v){
	var txt = document.getElementById("smsbody").value;
	var sign = "\r\n" + document.getElementById("csignvalue").value;
	document.getElementById("csignbg").style.display = (v==0 ? "none" : "inline");
	if(document.getElementById("csign1").checked) //不启用
	{
		document.getElementById("smsbody").value = (txt + "$$$#%$!").replace(sign + "$$$#%$!","").replace("$$$#%$!","")
	}
	else
	{
		if((txt + "$$$#%$!").indexOf(sign + "$$$#%$!")<0)
		{
			document.getElementById("smsbody").value = txt + sign;
		}
	}
}

function docancel(){
	document.getElementById("smsbody").value = "";
	document.getElementById("tels").value = "";
	document.getElementById("surname1").checked = true;
	surnamechange(0)
	document.getElementById("stimer1").checked = true;
	stimerchange(0)
	document.getElementById("csign1").checked = true;
	csignchange(0)
}

parent.showMoneyError = function(r){
	var div = DivOpen("ssdasd","账户余额",640,420,40,"a");
	div.innerHTML = "<iframe src='?__msgid=showmoneyerror' style='width:100%;height:100%' frameborder=0 ></iframe>";
}

//第1步，初始化分批提交海量手机号
function doSend()
{
	if(document.getElementById("smsbody").value.length>1000){
		showerr("发送内容超长，一次不超过1000字");
		return;
	}
	
	if(document.getElementById("smsbody").value.length==0){
		showerr("请输入短信内容");
		return;
	}

	window.willsendtelArray = document.getElementById("tels").value.split(",");
	window.willsendIndex = 0;
	if(window.willsendtelArray.length==0){
		showerr("请输入手机号");
		return;
	}
	window.showprocdiv = window.DivOpen("xadssd","提交数据",400,120,'a','b',true,15)
	InitunloadNumData(0);//开始分批提交手机号	
}

//第2步，分批提交海量手机号
function InitunloadNumData(xlh)		//xlh是提交的批次号，同一用户不重复
{
	if(isNaN(xlh)){
		window.showprocdiv.innerHTML = r;
		return;
	}
	if(window.willsendIndex >= window.willsendtelArray.length)
	{
		InitunloadsmsBody(xlh);	//跳入第2步骤，号码上传完毕，准备上传短信内容
	}
	else{
		var nindex =  window.willsendIndex + 5 //199; //一次提交200个手机号 
		if(nindex>window.willsendtelArray.length-1)
		{
			nindex = window.willsendtelArray.length;
		}
		var dat = window.willsendtelArray.slice(window.willsendIndex,nindex).join(",")
		window.willsendIndex = nindex ;
		var curr = nindex ;
		var all = window.willsendtelArray.length;
		window.showprocdiv = window.DivOpen("xadssd","发送状态",400,120,'a','b',true,15)
		window.showprocdiv.innerHTML = "<div style='padding:20px;'><table><tr><td style='color:#0000ee'>正在上传号码:&nbsp;</td><td>" 
					  + "<div style='position:relative;top:-1px;width:180px;border:1px solid #0000ee;height:9px'>" 
					  + "<div style='background-color:#0000ee;height:100%;width:" + (all>0? parseInt(curr*180/all) : 0) + "px;'></div>" 
					  + "</div></td><td>(" + (all>0? parseInt(curr*100/all) : 0) + "%)</td></tr></table></div>";
		ajax.regEvent("InitunloadNumData")
		ajax.addParam("data",dat)
		ajax.addParam("xlh",xlh)
		ajax.send(InitunloadNumData)
	}
}

//第3步，提交短信内容
function InitunloadsmsBody(xlh){	//xlh表示短信提交的手机批次号 
	window.showprocdiv = window.DivOpen("xadssd","发送状态",400,120,'a','b',true,15)
	window.showprocdiv.innerHTML = "<div style='padding:20px;color:#0000ee'>正在上传短信内容，请稍后</span>"
	ajax.regEvent("SendSMS");
	ajax.addParam("xlh",xlh);
	ajax.addParam("chancel",document.getElementById("chancelList").value);		//通道号
	ajax.addParam("smsbody",document.getElementById("smsbody").value);			//短信内容
	ajax.addParam("sp_contract_Ord",document.getElementById("sp_contract_Ord").value);	//审批ID
	ajax.addParam("curname",document.getElementById("surnamevalue").value);		//尊称方式
	ajax.addParam("timerSend",document.getElementById("stimer2").checked?1:0);	//定时发送时间
	ajax.addParam("stimervalue",document.getElementById("stimervalue").value);	//定时时间
	ajax.addParam("canlong",document.getElementById("usedlong").checked && !document.getElementById("usedlong").disabled ? 1 : 0);	//长短信模式
	ajax.addParam("needrec",document.getElementById("needrec").value);			//是否需要回复
	ajax.addParam("surname",document.getElementById("surnamevalue").value);	
	window.hideproc  = false //前台处理
	ajax.send(sendhandle);
}

//第4步，初始化zbintelserver后台定时发送
function sendhandle(r){
	if (isNaN(r))
	{
		window.showprocdiv = window.DivOpen("xadssd","发送状态",400,120,'a','b',true,15)
		window.showprocdiv.innerHTML = "<div style='padding:20px;color:red'>上传短信内容失败：" + r + "</span>"
	}
	else{
		dohide = false;
		clientSendProc(r,0,0); //检测发送进度
	}
}

//第5步-01，前台监视发送进度
function clientSendProc(xlh,all,curr){
	if(dohide==true) { //手动切换到后台执行
		docancel();
		return;
	}
	window.showprocdiv = window.DivOpen("xadssd","发送状态",400,120,'a','b',true,15)
	if (all==0 && curr==0)
	{	
		window.showprocdiv.innerHTML = "<div style='padding:20px;color:#0000ee'>准备发送，请稍后...</span>"
	}
	else
	{
		if(all<=curr)
		{
			window.showprocdiv.innerHTML = "<div style='padding:20px;color:#00aa00'>发送完成</span>"
			docancel();
			return;
		}
		else
		{
			window.showprocdiv.innerHTML = "<div style='padding:20px;'><table><tr><td style='color:#0000ee'>正在发送, 进度:&nbsp;</td><td>" 
			  + "<div style='position:relative;top:-1px;width:180px;border:1px solid #007700;height:9px'>" 
			  + "<div style='background-color:#007700;height:100%;width:" + (all>0? parseInt(curr*180/all) : 0) + "px;'></div>" 
			  + "</div></td><td>(" + (all>0? parseInt(curr*100/all) : 0) + "%)</td></tr><tr><td colspan=3 style='padding-top:4px;text-align:right'><a href=### style='color:blue' onclick='CHidePro(" + xlh + ")'>转到后台发送</a>&nbsp;&nbsp;</td></tr></table></div>"
		}
	}
	ajax.regEvent("clientSendProc");
	ajax.addParam("xlh",xlh);
	ajax.send(clientSendProchandle)
}

//第5步-02，接收发送进度
function clientSendProchandle(r)
{

	if(r.indexOf("错误")>=0 || r.indexOf("\1") < 0)
	{
		showerr(r);
	}
	else
	{
		r = r.split("\1")
		if(r.length!=3) 
		{
			showerr(r);
		}
		else
		{
			setTimeout("clientSendProc(" + r[0] + "," + r[1] + "," + r[2] + ");",300);
		}
	}
}

//第6步，取消监听
function CHidePro(xlh)  //后台处理
{
	dohide = true;
	window.DivClose(window.showprocdiv)
}

function showerr(err){
	window.showprocdiv = window.DivOpen("xadssd","发送状态",400,120,'a','b',true,15)
	window.showprocdiv.innerHTML = "<div style='padding:20px;color:red'>" + err + "</span>"
	return
}