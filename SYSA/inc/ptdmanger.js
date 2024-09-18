//***************限制行数，新增函数 tbh 10.12.08 ********************//
function PListManger() {
	var base = new Object();
	base.key = "trpx";
	base.unkey = "_";
	base.createSpanRows = function(){ //创建行数组
		if(!window.mxSpanRows){
			window.mxSpanRows = new Array();
			var i = 0;
			var  spans = document.getElementsByTagName("SPAN");
			for(var ii = 0 ; ii < spans.length ; ii ++){
				var item = spans[ii];
				if((item.id.length - item.id.replace(base.key,"").length) >0  && item.id.indexOf(base.unkey) <  0 ){
					 window.mxSpanRows[i] = item;
					 i ++; 
				}
			}

		}
	}
	
	base.getLength = function(){ //获取最大行数
		base.createSpanRows();
		return window.mxSpanRows.length;
	}

	base.getFreeRow = function(){  //获取空位行
		base.createSpanRows(); //尝试创建行数组
		var mList = window.mxSpanRows;
		var isAddNewPage = (mList[0].innerText.replace(/\s/g,"").replace(/\n/g,"").length < 10) && mList[0].getElementsByTagName("input").length<1;
		if(isAddNewPage){  //添加页面
			mList[0].innerHTML = "";
		}
		//else{									//修改页面
		//    if (window.location.href.indexOf("contract/top3.asp") > 0 || window.location.href.indexOf("contract/topadd2.asp") > 0)
		//	{}
		//	else{
		//		for(var i= mList.length -1;i>0;i--){
		//			mList[i].innerHTML = mList[i-1].innerHTML
		//		}
		//		mList[0].innerHTML = "";
		//	}
		//}

		for(var i = 1 ; i < mList.length ; i ++){
			if( mList[i].innerText.replace(/\s/g,"").length == 0){
				base.moveRows(mList[i]);
				return mList[i];
			} 
		}
		return null;
	}

	base.GetNextRow  = function(row){ //获取下一行
		for(var i = 0; i <  window.mxSpanRows.length ; i ++){
				if(window.mxSpanRows[i].id == row.id){
					return window.mxSpanRows[i+1];
				}
		}
		return null;
	}
	
	base.getLastVisbleNode = function(){ //获取最后一个非空行
		var currRow = window.mxSpanRows[0];
		for(var i=0 ; i<window.mxSpanRows.length; i++ ){
			var item = window.mxSpanRows[i];

			if(item.innerText.replace(/\s/g,"").length==0){
				return currRow;
			}
			else{
				currRow = item; 
			}
		}
		return currRow;
	}
	
	

	base.moveRows = function(row){  //删除后填补
		if((window.location.href.indexOf("xunjia/topadd.asp")>0)){
			//询价页面不需要按默认的模式处理
			return;
		}
		base.createSpanRows()   //尝试创建行数组
		var lastRow = base.getLastVisbleNode();
		var box = document.createElement("input");
		box.type = "text"
		box.style.display = "inline";
		var rbody = window.ActiveXObject?row.offsetParent:row.parentNode;
		rbody.appendChild(box);
		var rbox = box.previousSibling;
		var i = 0
		//兼容IE10对previousSibling的解释不同
		while(rbox && !rbox.tagName && i < 10000) {
			rbox = rbox.previousSibling;
			i ++;
		}
		//兼容代码结束
		i = 0;
		while(!(rbox.id.indexOf("trpx")==0 && !isNaN(rbox.id.replace("trpx",""))) && i < 1000)
		{
			rbox.swapNode(box);
			rbox = box.previousSibling;
			var ii = 0;
			while(rbox && !rbox.outerHTML && ii < 10000) {
				rbox = rbox.previousSibling;
				ii ++;
			}
			i ++;
		}
		
		if (i < 1000)
		{
			row.swapNode(box);
		}
		box.outerHTML = "";
	}

	base.getParent = function(child,parentIndex){  //获取指定层次级别的父对象
		for( var i= 0 ;i < parentIndex ; i++){
			child = child.parentElement;
		}
		return child;
	}


	base.add = function(url,callback){ //添加行，url 添加网址 , callback 回调行数
		var freeRow =  base.getFreeRow(); // tbh 2010.12.08 xmlHttp.responseText;;
		if(freeRow){
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function()
			{
				  if (xmlHttp.readyState < 4) {
						if(freeRow) {
							freeRow.innerHTML="loading...";
						}
				  }

				  if (xmlHttp.readyState == 4) {
						var htmls =   xmlHttp.responseText.split("<!--CP_Multi_Line-->");
						freeRow.innerHTML = htmls[0];
						xmlHttp.abort();
						if(callback){ callback(freeRow); 	}
						freeRow = null;
						for (var x = 1; x<htmls.length; x++)
						{
							 freeRow =  base.getFreeRow();
							 if(freeRow) {
									freeRow.innerHTML = htmls[x];
									if(callback){ callback(freeRow); 	}
									freeRow = null;
							 }
						}
				  }
			}
			xmlHttp.send(null);
		}
		else
		{	
			window.alert("当前配置最多只允许添加" + (window.mxSpanRows.length-1) + "行。\n\n详细情况，请咨询系统管理员。")
		}
	}

	base.add2 = function(html,callback){ //添加行，url 添加网址 , callback 回调行数
		var freeRow =  base.getFreeRow(); // ljh 2014.3.25 xmlHttp.responseText;;
		if(freeRow){
			if(html!=""){
				freeRow.innerHTML = html;
				if(callback){
					callback(freeRow);
				}
				freeRow = null;
			}
			return true;
		}
		else
		{	
			window.alert("当前配置最多只允许添加" + (window.mxSpanRows.length-1) + "行。\n\n详细情况，请咨询系统管理员。");
			return false;
		}
	}

	base.delcallback = function(currRow,callback,dismoverow){
		dismoverow = true;
		if(!dismoverow){  //自动移动位置
			return function(){
				if(xmlHttp.readyState == 4)
				{
					 currRow.innerHTML="";
					 base.moveRows(currRow);
					 if(callback){
						callback(currRow);
					 }
				}
			}
		}
		else{
			return  function(){ //不自动移动位置
				if(xmlHttp.readyState == 4)
				{
					 currRow.innerHTML="";
					 if(callback){
						callback(currRow);
					 }
				}
			}
		}
	}
	
	base.getRowIndex = function(row){
		for(var i=0 ; i<window.mxSpanRows.length ; i++ ){
			if(row==window.mxSpanRows[i]){
				return i;
			}
		}
		return -1;
	}

	base.getCurrRow = function (child){ //根据行中子对象获取当前行
		base.createSpanRows(); //尝试创建行数组
		for (var i = 0;i < 20 ;i++)
		{
			if(base.getRowIndex(child)>=0){
				return child;
			}
			if(child.parentElement){
				child = child.parentElement;
			}
			else{
				return base.getLastVisbleNode();
			}
		}

	}


	base.del = function(url,callback,dismoverow,ev){   //删除行，url为执行网址,callback 为回调函数\
	    base.createSpanRows()						//尝试创建行数组
	    var obj = ev && ev.srcElement || window.event.srcElement;//取window.event.srcElement时要注意，可能是被改写之后的window.event,具体参见cp_ajax.js-->refreshPrices
	    var currRow = base.getCurrRow(obj); //根据删除图标获取删除行
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = base.delcallback(currRow,callback,dismoverow);
		xmlHttp.send(null);
	}
	
	base.getCellInput = function(parent,defTag){ //获取单元格下面子类可输入对象
		if(!defTag){defTag = ""}
		if(defTag.length==0){
			switch(parent.tagName)
			{
				case "SELECT":
					return parent;
				case "TEXTAREA":
					return parent;
				case "INPUT":
					var tp = parent.type.toLowerCase();
					if(tp!="input" && tp!="button" && tp!="image")
					{
						return parent;
					}
				default:
					break;
			}
		}
		else{
			if(parent.tagName.toLowerCase()==defTag)
			{
				switch(parent.tagName)
				{
					case "SELECT":
						return parent;
					case "TEXTAREA":
						return parent;
					case "INPUT":
						var tp = parent.type.toLowerCase();
						if(tp!="input" && tp!="button" && tp!="image")
						{
							return parent;
						}
					default:
						break;
				}
			}
		}
		return null;
	}

	base.getCellTable = function(td){
		var nodes = td.getElementsByTagName("TABLE");
		for(var i = 0;i < nodes.length ; i++){
			if (nodes[i].tagName=="TABLE")
			{
				return nodes[i];
			}
		}
		return null;
	}

	base.setallvalue = function(colindex,value,defTagName){
		base.createSpanRows()   //尝试创建行数组
		if(!defTagName){defTagName = "";}
		defTagName = defTagName.toLowerCase();
		for(var i = 1 ; i <  window.mxSpanRows.length ; i ++){
			var span = window.mxSpanRows[i];
			var tb = base.getCellTable(span); 
			if(tb){
				var td = tb.rows[0].cells[colindex];
				var nds = td.getElementsByTagName("INPUT").length>0 ? td.getElementsByTagName("INPUT"):[]; 
				var sds = td.getElementsByTagName("SELECT");
				for(var l = 0;l<sds.length;l++){
					nds.push(sds[l]);
				}
				var tas = td.getElementsByTagName("TEXTAREA");
				for(var l = 0;l<tas.length;l++){
					nds.push(tas[l]);
				}
				for(var ii=0 ; ii < nds.length; ii++){
					var obj = base.getCellInput(nds[ii],defTagName)
					if(obj){
						obj.value = value;
						obj.checked = value;
					}
				}
			}
		}
	}

	return base;
}

var plist = new PListManger(); //实例化
// ******************************************************************//