var olddata = "\1";
function getCurrPageData() {
	var txts = new Array();
	var tb = $ID("editbody");
	var cells = tb.getElementsByTagName("td");
	for (var i = 0; i < cells.length ; i++)
	{
		var cell = cells[i];
		if(cell.getAttribute("ei")=="1" && cell.id!="@cqrcodePage_cel") {
			var v = bill.getCellValue(cell);
			if (v!="")
			{
				if (cell.id.indexOf("qrf_")==0)
				{	
					txts[txts.length] =  cell.previousSibling.innerText + bill.getCellValue(cell,null,true);
				}
			}
		}
	}
	return txts.join("\1");
}

function errhchange() {
	olddata = "\1";
	updateQrCodeView();
}

function setimgValue(box) {
	var v = box.value;
	var vbox = $ID("codelogo_0");
	v = v.toLowerCase();
	var id = v.replace("../sdk/bill.upload.asp?v", "");
	if (v.indexOf("http:")==-1 && id==(vbox.getAttribute("rsaid") + "").toLowerCase()){return; }
	vbox.value =  v;
	vbox.setAttribute("rsaid","");
}

function updateQrCodeView() {
	var ndata = getCurrPageData();
	if (ndata!=olddata)
	{
		olddata = ndata;
		var ems = document.getElementsByName("errorh");
		var emh = 0;
		for (var i = 0; i < ems.length ; i ++ )
		{
			if(ems[i].checked) {
				emh = ems[i].value;
				break;
			}
		}
		if(!$ID("esrl")) {return;}
		var xh = new xmlHttp();
		var w = $ID("esrl").value;
		var mw =  w > 280 ? 280: w;
		var  logw = parseInt(mw * 0.2);
		if ($ID("qrcodeView") && $ID("viewcodespan"))
		{
			$ID("qrcodeView").style.display = "";
			$ID("viewcodespan").style.display = "none";
			$ID("qrcodeView").style.width = (w > 280 ? "280px" : "");
			$ID("qrcodeView").src = "view.asp?sn=view&ct=" + $ID("ctype_0").value 
								+ "&data=" + xh.UrlEncode(olddata).replace(/\+/g,"%2B") 
								+ "&clr=" + xh.UrlEncode($ID("color_0").value) 
								+ "&bclr=" + xh.UrlEncode($ID("bgcolor_0").value)
								+ "&width=" + w
								+ "&errorh=" + emh 
								+ "&t=" + (new Date()).getTime()
								+ "&logo=" + xh.UrlEncode($ID("codelogo_0").value)
		}
		xh = null;
	}
}


window.onBillLoad = function() {
	 document.body.onactivate = function() {
		updateQrCodeView();
	 }
	  document.body.onkeydown = function() {
		if(window.event.keyCode==13) {
			updateQrCodeView();
		} 
	 }
	 updateQrCodeView();
	 sSetItem($ID("spk1"));
}

var lastselected =  ""
function swpColor(obj, t) {
	if (lastselected==obj.id) { return; }
	obj.style.borderBottomColor = t == 0 ? "#dde5dd" : "#eeeeee";
 }

 function sSetItem(obj) {
	 if(!obj) {return;}
	obj.style.borderBottomColor = "#aaccaa";
	obj.style.color = "#aaccaa";
	lastselected=obj.id;
	for (i=1 ; i < 4 ; i ++ )
	{
		if(lastselected != "spk" + i) {
			$ID("spk" + i).style.borderBottomColor = "#eeeeee";
			$ID("spk" + i).style.color = "";
			$ID("spk_b_" + i).style.display = "none";
		}
		else{
			$ID("spk_b_" + i).style.display = "block";
		}
	}
 }

 window.__onClrPickerChange =  function(box) {
	olddata = "\1";
	updateQrCodeView();
 } 

 var hwnd = 0;
	
 $(document).ready(
	function() {
		try{
			$('#esrl').slider({   
				mode: 'h',
				onChange: function(oldValue, newValue){
					$ID("esrvTxt").value =  newValue + 'px';
					window.clearTimeout(hwnd);
					hwnd = window.setTimeout("olddata='\1';updateQrCodeView()",500);
				}   
			});
			autoqrcimageSize();
		}catch(e){}
	}
 )

var autoqrcimagehwnd = 0;
var autoqrcimageindex = 0;
if (window.location.href.indexOf("onlyread=1")>0){
	autoqrcimagehwnd = window.setInterval("autoqrcimageSize()",100);
}

function autoqrcimageSize() {
	if($ID("commqrcodeimage")) {
		var box = $ID("commqrcodeimage");
		if(box.offsetWidth > 280) { 
			box.style.width = "280px";
			box.title = "点击查看原始大小图";
			box.style.cursor = "pointer";
			box.onclick = function() { window.open(box.src);}
			window.clearInterval(autoqrcimagehwnd);
			return;
		}
	}
	autoqrcimageindex++;
	if(autoqrcimageindex>100) {
		window.clearInterval(autoqrcimagehwnd);
		return;
	}
}

function NewPrint(id){
	window.open('../../SYSN/view/comm/TemplatePreview.ashx?sort=11&ord='+id,'newwin77','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0')
}


function cExcel() {
	//$ID("excel_data").value = 
	//$ID("excelfrm").submit();
}

function cBtnAjax(cEvent,id,cText){
	var r = true;
	if (cText)
	{
		r = window.confirm(cText);
	}
	if (r)
	{
		ajax.regEvent(cEvent);
		ajax.addParam("id",id);
		ajax.exec();
		opener.DoRefresh();
		top.close();
	}
	return;
}