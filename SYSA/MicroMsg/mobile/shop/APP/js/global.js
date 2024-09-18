var randcode = Math.random();

//函数.判断状态是否为1 为1超时
function doStatus(data){
	if(data.header.status == 1){
		wx.closeWindow();
	}else{
		return true;
	}
}

//函数.获取网址里的信息
function GetQueryString(name){
	var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
	var r = window.location.search.substr(1).match(reg);
	return (r!=null?decodeURI(r[2]):null);
}

//函数.自定义弹框
function createAlert(msg){
	var $div = $('<div style="position: fixed;top: 0;left: 0;height: 100%;width: 100%;z-index:99999" id="Tig">'+
									'<ul style="color: #fff;background:rgba(0,0,0,0.5);width: 200px;border-radius: 5px;margin:200px auto;">'+
											'<li style="padding:38px 5px;text-align:center">温馨提示5:'+msg+'</li>'+
									'</ul>'+
								'</div>');
	$("body").append($div);
	setTimeout(function(){
		$div.hide();
		$div.remove();
	},1000);
}

//函数.自定义确认弹框
function createConfirm(msg,fun1,fun2){
	console.log("1");
	var $div = $('<div id="confirmDiv">'+
					'<div>'+
						'<p style="border-bottom: 1px solid #ddd;padding-bottom: 10px;">'+msg+'</p>'+
						'<p style="overflow: hidden;clear: both;" class="btnGroups">'+
							'<span class="fl btn btn-danger" id="confirm">确定</span>'+
							'<span class="fr btn btn-danger" id="cancel">取消</span>'+
						'</p>'+
					'</div>'+
				'</div>');
	$("body").append($div);
	$("#confirm").unbind().bind("click",function(){
		fun1.call(this,[]);
		$div.remove();

	})
	$("#cancel").unbind().bind("click",function(){
		fun2.call(this,[]);
		$div.remove();
	})
}

//函数.获取图片路径
function getImgPath(path){
	path = path || '';
	var fileExt = path.split('.').pop();
	var o = {
		path : path,
		middle : path.substring(0,path.length - fileExt.length - 1) + '_m.' + fileExt,
		small : path.substring(0,path.length - fileExt.length - 1) + '_s.' + fileExt,
	};
	return o;
}

//函数.微信信息注册
function wxcnfg(ticket){
	ticket = ticket || {
		appId:'111',
		timestamp:'222',
		nonceStr:'333',
		signature:'444',
	};
	wx.config({
		debug: false,//开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
		appId: ticket.appId, // 必填，公众号的唯一标识
		timestamp: ticket.timestamp, // 必填，生成签名的时间戳
		nonceStr: ticket.nonceStr, // 必填，生成签名的随机串
		signature: ticket.signature,// 必填，签名，见附录1
		jsApiList: [
			'checkJsApi',
			'chooseWXPay',
			'closeWindow',
			'onMenuShareAppMessage',
			'scanQRCode',
			'startRecord',
			'stopRecord',
			'translateVoice'
		]  
	});
}

//函数.获取字段
function getPro(arr){
	var o = {};	
	for(var k=0;k<arr.length;k++){
		o[arr[k].id] = k;
	}
	return o;
} 
//函数.获取text
function getAttr(arr){
	var o = {};	
	for(var k=0;k<arr.length;k++){
		o[arr[k].id] = arr[k].text || '';
	}
	return o;
} 

//特殊字符转
var htmlDecode = function(str) {
    return str.replace(/&#(x)?([^&]{1,5});?/g,function($,$1,$2) {
        return String.fromCharCode(parseInt($2 , $1 ? 16:10));
    });
};

//函数.获取接口返回的文本数据
function getzsml(url, postdata, fun){
	var sendtext = "";
	var xhttp = new XMLHttpRequest;
	xhttp.open("POST",url,fun?true:false);
	xhttp.setRequestHeader("Content-Type", "application/zsml; charset=utf-8");
	if(postdata) {
		sendtext = "{datas:" + JSON.stringify(postdata) + "}";
	}
	try{
		if(fun) {
			xhttp.onreadystatechange = function(){
				if (xhttp.readyState==4){  fun(xhttp.responseText); }
			}
			xhttp.send(sendtext)
		}else {
			xhttp.send(sendtext);
			return xhttp.responseText;
		}
	}catch(e){return "网络请求异常";}
}
//函数.获取接口返回的对象
function getzsmlobj(url, postdata) {
	var data = getzsml(url, postdata);
	if(data.indexOf("header")>0 && data.indexOf("}")>0) {
		return eval("(" + data + ")");
	} else {
		return {header:{status:1,message:data}};
	}
}

//函数.微信API接口调用前注册
function initWeiXinApiConfig(){
	if(window.hasInvokWeiXinApiConfig==true) { return true; }; //保证一个页面只注册
	var obj = getzsmlobj(
		window.virpath + "home.asp?__msgId=getJsSdkTicket",
		[
			{"id":"openid", "val": localStorage.openID},
		    {"id":"url", "val": window.location.href}
		]
	);
	if(obj.header.status==0){
		if(obj.body.message.text.indexOf("fail")==-1) {
			wxcnfg( eval("(" + obj.body.message.data + ")") );
			window.hasInvokWeiXinApiConfig = true;
			return true;
		}
	}
	alert("调用微信功能失败，异常描述：" + (obj.header.status==0? obj.body.message.data : obj.header.message) );
	return false
}

//函数.调用微信二维码扫一扫功能.
function  wx_ScanQRCode( callBackfun ) {
	 if(window.onScanQrCodeing==true) { return false; }  //正在调用
	 window.onScanQrCodeing=true;
	 if(initWeiXinApiConfig()==false) { window.onScanQrCodeing = false; return false; }  //调用之前先注册接口
	 var fn = function(){
		 wx.scanQRCode({
			needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
			scanType: ["qrCode"], // 可以指定扫二维码还是一维码，默认二者都有
			success: function (res) {
				callBackfun(res.resultStr);
				window.onScanQrCodeing = false;

			 },error:function(a, b, c){
				alert("扫描失败：" + c);
				window.onScanQrCodeing = false;
			 }
		});
	}
	window.iswxload?fn():setTimeout(fn,1000);
}

//函数.调用微信语言功能
function wx_StartRecord( callBackfun ) {
	function getTime(){
		var t = 0;
		var timer = setInterval(getT,1000);
		function getT(){
			t++;
			try{
				if(t>=7){ 
					clearInterval(timer); t = 0; 
					$("body .voiceDiv").remove();
					$("#voiceBgDiv").remove();
					return; 
				}
				$(".timeP").text('00:00:0'+t);
			}catch(e){}
		}
	}
	if(window.onStartRecording==true) { return false; }  //正在调用
	window.onStartRecording=true;
	if(initWeiXinApiConfig()==false) { window.onStartRecording = false; return false; }  //调用之前先注册接口
	$("body").append('<div id="voiceBgDiv" style="position:fixed;top:0px;left:0px;width:100%;height:100%;background:rgba(0,0,0,0.1);z-index:1000000"></div><div class="voiceDiv" style="position:fixed;z-index:999995;left:33%;top:210px;text-align:center;background:rgba(0,0,0,.5);padding-top:10px;width: 120px;height:120px;border-radius: 10px;color: #fff;">'+
						'<img src="' + window.htmlvirpath + 'img/hua.png" style="width:40px;"/>'+
						'<p style="color: #f1f1f1;padding-top: 10px;">正在录音...</p>'+
						'<p style="color: #f1f1f1" class="timeP" >00:00:00</p>'+
					'</div>');
	getTime();
	//打开语音录入窗口
	var voice = {localId: '', serverId: ''};
	var fn = function(){
		wx.startRecord({
			complete: function () {
				setTimeout(function () {
					//停止录音
					//关闭语音录入窗口
					wx.stopRecord({
						success: function (res) {
							voice.localId = res.localId;
							wx.translateVoice({
								localId: voice.localId, // 需要识别的音频的本地Id，由录音相关接口获得
								isShowProgressTips: 1, // 默认为1，显示进度提示
								success: function (res) {
									if (res.hasOwnProperty('translateResult')) {
										var result = res.translateResult.toString().replace(/[\?|？|\.|。|\,|，|\!|！| ]/g,"");
										callBackfun(result, true);
									}
								}
							});
						},
						fail: function (res) { 
							callBackfun(res, false); 
						}
					});
					$("body .voiceDiv").remove();
					$("#voiceBgDiv").remove();
				},5000)
			},
			cancel: function () { 
				callBackfun("", false);
			}
		});
	}
	window.iswxload?fn():setTimeout(fn,1000);
}

//函数.购物车的数字
window.getCarNumFirstRun = 0
function getCarNum(){
	var carNumObj = $(".carNum");
	if(carNumObj[0].innerHTML!="0" || window.getCarNumFirstRun!=0){  //判断是否是第一次执行，防止打开购物车数字晃一下的问题
		carNumObj.animate({zoom:"1.5", width:"2.4rem",  height:"2.4rem", lineHeight:"2.4rem", paddingTop:"0.1rem", top:"-0.8rem", right:"1.2rem"},200);
	}
	window.getCarNumFirstRun = 1;
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url: window.virpath + "ShopCars.asp?__msgId=getCarItemCount&timev=" + (new Date()).getTime(),
		dataType:"text",
		contentType:"application/zsml",
		async:true,
		success:function(data){
			data = eval("("+data+")");
			if(data.body.message){
				var j = data.body.message.text;
				j>99?j=99+'+':j=j;
				carNumObj.text(j);
				if(j==0){
					carNumObj.hide();
				}else{
					carNumObj.show();
					carNumObj.animate({zoom:1,  width:"1.7rem", height:"1.7rem", lineHeight:"1.7rem", paddingTop:"0rem", top:"0rem", right:"2.0rem"},200);
				}
			}
		},
		error:function(){
			carNumObj.animate({zoom:1},200)
		}
	});
}

//函数.加入购物车
function addShopToCar(id, imgsrcobj, num1) {
	try{
		var carNumObj = $(".carNum"); //按钮图标
		var carNumDomObj = carNumObj[0];
		var pos = imgsrcobj.getBoundingClientRect();
		var pos2 = carNumDomObj.parentNode.getBoundingClientRect();
		var img = document.createElement("img");
		img.src = imgsrcobj.src;
		if(pos.width==0) {  
			//可能是隐藏状态
			var w = document.body.offsetWidth?document.body.offsetWidth:document.body.clientWidth;
			pos = {width:parseInt(w*0.65),height:parseInt(w*0.65),left:parseInt(w*0.17),top:parseInt(w*0.3)};
		}
		var wpx = (pos.width<pos.height?pos.height:pos.width);
		if(wpx<150) { wpx = 150;}
		pos.left = pos.left + (pos.width - wpx)/2;
		pos.top = pos.top + (pos.height - wpx)/2;
		var x1 = (pos2.left+(pos2.width/2) - pos.left-wpx*0.5);
		var y1 = (pos2.top+(pos2.height/2) - pos.top-wpx*0.5);
		img.style.cssText = "z-index:10000000;position:absolute;left:" + pos.left + "px;top:" + pos.top+ "px;width:" + wpx + "px;height:" + wpx + "px;" +
							"-webkit-transform:translate3d(0px,0px,0px) scale(0.6);-webkit-transition:-webkit-transform 0.8s;border-radius:" + wpx + "px";
		document.body.appendChild(img);
		//商品图片加入动画
		setTimeout(function(){
			img.style.webkitTransform = "translate3d(" +  parseInt(x1) + "px," + parseInt(y1) + "px,0px) scale(0.001) rotate(180deg)";
			setTimeout(function(){ document.body.removeChild(img); },900);
		},10);
		//购物车数字变化动画
		setTimeout(function(){
			var currnum = carNumDomObj.innerHTML;
			if(currnum.indexOf("+")==-1) {
				var newnum = currnum*1 + (num1?num1*1:1);
				if(newnum>99) { newnum = "99+"; }
				carNumDomObj.innerHTML=newnum;
				carNumObj.show();
			}
			carNumDomObj.style.webkitTransform = "-webkit-transform:scale(1)";
			carNumDomObj.style.webkitTransition = "-webkit-transform 0.2s,background-color 0.2s,-webkit-box-shadow 0.2s";
			setTimeout(function(){
				carNumDomObj.style.webkitTransform = "translate3d(0px,-8px,0px) scale(1.3) rotate(5deg)";
				carNumDomObj.style.webkitBoxShadow = "0px 0px 4px #550000";
				carNumDomObj.style.backgroundColor = "#aa2000";
			},10);
			setTimeout(function(){
				carNumDomObj.style.webkitTransform = "scale(1)";
				carNumDomObj.style.backgroundColor = "#f15352";
				carNumDomObj.style.webkitBoxShadow = "";
			},350);
		},400);
		//将实际数据提交请求到服务器端
		if(window.willAddShopCarHwnd>0) { clearTimeout(window.willAddShopCarHwnd); }
		if(!window.willaddShopCarList) {
			window.willaddShopCarList = [[id],[num1]];
		} else {
			var hs = false;
			for (var i = 0; i < window.willaddShopCarList.length ; i++)
			{
				if(window.willaddShopCarList[0][i]==id) {
					window.willaddShopCarList[1][i]=window.willaddShopCarList[1][i]*1+num1*1;
					hs = true;
					break;
				}
			}
			if(hs==false) {
				window.willaddShopCarList[0][window.willaddShopCarList[0].length] = id;
				window.willaddShopCarList[1][window.willaddShopCarList[1].length] = num1;
			}
		}
		window.willAddShopCarHwnd = setTimeout(function(){
			window.willAddShopCarHwnd = 0;
			var listid  = window.willaddShopCarList[0].join("_");
			var listnum = window.willaddShopCarList[1].join("_");
			var sendData = "{datas:[{id:'openid',val:'"+localStorage.openID+"'},{id:'id',val:'" + listid + "'},{id:'num',val:'"+ listnum + "'}]}";
			window.willaddShopCarList = null;
			$.ajax({
				type:"post",
				data: sendData,
				url: window.virpath + "ShopCars.asp?__msgId=addToCars",   
				dataType:"text",
				contentType:"application/zsml",
				async:true,
				success:function(data){ 
						var obj = eval("(" + data + ")");
						if(data && data.header && data.header.status!=0) {
							alert("加入购物车失败：" + data.header.message);
						}
					}
				}
			);
		},400); 
	} catch(e){
		alert(e.message);
	}
	/*
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}" + (num1?",{id:'num',val:'"+num1+"'}":"") + "]}";
	$.ajax({
		type:"post",
		data:datas,
		url: window.virpath + "ShopCars.asp?__msgId=addToCars&id="+id,   
		dataType:"text",
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			if(data.body.message.text == "success"){
				var _data = data.body.message.data;
				var srcpl = "../../../../Edit/upimages/shop/"+srcdata;
				var img = $("div.chooseImgWrap>img").attr("src");
				srcpl = img ? img : srcpl;
				$("#intoCarTig").css("background","url("+srcpl+") no-repeat center center")
				.css("background-size","100% 100%")
				.show().animate({"top":"95%","left":"8%","width":"1px","height":"1px"},700,function(){
					$(this).css({"top":"30%","left":"50%","width":"80px","height":"80px"}).hide();
					setTimeout("getCarNum();",10);
				})
			}else{
				alert(eval("("+data.body.message.data+")").msg);
			}
		}
	});*/
}

//初始过程.获取相对路径
window.virpath = window.location.href.toLowerCase().indexOf("/app/html/")>0?"../../":"../";  /* asp接口的相对路径*/
window.htmlvirpath = window.location.href.toLowerCase().indexOf("/app/html/")>0?"../":"";    /* html页面相对路径 */

//初始过程.微信身份验证
(function(){
	var lccode = localStorage["code"];
	var code = GetQueryString("code");
	//code = "01162baec3d1d6ba64782c5f2b178ddx";
	//lccode = "01162baec3d1d6ba64782c5f2b178ddx"
	if(code) { 
		localStorage["code"] = code; 
	} else {
		code = localStorage["code"];
	}
	if(code==null || code=="" || code.length<16) {
		//微信环境信息不正确
		var div = document.createElement("div");
		document.body.appendChild(div);
		div.style.cssText = "text-align:center;color:red;position:fixed;z-index:100000000;left:0px;top:0px;width:100%;height:100%;background-color:#fff;";
		div.innerHTML  = "<br><br><br><br><br><img src='" + window.htmlvirpath + "img/sml.png'><br><br>温馨提示：环境不正确。<br><br>请您在微信客户端中打开链接。";
		document.close();
		return;
	}
	if(lccode!=code) {
		var obj = getzsmlobj(window.virpath + "home.asp?__msgId=regUser&code="+code);
		if(obj.body.message.data) {
			localStorage["openID"] = obj.body.message.data;
		} else {
			//当前用户微信号信息不正确
			var div = document.createElement("div");
			document.body.appendChild(div);
			div.style.cssText = "text-align:center;color:red;position:fixed;z-index:100000000;left:0px;top:0px;width:100%;height:100%;background-color:#fff;";
			div.innerHTML  = "<br><br><br><br><br><img src='" + window.htmlvirpath + "img/sml.png'><br><br>温馨提示：无法获取您的微信号。<br><br>请您在微信客户端中打开链接。";
			document.close();
			return;
		}
	}
})();

//初始过程.错误统一提醒
window.onerror = function(sMessage,sUrl,sLine){
	//alert( "/MicroMsg/mobile" + sUrl.toLowerCase().split("micromsg/mobile")[1] +" 第" + sLine + "行\n\n" + sMessage);
}

/*
//此段代码用于控制按钮关闭时友好提示，目前貌似没有权限，后期再研究
var BindCloseEventTick = 0;
function BindCloseEvent() {
	if((typeof WeixinJSBridge == "undefined") || !WeixinJSBridge.invoke) {
		BindCloseEventTick = BindCloseEventTick + 1;
		if(BindCloseEventTick>30) {return;}
		setTimeout("BindCloseEvent();",500);
		return;
	}
	initWeiXinApiConfig();
	WeixinJSBridge.invoke("setCloseWindowConfirmDialogInfo",{"switch":"true",title_cn:"你要关闭购物页面?",title_eng:"Do not save the order info? ",ok_cn:"关闭",ok_eng:"OK",cancel_cn:"再逛逛",cancel_eng:"Cancel"},function(res){
		alert(res.err_msg+ "===" + res.err_desc );
	})
}*/

//初始过程.顶部过程绑定
$(function(){
	$("#back").unbind().bind("click",function(){
		history.back();
	})
	//禁止页面缓存
	$("head").append('<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">');
	//回到顶部
	$("#top,#totop").unbind().bind("click",function(){
		$("html,body,.goodsList").animate({scrollTop:0},500);  
	})
	//setTimeout("BindCloseEvent();",500); 此段代码用于控制按钮关闭时友好提示，目前貌似没有权限，后期再研究
})

//微信加载状态标记
wx.ready( function(){ window.iswxload = true; } );