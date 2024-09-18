
var hwndrk=null;

var hide = false;

var xmlHttp2 = GetIE10SafeXmlHttp(); 

function xmldata1(ord, act, fromType){
	if(typeof(act) == "undefined"){act = "";}
	if(typeof(fromType) == "undefined"){fromType = 0;}
	var dhtml=document.getElementById('dhtml');
	var left=parseInt(event.clientX)-30;
	var top=event.clientY+jQuery(document).scrollTop();  //鼠标的y坐标
	var htmlleft=document.body.offsetWidth; //所打开当前网页，办公区域的高度，网页的高度
	if(htmlleft-event.clientX<924) {
		left = htmlleft - 924;
	}
	var htmlheight=document.body.offsetHeight; //所打开当前网页，办公区域的高度，网页的高度
	var scrollheight = window.screen.availHeight;//整个windows窗体的高度
	if(htmlheight-event.clientY<200) {
		top = top - 20 * (4 - parseInt((htmlheight - event.clientY) / 100));
	}
	document.getElementById('dhtml').style.top=top+"px";
	document.getElementById('dhtml').style.left=left+"px";	
	var ajaxhtml = "";
	var url = "content_qcmx.asp?ord="+escape(ord)+"&act="+act+"&fromType="+fromType+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp2.open("GET", url, false);
	xmlHttp2.onreadystatechange =function(){
		if(xmlHttp2.readyState==4)
		{					
			var response = xmlHttp2.responseText;
			document.getElementById('dhtml').innerHTML=""
			document.getElementById('dhtml').style.display='none';
			if(response!=""){
				document.getElementById('dhtml').innerHTML=response;
				document.getElementById('dhtml').style.display='block';
			}
			hide = false;
		}
	};
	xmlHttp2.send(null);  
}

$(function(){
	jQuery('.content-split-bar').click(function(e){
		var $o=jQuery(this);
		var flg = $o.attr('flg')||"0";
		var src = flg=="0"?"../images/r_up.png":"../images/r_down.png";
		var $tr = $o.nextUntil('tr.content-split-bar,.content-split-foot',"tr:not([id])");
		flg=="0"?$tr.hide():$tr.show();
		$o.attr('flg',flg=="0"?"1":"0").find('.content-split-icon').attr("src",src);
	}).find(':reset,:button,:submit').click(function(e){
		e.stopPropagation();
	});

	resizeDiv();

	$(window).resize(function(){
		resizeDiv(); 
	});

});

function resizeDiv(){
	var mxdiv = $('#productlist');
	var h = 0;
	mxdiv.width($(document.body)[0].scrollWidth - 8);
	if(mxdiv.get(0).scrollWidth > mxdiv.innerWidth()){
		h = 20;
	}
	mxdiv.css({'height':mxdiv.children().eq(0).height()+h});
}

function setStopCaiGou(ord ,isstop_cg){
	var tsStr = "";
	if (isstop_cg=="1"){
		tsStr = "确定要取消终止此采购单吗？";
	}

	var delpayout, delInvoice, delkuin, delsend;
	if (tsStr == "") {
	    delpayout = 0; delInvoice = 0; delkuin = 0;
	    if (jQuery("#delpayout").size() > 0) {
	        if (jQuery("#delpayout").attr("checked")) { delpayout = 1; }
	    }
	    if (jQuery("#delInvoice").size() > 0) {
	        if (jQuery("#delInvoice").attr("checked")) { delInvoice = 1; }
	    }
	    if (jQuery("#delkuin").size() > 0) {
	        if (jQuery("#delkuin").attr("checked")) { delkuin = 1; }
	    }

	}
	if (tsStr == "" || (tsStr != "" && confirm(tsStr))) {
	    jQuery.ajax({
	        url: 'AjaxReturn.asp',
	        data: {isstop_cg:isstop_cg,id: ord, delpayout: delpayout, delInvoice: delInvoice, delkuin: delkuin },
	        cache: false,
	        async: false,
	        dataType: 'json',
	        success: function (r) {
	            if (r.success) {
	                try {
	                    window.opener.DoRefresh();//刷新父级页面
	                } catch (e) {}
	                window.location.reload();
	            }
	        },
	        error: function (req, textStatus, errorThrown) {
	            if (confirm('提交数据时发生错误，需要查看错误信息吗？')) {
	                alert(req.responseText);
	            }
	            jQuery('#terminateConfirm').dialog('close');
	        }
	    });
	}




}

function shouLabel(){
	if(document.getElementById('dhtml').style.display=='block'){
		hide = false
		document.getElementById('dhtml').style.display='block';	
	}
}


function hidelabel()
{	
	hide = true;
	window.setTimeout("hidelabel2()", 10); 
}

function hidelabel2()
{	
	if(document.getElementById('dhtml').style.display=="block" && hide == true){
		document.getElementById('dhtml').innerHTML="";
		document.getElementById('dhtml').style.display='none';
		xmlHttp2.abort();
	}
}

//删除采购关联费用分摊单
function delteCgPayCostFt(ftord){
	if(ftord!=""){
		if(confirm("确定要删除吗？")){
			jQuery.ajax({
				url:"../inc/AjaxReturn.asp",
				data:{
					__act:"delteCgPayCostFt",
					ftord:ftord
				},
				type:'post',
				success:function(r){
					try{
						var ret =r;
						if (ret == "1") {
						    window.AutoHandleToNet(74001, ftord, "Caigou_InventoryCost_DelteCgPayCostFt");
							window.location.reload();
						}else{
							alert('删除失败');
						}
					}catch(e){
						alert('删除失败');
					}
				},error:function(XMLHttpRequest, textStatus, errorThrown){
					alert(errorThrown);
				}
			});
		}
	}
}


var afterPrint = function () {
    document.getElementById('kh').style.display = ''
};

if (window.matchMedia) {
    var mediaQueryList = window.matchMedia('print');
    mediaQueryList.addListener(function (mql) {
        if (!mql.matches) {
            afterPrint();
        }
    });
}