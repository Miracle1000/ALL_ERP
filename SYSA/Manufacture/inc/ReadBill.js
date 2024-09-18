Bill.IsReadOnly = function(){}
loadevent = document.body.onload 
$(window).load(function(){
	if(loadevent) {loadevent();}
	var del = (document.getElementById("Bill_Info_del").value == "1")
	var html = ""
	var mSpan = document.getElementById("topmsg")
	if(!mSpan){return false}
	//if( window.opener){
		 var canLC = true //是否显示流程按钮
		 var canUp = true //是否显示修改按钮
		 switch(Bill.OrderId*1){
			case 23 : canUp = false ; break; //生产物料清单不允许修改
			case 24 : canUp = false ; break; //生产流程不允许修改
			default:
		 }
		 try{
			if(document.getElementById("Bill_Info_HasSpRank") && del==false && canUp == true){
					if( parseInt(document.getElementById("Bill_Info_HasSpRank").value)==0 && (!Bill.haschild2 || Bill.haschild2==0) )  
					{
						if (Bill.canupdate==1 )
						{
							 html = "<button class=button id='billupdatecmd' style='width:58px' onclick='window.location.href = window.location.href.replace(/ReadBill\\.asp/i,\"Bill.asp\")'>修改</button>&nbsp;" + html
						}
						document.getElementById("bcButton4").parentElement.style.display = "";
					}
					else{
						document.getElementById("bcButton4").parentElement.style.display = "none";
					}
			}
		 }catch(e){}
		 if(Bill.OrderId<1000 && canLC==true){	html = "<button class=button style='width:58px' onclick='Bill.ShowProcChart()'>流程<img src='../../images/smico/56.gif' style='display:none'></button>&nbsp;" + html }
	//}
	
	//添加订单状态
	var disButton = ",领料,补料,生产补料,"
	var ddnoStatus = document.getElementById("billBodyTable").innerHTML
	try{
		if(ddnoStatus.indexOf("sysmanuorderstatus2")>0){
			ddnoStatus = 2
		}
		else{
			if(ddnoStatus.indexOf("sysmanuorderstatus1")>0){
				ddnoStatus = 1
			}
			else{
				ddnoStatus = 0
			}
		}
		if(ddnoStatus!=0 && Bill.OrderId*1==4){
			for (var i=0;i<document.links.length ; i++)
			{
				var lk = document.links[i]
				if(lk.innerText == "添加派工单"){
					lk.innerText = "已停止派工"
					lk.href = "javascript:alert('订单已经" + (ddnoStatus==1 ? "完成" : "终止") + ",所以停止派工')";
					lk.target = ""
				}
			}
		}
	}catch(e){}
	//

	if(Bill.addSheetButton && ddnoStatus!=1) {
		for (var i = 0;i< Bill.addSheetButton.length ; i ++ )
		{
			if(ddnoStatus!=2 || disButton.indexOf("," + Bill.addSheetButton[i][0] + ",")<0){
				if(document.getElementById("Bill_Info_type")){
					html = "<button class='billcmdButton' onclick='window.open(\"bill.asp?orderid=" + Bill.addSheetButton[i][1] + "&ParentOrd=" + document.getElementById("Bill_Info_type").value + "&ParentTag=" + document.getElementById("Bill_Info_id").value + "\")'>"  + Bill.addSheetButton[i][0] + "</button>&nbsp;" + html
				}
			}
		}
	}
	if(Bill.otherSheetButton){
		for (var i = 0;i< Bill.otherSheetButton.length ; i ++ )
		{
			if(ddnoStatus==0  || disButton.indexOf("," + Bill.otherSheetButton[i][0] + ",")<0){
				if(Bill.otherSheetButton[i][1].indexOf("ajax:")==0) 
					html = "<button class='billcmdButton' onclick='Bill.AjaxUrl(\"" + Bill.otherSheetButton[i][1].replace("ajax:","") + "\")'>"  + Bill.otherSheetButton[i][0] + "</button>&nbsp;" + html
				else
					html = "<button class='billcmdButton' onclick='window.open(\"" + Bill.otherSheetButton[i][1] + "\")'>"  + Bill.otherSheetButton[i][0] + "</button>&nbsp;" + html
			}
		}
	}
	mSpan.innerHTML = html
	var buttons = mSpan.getElementsByTagName("button");

	for (var i=0;i<buttons.length ; i++)
	{
		if(buttons[i].offsetWidth<58)
		{
			buttons[i].style.width = "58px"  //按钮最小宽度为58px
		}
	}
})

Bill.AjaxUrl = function(url) {
	var x = new  xmlHttp();
	var t = x.getHttp();
	var tt = new Date();
	t.open("get",url + "&t=" + tt.getTime(),false);
	t.send();
	var r = t.responseText;
	try
	{
		eval(r);
	}
	catch(e){
		alert("返回结果：\n\n" + r)
	}
	t = null;
}

Bill.ShowProcChart = function(){
	ajax.regEvent("CProcChart")
	ajax.addParam("orderid",document.getElementById("Bill_Info_type").value)
	ajax.addParam("sheetid",document.getElementById("Bill_Info_id").value)
	r = ajax.send()
	var div = window.DivOpen("ProcChartDlg","业务流程图 - " + document.getElementById("billtitle").innerText,780,560,80,'a',true,10)
	div.innerHTML = "<div style='position:absolute;left:50px;top:60px'><img src='../../images/manuproc.gif'></div>"
}

window.onbeforeunload = function(){
	try{
		this.opener.ck.currRefresh(100);
	}catch(e){}
}
