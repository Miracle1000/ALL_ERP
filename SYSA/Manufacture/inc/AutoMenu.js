function CMenu(){  //菜单或者选择互交类
	var base = new Object()
	base.oPopup = {
		hide:function(){
			base.oPopup.isOpen = false;
			document.body.removeChild(document.getElementById("__AutoMenu_div"));
			document.body.removeChild(document.getElementById("__AutoMenu_div_bg"));
		},
		show:function(l, t, w, h){
			var div = document.getElementById("__AutoMenu_div");
			if(div){
				div.style.left = l + "px";
				div.style.top = t + "px";
				div.style.width = w + "px";
				div.style.overflow="visible";
				//div.style.height = h + "px";
				div.style.display = "block";
				base.oPopup.isOpen = true;
			}
		},
		isOpen: false
	}
	base.handText = null ;
	base.listtype = "const";
	base.net = new xmlHttp();
	base.sCol = "";
	base.showLastError = function(){
		try{
			var div = window.DivOpen("amerrdlg","系统技术支持",500,300,'a','b',1,20)
			div.innerHTML = base.amlastError
			div.innerHTML = div.innerText.replace("\n","<br>")
			//div.style.border = "1px inset white";
			div.style.lineHeight = "24px"
			div.style.fontSize = "12px";
			div.style.fontFamily = "宋体";
			div.style.color = "blue";
			div.style.overflow = "scroll"
		}
		catch(e){}
	}
	base.listSoure = function(key){  //数据源定义
		var cbase = new Object()
		var hs = false
		cbase.sCol = "";
		cbase.hCol = "";
		cbase.selectBox = 0
		key = key.replace(/(\s*$)/g, ""); //去掉右边空格
		cbase.textArray = null; //常数数组
		cbase.selIndex = 1;  //初始化选择第几项
		cbase.type = "const";	//数据源类型
		cbase.setConst = function(str){  //根据常量创建列表数据源
			cbase.type = "const";
			cbase.textArray = ("选择项" + ";|" + str).split("|");
			for (var i = 0;i < cbase.textArray.length ; i ++ )
			{
				cbase.textArray[i] = cbase.textArray[i].split(";")
			}
			cbase.SetConstSelectItem();
			cbase.sCol = "0".split("|")
			cbase.hCol = "-".split("|")
		    cbase.pageObject =  {dataLines: null, dataSize : null, dataIndex : null, dataCount : null, selIndex: null};	
		}

		cbase.SetConstSelectItem = function(){
			var hs = false
			for (var i = 1; i < cbase.textArray.length ; i ++ )
			{
				if(!hs) {
					if(cbase.textArray[i][0].indexOf(key)==0){
						cbase.selIndex =  i;
					}
				}
			}
		}
		cbase.pageObject = null;
		cbase.setSelectId = function(id, IsztlrbtnClick) { //根据查询ID创建列表数据源 : IsztlrbtnClick=true表示是通过整体录入点放大镜按钮检索
			var net = base.net
			var vp = "" 
			if(window.sys_verPath && window.sys_verPath.length>0) {
				vp = window.sys_verPath
			}
			var pageIndex = base.currhandle.getAttribute("selPageIndex")
			cbase.currhandle = base.currhandle;
			cbase.pageObject = null;
			net.url = vp + "autolist.asp?IsztlrbtnClick=" + (IsztlrbtnClick==1? "1" : "0") + "&" + base.getdbInputData() ;
			net.regEvent("KeyAutoList");
			net.addParam("selid",id);
			net.addParam("pageIndex", pageIndex ? pageIndex : 1);
			net.addParam("key",key);
			r = net.send();
			cbase.type = "const";
			try{
				eval("window.tmpJSON = " + r);
			}
			catch(e){
				cbase.textArray = new Array();
				if(r){base.amlastError = r}
				cbase.textArray[0] = "返回的JSON错误&nbsp;<span style='color:#6666aa;cursor:pointer' onclick='parent.menu.showLastError()'><U>详情</U></span>".split("|")
				return false;
			}
			
			var r = window.tmpJSON;
			cbase.pageObject = {dataLines: r.dataLines, dataSize : r.dataSize , dataIndex : r.dataIndex, dataCount : r.dataCount, selIndex: id};
			cbase.sCol = r.sCol.split("|")
			cbase.hCol = r.hCol.split("|")
			cbase.selectBox = r.SelectBox;
			cbase.textArray = r.data;
			if (r.data[0][0]=="---没有相关数据---")
			{
				cbase.textArray = null;
				return ;
			}
			for (var i = 1; i < cbase.textArray.length ; i ++ )
			{
				if(cbase.textArray[i][0].indexOf(key)==0){
					cbase.selIndex =  i;
					return;
				}
			}
		}
		return cbase;
	}

	base.getPosition = function(obj)
	{
		var cbase = new Object()
		cbase.obj = obj;
		var t,l,w,h
		try{
			t  = obj.offsetTop;
			l = obj.offsetLeft;
			w  = obj.offsetWidth;
			h = obj.offsetHeight;
			while(obj.offsetParent.tagName!="BODY"){
				obj= obj.offsetParent;
				t =  t*1 + obj.offsetTop*1;
				l =  l*1 + obj.offsetLeft*1;
			}
		}
		catch(e){
			t = 0;
			l = 0;
			w = 100;
			h = 100;
		} 
		cbase.width = w+"px";
		cbase.height = h+"px";
		cbase.left = l+"px";
		cbase.top = t+"px";
		
		return cbase;
	}
	
	base.getbnPosition = function(selButton){
		var td = selButton.parentElement;
		if(td.tagName=="TD"){
			if(td.previousSibling){
				base.handText = td.previousSibling.children[0];
				if(!base.handText){base.handText = td.previousSibling; }
				var p = base.getPosition(td.previousSibling)
				p.width = p.width + 20;
				return p;
			}
		}
	}
	
	base.getdbInputData = function(){
		var v = new Array()
		var dat = ""
		var bid = document.getElementById("Bill_Info_id")
		if(bid){
			v[v.length] = "dbf_bill_id" + "=" + bid.value;
			v[v.length] = "dbf_billid" + "=" + bid.value;
			v[v.length] = "dbf_bill_cls" + "=" + document.getElementById("Bill_Info_type").value;
		}
		var xmlhttp = new xmlHttp();//xmlhttp.UrlEncode
		var inputs = document.getElementsByTagName("input")
		for (var i = 0 ; i<inputs.length ; i ++ )
		{
			var input = inputs[i]
			if(input.dbname && input.dbname.indexOf("{us")!=0){ 
				dat = input.title.length > 0 ? input.title : input.value
				if(dat.length<50)
				{
					v[v.length] = escape("dbf_" + input.dbname) + "=" + xmlhttp.UrlEncode(dat.replace(/\+/,"#-add"));
				}
				else{
					v[v.length] = escape("dbf_" + input.dbname) + "=" + xmlhttp.UrlEncode(dat.substring(0,50).replace(/\+/,"#-add"));
				}
			}
		}
		var sels = document.body.getElementsByTagName("select")
		for (var i = 0 ; i<sels.length ; i ++ )
		{
			var sel = sels[i]
			if(sel.dbname  && sel.dbname.indexOf("{us")!=0){
				if(sel.value.length < 50)
				{
					v[v.length] = escape("dbf_" + sel.dbname) + "=" + xmlhttp.UrlEncode(sel.value.replace(/\+/,"#-add"));
				}
				else{
					v[v.length] = escape("dbf_" + sel.dbname) + "=" + xmlhttp.UrlEncode(sel.value.substring(0,50).replace(/\+/,"#-add"));
				}
			}
		}
		var ii = 0
		var bt = window.event.srcElement;
		if(bt && bt.parentElement.className=="smselButton"){
			bt = bt.parentElement;
		}
		if(bt.className=="smselButton"){
			var currRow = window.getParent(bt,6)
			var header = currRow.parentNode.rows[0];
			if(currRow.tagName=="TR"){
				
				for (var i = 0 ; i < currRow.cells.length -2; i ++ )
				{
					var cell = currRow.cells[i+2]
					var hd = header.cells[i+2]
					if(!hd.getAttribute("dbname") || hd.getAttribute("dbname").indexOf("{us999999}")==-1) {
						if(cell.children.length>0 && cell.children[0].tagName == "TABLE") {
							ii ++ ;
							var cv = lvw.getCellValue(cell).replace(/\+/,"#-add").split(lvw.sBoxSpr)
							if(cv.length > 1 && cv[1].replace(/\s/g,"").length>0) {
								cv = cv[1]
							}
							else{
								cv = cv[0]
							}
							cv = cv + "";
							if(cv.length>50) {cv = cv.substring(0,50)}
							v[v.length] = "dbf_cell[" + ii + "]=" + xmlhttp.UrlEncode(cv);
						}
						else{
							ii ++ ;
							cv = cell.innerText;
							if(cv.length>50) {cv = cv.substring(0,50)}
							v[v.length] = "dbf_cell[" + ii + "]=" + xmlhttp.UrlEncode(cv);
						}
					}

				}
			}
		}
		return v.join("&")
	}

	base.showbtnlist = function(selButton , button , disMultiline,e) { //根据按钮事件显示菜单，单列菜单选择从这里执行Multi-line
		base.currhandle = selButton
		var id = selButton.getAttribute("selid");
		var pos = base.getbnPosition(selButton);
		var k = "";
		if(base.handText){
			if(base.handText.tagName=="TD"){ k = "" ; } // base.handText.innerHTML ;}
			else{k = base.handText.value}
		}
		var soure = base.listSoure(k) 
		if(isNaN(id)){
			if(id == "date") { id = "10002" }
			if(id == "bit") { id = "10001" }
		}
		switch(id){
			case "10001":
				soure.setConst("是;1|否;0");
				soure.selectBox = 1
				break;
			case "10002":
				datedlg.show();
				break;
			case "10003":
				datedlg.showTime();
				break;
			default:
				if(selButton.isKey==true){
					var ztlrbtn = (selButton.ztlrbtn ==1 && k=="" ? 1 : 0)
					soure.setSelectId(id,  ztlrbtn);
				}
				else{
					if(selButton.getAttribute("keyselectbox")=="true"){
						var  box = selButton.parentNode.parentNode.getElementsByTagName("INPUT")[0];
						window.ProxykeyselectboxSrc = box;
						$(box).trigger("keyup");
						setTimeout(function(){window.ProxykeyselectboxSrc=null},100);
						return;
					}
					if(isNaN(selButton.IsSelectBox)){ //判断是否为selectbox类型数据
						soure.setSelectId(id);
						selButton.IsSelectBox = soure.selectBox;
						if(selButton.IsSelectBox=="1"){
							base.createlist(pos,soure)
							return;
						}
					}
					if(selButton.IsSelectBox=="1"){
						soure.setSelectId(id);
					}
					else{
						var t = new Date()
						var dat = {button:selButton, selID : id}
						
						if(disMultiline==undefined){
							if(selButton) {
								var tb = selButton.parentNode.parentNode.parentNode.parentNode;
								if(tb.className=="textitemtable"){
									disMultiline = 1;
								}
							}
						}
						
						if(!disMultiline){disMultiline=0}
						else{disMultiline=1}
						if(selButton.Mfield=="1"){
							disMultiline=1
						}
						if($ID("Bill_Info_type") && $ID("Bill_Info_type").value==3){
							disMultiline=1
						}
						var vp = "" 
						if(window.sys_verPath && window.sys_verPath.length>0) {
							vp = window.sys_verPath
						}
						var dbdata = "";
						try{ dbdata = base.getdbInputData() } catch(e){}
						url = vp + "autolist.asp?id=" + id + "&" + dbdata + "&disMultiline=" + disMultiline + "&t=" + t.getTime();
						if(window.ActiveXObject){
						    var dat = window.showModalDialog(url, (dat == undefined ? "" : dat), "dialogHeight:650px;dialogWidth:1000px;center:yes;resizable:yes;status:no;scroll:yes");
							if((dat+"").indexOf("[")==0) { dat = eval("(" + dat + ")");}
							if(dat){
								base.addselectData(dat,selButton.parentElement.parentElement.parentElement.parentElement.parentElement);
							}
						} else {
							window.showModalDialogProxyData = dat;
							var t = screen.availHeight>0?((screen.availHeight-650)/2):10;
							var l = screen.availWidth>0?((screen.availWidth-1000)/2):100;
							var win = window.open(url, "ManuModalDialog" , "height=650px,width=1000px,left=" + l + "px,top=" + t +"px,resizable=yes,status=no,scroll=yes");
							window.showModalDialogProxyFun = function(result) {
								if((result+"").indexOf("[")==0) { result = eval("(" + result + ")");}
								if(result){
									base.addselectData(result,selButton.parentElement.parentElement.parentElement.parentElement.parentElement);
								}
							}
						}
						
						return false;
					}
				}
				break;
		}
		base.createlist(pos,soure)
	}
	
	base.showSourceList = function(id , dbdata , disMultiline , exid1 , exid2){
		var t = new Date()
		var dat = {selID : id}
		var vp = "" 
		if(window.sys_verPath && window.sys_verPath.length>0) { vp = window.sys_verPath;}
		url = vp + "autolist.asp?id=" + id + "&" + dbdata + "&disMultiline=" + disMultiline + "&exid="+ exid1 +"&t=" + t.getTime();
		if(window.ActiveXObject){
			var dat = window.showModalDialog(url, dat , "dialogHeight:650px;dialogWidth:1000px;center:yes;resizable:yes;status:no;scroll:yes");
			if((dat+"").indexOf("[")==0) { dat = eval("(" + dat + ")");}
			if(dat){
				base.saveSelectData(id , dat , exid1 , exid2);
			}
		} else {
			window.showModalDialogProxyData = dat;
			var t = screen.availHeight>0?((screen.availHeight-650)/2):10;
			var l = screen.availWidth>0?((screen.availWidth-1000)/2):100;
			var win = window.open(url, "ManuModalDialog" , "height=650px,width=1000px,left=" + l + "px,top=" + t +"px,resizable=yes,status=no,scroll=yes");
			window.showModalDialogProxyFun = function(result) {
				if((result+"").indexOf("[")==0) { result = eval("(" + result + ")");}
				if(result){
					base.saveSelectData(id , result , exid1 , exid2);
				}
			}
		}
	}
	
	base.saveSelectData = function(id , result , exid1 , exid2){
		if(window.currMenusSelectData) {
			window.currMenusSelectData(id , result , exid1 , exid2);
		}
	}
	
	base.addselectData = function(rows,td){
		var tb = td.parentElement.parentElement.parentElement;
		if(tb.id == "MainTable") {
			Bill.mFieldSelReturn(tb,td,rows)
		}
		else{
			for (var i=0;i<rows.length ;i++ )
			{
				for (var ii=0;ii<rows[i].length ; ii++)
				{
					if(rows[i][ii]=="$0x-space") {rows[i][ii]="";}
				}
			}
			Bill.ListSelReturn(tb,td,rows)
		}
	}

	base.setItemFocus = function(handRow,focused){  //设置某一项的选中状况
			var currSpanCss = "background-color:#babcdc;width:100%;padding:1px;cursor:default;";
			var SpanCss = "width:100%;padding:1px;cursor:default;";
			var currtbColor = "#fffff8";
			var tbColor = "transparent";
			if(!handRow) {return false}
			if (focused)
			{
				handRow.style.cssText = currSpanCss;
				handRow.children[0].style.backgroundColor = currtbColor;
				try{handRow.focus();}
				catch(e){}
			}
			else{
				handRow.style.cssText = SpanCss;
				handRow.children[0].style.backgroundColor = tbColor;
			}
			return true;
	}
	
	base.itemclick = function(currRow){ //选择项   //获取选择的数据
			return function(){
				var result = new Array()
				var tr = currRow.children[0].rows[0];
				for (var i = 1 ; i < tr.cells.length ; i ++ )
				{
					var obj = tr.cells[i];
					var v = obj.getAttribute("value");
					if(obj.getAttribute("value")) {
						result[i-1] = obj.innerHTML + "^tag~" + v;
					}
					else{
						result[i-1] = obj.innerHTML;
					}
				}
				base.listBody.currRow = null;
				base.oPopup.hide();
				base.returnResult(result,base.selectBoxMode);
			}
	}

	base.eventKeydown = function(me){ //处理下拉菜单事件
		return function(){
			var doc = document;
			var sBody = base;
			switch(window.event.keyCode){
				case 40: //下移动
					if (!sBody.currRow) 
					{ 
						base.currRow = doc.getElementById("Row1")
						if(!sBody.currRow) { base.oPopup.hide(); return false; }
						base.setItemFocus(base.currRow,true);
					}
					else{
						var idIndex = sBody.currRow.id.replace("Row","");
						var nextRow = doc.getElementById("Row" + (idIndex*1 + 1));
						if(nextRow){
							base.setItemFocus(sBody.currRow,false);
							sBody.currRow = nextRow;
							base.setItemFocus(sBody.currRow,true);
						}
					}
					window.event.keyCode = 0;
					window.event.returnValue = false;
					return true;
				case 38: //上移动
					if (!sBody.currRow) 
					{ 
						sBody.currRow = doc.getElementById("Row1")
						if(!sBody.currRow) { base.oPopup.hide(); return false; }
						sBody.currRow.style.cssText = currSpanCss;
						sBody.currRow.children[0].style.backgroundColor = currtbColor;
					}
					else{
						var idIndex = sBody.currRow.id.replace("Row","");
						var nextRow = doc.getElementById("Row" + (idIndex*1 - 1));
						if(nextRow){
							base.setItemFocus(sBody.currRow,false);
							sBody.currRow = nextRow;
							base.setItemFocus(sBody.currRow,true);
						}
					}
					window.event.keyCode = 0;
					window.event.returnValue = false;
					return true;
				case 13: //确定选择项
					if (!sBody.currRow){
						sBody.currRow = doc.getElementById("Row1")
						if(!sBody.currRow) { base.oPopup.hide(); return false; }
						base.setItemFocus(sBody.currRow,true);
					}
					else{
						var result = new Array()
						var tr = sBody.currRow.children[0].rows[0];
						for (var i = 1 ; i < tr.cells.length ; i ++ )
						{
							result[i-1] = tr.cells[i].innerHTML; 
						}	
						$(sBody.currRow).click();
						sBody.currRow = null;
					
						//base.oPopup.hide();
						//base.returnResult(result,base.oPopup.document.selectBoxMode);
					}
					window.event.keyCode = 0;
					window.event.returnValue = false;
					return true;
			}
		}
	}

	base.rowCount = 0
	base.returnResult = function(result,sBox){  // 返回数据处理,根据sCol显示在界面
		var nResult = new Array();
		var LsFocusInput = null   //最后一个获取焦点的对象
		sBox = (sBox == "1")
		for(var i = 0 ; i<base.sCol.length ; i++){
			var index = base.sCol[i] 
			if (index.length==0){index = "--"}
			if (isNaN(index) || index < -1)
				nResult[i] = "$0x-null";
			else if (index== -1)
				nResult[i] = "";
			else
			{
				if(result[index]!=undefined){
					nResult[i] = result[index];
				}
				else{
					nResult[i] = "";
				}
			}
		}
			
		var cellBody, currtd , tb , mCellBody;
		switch(base.listtype)
		{
			case "const":
				if(base.handText){
					if (base.handText.tagName=="TD"){ cellBody = base.handText;}
					else{ cellBody = base.handText.parentElement;}
					mCellBody = cellBody;
					currtd = cellBody.parentElement.parentElement.parentElement.parentElement;
					tb = currtd.parentElement.parentElement.parentElement
					if (sBox)	//下拉框模式 name - > value 严格匹配
					{
							if(currtd){

								if(currtd.children.length>0&&currtd.children[0].tagName=="TABLE"){
									cellBody = currtd.children[0].rows[0].cells[0];									
									if(cellBody){
										
										if(cellBody.children.length>0){
											var txtbox = cellBody.children[0];	
											txtbox.value =  nResult[0];
											txtbox.title = nResult[1];
											if(txtbox.onchange){txtbox.fireEvent("onchange");} //触发onchange事件
											LsFocusInput = cellBody.children[0];
											//Task.1213.KILLER.2013.12.16 调拨保存提示顺序需要调整 ,输入无效仓库提示
											txtbox.setAttribute("oncechange", "1");
											setTimeout(function(){	txtbox.setAttribute("oncechange", null);}, 400);
										}
										else{
											cellBody.innerHTML = nResult[0];
											cellBody.title = nResult[1]
										}
									}

									var div = window.getParent(currtd,4);
									if(div.className=="ctl_listview"){
										if(cellBody.children.length>0)
										{
											lvw.updateRowByInput(cellBody.children[0]);  //更新数组
										}
										else{
											lvw.updateDataCell(currtd,cellBody.innerHTML + lvw.sBoxSpr + cellBody.title);
										}
									}
								}

							}
					}
					else //非下拉框模式
					{
						if (base.handText.tagName=="TD"){ cellBody = base.handText;}
						else{ cellBody = base.handText.parentElement;}
						mCellBody = cellBody;
						currtd = cellBody.parentElement.parentElement.parentElement.parentElement;
						base.addselectData([nResult],currtd);
						//if(base.handText.className.indexOf("ctllvw")==0){
						//	currtd = cellBody.parentElement.parentElement.parentElement.parentElement;
						//	tb = currtd.parentElement.parentElement.parentElement
						//	Bill.ListSelReturn()
						//}
						//else{
						//	Bill.setAutoFieldList(base.handText,nResult);
						//}
					}
				}
				break;
			default:
				break;
		}
	}

	base.getRealLen = function (sChars)
	{
		try{
			var span = document.createElement("Span")
			span.innerHTML = sChars;
			sChars = span.innerText;
			span = null;
			return sChars.replace(/\s/g,"").replace(/[^\x00-\xff]/g,"xx").length;
		}
		catch(e){
			return 0;
		}
	}

	base.createlist = function (pos,soure){
		if(!soure) {return;}
		var h = 0 , selRow = - 1 ,  html = new Array() ,clen , w , maxlen  = 0 
		base.listBody = document.getElementById("__AutoMenu_div");
		var bgdiv = document.getElementById("__AutoMenu_div_bg");
		if(!base.listBody) {
			base.listBody = document.createElement("div");
			base.listBody.id = "__AutoMenu_div";
			base.listBody.style.cssText = "background:white url(../../images/smico/contextmenubg2.jpg) repeat-y;position:absolute;"
										+ "padding:0px;margin:0px;overflow:hidden;border:1px solid #ccccd3;box-shadow:0px 0px 10px #acacb3;z-index:999910000; filter:progid:DXImageTransform.Microsoft.Shadow (color=#bcbcc3,direction=135,strength=3);";
			if(!bgdiv){ 
				bgdiv = document.createElement("div"); 
				bgdiv.id = "__AutoMenu_div_bg";
				bgdiv.style.cssText = "position:fixed;_position:absolute;top:0px;left:0px;width:100%;height:100%;display:block;z-index:99999999"
				bgdiv.innerHTML = "<div style='width:100%;height:100%;' onmousedown='menu.oPopup.hide()'>&nbsp;</div>"
				document.body.appendChild(bgdiv);
			}
			document.body.appendChild(base.listBody);
		}
		base.listBody.style.display = "block";
		bgdiv.style.display = "block";

		base.listtype = soure.type;
		var Pobj = soure.pageObject;
		if (soure.selectBox=="1")
		{base.sCol = "0|1".split("|");soure.hCol = "1".split("|")}
		else
		{base.sCol = soure.sCol;}
		
		var visble = new Array()
		if(!soure.textArray){
			if(base.oPopup.isOpen){
				base.oPopup.hide();
				base.listBody.currRow = null;
			}
			try{base.oPopup.hide();}catch(e){}
			return false;
		}

		for (var i=0;i<soure.textArray[0].length; i ++ )
		{
			visble[i] = "";
			for (var ii = 0; ii < soure.hCol.length ; ii ++ )
			{
				if(soure.hCol[ii]==i){
					visble[i] = "display:none";
					ii = soure.hCol.length ;
				}
					
			}
		}
		var cellsWidth = new Array()
		//绘制表头
		var cells = soure.textArray[0];
		var clen = 0;
		var pbar = false
		if (Pobj && Pobj.dataCount>1)
		{
			html.push("<div id='RowPageSize' style='font-size:12px;height:22px;line-height:22px;overflow:hidden;background-color:#e5e5e8;width:100%;padding:1px;cursor:default;border-bottom:1px solid #ccc'>");
			html.push("<div style='float:right'>");
			html.push("<a href='javascript:void(0)' " + (Pobj.dataIndex <=1?"disabled":"onclick='menu.toPage(1)'") + ">首页</a> <a " + (Pobj.dataIndex <=1?"disabled":" onclick='menu.toPage(" + (Pobj.dataIndex-1) + ")'") + " href='javascript:void(0)'>上页</a> ");
			html.push("<a href='javascript:void(0)' " + (Pobj.dataIndex >=Pobj.dataCount?"disabled":"onclick='menu.toPage(" + (Pobj.dataIndex+1) + ")'") + " >下页</a> <a " + (Pobj.dataIndex >=Pobj.dataCount?"disabled":"onclick='menu.toPage(" + Pobj.dataCount + ")'") + " href='javascript:void(0)'>尾页</a> ");
			html.push("&nbsp;</div>");
			html.push("&nbsp;共<b>" + Pobj.dataLines + "</b>条 " + Pobj.dataIndex + "/" + Pobj.dataCount + "页");
			html.push("</div>");
			h = h + 24
			pbar = true
		}
		html.push("<div id='RowHeader' style='width:100%;padding:1px;cursor:default;border-top:1px solid white'>");
		html.push("<table style='table-layout:fixed;width:100%;font-size:12px;border-collapse:collapse;cursor:default;overflow:hidden'>");
		html.push("<tr style='color:#222'><td style='width:24px'></td>");
		for (var ii = 0; ii < cells.length  ; ii ++ )
		{
			var v = cells[ii].replace(/\{us.*\}/g,"").replace(/\{hide\}/g,"").replace("billselectname","选择项")
			html.push("<td style='background-image:url(../../images/smico/bg4.jpg);white-space:nowrap;overflow:hidden;text-align:center;padding:0px;margin:0px;height:18px;" + visble[ii] + "'><b>" + v + "</b></td>");
			clen = 1*(visble[ii].length>0 ? 0: base.getRealLen(v));
			if(!cellsWidth[ii]) {cellsWidth[ii] = 0}
			cellsWidth[ii]  = cellsWidth[ii]  >  clen  ?  cellsWidth[ii] : clen;
			
		}
		html.push("<td style='width:auto;background-image:url(../../images/smico/bg4.jpg);'></td></tr>");
		html.push("</table></div>");
		h = h + 22
	    //绘制数据
		html.push("<div id='RowContain' style=''>");
		for (var i = 1 ; i < soure.textArray.length ; i ++)
		{
			cells = soure.textArray[i];
			clen = 0;
			html.push("<div onclick='menu.itemclick(this)()' id='Row" + i + "' style='width:100%;padding:1px;cursor:default;background-image:url(about:blank);'>");
			html.push("<table onmouseout='if(menu.currRow!=this.parentElement){this.style.backgroundColor=\"transparent\";}' onmouseover='if(menu.currRow!=this.parentElement){this.style.backgroundColor=\"#e0e0ff\";}' style='table-layout:fixed;width:100%;font-size:12px;border-collapse:collapse;cursor:default;'>");
			html.push("<tr><td style='width:24px;'>&nbsp;</td>");
			for (var ii = 0; ii < cells.length  ; ii ++ )
			{
				if(cells[ii].indexOf("^tag~") >= 0) {
					var dats = cells[ii].split("^tag~");
					html.push("<td style='white-space:nowrap;overflow:hidden;color:#222;padding:0px;margin:0px;height:18px;" + visble[ii] + "' value='" + dats[1] + "'>" + dats[0] + "</td>");
				}
				else{
				    html.push("<td style='white-space:nowrap;overflow:hidden;text-overflow:ellipsis;color:#222;padding:0px;margin:0px;height:18px;" + visble[ii] + "' value='' title='" + cells[ii] + "'>" + cells[ii] + "</td>");
				}
				clen = 1*(visble[ii].length>0?0:base.getRealLen(cells[ii]));
				if(!cellsWidth[ii]) {cellsWidth[ii] = 0}
				cellsWidth[ii]  = cellsWidth[ii]  >  clen  ?  cellsWidth[ii] : clen;
				
			}
			html.push("<td style='width:auto'></td></tr>");
			html.push("</table></div>");
			h = h + 20
		}
		html.push("</div>")
		var maxlen = 0
		for (var i = 0; i < cellsWidth.length ; i++ )
		{
			maxlen = maxlen*1 + cellsWidth[i]*1
		}
		base.rowCount = soure.textArray.length;
		base.listBody.innerHTML = html.join("");
		if(window.currMenusKeydownfun) {
			$(document).unbind("keydown", window.currMenusKeydownfun);
			window.currMenusKeydownfun =  null;
		}
		window.currMenusKeydownfun = base.eventKeydown(base);
		$(document).bind("keydown", window.currMenusKeydownfun);
		base.toPage = function(index)
		{
			 var box = soure.currhandle;
			 if(box) {
				box.setAttribute("selPageIndex", index);
				box.setAttribute("isKey",1);
				$(box).click();
				box.setAttribute("isKey",0);
			 }
		}
		var tbs = base.listBody.getElementsByTagName("table")
		ii = 0
		for (var i=0;i<tbs.length ; i++ )
		{
			var hr = tbs[i].rows[0]
			for (var iii=0;iii<cellsWidth.length ;iii++ )
			{
				if(cellsWidth[iii]>0){
					hr.children[iii+1].style.width = (cellsWidth[iii] * 6 + 8*1) + "px"
					if(i==0){ii++}
				}
				else{
					hr.children[iii+1].style.width = "0px"
				}
			}
		}
		w = maxlen * 6 + ii*8 + 32;
		if (w < pos.width + 5){ w =  pos.width + 5;}
		if (pbar == true && w < 240){ w = 240; }
		base.selectBoxMode = soure.selectBox;

		
		if(pos.obj){
			var p = pos.obj.getBoundingClientRect();
			var childmenupop = pos.obj.getAttribute("isContentMenuItem") == "1";
			rc = { x: (p.left + (childmenupop ? (pos.obj.offsetWidth - 4) : 0)), y: (p.top + document.documentElement.scrollTop + (childmenupop ? 4 : pos.obj.offsetHeight)) };
		}
		else{
			rc = {x: window.event.clientX, y:window.event.clientY};
		}

		var Cheight=document.documentElement.clientHeight||document.body.clientHeight;
		if(Cheight-pos.top<base.listBody.clientHeight)rc.y=Cheight-base.listBody.clientHeight-10;

		var bindobj = pos.obj;
		var win = (bindobj?(bindobj.ownerDocument.parentWindow?bindobj.ownerDocument.parentWindow:bindobj.ownerDocument.defaultView):window);
		rc = window.autoMovePageXY(rc, w, h, window);
		l = rc.x;
		t = rc.y;
		var layerDom=document.getElementById("__AutoMenu_div");
		var height = layerDom ? layerDom.offsetHeight : 0;
		var wh=document.documentElement.clientHeight;
		if (t + height > wh) { t = t - height}
		base.oPopup.show(l, t, w , h + 4, document.body);
		base.currRow = document.getElementById("Row" + soure.selIndex)
		base.setItemFocus(base.currRow,true);
		if(window.event && window.event.srcElement && window.ActiveXObject) {
			//IE下可能存在输入内容后焦点丢失的问题
			var srctxtbox = window.event.srcElement;
			if(srctxtbox.tagName == "BUTTON") {
				srctxtbox = srctxtbox.parentNode.parentNode.cells[0].getElementsByTagName("INPUT")[0];
			}
			if(srctxtbox) {
				srctxtbox.focus();
			}
		}
	}
	return base;
}
var menu = new CMenu()