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

// 插入内容方法封装
(function($) {
    $.fn.insertWxContent = function(myValue, t) {
    	var $t = $(this)[0];
    	var sessionobj = $t.document.selection;
    	if (!sessionobj) { sessionobj= $t.document.getSelection(); }
    	if (sessionobj) { //ie
			$t.focus();
			var sel = sessionobj.createRange ? sessionobj.createRange() : sessionobj.getRangeAt(0);
			if (myValue.indexOf('<') >= 0) {
				if (sel.pasteHTML) {
					sel.pasteHTML(myValue);
				} else {
					sel.insertNode($(myValue)[0]);
				}
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


// 

(function(wx) {

	// 表情面板
	var wxFaceSelector = function(callback){	
		var __faces = ['/::)','/::~','/::B','/::|','/:8-)','/::<','/::$','/::X','/::Z','/::\'(','/::-|','/::@','/::P','/::D','/::O','/::(','/::+','/:--b','/::Q','/::T','/:,@P','/:,@-D','/::d','/:,@o','/::g','/:|-)','/::!','/::L','/::>','/::,@','/:,@f','/::-S','/:?','/:,@x','/:,@@','/::8','/:,@!','/:!!!','/:xx','/:bye','/:wipe','/:dig','/:handclap','/:&-(','/:B-)','/:<@','/:@>','/::-O','/:>-|','/:P-(','/::’|','/:X-)','/::*','/:@x','/:8*','/:pd','/:<W>','/:beer','/:basketb','/:oo','/:coffee','/:eat','/:pig','/:rose','/:fade','/:showlove','/:heart','/:break','/:cake','/:li','/:bome','/:kn','/:footb','/:ladybug','/:shit','/:moon','/:sun','/:gift','/:hug','/:strong','/:weak','/:share','/:v','/:@)','/:jj','/:@@','/:bad','/:lvu','/:no','/:ok','/:love','/:<L>','/:jump','/:shake','/:<O>','/:circle','/:kotow','/:turn','/:skip','/:oY','/:#-0','/街舞','/:kiss','/:<&'];
		var __faceMap = {},__faceIdMap = {};
		for (var i=0;i<__faces.length;i++ ){
			__faceMap[i] = __faces[i];
			__faceIdMap[__faces[i]] = i;
		};

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
			var txt = $(img);
			callback.apply(img,[txt.attr("idx"),txt.attr("txt")]);
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
				left : pos.left - face.panel.width() / 3,
				top : pos.top - face.panel.height() - 27,
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

	var wxchat = {},
		_html = [],
		editor = null,
		editorDoc = null,
		meditorWindow = null,
		getInfoTimer = null,
		isOpendWin = false,
		defAvatar = "../hrm/img/noneperson.jpg";

	// 每页显示记录数
	wx.pagesize = 10;
	wx.uid = 0;

	
	// 初始化
	wx.init = function (callback) {
		wx.creatBaseHtml();
					
		// 判断窗口是否已存在
		var dlg = $("#wx-chat-wrap");
		if(dlg.size() == 0) { 
			$("body").append(_html.join(""));
		};
		
		// 执行回调函数
		try{
			if (typeof(callback) == "function") {
				callback();
			};
		}catch (e){};

	};

	// 创建窗口基础结构html
	wx.creatBaseHtml = function () {
		_html.push('<div id="wx-chat-wrap"> ');
		_html.push('	<div class="wx-chat-box"> ');
		_html.push('		<span class="wx_chat_radius radius-top-left"></span> ');
		_html.push('		<span class="wx_chat_radius radius-top-right"></span> ');
		_html.push('		<span class="wx_chat_radius radius-bottom-left"></span> ');
		_html.push('		<span class="wx_chat_radius radius-bottom-right"></span> ');
		_html.push('		<div class="wx-chat-head" id="wxHead"> ');
		_html.push('			<div class="wx-chat-avatar"><img id="wxAvatar" src="'+ defAvatar +'" width="43" height="43"></div> ');
		_html.push('			<div class="wx-chat-nickname" id="wxNickName"></div> ');
		_html.push('			<a class="wx-chat-top-btns wx-chat-close-btns" href="javascript:;" title="关闭"></a> ');
		_html.push('		</div> ');
		_html.push('		<div class="wx-chat-body-wrap"> ');
		_html.push('			<div class="wx-chat-main">		 ');
		_html.push('				<div class="wx-chat-body">					 ');
		_html.push('					<div class="wx-chat-info-show-box"> ');
		_html.push('					</div> ');
		_html.push('				</div>				 ');
		_html.push('				<div class="wx-chat-info-send-box"> ');
		_html.push('					<div class="wx-chat-fun-bar"> ');
		_html.push('						<div class="wx-chat-face"> ');
		_html.push('							<a href="javascript:;" id="faceSelector" class="wx-chat-face-btn"></a> ');
		_html.push('						</div> ');
		_html.push('						<div class="wx-chat-info-his"> ');
		_html.push('							<a href="javascript:;" class="wx-chat-info-his-btn" title="显示消息记录"><span>消息记录</span></a> ');
		_html.push('						</div> ');
		_html.push('					</div> ');
		_html.push('					<div class="wx-chat-textarea"> ');
		_html.push('						<iframe id="designArea" name="xxxxx" style="width:430px; height:95px; overflow-x:hidden; overflow-y:auto;" frameborder="0" scrolling="auto" ></iframe> ');
		_html.push('					</div> ');
		_html.push('					<div class="wx-chart-bottom-btns"> ');
		_html.push('						<input class="anybutton2 wx-chat-close-btns" type="button" name="closeBtn" value="关闭"> ');
		_html.push('						<input class="anybutton2" type="button" name="sendBtn" id="sendBtn" value="发送">						 ');
		_html.push('					</div> ');
		_html.push('				</div> ');
		_html.push('			</div> ');
		_html.push('			<div class="wx-chat-history-bar"> ');
		_html.push('				<div class="wx-chat-history-bar-head"> ');
		_html.push('					<a href="javascript:;" class="wx-chat-info-close" title="关闭">消息记录</a> ');
		_html.push('				</div> ');
		_html.push('				 ');
		_html.push('				<div class="wx-chat-history-bar-body"> ');
//		_html.push('					<div class="wx-chat-date-separator">2016-01-16</div> ');
//		_html.push('					<dl class="wx-chat-his-info me"> ');
//		_html.push('						<dt>杰克<span class="date">14:08:08</span></dt> ');
//		_html.push('						<dd>邦妮，上次我托你办的事怎么样了？</dd> ');
//		_html.push('					</dl> ');
//		_html.push('					<dl class="wx-chat-his-info other"> ');
//		_html.push('						<dt>邦妮<span class="date">14:08:08</span></dt> ');
//		_html.push('						<dd>已经好了</dd> ');
//		_html.push('					</dl> ');
		_html.push('				</div>				 ');
		_html.push('				<div class="wx-chat-history-bar-footer"> ');
		_html.push('					<div class="wx-chat-history-bar-footer-wrap"> ');
		_html.push('						<a href="javascript:;" class="wx-chat-his-datePicker-btn"></a> ');
		_html.push('						<span class="wx-chat-his-date"><input id="wxCurDate" type="text" onclick="datedlg.show();wxchat.calendarPositon();" onchange="wxchat.searchInfoHisByDate(this.value)"></span> ');
		_html.push('						<a href="javascript:;" class="wx-chat-page-btn home" id="pHome" title="第一页"></a> ');
		_html.push('						<a href="javascript:;" class="wx-chat-page-btn prev" id="pPrev" title="上一页"></a> ');
		_html.push('						<a href="javascript:;" class="wx-chat-page-btn next" id="pNext" title="下一页"></a> ');
		_html.push('						<a href="javascript:;" class="wx-chat-page-btn end"	 id="pEnd"  title="最后页"></a> ');
		_html.push('					</div> ');
		_html.push('				</div> ');
		_html.push('			</div> ');
		_html.push('		</div> ');
		_html.push('	</div> ');
		_html.push('</div> ');
	};

	// 初始化信息输入框及表情面板
	var selector;
	wx.infoBoxCreate = function () {
		editorDoc.designMode = "on";
		editorDoc.write("<html><head><style>html { overflow-x:hidden; overflow-y:auto; }</style></head><body style='width:430px;word-break: break-all;margin:0px;padding:3px;font-size:12px;background-color:white;'></body></html>");
		if(!selector){
			selector = new wxFaceSelector(function(idx,txt){
				$(editorWindow).insertWxContent('<img tag="faces" txt="' + txt + '" src="../MicroMsg/face/' + idx + '.gif">');
				
				editor.contentWindow.scrollTo(0,$(editorDoc.body).height());

			});
		};
		$('#faceSelector').click(function(e){
			selector.showSelector(e);
		});
		

		wx.setInfoBoxFocus();
	};

	// 将文字符号转换为表情
	wx.textToFace = function (newText) {
		var __faces = ['/::)','/::~','/::B','/::|','/:8-)','/::<','/::$','/::X','/::Z','/::\'(','/::-|','/::@','/::P','/::D','/::O','/::(','/::+','/:--b','/::Q','/::T','/:,@P','/:,@-D','/::d','/:,@o','/::g','/:|-)','/::!','/::L','/::>','/::,@','/:,@f','/::-S','/:?','/:,@x','/:,@@','/::8','/:,@!','/:!!!','/:xx','/:bye','/:wipe','/:dig','/:handclap','/:&-(','/:B-)','/:<@','/:@>','/::-O','/:>-|','/:P-(','/::’|','/:X-)','/::*','/:@x','/:8*','/:pd','/:<W>','/:beer','/:basketb','/:oo','/:coffee','/:eat','/:pig','/:rose','/:fade','/:showlove','/:heart','/:break','/:cake','/:li','/:bome','/:kn','/:footb','/:ladybug','/:shit','/:moon','/:sun','/:gift','/:hug','/:strong','/:weak','/:share','/:v','/:@)','/:jj','/:@@','/:bad','/:lvu','/:no','/:ok','/:love','/:<L>','/:jump','/:shake','/:<O>','/:circle','/:kotow','/:turn','/:skip','/:oY','/:#-0','/街舞','/:kiss','/:<&'];
		for (var i=0;i<__faces.length;i++){
			newText = newText.replace(new RegExp(wx.regConvert(__faces[i]),"g"),'<img txt="' + __faces[i] + '" src="../MicroMsg/face/' + i + '.gif" tag="faces"/>');
		}
		return newText;		
	};

	// 特殊字符转换
	wx.regConvert = function (s){
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
	};


	// 设置输入框光标
	wx.setInfoBoxFocus = function () {
		setTimeout(function(){
			editor.contentWindow.focus();
		},500);		
	};


	// 获取消息内容
	wx.getRealContent = function (s) {
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
	};



	// 打开微信聊天窗口
	wx.openDlg = function (uid) {
		
		wx.init(function () {
			editor = $('#designArea')[0];		
			editorDoc = editor.contentWindow.document;  
			editorWindow = editor.contentWindow;

			wx.uid = uid;


			// 清除定时器
			window.clearInterval(getInfoTimer);

			// 初始化聊天窗口的头像及昵称
			wx.setChatAvatar(uid);

			// 初始化信息输入框
			wx.infoBoxCreate();

			// 显示隐藏消息记录处理
			wx.showOrHideInfoHis(uid);

			// 显示窗口
			//var sTop = $("#frmbody").contents().find("#mainFrame").contents().scrollTop();
			var sTop = ($(window).height()-520)/2 + $(document).scrollTop();
			$("#wx-chat-wrap").css("top",sTop + "px").show();

			// 使用easyUI 实现拖拽效果
            $('#wx-chat-wrap').draggable({
                handle: '#wxHead'
            });

			// 打开窗口时显示历史消息
			wx.getInfo(uid);

			// 启用定时器接收实时消息
			wx.getCurInfo(uid);

			//wx.setInfoScroll();	

			// 消息发送
			wx.sendInfo(uid);

			// 窗口关闭处理			
			wx.closeDlg();
			
			// Ctrl + Enter 发送消息
			$(editorDoc).unbind("keydown");
			$(editorDoc).bind("keydown",function(e){
				if (e.ctrlKey && e.keyCode == 13){
					$("#sendBtn[disabled!=disabled]").trigger("click");
				};
			});


		});


	};

	// 关闭微信聊天窗口
	wx.closeDlg = function () {
		$(".wx-chat-close-btns").unbind("click");
		$(".wx-chat-close-btns").click(function () {
			$("#wx-chat-wrap").hide();
			
			// 清空聊天记录
			$(".wx-chat-info-show-box").html("");
			
			// 关闭表情面板
			wx.closeFacePannel();

			// 
			setTimeout(function(){
				wx.refresh();
			},100);


			// 清除定时器
			window.clearInterval(getInfoTimer);
		});	

	};

	// 刷新页面
	wx.refresh = function () {
		var talk = $("div.talk").size();
		var lvwbody = $("#lvwbody").size();
		try{
			if(talk == 1){
				ajaxPage(wx.uid,1,5);
				return false;
			}else{
				if(lvwbody == 1){
					lvw_refresh("mlistvw");
				}
			};
		}catch(e){
			
		};		
	};

	// 初始化聊天窗口的头像及昵称
	wx.setChatAvatar = function (uid) {
		var url = "../MicroMsg/MUserList.asp?__msgId=GetChatAvatar";
		$.post(url,{uid:uid},function (data) {
			if(data.length > 0){
				var json = eval('('+ data +')');
				$("#wxAvatar").attr("src","../MicroMsg/" + json.avatar);
				$("#wxNickName").html(json.nickName);
			};
		});
	};

	// 更新信息的时间节点标记
	wx.updateTimeFlag = function (mgID,flag) {
		var url = "../MicroMsg/MUserList.asp?__msgId=updateMsgTimeFlag";
		$.post(url,{mgID:mgID,flag:flag},function(){

		});
	};
	
	// 接收实时消息
	wx.getCurInfo = function (uid) {		
		getInfoTimer = window.setInterval(function(){
			var url = "../MicroMsg/MUserList.asp?__msgId=GetCurMsg";
			$.post(url,{uid:uid},function(data){
				var json = eval('('+ data +')');
				if(json.length > 0){

					var _msg = [];
					var sType = '';
					for (var i = 0;i < json.length ;i++ )
					{
						var flag = -1;
						(json[i].type == "1") ? sType = "other" : sType = "me";

						// 当有时间节点标记 或 是窗口第一次打开 则显示时间分割线
						if(json[i].timeFlag == "1" || !isOpendWin){
							flag = 1;
							// 维护窗口状态
							isOpendWin = true;
							_msg.push(' <div class="wx-chat-item-datetime">'+ json[i].flagTime +'</div> ');
						};
						
						// 更新信息的时间节点标记
						wx.updateTimeFlag(json[i].mgID,flag);

						_msg.push('<dl class="wx-chat-info-item '+ sType +'"> ');
						_msg.push('	<dt class="item-avatar"><img src="'+ wx.showAvatar(json[i].type,json[i].avatar) +'" width="43" height="43" /></dt> ');
						_msg.push('	<dd class="item-body-wrap"> ');
						_msg.push('		<div class="item-body"> ');
						_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-top-left"></span> ');
						_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-top-right"></span> ');
						_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-bottom-left"></span> ');
						_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-bottom-right"></span> ');
						_msg.push('			<span class="wx-chat-item-'+ sType +'-arrow"></span> ');
						_msg.push(''+ json[i].msg +'');
						_msg.push('		</div> ');
						_msg.push('	</dd> ');
						_msg.push('</dl> ');					

					};

					$(".wx-chat-info-show-box").append(_msg.join(""));
					
					wx.setInfoScroll();	
				};	
						
			});

		},3000);
	};

	// 获取历史消息的最后3条
	wx.getInfo = function (uid) {		
		var url = "../MicroMsg/MUserList.asp?__msgId=GetRecentlyMsg";
		$.post(url,{uid:uid},function (data) {
			var json = eval('('+ data +')');
			if(json.rows.length > 0){
				var _msg = [];
				var sType = '';
				var len = json.rows.length;

				// 如果获取的数据大于3条 则显示查看更多 否则不显示
				if(len > 3){
					len = len -1;
					_msg.push('<div class="wx-chat-view-more-inof"><a href="javascript:;" class="wx-chat-more-info-btn" mgID="'+ json.rows[0].mgID +'">查看更多消息</a></div> ');			
				};
				for (var i = 1;i < json.rows.length ;i++ )
				{
					(json.rows[i].type == "1") ? sType = "other" : sType = "me";

					if(json.rows[i].timeFlag == "1"){
						_msg.push(' <div class="wx-chat-item-datetime">'+ json.rows[i].flagTime +'</div> ');
					};

					_msg.push('<dl class="wx-chat-info-item '+ sType +'"> ');
					_msg.push('	<dt class="item-avatar"><img src="'+ wx.showAvatar(json.rows[i].type,json.rows[i].avatar) +'" width="43" height="43" /></dt> ');
					_msg.push('	<dd class="item-body-wrap"> ');
					_msg.push('		<div class="item-body"> ');
					_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-top-left"></span> ');
					_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-top-right"></span> ');
					_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-bottom-left"></span> ');
					_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-bottom-right"></span> ');
					_msg.push('			<span class="wx-chat-item-'+ sType +'-arrow"></span> ');
					_msg.push(''+ json.rows[i].msg +'');
					_msg.push('		</div> ');
					_msg.push('	</dd> ');
					_msg.push('</dl> ');					

				};
				_msg.push('<div class="wx-chat-his-info-saparator">以上是历史消息</div> ');

				$(".wx-chat-info-show-box").html(_msg.join(""));
				
									
				// 点击获取更多信息
				if(json.rows.length > 3){					
					wx.loadMoreInfo(uid,json.rows[0].mgID);
				};

				// 初始化默认日期
				$("#wxCurDate").val(json.curDate);	

				// 
				wx.setInfoScroll();	
			};

		});

	};


	// 消息显示区域滚动条控制
	wx.setInfoScroll = function () {
		var box = $(".wx-chat-info-show-box");
		var h = box[0].scrollHeight + 30;
		box.scrollTop(h);		
	};

	// 历史消息显示区域滚动条控制
	wx.setHisInfoScroll = function () {
		var box = $(".wx-chat-history-bar-body");
		var h = box[0].scrollHeight + 30;
		box.scrollTop(h);		
	};
	
	// 发送消息
	wx.sendInfo = function (uid) {
		$("#sendBtn").unbind("click");
		$("#sendBtn[disabled!=disabled]").bind("click",function () {
			var $btn = $(this);
			var html = getRealContent(editorDoc.body.innerHTML);
			html=html.replace(/\[!br!\]/gi,'\n');
			html=html.replace(/\[!space!\]/gi,' ');
			html=html.replace(/\[!([WLO])!\]/g,'<$1>');
			html=html.replace(/[\xa0]/gi,'\n');
			while (/[\n ]$/.test(html)){
				html = html.replace(/[\n ]$/,'');
			};

			wx.setInfoBoxFocus();
			wx.closeFacePannel();

			if (html.length==0){
				alert('发送内容不能为空，请重新输入。');
				return;
			};

			if (html.length>600){
				alert('消息内容长度超过限制（600个字符）！');
				return;
			};

			$btn.attr('disabled','disabled').val('发送中');
			$.ajax({
				url:'../MicroMsg/MUserList.asp?__msgId=postTextMsg',
				data:{uid:uid,msg:html},
				type:'post',
				success:function(r){
					r = eval('('+r+')');
					if (r.success){
						wx.closeDlg();

						$(editorDoc.body).empty();
						
						html = wx.textToFace(html);
						var _msg = [];

						// 当有时间节点标记 或 是窗口第一次打开 则显示时间分割线
						if(!isOpendWin){
							flag = 1;
							// 更新信息的时间节点标记
							wx.updateTimeFlag(r.mgID,flag);
							// 维护窗口状态
							isOpendWin = true;
							_msg.push(' <div class="wx-chat-item-datetime">'+ new Date().toLocaleTimeString() +'</div> ');
						};
						
						if(r.userAvatar.length == 0){
							userAvatar = defAvatar;
						}else{
							userAvatar = r.userAvatar;
						};

						_msg.push('<dl class="wx-chat-info-item me"> ');
						_msg.push('	<dt class="item-avatar"><img src="'+ userAvatar +'" width="43" height="43" /></dt> ');
						_msg.push('	<dd class="item-body-wrap"> ');
						_msg.push('		<div class="item-body"> ');
						_msg.push('			<span class="wx-chat-item-me-radius radius-itemp-top-left"></span> ');
						_msg.push('			<span class="wx-chat-item-me-radius radius-itemp-top-right"></span> ');
						_msg.push('			<span class="wx-chat-item-me-radius radius-itemp-bottom-left"></span> ');
						_msg.push('			<span class="wx-chat-item-me-radius radius-itemp-bottom-right"></span> ');
						_msg.push('			<span class="wx-chat-item-me-arrow"></span> ');
						_msg.push(''+ html +'');
						_msg.push('		</div> ');
						_msg.push('	</dd> ');
						_msg.push('</dl> ');

						$(".wx-chat-info-show-box").append(_msg.join(""));

						wx.setInfoScroll();
						
					}else{						
						alert('发送失败：'+r.msg);
					};
					$btn.attr('disabled',false).val('发送');
				}
			});


		});
	};


	// 显示或隐藏消息记录
	wx.showOrHideInfoHis = function (uid) {
		var dlg = $("#wx-chat-wrap");
		$(".wx-chat-info-his-btn").unbind("click");
		$(".wx-chat-info-his-btn").bind("click",function(){
			var act = $(this).parent(".wx-chat-info-his-active").size();
			if(act > 0){
				$(".wx-chat-info-his").removeClass("wx-chat-info-his-active");
				$(".wx-chat-history-bar").hide();
				dlg.width(440);
				return false;
			};
			// 
			wx.showInfoHis(uid,1,10);

			$(".wx-chat-info-his").addClass("wx-chat-info-his-active");
			$(".wx-chat-history-bar").show();
			dlg.width(801);
		});

		$(".wx-chat-info-close").unbind("click");
		$(".wx-chat-info-close").bind("click",function(event) {
			$(".wx-chat-info-his").removeClass("wx-chat-info-his-active");
			$(".wx-chat-history-bar").hide();
			dlg.width(440);
		});
		
		setTimeout(function () { $(".wx-chat-info-close").trigger("click"); },1);
	};

	// 显示表情面板
	wx.showFacePannel = function () {
		
	};

	// 关闭表情面板
	wx.closeFacePannel = function () {
		$("#facePanel").hide();
	};

	// 显示头像
	wx.showAvatar = function (type,path) {
		var img = "";
		if(path.length == 0){
			img = defAvatar;		
		}else{
			if(type == "2"){
				img = "../hrm/load/" + path;
			}else{
				img = "../MicroMsg/" + path;
			};
		};
		return img;
	};

	// 加载更多消息
	wx.loadMoreInfo = function (uid,mgID) {
		var btn = $(".wx-chat-more-info-btn");
		var box = $(".wx-chat-info-show-box");

		btn.unbind("click");
		btn.bind("click",function () {	
			var url = "../MicroMsg/MUserList.asp?__msgId=GetMoreMsg";
			$.post(url,{uid:uid,mgID:mgID},function (data) {
				var json = eval('('+ data +')');
				if(json.length > 0){
					var _msg = [];
					var sType = '';
					var len = json.length;

					//
					btn.parent().remove();

					// 如果获取的数据大于10条 则显示查看更多 否则不显示
					if(len > 10){
						len = len -1;						
						_msg.push('<div class="wx-chat-view-more-inof"><a href="javascript:;" class="wx-chat-more-info-btn" mgID="'+ json[0].mgID +'">查看更多消息</a></div> ');
					}else{
						btn.parent().remove();	
					};
					
					for (var i = 0;i < len ;i++ )
					{
						(json[i].type == "1") ? sType = "other" : sType = "me";

						if(json[i].timeFlag == "1"){
							_msg.push(' <div class="wx-chat-item-datetime">'+ json[i].flagTime +'</div> ');
						};

						_msg.push('<dl class="wx-chat-info-item '+ sType +'"> ');
						_msg.push('	<dt class="item-avatar"><img src="'+ wx.showAvatar(json[i].type,json[i].avatar) +'" width="43" height="43" /></dt> ');
						_msg.push('	<dd class="item-body-wrap"> ');
						_msg.push('		<div class="item-body"> ');
						_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-top-left"></span> ');
						_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-top-right"></span> ');
						_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-bottom-left"></span> ');
						_msg.push('			<span class="wx-chat-item-'+ sType +'-radius radius-itemp-bottom-right"></span> ');
						_msg.push('			<span class="wx-chat-item-'+ sType +'-arrow"></span> ');
						_msg.push(''+ json[i].msg +'');
						_msg.push('		</div> ');
						_msg.push('	</dd> ');
						_msg.push('</dl> ');					

					};

					$(".wx-chat-info-show-box").prepend(_msg.join(""));
					
					if(json.length > 10){
						wx.loadMoreInfo(uid,json[0].mgID);
					};

					// 
					//wx.setInfoScroll();	
				};				
			});

		});
	};

	// 显示历史消息记录
	wx.showInfoHis = function (uid,pageindex,pagesize,sDate) {
		var url = "../MicroMsg/MUserList.asp?__msgId=GetHisMsg";
		$.post(url,{uid:uid,pageindex:pageindex,pagesize:pagesize,sDate:sDate},function (data) {
			var json = eval('('+ data +')');
			
			if(json.rows.length > 0){
				var _msg = [];
				var sType = '';
				if(!!sDate){
					_msg.push('<div class="wx-chat-date-separator">'+ sDate +'</div> ');					
				};

				for (var i = json.rows.length -1;i >= 0 ;i--)
				{					
					sType = (json.rows[i].type == "1") ? "other" : "me";

					if(json.rows[i].timeFlag == "1"){
						_msg.push(' <div class="wx-chat-item-datetime">'+ json.rows[i].flagTime +'</div> ');
					};
					
//					_msg.push('<div class="wx-chat-date-separator">2016-01-16</div> ');
					_msg.push('<dl class="wx-chat-his-info '+ sType +'"> ');
					_msg.push('	<dt>'+ json.rows[i].nickName +'<span class="date">'+ json.rows[i].createTime +'</span></dt> ');
					_msg.push('	<dd>'+ json.rows[i].msg +'</dd> ');
					_msg.push('</dl> ');					

				};

				$(".wx-chat-history-bar-body").html(_msg.join(""));
	
				//
				wx.hisInfoPage(uid,json.pageinfo.pageindex,json.pageinfo.pagecount);

				// 
				wx.setHisInfoScroll();	
			}else{
				if(!!sDate){
					$(".wx-chat-history-bar-body").html('<div class="wx-chat-date-separator">'+ sDate +'</div>');
				};				
			};



		});		
	};

	// 消息记录翻页处理
	wx.hisInfoPage = function (uid,pageindex,pagecount) {
		var home = $("#pHome");
		var prev = $("#pPrev");
		var next = $("#pNext");
		var end  = $("#pEnd");

		pageindex = parseInt(pageindex)
		pagecount = parseInt(pagecount)

		home.unbind("click")
		home.bind("click",function () {
			wx.showInfoHis(uid,pagecount,wx.pagesize);
		});

		prev.unbind("click")
		prev.bind("click",function () {
			wx.showInfoHis(uid,pageindex + 1,wx.pagesize);
		});

		next.unbind("click")
		next.bind("click",function () {
			wx.showInfoHis(uid,pageindex - 1,wx.pagesize);
		});

		end.unbind("click")
		end.bind("click",function () {
			wx.showInfoHis(uid,1,wx.pagesize);
		});

	};

	// 按日期检索消息记录
	wx.searchInfoHisByDate = function (date) {
		wx.showInfoHis(wx.uid,1,999999,date);

	};

	// 处理日期选择框显示位置问题
	wx.calendarPositon = function () {
		var w = $("#wx-chat-wrap");
		wLeft = parseInt(w.css("left"));
		wTop = parseInt(w.css("top"));
		var c = $("#calendardiv"),
			l = wLeft + 245 + "px",
			t = wTop + 280 + "px";

		c.css({left:l,top:t,"z-index":"9999999999"});
	};

	//
	wx.preventRepeatClick = function (ele) {
		var dis = ele.getAttribute("disabled")
		if (dis !== "true") {
			ele.setAttribute("disabled","true")
		};
		
		setTimeout(function () {
			ele.setAttribute("disabled","");
		},500);
	};

	return window.wxchat = wxchat = wx;
})(window)