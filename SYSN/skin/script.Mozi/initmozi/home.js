var HomeObj = null;
window.PageInitParams = new Array();
window.setFinanceSign=true;
function createOldAttrs() {
    window.sysskin = "../../../SYSA/skin/default";
    window.sysConfig = { floatnumber: window.SysConfig.NumberBit, moneynumber: window.SysConfig.MoneyBit, hlnumber: window.SysConfig.RateBit, zkmumber: window.SysConfig.DiscountBit };
    window.virpath = "../../../";
    window.syssoftversion = window.sysConfig.ProductVersion;
    window.printlog = 0;
    window.currUserId = window.UserInfo.Id;
    window.uizoom = window.UserInfo.Zoom;
    if (window.onpageinit) { onpageinit(); }

}

function AddTopMenus(ms, ds) {
    for (var i = 0; i < ds.length; i++) {
        var item = ds[i];
        var nm = ms.add()
        nm.text = item.Text;
        var url = item.Url.replace("sys:", "") + "??" + item.Otype + "??" + item.Id;
        nm.value = url;
        if (item.NodesCount > 0) {
            AddTopMenus(nm.menus, item.Nodes);
        }
    }
}

var needlistresize = 0;
function listResize() {
    $ID("frmbody").style.height = $ID("bodydiv").offsetHeight + "px";
}
function body_resize() {
    if (document.body.offsetHeight > 300) { autosizeframe(); }
    listResize();
}

//binary.IE11JS刷新高度
window.onmainFrameLoad = function () {
    listResize();
    if (top.document.body.style.zoom && top.document.body.style.zoom > 1) {
        if (app.getIEVer() > 12) {
            return "100%";
        }
    }
    
    return $ID("bodydiv").offsetHeight?$ID("bodydiv").offsetHeight:'100%';
}
function TopScan(id, srcTag) {
    srcTag.value = "../store/planall7.asp?product_txm=" + srcTag.value + "??0??22"
    if (window.onMenuItemClick) {
        window.onMenuItemClick(id, srcTag);
    }
}

//创建页面
window.createPage = function () {
    if (window.UserInfo.Zoom && !isNaN(window.UserInfo.Zoom) && window.UserInfo.Zoom != 1) {
        document.body.style.zoom = window.UserInfo.Zoom;
    }
    createOldAttrs();
    HomeObj = window.PageInitParams[0];
    document.body.id = "homebody";
    window.propmTimer = HomeObj.PropmTimer;
    window.UserTimeout = HomeObj.UserTimeout;
    HomeObj.EWords = (HomeObj.EWords || "").replace(/\n/g, "").replace(/\r/g, "").replace(/\s/g, "&nbsp;");
    HomeObj.EWords = HomeObj.EWords || "未设置激励语";
    //此处编写渲染代码
    var dat = new Array();
    dat[0] = "<img  onpropertychange='logoicochange(this)' onclick='goHome()' src='" + HomeObj.LogoUrl + "' id='logoBox'/>\n"
    dat[1] = "<script>document.getElementById(\"logoBox\").src = \"" + (HomeObj.LogoUrl + "?t=" + (new Date()).getTime()) + "\";</script>\n"
    dat[16] = "<div id='topdiv'>\n"
    dat[17] = "  <div id=\"top\">\n"
    dat[20] = "    <div class=\"t-m-menu\">\n"
    dat[21] = "      <div class=\"t-m\">\n"
    dat[22] = "        <div class=\"link-right right\">\n"
    dat[23] = "		<a href=\"../china/tophome2.asp\"  target='mainFrame' class='VersionEnv'>"
    var html = new Array();//顶部导航跳转链接
    HomeObj.TopLinkBars = HomeObj.TopLinkBars ? HomeObj.TopLinkBars : [];
    var c = HomeObj.TopLinkBars.length;
    var hspop = false;
    for (var i = 0; i < c; i++) {
        var item = HomeObj.TopLinkBars[i];
        if (item.Url) {
            var u = item.Url.split("|");
            var canclick = false;
            if (u[0] == "") { u[0] = "javascript:void(0)"; }
            switch (u[0]) {
                case "../../../SYSA/china/tophome2.asp":
                case "../../../SYSA/china/topalt.asp":
                case "../../../SYSA/china/topadd.asp":
                case "../comm/RecycleBin.ashx": canclick = true; break;
            }
            u[1] = u[1] ? " onclick='" + u[1] + "' " : "";
            if (canclick) {
                if (u[1]) {
                    u[1] = u[1].replace("onclick='", "onclick='hideLeftNav();")
                } else {
                    u[1] = "onclick='hideLeftNav()'"
                }
            }
            var tgt = (u[1] == "onclick='hideLeftNav()'" ? " target=mainFrame " : "");
            if (item.Url.indexOf("homeseting") > 0 || u[0] == "../../../SYSA/china/topadd.asp") {
                tgt = " target=mainFrame ";
            } 
            var classname = "";
            if (item.Title == "提醒") { hspop = true; classname ="remind"}
            html.push("<a class='" + (classname ? classname : "") + "' style='_color:white' data-index='" + i + "' onmousedown='showList(this)' title='" + item.Title + "' href='" + u[0] + "' " + u[1] + tgt + "><span class='imgIco'><img src=\"@SYSA/skin/default/images/MoZihometop/topNav/" + item.Ico + "\" class=\"ico\" />" + (classname ? "<span class='newRemindIco'><img id='newReminds' class='hidden' src='@SYSA/skin/default/images/MoZihometop/topNav/red.png'></span>" : "") + "</span></a>");
        } else {
            var classname = "";
            if (i == c - 1) { classname = 'user' }
            switch (item.Title) {
                case "首页":
                    html.push("<a class='goHome' style='_color:white' title='" + item.Title + "' data-index='" + i + "' onmousedown='goHome()'><span class='imgIco'><img src=\"@SYSA/skin/default/images/MoZihometop/topNav/" + item.Ico + "\" class=\"ico\" /></span></a>")
                    break;
                case "界面大小":
                    html.push("<a class='setPageSize' style='_color:white' title='" + item.Title + "' data-index='" + i + "' onclick='formconfig();return false'><span class='imgIco'><img src=\"@SYSA/skin/default/images/MoZihometop/topNav/" + item.Ico + "\" class=\"ico\" /></span></a>")
                    break;
                default:
                    html.push("<a class='" + (classname ? classname : "") + "' style='_color:white' title='" + item.Title + "' data-index='" + i + "' onmousedown='showList(this)'><span class='imgIco'><img src=\"@SYSA/skin/default/images/MoZihometop/topNav/" + item.Ico + "\" class=\"ico\" />" + (classname ? "<span class='userName'>" + item.Title + "</span>" : "") + "<img class='pulldown' src='@SYSA/skin/default/images/MoZihometop/topNav/arrow.png'></span></a>");
            }
        }
    }
    try {
        var firstvalue = HomeObj.Searchs.length > 0 ? HomeObj.Searchs[0].concat().splice(1, 100).join("|") : "";

    } catch (e) { }
    html.push("<input type=\"hidden\" id=\"allowPop\"  value=\"" + (hspop ? 1 : 0) + "\" />");
    if (window.SysConfig.IsDebugModel == 1) {
        dat[23] += ("<div id='debugsignbar'onclick='app.Alert(\"客户第一，打造精品，我只是一个彩蛋！\");return false;'>调•试</div>");
        dat[23] += ("<div id='debughandle' onclick=\"window.open('" + window.SysConfig.VirPath + "SYSN/update/HistoryDataHandle_CostAnalysis.ashx', 'handlewindow', fwAttr());return false\" title='成本核算数据检测'>检•测</div>");
    }
    dat[23] += html.join("");
    dat[24] = "		</a></div>\n"
    dat[25] = "      </div>\n"
    dat[26] = "      <div class=\"t-s\">\n"
    dat[27] = "		\n"
    dat[28] = "	<div class=\"search-right\">"
    dat[29] = "" + (getTopSearchHtml() || "")
    dat[39] = "	</div>\n"
    dat[45] = "      </div>\n"
    dat[46] = "    </div>\n"
    dat[47] = "  </div>\n"
    dat[48] = "</div>\n"
    dat[49] = "<div id='bodydiv' style='z-index:100;' onscroll='this.scrollTop=\"0px\"'>\n"
    dat[50] = "  <iframe src=\"../../../SYSA/china2/default.aspx?cache=0\" onload='if(!window.xxfirstload){window.xxfirstload=1;onload()}' frameborder=\"0\" id=\"frmbody\" scrolling=\"no\"></iframe>\n"
    dat[51] = "</div>\n"
    dat[68] = "<input type='hidden' name='I1' id='I1'><!-- 兼容老代码对框架名称为I1的错误，防止报错 -->\n"
    dat[69] = "\n"
    dat[70] = "<form method=\"post\"  id=\"txmfrom\"  name=\"txmfrom\" style=\"width:0; height:0;border:0 0 0 0;margin: 0px;padding: 0px;\">\n"
    dat[71] = "	<input name=\"txm\" autocomplete=\"off\" type=\"text\" style=\" width:0px; height:0px; border:0;margin: 0px;padding: 0px;\" onkeypress=\"if(event.keyCode==13) {TopScan('topmenu',this);this.value='';unEnterDown();}\" onFocus=\"this.value=''\" size=\"10\">\n"
    dat[72] = "</form>\n"
    document.write(dat.join("").replace(/\@SYSA/g, window.SysConfig.VirPath + "SYSA"));
    if (window.UserInfo.Zoom && !isNaN(window.UserInfo.Zoom) && window.UserInfo.Zoom != 1) {//顶部最大缩放导致检索框与logo重叠
        if (window.screen.width <= 1366 && window.UserInfo.Zoom > 1.2) { $("#top .t-m-menu").css("zoom", "0.9") }
    }
    
    if (HomeObj.NeedShowGuidePage) {
        var h = document.documentElement.offsetHeight || 800;
        var div = app.createWindow("guiddlg", "系统启用及配置引导", '', '', parseInt(h * 0.05), 1100, parseInt(h * 0.90), '', 1, '#E3E7F0')
        div.style.overflow = "hidden";
        div.innerHTML = "<iframe style='width:100%;height:100%;background-color:white;border:1px solid #ccc' scrolling='yes' src='../../../SYSN/view/init/guide.ashx' frameborder='0'></iframe>";
    }
}

window.ShowAutoMeDlg = function (obj) {
    //var cs = HomeObj.CopyRightText.split("—");
    var verinfodiv = $ID("versioninfodlg");
    if (verinfodiv) { return; }
    verinfodiv = document.createElement("div");
    verinfodiv.id = "versioninfodlg";
    var bcss = app.getIEVer() < 9 ? "border-left:1px solid #ccc;border-right:1px solid #ccc;" : "";
    verinfodiv.style.cssText = bcss + "box-shadow: 0px 0px 6px #333355;position:absolute;width:500px;height:300px;bottom:0px;left:60px;background-color:white;display:block;z-index:1000000";
    verinfodiv.innerHTML = "<div style='height:120px;background-color:#313133;'>&nbsp;</div>"
	+ "<div style='position:absolute;left:24px;top:16px;font-size:15px;color:#fff;line-height:15px;'>版本</div>"
	+ "<div style='position:absolute;right:16px;top:16px;font-family:微软雅黑;font-size:18px;color:#fff;line-height:16px;cursor:pointer;' title='关闭'  onclick='$(\"#versioninfodlg\").remove()'>×</div>"
	+ "<div style='position:absolute;top:52px;font-size:21px;color:#fff;line-height:21px;text-align:center;width:100%;'>" + HomeObj.ProductVersionName + "</div>"
	+ "<table  style='position:absolute;top:150px;width:100%;'>"
	+ "<tr style='height:40px;background-color:#e3ebf8;font-weight:bold'><td>版本</td><td>当前版本</td><td>最新版本</td></tr>"
	+ "<tr style='height:5px;'><td></td></tr>"
	+ "<tr style='height:35px;'><td>PC版本</td><td>" + HomeObj.AppVersionDetails + "</td><td class='newver'><a href='javascript:void(0);'>" + (HomeObj.NewAppVersionDetails || "") + "<span class=jt2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></a></td></tr>"
	+ "<tr style='height:35px;'><td>移动版本</td><td>" + HomeObj.MobileAppVersion + "</td><td  class='newver'><a href='javascript:void(0);'>" + (HomeObj.NewMobileAppVersion || "") + "<span class=jt2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></a></td></tr>"
	+ "</table>"
    document.body.appendChild(verinfodiv);
}

window.setFinanceName = function (name, title) {
    if (window.PageInitParams && window.PageInitParams[0]) {
        window.PageInitParams[0].FinanceName = name;
        window.PageInitParams[0].FinancerangeTitle = title;
    };
}
//重新定位
function ShowFinaceYearList(box) {
    var div = $ID("FinaceYearList");
    if (!div) {
        div = document.createElement("div");
        div.id = "FinaceYearList";
        box.appendChild(div);
        div.onclick = function () { $("#FinaceYearList").remove(); $("#topShowList").css("display","none") }
    }
    div.style.display = "block";
    div.innerHTML = "<div id='FinaceYearListBody' onmousedown='app.stopDomEvent(event)'></div>"
    ajax.regEvent("GetFinaceYearList");
    var strs=ajax.send();
    var finacelist = eval("(" + (strs?strs:"[]") + ")");
    var html = "";
    for (var i = 0; i < finacelist.length; i++) {
        var fitem = finacelist[i];
        if (fitem.iscurryear == 1) {
            html = html + "<div title='" + fitem.year + "年' class='curr'>" + fitem.year + "年</div>";
        } else {
            html = html + "<div title='" + fitem.year + "年' onmousedown='' onclick='ChaneCurrFinaceYear(" + fitem.year + ")'>" + fitem.year + "年</div>";
        }
    }
    var listbody = document.getElementById("FinaceYearListBody");
    listbody.innerHTML = html;
    div.style.left = parseInt(box.offsetWidth) + "px";
}

//
function ChaneCurrFinaceYear(year) {
    if (!window.confirm("确定要切换会计年吗？")) { return; }
    ajax.regEvent("ChangeFinaceYear");
    ajax.addParam("CurrYear", year)
    var r = ajax.send() + "";
    if (r.indexOf("成功") == -1) {
        alert(r);
        return;
    }
    var fram = document.getElementById('frmbody');
    if (fram) {
        var box = fram.contentWindow.document.getElementById('mainFrame');
        box.contentWindow.location.reload();
    }
}

function hideLeftNav() {

    var fram = document.getElementById('frmbody');
    if (fram) {
        var box = fram.contentWindow.document.getElementById('borderFrame');
        if (box) { box.style.width = "1px" }
        var spliter = fram.contentWindow.document.getElementById("spliter");
        if (spliter) { $(spliter).addClass("childremenu0").removeClass("childremenu1"); }
    }
}

function showBetaBugPage() {
    window.open("http://2018.zbintel.com/SYSN/view/kfgl/addissue.ashx?basemsg=" + HomeObj.BetaBugKey, "asdasdasd", "width=860px, height=600px, left=200px, top=100px")
}

$(document).ready(function () {
    if (!window.XMLHttpRequest) {
        body_resize();
    }
    $(window).bind("resize", body_resize);
    $(document.body).bind("scroll", function () { window.scrollTo(0, 0) });
    $(document).click(function () {
        if ($ID("frmbody")) {
            var mask = $ID("frmbody").contentWindow.document.getElementById("navPanelMask");
            mask ? mask.style.display = "none" : "";
            if (!mask) { return; }
            var leftMune = $ID("frmbody").contentWindow.document.getElementById("leftFrame");
            if (!leftMune) { return; }
            var ulNav = leftMune ? leftMune.contentWindow.document.getElementById("muneMainNav") : "";
            if (leftMune && ulNav) { $(ulNav).find("ul.muneMainNav li.listActived").removeClass("listActived") } else { return;}
        }
    })
    $("#topdiv div.link-right a").mousedown(function () {
        app.stopDomEvent();
        $(this).addClass("actived").siblings().removeClass("actived");
    })
})

//页面顶部快速检索
function getTopSearchHtml() {
    var datas = HomeObj.Searchs;
	if(datas.length == 0){
		return '';
	}
	window.currsearchCls = datas[0][1];
    var strs = "";
    for (var i = 0; i < datas.length; i++) {
        strs += "#$" + datas[i].join("|");
    }
    var str = "<div class=\"topSearchForm\" id=\"topSearchForm\" style='" + (strs ? "" : "display:none") + "'>\n" +
            "	 <form action='@SYSA/china2/search.asp?utf8=1' method='post' style='display:inline' id='s_form' target='mainFrame'>\n" +
            "		<input type='hidden' name='s_cls' id='s_cls1'>\n" +
            "		<input type='hidden' name='s_fld' id='s_fld1'>\n" +
            "		<input type='hidden' name='s_key' id='s_key1'>\n" +
            "       <input type='hidden' name='s_fname' id='s_fname1'>\n" +
            "	 </form>\n" +
	        "    <input type=\"text\" id=\"topSearchText\" name=\"title\" required lay-verify=\"required\" placeholder=\"请输入关键字【回车】查询\" autocomplete=\"off\"\n" +
	        "      class=\"topSearchText\" onkeydown='sKeyText_onkeydow(1)'>\n" +
	        "    <div class=\"selectBox\" id=\"topSelectBox\" onmousedown='showMoreSearch(this)' value='" + strs + "'>\n" +
	        "      <input type=\"text\" readonly placeholder=\"请选择\" value=\"" + datas[0][1] + "\" dbname=" + (datas[0][1] ?datas[0][1]:"")+ " class=\"selectedSearchTitle\" id='selectedSearchTitle'>\n" +
	        "      <i class=\"arrow-edge\"></i>\n" +
            "      <i class='line'></i>"
            "    </div>" +
            "</div>"
            if (datas[0][0]) { window.currsearchCls = datas[0][0] }
    return str
}

//**********************原home.js函数================


function urlto(url, target) {
    var w = screen.availWidth;
    var h = screen.availHeight;
    var t = new Date();
    var turl = url.indexOf("?") > 0 ? url + "&tmvalue=" + t.getTime() : url + "?tmvalue=" + t.getTime();
    var att = target.replace(/\,/g, "|").split("|");
    if (!att[1] || isNaN(att[1])) { att[1] = parseInt(screen.availWidth * 0.9); }
    if (!att[2] || isNaN(att[2])) { att[2] = parseInt(screen.availHeight * 0.88); }
    if (!att[3] || isNaN(att[3])) { att[3] = 1; }
    var w = att[1], h = att[2], rsize = att[3];
    var l = parseInt((screen.availWidth - w) * 0.5);
    var t = parseInt((screen.availHeight - h) * 0.35);
    switch (att[0]) {
        case "href":	//普通open
            window.open(url);
            break;
        case "open":	//弹出窗口
            window.open(url, "", "width=" + v + ",height=" + h + ",left=" + l + ",top=" + t + ",resizable=" + rsize + ",menubar=0,status=0");
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


//打开连接
function GoURL(url, type) {
    if (url.toLowerCase().indexOf("sysn/") == -1 && url.toLowerCase().indexOf("http") != 0) {
        url = "../../SYSA/" + url.replace("../", "");
    } else {
        url = url.toLowerCase();
        if (url.indexOf("/sysn/") >= 0) {
            url = window.SysConfig.VirPath + "sysn/" + url.split("/sysn/")[1];
        }
    }
    if (type == "undefined") { type = 0; }
    url = url + (url.indexOf("?") >= 0 ? "&" : "?") + "FromHomeTopMenu=" + ((type || 0) * 1 + 1);
    switch (type) {
        case "0":
            $ID("frmbody").contentWindow.document.getElementById("mainFrame").contentWindow.location.href = url;  //框架
            break;
        case "1":
            var w = parseInt(screen.availWidth * 0.96)
            var h = parseInt(screen.availHeight * 0.94)
            var t = parseInt(screen.availHeight * 0.02)
            var l = parseInt(screen.availWidth * 0.02)
            window.open(url, "", "resizable=1,width=" + w + "px,height=" + h + "px,top=" + t + "px,left=" + l + "px, scrollbars=1");	//js
            break;
        case "3":
            window.open(url);	//超链接
            break;
        default:
            var url = url;
            var isAbsoluteUrl = url.toLowerCase().indexOf("http://") >= 0;//是否是绝对地址
            var isRemoteUrl = isAbsoluteUrl && url.toLowerCase().indexOf(window.location.host.toLowerCase()) < 0;//地址是否不是来自本站点
            if (!isRemoteUrl) {
                $ID("frmbody").contentWindow.document.getElementById("mainFrame").contentWindow.location.href = url;//框架
            } else {
                window.open(url); //超链接
            }
    }
}


//工具栏点击事件
window.ontoolbarclick = function (evTag) {
    if (evTag.id == "topbar") //顶部工具栏导航
    {
        var v = evTag.value.split("??");
        GoURL(v[1], v[0]);
    }
}

//顶部快速检索选择下拉框
function showMoreSearch(a) {
    if ($ID("topShowList")) { $ID("topShowList").style.display="none" }
    app.stopDomEvent();
    var vs = a.getAttribute("value").split("#$");
    var div = $ID("TopSearchSelectList");
    if (div && div.offsetHeight) { div.style.display = 'none'; return; }
    if (!div) {
        div = document.createElement("div");
        div.id = "TopSearchSelectList";
        div.onmousedown = function () { app.stopDomEvent(); }
        var html = ["<div class='billType list'><ul class='searchSelectUl'>"];
        var html2 = ["<div class='billTitle list'><ul class='searchSelectTitle'>"];
        var str = "";
        for (var i = 1; i < vs.length; i++) {
            var item = vs[i].split("|");
            var txt = item[0];
            item.splice(0, 1);
            str = "<li class='"+(i==1?"actived":"")+"' value='" + item.join("|") + "' onmousedown='changeSearchTitle(this)'>" + txt + "</li>";
            html.push(str)
            if (i == 1) { window.currsearchCls = txt; html2.push(SearchTitleHtml(item.join("|"))); };//改成点击变更，不加载
        }
        html.push("</ul></div>");
        html2.push("</ul></div>");
        div.innerHTML = html.join("") + html2.join("")+"<div class='list_arrow'></div>";
        document.body.appendChild(div);
    }
    $ID("topSearchForm") ? $("#topSearchForm").addClass("searched") : "";
    resetSearchListPos(a, div);
}
//顶部快速检索下拉框右侧html生成
function SearchTitleHtml(items) {
    if (!items) return false;
    var sv = items;
    if (sv.indexOf("自定义*") >= 0) {//获取自定义字段详细内容
        ajax.regEvent("GetSearchDefFields", window.virpath + "SYSA/china2/SearchDef.asp");
        ajax.addParam("cls", window.currsearchCls);
        sv = sv.replace("自定义*", ajax.send());
    }
    var v = sv.split("|");
    var str2 = "";
    for (var j = 0; j < v.length; j++) {
        var r = v[j];
        if (r) {
            if (r.indexOf("?def$") > 0) {
                r = r.split("?def$")
                str2 += "<li onmousedown='selectedSearchTitle(this)' value='" + r[1] + "'>" + r[0] + "</li>";
            }
            else {
                str2 += "<li onmousedown='selectedSearchTitle(this)' value='" + r + "'>" + r + "</li>";
            }
        }
    }
    return str2;
}
//顶部快速检索下拉框右侧细类渲染
function changeSearchTitle(a) {
    if (!a || a.innerHTML == window.currsearchCls) { return; }
    $(a).addClass("actived").siblings().removeClass("actived");
    var v = a.getAttribute("value");
    window.currsearchCls = a.innerHTML;
    var htm = SearchTitleHtml(v);
    $("#TopSearchSelectList ul.searchSelectTitle").html(htm);
}

//顶部检索项赋值
function selectedSearchTitle(a) {
    var v = a.innerHTML;
    var dbname = a.getAttribute("value");
    $(a).addClass("actived").siblings().removeClass("actived");
    $("#selectedSearchTitle").val(v);
    $("#selectedSearchTitle").attr("dbname", dbname);
    $ID("TopSearchSelectList").style.display='none';
    $("#topSearchForm").removeClass("searched")
}

/*
**@a   操作的dom对象;
**@div 弹层对象
**@d   弹层相对操作dom的对齐方向,默认左对齐,true右对齐 
*/
function resetSearchListPos(a, div,d) {
    if (!a) { return; }
    var pos = a.getBoundingClientRect();
    if (!div) { return; }
    if(d){
        var divw = div.offsetWidth ? div.offsetWidth : $(div).width();
        div.style.left = pos.left - divw + a.offsetWidth + "px";
    } else {
        div.style.left = pos.left + "px";
    }
    div.style.display = "block";
}

// 被点击的顶部按钮的索引;
var sortIndex;
//顶部导航下拉框渲染
function showList(a) {
	if ($ID("TopSearchSelectList")) { $ID("TopSearchSelectList").style.display = "none"; }
	var status = $ID("topShowList") ? $ID("topShowList").style.display : '';
    var div = $ID("topShowList");
    var html = ["<ul class='showlist'>"];
    if (!div) {
        div = document.createElement("div");
        div.id = "topShowList";
        div.style.width = 150 + "px";
        div.style.top = '60px';
        div.style.left=a.offsetLeft+'px'
        document.body.appendChild(div);
    }
    var index = a.getAttribute("data-index");
    if (index == sortIndex && status == 'block') { $ID("topShowList").style.display = "none"; return }
    sortIndex = index;
    if (!index && (index + "") != "0") { return }
    var pageParams=window.PageInitParams[0];
    var item = pageParams.TopLinkBars[index * 1];
    var list = item.ChildMenus;
    if (!list) { div.style.display = "none"; return; }
    var str = "", f = false, url = "", clickEvent = "";
    if (pageParams.FinanceName && item.Title == "设置") { str += "<li title='" + pageParams.FinanceRangeTitle + "' onmousedown='app.stopDomEvent();' onclick='ShowFinaceYearList(this)'><div  id='financeAcount' ><a href='javascript:void(0);' >" + pageParams.FinanceName + "</a><span class='financeAccount' id='finacelistico' style='font-family:\"宋体\"'>></span></div></li>"; }
    for (var i = 0; i < list.length; i++) {
        var item = list[i];
        url = item.Url ? item.Url : "javascript:void(0);";
        var urlarr=url.split("|");
        if (urlarr.length > 1) { url = urlarr[0]; clickEvent = urlarr[1] }
        str += "<li title='" + item.Title + "' onmousedown='app.stopDomEvent();' onclick='window.top.hideLeftNav();" + clickEvent + ";this.parentNode.parentNode.style.display=\"none\"'><a href='" + (url.indexOf("../")<0?window.SysConfig.VirPath + url:url) + "' " + (url && urlarr.length < 2 ? "target=mainFrame" : "") + ">" + item.Title + "</a></li>";
    }
    html.push(str);
    html.push("</ul>");
    div.innerHTML = html.join("");
    resetSearchListPos(a, div,true)
}

function srTypeChane(a) {
    for (var i = 0; i < 3 ; i++) {
        var na = document.getElementById("srcitem" + i);
        if (!na) { break; }
        if (na.id != a.id) {
            na.className = na.className.replace("_sel", "")
        }
        else {
            if (na.className.indexOf("_sel") < 0) {
                na.className = na.className + "_sel";
            }
        }
    }

    window.currsearchCls = a.innerHTML;
    var v = a.getAttribute("value");
    while (v.indexOf("||") >= 0) {
        v = v.replace("||", "|");
    }

    if (v.indexOf("|") == 0) { v = ("%%x%" + v).replace("%%x%|", ""); }
    var v = v.split("|");
    var txts = v;
    /*if (window.currsearchCls == "客户") {
        txts = document.getElementById("currsrfield2").getAttribute("value").split("|");
    }*/
    if (v[0] == "自定义*") {
        ajax.regEvent("GetSearchDefFields", window.virpath + "SYSA/china2/SearchDef.asp");
        ajax.addParam("cls", window.currsearchCls);
        var r = ajax.send();
        v[0] = r.split("|")[0];
        r = v[0].split("?def$");
        var txt = r[0];
        document.getElementById("currsrfield").innerHTML = txt;
        document.getElementById("currsrfield").title = txt.length > 5 ? txt : "";
        document.getElementById("currsrfield").setAttribute("dbname", r[1]);
    }
    else {
        var txt = txts[0];
        document.getElementById("currsrfield").innerHTML = txt;
        document.getElementById("currsrfield").title = txt.length > 5 ? txt : "";
        document.getElementById("currsrfield").setAttribute("dbname", v[0]);
    }
    if (app.IeVer > 6) {	//IE下该代码在初次加载的时界面小的情况下会引起错乱
        document.getElementById("searchKeyText").focus();
        document.getElementById("searchKeyText").select();
    }
    document.getElementById("currsrfield").setAttribute("value", v.join("|"));
}

/*原检索下拉处理*/
function showsrfields(bn) {
    var sv = document.getElementById("currsrfield").getAttribute("value");
    //没有启用任何检索栏的情况下，直接退出。
    if (!sv) return false;
    if (sv.indexOf("自定义*") >= 0) {
        ajax.regEvent("GetSearchDefFields", window.virpath + "SYSA/china2/SearchDef.asp");
        ajax.addParam("cls", window.currsearchCls);
        sv = sv.replace("自定义*", ajax.send());
    }

    var v = sv.split("|");
    var currv = document.getElementById("currsrfield").outerHTML;
    var m = new ContextMenuClass();
    m.id = "srfields";
    m.onitemclick = function (li) {
        var txt = li.getAttribute("text");
        document.getElementById("currsrfield").innerHTML = txt;
        document.getElementById("currsrfield").title = txt.length > 5 ? txt : "";
        document.getElementById("currsrfield").setAttribute("dbname", li.getAttribute("value"));
        document.getElementById("searchKeyText").focus();
        document.getElementById("searchKeyText").select();
    }

    var txts = v;
    /*if (window.currsearchCls == "客户") {
        txts = document.getElementById("currsrfield2").getAttribute("value").split("|");
    }*/
    for (var i = 0 ; i < v.length ; i++) {
        if (v[i].length > 0 && v[i] != currv) {
            var r = v[i];
            if (r.indexOf("?def$") > 0) {
                r = r.split("?def$")
                m.menus.add(r[0], r[1], "");
            }
            else {

                m.menus.add(txts[i], v[i], "");
            }
        }
    }
    m.show();
    m.BindElement(bn, -100, bn.offsetHeight + 2); //绑定在bn旁边显示
}

//顶部检索提交
function sKeyText_onkeydow(v) {
	if (window.event.keyCode == 13) {
		window.top.hideLeftNav();
        var k = document.getElementById("selectedSearchTitle").getAttribute("dbname") || "";
        if (!k) { if (!window.currsearchCls) { return; } }
        if (k.length == 0) { alert("无法进行检索", window.currsearchCls + "栏目下没有设置可检索的字段"); return false; }
        document.getElementById("s_cls1").value = encodeURIComponent(window.currsearchCls);
        document.getElementById("s_fld1").value = encodeURIComponent(k);
        document.getElementById("s_fname1").value = encodeURIComponent(document.getElementById("selectedSearchTitle").value);
        document.getElementById("s_key1").value = encodeURIComponent(document.getElementById("topSearchText").value);
        document.getElementById("s_form").submit();
        return false;
    }
}

//退出函数
function doExit() {
    if (window.confirm("您确定要退出吗？")) {
        if (top.saveMenuHistory) {
            try { top.saveMenuHistory(); } catch (e) { }
        }
        return true;
    }
    else { window.returnValue = false; return false; }
}

//返回首页
function goHome() {
    try {
        $ID('frmbody').contentWindow.document.getElementsByTagName("iframe")[0].contentWindow.cMenuPag(0);
    }
    catch (e) { }
    $ID('frmbody').contentWindow.document.getElementsByTagName("iframe")[2].contentWindow.location.href = window.virpath + "SYSA/china2/home.html";
    window.top.borderFrame.css({ width: "1px" }); window.top.spliter.addClass("childremenu0").removeClass("childremenu1");
}

//设置界面大小
function formconfig() {
    $("#topShowList").hide();
    var div = app.createWindow("userconfig", "UI设置", "null", "null", "null", 400, 200, 0, 1, "#e3e7f0");
    div.style.cssText = "cursor:default;border:1px solid #ccc;width:359px;height:125px;background-color:#f2f2f2";
    var zm = window.uizoom;
    if (!zm) { zm = 1; }
    div.innerHTML = "<div style='margin:20px;margin-left:30px;color:#000;cursor:default;font-size:12px;'>界面缩放：" +
					"<input  type='radio'name='uiformzoom' onclick='formconfigc(this.value)' value='1' " + (zm == 1 ? "checked" : "") + " id='uif1'><label for='uif1'>原始</label>&nbsp;&nbsp;" +
					"<input type='radio' name='uiformzoom' onclick='formconfigc(this.value)' value='1.13' " + (zm == 1.13 ? "checked" : "") + " id='uif2'><label for='uif2'>中</label>&nbsp;&nbsp;" +
					"<input type='radio' name='uiformzoom' onclick='formconfigc(this.value)' value='1.3' " + (zm == 1.3 ? "checked" : "") + " id='uif3'><label for='uif3'>大</label></div>" +
					"<center><button onclick='app.closeWindow(\"userconfig\")' class='oldbutton'>关闭</button></center>";
}

function formconfigc(v) {
    window.location.href = "?zoom=" + v;
}
//初始化短消息提醒
var oldPropmResponeText = "";
function ResultPromp(ResponeText) {
    if (ResponeText) {
        var tagFrame = window.location.href.toLowerCase().indexOf("/home.ashx") < 0 ? "I1" : "mainFrame"
        if (window.disPrompValue == true) { return; }
        if (oldPropmResponeText == ResponeText) {
            if (ResponeText.length > 0) {//顶部提醒提示图标显示与否
                var obj = eval("(" + ResponeText + ")"), dat, allnum;
                dat = obj.data;
                for (var i = 0; i < dat.length; i++) {
                    if (dat[i][0] == "allnum") {
                        allnum = dat[i][1];
                        if (allnum * 1) { $("#newReminds").removeClass("hidden") } else { $("#newReminds").addClass("hidden") }
                        break;
                    }
                }
            } else { $("#newReminds").addClass("hidden") }
            window.setTimeout("InitPromp()", window.propmTimer);
            return;
        }
        else {
            oldPropmResponeText = ResponeText;
        }
        try {
            var o = eval("var x=" + ResponeText + ";x");
        } catch (e) { return; }
        var dat = o.data;
        if (o.sound == 1) {
            app.playMedia(window.virpath + "SYSA/images/security.wav");
            var sound_check = 'checked';
        }
        var new_check = '';
        if (o.new1 == 6) {
            new_check = '【最新】';
        }
        var allnum = 0;
        var sw = (parent.document.body).clientWidth;//document.documentElement.offsetWidth;
        var sh = (parent.document.body).clientHeight;//document.documentElement.offsetHeight-22;
        var htm = "<table align=center style='width:240px;'><tr>";
        var hs = false;
        for (var i = 0; i < dat.length ; i++) {
            hs = false;
            if (dat[i][0] == "allnum") {
                allnum = dat[i][1];
                if (allnum*1) { $("#newReminds").removeClass("hidden") } else { $("#newReminds").addClass("hidden") }
            }
            else {
                htm = htm + "<td style='padding-left:5px;width:auto;color:#333;line-height:20px'>" + dat[i][0] + "(<a class='sys_noticeMessage' href='" + dat[i][2].replace("../", window.virpath + "SYSA/") + "' target='" + tagFrame + "' style='color:#FF004C;cursor:pointer;font-weight:bold;'>" + dat[i][1] + "</a>) </td>";
            }
            if (i % 2 == 1 && i > 0) {
                hs = true;
                htm = htm + "</tr><tr>";
            }
        }
        if (hs == false) { htm = htm + "</tr>"; }
        htm = htm + "</table>"
        if (allnum * 1 > 0) {
            var div = app.createWindow("propmDiv", "<span style='font-size:12px;position:relative;top:1px;width:350px;'>" + new_check + "您有(<a target='" + tagFrame + "' href='../../../SYSA/china/topalt.asp'  onclick='showallPropm()' style='text-decoration:underline;color:#FF004C;cursor:pointer'>" + allnum + "</a>)条消息</span>",  window.sysskin + "/images/dlgico/loudspeaker.png", parseInt((sw - 280)), parseInt((sh - 190)), 280, 180, 0, 0, "#E3E7F0");
            div.innerHTML = "<div style='position:absolute;top:0px;height:90px;overflow:auto;background-color:#fff;cursor:default;overflow-x:hidden;width:240px;padding-left: 8px;box-sizing: border-box;padding-right: 10px;'>" + htm + "</div>" +
							"<div style='height:20px;overflow:hidden;line-height:14px;position:absolute;top:90px;box-sizing:border-box;margin-top:5px;padding-left:18px;width:220px;'>" +
								"<input onclick='disPromp()' style='position:relative;top:2px' class='radio' type=checkbox id='yxsdsd'>" +
								"<label style='position:relative;color:#333'>今日不再提醒</label>" +
								"<span style='position:relative;left:44px;'>" +
									"<input onclick='sound_open()' style='position:relative;top:2px;color:#E5E5E5' class='radio' type=checkbox id='yxsdsd2' " + sound_check + ">" +
									"<label style='color:#333'>声音提醒</label>" +
									"<a href='../setjm/set_jm.asp' target='" + tagFrame + "' style='position:relative;left:16px;'>设置</a>" +
								"</span>" +  
							"</div>";
        }
        if (window.disPrompValue == false) { window.setTimeout("InitPromp()", window.propmTimer); }

    }
}


function InitPromp() {
    var t = new Date();
    var r = Math.round(Math.random() * 100);
    var s = document.getElementById("allowPop").value;
    if (s == 1) {
        ajax.regEvent("", window.virpath + "SYSA/china/cu.asp?timestamp=" + t.getTime() + "&date1=" + r + "&ver=new");
        ajax.send(ResultPromp);
    }
}

function showallPropm() {
    app.closeWindow("propmDiv");
}

function alt_SetDisPromp() {//--设置今日不再提醒session
    var url = "../../../SYSA/inc/ReminderDisPromp.asp?act=SetDisPromp&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    try { xmlHttp.send(null); } catch (e) { }
}

function alt_GettDisPromp() {//--获取今日不再提醒session
    var DisPromp;
    var url = "../../../SYSA/inc/ReminderDisPromp.asp?act=GetDisPromp&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        if (xmlHttp.readyState == 4) {
            DisPromp = xmlHttp.responseText;
            xmlHttp.abort();
        }
    };
    try { xmlHttp.send(null); } catch (e) { }
    return DisPromp;
}

window.disPrompValue = false;
function disPromp() {//禁止今日提醒
    window.disPrompValue = true;
    alt_SetDisPromp();
    app.closeWindow("propmDiv");
}

function showDatePanel() //显示日历
{
    var div = app.createWindow("szczxcdate", "系统日历", '', '', '', 560, 455, '', 1, '#E3E7F0')
    div.style.overflow = "hidden";
    div.innerHTML = "<iframe style='width:100%;height:100%' scrolling='no' src='' frameborder='0'></iframe>";
    div.children[0].src = window.virpath + "SYSA/ATools/wnl/index.htm";
}

function autosizeframe() {
    if (window.tmp00124) { window.clearTimeout(window.tmp00124) };
    window.tmp00124 = setTimeout(function () {
        try {
            var bodydiv = $ID("bodydiv");
            var h1 = document.body.offsetHeight;
            //var h2 = $ID("buttomdiv").offsetHeight;
            var h3 = $ID("topdiv").offsetHeight;
            var h4 = $ID("frmbody");
            bodydiv.style.height = (h1 - (h3 == 0 ? 6 : h3)) + "px";
            h4.style.height = bodydiv.style.height;
        } catch (e) {
            alert(e)
        }
    }, 10
	);
}

//创建电话组件
function initphonectl() {
    var url = window.location.href
    var si = url.toLowerCase().indexOf("sysn/view/initmozi/home.ashx")
    url = url.substr(0, si - 1) + "/SYSA"
    ajax.regEvent("getObjectHTML", window.virpath + "SYSA/ocx/ctlevent.asp?date1=" + Math.round(Math.random() * 100));
    ajax.send(
		function (html) {
		    if (html.length > 0) {
		        var div = document.createElement("div");
		        div.style.cssText = "position:absolute;left:1px;height:1px;top:1px;width:1px;background-color:white";
		        document.body.appendChild(div);
		        html = html.replace("#defserverurl", url);
		        div.innerHTML = html;
		        try {
		            if (!document.getElementById("PhoneCtl").version) {
		                //alert("加载组件失败，可能需要降低浏览器安全设置，然后启动浏览器。")
		                var setupdiv = app.createWindow("setupsss", "下载组件安装程序", '', '', '', 600, 400, '', 1, '#E3E7F0')
		                setupdiv.innerHTML = "<iframe src='../../../SYSA/ocx/setup.asp' frameborder=0 style='width:560px;height:320px'></iframe>"
		            }
		            else {
		                var txt = "<span style='color:#007700;font-size:12px;font-family:宋体;position:relative;top:4px;left:2px;line-height:15px'>电话录音组件启动正常。<br>"
								 + "组件版本:<span style='color:red'>" + document.getElementById("PhoneCtl").version + "</span></span>"
		                document.getElementById("PhoneCtl").showtext(txt)
		            }
		        } catch (e) {
		            //alert("加载组件失败，可能需要降低浏览器安全设置，然后启动浏览器。")
		            var setupdiv = app.createWindow("setupsss", "下载组件安装程序", '', '', '', 600, 400, '', 1, '#E3E7F0')
		            setupdiv.innerHTML = "<iframe src='../../../SYSA/ocx/setup.asp' frameborder=0 style='width:560px;height:320px'></iframe>"
		        }
		    }
		}
	);
}

function InitPage()	//页面初始化是
{
    var ax = new window.XmlHttp();
    ax.regEvent("InitWork", window.virpath + "SYSA/china2/topsy.asp");
    ax.send(
		function (r) {
		    if (r != "ok") {
		        var div = app.createWindow("initalert", "系统加载警告", '', '', '', 480, 300, '', '')
		        var d = document.createElement("div");
		        try { d.innerHTML = r; } catch (e) { }
		        div.innerHTML = "<div style='color:red;padding:10px;line-height:22px;'>在加载相关业务过程出现警告或错误<br><b><a class='fun' href='javascript:void(0)' onclick='return app.swpVisible(\"initerrorpanel\")'>点击</a></b>查看详情。<div style='height:5px;overflow:hidden'></div>"
							  + "<div style='display:none;color:blue;padding:4px;border:1px dashed #ccccdd;background-color:white' id='initerrorpanel'>" + d.innerText + "</div></div>";
		    }
		}
	);
}

window.onload = function () { //topsy.asp加载
    try { if (window.addPhone == 1) { initphonectl(); }; } catch (e) { }
    window.setTimeout("InitPage()", 2000);//初始系统加载项，例如库存备份等...
    setTimeout(function () {
        try { window.disPrompValue = (alt_GettDisPromp() == "True") ? true : false; } catch (e) { }
        InitPromp()  //初始化提示
    }, 3000);
    try { initUserTimeoutTest(); } catch (e) { }  //初始化默认退出时间设置功能
    window.setTimeout("try{getSession()}catch(ex){}", 1000);
}

function initUserTimeoutTest() {  //初始化默认退出时间设置功能
    UserTimeout = UserTimeout * 1; //类型转化
    if (UserTimeout <= 0) { return; }
    window.UserTimeoutI = parseInt(UserTimeout * 60 / 10);  //设置的超时时间的十分之1作为定时间隔时间，如果定时间隔时间超过1.5分钟，这设置为1.5分钟，小于5s则，为5s
    if (window.UserTimeoutI < 6) { window.UserTimeoutI = 5; }
    if (window.UserTimeoutI > 90) { window.UserTimeoutI = 90; }
    setTimeout("UserTimeoutTest()", window.UserTimeoutI * 1000);
}
window.ajax = new xmlHttp();
window.XmlHttp = xmlHttp;
window.utHttp = new window.XmlHttp();
window.userTimeoutState = 0
function UserTimeoutTest() { //提交超时验证请求
    var t = new Date();
    var ax = utHttp;
    ax.regEvent("", window.virpath + "SYSA/china2/UserTimeoutTest.asp?tt=" + t.getTime());
    ax.addParam("maxv", UserTimeout * 60);
    ax.send(function (r) {
        //top.document.title = r;  //调试语句，检测超时状态，建议勿删
        if (r == "1") {  //超时了
            window.userTimeoutState = 1
            getSession(1); //启动原有的超时检测代码。
        }
        else {
            setTimeout("UserTimeoutTest()", window.UserTimeoutI * 1000);
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

function sound_open() {
    //开启关闭声音
    var url = "../../../SYSA/cu_sound.asp?timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
    };
    xmlHttp.send(null);
    xmlHttp.abort();
}

try { document.onmousedown = datedlg.autohide; } catch (e) { } //#bug301
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
    try {
        var frm = document.getElementById("frmbody").contentWindow.document.getElementById("mainFrame").contentWindow;
        frm.history.go(1);
    }
    catch (e) { }
}

function homeGoBack() {
    try {
        var frm = document.getElementById("frmbody").contentWindow.document.getElementById("mainFrame").contentWindow;
        //currlinkTime和FirstlinkTime防止点击后退按钮直接退出 ， 关联main.asp 134 行代码
        if (window.currlinkTime && window.FirstlinkTime) {
            if (window.currlinkTime == window.FirstlinkTime) {
                if (frm.location.href.indexOf("china2/main.asp") > 0) {
                    return;
                }
            }
        }
        frm.history.go(-1);
    }
    catch (e) { }
}

//设置桌面快捷方式
function toDesktop(n) {
    if (app.getIEVer() > 11) {
        alert("抱歉，此功能目前只支持IE浏览器。");
        return;
    }
    var url = window.location.href.split("?")[0].toLowerCase();
    url = url.replace("/sysn/view/init/home.ashx", "");
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
            f.writeline("URL=" + url + "/sysn/view/init/login.ashx");
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
    var h = (window.screen.availHeight < window.screen.height ? screen.availHeight : screen.height);
    var s = 'left=' + parseInt(w * 0.07) + ',top=' + parseInt((h - 55) * 0.05) + ',width=' + parseInt(w * 0.86) + ',height=' + parseInt((h - 55) * 0.9) + ',scrollbars=yes,resizable=yes'
    return s;
}

window.onunload = function () {
    if (event.clientX < 0 || event.clientY < 0) {
        ajax.url = window.virpath + "SYSA/inc/logout.asp?tryloginout=1&data=" + (new Date()).getTime()
        ajax.regEvent("", ajax.url);
        ajax.send();
    }
}
