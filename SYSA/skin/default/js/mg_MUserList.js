jQuery.param=function(a){ 
	var s = [];
	function encode(str){ str=escape(str);str=str.replace(/\+/g,'%u002B');return str;}
	function add(key,value){s[s.length] = encode(key) + '=' + encode(value);}
	if (jQuery.isArray(a) || a.jquery){
		jQuery.each(a,function(){add(this.name,this.value); }); 
	}else{
		for (var j in a){
			if (jQuery.isArray(a[j])){
				jQuery.each(a[j],function(){ add(j,this); }); 
			}else{
				add(j,jQuery.isFunction(a[j])?a[j]():a[j]); 
			}
		}
	}
	return s.join("&").replace(/%20/g,"+"); 
};

//$(document).ajaxStart(function (a,b,c) {
//	$("body").showLoading();  
//}).ajaxSend(function (e, xhr, opts) {
//}).ajaxError(function (e, xhr, opts) {
//	$("body").hideLoading();  
//}).ajaxSuccess(function (e, xhr, opts) {
//	$("body").hideLoading();  
//}).ajaxComplete(function (e, xhr, opts) {
//	$("body").hideLoading();  
//}).ajaxStop(function (){
//	$("body").hideLoading();  
//});

(function($) {
    $.fn.insertContent = function(myValue, t) {
		var $t = $(this)[0];
		if (document.selection) { //ie
			this.focus();
			var sel = document.selection.createRange();
			if (myValue.indexOf('<')>=0){
				sel.pasteHTML(myValue);
			}else{
				sel.text = myValue;
			}
			this.focus();
			sel.moveStart('character', -l);
			var wee = sel.text.length;
			if (arguments.length == 2) {
				var l = $t.value.length;
				sel.moveEnd("character", wee + t);
				t <= 0 ? sel.moveStart("character", wee - 2 * t - myValue.length) : sel.moveStart("character", wee - t - myValue.length);
 
				sel.select();
			}
		} else if ($t.selectionStart || $t.selectionStart == '0') {
			var startPos = $t.selectionStart;
			var endPos = $t.selectionEnd;
			var scrollTop = $t.scrollTop;
			$t.value = $t.value.substring(0, startPos) + myValue + $t.value.substring(endPos, $t.value.length);
			this.focus();
			$t.selectionStart = startPos + myValue.length;
			$t.selectionEnd = startPos + myValue.length;
			$t.scrollTop = scrollTop;
			if (arguments.length == 2) {
				$t.setSelectionRange(startPos - t, $t.selectionEnd + t);
				this.focus();
			}
		}
		else {
			this.value += myValue;
			this.focus();
		}       
    };
})(jQuery);

function loadFans(){
	if(!confirm('此操作将读取并更新关注服务号的所有微信用户信息\n操作耗时较长（执行所需时间与用户数量有关）\n            确定要执行吗？')) return;
	$.ajax({
		url:'?__msgId=loadFans',
		success:function(r){
			var r = eval('('+r+')');
			app.Alert(r.msg);
			lvw_refresh("mlistvw");
		}
	});
}

function resumeUser(id){
	if(!confirm('确定要启用该用户吗？')) return;
	$.ajax({
		url:'?__msgId=changeStat',
		data:{id:id,stat:1},
		success:function(r){
			r = eval('('+r+')');
			if (r.success){
				lvw_refresh("mlistvw");
			}else{
				app.Alert('操作失败：'+r.msg);
			}
		}
	});
}

var $reasonDlg,currUid;
function cancelUser(id){
	currUid = id;
	if(!$reasonDlg){
		$reasonDlg = $('<div id="reasonDlg" class="easyui-window" title="请填写作废原因" style="top:100px;width:400px;height:232px;padding:2px;background: #fafafa;" collapsible="false" minimizable="false" modal="true"></div>');
		$reasonDlg.appendTo(document.body);
		$reasonDlg.hide().html(''+
			'<div style="margin:0px;display:block;height:130px;width:100%;padding-right:2px">'+
				'<textarea id="reasonBox" style="border:1px #CCCCCC solid;width:99%;height:130px"></textarea>'+
			'</div>'+
			'<div style="margin-top:10px;display:block;line-height:40px;height:40px;text-align:center">'+
				'<input id="reasonSaveBtn" type="button" class="oldbutton2" value="保存"/>&nbsp;' +
				'<input type="button" class="oldbutton2" onclick="$(\'#reasonBox\').text(\'\');" value="重填"/>' +
			'</div>' +
		'');

		$reasonDlg.find('#reasonSaveBtn').bind('click',function(){
			var reason = $('#reasonBox').val();
			if (reason.length>500){
				app.Alert('长度不能超过500个字符');
				return;
			}

			$.ajax({
				url:'?__msgId=changeStat',
				data:{id:currUid,stat:2,reason:reason},
				type:'post',
				success:function(r){
					r = eval('(' + r + ')');
					if (r.success){
						$reasonDlg.dialog('close');
						$('#reasonBox').empty();
						lvw_refresh("mlistvw");
					}else{
						app.Alert('操作失败：' + r.msg);
					}
				}
			});
		});
	}else{
		$('#reasonBox').val("");
	}
	var top = ($(window).height()-186)/2 + $(document).scrollTop();
	var left = ($(window).width()-400)/2 + $(document).scrollLeft();
	$reasonDlg.show().dialog({
		top:top,
		left:left
	}).dialog('open');
}

function showPic(obj){
	window.open(obj.src);
}

function downloadFile(obj){
    window.open('../out/downfile.asp?fileSpec=' + obj.getAttribute("file"));
}

function menuAddByType(stype){
	var winStyle = 'fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150';
	if (stype=='1'){//新单位客户
		window.open('../work/add.asp?intsort=1&muid='+menuUserId,'newCompany',winStyle);
	}else if (stype=='2'){//新个人客户
		window.open('../work/add.asp?intsort=2&muid='+menuUserId,'newCompany',winStyle);
	}else if (stype=='3'){//已有客户
		showPersonDlg();
	}
}

var $menu,menuUserId;
function showMenu(obj){
	if($menu){$menu.menu('hide')};
	var uid = $(obj).attr("uid");
	var binded = $(obj).attr("binded")=='1';
	menuUserId = uid;
	if(!$menu){
		$menu = $('<div id="menuDiv" style="position:absolute;width:140px;background-color:white;border:1px #CCCCCC solid"></div>');
		$menu.appendTo(document.body);
		$menu.hide().html(''+
			"<div cmd='1' class='gp1' onclick='menuAddByType(1)'>添加新单位客户</div>" +
			"<div cmd='2' class='gp1' onclick='menuAddByType(2)'>添加新个人客户</div>" +
			"<div cmd='3' onclick='menuAddByType(3)'>选择已有联系人</div>" +
		'').mouseleave(function(){$menu.hide();});
		$menu.children('div')
		.css({
			lineHeight:'25px',
			color:'#5b7cae',
			cursor:'pointer',
			paddingLeft:5
		}).mouseenter(function(){
			$(this).css({
				fontWeight:'bolder',
				backgroundColor:'#ECF5FF'
			});
		}).mouseleave(function(){
			$(this).css({
				fontWeight:'normal',
				backgroundColor:'white'
			});
		});
	}

	if (binded){
		$menu.children('div.gp1').hide();
	}else{
		$menu.children('div.gp1').show();
	}
	
	var pos = GetObjectPos(obj);
	$menu.css({
		left:obj.getBoundingClientRect().left - 70,
		top:obj.getBoundingClientRect().top + obj.offsetHeight + $(document).scrollTop()
	}).show()
}

var $personDlg;
function showPersonDlg(){
	if($personDlg){$personDlg.dialog('close');}
	if (!$personDlg){
		$personDlg = $('<div id="userDlg" class="easyui-window" title="绑定联系人" style="top:20px;width:1000px;height:600px;padding:5px;background: #fafafa;"collapsible="false" minimizable="false" modal="true"></div>');
		$personDlg.appendTo(document.body);
		$personDlg.hide().html(''+
			'<iframe style="width:100%;height:99%" frameborder="0" src="../person/telall.asp?q=1&s3=1&uitype=micromsg.binduser"></iframe>' +
		'');
	}

	var top = ($(window).height() - 600) / 2 + $(document).scrollTop();
	if (top < 0) { top = 0; }
	var left = ($(window).width()-1000)/2 + $(document).scrollLeft();

	$personDlg.show().dialog({
		left:left,
		top:top
	}).dialog('open');
}

var __faces = ['/::)','/::~','/::B','/::|','/:8-)','/::<','/::$','/::X','/::Z','/::\'(','/::-|','/::@','/::P','/::D','/::O','/::(','/::+','/:--b','/::Q','/::T','/:,@P','/:,@-D','/::d','/:,@o','/::g','/:|-)','/::!','/::L','/::>','/::,@','/:,@f','/::-S','/:?','/:,@x','/:,@@','/::8','/:,@!','/:!!!','/:xx','/:bye','/:wipe','/:dig','/:handclap','/:&-(','/:B-)','/:<@','/:@>','/::-O','/:>-|','/:P-(','/::’|','/:X-)','/::*','/:@x','/:8*','/:pd','/:<W>','/:beer','/:basketb','/:oo','/:coffee','/:eat','/:pig','/:rose','/:fade','/:showlove','/:heart','/:break','/:cake','/:li','/:bome','/:kn','/:footb','/:ladybug','/:shit','/:moon','/:sun','/:gift','/:hug','/:strong','/:weak','/:share','/:v','/:@)','/:jj','/:@@','/:bad','/:lvu','/:no','/:ok','/:love','/:<L>','/:jump','/:shake','/:<O>','/:circle','/:kotow','/:turn','/:skip','/:oY','/:#-0','/街舞','/:kiss','/:<&'];
var __faceMap = {},__faceIdMap = {};
for (var i=0;i<__faces.length;i++ ){
	__faceMap[i] = __faces[i];
	__faceIdMap[__faces[i]] = i;
}
var FaceSelector = function(callback){
	var FACE_WIDTH = 26;
	var face = this;
	face.faces = __faces;
	face.panel = $('<div id="facePanel" style="background-color:white;border:1px solid #CACACA;padding:10px;position:absolute;display:inline-block"></div>')
	.appendTo(document.body).hide();
	var tb = '<table cellspacing="0" cellpadding="0" border="0" style="border-collapse:collapse;table-layout:auto;border-bottom:1px solid #CACACA"><tr>';
	var i;
	for(i=0;i<face.faces.length;i++){
		if (i > 0 && i % 15 == 0){
			tb += '<tr>';
		}
		var rline = (i > 0 && (i+1) % 15 == 0);
		tb += '<td align="center" style="width:' + (FACE_WIDTH + 5) + 'px;height:' + (FACE_WIDTH + 5) + 'px">' +
				'<button style="border-right:' + (rline?"1px solid #CACACA":"0px") + ';border-bottom:0px;border-left:1px solid #CACACA;border-top:1px solid #CACACA;width:100%;height:100%;background-color:transparent;"><img src="../MicroMsg/face/' + i + '.gif" idx="' + i + '" ' +
					'txt="' + face.faces[i] + '" width="' + (FACE_WIDTH) + 'px" height="' + (FACE_WIDTH) + 'px"/>'+
				'</button></td>';
		if (rline) tb += '</tr>';
	}

	if (i % 15 !=0){
		for (var j = i;j % 15 !=0;j++){
			tb += '<td style="border:1px solid #CACACA">&nbsp;</td>';
		}
		tb += "</tr>";
	}
	tb += '</table>';
	face.panel.html(tb).find('td').bind('click',function(e){
		var img = this.children[0]
		if(img){img=img.children[0];}else{return;}
		callback.apply(img,[img.idx,img.txt]);
		e.stopPropagation();
	}).bind('mouseenter',function(){
		$(this).css({backgroundColor:'#CACACA'});
	}).bind('mouseleave',function(){
		$(this).css({backgroundColor:'white'});
	});

	face.panel.bind('mouseleave',function(){
		face.panel.hide();
	});

	face.showSelector = function(e){
		var pos = absPos(e.target);
		face.panel.css({
			left : pos.left,
			top : pos.top,
			zIndex:'9999999'
		}).show();
	};

	function absPos(node){
		var x=y=0;
		do{
			x+=node.offsetLeft;
			y+=node.offsetTop;
		}while(node=node.offsetParent);   
		return{   
			left:x,   
			top:y   
		};         
	}
		
	return face;
};

function MicroMsgDlg(callback){
	var o = this;

	function init(){
		if (o.msgDlg) return;
		o.msgDlg = $('<div id="userDlg" class="easyui-window" title="消息回复" style="top:100px;width:600px;height:300px;padding:0px;background-color:#ECF5FF;"collapsible="false" minimizable="false" modal="true"></div>');
		o.msgDlg.appendTo(document.body);
		$(''+
		'<style>'+
			'.tabHeader{line-height:30px;height:30px;width:130px;padding:0 20 0 20;display:inline-block;text-align:center;background-color:;cursor:hand;color:#0e2d5f;}'+
			'.tabTitle:{height:30px}' +
			'.picPanel{' +
				'border:2px dotted rgb(217,218,220);'+
				'border-image-outset:0px;'+
				'border-image-repeat:stretch;'+
				'border-image-slice:100%;'+
				'border-image-source:none;'+
				'border-image-width:1;'+
				'color:rgb(34,34,34);'+
				'display:block;'+
				'font-size:14px;'+
				'height:55px;'+
				'line-height:55px;'+
				'margin-top:10px;'+
				'padding:60px 0px 60px 0px;'+
				'text-align: center;'+
				'width: 421.75px;'+
				'font-family:\'Helvetica Neue\', \'Hiragino Sans GB\', \'Microsoft YaHei\', 黑体, Arial, sans-serif;'+
			'}'+
		'</style>').appendTo(document.body);

		o.msgDlg.hide().html(''+
			'<div class="tabTitle" style="display:none">'+
				'<span class="tabHeader" msgType="text" tabIdx="1" selected="1">文本消息</span>'+
//				'<span style="margin-left:1px"></span>'+
//				'<span class="tabHeader" tabIdx="2" msgType="img">图片消息</span>'+
			'</div>'+
			'<div class="tabContent" tabIdx="1" style="border-top:0px #95b8e7 solid">' +
				'<iframe id="designArea" style="width:100%;height:227px" frameborder="0"></iframe>' +
				'<div style="height:25px;padding-top:7px;padding-left:5px;padding-right:5px;border-top:1px #95b8e7 solid">'+
					'<img id="faceSelector" src="../MicroMsg/face/0.gif" style="cursor:hand;float1:left">' +
					'<input id="sendMsg" type="button" class="oldbutton3" style="float:right" value="发送">' +
				'</div>' +
			'</div>' +
//			'<div class="tabContent" tabIdx="2" style="display:none;height:233px;line-height:233px;text-align:center;overflow-x:auto;background-color:white">' +
//				'<span class="picPanel">' +
//					'<div style="cursor:hand;font-size:50pt;font-weight:normal" onclick="javascript:$(\'#fileBox\').trigger(\'click\');">+</div>' +
//				'</span>' +
//				'<span style="display:none"><img/></span>' +
//			'</div>' +
//			'<form method="" target=""><input id="fileBox" type="file" style="width:0px;height:0px;border:0px;float1:left"/></form>' +
//			'<iframe id="fileUploadIframe" frameborder="0" style="display:none"></iframe>' +
		'');
		o.msgDlg.find('.tabHeader').click(function(){
			var $o = $(this);
			var tabIdx = $o.attr("tabIdx");

			$o.css({backgroundColor:'lightblue'})
			.attr("selected",'1').css({fontWeight:'bolder'})
			.siblings('.tabHeader')
			.css({backgroundColor:'#edFeFF',fontWeight:'normal'})
			.attr("selected",'0');

			o.msgDlg.find('.tabContent[tabIdx="'+tabIdx+'"]').show();
			o.msgDlg.find('.tabContent[tabIdx!="'+tabIdx+'"]').hide();
		});

		var editor = $('#designArea')[0];
		var editorDoc = editor.contentWindow.document;  
		var editorWindow = editor.contentWindow;
		editorDoc.designMode = "on";
		editorDoc.write("<html><head></head><body style='width:100%;margin:0px;padding:3px;font-size:12px;background-color:white;'></body></html>");

		if($.browser.msie){
			editorDoc.documentElement.attachEvent("onpaste", function(e){return pasteClipboardData("designArea",e);}); 
		}else{
			editorDoc.addEventListener("paste", function(e){return pasteClipboardData("designArea",e);},false); 
		}

		var selector = new FaceSelector(function(idx,txt){
			$(editorWindow).insertContent('<img tag="faces" txt="' + txt + '" src="../MicroMsg/face/' + idx + '.gif">');
		});

		$('#faceSelector').click(function(e){
			selector.showSelector(e);
		});

		$('#sendMsg').click(function(){
			var $btn = $(this);
			var html = getRealContent(editorDoc.body.innerHTML);
			html=html.replace(/\[!br!\]/gi,'\n');
			html=html.replace(/\[!space!\]/gi,' ');
			html=html.replace(/\[!([WLO])!\]/g,'<$1>');
			html=html.replace(/[\xa0]/gi,'\n');
			while (/[\n ]$/.test(html)){
				html = html.replace(/[\n ]$/,'');
			}

			if (html.length==0){
				if (app.Alert){
					app.Alert('请输入消息内容！');
				}else{
					alert('请输入消息内容！');
				}
				return;
			}

			if (html.length>600){
				if (app.Alert){
					app.Alert('消息内容长度超过限制（600个字符）！');
				}else{
					alert('消息内容长度超过限制（600个字符）！');
				}
				return;
			}

			$btn.attr('disabled','disabled').val('发送中');
			$.ajax({
				url:'../MicroMsg/MUserList.asp?__msgId=postTextMsg',
				data:{uid:o.uid,msg:html},
				type:'post',
				success:function(r){
					r = eval('('+r+')');
					if (r.success){
						o.msgDlg.dialog('close');
						$(editorDoc.body).empty();
						if (callback){
							callback.call(this,[]);
						}else{
							lvw_refresh("mlistvw");
						}
					}else{
						if (app.Alert){
							app.Alert('操作失败：'+r.msg);
						}else{
							alert('操作失败：'+r.msg);
						}
					}
					$btn.attr('disabled',false).val('发送');
				}
			});
		});
		o.msgDlg.find('.tabHeader[tabIdx="1"]').trigger('click');
	}

	o.open = function(obj){
		if (o.uid && o.uid != obj.uid){
			$($('#designArea')[0].contentWindow.document.body).empty();
		}
		o.uid = obj.uid;
		init();
		var top = ($(window).height()-300)/2 + $(document).scrollTop();
		var left = ($(window).width()-600)/2 + $(document).scrollLeft();

		o.msgDlg.show().dialog({
			left:left,
			top:top
		}).dialog('open');
		setTimeout(function(){$('#designArea')[0].contentWindow.document.body.focus();},100);
	}

	function getRealContent(s){
		var $div = $('<div style="display:none;">').appendTo(document.body);
		$div[0].innerHTML = s;
		$div.find('img[tag="faces"]').each(function(){
			var $o = $(this);
			var txt = $o.attr('txt');
			$o.replaceWith($('<span>'+txt+'</span>'));
		});

		$div.html(
			$div.html()
			.replace(/<p>/gi,'')
			.replace(/&nbsp;/gi,'[!space!]')
			.replace(/\r\n/gi,'[!br!]')
			.replace(/<\/p>/gi,'[!br!]')
			.replace(/<br>/gi,'[!br!]')
			.replace(/<([WLO])>/g,'[!$1!]')
		);
		var result = $div.text();
		$div.remove();
		return result;
	}

	function getSel(w){ 
		return w.getSelection ? w.getSelection() : w.document.selection; 
	} 

	function setRange(sel,r){ 
		sel.removeAllRanges(); 
		sel.addRange(r); 
	}

	function filterPasteData(originalText){ //过滤掉除表情以外的html标记
		var newText=originalText; 
		if (!o.$container){
			o.$container = $('<div style="display:none;">').appendTo(document.body);
		}
		o.$container[0].innerHTML = newText;
		o.$container.find('img[tag="faces"]').each(function(){
			var $o = $(this);
			$o.replaceWith($('<span>'+$o.attr('txt')+'</span>'));
		});
		newText = o.$container[0].innerText;

		for (var i=0;i<__faces.length;i++){
			newText = newText.replace(new RegExp(regConvert(__faces[i]),"gi"),'<img txt="' + __faces[i] + '" src="../MicroMsg/face/' + i + '.gif" tag="faces"/>');
		}
		return newText;
	} 

	function regConvert(s){
		return s.replace(/\\/g,'\\')
		.replace(/\(/g,'\\(')
		.replace(/\)/g,'\\)')
		.replace(/\[/g,'\\[')
		.replace(/\]/g,'\\]')
		.replace(/\</g,'\\<')
		.replace(/\>/g,'\\>')
		.replace(/\*/g,'\\*')
		.replace(/\+/g,'\\+')
		.replace(/\-/g,'\\-')
		.replace(/\?/g,'\\?')
		.replace(/\./g,'\\.')
		.replace(/\|/g,'\\|')
		.replace(/\$/g,'\\$')
	}

	function block(e){ 
		e.preventDefault(); 
	} 

	function pasteClipboardData(editorId,e){ 
		var objEditor = document.getElementById(editorId); 
		var edDoc=objEditor.contentWindow.document; 
		if($.browser.msie){ 
			var orRange=objEditor.contentWindow.document.selection.createRange(); 
			var ifmTemp=document.getElementById("ifmTemp"); 
			if(!ifmTemp){ 
				ifmTemp=document.createElement("IFRAME"); 
				ifmTemp.id="ifmTemp"; 
				ifmTemp.style.width="1px"; 
				ifmTemp.style.height="1px"; 
				ifmTemp.style.position="absolute"; 
				ifmTemp.style.border="none"; 
				ifmTemp.style.left="-10000px"; 
				ifmTemp.src="about:blank"; 
				document.body.appendChild(ifmTemp); 
				ifmTemp.contentWindow.document.designMode = "On"; 
				ifmTemp.contentWindow.document.open(); 
				ifmTemp.contentWindow.document.write("<body></body>"); 
				ifmTemp.contentWindow.document.close(); 
			}else{ 
				ifmTemp.contentWindow.document.body.innerHTML=""; 
			} 
			o.originText=objEditor.contentWindow.document.body.innerText; 
			ifmTemp.contentWindow.focus(); 
			ifmTemp.contentWindow.document.execCommand("Paste",false,null); 
			objEditor.contentWindow.focus(); 
			o.newData=ifmTemp.contentWindow.document.body.innerHTML; 
			//filter the pasted data 
			o.newData=filterPasteData(o.newData); 
			ifmTemp.contentWindow.document.body.innerHTML=o.newData; 
			//paste the data into the editor 
			orRange.pasteHTML(o.newData); 
			//block default paste 
			if(e) { 
				e.returnValue = false; 
				if(e.preventDefault) 
				e.preventDefault(); 
			} 
			return false; 
		}else{ 
			enableKeyDown=false; 
			//create the temporary html editor 
			var divTemp=edDoc.createElement("DIV"); 
			divTemp.id='htmleditor_tempdiv'; 
			divTemp.innerHTML='\uFEFF'; 
			divTemp.style.left="-10000px"; //hide the div 
			divTemp.style.height="1px"; 
			divTemp.style.width="1px"; 
			divTemp.style.position="absolute"; 
			divTemp.style.overflow="hidden"; 
			edDoc.body.appendChild(divTemp); 
			//disable keyup,keypress, mousedown and keydown 
			objEditor.contentWindow.document.addEventListener("mousedown",block,false); 
			objEditor.contentWindow.document.addEventListener("keydown",block,false); 
			enableKeyDown=false; 
			//get current selection; 
			o.w=objEditor.contentWindow; 
			o.or=getSel(o.w).getRangeAt(0); 
			//move the cursor to into the div 
			var docBody=divTemp.firstChild; 
			rng = edDoc.createRange(); 
			rng.setStart(docBody, 0); 
			rng.setEnd(docBody, 1); 
			setRange(getSel(o.w),rng); 
			o.originText=objEditor.contentWindow.document.body.textContent; 
			if(o.originText==='\uFEFF'){ 
				o.originText=""; 
			}
			window.setTimeout(function(){ 
				//get and filter the data after onpaste is done 
				if(divTemp.innerHTML==='\uFEFF'){ 
					o.newData=""; 
					edDoc.body.removeChild(divTemp); 
					return; 
				} 
				o.newData=divTemp.innerHTML; 
				// Restore the old selection 
				if (o.or){ 
					setRange(getSel(o.w),o.or); 
				} 
				o.newData=filterPasteData(o.newData); 
				divTemp.innerHTML=o.newData; 
				//paste the new data to the editor 
				objEditor.contentWindow.document.execCommand('inserthtml',false,o.newData);
				edDoc.body.removeChild(divTemp); 
			},100); 
			//enable keydown,keyup,keypress, mousedown; 
			enableKeyDown=true; 
			objEditor.contentWindow.document.removeEventListener("mousedown",block,false); 
			objEditor.contentWindow.document.removeEventListener("keydown",block,false); 
			return true; 
		}
	}
	return o;
}

var msgDlg = new MicroMsgDlg();

function bindMicroMsgUser(personId){
	$.ajax({
		url:'?__msgId=bindMicroMsgUser',
		data:{
			pid:personId,
			uid:menuUserId
		},
		success:function(r){
			r = eval('('+r+')');
			if (r.success){
				$personDlg.dialog('close');
				lvw_refresh("mlistvw");
			}else{
				app.Alert('操作失败：'+r.msg);
			}
		}
	});
}

var $dlg;
function setAppoint(obj){
	if($dlg){$dlg.dialog('close');}

	var id = '',cateid = '';
	if (obj){
		id = $(obj).attr("uid");
		cateid = obj.cateid;
	}else{
		$('.lvcbox:checked').each(function(){
			id += (id.length==0?'':',') + this.value;
		})
	}
	if (id.length==0){
		app.Alert('请选择微信用户！');
		return;
	}

	if (!$dlg){
		$dlg = $('<div id="userDlg" class="easyui-window" title="微信用户指派" style="top:100px;width:520px;height:370px;padding:5px;background: #fafafa;"collapsible="false" minimizable="false" modal="true"></div>');
		$dlg.appendTo(document.body);
		$dlg.hide().html(''+
				'<div region="center" id="select_users" border="false" style="width:495px; height:275px;overflow:auto;margin-top:2px;scrollbar-highlight-color:#fff;scrollbar-face-color:#f0f0ff;scrollbar-arrow-color:#c0c0e8;scrollbar-shadow-color:#d0d0e8;scrollbar-darkshadow-color:#fff; scrollbar-base-color:#ffffff; scrollbar-track-color:#fff;"></div>' +
				'<div region="south" border="false" style="text-align:center;height:25px;line-height:25px; margin-top:8px;">' +
					'<input type="button" class="oldbutton" value="确定" id="saveOrderBtn">' +
				'</div>' +
		'');
	}
	
	var top = ($(window).height()-400)/2 + $(document).scrollTop();
	var left = ($(window).width()-600)/2 + $(document).scrollLeft();

	$.ajax({
		url:'?__msgId=showUserList',
		data:{selectedid:cateid},
		success:function(html){
			$('#select_users')[0].innerHTML = html;
			$('#saveOrderBtn').unbind().click(function(){
				var cid = $dlg.find(":checked[name='member']").val();
				if (!cid){
					app.Alert('请选择指派用户！');
					return;
				}

				$.ajax({
					url:'?__msgId=saveAppoint',
					type:'post',
					data:{
						uid:id,
						cateid:cid
					},
					success:function(r){
						r = eval('('+r+')');
						if (r.success){
							$dlg.dialog('close');
							lvw_refresh("mlistvw");
						}else{
							app.Alert('操作失败：'+r.msg);
						}
					}
				});
			});

			$dlg.show().dialog({
				title : obj?'微信用户指派':'微信用户批量指派',
				left : left,
				top : top
			}).dialog('open');
		}	
	});
}

function ajaxPage(ord,pageindex,pagesize){
	$.ajax({
		url:'../MicroMsg/MUserContent.asp?__msgId=ReplyList',
		data:{ord:ord,pageindex:pageindex,pagesize:pagesize},
		success:function(html){
			$('.talk').parent()[0].innerHTML = html;
		}
	});
}

function pageboxkeypress(obj,ord,pagesize){
	var keyCode = window.event.charCode || window.event.keyCode;
	if (keyCode == 13){
		if (isNaN(obj.value)) return false;
		ajaxPage(ord,obj.value,pagesize);
	}else if(keyCode < 48 || keyCode > 57){
		return false;
	}else{
		return true;
	}
}

var msgDlgInContent;
function replyFromContent(ord,pageindex,pagesize){
	if (!msgDlgInContent){
		msgDlgInContent = new MicroMsgDlg(function(){
			ajaxPage(ord,1,5);
		});
	}
	msgDlgInContent.open({uid:ord});
}

var msgDlgInTelContent;
function replyFromTelContent(ord){
	if (!msgDlgInTelContent){
		msgDlgInTelContent = new MicroMsgDlg(function(){
			alert('消息发送成功');
		});
	}
	msgDlgInTelContent.open({uid:ord});
}

function cantReply(){
	if(app.Alert){
		app.Alert('该用户最近消息时间超过48小时，不能发送消息！')
	}else{
		alert('该用户最近消息时间超过48小时，不能发送消息！');
	}
}

$(function(){
	$('.replyTitle').click(function(){
		var $o = $(this);
		$('.person_reply').hide();
		$('.person_reply.'+ $o.attr("tp") +'').show();
		$o.css('font-weight','bolder').siblings('.replyTitle').css('font-weight','normal');
	});

	$(document).keydown(function (event) {
	        if (event.keyCode == 13) {
	            $("#serch").click();
	        }
	});
});

window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!="")
	{
		$("#searchitemsbutton2").click();
	}
}

function addrPage(pageindex, pagesize) {
    var shouhuoname = $("#shouhuoname").val();
    var serchkey = $("#serchkey").val();
    var serchtext = $("#serchtext").val();
    var shadress = $("#shadress").val();
	var $box = $('#personAddressList');
	if(!$box){return;}
	if($box.attr('ordType')==undefined){return;}
	$.ajax({
		url:'../MicroMsg/Addresses.asp',
		data: { ord: $box.attr('ord'), ordType: $box.attr('ordType'), pageindex: pageindex, pagesize: pagesize, mode: $box.attr('mode'), shouhuoname: shouhuoname, serchkey: serchkey, serchtext: serchtext, shadress: shadress },
		success:function(html){
			$box.parent().html(html);
		}
	});
}

function addrPageBoxKeyDown(obj,ord){
	var keyCode = window.event.charCode || window.event.keyCode;
	if (keyCode == 13){
		if (isNaN(obj.value)) return false;
		addrPage(parseInt(obj.value)>parseInt(obj.max)?obj.max:obj.value,$('#addr_pgsize').val());
	}else if(keyCode < 48 || keyCode > 57){
		return false;
	}else{
		return true;
	}
}

var $addrModifyWindow = null;
function addrModify(obj,ord,ordType){
	if (!$addrModifyWindow){
		$addrModifyWindow = $('<div id="addrModifyWindow" class="easyui-window" title="收货地址修改" style="top:100px;width:550px;height:470px;padding:5px;background: #fafafa;"collapsible="false" minimizable="false" modal="true"></div>');
		$addrModifyWindow.appendTo(document.body);
		$addrModifyWindow.hide().html(''+
				'<div id="addrContent" border="false" style="width:484px; height:450px;margin-top:2px;position:relative;"></div>' +
		'');
	}

	var addrId = obj?$(obj).attr("addrId"):0;
	var ord = ord?ord:0;
	var top = ($(window).height()-400)/2 + $(document).scrollTop();
	var left = ($(window).width()-600)/2 + $(document).scrollLeft();
	var isAddNew = obj?false:true;

	$.ajax({
		url:'../MicroMsg/Addresses.asp?__msgId=addrModify',
		data:{ord:ord,id:addrId,ordType:ordType},
		success:function(html){
			if (html.indexOf('error:')==0){
				alert(html.split(':')[1]);
				return;
			}
			$('#addrContent').click(function(){$('.addr-person-menu').hide()})[0].innerHTML = html;
			$('#addrFrom').form({
				url:'../MicroMsg/Addresses.asp?__msgId=saveModify',
				onSubmit:function(){
					if(!Validator.Validate(this,2) || !__AreaCheck(this) || !__PhoneCheck(this)){
						return false;
					}
					return true;
				},
				success:function(jsonstr){
					var json = eval('(' + jsonstr + ')');
					if(!json.success){
						alert(json.msg);
						return;
					}
					$addrModifyWindow.dialog('close');
					if (isAddNew){
						addrPage(1,$("#addr_pgsize").val());
					}else{
						$('#addrPageJumpBtn').trigger('click');
					}
				},
				error:function(r){
					alert(r.responseText);
				}
			});

			//选择联系人下拉菜单控制
			$('.addr-person-menu-link').click(function(e){
				$(this).next().toggle();
				setTimeout(function(){
					var h = $('.addr-person-menu').height();
					$('#addrContent').css("height",h);
				},100)
				e.stopPropagation();
			});
				
			$('.addr-person-menu').mouseleave(function(){
				$(this).children().removeClass('addr-person-menu-item-hover');
			}).children().mouseenter(function(){
				$(this).addClass('addr-person-menu-item-hover').siblings().removeClass('addr-person-menu-item-hover');
			}).click(function(e){
				var $this = $(this);
				var pid = $this.attr('pid');
				$.ajax({
					url:'../MicroMsg/Addresses.asp?__msgId=getPersonAddr&pid=' + pid,
					success:function(r){
						var json = eval('(' + r + ')');
						if (json.length>0){
							$addrModifyWindow.find('input[name^="addr_"]').each(function(){
								this.value = eval('json[0].' + this.name.replace('addr_',''));
							});
							$('.addr_areaSelector').html(json[0].areaControl);
							$('.area_full_name').html(json[0].areaFullName);
						}else{
							alert('联系人信息不存在！');
						}
						$this.parent().hide();
					}
				});
				e.stopPropagation();
			});
			//选择联系人下拉菜单控制结束

			$addrModifyWindow.show().dialog({
				title : isAddNew?'收货地址添加':'收货地址修改',
				left : left,
				top : top
			}).dialog('open');
		},
		error:function(r){
			alert(r.responseText);
		}
	});
}

function addrDelete(obj){
	if(!confirm('确定要删除此收货地址吗？')) return;
	$.ajax({
		url:'../MicroMsg/Addresses.asp?__msgId=delete&id=' + $(obj).attr("addrId"),
		success:function(r){
			$('#addrPageJumpBtn').trigger('click');
		}
	});
}

function addrSelect(obj){
	var $this = $(obj);
	var $tr = $this.parentsUntil('tbody').last();

	var result = {
		id : $this.attr('addrId'),
		areaId : $tr.find('.addr_areaId').text(),
		area : $tr.find('.addr_area').text(),
		receiver : $tr.find('.addr_receiver').text(),
		mobile : $tr.find('.addr_mobile').text(),
		mobile_show : $tr.find('.addr_mobile_show').text(),
		phone : $tr.find('.addr_phone').text(),
		phone_show : $tr.find('.addr_phone_show').text(),
		address : $tr.find('.addr_address').text(),
		zip : $tr.find('.addr_zip').text(),
		isDefault : $tr.find('.addr_isDefault').text(),
		fromWx : $tr.find('.addr_fromWx').text()
	};

	if (window.__onAddressSelect){
		window.__onAddressSelect.apply(this,[obj,result]);
	}else{
		alert('未定义回调处理函数window.__onAddressSelect');
	}
}

function __PhoneCheck(frm){
	var result = true;
	var $frm = $(frm);
	var phone = trim(frm.addr_phone.value+"");
	var mobile = trim(frm.addr_mobile.value+"");
	if(phone=="" && mobile=="")	{
		result = false;
	}
	if (!result){
		var $errLabel = $frm.find('input[name="addr_phone"]:last').nextAll('span.errLabel');
		if ($errLabel.size()==0){
			$errLabel = $('<span class="errLabel" style="color:red">&nbsp;请填写固话或手机</span>').insertAfter($frm.find('input[name="addr_phone"]:last'));
		}
		$errLabel.show();
	}else{
		$frm.find('input[name="addr_phone"]:last').nextAll('span.errLabel').hide();
	}
	return result;
}

function __AreaCheck(frm){
	var result = true;
	var $frm = $(frm);
	$frm.find('.addr_area').each(function(){
		var $this = $(this);
		if ($this.children().size()>1){
			if ($this.val().length==0){
				result = false;
			}else{
				$('#area_areaId').val($this.val());
			}
		}
	});

	if (!result){
		var $errLabel = $frm.find('.addr_area:last').nextAll('span.errLabel');
		if ($errLabel.size()==0){
			$errLabel = $('<span class="errLabel" style="color:red">请填写完整区域信息</span>').insertAfter($frm.find('.addr_area:last'));
		}
		$errLabel.show();
	}else{
		$frm.find('.addr_area:last').nextAll('span.errLabel').hide();
	}

	return result;
}

//无限级地区下拉框事件
function __AreaOnChange(obj){
	var $this = $(obj);
	var $box = $this.parent();

	//只需要处理本下拉框后面的控件，无需处理前面的
	//先清空后面所有控件内容
	$this.nextAll('.addr_area').html('<option value="">请选择</option>');
	$box.children('.addr_area:gt('+$this.index()+')').remove();
	var fullName = ''
	$box.children().each(function(){
		var name = $(this).children(':selected').text();
		if ($(this).val().length==0) return false;
		fullName += ' ' + name
	});
	$('.area_full_name').html(fullName);
	if ($this.val().length==0) return;

	//ajax获取本控件下级内容，没有的话会返回一个空数组
	$.ajax({
		url:'../MicroMsg/Addresses.asp?__msgId=getArea&id=' + $this.val(),
		success:function(r){
			try{
				var json = eval('(' + r + ')');
				if (json.length>0){
					var opts = '<option value="">请选择</option>';
					$.each(json,function(){
						opts += '<option value="'+ this.id +'">' + this.name + '</option>';
					});

					$('<select name="area" class="addr_area" style="width:120px;margin:2px 2px 0px 2px;float1:left" onchange="__AreaOnChange(this);">' + opts + '</select>')
					.insertAfter($this);
				}
			}catch(e){
				alert(e.message);
			}
		}
	});
}

var $addrShowSelector = null;
function addrShowSelector(ordType,ord){
	if (!$addrShowSelector){
		$addrShowSelector = $('<div id="addrModifyWindow" class="easyui-window" title="收货地址选择" style="top:100px;width:740px;height:350px;padding:5px;background: #fafafa;"collapsible="false" minimizable="false" modal="true"></div>');
		$addrShowSelector.appendTo(document.body);
		$addrShowSelector.hide().html(''+
				'<div id="addrList" border="false" style="width:700px;margin-top:2px;"></div>' +
		'');
	}

	var top = ($(window).height()-400)/2 + $(document).scrollTop();
	var left = ($(window).width()-600)/2 + $(document).scrollLeft();
	var shouhuoname = $("#shouhuoname").val();
	var serchkey = $("#serchkey").val();
	var serchtext = $("#serchtext").val(); 
	var shadress = $("#shadress").val();
	$.ajax({
		url:'../MicroMsg/Addresses.asp',
		data: { ord: ord ? ord : 0, ordType: ordType, pageindex: 1, pagesize: 10, mode: 'select', shouhuoname: shouhuoname, serchkey: serchkey, serchtext: serchtext, shadress: shadress },
		success:function(html){
			if (html.indexOf('error:')==0){
				alert(html.split(':')[1]);
				return;
			}
			$('#addrList').html(html);
			$('#personAddressList').find("td").css('border','1px solid #c0ccdd');

			$addrShowSelector.show().dialog({
				left : left,
				top : top
			}).dialog('open');
		},
		error:function(r){
			alert(r.responseText);
		}
	});
}

function clearAddr(obj){
	var $this = $(obj);
	$this.prev().empty();
	$this.parent().prev().empty();
	$('#addressSelector').siblings('input:hidden').val('');
	$this.parentsUntil('tbody').last().hide();
}

window.__onAddressSelect = function(obj,r){
	var $obj = $('#addressSelector');
	var $showBox = $obj.parentsUntil("tbody").prev();
	if (!r.id){
		$showBox.hide();
		$obj.parent().find('input').each(function(){
			this.value = '';
		});
		return;
	}

	$showBox.children(':eq(0)').html(r.receiver);
	$showBox.children(':eq(1)').children(':eq(0)').html(
		r.mobile_show + ' ' +
		r.phone_show + ' ' +
		r.area + ' ' +
		r.address + ' ' + 
		r.zip + ' ' +
		r.isDefault + ' ' +
		r.fromWx
	);
	$showBox.show();
	$obj.parent().find('input').each(function(){
		this.value = eval('r.' + this.name);
	});
	if($addrShowSelector) {
		try{$addrShowSelector.dialog('close');}catch(e){}
	}
}

function trim(str) { return str.replace(/(^\s*)|(\s*$)/g, ""); }

function showHelpExplan() {
	var htmlStr = "<div id='bill_help_expaln_text' class='bill_help_expaln_text'>";
	htmlStr += "当无法获取到用户头像和昵称时，可将此授权连接，发送到公众号，让用户接受授权。温馨提示：&lt;a href='" + $("#helpStr").text() + "'> 点击授权 &lt;/a>享更多优惠服务。";
	htmlStr += "<a title='关闭' href='javascript:;' onclick ='closediv()' class='bill_help_expaln_close' style='position:absolute;right:0px;top:0px;padding:10px;line-height:1;text-decoration: none;'>×</a></div>";
	var div = $('<div class="warming-tips" style="border-radius:5px;position: fixed;width: 600px;height: 120px;background: #b2dbfd;left:50%;margin-left: -300px;top: 200px;padding:30px;font-size:14px;word-break:break-all;"></div>');
	div.html(htmlStr)
	$('body').append(div);
}
function closediv() {
	$('.warming-tips').hide();
}