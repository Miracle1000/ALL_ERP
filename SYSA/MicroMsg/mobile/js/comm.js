function gotourl(sReplaceValue)
{ 
	var allurl=document.URL.split("?");
	/*当前页面URL，如：http://127.0.0.1/work/telhy2.asp?currpage=1&a=1&b=2&c=3*/ 
	var baseurl="";/*基础URL,比如：http://127.0.0.1/work/telhy2.asp*/ 
	var baseparam="";/*基础参数,比如：currpage=1&a=1&b=2&c=3*/
	if (allurl.length > 0) baseurl = allurl[0].replace(/\#/g, ""); 
	var strpara=getUrl(sReplaceValue); 
	var finalurl=baseurl+(strpara.length==0?"":"?")+strpara; 
	window.location=finalurl; 
};

function getUrl(sReplaceValue){ 
	var allurl=document.URL.split("#")[0].split("?");
	/*当前页面URL，只取#号前的部分（如果有的话），如：http://127.0.0.1/work/telhy2.asp?currpage=1&a=1&b=2&c=3*/ 
	var baseparam="";/*页面参数,比如：currpage=1&a=1&b=2&c=3*/
	sReplaceValue = sReplaceValue || "";
	baseparam = allurl.length > 1 ? allurl[1] : "";
	//if (sReplaceValue.length==0 || sReplaceValue.indexOf("=")<0 ) return baseparam;
	var arrparam=baseparam.split("&");/*分割原始参数*/ 
	var arrvalue=sReplaceValue.split("&");/*分割需更新的参数*/ 
	//循环需更新的参数
	for(var i=0;i<arrvalue.length;i++) { 
		//BUG 7150 Sword 2015-2-28 客户列表切换至高级检索条件时候报错 
		if (arrvalue[i].indexOf("=")<0) continue;
		var flg=false;//参数是否已匹配上
		var vnode=arrvalue[i].split("=");
		var vkey=vnode[0],vvalue=vnode[1];
		//在基础参数中逐个匹配
		for(var j=0;j<arrparam.length;j++){ 
			var pnode=arrparam[j].split("=");
			var pkey=pnode[0];
			//找到了参数，修改参数值
			if(pkey.toLowerCase() == vkey.toLowerCase()){ 
				arrparam[j] = (vvalue == ""?"" : pkey+"=" + UrlEncode(vvalue)); 
				flg=true;
				break;
			}; 
		}; 

		//没找到则需要加入到参数数组中
		if(!flg){
			arrparam.push(vkey + "=" + UrlEncode(vvalue));
		};
	};

	//删除没有值的参数
	for(var i=0;i<arrparam.length;i++){
		var pnode=arrparam[i].split("=");
		if (pnode.length<2 || pnode[1].length==0){
			arrparam.splice(i--,1);
		};
	};

	return arrparam.join("&");
};

function UrlEncode(data) {
    var ascCodev = "& ﹙ ﹚ ﹛ ﹜ ＋ － × ÷ ﹢ ﹣ ≠ ≤ ≥ ≈ ≡ ≒ ∥ ／ ± ＜ ＞ ﹤ ﹥ ≦ ＝ ≧ ≌ ∽ ≮ ≯ ∶ ∴ ∵ ∷ ⊙ ∑ ∏ ∪ ∩ ∈ ⌒ ⊥ ∠ ㏑ ￠ ㏒ ∟ √ ∨ ∧ ∞ ∝ ∮ ∫ ％ ‰ ℅ ° ℃ ℉ ′ ″ 〒 ¤ ○ ￡ ￥ ㏕ ♂ ♀ △ ▽ ● ○ ◇ □".split(" ");
    var ascCodec = "%26+%A9v+%A9w+%A9x+%A9y+%A3%AB+%A3%AD+%A1%C1+%A1%C2+%A9%80+%A9%81+%A1%D9+%A1%DC+%A1%DD+%A1%D6+%A1%D4+%A8P+%A1%CE+%A3%AF+%A1%C0+%A3%BC+%A3%BE+%A9%82+%A9%83+%A8Q+%A3%BD+%A8R+%A1%D5+%A1%D7+%A1%DA+%A1%DB+%A1%C3+%A1%E0+%A1%DF+%A1%CB+%A1%D1+%A1%C6+%A1%C7+%A1%C8+%A1%C9+%A1%CA+%A1%D0+%A1%CD+%A1%CF+%A9R+%A1%E9+%A9S+%A8N+%A1%CC+%A1%C5+%A1%C4+%A1%DE+%A1%D8+%A1%D3+%A1%D2+%A3%A5+%A1%EB+%A8G+%A1%E3+%A1%E6+%A8H+%A1%E4+%A1%E5+%A8%93+%A1%E8+%A1%F0+%A1%EA+%A3%A4+%A9T+%A1%E1+%A1%E2+%A1%F7+%A8%8C+%A1%F1+%A1%F0+%A1%F3+%A1%F5".split("+");

    data = data.replace(/\s/g, "kglllskjdfsfdsdwerr")
    if (!isNaN(data) || !data) { return data; }
    for (var i = 0; i < ascCodev.length; i++) {
        var re = new RegExp(ascCodev[i], "g")
        data = data.replace(re, "ajaxsrpchari" + i + "endbyjohnny");
        re = null;
    }
    data = escape(data);
    for (var i = ascCodev.length - 1; i > -1; i--) {
        var re = new RegExp("ajaxsrpchari" + i + "endbyjohnny", "g")
        data = data.replace(re, ascCodec[i]);
    }
    data = data.replace(/\+/g, "%2B")
    data = data.replace(/\*/g, "%2A"); 	//置换*		
    data = data.replace(/\-/g, "%2D"); 	//置换-
    data = data.replace(/\./g, "%2E"); 	//置换.
    data = data.replace(/\@/g, "%40"); 	//置换@
    data = data.replace(/\_/g, "%5F"); 	//置换_
    data = data.replace(/\//g, "%2F"); 	//置换/
    data = data.replace(/kglllskjdfsfdsdwerr/g, "%20");
    return data;
};




function gotourl(sReplaceValue) 
{ 
	var allurl=document.URL.split("?");	
	var baseurl="";
	var baseparam="";
	if (allurl.length > 0) baseurl = allurl[0].replace(/\#/g, ""); 
	var strpara=getUrl(sReplaceValue); 
	var finalurl=baseurl+(strpara.length==0?"":"?")+strpara; 
	window.location=finalurl; 
}; 

function getUrl(sReplaceValue){ 
	var allurl=document.URL.split("#")[0].split("?");	
	var baseparam="";
	sReplaceValue = sReplaceValue || "";
	baseparam = allurl.length > 1 ? allurl[1] : "";	
	var arrparam=baseparam.split("&");
	var arrvalue=sReplaceValue.split("&");
	for(var i=0;i<arrvalue.length;i++) { 		
		if (arrvalue[i].indexOf("=")<0) continue;
		var flg=false;
		var vnode=arrvalue[i].split("=");
		var vkey=vnode[0],vvalue=vnode[1];		
		for(var j=0;j<arrparam.length;j++){ 
			var pnode=arrparam[j].split("=");
			var pkey=pnode[0];			
			if(pkey.toLowerCase() == vkey.toLowerCase()){ 
				arrparam[j] = (vvalue == ""?"" : pkey+"=" + UrlEncode(vvalue)); 
				flg=true;
				break;
			}; 
		}; 

		
		if(!flg){
			arrparam.push(vkey + "=" + UrlEncode(vvalue));
		};
	};

	
	for(var i=0;i<arrparam.length;i++){
		var pnode=arrparam[i].split("=");
		if (pnode.length<2 || pnode[1].length==0){
			arrparam.splice(i--,1);
		};
	};

	return arrparam.join("&");
};

$(function(){


	$(".zb-icon-back").click(function(e) {
		var c = this.className;
		if(c.match("zb-home")){
			window.location.href='../index.asp'
		}else{
			window.history.back();
		};
		
	});	

	
	$(".zb-close").bind("click",function () {
		ui.close()
	});

	$(".zb-icon-home").bind("click",function () {
		window.location.href = "../index.asp";
	})


	
	$(".zb-icon-save").unbind("click");
	$(".zb-icon-save").bind('click', function() {
		var dis = $(this).attr("disabled")
		if (dis !== "true") {
			$("form").unbind("submit");
			$("form").bind("submit",function () {
				return ui.validForm($(this));
			}).submit();

			p.setAttribute("disabled","true")
		};
		setTimeout(function () {
			p.attr("disabled","");
		},2000);	
	});
	
});


var ui = {};

ui.close = function () {
	window.opener=null;  
    window.open('','_self');  
    window.close();	
};


ui.dialog = function (tit,body,callback) {
	$(function () {
		$("<div id='zb-mask' class='zb-mask'></div>").appendTo("body");
		$("<div id='zb-dialog' class='zb-dialog'><div class='zb-dialog-header'>"+ tit +"<span class='mui-icon mui-icon-close zb-dialog-btn-close'></span></div><div class='zb-dialog-body'></div></div>").appendTo("body");
		$(".zb-dialog-body").append(body);
		
		$(".zb-dialog-btn-close").click(function(){
			ui.closeDialog();
		});

		if (callback) {
			callback();
		};
	});	
};


ui.closeDialog = function () {
	$(function () {	
		$("#zb-mask").remove();
		$("#zb-dialog").remove();	
	});	
};


ui.confirm = function (tit,body,callback) {
	$(function () {
		$("<div id='zb-mask' class='zb-mask'></div>").appendTo("body");
		$("<div id='zb-dialog' class='zb-dialog zb-confirm'><div class='zb-dialog-header'>"+ tit +"</div><div class='zb-dialog-body'></div><div class='zb-dialog-btns'><button id='confirmCancel' class='mui-btn mui-btn-blue'>取消</button><button id='confirmOk' class='mui-btn mui-btn-blue'>确定</button></div></div>").appendTo("body");
		$(".zb-dialog-body").append(body);
		
		$("#confirmCancel").click(function(){
			ui.confirmDialog();
		});
		
		$("#confirmOk").click(function(){
			if (callback) {
				callback();
			}else{
				ui.confirmDialog();	
				return;
			};						
		});


	});	
};

ui.confirmDialog = function () {
	$(function () {	
		$("#zb-mask").remove();
		$("#zb-dialog").remove();
	});
};

// 选择分类对话框
ui.categoryDialog = function (pid,jsonData,callback) {
	
	var _html = [];
	_html.push("<div class='category-dialog' pid='"+ pid +"'>");
	_html.push("<div class='category-dialog-header'><span class='mui-icon mui-icon-back category-dialog-close'></span><h3>分类选择</h3></div>");
	_html.push("<div class='category-dialog-body'>");
	_html.push("<ul class='category-dialog-list-table'>");

	for(var i = 0; i < jsonData.length; i++) {
		var cname = jsonData[i].cname,
			cid = jsonData[i].cid,
			children = jsonData[i].children || 0;
		if(typeof(children) == "object"){children = 1};
		_html.push("<li class='category-dialog-list-cell' cname='"+ cname +"' cid='"+ cid +"' pid='"+ pid +"' children='"+ children +"'>"+ cname +"");
		if(children == 1){
			_html.push("<span class='mui-icon mui-icon-forward category-dialog-go'></span>")
		};
		_html.push("</li>");
	};

	_html.push("</ul>");
	_html.push("</div>");
	_html.push("</div>");

	$(_html.join("")).appendTo("body");

	// 关闭处理
	$(".category-dialog-close").click(function () {		
		ui.categoryDialogClose(pid);
	});

	// 执行回调函数
	if (callback)
	{
		callback();
	};
};

// 分类对话框关闭
ui.categoryDialogClose = function (pid) {
	$(".category-dialog[pid="+ pid +"]").remove();
};

//
ui.categoryDialogCloseAll = function () {
	$(".category-dialog").remove();
};




ui.toast = function (msg) {
	$("<div class='zb-toast'>"+ msg +"</div>").appendTo("body");

	setTimeout(function () {		
		$(".zb-toast").show().fadeOut(1000).remove();
	},3000);

	return;
};

ui.progressBar = function(html) {
	if(!html){
		html = "亲，努力加载中，请稍候...";
	};
	var _html = [];
	_html.push("<div id='zb-progress' class='zb-loading-box'>");
	_html.push("	<div class='zb-loading-box-body'>");
	_html.push("		<table><tr><td><div class='zb-loading-img'></div></td><td>"+ html +"</td></tr></table>");
	_html.push("	</div>");
	_html.push("</div>");

	$(_html.join("")).appendTo("body");
};

ui.progressBarClose = function() {	
	$("#zb-progress").remove();	
};


ui.validForm = function (form) {
	var result = true;
	form.find("input[required],textarea[required]").each(function (index,ele) {
		var v = $(ele).val(),
			fName = $(ele).siblings("label").text(),
			min = $(ele).attr("min"),
			max = $(ele).attr("max");
		if (v.length == 0) {			
			ui.toast("请填写"+ fName +"！");			
			$(ele).addClass("zb-error");
			$(ele).focus();
			return result = false;
		}else{
			$(ele).removeClass("zb-error");
			$(ele).blur();
		};

		if (max && v.length > max) {
			ui.toast(fName +"必须在["+ min +" - "+ max +"]字之间！");
			$(ele).addClass("zb-error");
			$(ele).focus();
			return result = false;
		}
		else{
			$(ele).removeClass("zb-error");
			$(ele).blur();
		};

	});

	return result;
};

// 清楚内容
ui.inputClear = function () {
	$("input.zb-input-clear").each(function (index,ele) {		
		$(this).parent().append("<span class='zb-icon zb-icon-clear'></span>");

		ele.addEventListener("input",function () {
			$(this).siblings(".zb-icon-clear").fadeIn();
		});

		ele.addEventListener("focus",function () {
			var v = $(ele).val();
			if (v.length > 0) {
				$(this).siblings(".zb-icon-clear").fadeIn();
			};			
		});

		
	});

	var $ele = $(".zb-icon-clear");
	$ele.click(function (e) {
		var $input = $(this).siblings("input.zb-input-clear");		
		$input.val("");		
		$(this).fadeOut();
		$input.focus();
	});

};


ui.formatTextString = function(content)  
{  
    var str = content || "";  
    try{  
        str=str.replace(/\r\n/g,"</br>")  
        str=str.replace(/\n/g,"</br>");  
    }catch(e) {  
        alert(e.message);  
    }  
    return str;  
};

ui.inputSpeech = function () {
	$(".mui-input-speech").each(function () {
		$(this).parent().append("<span class='mui-icon mui-icon-speech'></span>");
	});

	var voice = {
	  localId: '',
	  serverId: ''
	};

	// 识别语音
	function translateVoice () {
		wx.translateVoice({
			localId: voice.localId,
			complete: function (res) {
				if (res.hasOwnProperty('translateResult')) {
					var result = res.translateResult.toString().replace(/[\?|？|\.|。|\,|，|\!|！| ]/g,"");
					var sInput = $(".zb-quick-search #search");
					var sForm = $(".zb-quick-search #listForm");
					sInput.val(result);
					sForm.submit();

				} else {
					// alert('无法识别');
				};
			}
		});
	};


	var sbtn = $(".zb-quick-search .mui-icon-speech");
	sbtn.click(function (e) {
		ui.recordBox();
		wx.startRecord({
			complete: function () {
				setTimeout(function () {
					// 停止录音
					ui.recordBoxClose();
					wx.stopRecord({
						success: function (res) {
							voice.localId = res.localId;
							translateVoice ();
						},
						fail: function (res) {
							alert(JSON.stringify(res));
						}
					});
				},5000)
			},
		 	cancel: function () {
		    	// alert('用户拒绝授权录音');
		 	}
		});


	});


};


ui.recordBox = function () {
	var _html = [];
	
	_html.push("<div class='zb-record-box'>");
		_html.push("<div class='zb-speech-recognition'>");
			_html.push("<span class='zb-icon zb-speech-microphone'></span>");
			_html.push("<div class='zb-speech-puls-box'>");
				_html.push("<span class='zb-speech-pulse p1'></span>");
				_html.push("<span class='zb-speech-pulse p2'></span>");
				_html.push("<span class='zb-speech-pulse p3'></span>");
				_html.push("<span class='zb-speech-pulse p4'></span>");
				_html.push("<span class='zb-speech-pulse p5'></span>");
				_html.push("<span class='zb-speech-pulse p6'></span>");
				_html.push("<span class='zb-speech-pulse p7'></span>");
				_html.push("<span class='zb-speech-pulse p8'></span>");
			_html.push("</div>");
			_html.push("<span class='zb-speechtext'>正在录音</span>");
		_html.push("</div>");
	_html.push("</div>");

	$("body").append(_html.join(""));

};

ui.recordBoxClose = function () {
	$(".zb-record-box").remove();
};

$(function () {
	ui.inputClear();
	ui.inputSpeech();

	// 首页尾页提示
	$(".homePage").click(function () {
		ui.toast("已经是第一页！");
	});

	$(".endPage").click(function () {
		ui.toast("已经是最后一页！");
	});

	// 列表项点击效果
	$(".zb-table-view").click(function(){
		$(".zb-table-view").removeClass("active")
		$(this).addClass("active");
	});



	// 选择分类
	$("#category").click(function () {
		var pid = 0;
		var act = $(this).attr("action");
		selectCategory(pid);
		function selectCategory(pid) {
			ui.progressBar();
			$.post("../fun.asp",{action:act,pid:pid},function (data) {
				var jsonData;
				if (data.length > 0)
				{
					jsonData = JSON.parse(data)
				}else{
					ui.toast('获取分类失败！');
					return;
				};
								
				ui.categoryDialog(pid,jsonData,function(){ 
					ui.progressBarClose(); 

					// 点击弹出下级分类
					$(".category-dialog-list-cell[children=1]").unbind('click');
					$(".category-dialog-list-cell[children=1]").on("click",function(){
						
						$(this).siblings().removeClass("active");
						$(this).addClass("active");

						var cid = $(this).attr("cid");
						selectCategory(cid);
						
					});
					
					// 点击完成分类选择
					$(".category-dialog-list-cell[children=0]").unbind('click');
					$(".category-dialog-list-cell[children=0]").on("click",function(){
						
						$(this).siblings().removeClass("active");
						$(this).addClass("active");

						var cid = $(this).attr("cid"),
							cname = $(this).attr("cname");
						$("#category").val(cname);
						$("#category").siblings("input[name=category]").val(cid);

						ui.categoryDialogCloseAll();
					});

				});

			});

		};

	});

});




// 日期选择器
$(function(){	
	$(".mui-date-picker").each(function (i,ele) {
		(function($) {							
				ele.addEventListener('tap', function() {
					var optionsJson = this.getAttribute('data-options') || '{}';
					var options = JSON.parse(optionsJson);
					var id = this.getAttribute('id');
					var self = this;
					self.focus();
					var picker = new $.DtPicker(options);
					picker.show(function(rs) {
						self.value = rs.value;
						picker.dispose();
					});
				}, false);				
		})(mui);
	});

});

var vpathtmp = window.location.href.toLowerCase().split("/sysa/")[0].split("//")[1];
window.virPathCode = vpathtmp.replace(vpathtmp.split("/")[0],"");