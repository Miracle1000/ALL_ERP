
function nodeClick(e,node){
	var $node = $(node);
	LVSelectProduct($node.attr('nid'));
}

function LVSelectProduct(pid) {
    try { //判断父页面是否直接出库
        if (window.parent.location.href.indexOf("/addck.asp") > 0 && typeof (eval("parent.LVSelectProduct")) == "function") {
            parent.LVSelectProduct(pid);
            return;
        }
    }
    catch (e) { }
	url="../store/addlistadd_rk.asp?lv=1&ord="+escape(pid)+"&t="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send(null);
	var jsonobj=eval(xmlHttp.responseText);
	xmlHttp.abort();
	var cells = parent.lv.Rows.Add().Cells;
	var values=jsonobj.cklist;
	for(var i=0;i<parent.lv.Headers.length;i++){
		if(i==1) cells[i].value=values[i].value;
		if(i<=1) continue;
        var cell = cells.Add();
        try {
            cell.text = values[i].text;
            cell.value=values[i].value;
            cell.datatype = values[i].datatype;
        } catch (e) { }
    }
    parent.lv.startIdx=parent.lv.Rows.length>parent.lv.RowsPerPage?parent.lv.Rows.length-parent.lv.RowsPerPage:0;
	parent.lv.RefreshContent();
	parent.lv.EditRow=parent.lv.Container.rows.length-3;
	parent.lv.RefreshContent();
	var mp=parent.document.getElementById("productselect");
	var pfm=parent.parent.document.getElementById("cFF");
	if(pfm){
		if(parseInt(mp.style.top)+parseInt(mp.offsetHeight)>parseInt(pfm.style.height)) pfm.style.height=parseInt(mp.style.top)+parseInt(mp.offsetHeight);
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
	var url = "../contract/search_cp.asp?cstore=1&lv=1&P=" + pagenum + "&B=" + B + "&C=" + encodeURIComponent(C) + "&top=" + escape(top) + "&sort1=" + escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
	try{
		if(window.searchModel==1){
			//处理高级搜索
			var ifcobj=document.getElementById("adsIF").contentWindow.document;
			var sobj=ifcobj.getElementsByTagName("input");
			var txValue="";
			for(var i=0;i<sobj.length;i++){
				var sk = $(sobj[i]).attr("sk");
				if(sk && $(sobj[i]).attr("type")=='text'&& sobj[i].value!=''){
				    txValue += (txValue == "" ? "" : "&") + sk + "=" + encodeURIComponent(sobj[i].value);
				}
			}
			sobj=ifcobj.getElementsByTagName("select");
			for(var i=0;i<sobj.length;i++){
				var sk = $(sobj[i]).attr("sk");
				if(sk&&sobj[i].value!=''){
					txValue+=(txValue==""?"":"&")+sk+"="+ sobj[i].value;
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
			url="../contract/search_cp.asp?cstore=1&lv=1&ads=1"+(txValue==""?"":"&")+txValue+"&P="+pagenum+"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		}
	}catch (e){}

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
	var url = "../product/txmRKnew.asp?cstore=1&txm="+escape(TxmID)+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
	dv.style.left=223+"px";
	dv.style.top=0;
	var dvdlg=parent.document.getElementById("productselect");
	
	if(dv.disp==1){
		dv.style.display="none";
		dv.disp=0;
		dvdlg.style.width="240px";
		$('#__adv_search_btn').val("高级");
		document.getElementById("productdh").style.width = "221px";
		//document.getElementById("productTree").style.width = "100%";
	}else{
		dv.style.display="block";
		var h = $(frm.contentWindow.document.body).children('table:eq(1)').height() + 35;
		frm.style.height = h+"px";
		dv.style.height=h+"px";
		var proSelectFrame = parent.document.getElementById('proSelectFrame');
		var h2 = $(proSelectFrame).parent().height();
		if(h2<h) {$(proSelectFrame).height(h).parent().height(h); }
		dv.disp=1;
		$('#__adv_search_btn').val("收回");
		dvdlg.style.width="631px";
		document.getElementById("productdh").style.width = "221px";
		/*document.getElementById("productTree").style.width = "220px"; */
	}

}

function Left_adClose(){
	var dv=document.getElementById("adsDiv");
	if(dv.disp==1){Left_adSearch();}
}

$(function(){
	parent.$('#productselect').width(240);
});

function ajaxSubmit(sort1){
	$('#cp_search').width(210);
	var B=document.forms[0].B.value;
	var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
	//cstore=1表示只查询实体产品.Task.1440.binary.2014.03.09
	var url = "../contract/search_cp.asp?cstore=1&lv=1&B=" + B + "&C=" + encodeURIComponent(C) + "&top=" + escape(top) + "&sort1=" + escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
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
