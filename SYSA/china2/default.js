window.onmousedownHandle = function() {
	if(parent!=window)
	{
		if(document.all) { parent.document.fireEvent("onmousedown"); }
		else{
			var evt = parent.document.createEvent("MouseEvents");
            evt.initEvent("mousedown", true, true);
			try { parent.document.dispatchEvent(evt) } catch (e) {};
		}
	}
	if(window.currPopMenu)
	{window.currPopMenu.style.display = "none";}
}
if(document.attachEvent) { document.attachEvent("onmousedown",window.onmousedownHandle);}
else{document.addEventListener("mousedown",window.onmousedownHandle,false);}
if(0==0 )
{
	var doc = top.document;
	var div = doc.getElementById("frameProcDiv");
	if(!div && doc.body) {
		var div = doc.createElement("Div");
		div.id = "frameProcDiv";
		div.style.cssText = "position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:500;";
		div.innerHTML = "<table style='width:100%;height:100%' border=1><tr><td align=cenetr style='text-align:center'><div style='text-align:center;color:#000'>系统正在加载中,请稍后...<br><img src='../../../SYSA/skin/default/images/procimg.gif'><br><br><br><br><br></div></td></tr></table>"
		doc.body.appendChild(div);
	}
}
function getCookie(name){//得到cookie中的值
    var cookiename = name +"=";
    var dc =document.cookie;
    var begin, end;
    if (dc.length>0){
        begin = dc.indexOf(cookiename);
        if (begin!=-1){
            begin+= cookiename.length;
            end = dc.indexOf(";",begin);
            if (end==-1){
                end=dc.length;
            }
            return unescape(dc.substring(begin,end));
        }
    }
    return null;
} 

function setCookie(name,value,expires){//获取cookie中的值
    document.cookie = escape(name)+"="+escape(value)+";path=/"+((expires==null)?"":";expires=" +expires.toGMTString());
}

function deleteCookie(name){//删除cookie中的值
    document.cookie=name+"=; expires=Thu, 01-Jan-70 00:00:01 GMT"+";path=/";
}

function closeproc(){
	/*
	disToHomePage==true表示是否刷新左侧导航后不需要刷新首页，默认需要刷新；
	例如：积分设置等变更后需要刷新左侧导航但是需要有刷新首页
	*/
	if(top.disToHomePage==true) {
		top.disToHomePage = false;
		return;
	}
    var loginpage="firstname" + window.curruserid;
    var loginstr = getCookie(loginpage);
    if(div){ div.style.display = "none";}
}

function writeFrameSrc(url) {
    url=url.replace("http://","");
    if(url.lastIndexOf('/')>0){
        var urlpage=url.substring(url.indexOf('/')+1,url.length);
        var exp =new Date();
        exp.setTime(exp.getTime()+(60*60*60*24*31));
        var loginpage="firstname" + window.curruserid;
        deleteCookie(loginpage);
        setCookie(loginpage,urlpage,exp);
    }
}

//binary.IE11JS刷新高度
function pageload() {
	var mainwin = document.getElementById("mainFrame");
	if(!mainwin) {return;}
	if(parent.onmainFrameLoad) {
		var h = parent.onmainFrameLoad() + "";
		if (h.indexOf("%") == -1 && h.indexOf("px") == -1) { h = h + "px"; }
		mainwin.style.height = h;
	}
	//改写模式对话框，防止线程卡住导致账号异常
	if(window.showModalDialog) {
		var win = mainwin.contentWindow;
		if(!win.old_showModalDialog){
			win.old_showModalDialog = win.showModalDialog;
			win.showModalDialog = function(p1, p2, p3) {
				var result;
				showModalDialogBegin();
				result = win.old_showModalDialog(p1, p2, p3);
				showModalDialogEnd();
				return result;
			}
		}
	}
	if(top.body_resize) {top.body_resize();}
	handleSpliterBar();
}

function spbarmouseup() {
    if (window.top.SysConfig && window.top.SysConfig.SystemType==3) { return; }
	$ID("mleftbody").style.width = ($ID("borderFramediv").style.left.replace("px", "") * 1) + "px";
   window.leftPageSplitMovePosX = null;
   $("#borderFramediv").css("opacity","0");
   $ID("borderFramedivbg").style.display = "none";
   $ID("spliterimg").style.left = $ID("mleftbody").style.width; 
   window.leftmoveing = 0;
};

window.leftmoveing = 0;
function handleSpliterBar() {
    return;
	var spbar = $ID("borderFramediv");
	var spbarbg = $ID("borderFrame");
	var smbar = $ID("spliterimg");
	var h = $ID("frame-body").offsetHeight;
	var rc = spbarbg.getBoundingClientRect();
	spbar.style.cssText = "position:absolute;left:" + rc.left + "px;top:" + rc.top + "px;height:" + h + "px";
	smbar.style.left = spbar.style.left;
	$(spbar).css("opacity","0");
	$(spbar).unbind("mousedown",handleSpliterEvent).bind("mousedown", handleSpliterEvent);
	setTimeout(ywtest,1);
}

function handleSpliterEvent(ev) {
	var spbar = window.event.srcElement;
	$(spbar).css("opacity","0.3");
	$ID("borderFramedivbg").style.display = "block";
	window.leftPageSplitMovePosX = [ev.clientX, ev.offsetX];
	app.beginMoveElement(ev.target, function ( mvevt) {
		window.leftmoveing = 1;
		mvevt = mvevt || window.event;
		if(window.leftPageSplitMovePosX==null) { window.leftPageSplitMovePosX = [mvevt.clientX, mvevt.offsetX]; }
		$ID("borderFramediv").style.left = (mvevt.clientX - window.leftPageSplitMovePosX[1]) + "px";
	}, spbarmouseup);
	$(document).unbind("mouseup",spbarmouseup).bind("mouseup",spbarmouseup);
}

function ywtest() {
    return;
	if(window.leftmoveing==1) {return;}
	var spbar = $ID("borderFramediv");
	var smbar = $ID("spliterimg");
	spbar.style.left = $ID("mleftbody").style.width;
	smbar.style.left = spbar.style.left;
}

function showModalDialogBegin(){
	var xhttp = new (XMLHttpRequest?XMLHttpRequest:ActiveXObject)("Msxml2.XMLHTTP");
	xhttp.open("get","../getsession.asp?cmd=startHang&t=" + (new Date()).getTime(),false); //挂起账号
	xhttp.send();
	xhttp = null;
}

function showModalDialogEnd(){
	var xhttp = new (XMLHttpRequest?XMLHttpRequest:ActiveXObject)("Msxml2.XMLHTTP");
	xhttp.open("get","../getsession.asp?cmd=stopHang&t=" + (new Date()).getTime(),true); //停止挂起账号
	xhttp.send();
	xhttp = null;
}

function pageload2(){
	try{
	var cmtxt = top.document.getElementById("Manu_Cont_Manu");
	if(cmtxt) {
		top.document.body.removeChild(cmtxt);
	}}catch(e){}
}

window.setChildMenuFrame = function(show, title,  treehtml) {
	try{
		var borderfrm = document.getElementById("borderFrame");
		if(top.BindSecondIFrameRefresh && borderfrm.style.width=="206px"){ setTimeout(function(){ top.BindSecondIFrameRefresh = null; },800); return; }
		borderfrm.style.width = (show==1?"206px":"6px");
		var frm = document.getElementById("spliter");
		frm.className = "childremenu" + show;
		var cobj = (frm.contentWindow||frm);
		cobj.ShowChildrenMenu((title||""),treehtml);
		if (title == "生成凭证") {
		    //关闭默认打开父级的菜单
		    cobj.$(".ty_1_e1").click();
		    cobj.$(".ty_2_e1").click();

            //打开全部父级菜单
		    cobj.$(".ty_1_e0").click();
		    cobj.$(".ty_2_e0").click();

            //打开第一个叶子菜单
		    cobj.$("div.tvw_n_txt a").not("[value='']")[0].click();
		}
	}catch(e){}
}

function toggleMenu(){
	var smbar = $ID("spliterimg");
	var spbar = $ID("borderFramediv");
	var frmBody = document.getElementById('frame-body');
	var leftmenu = frmBody.rows[0].cells[0];
	if (leftmenu.offsetWidth==0)
	{
		var l = window.currselleft ? (window.currselleft + "px") : "209px";
		leftmenu.style.width = l;
		spbar.style.left = l;
		smbar.style.left = l;
		smbar.src="../skin/default/images/btn_left.gif";
	}
	else
	{
		window.currselleft = leftmenu.offsetWidth;
		leftmenu.style.width = "0px";
		spbar.style.left = "0px";
		smbar.style.left = "0px";
		smbar.src="../skin/default/images/btn_right.gif";
	}
}

window.IE11BugPackS =  true;
window.onBodyResize = function(){
	if(window.IE11BugPackS==true) {
		var h = document.documentElement.offsetHeight;
		var wh = $ID("leftFrame").offsetHeight;
		if(wh==0) { return; }
		if(wh > 30 && Math.abs(h-wh)>20) {  //防止IE11下出故障
			$ID("leftFrame").style.height = parseInt(h*1-31) + "px";
			$ID("mainFrame").style.height = parseInt(h*1-31) + "px";
		} else {
			window.IE11BugPackS = false;
		}
	}
}
$(window).bind("resize", window.onBodyResize);
$(window.onBodyResize);
