//注意，调试模式下不会加载此页面
var hWnds = new WinManager();
hWnds.Windows.Add(window);
window.ActiveTime=(new Date()).getTime();

var RootOBJ = window;
window.onfocus=function()
{
	hWnds.Recycle();
	var t=new Date();
	window.ActiveTime=t.getTime()
};

if (window.addEventListener) {
    window.addEventListener('beforeunload', BeforeUnload, false);
} else if (window.attachEvent){
    window.attachEvent('onbeforeunload', BeforeUnload);
}
else{
	window.onunload = BeforeUnload;
}

function BeforeUnload()
{
	if(hWnds.HasOpenWindow()) {
		window.event.returnValue="还有弹出窗口未关闭，关闭本页面可能导致一些其它问题"
	}
	else{
		var h = false;
		try { 
			var buttons = window.frames[0].frames["mainFrame"].document.getElementsByTagName("input");
		}
		catch(e){return}
		for (var i=0 ; i< buttons.length ; i++)
		{
			var bn = buttons[i];
			if(bn.type=="button" || bn.type=="submit")
			{
				if(bn.value.indexOf("保存")>=0 || bn.value.indexOf("提交")>=0 || bn.value.indexOf("增加")>=0)
				{ 
					h = true;
					break; 
				}
			}
		}
		if(h==false){
			var buttons = window.frames[0].frames["mainFrame"].document.getElementsByTagName("button");
			for (var i=0 ; i< buttons.length ; i++)
			{
				var bn = buttons[i];
				if(bn.value.indexOf("保存")>=0 || bn.value.indexOf("提交")>=0 || bn.value.indexOf("增加")>=0)
				{ 
					h = true;
					break; 
				}
			}
		}
		if( h == true ) {window.event.returnValue = "提示您：当前页面可能存在需要保存的信息";}
	}
}
;


function WinManager()
{
	var me=new Object();
	me.CurrentDialog=null;
	me.Windows=new Array();
	//向数组中添加窗口对象，新开窗口时调用
	me.Windows.Add = function(w)
	{
		me.Windows[me.Windows.length]=new hWnd(w);
		return me.Windows[me.Windows.length-1];
	};

	//查找当前激活的窗口对象
	me.FindActiveWindow = function()
	{
		var maxDate=0;
		var maxI=-1;
		for(var i=0;i<me.Windows.length;i++)
		{
			try
			{
				if(me.Windows[i].obj.document.body&&me.Windows[i].obj.ActiveTime>maxDate)
				{
					maxDate=me.Windows[i].obj.ActiveTime;
					maxI=i;
				}
			}
			catch(e1)
			{
				continue;
			}
		}
		return maxI==-1?null:me.Windows[maxI];
	};

	me.DisableWindow = function()
	{
		for(var i=0;i<me.Windows.length;i++)
		{
			try
			{
				me.Windows[i].obj.DisableWindow();
			}
			catch(e1){}
		}
	};

	me.EnableWindow = function() 
	{
		for(var i=0;i<me.Windows.length;i++)
		{
			try
			{
				me.Windows[i].obj.EnableWindow();
			}
			catch(e1){}
		}
	};

	me.CloseWindow  = function()
	{
		for(var i=1;i<me.Windows.length;i++)
		{
			try
			{
				if(me.Windows[i].obj.opener!=window)
				{
					me.Windows[i].obj.document.body.onunload=function(){return true;};
				}
				me.Windows[i].obj.opener=null;
				me.Windows[i].obj.open('','_self');
				me.Windows[i].obj.close();
			}
			catch(e1){}
		}
	}

	//检测窗口列表中是否还有除了本窗口外仍然开着的子窗口
	me.HasOpenWindow = function()
	{
		for(var i=0;i<me.Windows.length;i++)
		{
			try
			{
				if(me.Windows[i].obj.document.body&&me.Windows[i].obj!=window)
				{
					return true;
				}
			}
			catch(e1)
			{
				continue;
			}
		} 
		return false;
	};

	//从数组中移除掉已经关掉的窗口对象
	me.Recycle = function()
	{
		var i=0
		while(i<me.Windows.length)
		{
			try
			{
				if(me.Windows[i].obj.document.body)
				{
					i++;
					continue;
				}
			}
			catch(e1)
			{
				me.Windows.splice(i,1);
			}
		}
	}
	return me;
}

//窗口对象
function hWnd(w)
{
	var me=new Object();
	me.obj=w?w:null;
	return me;
}

var xmlHttp = false;
try
{
	xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
}
catch(e)
{
	try
	{
		xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	catch(e2)
	{
		xmlHttp = false;
	}
}
if(!xmlHttp && typeof XMLHttpRequest != 'undefined')
{
	xmlHttp = new XMLHttpRequest();
}
window.sessionTimeroutId = 0; //用来判断定时器是否超时
window.sessionTimeroutAlert = true;
function OnSessionTimerout()
{
	//当session超时事件
	xmlHttp.abort();
	window.clearTimeout(window.sessionTimeroutId);
	setTimeout("getSession()", 1000);
	//top.document.title =  "out了";
	if(window.sessionTimeroutAlert && false) 
	{
		var div = document.getElementById("sTimeroutAlertDiv");
		if (!div)
		{
			div = document.createElement("div");
			document.body.appendChild(div);
			div.id = "sTimeroutAlertDiv";
			div.style.cssText = "overflow:hidden;display:none;position:absolute;right:2px;width:240px;border:1px solid #aaa;height:100px;z-index:1000000;background-color:white;";
			div.innerHTML = "<div style='background-color:#f0f0f0;color:#000;padding-left:3px;height:18px;overflow:hidden'></div><div style='padding:5px;padding-left:8px;padding-right:8px;'><span style='color:red'>&nbsp;&nbsp;系统与服务器会话过程出现中断，请检查您的网络状况是否良好。</span></div><div style='height:5px;'></div><div style='float:right'><button onclick='document.getElementById(\"sTimeroutAlertDiv\").style.display=\"none\";' class='button' style='height:18px;line-height:16px;color:#888'>关闭</button>&nbsp;</div><div style='color:#aaaaaa'>&nbsp;<input  type='checkbox' style='position:relative;top:3px;' onclick='window.sessionTimeroutAlert=!this.checked'>知道了，不再提示</div>";
		}
		div.style.top = (document.body.offsetHeight - 110) + "px";
		div.style.display = "block";
	}
}

window.getSessionUrlTick = 1;
function getSession(tout) {
    if (window.userTimeoutState == 1 && tout!=1) {return false;}   //用户超时检测能中断其它用户登录检测
	window.getSessionUrlTick ++;
    var url = "";
	if(window.getSessionUrlTick%2==1) {  
		//奇数次请求ASP.Net页面，维护.Net的Session会话。
		url =  window.virpath  + "SYSN/view/init/keeper.ashx?stamp=" + (new Date()).getTime();
	}else{
		//偶数次请求ASP页面，维护ASP的Session会话。
		url =  window.virpath  + "SYSA/getsession.asp?ac=g&stamp=" + (new Date()).getTime() + "&date1=" + Math.round(Math.random() * 100);
	}
	xmlHttp.onreadystatechange = function () {}
    xmlHttp.open("GET", url, true);
    xmlHttp.onreadystatechange = function () {
        if (xmlHttp.readyState == 4) {
			window.clearTimeout(window.sessionTimeroutId);
            var response = xmlHttp.responseText;
			if(response.indexOf("{result:")>=0) 
			{
				var res = eval("(" + response + ")");
				showasynerror(res);
				if(res.result == "0") {
					response  = "0"
				} else {
					if (res.result == "1") {
						response = "ok=" + res.userid + "=" + res.usercount;
						if (res.userid > 0 && (res.userid + "") != top.UserUniqueID) {
							if (!window.SysConfig || window.SysConfig.IsDebugModel!=true) {
								response = "-8";
							}
						}
					} else {
						response = res.result;
					}
				}
			}

			xmlHttp.abort();
			//top.document.title =  response + "=a=" + (new Date()).getTime();
			if(response.indexOf("ok=")>=0) {
				var item = response.split("=");
				var obj = document.getElementById("onlinenumber");
				if(obj) {
					obj.innerHTML = item[2];
				}
				response = item[1];
			}
            if (isNaN(response)) {
				var div = document.createElement("div")
				div.innerHTML = response;
				response = div.innerText;
				div = null;
                if(app) {
					app.Alert("程序错误：" + response);
				}else{
					alert("程序错误：" + response);
				}
				response = "0"
            }
			 if (response=="") {
                OnSessionTimerout();
                return;
            }
            var res = parseInt(response);
            if (res > 0) {
				if(document.getElementById("sTimeroutAlertDiv")) 
				{
					document.getElementById("sTimeroutAlertDiv").style.display = "none";
				}
                hWnds.EnableWindow();
                if (window.userTimeoutState == 1) {
                    window.userTimeoutState = 0
                    if (LoginDialogOk) { window.LoginDialogOk(); }
                }
                setTimeout("getSession()", 8000);
            }
            else {
                hWnds.DisableWindow();
                var curwin = hWnds.FindActiveWindow();
                setTimeout(DialogFun(res, curwin), 500);
            }

        }
    };
	//top.document.title =  "定时";
	window.sessionTimeroutId = setTimeout("OnSessionTimerout()",20000);
    xmlHttp.send(null);
	
}

var asynerrormx = "";
function showasynerror(res) {
	if (!res.error) { return; }
	asynerrormx = "<hr>" + res.error + "<hr>" + asynerrormx;
	var div = app.createWindow("asynerrordlg", "异常消息", "", (document.body.offsetWidth - 400), (document.body.offsetHeight - 200), 360, 160, 0, 0);
	div.innerHTML = "<div style='color:red;padding:25px 20px;background-color:#ffffaa'  >系统运行过程中有异常信息，<a onclick='showasynerrormx()' href='javascript:void(0)' style=color:blue >点击可查看详情</a>，如有疑问，请联系智邦国际。</div>";
}

function showasynerrormx() {
	var win = window.open("about:blank");
	win.document.write('<title>异常详情</title><meta http-equiv="Content-Type" content="text/html;charset=UTF-8">');
	win.document.write('<div style="font-size:13px;font-family:arial"><h2 style=color:red >异常信息详情</h2>' + asynerrormx + '<div>');
}

function DialogFun(r,curwin, OpenJmg)
{
	return function()
	{
		curwin.obj.focus();
		curwin.obj.LoginDialog(r);
		if(OpenJmg) {
			setTimeout("CheckJmgOnline(NT120Client,jmgpwd)",6000);
		} 
	}
}

function LoginDialog(r)
{
	var t = new Date();
	window.reloginSign = 0;
	var rtnvalue = null;
	if(window.ActiveXObject)
	{
		//出错意味着被弹出窗体程序禁止
		try{
			rtnvalue = window.showModalDialog(window.virpath + "SYSN/view/init/relogin.ashx?sver=" + window.SysConfig.ProductVersion + "&dlg=" + t.getTime() + "&res=" + r + "&unique=" + UserUniqueID + "&sid=" + UserUniqueSID, window, "status:no;help:no;scroll:no;dialogWidth:600px;dialogHeight:428px");
		}catch(ex){
			showreloginDivWindow(r);
			return;
		}
	}
	else{
		showreloginDivWindow(r);
		return;
	}
	if (!rtnvalue) {
	    if (window.reloginSign == 0 && window.confirm("注意：系统检测到未能成功加载超时登陆页面。\n\n点击“确定”尝试重新登陆，点击“取消”退出系统。\n\n确定要重新登陆吗？")) {
	        return LoginDialog(r);
	    }
	    RootOBJ.hWnds.CloseWindow();
	    RootOBJ.hWnds.Windows[0].obj.detachEvent("onbeforeunload", RootOBJ.hWnds.Windows[0].obj.BeforeUnload);
	    RootOBJ.hWnds.Windows[0].obj.location = window.virpath + "SYSA/index2.asp";
	}
	else {
	    //修改的切入点
	    hWnds.EnableWindow();
	    if (window.LoginDialogOk && window.userTimeoutState == 1) {
            window.userTimeoutState = 0
	        window.LoginDialogOk();
	    }
        setTimeout("getSession()", 1000);
    }
}

window.OnreloadOk = function(){
	//div模式重新登陆成功
	var div = document.getElementById("__sys_rlg_win");
	if(div) {
		div.style.display = "none"
	}
	 hWnds.EnableWindow();
	if (window.LoginDialogOk && window.userTimeoutState == 1) {
		window.userTimeoutState = 0
		window.LoginDialogOk();
	}
	setTimeout("getSession()", 5000);
}

function showreloginDivWindow(r) {
	try{window.focus();}catch(e){}
	var t = new Date();
	var div = document.getElementById("__sys_rlg_win");
	if(!div) {
		var div = document.createElement("div");
		div.id = "__sys_rlg_win";
		document.body.appendChild(div);
		div.style.cssText = "width:604px;box-shadow:0 0 12px #666;border-radius:2px;display:none;position:absolute;z-index:100000;border:1px solid #333;top:160px;padding:5px;padding-bottom:6px;background-color:#dcdded;overflow:hidden;";
	}
	div.style.left = parseInt((document.body.offsetWidth - 600) / 2) + "px";
	div.style.display = "block";
	div.innerHTML = "<div id='winTitle'><div style='float:right;padding-right:5px'><a href='login.ashx' style='color:red;'><b>直接退出系统</b></a></div>"
					+ "<div style='margin:2px 0px 4px 4px;font-weight:bold;color:#000'>重新登录</div></div>"
					+ "<iframe scrolling=no frameborder=0 style='border-radius:2px;border:1px solid #909aaa;display:block;width:480px;height:570px;margin:0px auto' src='" + window.virpath + "SYSN/view/init/relogin.ashx?sver=" + window.SysConfig.ProductVersion + "&dlg=" + t.getTime() + "&res=" + r + "&unique=" + UserUniqueID + "&sid=" + UserUniqueSID + "'></iframe>"
	if (window.top.UserInfo && window.top.UserInfo.Zoom) {
	    var div = $("#__sys_rlg_win")[0];
	    div ? div.style.zoom = (1 / window.top.UserInfo.Zoom + "") : "";
	}
}

setTimeout(function(){
//showreloginDivWindow();
},3000)


function DisableWindow()
{
	var dv=document.getElementById("wmg_disable_div");
	if(!dv)
	{
		dv=document.createElement("div");
		dv.style.cssText="display:none;position:absolute;top:0%;left:0%;width:100%;height:100%;background-color:#39457D;z-index:10000;-moz-opacity:0.3;opacity:.30;filter:alpha(opacity=30)";
		dv.id="wmg_disable_div";
		document.body.appendChild(dv);
	}
	if(dv.style.display!="block") dv.style.display="block";
}

function EnableWindow()
{
	var dv=document.getElementById("wmg_disable_div");
	if(dv&&dv.style.display!="none"){dv.style.display="none";}
}
