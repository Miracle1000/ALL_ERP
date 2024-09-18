//明细选择产品
function nodeClick(e,node){
	var $node = $(node);
	var product= $node.attr('nid');
	//判断产品是否已通过关联单价选择出来了
	var hasProduct = false;
	if (parent.opener.window.checkProductByOrder){hasProduct = parent.opener.window.checkProductByOrder(product);}
	if (hasProduct==true){
		alert("您选择的产品在关联单据中已存在,请重新选择!");
		return;
	}
	//判断产品是否手动选择了
	hasProduct = parent.checkProductByCurrList(product);
	if (hasProduct==true){
		alert("您选择的产品已存在,请重新选择!");
		return;
	}
	if (window.setParentProduct){window.setParentProduct(product,1);}
}

window.setParentProduct = function(ord,ptype){
	var json = {};
	json.__msgid = "getProInfo";
	json.product = ord;
	json.ptype = ptype
	var aj = $.ajax({
		type:'post',
		url:'add.asp',
		cache:false,  
		dataType:'html', 
		data:json,
		success: function(data){
			parent.setSubProInfo(data);
		},
		error:function(data){}
	});
}

//以上js在select_product.asp中使用

//以下js在searchProduct.asp中使用

//初始化页面产品列表(已选择的产品)
function initProductList(dataType , id){
	switch (dataType)
	{
	case "content" :
		var json = {};
		json.__msgid = "getProMxInfo";
		json.id = id;
		json.ptype = 0;
		var aj = $.ajax({
			type:'post',
			url:'content.asp',
			cache:false,  
			dataType:'html', 
			data:json,
			success: function(data){
				parent.setSubProInfo(data);
			},
			error:function(data){}
		});
		break;
	case "design" :
		var json = {};
		json.__msgid = "getProMxInfo";
		json.id = id;
		json.ptype = 1;
		var aj = $.ajax({
			type:'post',
			url:'content.asp',
			cache:false,  
			dataType:'html', 
			data:json,
			success: function(data){
				parent.setSubProInfo(data);
			},
			error:function(data){}
		});
		break;
	default :
		var rows = opener.window.lvw_JsonData_bllst_designlist.rows;
		var keyIndex = opener.getFieldIndex("ProductID");
		var listid = opener.getFieldIndex("listid");
		var products = "";
		for (var i = 0;i<rows.length ;i++ ){
			if (rows[i][listid]=="0"){
				if (products.length>0){products +=",";}
				products +=rows[i][keyIndex];
				window.setParentProduct(rows[i][keyIndex],3);
			}
		}
		//if (products.length>0){cptj(products,0);}
	}	
}

function checkProductByCurrList(product){
	var hasProduct=false;
	for (var i=0;i<window.LvRows.length;i++){
		if (window.LvRows[i][1]==product){
			hasProduct = true;
			break;
		}
	}
	return hasProduct;
}


window.LvRows=[];
function setSubProInfo(data){
	var result = eval("o=" + data + "");
	if (result.msg == 'true'){
		$("#trpx0")[0].style.display = "none";
		for (var k =0; k< result.rows.length; k++){
			var a = result.rows[k];
			var r = [];
			r[0] = a.mxid;
			r[1] = a.ord;
			r[2] = a.title;
			r[3] = a.BH;
			r[4] = a.XH;
			r[5] = a.UnitJB;
			r[6] = a.UnitAll;
			r[7] = a.zdy1;
			r[8] = a.zdy2;
			r[9] = a.zdy3;
			r[10] = a.zdy4;
			r[11] = a.zdy5;
			r[12] = a.zdy6;
			r[13] = "-"+window.LvRows.length;
			window.LvRows.push(r);
			addTrBy(a);
		}
	}
}

//页面增加行By LvRows
function addTrBy(a){
	if ($("#content").length==0){return;}
	var tb = $("#content")[0];
	var top  = tb.rows[0];
	var tr = document.createElement("tr");
	var cells = top.cells;
	for (var i = 0; i < cells.length; i++){
		var td = document.createElement("td");
		var dbname = cells[i].getAttribute("dbname");
		td.className = "proTd"
		td.style.cssText = cells[i].style.cssText + ';height:30px;';
		switch (dbname)
		{
			case "index":
				td.innerText = tb.rows.length;
				break;
			case "title":
				var t = "";
				if (a.haslink == "1"){
					t = "<a href='../product/content.asp?ord=" + a.pword + "' target='_blank'>" + a.title + "</a> ";
				}else{
					t = a.title + " ";
				}
				t = t + "<img src='../images/del2.gif' pid='" + a.ord + "' ptype='" + a.ptype + "' onclick='delPro(this)' onmousedown='stopBubble(event)' style='cursor:pointer' title='点击删除产品' />"
				td.innerHTML = t;
				break;
			case "order1":
				td.innerText = a.BH;
				break;
			case "type1":
				td.innerText = a.XH;
				break;
			case "zdy1":
				td.innerText = a.zdy1;
				break;
			case "zdy2":
				td.innerText = a.zdy2;
				break;
			case "zdy3":
				td.innerText = a.zdy3;
				break;
			case "zdy4":
				td.innerText = a.zdy4;
				break;
			case "zdy5":
				td.innerText = a.zdy5;
				break;
			case "zdy6":
				td.innerText = a.zdy6;
				break;
			case "link":
				td.innerHTML = "<a pid='" + a.ord + "' ptype='" + a.ptype + "' class='bom_addLine' href='javascript:void(0);' onclick='delPro(this)' onmousedown='stopBubble(event)'>删除</a>";
				break;
		}
		tr.appendChild(td);
	}
	$(tb).append(tr);
}

//--删除
function delPro(obj){
	var pid = obj.getAttribute("pid");
	var ptype = obj.getAttribute("ptype");
	var r =window.LvRows;
	for (var i=r.length-1; i>=0;i--){
		if (r[i][1]==pid){r.splice(i,1);}
	}
	var tr = obj.parentElement.parentElement;
	try{
		tr.removeNode(true);
	}catch (e){
		tr.parentNode.removeChild(tr);// firefox 没有 removeNode 方法
	}

	var tb = $("#content")[0];
	for (var i = 1; i < tb.rows.length; i++){
		tb.rows[i].cells[0].innerText = i;
		window.LvRows[i-1][13]=i-1;
	}
	if (r.length == 0){$("#trpx0")[0].style.display = "";}
}

function stopBubble(e){
	//一般用在鼠标或键盘事件上
	if(e && e.stopPropagation){
		e.stopPropagation();//W3C取消冒泡事件
	}else{	
		window.event.cancelBubble = true;//IE取消冒泡事件
	}	
}

//--产品添加——保存后回调函数
function cptj(ord,top) {
	window.setTimeout(function(){window.setParentProduct(ord,2)},1000);
}

//编辑明细保存
function SaveList(dataType , id ,pword , canAddNotice){
	if (opener.window.RefreshLvwRow){opener.window.RefreshLvwRow(window.LvRows);}
	if (opener.window.RefreshMxList){opener.window.RefreshMxList(window.LvRows ,dataType ,id);}
	if (dataType.indexOf("change")>0 && canAddNotice == 1){
		window.location.href="../notice/add.asp?datatype=-31&fromid="+ pword;
	}else{
		window.close();
	}
}

function ajaxSubmit(sort1){
    $('#cp_search').width(210);
    $('#cp_search').height(410);
    $('#cp_search').css("overflow", "auto");
	var B=document.forms[0].B.value;
	var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
	//cstore=1表示只查询实体产品.Task.1440.binary.2014.03.09
	var url = "../contract/search_cp.asp?cstore=1&cbom=" + window.ShowOnlyHasBomProduct + "&lv=1&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4){
			var response = xmlHttp.responseText;
			cp_search.innerHTML=response;
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);  
}

function LVSelectProduct(pid){
	if (parent.window.setParentProduct)
	{
		parent.window.setParentProduct(pid,1);
	}
}

function updatePage_cp(callBack){
	if (xmlHttp.readyState == 4){
		var response = xmlHttp.responseText;
		cp_search.innerHTML=response;
		if(callBack){
			callBack.apply(this,arguments);
		}
		xmlHttp.abort();
	}
}