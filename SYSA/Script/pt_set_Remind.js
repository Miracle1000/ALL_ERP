
function frameResize(){
	$ID("txFrame").style.height=(txFrame.document.getElementById("mxPos").offsetTop+30)+"px";
}

function changeTxType(){
	var txType = 1;
	if($ID("txType2").checked == true){
		txType = 2;
	}
	try{$('#w2').window('close');}catch(e){}
	if(txType == 1){		
		$ID("txFrame").src = "?__msgID=txBatFrame"
	}else if(txType == 2){		
		$ID("txFrame").src = "?__msgID=txCPFrame"
	}
	frameResize();
}

function chkTxrForm(itemID){		//选择受理人员窗口
	var TXUser = document.getElementById("TXUser");
	var txIdStr = ""
	if (itemID!=""){
		txIdStr = "_" + itemID
	}		
	txFrame.document.getElementById("txCate"+txIdStr).blur();
	var txCateid = txFrame.document.getElementById("RemindPerson"+txIdStr).value;
	$('#w2').window('open');
	document.getElementById("w2").style.display = "block";
	TXUser.innerHTML="loading...";
	$ID("itemID").value = itemID;
	ajax.regEvent("txUserList");
	$ap("userStr",txCateid)
	var r = ajax.send();
	if(r != ""){
		TXUser.innerHTML = r;
	}
}

function setTXUser(){		//设置受理人
	var member2 = "";
	var userid = "";
	var uid = "";
	try{
		var box = document.getElementsByName("member2")[0];
		member2 = box.getAttribute("text");
		userid = box.getAttribute("value");
	}catch(e){}
	if(userid == ""){
		app.Alert("请选择提醒人员");
		return false;
	}else{	
		var itemID = $ID("itemID").value;	
		var txIdStr = ""
		if (itemID!=""){
			txIdStr = "_" + itemID
		}
		txFrame.document.getElementById("txCate"+txIdStr).value = member2;
		txFrame.document.getElementById("RemindPerson"+txIdStr).value = userid;
		$('#w2').window('close');
		if(itemID!=""){
			txFrame.saveCPRemind(itemID,txFrame.document.getElementById("RemindPerson"+txIdStr));
		}
	}
		
}

function selectAll(){
	var nm = document.getElementsByName("member2")[0];
	var id = nm.id.replace("_w3","");
	var win = document.getElementById(id).contentWindow;
	var jtvw = win.TreeView.objects[0];
	win.TreeView.CheckAll(jtvw);
}

function selectFan(){
	var nm = document.getElementsByName("member2")[0];
	var id = nm.id.replace("_w3","");
	var win = document.getElementById(id).contentWindow;
	var jtvw = win.TreeView.objects[0];
	win.TreeView.CheckXOR(jtvw);
}
