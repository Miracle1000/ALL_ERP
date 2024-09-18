function nodeClick(e,node){
	var $node = $(node);
	LVSelectProduct($node.attr('nid'));
}

function LVSelectProduct(pid){
	if (parent.window.setParentProduct)
	{
		parent.window.setParentProduct(pid,1);
	}
}
function LVSelectProduct1(pid){
	if (parent.window.setParentProduct)
	{
		parent.window.setParentProduct(pid,0);
	}
}

function ajaxSubmit_page(sort1,pagenum,callBack){
	$('#productTree').hide();
	$('#cp_search').show();
	$('#cp_search').width(210);

	//获取用户输入
	var B=document.forms[0].B.value;
	var C=(document.forms[0].C.value==$("#txtKeywords").get(0).defaultValue?"":document.forms[0].C.value);
	var top=document.forms[0].top.value;
	//cstore：表示是否要求显示能出库的产品，即只显示实体产品
	var url = "../contract/search_cp.asp?cstore=0&lv=1&P="+pagenum+"&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	if(event==null|| (event.srcElement && event.srcElement.getAttribute("ads"))){
		//处理高级搜索
		var ifcobj=document.getElementById("adsIF").contentWindow.document;
		var sobj=ifcobj.getElementsByTagName("input");
		var txValue="";
		for(var i=0;i<sobj.length;i++){
			if(sobj[i].getAttribute("sk")&&sobj[i].type=='text'&&sobj[i].value!=''){
				txValue+=(txValue==""?"":"&")+sobj[i].getAttribute("sk")+"="+escape(sobj[i].value);
			}
		}
		sobj=ifcobj.getElementsByTagName("select");
		for(var i=0;i<sobj.length;i++){
			if(sobj[i].getAttribute("sk")&&sobj[i].value!=''){
				txValue+=(txValue==""?"":"&")+sobj[i].getAttribute("sk")+"="+escape(sobj[i].value);
			}
		}
		//任务：3573 直接入库明细按照产品分类检索检索出来产品不是分类内的 xieyanhui20150704
		sobj=ifcobj.getElementsByName("A2");
		var tmp="";
		for(var i=0;i<sobj.length;i++){
			if(sobj[i].checked){
				tmp+=(tmp==""?"":",")+escape(sobj[i].value);
			}
		}
		txValue+=(tmp==""?"":(txValue==""?"":"&")+"A2="+tmp)
		url="../contract/search_cp.asp?cstore=0&lv=1&ads=1"+(txValue==""?"":"&")+txValue+"&P="+pagenum+"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	}

	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_cp(callBack)};
	xmlHttp.send(null);  
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

function TxmAjaxSubmit(){
	//获取用户输入
	var TxmID=document.txmfrom.txm.value;
	if (TxmID.length ==0){return;}
	var url = "../product/txmRKnew.asp?cstore=0&txm="+escape(TxmID)+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updateTxm(top);};
	xmlHttp.send(null);
}

function updateTxm(x1){
	if (xmlHttp.readyState == 4){
		var response = xmlHttp.responseText;
		if (response!=""){
			LVSelectProduct(response);
		}else{
			alert("产品不存在");
		}
	}
}

function ContinueMovePannel(event,flg){
	event=event||window.event;
	var mp=parent.document.getElementById("productselect");
	if (!mp)
	{
		return;
	}
	if(flg==0){mp.ismoving=0;return false;}
	if(!mp.ismoving||!mp.oldx||!mp.oldx||!mp.oldleft||!mp.oldtop||mp.ismoving!=1) return false;
	var newleft=parseInt(mp.oldleft)+(event.clientX+parseInt(mp.style.left))-parseInt(mp.oldx);
	var newtop=parseInt(mp.oldtop)+(event.clientY+parseInt(mp.style.top))-parseInt(mp.oldy);
	//top.document.title=newleft+","+newtop;
	if(newleft<0||newtop<0) return false;
	mp.style.left=newleft;
	mp.style.top=newtop;
	var pfm=parent.parent.document.getElementById("cFF");
	if(parseInt(mp.style.top)+parseInt(mp.offsetHeight)>parseInt(pfm.style.height)) pfm.style.height=parseInt(mp.style.top)+parseInt(mp.offsetHeight);
}

function Left_adSearch(){
	var dv=document.getElementById("adsDiv");
	var frm=document.getElementById("adsIF");
	dv.style.left=210+'px';
	dv.style.top=0+'px';
	var dvdlg=parent.document.getElementById("productselect");
	if(dv.disp==1){
		dv.style.display="none";
		dv.disp=0;
		dvdlg.style.width="230px";
		$('#__adv_search_btn').val("高级");
		document.getElementById("productdh").style.width = "100%";
		document.getElementById("productTree").style.width = "100%";
	}else{
		dv.style.display="block";
		var h = $(frm.contentWindow.document.body).children('table:eq(1)').height() + 35;
		frm.style.height = h*1+"px";
		dv.style.height=h*1+"px";
		var proSelectFrame = parent.document.getElementById('proSelectFrame');
		var h2 = $(proSelectFrame).parent().height();
		if(h2<h) {$(proSelectFrame).height(h).parent().height(h); }
		dv.disp=1;
		$('#__adv_search_btn').val("收回");
		dvdlg.style.width="633px";
		document.getElementById("productdh").style.width = "210px";
		document.getElementById("productTree").style.width = "210px";
	}

}

function Left_adClose(){
	var dv=document.getElementById("adsDiv");
	if(dv.disp==1){Left_adSearch();}
}

$(function(){
	//parent.$('#productselect').width(230);
});

function ajaxSubmit(sort1){
	$('#cp_search').width(210);
	var B=document.forms[0].B.value;
	var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
	//cstore=1表示只查询实体产品.Task.1440.binary.2014.03.09
	var url = "../contract/search_cp.asp?cstore=0&cbom=" + window.ShowOnlyHasBomProduct + "&lv=1&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function MovingPannelMouseDown()
{
	var dvobj=document.getElementById('productselect');
	dvobj.ismoving=1;
	dvobj.oldx=event.clientX;
	dvobj.oldy=event.clientY;
	dvobj.oldleft=dvobj.style.left;
	dvobj.oldtop=dvobj.style.top;
}
function MovingPannel(event,flg)
{
	event=event||window.event;
	var mp=document.getElementById("productselect");
	if(flg==0){mp.ismoving=0;return false;}
	if(!mp.ismoving||!mp.oldx||!mp.oldx||!mp.oldleft||!mp.oldtop||mp.ismoving!=1) return false;
	var newleft=parseInt(mp.oldleft)+event.clientX-parseInt(mp.oldx);
	var newtop=parseInt(mp.oldtop)+event.clientY-parseInt(mp.oldy);
	if(newleft<0||newtop<0) return false;
	mp.style.left=newleft;
	mp.style.top=newtop;
	try{
	if(parseInt(mp.style.top)+parseInt(mp.offsetHeight)>parseInt(parent.document.getElementById("cFF").style.height)) parent.document.getElementById("cFF").style.height=parseInt(mp.style.top)+parseInt(mp.offsetHeight);
	}catch(e){}
}

//--------------------------------------------------------
window.setParentProduct = function(pid,ptype){
	//confirm("[pid="+pid+"][ptype="+ptype+"]");
	if (bomadd.addAction == '1')
	{
		//--pid:产品ord；ptype:产品类型，实际产品 还是 虚拟名称
		bomadd.parentPro = {"pid":pid,"ptype":ptype}
	}
	bomadd.getProInfo({"pid":pid,"ptype":ptype});
}

var bomadd = {};
//--父件数据
bomadd.parentPro = {'pid':'0',"ptype":'0'};
//--子件数据,数组数据JSON = {'pid':'0',"ptype":'0'}
bomadd.subProInfo = {};
bomadd.subProInfo1 = [];
//--产品选择列表事件类型：1 = 主页面添加父件；0 = 弹窗选择子件； 默认1，弹窗页面会设为0；
bomadd.addAction = '1';
bomadd.treeType = '1';
bomadd.lvw = {};
bomadd.lvw.rows = [];

bomadd.$ID = function(id){
	return document.getElementById(id);
}
//--弹出父件选择窗口
bomadd.showProductSelect = function(){
	var div = bomadd.$ID("productselect");
	if (!div)
	{
		var html = [];
		html.push("<div style='WIDTH: 99%; HEIGHT: 25px; CURSOR: move' onmousedown='MovingPannelMouseDown();' ismoving='0'>");
		html.push("<div style='LINE-HEIGHT: 25px; WIDTH: 120px; FLOAT: left; HEIGHT: 25px; FONT-SIZE: 12px; FONT-WEIGHT: bolder; MARGIN-RIGHT: -90px'>");
		html.push("&nbsp;选择产品明细");
		html.push("</div>");
		html.push("<div style='MARGIN: 0px 80px 0px 90px; WIDTH: auto'></div>");
		html.push("<div style='WIDTH: 50px; FLOAT: right; PADDING-TOP: 2px;margim-right:5px'>");
		html.push("<input class='button2' onclick=\"document.getElementById('productselect').style.display='none';\" value='关闭' type='button' />");
		html.push("</div>");
		html.push("</div>");
		html.push("<div id='pro_tab' class='selected1'>");
		html.push("<span id='select_product'class='tabBarBgSel'>产品</span>");
		html.push("<span id='select_productName' class='tabBarBg'>虚拟</span>");
		html.push("</div>");
		html.push("<iframe id='proSelectFrame' src='select_product.asp' border='0' frameBorder='0' style='margin-top: 0px; width: 99%; height: 672px; margin-left: 2px;' scorlling='no'></iframe>");
		//html.push("<iframe id='proSelectFrame' src='' border='0' frameBorder='0' style='margin-top: 0px; width: 100%; height: 672px; margin-left: 2px;' scorlling='no'></iframe>");
		var div = document.createElement("div");
		div.id = "productselect";
		div.style.cssText = "border-bottom: #889bbc 1px solid; position: absolute; text-align: center; border-left: #889bbc 1px solid; width: 230px; display: inline; background: #EFEFEF; border-top: #889bbc 1px solid; top: 0px; border-right: #889bbc 1px solid; left: 300px;";
		document.body.appendChild(div);
		div.innerHTML = html.join("\n");
		bomadd.$ID("select_product").onclick = function () { bomadd.$ID("proSelectFrame").src = 'select_product.asp'; $(this).addClass("tabBarBgSel").siblings().removeClass("tabBarBgSel").addClass("tabBarBg"); this.parentElement.className = "selected1"; }
		bomadd.$ID("select_productName").onclick = function () { bomadd.$ID("proSelectFrame").src = 'select_productName.asp'; $(this).addClass("tabBarBgSel").siblings().removeClass("tabBarBgSel").addClass("tabBarBg"); this.parentElement.className = "selected2"; div.style.width = "230px"; }
	}
	div.className = "resetTableBg resetBorderColor";
	div.style.display = "inline";
	if (!document.body.onmouseup)
	{
		document.body.onmouseup = function(){try{MovingPannel(event,0);ScrollBarMouseUP();}catch(e){}}
	}
	if (!document.body.onmousemove)
	{
		document.body.onmousemove = function(){try{MovingPannel(event,1);ScrollBarMouseMove(event);}catch(e){}}
	}
}

//--结构类型触发事件，异步加载结构编码
bomadd.ChangeProType = function(obj){
	var $this = obj;
	var id = $this.id;
	var aj = $.ajax({
		type: 'post',
		url: 'add.asp' ,
		cache:false,  
		dataType:'html', 
		data: {
			'__msgid':'ChangeProType',
			'ord':$this.value
		},
		success: function(data){
			id = 'p_proCode' + id.replace("p_proType","");
			var l = $("#" + id + " option:last").attr("index");
			for (var i = l; i >= 0; i--)
			{
				$("#" + id + " option[index=" + i + "]").remove();
			}
			if (data != "false")
			{
				$("#" + id).append(data);
				if (bomadd.subPro.protype_all == 1)		//--批量修改【结构类型】
				{
					bomadd.subPro.protype_all = 0;		//--取消批量修改标记
					for (var i in bomadd.subPro.move.SubType)
					{
						$("#p_proType" + i.replace("SubType","")).val(obj.value);
						$("#p_proCode" + i.replace("SubType","")).html('').append(data);
					}
				}
			}
		},
		error:function(data){
			
		}
	});
}
//--子件【结构类型】批量修改触发事件，异步加载结构编码
bomadd.ChangeProType_all = function(obj){
	bomadd.subPro.protype_all = 1;					//--标记为批量修改
	bomadd.ChangeProType(obj);
}
//--子件【结构编码】批量修改触发事件
bomadd.ChangeProCode_all = function(obj){
	for (var i in bomadd.subPro.move.SubType)
	{
		$("#p_proCode" + i.replace("SubType","")).val(obj.value);
	}
}

//--父件和子件选择异步加载产品信息
//--参数：{"pid":pid,"ptype":ptype}
bomadd.getProInfo = function(json){	
	if (bomadd.addAction == '0' && bomadd.checkSubProInfo(json))	//--添加子件时，检测产品是否重复
	{
		return false;
	}
	if (bomadd.addAction == '2' && bomadd.checkSubProInfo(json))	//--添加子件时，检测产品是否重复
	{
		alert("产品已存在，请不要重复添加！")
		return false;
	}
	json.__msgid = "getProInfo";
	var aj = $.ajax({
		type:'post',
		url:'add.asp',
		cache:false,  
		dataType:'html', 
		data:json,
		success: function(data){
			if (bomadd.addAction == '1')
			{
				bomadd.setParentProInfo(data);//--将件产品信息加载到页面
			}
			else if (bomadd.addAction == '2')
			{
				bomadd.setTeLiProInfo(data);//--将特例产品信息加载到页面
			}
			else if (bomadd.addAction == '0')
			{
				bomadd.setSubProInfo(data);//--将子件产品信息加载到页面
			}
		},
		error:function(data){
			
		}
	});
}
//--将父件属性加载到页面
bomadd.setParentProInfo = function(data){
	try
	{
		var a = eval("(" + data + ")");	
	}
	catch (e)
	{
		return false;
	}
	var id = "p_proUnit_0";						//--父件单位ID
	var p_title = bomadd.$ID("p_proName_0");	//--父件名称
	var p_ord = bomadd.$ID("p_proOrd_0");		//--父件ORD
	var p_type = bomadd.$ID("p_pType_0");		//--父件类型
	var p_BH = bomadd.$ID("p_proBH");			//--父件编号
	var p_XH = bomadd.$ID("p_proXH");			//--父件型号
    var p_Unit = bomadd.$ID(id);				//--父件单位
    var p_ProductAttr1Name = bomadd.$ID("p_ProductAttr1Name_0");
    var p_ProductAttr2Name = bomadd.$ID("p_ProductAttr2Name_0");
    var p_SX = bomadd.$ID("p_proSX");			//--父件属性
	var p_zdy1 = bomadd.$ID("p_zdy1_21");			//--父件自定义1
	var p_zdy2 = bomadd.$ID("p_zdy2_21");			//--父件自定义2
	var p_zdy3 = bomadd.$ID("p_zdy3_21");			//--父件自定义3
	var p_zdy4 = bomadd.$ID("p_zdy4_21");			//--父件自定义4
	var p_zdy5 = bomadd.$ID("p_zdy5_21");			//--父件自定义5
	var p_zdy6 = bomadd.$ID("p_zdy6_21");			//--父件自定义6
	var l = $("#" + id + " option:last").attr("index");
	for (var i = l; i >= 0; i--)
	{
		$("#" + id + " option[index=" + i + "]").remove();
    }
    var m = $("#p_ProductAttr1Name_0 option:last").attr("index");
    for (var j = m; j >= 0; j--) {
        $("#p_ProductAttr1Name_0 option[index=" + j + "]").remove();
    }
    var n = $("#p_ProductAttr2Name_0 option:last").attr("index");
    for (var k = n; k >= 0; k--) {
        $("#p_ProductAttr2Name_0 option[index=" + k + "]").remove();
    }

    if (a.msg == 'true')
	{
		p_title.value = a.title;
		p_ord.value = a.ord;
		p_type.value = a.ptype;
		p_BH.innerText = a.BH;
		p_XH.innerText = a.XH;
		p_SX.innerText = a.SX;
		if (p_zdy1){p_zdy1.innerText = a.zdy1}
		if (p_zdy2){p_zdy2.innerText = a.zdy2}
		if (p_zdy3){p_zdy3.innerText = a.zdy3}
		if (p_zdy4){p_zdy4.innerText = a.zdy4}
		if (p_zdy5){p_zdy5.innerText = a.zdy5}
		if (p_zdy6){p_zdy6.innerText = a.zdy6}
		if (a.ptype == "1")
		{
			$("#" + id).removeAttr("disabled");
			$("#" + id).parent().find(".notnull").show();
			$("#p_proUnit_cel").attr("nu","1");
			$("#" + id).append(a.Unit);
			$("#" + id).val(a.UnitJB);
		}
		else
		{
			$("#" + id).attr({"disabled":"disabled"});
			$("#" + id).parent().find(".notnull").hide();
			$("#p_proUnit_cel").attr("nu","0");
			$("#p_proUnit_cel .bill_valid_msg").text("");
        }
        $("#p_ProductAttr1Name_0").append(a.ProductAttr1Option);
        $("#p_ProductAttr2Name_0").append(a.ProductAttr2Option);
        if (a.ProductAttrsName.length > 0) {
            var productAttrsNameArray = a.ProductAttrsName.split("___");
            if (productAttrsNameArray.length > 1) {
                $("#p_ProductAttr1Name_tit").text(productAttrsNameArray[0]);
                $("#p_ProductAttr2Name_tit").text(productAttrsNameArray[1]);
            }
        }
    }
	else{
		p_title.value = '';
		p_ord.value = '';
		p_type.value = '';
		p_BH.innerText = '';
		p_XH.innerText = '';
		p_SX.innerText = ''
	}
}

//--将子件属性加载到页面
bomadd.setSubProInfo = function(data){
	bomadd.$ID("trpx0").style.display = "none";
	var a = eval("(" + data + ")");
	var tb = bomadd.$ID("content");
	var top  = tb.rows[0];
	if (a.msg == 'true' && tb && top)
	{
		var tr = document.createElement("tr");
		var cells = top.cells;
		for (var i = 0; i < cells.length; i++)
		{
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
					if (a.haslink == "1")
					{
						t = "<a href='../product/content.asp?ord=" + a.pword + "' target='_blank'>" + a.title + "</a> ";
					}
					else
					{
						t = a.title + " ";
					}
					t = t + "<img src='../images/del2.gif' pid='" + a.ord + "' ptype='" + a.ptype + "' onclick='bomadd.subPro.delPro(this)' onmousedown='stopBubble(event)' style='cursor:pointer' title='点击删除产品' />"
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
					td.innerHTML = "<a pid='" + a.ord + "' ptype='" + a.ptype + "' class='bom_addLine' href='javascript:void(0);' onclick='bomadd.subPro.delPro(this)' onmousedown='stopBubble(event)'>删除</a>";
					break;
			}
			tr.appendChild(td);
		}
		$(tb).append(tr);
		if (bomadd.subProInfo['subProRow_' + a.ord + '_' + a.ptype])
		{
			bomadd.subProInfo['subProRow_' + a.ord + '_' + a.ptype].edit = '0';	//--取消编辑状态
		}
		else
		{
            var r = [];
            var i = 0;
			r[i++] = '';//0
			r[i++] = '0';
            r[i++] = '1';
            r[i++] = '';
            r[i++] = a.title;
            r[i++] = a.ord;//5
            r[i++] = a.ptype;
            r[i++] = a.BH;
            r[i++] = a.XH;
            r[i++] = a.UnitJB;
            r[i++] = '';//10
            r[i++] = '';
            r[i++] = a.ProductAttr1OptionIds;
            r[i++] = a.ProductAttr2OptionIds;
            r[i++] = a.UnitAll;
            r[i++] = 1;//15
            r[i++] = a.price2jy;
            r[i++] = a.price2;
            r[i++] = a.price1jy;
            r[i++] = a.SX;//20
            r[i++] = '';
            r[i++] = '';

            bomadd.lvw.rows.push(r);
			//bomadd.subProInfo['subProRow_' + a.ord + '_' + a.ptype] = {'pid':a.ord,'ptype':a.ptype,'index':r.length};
			bomadd.subProInfo['subProRow_' + a.ord + '_' + a.ptype] = {'pid':a.ord,'ptype':a.ptype,'edit':'0'};
		}
	}
}

bomadd.setTeLiProInfo = function(data){
	var a = eval("(" + data + ")");
	if (a.msg == 'true')
	{
        var r = [];
        var i = 0;
        r[i++] = '';//0
        r[i++] = '0';
        r[i++] = '1';
        r[i++] = '';
        r[i++] = a.title;
        r[i++] = a.ord;//5
        r[i++] = a.ptype;
        r[i++] = a.BH;
        r[i++] = a.XH;
        r[i++] = a.UnitJB;
        r[i++] = 0;//10
        r[i++] = 0;
        r[i++] = a.ProductAttr1OptionIds;
        r[i++] = a.ProductAttr2OptionIds;
        r[i++] = a.UnitAll;
        r[i++] = 1;
        r[i++] = a.price2jy;//15
        r[i++] = a.price2;
        r[i++] = a.price1jy;
        r[i++] = a.SX;
        r[i++] = '';
        r[i++] = '';
        bomadd.lvw.rows = [];
		bomadd.lvw.rows.push(r);
		//bomadd.subProInfo['subProRow_' + a.ord + '_' + a.ptype] = {'pid':a.ord,'ptype':a.ptype,'index':r.length};
		bomadd.subProInfo['subProRow_' + a.ord + '_' + a.ptype] = {'pid':a.ord,'ptype':a.ptype,'edit':'0'};
		
		var x = document.getElementById("Bom_Trees_View");
		x.contentWindow.bomadd.subProInfo = bomadd.subProInfo;
		x.contentWindow.bomadd.lvw = bomadd.lvw;
		if (x.contentWindow.bomadd.subPro.doTeliRefresh)
		{
			x.contentWindow.bomadd.subPro.doTeliRefresh();
		}
	}
}
//--检测子件产品是否重复,若有重复，返回true
bomadd.checkSubProInfo = function(json){
	for (var i in bomadd.subProInfo)
	{
		if (bomadd.subProInfo[i].pid == json.pid && bomadd.subProInfo[i].ptype == json.ptype && bomadd.subProInfo[i].edit != "1")
		{
			//confirm('产品重复');
			return true;
		}
	}
	return false;
}

//--获取产品结构类型，返回数组；
bomadd.getProType = function(){
	var json = {};
	json.__msgid = "getProType";
	var aj = $.ajax({
		type:'post',
		url:'add.asp',
		cache:false,  
		dataType:'html', 
		data:json,
		success: function(data){
			bomadd.subPro.protype = data;
			bomadd.subPro.init();
		},
		error:function(data){
			bomadd.subPro.protype = "[]";
		}
	});
}

bomadd.subPro = {};

bomadd.subPro.title = ['序号','类型','必选','编辑','产品名称','产品编号','产品型号','单位','数量','销售单价','标准单价','建议进价','产品属性','结构类型','结构编码','操作'];
bomadd.subPro.titleLength = [4,8,6,6,10,10,10,8,8,8,8,8,8,8,8,6];
//--产品结构类型
bomadd.subPro.protype = '';
//--【结构类型】批量修改标记，默认0 = 非批量修改
bomadd.subPro.protype_all = 0;
//--行数据模板
bomadd.subPro.mRows = '';
//--列表数据
bomadd.subPro.rows = [];
//--随机数
bomadd.subPro.rnd = '';
//--子件可移动范围
bomadd.subPro.tBodyRange = {top:'0',bottom:'0'};
//--行移动命名空间
bomadd.subPro.move = {};
//--被移动行序号
bomadd.subPro.move.rowIndex = {s:'0',e:'0'};
//--各子件【类型】ID
bomadd.subPro.move.SubType = {};
//--数据初始化
bomadd.subPro.init = function(){
	var rows;
	rows = [];
	//rows.push("[");
	rows.push("{cells:[");
	for (var i = 0; i < bomadd.subPro.title.length; i++)
	{
		switch (bomadd.subPro.title[i])
		{
			case '序号':
				rows.push("{id:'arrIndex',type:'arrIndex',index:'@arrIndex'},");	
				break;
			case '类型':
				rows.push("{id:'SubType',type:'select',text:'',val:'',options:[['固定','1'],['单选','2'],['复选','3']]},");	
				break;
			case '必选':
				rows.push("{id:'SubNotNull',type:'checkbox'},");	
				break;
			case '编辑':
				rows.push("{id:'SubEdit',type:'checkbox'},");	
				break;
			case '产品名称':
				rows.push("{id:'subPro',type:'CheckWindow',text:'',val:'',proType:'',action:''},");	
				break;
			case '产品编号':
				rows.push("{id:'subProBH',type:'text',text:''},");	
				break;
			case '产品型号':
				rows.push("{id:'subProXH',type:'text',text:''},");	
				break;
			case '单位':
				rows.push("{id:'subProUnit',type:'select',text:'',options:[]},");	
                break;
            case '产品属性1':
                rows.push("{id:'subProAttr1',type:'select',text:'',options:[]},");
                break;
            case '产品属性2':
                rows.push("{id:'subProAttr2',type:'select',text:'',options:[]},");
                break;
            case '数量':
				rows.push("{id:'subProNum',type:'numText',text:'',action:'bomadd.subPro.formatNumber'},");	
				break;
			case '销售单价':
				rows.push("{id:'subProPriceXS',type:'numText',text:'',action:'bomadd.subPro.formatNumber'},");	
				break;
			case '标准单价':
				rows.push("{id:'subProPriceBZ',type:'numText',text:'',action:'bomadd.subPro.formatNumber'},");	
				break;
			case '建议进价':
				rows.push("{id:'subProPriceJY',type:'numText',text:'',action:'bomadd.subPro.formatNumber'},");	
				break;
			case '产品属性':
				rows.push("{id:'subProSX',type:'text',text:''},");	
				break;
			case '结构类型':
				rows.push("{id:'p_proType',type:'select',text:'',options:" + bomadd.subPro.protype + ",action:'bomadd.ChangeProType'},");	
				break;
			case '结构编码':
				rows.push("{id:'p_proCode',type:'select',text:'',options:[]},");	
				break;
			case '操作':
				rows.push("{id:'p_action',type:'link',text:'删除'}");	
				break;
		}
	}
	rows.push("]}");
	//rows.push("]");
	rows = rows.join("\n");
	bomadd.subPro.mRows = rows;
	bomadd.subPro.createTable();
}
//bomadd.getProType();

//--格式化数据【序号】
bomadd.subPro.formatIndex = function(){
	if (bomadd.subPro.rows.length > 0)
	{
		for (var i = 0; i < bomadd.subPro.rows.leng; i++)
		{
			bomadd.subPro.rows[i].cells[0].index = i;
		}
	}
}

//--格式化表格【序号】
bomadd.subPro.formatTableIndex = function(tb){
	if (!tb)
	{
		var tb = bomadd.$ID("BOM_proList_Table");
	}
	var tBody = tb.children[1];
	for (var i = 0; i < tBody.rows.length; i++)
	{
		if (tBody.rows[i])
		{
			tBody.rows[i].cells[0].innerHTML = i + 1;
		}
	}
}

//--创建子件表格
bomadd.subPro.createTable = function(){
	var div = bomadd.$ID("BOM_proList_Div");
	var tb = document.createElement("table");
	tb.id = "BOM_proList_Table";
	tb.className = "lvwframe2";
	tb.style.cssText = "border-left:#cccddc 1px solid;border-right:#cccddc 1px solid";
	div.appendChild(tb);
	var tHead = bomadd.subPro.createHead();
	tb.appendChild(tHead);
	var tBody = bomadd.subPro.createBody();
	tb.appendChild(tBody);
	var tFoot = bomadd.subPro.createFoot();
	tb.appendChild(tFoot);
	bomadd.subPro.formatTableIndex(tb);
}
//--创建子件表头
bomadd.subPro.createHead =function(){
	var tHead = document.createElement("thead");
	var h1 = document.createElement("tr");
	var h2 = document.createElement("tr");
	h2.className = "subTop";
	bomadd.subPro.rnd = Math.random();
	for (var i = 0; i < bomadd.subPro.title.length; i++)
	{
		var cell_1 = document.createElement("td");
		//cell_1.innerText =  bomadd.subPro.title[i];
		var obj = null;
		switch (bomadd.subPro.title[i])
		{
			case '数量':
				obj = bomadd.subPro.createNumInput({'id':'','action':'bomadd.subPro.formatNumber_all'});
				break;
			case '结构类型':
				obj = bomadd.subPro.createSelect({'id':'p_proType_all','options':eval(bomadd.subPro.protype),'action':'bomadd.ChangeProType_all'});
				break;
			case '结构编码':
				obj = bomadd.subPro.createSelect({'id':'p_proCode_all','options':[],'action':'bomadd.ChangeProCode_all'});	
				break;
		}
		if (obj)
		{
			cell_1.appendChild(obj);
		}
		cell_1.className = "ctl_listview ctl_listviewbgtable";
		cell_1.setAttribute("width",bomadd.subPro.titleLength[i] + "%");
		h1.appendChild(cell_1);
		var cell_2 = document.createElement("th");
		cell_2.className = "lvwheader h_1";
		cell_2.setAttribute("width",bomadd.subPro.titleLength[i] + "%");
		cell_2.innerText = bomadd.subPro.title[i];
		h2.appendChild(cell_2);
	}
	tHead.appendChild(h1);
	tHead.appendChild(h2);
	return tHead;
}

//--创建子件表体
bomadd.subPro.createBody =function(){
	var tBody = document.createElement("tbody");
	var cells = bomadd.subPro.mRows;
	cells = eval(cells);
	bomadd.subPro.rows.push(cells);
	bomadd.subPro.formatIndex();
	var tr = bomadd.subPro.createLine(cells);
	tBody.appendChild(tr);
	return tBody;
}
//--新增空行
bomadd.subPro.addLine =function(){
	var tb = bomadd.$ID("BOM_proList_Table");
	var tBody = tb.children[1];
	var cells = bomadd.subPro.mRows;
	cells = eval(cells);
	bomadd.subPro.rows.push(cells);
	bomadd.subPro.formatIndex();
	var tr = bomadd.subPro.createLine(cells);
	tBody.appendChild(tr);
	bomadd.subPro.formatTableIndex();
	return tr;
}
//--新增产品对应行
bomadd.subPro.addDataLine =function(json){
	json.__msgid = "getProInfo";
	var aj = $.ajax({
		type:'post',
		url:'add.asp',
		cache:false,  
		dataType:'html', 
		data:json,
		success: function(data){
			var tb = bomadd.$ID("BOM_proList_Table");
			var tBody = tb.children[1];
			var cells = bomadd.subPro.mRows;
			cells = eval(cells);
			var a = eval("(" + data + ")");
			for (var i = 0; i < cells.length; i++)
			{
				switch (cells[i].id)
				{
					case "subPro":
						cells[i].text = a.title;
						cells[i].val = a.ord;
						cells[i].proType = a.ptype;
						break;
					case "subProBH":
						cells[i].text = a.BH;
						break;
					case "subProXH":
						cells[i].text = a.XH;
						break;
					case "subProPriceXS":
						cells[i].text = a.price2jy;
						break;
					case "subProPriceBZ":
						cells[i].text = a.price2;
						break;
					case "subProPriceJY":
						cells[i].text = a.price1jy;
						break;
					case "subProUnit":
						cells[i].options = a.Unit;
                        break;
                    case "subProAttr1":
                        cells[i].options = a.ProductAttr1;
                        break;
                    case "subProAttr2":
                        cells[i].options = a.ProductAttr2;
                        break;
					case "subProSX":
						cells[i].text = a.SX;
						break;
				}
			}
			bomadd.subPro.rows.push(cells);
			bomadd.subPro.formatIndex();
			var tr = bomadd.subPro.createLine(cells);
			tBody.appendChild(tr);
			tr.id = 'subProRow_' + a.ord + '_' + a.ptype;
			tr.setAttribute("del","0");
			bomadd.subPro.formatTableIndex();
		},
		error:function(data){
			
		}
	});
}

//--创建行
bomadd.subPro.createLine = function(cells){
	bomadd.subPro.rnd = Math.random();
	var tr = document.createElement("tr");
	tr.className = "BomList_Line";
	tr.onmousedown = function(){bomadd.subPro.move.MouseDown(this)}
	tr.onmouseover = function(){bomadd.subPro.move.rowIndex.e = this.rowIndex;}
	if (cells.constructor == Array && cells.length > 0)
	{
		for (var i = 0; i < cells.length; i++)
		{
			var c = document.createElement("td");
			c.className = "lvw_index str fcell";
			c.width = bomadd.subPro.titleLength[i] + "%";
			var d = document.createElement("div");
			d.className = "sub-field";
			var obj = null;
			switch (cells[i].type)
			{
				case "select":
					var obj = bomadd.subPro.createSelect(cells[i]);
					if (cells[i].notNull != "0")
					{
						c.setAttribute("nu","1");
						c.setAttribute("ei","1");
						c.setAttribute("ui","select");
						c.id = cells[i].id + (bomadd.subPro.rnd+"").replace(".","") + "_cel";
					}
					break;
				case "numText":
					var obj = bomadd.subPro.createNumInput(cells[i]);
					c.setAttribute("nu","1");
					c.setAttribute("ei","1");
					c.setAttribute("ui","select");
					c.id = cells[i].id + (bomadd.subPro.rnd+"").replace(".","") + "_cel";
					break;
				case "checkbox":
					var obj = bomadd.subPro.createCheckbox(cells[i]);
					break;
				case "CheckWindow":
					var html = [];
					html.push("<table style='width:100%'>");
					html.push("<tr><td>");
					html.push(cells[i].text);
					html.push("</td><td style='width:18px;'>");
					html.push("<button class='smselButton' onclick='bomadd.subPro.openProSelect()' onmousedown='stopBubble(event)'>");
					html.push("<img src='../../images/11645.png'/>");
					html.push("</button>");
					html.push("</td>");
					html.push("</tr>");
					html.push("</table>");
					c.innerHTML = html.join("\n");
					break;
				case "arrIndex":
					c.innerHTML = cells[i].index;
					break;
				case "link":
					c.innerHTML = "<a id='link" + (bomadd.subPro.rnd+"").replace(".","") + "' class='bom_addLine' href='javascript:void(0);' onclick='bomadd.subPro.delLine(this)' onmousedown='stopBubble(event)'>删除</a>";
					break;
				default:
					var obj = document.createElement("span");
					obj.innerText = cells[i].text;
			}
			if (obj)
			{
				d.appendChild(obj);
				c.appendChild(d);
				if (cells[i].type == "checkbox" && cells[i].id == "SubNotNull")
				{
					obj.checked = "checked";
					obj.setAttribute("disabled","disabled");
					obj.onclick = function(){bomadd.subPro.notNullClick(this)}//--必选复选框点击事件
				}
				if (cells[i].type == "select" && cells[i].id == "SubType")
				{
					obj.onchange = function(){bomadd.subPro.SubTypeChange(this)}//--子件类型下拉框切换事件
				}
				obj.onmousedown = function(event){stopBubble(event)}
				obj.setAttribute("isfield","1");
			}
			tr.appendChild(c);
		}
	}
	return tr;
}

//--删除子件行(主页面列表)
bomadd.subPro.delLine = function(obj){
	var td = obj.parentElement;
	var tr = td.parentElement;
	var tbody = tr.parentElement;
	var id = obj.id;
	id = "SubType" + id.replace("link","");
	delete bomadd.subPro.move.SubType[id];
	tbody.removeChild(tr);
	bomadd.subPro.formatTableIndex();
}
//--删除子件行(弹窗)
bomadd.subPro.delPro = function(obj){
	var pid = obj.getAttribute("pid");
	var ptype = obj.getAttribute("ptype");
	var n = 0;
	for (var i in bomadd.subProInfo)
	{
		if (bomadd.subProInfo[i].pid == pid && bomadd.subProInfo[i].ptype == ptype)
		{
			//bomadd.lvw.rows[bomadd.subProInfo[i].index] = [];
			delete bomadd.subProInfo[i];
		}
		else
		{
			n = n + 1;
		}
	}
	var r = bomadd.lvw.rows;
	for (var i = r.length - 1; i >= 0; i --)
	{
		if (r[i][5] == pid && r[i][6] == ptype)
		{
			r.splice(i,1);
		}
	}
	var td = obj.parentElement;
	var tr = td.parentElement;
	var tb = tr.parentElement.parentElement;
	try
	{
		tr.removeNode(true);
	}
	catch (e)
	{
		// firefox 没有 removeNode 方法
		tr.parentNode.removeChild(tr);
	}
	
	if (tb.tagName.toLowerCase() == "table")
	{
		for (var i = 1; i < tb.rows.length; i++)
		{
			tb.rows[i].cells[0].innerText = i;
		}
	}
	if (n == 0)
	{
		bomadd.$ID("trpx0").style.display = "block";
	}
}

//--根据JSON，创建下拉框
bomadd.subPro.createSelect = function(json){
	var rnd = bomadd.subPro.rnd;
	var select = document.createElement("select");
	select.setAttribute("name",json.id);
	select.id = json.id + (rnd + '').replace('.','');
	if (json.id == "SubType")
	{
		bomadd.subPro.move.SubType[select.id] = "1";		//--存储对象，用来遍历
	}
	select.className = "select";
	if (json.action)
	{
		select.onchange = function(){eval(json.action + "(this)")}
	}
	var opts = json.options;
	if (json.id == "subProUnit" && opts.length > 0)
	{
		$(select).append(opt);
	}
	else
	{
		if (opts.constructor == Array && opts.length > 0)
		{
			for (var i = 0; i < opts.length; i++)
			{
				var opt = document.createElement("option");
				opt.value = opts[i][1];
				opt.innerText = opts[i][0];
				select.appendChild(opt);
			}
		}
		else
		{
			var opt = document.createElement("option");
			opt.value = '';
			opt.innerText = '请选择';
			select.appendChild(opt);
		}
	}
	return select;
}
//--创建数字输入框
bomadd.subPro.createNumInput = function(json){
	var rnd = bomadd.subPro.rnd;
	var input = document.createElement("input");
	input.setAttribute("name",json.id);
	input.id = json.id + (rnd + '').replace('.','');
	input.type = "text";
	input.className = "number";
	if (json.action)
	{
		$(input).bind('input propertychange',function(){eval(json.action + "(this)");}); 
	}
	return input;
}

//--创建复选框
bomadd.subPro.createCheckbox = function(json){
	var rnd = bomadd.subPro.rnd;
	var input = document.createElement("input");
	input.setAttribute("name",json.id);
	input.id = json.id + (rnd + '').replace('.','');
	input.type = "checkbox";
	input.value = "1";
	return input;
}
//--创建表格底部
bomadd.subPro.createFoot = function(){
	var tFoot = document.createElement("tfoot");
	var tr = document.createElement("tr");
	var td = document.createElement("td");
	td.innerHTML = "<a class='bom_addLine' href='javascript:void(0);' onclick='bomadd.subPro.addLine()''>添加新行</a>";
	td.className = "lvw_cell";
	td.colSpan = bomadd.subPro.title.length;
	td.style.cssText = "padding-left:10%";
	tr.appendChild(td)
	tFoot.appendChild(tr);
	return tFoot;
}

//--获取交换用div
bomadd.subPro.move.getSwapDiv = function(){
	var div = bomadd.$ID("BOM_proList_SwapDiv");
	if (!div)
	{
		var div = document.createElement("div");
		div.id = "BOM_proList_SwapDiv";
		div.className = "BOM_proList_SwapDiv";
		document.body.appendChild(div);
	}
	return div;
}
//--显示交换用层
bomadd.subPro.move.MouseDown = function(obj){//bomadd.subPro.tBodyRange
	while (obj.className != "BomList_Line" && obj.tagName.toLowerCase() != "body")
	{
		obj = obj.parendElement;
	}
	if (obj.tagName.toLowerCase() == "tr")
	{
		var o  = obj.cloneNode(true);
		var tb = bomadd.$ID("BOM_proList_Table");
		var tBody = tb.children[1];
		//--设置移动起始点
		bomadd.subPro.move.rowIndex.s = obj.rowIndex;
		//tBody.insertBefore(tBody.rows[3],tBody.rows[2]);
		//--设置可移动范围
		bomadd.subPro.tBodyRange.top = $(tBody).offset().top;
		bomadd.subPro.tBodyRange.bottom = $(tBody).offset().top + $(tBody).height() - $(obj).height();
		//--显示移动容器
		var div = bomadd.subPro.move.getSwapDiv();
		var offset = $(obj).offset();
		div.setAttribute("canMove","1");
		div.style.display = "block";
		div.style.left = offset.left + "px";
		div.style.top = offset.top + "px";
		div.style.width = ($(obj).width() + 2) + "px";
		div.style.height = $(obj).height() + "px";
		//div.style.border = "1px solid red";
		div.innerHTML = "<table class='lvwframe2'style='border:none;background:none'></table>";
		div.children[0].children[0].appendChild(o);
		
		ev= e || window.event;
		if(ev.pageX || ev.pageY){ 
			var mousePos = {x:ev.pageX, y:ev.pageY};
		}
		else{
			var mousePos = {
				x:ev.clientX + document.body.scrollLeft - document.body.clientLeft, 
				y:ev.clientY + document.body.scrollTop - document.body.clientTop
			};
		}
		var y = mousePos.y;
		div.setAttribute("preY",y);

		document.body.onmouseup = function(){bomadd.subPro.move.MouseUp()}
		document.body.onmousemove = function(){bomadd.subPro.move.MouseMove()}
		document.body.onselectstart = function(){return false}
	}
}
//--鼠标弹出事件
bomadd.subPro.move.MouseUp = function(){
	bomadd.subPro.move.swapRows();		//--行交换
	var div = bomadd.subPro.move.getSwapDiv();
	div.style.display = "none";
	div.setAttribute("canMove","0");
	document.body.onselectstart = null;
	document.body.onmousemove = null;
}
//--鼠标移动事件
bomadd.subPro.move.MouseMove = function(e){
	ev= e || window.event;
	if(ev.pageX || ev.pageY){ 
		var mousePos = {x:ev.pageX, y:ev.pageY};
	}
	else{
		var mousePos = {
			x:ev.clientX + document.body.scrollLeft - document.body.clientLeft, 
			y:ev.clientY + document.body.scrollTop - document.body.clientTop
		};
	}
	//alert(ev.pageX);
	//document.title = mousePos.x;
	//document.title = mousePos.y;
	var y = mousePos.y;
	var div = bomadd.subPro.move.getSwapDiv();
	var preY = div.getAttribute("preY");
	if (!preY)
	{
		div.setAttribute("preY",y);
		var preY = y;
	}
	if (y - preY != 0)
	{
		var yy = $(div).offset().top + (y - preY);
		if (yy < bomadd.subPro.tBodyRange.top)
		{
			yy = bomadd.subPro.tBodyRange.top;
		}
		if (yy > bomadd.subPro.tBodyRange.bottom)
		{
			yy = bomadd.subPro.tBodyRange.bottom;
		}
		div.style.top = yy + "px";
		div.setAttribute("preY",y);
	}
}
//--移动行交换
bomadd.subPro.move.swapRows = function(){
	var div = bomadd.subPro.move.getSwapDiv();
	var canMove = div.getAttribute("canMove");
	if (canMove == "1")
	{
		var tb = bomadd.$ID("BOM_proList_Table");
		var tHead = tb.children[0];
		var t = tHead.rows.length;
		var tBody = tb.children[1];
		var s = bomadd.subPro.move.rowIndex.s;
		var e = bomadd.subPro.move.rowIndex.e;
		tBody.insertBefore(tBody.rows[s-t],tBody.rows[e-t]);
		bomadd.subPro.formatTableIndex();
	}
}

//--切换相同【类型】子件的【必选】状态
bomadd.subPro.notNullClick = function(obj){
	var id = obj.id;
	id1 = "SubType" + id.replace("SubNotNull","");
	for (var i in bomadd.subPro.move.SubType)
	{
		if (bomadd.subPro.move.SubType[i] == bomadd.subPro.move.SubType[id1])
		{
			var id2 = "SubNotNull" + i.replace("SubType","");
			$("#" + id2).attr("checked",obj.getAttribute("checked"))
		}
	}
}

//--切换子件【类型】，更新【必填】复选框状态
bomadd.subPro.SubTypeChange = function(obj){
	var v = obj.value;
	var id = obj.id;
	bomadd.subPro.move.SubType[id] = v;
	id1 = "SubNotNull" + id.replace("SubType","");
	var n = bomadd.$ID(id1);
	switch (v)
	{
		case "1":
			n.setAttribute("checked","checked");
			n.setAttribute("disabled","disabled");
			break;
		default:
			$("#" + id1).removeAttr("disabled");
			for (var i in bomadd.subPro.move.SubType)
			{
				if (bomadd.subPro.move.SubType[i] == v && i != id)
				{
					var o = bomadd.$ID("SubNotNull" + i.replace("SubType",""));
					$("#" + id1).attr("checked",o.getAttribute("checked"))
					break;
				}
			}
			break;
	}
}

//--键入数字时，数字验证
bomadd.subPro.formatNumber = function(obj){
	if (obj.value != "" && obj.value * 1 != FormatNumber(obj.value,window.sysConfig.floatnumber) * 1)
	{
		obj.value = FormatNumber(obj.value,window.sysConfig.floatnumber);
		if (obj.value * 1 > 999999999999)
		{
			obj.value = FormatNumber(999999999999,window.sysConfig.floatnumber);
		}
	}
}
//--键入数字时，批量修改
bomadd.subPro.formatNumber_all = function(obj){
	if (obj.value != "" && obj.value * 1 != FormatNumber(obj.value,window.sysConfig.floatnumber) * 1)
	{
		obj.value = FormatNumber(obj.value,window.sysConfig.floatnumber);
		if (obj.value * 1 > 999999999999)
		{
			obj.value = FormatNumber(999999999999,window.sysConfig.floatnumber);
		}
	}
	for (var i in bomadd.subPro.move.SubType)
	{
		var o = bomadd.$ID("subProNum" + i.replace("SubType",""));
		if (o)
		{
			o.value = FormatNumber(obj.value,window.sysConfig.floatnumber);
		}
	}
}

bomadd.subPro.openProSelect = function(){
	//if (bomadd.parentPro.pid * 1  == 0)
	//{
		//app.Alert("请先选择父件产品！");
		//return;
	//}
	var tb = bomadd.$ID("BOM_proList_Table");
	var tBody = tb.children[1];
	var rows = tBody.rows;
	for (var i = 0; i < rows.length; i++)
	{
		rows[i].removeAttribute("del");
	}
	window.open('add_top.asp','bom_list_add_top','width=' + 1350 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=100');
	return false;
}
//--子件选择页面保存事件
bomadd.subPro.doSave = function(){
	opener.window.bomadd.subProInfo = bomadd.subProInfo;
	opener.window.bomadd.lvw = bomadd.lvw;
	if (opener.window.bomadd.subPro.doRefresh)
	{
		opener.window.bomadd.subPro.doRefresh();
	}
	window.close();
}
//--主页面子件列表刷新
bomadd.subPro.doRefresh = function(){
	var lvw = window.lvw_JsonData_bllst_clist;
	var h = lvw.headers;
	var proIndex = 0;
	var ptypeIndex = 0;
	for (var i = 0; i < h.length; i++)
	{
		if (h[i].dbname == 'proOrd')
		{
			proIndex = i;
		}
		if (h[i].dbname == 'proType')
		{
			ptypeIndex = i;
		}
	}
	var r = lvw.rows;
	lvw.recordcount = r.length;
	//--移除被删除的行
	for (var i = r.length - 1; i >= 0; i --)
	{
		if (!bomadd.subProInfo['subProRow_' + r[i][proIndex] + '_' + r[i][ptypeIndex]])
		{
			r.splice(i,1);
		}
		else
		{
			delete bomadd.subProInfo['subProRow_' + r[i][proIndex] + '_' + r[i][ptypeIndex]];
		}
		//--移除空行
		if (r[i] && (r[i][proIndex] == 0 || r[i][proIndex].length == 0))
		{
			r.splice(i,1);
		}
	}
	var r = bomadd.lvw.rows;
	for (var i = r.length - 1; i >= 0; i --)
	{
		if (!bomadd.subProInfo['subProRow_' + r[i][proIndex] + '_' + r[i][ptypeIndex]])
		{
			r.splice(i,1);
		}
	}
	for (var i = 0; i < bomadd.lvw.rows.length; i++)
	{
		var a = [];
		for (var ii = 0; ii < bomadd.lvw.rows[i].length; ii++)
		{
			a[ii] = bomadd.lvw.rows[i][ii];
		}
		lvw.rows.push(a);
		//lvw.rows.push(bomadd.lvw.rows[i]);
	}
	lvw.doSum();
	___RefreshListViewByJson(lvw);
	window.onlvwUpdateRows(lvw);
}

//--特例添加页面子件列表刷新
bomadd.subPro.doTeliRefresh = function(){
	var lvw = window.lvw_JsonData_bllst_clist;
	var h = lvw.headers;
	var proIndex = 0;
	var ptypeIndex = 0;
	for (var i = 0; i < h.length; i++)
	{
		if (h[i].dbname == 'proOrd')
		{
			proIndex = i;
		}
		if (h[i].dbname == 'proType')
		{
			ptypeIndex = i;
		}
	}
	var r = lvw.rows;
	lvw.recordcount = r.length;
	//--移除被删除的行
	for (var i = r.length - 1; i >= 0; i --)
	{
		//if (!bomadd.subProInfo['subProRow_' + r[i][proIndex] + '_' + r[i][ptypeIndex]])
		//{
			//r.splice(i,1);
		//}
		//else
		//{
			//delete bomadd.subProInfo['subProRow_' + r[i][proIndex] + '_' + r[i][ptypeIndex]];
		//}
		//--移除空行
		if (r[i] && (r[i][proIndex] == 0 || r[i][proIndex].length == 0))
		{
			r.splice(i,1);
		}
	}
	var r = bomadd.lvw.rows;
	for (var i = r.length - 1; i >= 0; i --)
	{
		if (!bomadd.subProInfo['subProRow_' + r[i][proIndex] + '_' + r[i][ptypeIndex]])
		{
			r.splice(i,1);
		}
	}
	for (var i = 0; i < bomadd.lvw.rows.length; i++)
	{
		var a = [];
		for (var ii = 0; ii < bomadd.lvw.rows[i].length; ii++)
		{
			a[ii] = bomadd.lvw.rows[i][ii];
		}
		lvw.rows.push(a);
		//lvw.rows.push(bomadd.lvw.rows[i]);
	}
	lvw.doSum();
	___RefreshListViewByJson(lvw);
}

//--页面间数据转换
bomadd.getlvwPro = function(){
	//--获取父页面子件数据
	try
	{
		var lvw = opener.window.lvw_JsonData_bllst_clist;
	}
	catch (e)
	{
		//confirm(e.message);
	}
	var r = lvw.rows;
	for (var i = 0; i < r.length; i++)
	{
		bomadd.subProInfo['subProRow_' + r[i][5] + '_' + r[i][6]] = {'pid':r[i][5],'ptype':r[i][6],'index':i};
		//bomadd.subProInfo1.push({'pid':r[i][5],'ptype':r[i][6],'index':i});
	}
}
//--保存前检查子件产品
bomadd.beforeSave = function(){
	if (document.getElementById("remark_editor"))
	{
		try
		{
			var remark = remark_editor.getHTML();
		}
		catch (e)
		{
			var remark = remark_editor.contentWindow.getHTML();
		}
		if (remark.length > 2000)
		{
			app.Alert("备注信息不得超过2000字！");
			return false;
		}
	}
	var p_proType_0 = document.getElementById("p_proType_0");
	var p_proCode_0 = document.getElementById("p_proCode_0");
	if (p_proType_0 && p_proCode_0)
	{
		if (p_proType_0.value.length > 0 && p_proCode_0.value.length == 0)
		{
			app.Alert("请选择父件结构编码！");
			try
			{
				p_proCode_0.focus();
			}
			catch (e)
			{
			}
			return false;
		}
	}
	
	var lvw = window.lvw_JsonData_bllst_clist;
	var rows = lvw.rows;
	var n = 0;
	var m = 0;
	var x = 0;
	var nulltr = -1;
	for (var i = 0; i < rows.length; i++)
	{
		if (rows[i][5] > 0)
		{
			n = n + 1;
		}else{
			if (nulltr == -1 && rows[i][5]<=0){
				nulltr = i;
			}
		}
		if (rows[i][11] > 99999999)
		{
			m = m + 1;
			break;
		}
		if (rows[i][11] < 0)
		{
			x = x + 1;
			break;
		}
	}
	if (n == 0)
	{
		app.Alert("请选择子件！");
		return false;
	}else if(nulltr>=0){
		lvw.selpos = nulltr;	
		___RefreshListViewselPos(lvw);
		app.Alert("请选择子件！");
		return false;
	}
	if (m > 0)
	{
		lvw.selpos = i;
		___RefreshListViewselPos(lvw);
		app.Alert("子件数量不可以超过99999999！");
		return false;
	}
	if (x > 0)
	{
		lvw.selpos = i;
		___RefreshListViewselPos(lvw);
		app.Alert("子件数量不可以小于0！");
		return false;
    }
	var a = ['1','2','3','5','6','9','10','11','15','16','17','18','20','21'];
	var b = ['sType','notNull','canEdit','proOrd','proType','unit',"ProductAttr1","ProductAttr2",'num','PriceXS','PriceBZ','PriceJY','sProType','sCode'];
	var index = {};
	for (var ii = 0; ii < a.length; ii++)
	{
		index[b[ii]] = a[ii];
	}
	for (var i = 0; i < rows.length; i++)
	{
		for (var ii = 0; ii < b.length; ii++)
		{
			if (rows[i][index['sProType']] > 0 && rows[i][index['sCode']] == 0)
			{
				app.Alert("请选择子件结构编码！");
				lvw.selpos = i;
				___RefreshListViewselPos(lvw);
				return false;
				break;
			}
			var input = document.getElementById("s_" + b[ii] + "_0");
			var v = input.value;
			if (!rows[i][index[b[ii]]])
			{
				rows[i][index[b[ii]]] = '0';
			}
			if (rows[i][index[b[ii]]].length == 0)
			{
				rows[i][index[b[ii]]] = '0';
			}
			if (i == 0)
			{
				v = rows[i][index[b[ii]]] + "";
			}
			else
			{
				v = v + ',' + rows[i][index[b[ii]]] + "";
			}
			input.value = v;

		}
	}
	return true;
}

bomadd.copy = function(obj){
	window.location.href = "?bomord=" + bomadd.ord;
}
bomadd.edit = function(obj){
	window.location.href = "?add=1&bomord=" + bomadd.ord;
}

bomadd.showErrProInfo = function(pord, ptype, unit){
	var lvw = window.lvw_JsonData_bllst_clist;
	var h = lvw.headers;
	var pordIndex = -1;
	var ptypeIndex = -1;
	var unitIndex = -1;
	for (var i = 0; i < h.length; i++)
	{
		if (h[i].dbname == "proOrd")
		{
			pordIndex = i;
		}
		if (h[i].dbname == "proType")
		{
			ptypeIndex = i;
		}
		if (h[i].dbname == "单位")
		{
			unitIndex = i;
		}
	}
	var rows = lvw.rows;
	for (var i = 0; i < rows.length; i++)
	{
		if (rows[i][pordIndex] == pord && rows[i][ptypeIndex] == ptype &&  rows[i][unitIndex] == unit)
		{
			lvw.selpos = i;
			___RefreshListViewselPos(lvw);
			break;
		}
	}
}

//--产品选择页面加载父页面产品
window.onload = function(){
	if (bomadd.addAction == "0")
	{
		//bomadd.subProInfo = opener.window.bomadd.subProInfo;
		bomadd.getlvwPro();
		//for (var i = 0; i < bomadd.subProInfo1.length; i++)
		var arr = [];
		var x = 0
		for (var i in bomadd.subProInfo)
		{
			if (bomadd.subProInfo[i].pid > 0)
			{
				x += 1;
				bomadd.subProInfo[i].edit = "1";			//--标记为编辑模式
				//bomadd.getProInfo(bomadd.subProInfo[i]);
				arr.push(bomadd.subProInfo[i].pid + String.fromCharCode(2) + bomadd.subProInfo[i].ptype);
			}
		}
		if(x == 0){return false;}
		var data = arr.join(String.fromCharCode(1));
		//confirm(data);
		var aj = $.ajax({
			type: 'post',
			url: 'add.asp' ,
			cache:false,  
			dataType:'html', 
			data: {
				'__msgid':'getProInfos',
				'data':data
			},
			success: function(data){
				//confirm(data)
				var arr = data.split(String.fromCharCode(1));
				for (var i = 0; i < arr.length; i++)
				{
					bomadd.setSubProInfo(arr[i]);
				}
			},
			error:function(data){
				
			}
		});
	}
}

function stopBubble(e){
//一般用在鼠标或键盘事件上
	if(e && e.stopPropagation){
		//W3C取消冒泡事件
		e.stopPropagation();
	}else{
		//IE取消冒泡事件
		window.event.cancelBubble = true;
	}
	
}
//--页面验证回调函数
window.onbillTbValid = function(){
	if (bomadd.beforeSave())
	{
	    if (bomadd.addAction == "2") //特例编辑
		{
			var isTemp_0 = document.getElementById("isTemp_0");
			if (bomadd.treeType=="1" && confirm("是否更新到组装清单？"))
			{
				isTemp_0.value = "0"
			}
			else
			{
				isTemp_0.value = "1"
			}
			if (top && top.document && top.document.body)
			{
				top.window.unload = function(){
				//--保存后的响应事件
					if (top.opener && top.opener.window.onTeLiAddSave)
					{
						window.setTimeout(
							function(){;
								top.opener.window.onTeLiAddSave(bomadd.TeLiAddTreeOrd, bomadd.TeLiAddBomOrd, bomadd.mxid);
								top.window.close();
							},500
						);
					}
				}
			}
		}
		return true;
	}
	else
	{
		return false;
	}
	//return bomadd.beforeSave();
}


window.onlvwUpdateCellValue = function(id, rowindex, cellindex, v){
	var lvw = eval("lvw_JsonData_" + id);
	var h = lvw.headers[cellindex];
	if(h.dbname == "类型") {		//--【类型】下拉框切换，【必选】框联动
		if (v == 0)
		{
			lvw.rows[rowindex][h.i+1] = 1;
		}
		else
		{
			for (var i = 0; i < lvw.rows.length; i++)
			{
				if (lvw.rows[i][h.i] == lvw.rows[rowindex][h.i] && i != rowindex)
				{
					lvw.rows[rowindex][h.i + 1] = lvw.rows[i][h.i+1];
					continue;
				}
			}
		}
		//___RefreshListViewByJson(lvw);
	}
	if (h.dbname == "必选")		//--【必选】复选框，根据【类型】联动
	{
		var t = lvw.rows[rowindex][h.i-1];
		for (var i = 0; i < lvw.rows.length; i++)
		{
			if (lvw.rows[i][h.i-1] == t)
			{
				lvw.rows[i][h.i] = v;
			}
		}
		___RefreshListViewByJson(lvw);
	}
	if (h.dbname == "单位")		//--【单位】切换
	{
		var unit = lvw.rows[rowindex][h.i];
		var icpord, iprice1jy, iprice2jy, iprice2;
		icpord= 0; iprice1jy = 0; iprice2jy = 0; iprice2 = 0;
		var cpord = 0;
		for (i=0; i<lvw.headers.length ; i++){
			switch(lvw.headers[i].dbname){
			case "proOrd":
				icpord = i; break;
			case "销售单价":
				iprice2jy = i; break;
			case "标准单价":
				iprice2 = i; break;
			case "建议进价":
				iprice1jy = i; break;
			}
		}
		cpord = lvw.rows[rowindex][icpord];

		$.ajax({
			type: 'post',
			url: 'add.asp' ,
			async:false,
			cache:false,  
			data: {
				'__msgid':'changeUnit',
				'ord':cpord,
				'unit':unit
			},
			success: function(data){
				//confirm(data)
				var arr_ret = data.split(String.fromCharCode(1));
				var price1jy = "";
				var price2jy = "";
				var price2 = "";
				if(arr_ret.length>0){
					price1jy = arr_ret[0];
					price2jy = arr_ret[1];
					price2 = arr_ret[2];
				}
				if (price1jy!=""){lvw.rows[rowindex][iprice1jy]=price1jy;	}
				if (price2jy!=""){lvw.rows[rowindex][iprice2jy]=price2jy;	}
				if (price2!=""){lvw.rows[rowindex][iprice2]=price2;	}
				___RefreshListViewByJson(lvw);
				lvw.doSum();
			},
			error:function(data){
				
			}
		});
	}

	window.onlvwUpdateRows(lvw);
}

window.onlvwUpdateRows = function(lvw){
	getSumPrice(lvw);
}

function getSumPrice(lvw){
	var mxtype, num1, PriceXS, PriceBZ, PriceJY, MaxPriceXS, MaxPriceBZ, MaxPriceJY, SumPriceXS, SumPriceBZ, SumPriceJY;
	var i, i1, i2, i3, i4, i5;
	PriceXS = 0; PriceBZ=0; PriceJY = 0; num1=1;
	MaxPriceXS = 0; MaxPriceBZ=0; MaxPriceJY = 0; SumPriceXS = 0; SumPriceBZ=0; SumPriceJY = 0;
	setTimeout(function(){
		for (i=0; i<lvw.headers.length ; i++){
				switch(lvw.headers[i].dbname){
				case "数量":
					i2 = i; break;
				case "销售单价":
					i3 = i; break;
				case "标准单价":
					i4 = i; break;
				case "建议进价":
					i5 = i; break;
				}
		}	
		
		for (i = 0; i<lvw.rows.length; i++){
			num1 = Number(lvw.rows[i][i2].toString().replace(/,/g,''));
			PriceXS = Number(lvw.rows[i][i3].toString().replace(/,/g,''));
			PriceBZ = Number(lvw.rows[i][i4].toString().replace(/,/g,''));
			PriceJY = Number(lvw.rows[i][i5].toString().replace(/,/g,''));
			SumPriceXS += PriceXS * num1;
			SumPriceBZ += PriceBZ * num1;
			SumPriceJY += PriceJY * num1;
		}
		
		try{
			$ID("sumPriceXS_0").value = FormatNumber(SumPriceXS, window.sysConfig.SalesPriceDotNum);
			$ID("sumPriceBZ_0").value = FormatNumber(SumPriceBZ, window.sysConfig.SalesPriceDotNum);
			$ID("sumPriceCB_0").value = FormatNumber(SumPriceJY, window.sysConfig.moneynumber);
		}catch(e){}
	},10);
}
//--产品添加——保存后回调函数
function cptj(ord,top) {
	window.setTimeout(function(){LVSelectProduct(ord)},1000);
}

//__lvw_je_redrawCell(lvw,h, rowindex,iii)

//--图片自动缩小
window.__ShowImgBigToSmall=true ;

//--特例添加，子件列表删除事件扩展
if (window.__lvw_je_btnhandle)
{
	window.__user_lvw_je_btnhandle = window.__lvw_je_btnhandle;
	window.__lvw_je_btnhandle = function(btn, ht){
		if (ht == "2" && bomadd.addAction == '2')
		{
			bomadd.beforeSubproDel(btn);
		}
		window.__user_lvw_je_btnhandle(btn, ht)
	}
}

bomadd.beforeSubproDel = function(btn){
	var lvw = window.lvw_JsonData_bllst_clist;
	//bomadd.subProInfo['subProRow_' + a.ord + '_' + a.ptype]
	var tr = btn.parentElement.parentElement;
	var pos = tr.getAttribute("pos");
	var rows = lvw.rows;
	var pid = rows[pos][5];
	var ptype = rows[pos][6];
	delete bomadd.subProInfo['subProRow_' + pid + '_' + ptype];
}