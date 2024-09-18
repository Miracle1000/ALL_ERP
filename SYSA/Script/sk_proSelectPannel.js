
function autoHeight(){
	parent.$('#__proSelectPannel').height($('#cp_search').height()+$('#productTree').height()+280);
}

function colspanAll(){
	$.ajax({
		url:'../store/CommonReturn.asp',
		data:{act:'leftlist',leftlist:1},
		async:false,
		cache:false,
		success:function(r){
			$('#__tree_toggle_btn').attr('state','2').html('<u>全部展开</u>');
			$('#cp_search').hide();
			$('#productTree').show();
			$('.tree-lastfolder-open,.tree-folder-open').trigger('click');
		}
	});
}

function expandAll(){
	$.ajax({
		url:'../store/CommonReturn.asp',
		data:{act:'leftlist',leftlist:2},
		async:false,
		cache:false,
		success:function(r){
			$('#__tree_toggle_btn').attr('state','1').html('<u>全部收缩</u>');
			$('#cp_search').hide();
			$('#productTree').show();
			$('.tree-lastfolder-closed,.tree-folder-closed').each(function(){
				__toggleNode(this,true);
			});
		}
	});
}

function callServer4(pid){
	var arr_item;
	var mxCount=Number(parent.$ID("mxCount").value);
	parent.ajax.regEvent("addProduct");
	parent.$ap("cpord",pid);
	parent.$ap("htord",0);
	parent.$ap("htlId",0);
	parent.$ap("timestamp",new Date().getTime());	
	var r = parent.ajax.send();
	if(r != ""){
		var newData
		var arr_res = r.split("\3\5");
		if (arr_res[0]=="1" && arr_res[1] != ""){
			var ArrDatalist = arr_res[1].split("\4\6");
			for (var i =0; i< ArrDatalist.length; i++ ){
				newData = ArrDatalist[i].split("\1\2");
				parent.lvw_InsertRow("mlistvw", newData);
			}	
			mxCount += ArrDatalist.length;
			parent.$ID("mxCount").value = mxCount;
			var arr_index = parent.$(".lvw_index");
			var indexTab = "";
			var indexTd = ""
			for(var i = 0; i< arr_index.length; i++){
				indexTab = arr_index[i].childNodes[0];
				indexTd = indexTab.rows.item(0).cells[1];
				indexTd.innerHTML = i+1;
			}
		}else if(arr_res[0]=="2"){
			parent.app.Alert("添加失败，可添加产品数超过系统设定数量");
		}else if(arr_res[0]=="3"){
			parent.app.Alert("参数丢失，请重新登录");
		}else{
			parent.app.Alert(r);//app.Alert("数据保存错误，请刷新后重试");
		}
	}
}

function nodeClick(e,node){
	var $node = $(node);
	callServer4($node.attr('nid'));
}

function ajaxSubmit_page(sort1,pagenum,callBack){
	$('#productTree').hide();
	$('#cp_search').show();
	//获取用户输入
	var B=document.forms[0].B.value;
	var C=(document.forms[0].C.value==$("#txtKeywords").get(0).defaultValue?"":document.forms[0].C.value);
	var top=document.forms[0].top.value;
	//cstore：表示是否要求显示能出库的产品，即只显示实体产品
	var cstore = 1;
	try {
		cstore = document.forms[0].cstore.value;
	} catch (e) {}
	var url = "../contract/search_cp.asp?cstore="+cstore+"&P="+pagenum+"&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	try{
		if(parent.searchModel==1){
			//处理高级搜索
			parent.document.getElementById("adsIF").contentWindow.document;
			var ifcobj=parent.document.getElementById("adsIF").contentWindow.document;
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
			sobj=ifcobj.getElementsByName("A2");
			var tmp="";
			for(var i=0;i<sobj.length;i++){
				if(sobj[i].checked){
					tmp+=(tmp==""?"":",")+escape(sobj[i].value);
				}
			}
			txValue+=(tmp==""?"":(txValue==""?"":"&")+"A2="+tmp)
			url="../contract/search_cp.asp?cstore="+cstore+"&ads=1"+(txValue==""?"":"&")+txValue+"&P="+pagenum+"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		}
	}catch (e){}

	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_cp(callBack)};
	xmlHttp.send(null);  
}

parent.ajaxSubmit_page = ajaxSubmit_page ;

function updatePage_cp(callBack){
	if (xmlHttp.readyState == 4){
		var response = xmlHttp.responseText;
		cp_search.innerHTML=response;
		autoHeight();
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
	var url = "../product/txmRKnew.asp?cstore=1&txm="+escape(TxmID)+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updateTxm(top);};
	xmlHttp.send(null);
}

function updateTxm(x1){
	if (xmlHttp.readyState == 4){
		var response = xmlHttp.responseText;
		if (response!=""){
			callServer4(response);
		}else{
			alert("产品不存在");
		}
	}
}

function Left_adSearch(){
	var $dv = parent.$('#adsDiv');
	if($dv.size()==0){
		$dv=$("#adsDiv").clone()
		$dv.appendTo(parent.document.body).show();
	}
	var frm=parent.$("#adsIF").get(0);
	$dv.css({left:218,top:40});
	var h=$dv.attr('_h');
	if($dv.attr('disp')==1){
		$dv.hide().attr('disp',0);
		$('#__adv_search_btn').val("高级");
	}else{
		$dv.show().attr('disp',1);
		if(h!='undefined'){
			$dv.height(h);
			$(frm).height(h);
		}else{
			$dv.css({height:$(frm).height()});
		}
		$('#__adv_search_btn').val("收回");
	}
}

function Left_adClose(){
	var $dv = parent.$('#adsDiv');
	if($dv.attr('disp')==1){Left_adSearch();}
}

parent.Left_adClose = function(){
	var $div = parent.$("#adsDiv");
	$div.hide().attr({disp:0,_h:$div.height()});
	parent.$('#__proSelectPannel').get(0).contentWindow.$('#__adv_search_btn').val("高级");
};

function ajaxSubmit(sort1){
	var B=document.forms[0].B.value;
	var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
	//cstore=1表示只查询实体产品.Task.1440.binary.2014.03.09
	var cstore = 1;
	try {
		cstore = document.forms[0].cstore.value;
	} catch (e) {}
	var url = "../contract/search_cp.asp?cstore="+cstore+"&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4){
			var response = xmlHttp.responseText;
			cp_search.innerHTML=response;
			autoHeight();
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);  
}
