function urlto(url ,target)
{	
	var w = screen.availWidth;
	var h = screen.availHeight;
	var t = new Date();
	var turl = url.indexOf("?")>0 ? url + "&tmvalue=" + t.getTime() : url + "?tmvalue=" + t.getTime();
	var att = target.replace(/\,/g,"|").split("|") ;
	if(!att[1] || isNaN(att[1])) { att[1] =  parseInt(screen.availWidth*0.9); }
	if(!att[2] || isNaN(att[2])) { att[2] =  parseInt(screen.availHeight*0.88); }
	if(!att[3] || isNaN(att[3])) { att[3] =  1; }
	var w = att[1], h = att[2] , rsize = att[3];
	var l = parseInt((screen.availWidth-w)*0.5);
	var t = parseInt((screen.availHeight-h)*0.35);
	switch(att[0]){
		case "href":	//普通open
			window.open(url);
			break;
		case "open":	//弹出窗口
			window.open(url,"","width=" + v + ",height=" + h + ",left=" + l + ",top=" + t + ",resizable=" + rsize + ",menubar=0,status=0" );
			break;
		case "dlg":		//对话窗口
			window.showModalDialog(turl, window, "dialogLeft:" + l + "px;dialogTop:" + t + ";dialogWidth:" + w + "px;dialogHeight:" + h + "px;status:0;resizable:" + rsize + ";");
			break;
		case "frame":	//大模式窗口-可缩放
			
			break;
		default:
			window.open(url);
	}
}

//设置激励语
function setStimulusWords()
{
	var div = app.createWindow("StimulusWords","自我激励语设置","","","",400,200,0,1,"white");
	if(div.children.length==0)
	{
		ajax.regEvent("setStimulusWords")
		div.innerHTML = ajax.send();
	}
}

//保存激励语
function saveStimulusWords(){
	var newword = document.getElementById("StimulusWordsBox").value;
	if(newword.length>=100)
	{
		alert("激励语不能超过100字");
		return;
	}
	ajax.regEvent("saveStimulusWords")
	ajax.addParam("word" , newword)
	r = ajax.send();
	if (r.length > 0) {alert(r); return;}
	document.getElementById("UserStWords").innerHTML = newword;
	app.closeWindow("StimulusWords");
}
//我的导航分类界面切换
function VisibleaddMenuClsPenel(v)
{
	if(v==true){
		document.getElementById("addMenuClsPanel").style.display="inline";
		document.getElementById("addMenuClsPanel_s").style.display="none";
	}
	else{
		document.getElementById("addMenuClsPanel").style.display="none";
		document.getElementById("addMenuClsPanel_s").style.display="inline";
	}
}
//保存我的导航分类
function addMenuClsSave()
{
    var txt = trim(document.getElementById("MenuClsText").value);
    if (txt == "") {
        //alert("目录名称不能为空");
        document.getElementById("tit_3").style.display = '';
        return;
    }
	ajax.regEvent("form:addMyMenuCls");
	ajax.addParam("clsName",txt);
	ajax.send(
	function (r) {
		if(isNaN(r)==false)
		{		
			if(r>0) 
			{
				var clsbox = document.getElementById("Amm_MenuCls");
				var opt = document.createElement("option");
				opt.value = r;
				opt.innerText = txt;
				opt.text = txt;
				try{
					clsbox.options.appendChild(opt);
				}catch(e){
					clsbox.options.add(opt);
					
				}
				clsbox.selectedIndex = clsbox.options.length-1;
			}
			else{
				alert("您要添加的目录已经存在。")
			}
		}
		else{
			alert(r);
		}
	});
}
//保存我的导航明细
function myMenuSave(mord) {
    if (trim(document.getElementById("mymenutit").value) == "") {
        //alert("名称不能为空");
        document.getElementById('tit_4').style.display = '';
        document.getElementById("mymenutit").value = trim(document.getElementById("mymenutit").value);
        return;
    }
	if(document.getElementById("Amm_MenuCls").value*1<=0){
		alert("请选择目录");
		return;
	}
	ajax.regEvent("form:addMyMenu");  //此处采用表单方式模拟ajax提交
	ajax.addParam("mtit",document.getElementById("mymenutit").value);
	ajax.addParam("mcls",document.getElementById("Amm_MenuCls").value);
	ajax.addParam("murl",document.getElementById("mymenuurldata").value);
	ajax.addParam("mord",mord);
	ajax.send(
		function(r){
			if(r==1)
			{
				app.closeWindow("addmymen");
				try{window.frames[0].frames[0].onMyMenuUpdate();}catch(e){}
			}
			else{
				alert(r);	
			}
		}
	);
}
//打开连接
function GoURL(url , type) {
	switch(type){
		case "0":
			$ID("frmbody").contentWindow.document.getElementById("mainFrame").contentWindow.location.href = url;  //框架
			break;
		case "1":
			var w = parseInt(screen.availWidth*0.96)
			var h = parseInt(screen.availHeight*0.94)
			var t = parseInt(screen.availHeight*0.02)
			var l = parseInt(screen.availWidth*0.02)
			window.open(url,"","resizable=1,width=" + w + "px,height=" + h + "px,top=" + t + "px,left=" + l + "px, scrollbars=1" );	//js
			break;
		case "3":
			window.open(url);	//超链接
			break;
		default:
			var url = url;
			var isAbsoluteUrl = url.toLowerCase().indexOf("http://")>=0;//是否是绝对地址
			var isRemoteUrl = isAbsoluteUrl && url.toLowerCase().indexOf(window.location.host.toLowerCase())<0;//地址是否不是来自本站点
			if (!isRemoteUrl){
				$ID("frmbody").contentWindow.document.getElementById("mainFrame").contentWindow.location.href = url;//框架
			}else{
				window.open(url); //超链接
			}
	}
}

//菜单点击事件
window.onMenuItemClick = function(id,srcElement) {
	if(id=="topmenu")
	{
		var vArray =  srcElement.getAttribute("value").split("??");
		if(vArray[0].length > 0)
		{
			 GoURL(vArray[0],vArray[1])
		}
	}
}

//工具栏点击事件
window.ontoolbarclick = function(evTag){
	if(evTag.id=="topbar") //顶部工具栏导航
	{
		var v = evTag.value.split("??");
		 GoURL(v[1],v[0]);
	}
}


function showMoreSearch(a) {
	var vs = a.getAttribute("value").split("#$");
	var m = new ContextMenuClass();
	m.id ="srtypes";
	m.onitemclick = function(li){
		var bar = document.getElementById("srcitem2");
		if(!bar) {bar = document.getElementById("srcitem1");}
		if(!bar) {bar = document.getElementById("srcitem0");}
		if(!bar) {return false;}
		var rvalue = bar.innerHTML + "|" + bar.getAttribute("value");
		var ntext =  li.getAttribute("text");
		bar.setAttribute("value",li.getAttribute("value"));
		bar.innerHTML = ntext;
		var s = a.getAttribute("value").split("#$");
		for (var i=s.length-1;i>=0 ; i-- )
		{
			if(s[i].indexOf(ntext + "|")==0) {
				s.splice(i,1);
				break;
			}
		}
		s[s.length] = rvalue;
		a.setAttribute("value",s.join("#$"));
		srTypeChane(bar);
	}
	for(var i = 1 ; i< vs.length ;i++)
	{
		var item = vs[i].split("|");
		var txt = item[0];
		item.splice(0,1)
		m.menus.add(txt,item.join("|"),window.sysskin + "/images/ico16/cl2.gif");
	}
	m.show();
	m.BindElement(a,-108,a.offsetHeight+2); //绑定在bn旁边显示
}


function srTypeChane(a)
{
	for (var i = 0; i < 3 ; i++ )
	{
		var na = document.getElementById("srcitem" + i);
		if(!na) {break;}
		if(na.id != a.id) {
			na.className = na.className.replace("_sel","")
		}
		else{
			if(na.className.indexOf("_sel")<0) {
				na.className = na.className + "_sel";
			}
		}
	}
	
	window.currsearchCls =  a.innerHTML;
	var v = a.getAttribute("value");
	while (v.indexOf("||")>=0)
	{
		v = v.replace("||","|");
	}
	
	if(v.indexOf("|")==0) {v = ("%%x%" + v).replace("%%x%|","");}
	var v = v.split("|");
	var txts = v;
	if (window.currsearchCls=="客户")
	{
		txts = document.getElementById("currsrfield2").getAttribute("value").split("|");
	}
	if(v[0]=="自定义*"){
		ajax.regEvent("GetSearchDefFields","SearchDef.asp");
		ajax.addParam("cls",window.currsearchCls);
		var r = ajax.send();
		v[0] = r.split("|")[0];
		r = v[0].split("?def$");
		var txt = r[0];
		document.getElementById("currsrfield").innerHTML = txt;
		document.getElementById("currsrfield").title = txt.length>5 ? txt : "";
		document.getElementById("currsrfield").setAttribute("dbname",r[1]);
	}
	else{
		var txt = txts[0];
		document.getElementById("currsrfield").innerHTML = txt;
		document.getElementById("currsrfield").title = txt.length>5 ? txt : "";
		document.getElementById("currsrfield").setAttribute("dbname",v[0]);
	}
	if (app.IeVer>6)
	{	//IE下该代码在初次加载的时界面小的情况下会引起错乱
		document.getElementById("searchKeyText").focus();
		document.getElementById("searchKeyText").select();
	}
	document.getElementById("currsrfield").setAttribute("value",v.join("|"));
}


function showsrfields(bn){
	var sv = document.getElementById("currsrfield").getAttribute("value");
	if(!sv)
	{
		//没有启用任何检索栏的情况下，直接退出。
		return false;
	} 
	if(sv.indexOf("自定义*")>=0)
	{
		ajax.regEvent("GetSearchDefFields","SearchDef.asp");
		ajax.addParam("cls",window.currsearchCls);
		sv = sv.replace("自定义*",ajax.send());
	}

	var v = sv.split("|");
	var currv = document.getElementById("currsrfield").outerHTML;
	var m = new ContextMenuClass();
	m.id ="srfields";
	m.onitemclick = function(li){
		var txt = li.getAttribute("text");
		document.getElementById("currsrfield").innerHTML = txt;
		document.getElementById("currsrfield").title = txt.length>5 ? txt : "";
		document.getElementById("currsrfield").setAttribute("dbname",li.getAttribute("value"));
		document.getElementById("searchKeyText").focus();
		document.getElementById("searchKeyText").select();
	}	
	
	var txts = v;
	if (window.currsearchCls=="客户")
	{
		txts = document.getElementById("currsrfield2").getAttribute("value").split("|");
	}
	for(var i =0 ; i< v.length ;i++)
	{
		if(v[i].length > 0 && v[i]!=currv) {
			var r = v[i];
			if(r.indexOf("?def$")>0)
			{
				r = r.split("?def$")
				m.menus.add(r[0],r[1],"");
			}
			else{
			
				m.menus.add(txts[i],v[i],"");
			}
		}
	}
	m.show();
	m.BindElement(bn, -100 ,bn.offsetHeight+2); //绑定在bn旁边显示
}

function sKeyText_onkeydow(v){
	if(window.event.keyCode==13 || v==1) {
		var k = document.getElementById("currsrfield").getAttribute("dbname");
		if(!k){if(!window.currsearchCls){return;}}
        if(k.length==0){alert("无法进行检索",window.currsearchCls + "栏目下没有设置可检索的字段"); return false;}
		document.getElementById("s_cls1").value = window.currsearchCls;
		document.getElementById("s_fld1").value = k;
		document.getElementById("s_fname1").value = document.getElementById("currsrfield").innerText;
		document.getElementById("s_key1").value = document.getElementById("searchKeyText").value;
		document.getElementById("s_form").submit();
		return false;
	}
}

function doExit(){
	if(window.confirm("您确定要退出吗？"))
	{
		if(top.saveMenuHistory)
		{
			try{top.saveMenuHistory();}catch(e){}
		}
		return true;
	}
	else
	{window.returnValue=false;return false;}
}


function goHome(){
	try{
		$ID('frmbody').contentWindow.document.getElementsByTagName("iframe")[0].contentWindow.cMenuPag(0);
	}
	catch(e){}
	$ID('frmbody').contentWindow.document.getElementsByTagName("iframe")[2].contentWindow.location.href = "main.asp";
}

//初始化短消息提醒
var oldPropmResponeText = "";
function ResultPromp(ResponeText)
{
	if(ResponeText)
	{
		var tagFrame=window.location.href.toLowerCase().indexOf("/china2/top")<0?"I1":"mainFrame"
		if(window.disPrompValue==true){return;}
		if(oldPropmResponeText==ResponeText)
		{
			window.setTimeout("InitPromp()",window.propmTimer);
			return; 
		}
		else
		{
			oldPropmResponeText = ResponeText;
		}
		try{
			var o = eval("var x=" + ResponeText + ";x");
		}catch(e){return;}
		var dat = o.data;
		if(o.sound==1){
			app.playMedia("../images/security.wav");
			var sound_check = 'checked';
		}
		var new_check = '';
		if(o.new1==6){
			 new_check = '【最新】';
		}
		var allnum = 0;
		var sw = (parent.document.body).clientWidth;//document.documentElement.offsetWidth;
		var sh = (parent.document.body).clientHeight;//document.documentElement.offsetHeight-22;
		var htm = "<table align=center style='width:240px;'><tr>"; 
		var hs = false;
		for (var i = 0; i < dat.length ; i ++ )
		{
			hs = false;
			if(dat[i][0]=="allnum")
			{
				allnum = dat[i][1];
			}
			else{
			    htm = htm + "<td style='padding-left:5px;width:auto;color:#5b7cae;line-height:20px'>" + dat[i][0] + "(<a href='" + dat[i][2] + "' target='" + tagFrame + "' style='color:red;cursor:pointer;font-weight:bold;' onmouseout='app.unline(this,0)' onmouseover='app.unline(this,1)'>" + dat[i][1] + "</a>) </td>";
			}
			if (i%2==1 && i > 0)
			{
				hs = true;
				htm = htm + "</tr><tr>";
			}
		}
		if(hs==false){ htm = htm + "</tr>";}
		htm = htm + "</table>"
		if(allnum*1 > 0) 
		{
			var div = app.createWindow("propmDiv","<span style='font-size:12px;position:relative;top:1px;width:350px;'>" + new_check + "您有(<a target='" + tagFrame + "' href='../china/topalt.asp'  onclick='showallPropm()' style='text-decoration:underline;color:red;cursor:pointer'>" + allnum + "</a>)条消息</span>","../skin/" + window.sysskin  + "/images/ico16/alt1.gif",parseInt((sw - 280)), parseInt((sh-208)),280,180,0,0,"#E3E7F0");
			div.innerHTML = "<div style='position:absolute;top:0px;height:90px;overflow:auto;background-color:#f5f8Fd;cursor:default;overflow-x:hidden;width:242px;'>" + htm + "</div>" + 
							"<div style='height:20px;overflow:hidden;line-height:14px;position:absolute;top:90px;'>"+
								"<input onclick='disPromp()' style='position:relative;top:2px' class='radio' type=checkbox id='yxsdsd'>"+
								"<label style='position:relative;color:#545454'>今日不再提醒</label>"+
								"<span style='position:relative;left:26px;'>"+
									"<input onclick='sound_open()' style='position:relative;top:2px;color:#E5E5E5' class='radio' type=checkbox id='yxsdsd2' " + sound_check + ">" +
									"<label style='color:#545454'>声音提醒</label>"+
									"<a href='../setjm/set_jm.asp' target='" + tagFrame + "' style='position:relative;left:16px;'>设置</a>"+
								"</span>"+
							"</div>";
		}
		if(window.disPrompValue==false) { window.setTimeout("InitPromp()",window.propmTimer);}
		
	}
}


function InitPromp(){
	var t = new Date();
	var r = Math.round(Math.random() * 100);
	var s = document.getElementById("allowPop").value;
    if (s==1){
	    ajax.regEvent("","../china/cu.asp?timestamp=" + t.getTime() + "&date1=" + r + "&ver=new");
	    ajax.send(ResultPromp);
    }
}

function showallPropm(){
	app.closeWindow("propmDiv");
}

function alt_SetDisPromp() {//--设置今日不再提醒session
	var url = "../inc/ReminderDisPromp.asp?act=SetDisPromp&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send(null);  
}

function alt_GettDisPromp() {//--获取今日不再提醒session
	var DisPromp;
	var url = "../inc/ReminderDisPromp.asp?act=GetDisPromp&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		if(xmlHttp.readyState == 4)
		{
			DisPromp = xmlHttp.responseText;
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);
	return DisPromp;
}

window.disPrompValue = false;
function disPromp(){//禁止今日提醒
	window.disPrompValue = true;
	alt_SetDisPromp();
	app.closeWindow("propmDiv");
}

function showDatePanel() //显示日历
{
	var div = app.createWindow("szczxcdate","系统日历",'','','',560,455,'',1,'#E3E7F0')
	div.style.overflow = "hidden";
	div.innerHTML = "<iframe style='width:100%;height:100%' scrolling='no' src='' frameborder='0'></iframe>";
	div.children[0].src = "../ATools/wnl/index.htm";
}

function autosizeframe(){
	if(window.tmp00124){window.clearTimeout(window.tmp00124)};
	window.tmp00124 = setTimeout(function(){
	try{
		var bodydiv = $ID("bodydiv");
		var h1 = document.body.offsetHeight;
		var h2 = $ID("buttomdiv").offsetHeight;
		var h3 = $ID("topdiv").offsetHeight;
		var h4 = $ID("frmbody");
		bodydiv.style.height = (h1-h2-(h3==0?6:h3)) + "px";
		h4.style.height = bodydiv.style.height;
	} catch(e){
		alert(e)
	}},10
	);
}

//创建电话组件
function initphonectl(){
	var url = window.location.href
	var si  = url.toLowerCase().indexOf("china2/topsy.asp")
	url = url.substr(0,si-1)
	ajax.regEvent("getObjectHTML", "../ocx/ctlevent.asp?date1="+ Math.round(Math.random()*100));
	ajax.send(
		function(html){
			if(html.length>0){
				var div = document.createElement("div");
				div.style.cssText = "position:absolute;left:1px;height:1px;top:1px;width:1px;background-color:white";
				document.body.appendChild(div);
				html = html.replace("#defserverurl",url);
				div.innerHTML = html;
				try{
					if(!document.getElementById("PhoneCtl").version){
						//alert("加载组件失败，可能需要降低浏览器安全设置，然后启动浏览器。")
						var setupdiv = app.createWindow("setupsss","下载组件安装程序",'','','',600,400,'',1,'#E3E7F0')
						setupdiv.innerHTML = "<iframe src='../ocx/setup.asp' frameborder=0 style='width:560px;height:320px'></iframe>"
					}
					else{
						var txt = "<span style='color:#007700;font-size:12px;font-family:宋体;position:relative;top:4px;left:2px;line-height:15px'>电话录音组件启动正常。<br>" 
								 + "组件版本:<span style='color:red'>" + document.getElementById("PhoneCtl").version + "</span></span>"
						document.getElementById("PhoneCtl").showtext(txt)
					}
				}catch(e){
					//alert("加载组件失败，可能需要降低浏览器安全设置，然后启动浏览器。")
					var setupdiv = app.createWindow("setupsss","下载组件安装程序",'','','',600,400,'',1,'#E3E7F0')
					setupdiv.innerHTML = "<iframe src='../ocx/setup.asp' frameborder=0 style='width:560px;height:320px'></iframe>"
				}
			}
		}	
	);
}

function InitPage()	//页面初始化是
{
	var ax = new window.XmlHttp();
	ax.regEvent("InitWork");
	ax.send(
		function(r)
		{
			if(r!="ok")
			{
				var div = app.createWindow("initalert","系统加载警告",'','','',480,300,'','')
				var d = document.createElement("div");
				try {d.innerHTML =  r;} catch (e){}
				div.innerHTML = "<div style='color:red;padding:10px;line-height:22px;'>在加载相关业务过程出现警告或错误<br><b><a class='fun' href='javascript:void(0)' onclick='return app.swpVisible(\"initerrorpanel\")'>点击</a></b>查看详情。<div style='height:5px;overflow:hidden'></div>"
							  + "<div style='display:none;color:blue;padding:4px;border:1px dashed #ccccdd;background-color:white' id='initerrorpanel'>" + d.innerText + "</div></div>";
			}
		}
	);
}

function onload(){ //topsy.asp加载
	try{if(window.addPhone==1){initphonectl();};}catch(e){}
	window.setTimeout("InitPage()",100);//初始系统加载项，例如库存备份等...
	try{window.disPrompValue = (alt_GettDisPromp() == "True") ? true : false;}catch(e){}
	window.setTimeout("InitPromp()",1000);//初始化提示
	try{initUserTimeoutTest(); }catch(e){}  //初始化默认退出时间设置功能
	window.setTimeout("getSession()", 1000);
}

function initUserTimeoutTest() {  //初始化默认退出时间设置功能
    UserTimeout = UserTimeout * 1; //类型转化
    if (UserTimeout <= 0) { return; }
    window.UserTimeoutI = parseInt(UserTimeout * 60 / 10);  //设置的超时时间的十分之1作为定时间隔时间，如果定时间隔时间超过1.5分钟，这设置为1.5分钟，小于5s则，为5s
    if (window.UserTimeoutI < 6) { window.UserTimeoutI = 5; }
    if (window.UserTimeoutI > 90) { window.UserTimeoutI = 90; }
    setTimeout("UserTimeoutTest()", window.UserTimeoutI*1000);
}

window.utHttp = new window.XmlHttp();
window.userTimeoutState = 0
function UserTimeoutTest() { //提交超时验证请求
    var t = new Date();
    var ax = utHttp;
    ax.regEvent("", "UserTimeoutTest.asp?tt=" + t.getTime());
    ax.addParam("maxv", UserTimeout*60);
    ax.send(function (r) {
        //top.document.title = r;  //调试语句，检测超时状态，建议勿删
        if (r == "1") {  //超时了
            window.userTimeoutState = 1
            getSession(1); //启动原有的超时检测代码。
        }
        else {
            setTimeout("UserTimeoutTest()", window.UserTimeoutI*1000);
        }
    });
}

window.LoginDialogOk = function () {
    setTimeout("UserTimeoutTest()", window.UserTimeoutI * 1000);
    getSession();
}

//首页logo改变，IE6模式下处理png
function logoicochange(logo) {
    if (app.IeVer == 6) {
        if (window.event.propertyName == "src" && logo.getAttribute("changeSrc") != 1) {
            logo.setAttribute("changeSrc", 1);
            if (logo.src.indexOf(".png") > 0) {
                logo.setAttribute("changeSrc", 1);
                var url = logo.src;
                logo.src = window.sysskin + "/images/s.gif";
                logo.style.cssText = "width:" + logo.offsetWidth + "px;height:" + logo.offsetHeight + ";filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale,src=" + url + "')";
                logo.outerHTML = logo.outerHTML;
            }
            logo.setAttribute("changeSrc", 0);  //bug#247
        }
    }
}

function sound_open(){
  //开启关闭声音
  var url = "cu_sound.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  };
  xmlHttp.send(null); 
  xmlHttp.abort();
}

try { document.onmousedown = datedlg.autohide; } catch(e){} //#bug301
/*仓库选择js结束*/

function check_length(id, tid) {
    if (document.getElementById(id).value.length >= 49)
        document.getElementById(tid).style.display = '';
    else
        try {
            document.getElementById(tid).style.display = 'none';
            document.getElementById("tit_4").style.display = 'none';
            document.getElementById("tit_3").style.display = 'none';
        } catch (e) { }

}
function trim(val) {
    var str = val + ""; if (str.length == 0) return str;
    return str.replace(/^\s*/, '').replace(/\s*$/, '');
}

function homeGoNext() {
	try
	{
		var frm = document.getElementById("frmbody").contentWindow.document.getElementById("mainFrame").contentWindow;
		frm.history.go(1);
	}
	catch (e){}
}

function homeGoBack() {
	try
	{
		var frm = document.getElementById("frmbody").contentWindow.document.getElementById("mainFrame").contentWindow;
		//currlinkTime和FirstlinkTime防止点击后退按钮直接退出 ， 关联main.asp 134 行代码
		if(window.currlinkTime && window.FirstlinkTime) {
			if(window.currlinkTime==window.FirstlinkTime) {
				if(frm.location.href.indexOf("china2/main.asp")>0) {
					return ;
				}
			}
		}
		frm.history.go(-1);
	}
	catch (e){}
}

//设置桌面快捷方式
function toDesktop(n) {
	var url = window.location.href.split("?")[0].toLowerCase();
	url = url.replace("/china2/topsy.asp","")
	if (n.length == 0) {
		alert("缺少必要的参数!");
	} else {
		try {
			var wsh = new ActiveXObject("WScript.Shell");
			var fso = new ActiveXObject("Scripting.FileSystemObject");
			var f = fso.CreateTextFile(wsh.SpecialFolders("desktop").replace(/\\/g, "\\\\") + "\\" + n + ".url", true);
			f.writeline("[{000214A0-0000-0000-C000-000000000046}]");
			f.writeline("Prop3=19,2");
			f.writeline("[InternetShortcut]");
			f.writeline("URL=" + url + "/index2.asp");
			f.writeline("IDList=");
			f.writeline("IconFile=" + url + "/favicon.ico");
			f.writeline("IconIndex=0");
			f.close();
			var f = null;
			var fso = null;
			var wsh = null;
			app.Alert('快捷方式创建成功！');
		} catch (e) {
			app.Alert('当前IE安全级别不允许操作！请按以下设置后重试.\nIE设置步骤：\nInternet选项》安全》自定义级别》对未标记为可安全执行的脚本 ActiveX控件初始化并执行脚本\n设置为：启用');
		}
	}
}

function fwAttr() {
	var w = screen.width;
	var h = (window.screen.availHeight<window.screen.height ? screen.availHeight : screen.height);
	var s =  'left=' + parseInt(w*0.07) + ',top=' + parseInt((h-55)*0.05) + ',width=' + parseInt(w*0.86) + ',height=' + parseInt((h-55)*0.9) + ',resizable=yes'
	return s;
}

window.onunload = function() {
	if(event.clientX<0 || event.clientY<0) {
		ajax.url = "../inc/logout.asp?tryloginout=1&data=" + (new Date()).getTime()
		ajax.regEvent("", ajax.url);
		ajax.send();
	}
}

function formconfig(){
	var div = app.createWindow("userconfig","UI设置","null","null","null",400,200,0,1,"#e3e7f0");
	div.style.cssText = "cursor:default;border:1px solid #ccc;width:359px;height:125px;background-color:#f2f2f2";
	var zm = document.body.getAttribute("uizoom");
	if(zm=="") {zm=1;}
	div.innerHTML = "<div style='margin:20px;margin-left:30px;color:#000;cursor:default;font-size:12px;'>界面缩放：" +
					"<input  type='radio'name='uiformzoom' onclick='formconfigc(this.value)' value='1' " + (zm==1?"checked":"") + " id='uif1'><label for='uif1'>原始</label>&nbsp;&nbsp;"  +
					"<input type='radio' name='uiformzoom' onclick='formconfigc(this.value)' value='1.13' " + (zm==1.13?"checked":"") + " id='uif2'><label for='uif2'>中</label>&nbsp;&nbsp;"  +
					"<input type='radio' name='uiformzoom' onclick='formconfigc(this.value)' value='1.3' " + (zm==1.3?"checked":"") + " id='uif3'><label for='uif3'>大</label></div>"  +
					"<center><input type=button value='&nbsp;&nbsp;关闭&nbsp;&nbsp;' onclick='app.closeWindow(\"userconfig\")' class='button'></center>";
}

function formconfigc(v) {
	window.location.href = "?zoom=" + v;
}

function zoomfBox(box){
	var v = ((box.getAttribute("value") + "") == "0");
	box.src = window.sysskin + "/images/hometop/" + (v ? "allp_s.png": "allp.png");
	box.title = v ? "点击界面还原" : "点击界面全屏";
	box.setAttribute("value", v?"1":"0");
	if(v) {
		 $ID("logoBox").style.display = "none";
		 $ID("topmenuarea").style.display = "none";
		 $ID("topbararea").style.display = "none";
		 $ID("topdiv").style.display = "none";
		 $ID("bodydiv").style.top = "6px";
		 if(window.CHiddenLeftMenu){window.CHiddenLeftMenu();}
	}else{
		 $ID("logoBox").style.display = "block";
		 $ID("topmenuarea").style.display = "block";
		 $ID("topbararea").style.display = "block";
		 $ID("topdiv").style.display = "block";
		 $ID("bodydiv").style.top = "";
		 if(window.CShowLeftMenu){window.CShowLeftMenu();}
	}
	body_resize();
}

window.showHelp = function(ord) { 
	if(!window.virpath) {window.virpath="../"}
	app.showHelp(ord); 
}


window.CostAnalysis = {};
window.CostAnalysis.ShowMainAnalysisDlg = function () {

}

window.CostAnalysis.ShowSmpAnalysisLayer = function () {

}