//审批流程设置自定义文件
var timer = null
var baseBillAdd = null;


document.write("<style>span.spitem{padding:3px;border:1px solid white;color:#006600;display:inline-block;height:12px;} span.spitemOndel{display:inline-block;padding:3px;border:1px solid #fe5555;color:#006600;height:12px;cursor:pointer;background-color:#ffffff;filter:wave(strength=0,freq=1,lightstrength=8,phase=0);}</style>")

window.spInit = function(){ //审批单据初始化
	if(baseBillAdd==null){
		baseBillAdd = Bill.AddBill;
		Bill.AddBill = function(id){
			baseBillAdd(id);
			spInit();
		}
	}
	window.handSpIDList();
}


window.handSpIDList = function(){
	var tabs = document.getElementsByTagName("table")
	var list = null;
	for (var i = 0 ; i<tabs.length ; i++)
	{
		if(tabs[i].getAttribute("canadd")=="1"){
			var list = tabs[i];
			break;
		}
	}
	if(list){
		document.getElementById("refreshdetailtd").style.display = "none"
		for (var i = 1; i < list.rows.length;i++ )
		{
			var td = list.rows[i].cells[5];
			td.style.whiteSpace = "normal";
			var spArray = td.innerText.split("&L");
			var spMan = new Array()
				
			for (var ii = 0; ii < spArray.length ; ii++ )
			{

				var item = spArray[ii].toString().split("=")
					
				if(item.length==2){
					spMan[spMan.length] = "<span class=spitem title='" + item[0] + "' onmouseout='window.showdelBorder(this,0)' onmouseover='window.showdelBorder(this,1)'>" + item[1] + "</span>"
				}
			}
			lvw.updateDataCell(td, spMan.join("") + " <span style='float:right;cursor:pointer' onclick='window.spItemedit(this)' onmouseout='Bill.hideunderline(this,\"#666666\")' onmouseover='Bill.showunderline(this,\"red\")' class='c_c reseetTextColor'>添加</span>")
			
		}
		lvw.Refresh(list.parentElement)


		var nullRowDiv = list.parentElement.getElementsByTagName("DIV")[2]
			//alert(nullRowDiv.outerHTML)
		if(!nullRowDiv){
			//不允许添加
			return false
		}
		try{
			var td = nullRowDiv.children[0].rows[0].cells[5].children[0].cells[0]
			td.innerHTML = " <span style='float:right;cursor:pointer' onclick='window.spItemedit(this)' onmouseout='Bill.hideunderline(this,\"#666666\")' onmouseover='Bill.showunderline(this,\"red\")' class='c_c  reseetTextColor'>添加</span>"
			td.style.whiteSpace = "normal"
		}catch(e){}
	}
}

window.showdelBorder = function(span,sType){
	var deldiv = document.getElementById("delSpitemBar")
	if(sType=="1"){
		span.className= "spitemOndel"
		if(!deldiv){
			deldiv = document.createElement("div")
			deldiv.id = "delSpitemBar"
			deldiv.style.cssText = "padding-top:2px;;padding-bottom:1px;padding-left:4px;padding-right:4px;position:absolute;border-left:1px solid #fe5555;border-bottom:1px solid #fe5555;border-right:1px solid #fe5555;background-color:#ffffff;"
			deldiv.innerHTML = "<span class=c_r style='font-size:10px;font-family:arial;cursor:default' title='删除审批人【" + span.innerText + "】'>删除</span>"
			document.body.appendChild(deldiv)
		}
		var rc = span.getBoundingClientRect()
		deldiv.style.left = rc.left + "px";
		deldiv.style.top =  (rc.bottom-3) + "px";
		deldiv.style.display = "";
		deldiv.span = span;
		deldiv.onmouseover = function(){
			this.span.className = "spitemOndel"
			this.style.display = ""
		}
		deldiv.onclick = function(){
			var id = this.span.title;
			var td = window.getParent(this.span,5)
			var cellBody = this.span.parentElement;
			cellBody.removeChild(this.span);
			lvw.updateDataCell(td,cellBody.innerHTML.replace(",,",","))
			deldiv.style.display = "none";
			cellBody.innerHTML = cellBody.innerHTML.replace(",,",",")
			
			var idArraytd =  td.previousSibling
			var ids = idArraytd.innerText.split(",")
			for (var i=0;i<ids.length ;i++ )
			{
				if(ids[i]==id){
					ids.splice(i,1)
				}
			}
			lvw.updateDataCell(idArraytd,ids.join(","))
			idArraytd.children[0].cells[0].innerHTML =ids.join(",")
		}
		deldiv.onmouseout = function(){
			this.span.className = "spitem"
			this.style.display = "none"
		}
	}
	else{
		span.className= "spitem"
		deldiv.style.display = "none"
	}
}

window.onspItemAddSelect=  function(dat, span) {
	if(!dat){return false}
	var oldIds = new Array()
	var cellBody = span.parentElement;
	dat = eval("(" + dat + ")");
	var spans = cellBody.getElementsByTagName("span")
	for (var i=0;i<spans.length ;i++ )
	{
		if(spans[i].title.length>0 && !isNaN(spans[i].title)){
			oldIds[oldIds.length] = spans[i].title
		}
	}
	for (var i = 0;i < dat.length ; i++)
	{
		var hs = false
		var item = dat[i]
		for (var ii=0;ii<oldIds.length ;ii++)
		{
			if(oldIds[ii] == item[0]){
				hs = true
				ii = oldIds.length
			}
		}
		if(hs == false){
			oldIds[oldIds.length] = item[0]
			var nItem = document.createElement("span")
			cellBody.insertBefore(nItem,cellBody.children[cellBody.children.length-1])
			nItem.outerHTML = "<span class=spitem onmouseout='window.showdelBorder(this,0)' onmouseover='window.showdelBorder(this,1)' title='" + item[0] + "'>" + item[1] + "</span>"
		}
	}
	var td = window.getParent(cellBody,4);
	lvw.updateDataCell(td,cellBody.innerHTML);
	td = td.previousSibling;
	lvw.updateDataCell(td,oldIds.join(","))
	td.children[0].rows[0].cells[0].innerHTML = oldIds.join(",");
}

window.spItemedit = function(span){ //添加审批人
	var t = new Date()
	var url = "autolist.asp?id=37&dbf_Bill_Info_id="+document.getElementById("Bill_Info_id").value+"&t=" + t.getTime();
	if(window.ActiveXObject){
	    var dat = window.showModalDialog(url, (dat==undefined?"":dat) , "dialogHeight:650px;dialogWidth:1000px;center:yes;resizable:yes;status:no;scroll:yes")
		window.onspItemAddSelect(dat, span);
	} else {
		window.showModalDialogProxyData = dat;
		var t = screen.availHeight>0?((screen.availHeight-650)/2):10;
		var l = screen.availWidth>0?((screen.availWidth-1000)/2):100;
		var win = window.open(url, "ManuModalDialog" , "height=650px,width=1000px,left=" + l + "px,top=" + t +"px,resizable=yes,status=no,scroll=yes");
		window.showModalDialogProxyFun = function(result) {
			window.onspItemAddSelect(result, span);
		}
	}
}

window.bodyTest = function(){//检测页面加载情况，实现页面初始化
	if(document.getElementById("Bill_Info_id")){
		window.clearInterval(timer);
		window.spInit();
	}
	lvw.RowMouseOut = function(){}
	lvw.RowMouseOver = function(){}
}
timer = window.setInterval("window.bodyTest()",200,"JavaScript");

