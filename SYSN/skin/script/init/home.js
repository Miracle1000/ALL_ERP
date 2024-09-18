var HomeObj = null;
window.PageInitParams = new Array();
window.setFinanceSign = true;//设置财务账套的标记，服务端回调判断用；
window.PageInitParams.NewChangeGuide = {
    homeGuide:{ homeGuideStep:[{
        stepTitle: "全局导航",
        txtInfo: "你想要的功能都在这里哦～",
        areaWidth: 212,
        areaHeight: 0,
        layerdec:"left"
    }, {
        stepTitle: "常用功能",
        txtInfo: "常用功能自定义，高效进入",
        areaWidth: 92,
        areaHeight: 44,
        layerdec: "left"
    }, {
        stepTitle: "消息提醒",
        txtInfo: "快速处理待办事项",
        areaWidth: 70,
        areaHeight: 60,
        layerdec: "up"
    }, {
        stepTitle: "常用工具",
        txtInfo: "在这里设置自己的常用工具，如：微信、邮箱等",
        areaWidth: 70,
        areaHeight: 60,
        layerdec: "up"
    }, {
        stepTitle: "换肤",
        txtInfo: "皮肤和字号不喜欢？点击这里，一键切换",
        areaWidth: 70,
        areaHeight: 60,
        layerdec: "up"
    }, {
        stepTitle: "帮助",
        txtInfo: "1. 操作中有问题可以进入使用手册<br><span style='color:#fff'>1. </span>查询使用说明 <br>2. 有更好的建议，在这里提交吧",
        areaWidth: 70,
        areaHeight: 60,
        layerdec: "up"
    }],
    currStep: -1,
    domsign:"home"
    },
    commUsedGuide:{
        commUsedGuideStep: [{
            stepTitle: "",
            txtInfo: "点击返回标准导航",
            areaWidth: 212,
            areaHeight: 212,
            layerdec: "left"
        }],
        currStep: -1,
        domsign: "used"
    }
}
window.NewChangeGuide = {
    startText: function () {
        var version = document.getElementsByName("version")[0].getAttribute("content");
        var str = "<div id='new_guide_start'>" +
                    "<div class='new_guide_hello'><div class='img'></div><h1 class='meet'>终于见面啦！</h1></div>" +
                    "<p class='new_guide_version'>您已经进入智邦国际ERP【V" + (version||3202) +"】版本哦</p>" +
                    "<p class='new_guide_text'>接下来跟着我的指引，了解一下这里吧~</p>" +
                    "<div class='new_guide_button'><button class='skip' onclick='NewChangeGuide.skipGuide(\"homeGuide\")'>跳过引导</button><button class='start' onclick='NewChangeGuide.nextGuide()'>开始吧</button></div>"+
                    "<div class='bgline'></div>"+
                   "</div>"
        return str;
    },
    stepText: function (key) {
        var na = key ? key :"homeGuide"
        var pobj = window.PageInitParams.NewChangeGuide[na];
        var obj = pobj[na + "Step"];
        var step = pobj.currStep;
        var str = "<div id='new_guide_goStart'>" +
            "<div class='new_guide_stepInfo'><span class='step'><span id='new_guide_stepIdx'>" + (step * 1 + 1) + "</span>/" + obj.length + "</span><span class='skip' onclick='NewChangeGuide.skipGuide(\""+(key||"")+"\")'>跳过</span></div>" +
            "<div id='new_guide_step_title'>" + obj[step]["stepTitle"] + "</div>" +
            "<div id='new_guide_step_text'>" + obj[step]["txtInfo"] + "</div>" +
            "<div class='new_guide_step_btn'><button class='new_guide_next_step' onclick='" + (obj.length - 1 == step ?"NewChangeGuide.doneGuide(\""+(key||"")+"\")":"NewChangeGuide.nextGuide()")+"'>" + (obj.length - 1 == step?"我知道了": "下一步") +"</button>" +
            "<button class='new_guide_prev_step" + (step >= 1 ? "" : " hide") + "' onclick='NewChangeGuide.preGuide(\""+(key||"")+"\")'>上一步</button></div>" +
            "<div class='arrow" + (step < 0 ? " hide" : "") + (obj[step].layerdec == "left"?" left":" up")+"'></div>"
            "</div>"
        return str
    },
    creatGuideHtml: function (htm) {
        var guidePanel = document.getElementById("new_guide_panel");
        var guideViewarea = document.getElementById("new_guide_area");
        var h = $("body").height();
        var w = $("body").width();
        if (!guideViewarea) { $("body").append("<div id='new_guide_area' style='border-top-width:" + h / 2 +"px;border-bottom-width:" + h/2 + "px;border-left-width:0px;border-right-width:" + w + "px'></div>") }
        if (!guidePanel) { $("body").append("<div id='new_guide_panel' style='top:50%;left:50%;margin-top:-200px;margin-left:-292px;'>" + (htm||"") + "</div>") }
    },
    guideAreaPos: function (key) {
        var z = window.uizoom||1;
        var obj = PageInitParams.NewChangeGuide[key];
        var idx = obj.currStep;
        var area = obj[key + "Step"][idx];
        var borderLw, borderTw, borderRw, borderBw, element;
        var ww = document.documentElement.clientWidth || document.body.clientWidth;
        var wh = (document.documentElement.clientHeight || document.body.clientHeight);
        if (key == "homeGuide" && (idx == 0 || idx == 1) || key =="commUsedGuide") {
            var leftnav = window.frames[0].frames[0].document.getElementById("navContain");
            if (!leftnav) { alert("未找到元素"); NewChangeGuide.layerHide(); return }
            element = $(leftnav).find("[" + obj.domsign + "-data-step='" + (idx * 1 + 1) + "']")[0];
            borderLw = 0; borderTw = element.getBoundingClientRect().top + 60;
        } else {
            element = $("[" + obj.domsign + "-data-step='" + (idx * 1 + 1) + "']")[0];
        }
        if (!element) { alert(element); NewChangeGuide.layerHide(); return; }
        var pos = element.getBoundingClientRect();
        borderLw = isNaN(borderLw) ? pos.left : borderLw;
        borderTw = isNaN(borderTw) ? pos.top - 15 : borderTw;
        borderRw = ww - borderLw - area.areaWidth;
        borderBw = wh - borderTw - (area.areaHeight)*z;
        $("#new_guide_area").css({
            width: ww + "px",
            height: wh + "px",
            borderLeftWidth: (borderLw < 0 ? 0 : borderLw) + "px",
            borderTopWidth: (borderTw < 0 ? 0 : borderTw) + "px",
            borderRightWidth: (borderRw < 0 ? 0 : borderRw) + "px",
            borderBottomWidth: (borderBw<0?0:borderBw) + "px"
        })
        /*引导弹层的位置*/
        var gh = $("#new_guide_panel").height() * z;
        var gw = 270;//#new_guide_panel弹层宽度；
        var gtop, gleft,awlft,awtop;
        if (area.layerdec == "left") {
            gtop = borderTw + (area.areaHeight / 2)*z - gh / 2;
            gleft = borderLw + area.areaWidth + 20;
            $("#new_guide_panel .arrow").css({ top: "50%", left: "-10px", marginTop: "-12px" })
            if (gtop < 60 * z) {
                gtop = 60 * z;
                awtop=(area.areaHeight / 2)*z - 12;//12是箭头图标一半的高度
            }

            if (gtop*z + gh >= wh) {
                gtop = (wh/z) - (gh/z) - 6;//6是弹层距离底部的的高度，自定义的
                awtop = borderTw + (area.areaHeight / 2)*z - gtop - 12;
                if (awtop + 24 >= (gh/z)) { awtop = (gh/z) -34  }
                awlft = "-10px";
                $("#new_guide_panel .arrow").css({ top: awtop + "px", left: awlft, marginTop: "0px" })
            }
        } else if (area.layerdec == "up"){
            gtop = borderTw + area.areaHeight*z  + 12;
            gleft = borderLw + area.areaWidth / 2 - gw/2;
            $("#new_guide_panel .arrow").css({ top: "0", left: "50%", marginTop:"-10px" })
            if (gleft + gw >= ww) { gleft = ww - gw - 6; }
        }
        $("#new_guide_panel").css({ left: gleft + "px", top: gtop + "px", margin: "0px" });
    },
    nextGuide: function (key) {
        $("#new_guide_panel").hide();
        var na = key ? key : "homeGuide";
        var pobj = window.PageInitParams.NewChangeGuide[na];
        pobj.currStep = pobj.currStep*1+1;
        var htm = NewChangeGuide.stepText(na);
        $("#new_guide_panel").html(htm);
        NewChangeGuide.guideAreaPos(na);
        $("#new_guide_area").show();
        setTimeout(function () { $("#new_guide_panel").stop().fadeIn(100, "swing") }, 400);
    },
    preGuide: function (key) {
        $("#new_guide_panel").hide();
        var na = key ? key : "homeGuide";
        var pobj = window.PageInitParams.NewChangeGuide[na];
        pobj.currStep = pobj.currStep * 1 - 1;
        var htm = NewChangeGuide.stepText(na);
        $("#new_guide_panel").html(htm);
        NewChangeGuide.guideAreaPos(na);
        $("#new_guide_area").show();
        setTimeout(function () { $("#new_guide_panel").stop().fadeIn(100, "swing") }, 400);
    },
    skipGuide: function (n) {
        var n = n ||"homeGuide"
        if (!n) { return }
        NewChangeGuide.doneGuide(n)
    },
    doneGuide: function (n) {
        var ne = n || "homeGuide"
        NewChangeGuide.layerHide();
        localStorage.setItem(window.UserInfo.Id +"_" + ne, 1);
    },
    layerHide: function () {
        $("#new_guide_panel").hide();
        $("#new_guide_area").hide();
    },
    resize: function () {
        var homestorage = localStorage.getItem(window.UserInfo.Id + "_homeGuide");
        var usedstroage = localStorage.getItem(window.UserInfo.Id + "_commUsedGuide");
        if (!homestorage) {
            var step = PageInitParams.NewChangeGuide.homeGuide.currStep;
            if (step < 0) {
                var h = $("body").height();
                var w = $("body").width();
                $("#new_guide_area").css({
                    borderLeftWidth: 0+ "px",
                    borderRightWidth: w  + "px",
                    borderTopWidth: 0 + "px",
                    borderBottomWidth: h  + "px",
                });
            } else { NewChangeGuide.guideAreaPos("homeGuide") }
            return;
        }
        if (!usedstroage) {
            if (!$("#new_guide_area")[0] || !$("#new_guide_area")[0].offsetHeight) { return; }
            NewChangeGuide.guideAreaPos("commUsedGuide")
        }
    }
};

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

//生成导航菜单html
function GetTopMenuHTML() {
    var mvw = new MenuViewClass();
    mvw.id = "topmenu";
    mvw.itemwidth = 90;
    mvw.width = 360;
    var nodes=HomeObj.TopMenus.Nodes;
    if ((nodes && nodes[nodes.length - 1] && !mvw.isSetTopNavBtn(nodes[nodes.length - 1].Text)) || (nodes && !nodes.length)) {//新增顶部导航设置按钮
        HomeObj.TopMenus.Nodes.push({
            ID: "1",
            Nodes: [],
            NodesCount: 0,
            OType: 0,
            Text: "设置顶部导航",
            Url: ""
        });
    }
    AddTopMenus(mvw.menus, HomeObj.TopMenus.Nodes);
    return mvw.Html();
}

function AddTopMenus(ms, ds) {
    for (var i = 0; i < ds.length; i++) {
        var item = ds[i];
        var nm = ms.add()
        nm.text = item.Text;
        var url = item.Url.replace("sys:", "") + "??" + item.Otype + "??" + item.Id;
		nm.value  = url;
        if (item.NodesCount > 0) {
            AddTopMenus(nm.menus, item.Nodes);
        }
    }
}


function GetTopBarHTML() {
    var html = new Array();
    var id = "topbar";
    var itemHeight = 30;
    var itemWidth = 30;
    html.push("<div id='toolbar_" + id + "' class='toolbar'>");
    var pagesize = 10;
    var dsize = HomeObj.TopFunBars.length;
    for (var i = 0; i < (dsize > pagesize ? pagesize : dsize) ; i++) {
        var bn = HomeObj.TopFunBars[i];
        html.push("<div id='toolbar_" + id + "_" + i + "' sort=" +  i + " class='btnlist' value=\"" + bn.Title.replace("\"","&#34;") + "#-#" + bn.Otype + "??" + bn.Url.replace("\"","&#34;") + "??" + bn.TipUrl + "??" + bn.Id + "#-#" + bn.Ico + "#-#0#-#" + i + "#-#" + id  + "\" style='height:" + (itemHeight+2) + "px;' onclick='__toolbarclick(this)' ico1='" + bn.Ico + "' title=\"" +  bn.Title.replace("\"","&#34;") + "\" >");
        html.push("<div class='btnimg' style='height:" + itemHeight + "px;width:" + itemWidth + "px;overflow:hidden;padding:0px;'>")
        html.push("<div style='cursor:pointer;background:transparent url(" + window.SysConfig.VirPath + "SYSA/skin/default/images/toolbar/" + bn.Ico + ") no-repeat center center;width:100%;height:100%;FILTER: progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\"" + window.SysConfig.VirPath + "SYSA/skin/default/images/toolbar/" + bn.Ico + "\",sizingMethod=\"scale\");_background:transparent;background-size:100% 100%'>");
        html.push("</div></div></div>");
        html.push("<div style='width:5px;' class='spc'>&nbsp;</div>");
    }
    if (dsize > pagesize) {
        var moredata = "";
        for(var i = pagesize; i < dsize; i++) {
            var bn = HomeObj.TopFunBars[i];
            moredata = moredata + "$%#4" + bn.Title + "#-#" + (bn.Otype + "??" + bn.Url.replace("\"","&#34;") + "??" + bn.TipUrl + "??" + bn.Id) + "#-#" + bn.Ico + "#-#0#-#" + i + "#-#" + id;
        }
        html.push("<div class=arrow  style='height:" + (itemHeight + 2) + "px;' onmouseout='this.className=\"arrow\"' onmousedown='__toolbarshowmore(this)' onmouseover='this.className=\"arrow_hover\"'>");
        html.push("<input type='hidden' value=\"" + moredata.replace("\"", "&#34;") + "\">");
        html.push("</div>");
    }
    html.push("<div class='setToolBar'><a href='../../../SYSA/china2/homeseting/homeSet.html?type=2' target='mainFrame' title='添加工具栏'></a></div>")
    html.push("</div>");
    return html.join("");
}

function GetSearchHTML() {
    var datas = HomeObj.Searchs;
    var html = new Array();
    morev = "";
    if (datas.length > 3) {
        for (var i = 3; i < datas.length; i++) {
            morev = morev + "#$" + datas[i].join("|");
        }
        html.push("<a onmousedown='showMoreSearch(this);' onclick='return false' onfocus='this.blur()' href='javascript:void(0)' class='a04' value='" + morev + "'>&nbsp;</a>");
    }
    else if(datas.length>0) {
        html.push("<a click='return false' onfocus='this.blur()' href='javascript:void(0)' class='a04_dis'>&nbsp;</a>");
    }
    for (var i = (datas.length > 3 ? 3 : datas.length) - 1; i >= 0; i--) {
        var items = datas[i];
        html.push("<a onclick='srTypeChane(this);return false;' id='srcitem" + i + "' onfocus='this.blur()' href='javascript:void(0)' value=\"" + items.slice(1).join("|") + "\" class='a0" + (i==0?"1":"2") + "'>" + items[0] + "</a>");
    }
    return html.join("");
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
    return $ID("bodydiv").offsetHeight;
}
function TopScan(id, srcTag) {
    srcTag.value = "../store/planall7.asp?product_txm=" + srcTag.value + "??0??22"
    if (window.onMenuItemClick) {
        window.onMenuItemClick(id, srcTag);
    }
}

window.createPage = function () {
    if (window.UserInfo.Zoom && !isNaN(window.UserInfo.Zoom) && window.UserInfo.Zoom != 1) {
        document.body.style.zoom = window.UserInfo.Zoom;
    }
    createOldAttrs();
    HomeObj = window.PageInitParams[0];
    document.body.id = "homebody";
    window.propmTimer = HomeObj.PropmTimer;
    window.UserTimeout = HomeObj.UserTimeout;
	HomeObj.EWords = (HomeObj.EWords || "").replace(/\n/g,"").replace(/\r/g,"").replace(/\s/g,"&nbsp;");
	HomeObj.EWords = HomeObj.EWords || "未设置激励语";
    //此处编写渲染代码
    var dat = new Array();
    dat[0] = "<img  onpropertychange='logoicochange(this)' onclick='goHome();' style='cursor:pointer;' src=\"" + HomeObj.LogoUrl + "\" id='logoBox'/>\n"
    dat[1] = "<script>document.getElementById(\"logoBox\").src = \"" + (HomeObj.LogoUrl + "?t=" + (new Date()).getTime()) + "\";</script>\n"
    dat[16] = "<div id='topdiv'>\n"
    dat[17] = "  <div id=\"top\">\n"
    dat[18] = "    <div class=\"logo left\">\n"
    dat[19] = "	</div>\n"
    dat[20] = "    <div class=\"t-m-menu\">\n"
    dat[21] = "      <div class=\"t-m\">\n"
    dat[22] = "        <div class=\"link-right right\">\n"
    dat[23] = "		<a href=\"../china/tophome2.asp\"  target='mainFrame'>" 

    
    var navs = [{
        Children:[],
        Icon: "account.png",
        Name: "账套",
        Url: null,
        className:'account-btn'
    },{
        Children:[],
        Icon: "home.png",
        Name: "首页",
        Url: null,
        className:'home-btn'
    },{
        Children:[],
        Icon: "msg.png",
        Name: "消息",
        Url: null,
        className:'msgtips-btn'
    }]
    var rightNav = HomeObj.TopFuncMenu;
    var html = new Array();
    for(var i = 0;i<navs.length;i++){
        var item = navs[i];
        var scriptStr = '';// 要执行的js语句
        var tipsStr = '';// 消息的角标
        var styleStr = '';// 控制样式
        switch(i){
            case 0:
                scriptStr = 'ShowFinaceYearList();showSubNav(this)';
                styleStr = HomeObj.FinanceName && HomeObj.FinanceName != "" ?'':'display:none';
                break;
            case 1:
                scriptStr = 'goHome()';
                break;
            case 2:
                scriptStr = 'showSubNav(this)';
                tipsStr = '<span class="msgTips">0</span>';
                break
            default:
                scriptStr = 'alert("默认")';
                break;
        }
        html.push("<div class='topnav-item "+ item.className +"' home-data-step='"+ (item.Name == '消息'?'3':'') +"'  style='"+ styleStr +"' onclick='"+ scriptStr +"'> <a style='_color:white;' href='javascript:void(0)'>"+ tipsStr +"<img src=\"@SYSA/skin/default/images/hometop/" + item.Icon + "\" class=\"ico\" />" + item.Name + "</a></div>");
    }
    var c = rightNav.length;
    var hspop = false;
    for (var i = 0; i < c; i++) {
        var item = rightNav[i];
        if(item.Name == '工具'){
            item.step = 4;
        }else if(item.Name == '换肤'){
            item.step = 5;
        }else if(item.Name == '帮助'){
            item.step = 6;
        }
        var u = item.Url?item.Url.split("|"):[];
		var canclick=false;
        if (u[0] == "" || u[0] === undefined) { u[0] = "javascript:void(0)"; }
		switch(u[0]){
			case "../../../SYSA/china/tophome2.asp":
			case "../../../SYSA/china/topalt.asp":
		    case "../../../SYSA/china/topadd.asp":
		    case "../comm/RecycleBin.ashx":
		    case "../../../SYSA/china2/homeseting/index.asp": canclick = true; break;
		}
		if (u[0] == "../../../SYSA/china/topadd.asp") {
			u[1] = "LeftGotoUserMenu()";
		}
        u[1] = u[1] ? " onclick='" + u[1] + "' " : "";
		if(canclick){
			if(u[1]){
			  u[1]=u[1].replace("onclick='","onclick='hideLeftNav();")
			}else{
			   u[1]="onclick='hideLeftNav()'"
			  }
		}
        var tgt = (u[1] == "onclick='hideLeftNav()'" ? " target=mainFrame " : "");
        if ( item.Url && item.Url.indexOf("homeseting") > 0 || u[0] == "../../../SYSA/china/topadd.asp") {
			tgt =  " target=mainFrame ";
        }
        u[0] = u[0].replace("index.asp", "homeSet.html")
        html.push(" <div class='topnav-item' onclick='showSubNav(this)' home-data-step='"+ item.step +"'> <a style='_color:white' href='" + u[0] + "' " + u[1] + tgt + "><img src=\"@SYSA/skin/default/images/hometop/" + item.Icon + "\" class=\"ico\" />" + (item.Name == '个人信息'?window.UserInfo.Name:item.Name)  + (i == c-1?' <img src="@SYSA/skin/default/images/hometop/expand.png">':'')  + "</a>"+ ( item.Name != '日程'? createSubNav(item, i) :'' ) + "</div>");
        if (item.Title == "提醒") { hspop = true;}
    }
    try {
    	var firstvalue = HomeObj.Searchs.length>0?HomeObj.Searchs[0].concat().splice(1, 100).join("|"):"";
    	
    } catch (e) { }
    html.push("<input type=\"hidden\" id=\"allowPop\"  value=\"" + (hspop ? 1 : 0) + "\" />");
    if (window.SysConfig.IsDebugModel == 1) {
        dat[23] += ("<div id='debugsignbar'onclick='app.Alert(\"客户第一，打造精品，我只是一个彩蛋！\");return false;'>调•试</div>");
        dat[23] += ("<div id='debughandle' onclick=\"window.open('" + window.SysConfig.VirPath + "SYSN/update/HistoryDataHandle_CostAnalysis.ashx', 'handlewindow', fwAttr());return false\" title='成本核算数据检测'>检•测</div>");
    }
    window.PageInitParams.search = [["客户", "客户名称", "拼 音 码", "客户编号", "办公电话", " 传   真 ", "客户地址", " 邮   编 ", "电子邮件", "客户网址", " 备   注 ", "客户分类", "跟进程度", "客户来源", "客户行业", "价值评估", "联系人姓名", "联系人电话", "联系人手机", "联系人微信", "洽谈进展", "自定义*"], ["产品", "产品名称", "拼音码", "条形码", "产品编号", "产品型号", "自定义*", "产品参数", "产品说明", "图片与附件"], ["合同", "合同主题", "合同编号", "客户名称", "客户编号", "合同分类", "合同概要", "合同状态", "销售人员", "自定义*"], ["联系人", "姓名", "拼音码", "电话", "传真", "邮件", "手机", "手机2", "生日", "性别", "家庭电话", "QQ", "MSN", "微信", "爱好", "地址", "备注"], ["报价", "报价主题", "报价编号", "客户名称", "报价备注", "自定义*"], ["售后", "售后主题", "售后编号", "售后内容", "接待人员", "处理内容", "售后备注", "紧急程度", "售后结果"], ["供应商", "供应商名称", "拼音码", "供应商编号", "电话", "传真", "地址", "邮件", "联系人姓名", "联系人电话", "联系人手机", "备注"], ["预购", "预购主题", "预购编号", "预购概要", "预购人员", "供应商", "预购状态"], ["采购", "采购主题", "采购编号", "供应商", "采购概要", "采购人员", "采购分类", "自定义*"], ["库存", "产品名称", "产品编号", "产品型号", "仓库名称"], ["入库", "入库主题", "入库编号", "库管人员", "关联采购", "关联供应商", "自定义*"], ["出库", "出库主题", "出库编号", "审批人员", "关联合同", "关联客户", "自定义*"], ["发货", "发货主题", "发货编号", "发货状态", "关联客户", "自定义*"], ["收款", "客户名称", "客户编号", "关联合同", "合同编号", "底单编号"], ["付款", "供应商名称", "供应商编号", "关联采购", "采购编号"], ["报销费用", "报销主题", "报销编号", "报销概要", "报销人员"], ["公告", "公告主题", "公告内容"], ["日程", "日程内容", "周报内容", "月报内容", "年报内容"], ["物料清单", "清单主题", "清单编号", "产品名称", "产品编号", "产品型号"], ["生产计划", "计划主题", "计划编号", "添加人员"], ["生产订单", "订单主题", "订单编号", "添加人员"], ["生产派工", "派工主题", "派工编号", "产品名称", "产品编号", "产品型号"], ["工序计划", "工序名称", "单据主题", "单据编号", "产品名称", "产品编号", "产品型号"], ["派工质检", "质检主题", "质检编号", "单据主题", "单据编号", "添加人员", "质检人员", "产品名称", "产品编号", "产品型号"], ["整单委外", "委外主题", "委外编号"], ["委外质检", "质检主题", "质检编号", "委外主题", "委外编号"], ["工序质检", "质检主题", "质检编号", "质检工序", "单据主题", "单据编号"], ["生产领料", "领料主题", "领料编号", "产品名称", "产品编号", "产品型号"], ["物流", "第三方物流单号", "物流单主题", "物流编号", "物流对账主题", "物流对账编号"]],
    window.PageInitParams[0].NewSearchs = [{
                                        "Name": "客户",
                                        "Children": ["客户名称", "拼 音 码", "客户编号", "办公电话", " 传   真 ", "客户地址", " 邮   编 ", "电子邮件", "客户网址", " 备   注 ", "客户分类", "跟进程度", "客户来源", "客户行业", "价值评估", "联系人姓名", "联系人电话", "联系人手机", "联系人微信", "洽谈进展", "自定义5$def=zdy5", "111$def=zdy6"]
                                }, {
                                        "Name": "产品",
                                        "Children": ["产品名称", "拼音码", "条形码", "产品编号", "产品型号", "规格$def=zdy1", "材质$def=zdy2", "功率$def=zdy3", "产品参数", "产品说明", "图片与附件"]
                                }, {
                                        "Name": "合同",
                                        "Children": ["合同主题", "合同编号", "客户名称", "客户编号", "合同分类", "合同概要", "合同状态", "销售人员"]
                                }, {
                                        "Name": "联系人",
                                        "Children": ["姓名", "拼音码", "电话", "传真", "邮件", "手机", "手机2", "生日", "性别", "家庭电话", "QQ", "MSN", "微信", "爱好", "地址", "备注"]
                                }, {
                                        "Name": "报价",
                                        "Children": ["报价主题", "报价编号", "客户名称", "报价备注"]
                                }, {
                                        "Name": "售后",
                                        "Children": ["售后主题", "售后编号", "售后内容", "接待人员", "处理内容", "售后备注", "紧急程度", "售后结果"]
                                }, {
                                        "Name": "供应商",
                                        "Children": ["供应商名称", "拼音码", "供应商编号", "电话", "传真", "地址", "邮件", "联系人姓名", "联系人电话", "联系人手机", "备注"]
                                }, {
                                        "Name": "预购",
                                        "Children": ["预购主题", "预购编号", "预购概要", "预购人员", "供应商", "预购状态"]
                                }, {
                                        "Name": "采购",
                                        "Children": ["采购主题", "采购编号", "供应商", "采购概要", "采购人员", "采购分类"]
                                }, {
                                        "Name": "库存",
                                        "Children": ["产品名称", "产品编号", "产品型号", "仓库名称"]
                                }, {
                                        "Name": "入库",
                                        "Children": ["入库主题", "入库编号", "库管人员", "关联采购", "关联供应商", "磅单编号$def=newmain_414", "入库车号$def=newmain_415"]
                                }, {
                                        "Name": "出库",
                                        "Children": ["出库主题", "出库编号", "审批人员", "关联合同", "关联客户", "客户名称$def=newmain_511", "自定义2$def=newmain_512", "自定义3$def=newmain_513", "自定义4$def=newmain_514", "自定义5$def=newmain_515", "自定义6$def=newmain_516"]
                                }, {
                                        "Name": "发货",
                                        "Children": ["发货主题", "发货编号", "发货状态", "关联客户", "发货1$def=newmain_434", "自定义6$def=newmain_439"]
                                }, {
                                        "Name": "收款",
                                        "Children": ["客户名称", "客户编号", "关联合同", "合同编号", "底单编号"]
                                }, {
                                        "Name": "付款",
                                        "Children": ["供应商名称", "供应商编号", "关联采购", "采购编号"]
                                }, {
                                        "Name": "报销费用",
                                        "Children": ["报销主题", "报销编号", "报销概要", "报销人员"]
                                }, {
                                        "Name": "公告",
                                        "Children": ["公告主题", "公告内容"]
                                }, {
                                        "Name": "日程",
                                        "Children": ["日程内容", "周报内容", "月报内容", "年报内容"]
                                }, {
                                        "Name": "物料清单",
                                        "Children": ["清单主题", "清单编号", "产品名称", "产品编号", "产品型号"]
                                }, {
                                        "Name": "生产计划",
                                        "Children": ["计划主题", "计划编号", "添加人员"]
                                }, {
                                        "Name": "生产订单",
                                        "Children": ["订单主题", "订单编号", "添加人员"]
                                }, {
                                        "Name": "生产派工",
                                        "Children": ["派工主题", "派工编号", "产品名称", "产品编号", "产品型号"]
                                }, {
                                        "Name": "工序计划",
                                        "Children": ["工序名称", "单据主题", "单据编号", "产品名称", "产品编号", "产品型号"]
                                }, {
                                        "Name": "派工质检",
                                        "Children": ["质检主题", "质检编号", "单据主题", "单据编号", "添加人员", "质检人员", "产品名称", "产品编号", "产品型号"]
                                }, {
                                        "Name": "整单委外",
                                        "Children": ["委外主题", "委外编号"]
                                }, {
                                        "Name": "委外质检",
                                        "Children": ["质检主题", "质检编号", "委外主题", "委外编号"]
                                }, {
                                        "Name": "工序质检",
                                        "Children": ["质检主题", "质检编号", "质检工序", "单据主题", "单据编号"]
                                }, {
                                        "Name": "生产领料",
                                        "Children": ["领料主题", "领料编号", "产品名称", "产品编号", "产品型号"]
                                }, {
                                        "Name": "物流",
                                        "Children": ["第三方物流单号", "物流单主题", "物流编号", "物流对账主题", "物流对账编号"]
                                }];
    dat[23] += html.join("");
    dat[24] = "		</div>\n"
    dat[25] = "      </div>\n"
    dat[31] = "		 <form action='@SYSA/china2/search.asp?utf8=1' method='post' style='display:inline' id='s_form' target='mainFrame'>\n"
    dat[32] = "			<input type='hidden' name='s_cls' id='s_cls1'>\n"
    dat[33] = "			<input type='hidden' name='s_fld' id='s_fld1'>\n"
    dat[34] = "			<input type='hidden' name='s_key' id='s_key1'>\n"
    dat[35] = "         <input type='hidden' name='s_fname' id='s_fname1'>\n"
    dat[36] = "		 </form>\n"
    
    window.currsearchCls = window.PageInitParams[0].NewSearchs.length && window.PageInitParams[0].NewSearchs[0].Name;
    dat[26] =  window.PageInitParams[0].NewSearchs.length>0? "<div class='key-search-box'><div class='key-box'><span onclick='showSubSort()' style='position: absolute;width: 70px;height: 20px;left: -6px;top: -6px;padding: 6px 20px 6px 16px;z-index:2;text-overflow: ellipsis;overflow: hidden;white-space: nowrap;' class='key-sort' id='key-sort'>"+ window.PageInitParams[0].NewSearchs[0].Children[0] +"</span><img class='expand-keys' src='@SYSA/skin/default/images/hometop/expand-keys.png'><ul class='keysort-list' style='z-index:2;'>"+ window.createSortItem(window.PageInitParams[0].NewSearchs) +"</ul><ul class='keysort-sub-list'></ul></div><div class='search-box'><input class='search-txt' id='search-txt' placeholder='输入关键字查询' onkeypress='return sKeyText_onkeydow(0)'></div><div class='search-btn' onclick='sKeyText_onkeydow(1)'><img class='search-icon' src='@SYSA/skin/default/images/hometop/search-btn.png'></div></div>":'</div>';
    dat[46] = "    </div>\n"
    dat[47] = "  </div>\n"
    dat[48] = "</div>\n"
    dat[49] = "<div id='bodydiv' style='z-index:100;' onscroll='this.scrollTop=\"0px\"'>\n"
    dat[50] = "  <iframe src=\"../../../SYSA/china2/default.aspx?cache=0\" onload='if(!window.xxfirstload){window.xxfirstload=1;onload()}' frameborder=\"0\" id=\"frmbody\" scrolling=\"no\"></iframe>\n"
    dat[51] = "</div>\n"
    var now = new Date();
	var m = (now.getMonth()*1+1);
	var d= now.getDate();
	dat[56] = "			<a style='display:none;' href='javascript:void(0)' onclick='showDatePanel();return false;' id='DateStWords' title='鼠标单击查看日历'>" + now.getFullYear() + "年" + (m < 10 ? ("0" + m) : m) + "月" + (d < 10 ? ("0" + d) : d) + "日</a>"
				+ "<img style='display:none;' src=\"@SYSA/skin/default/images/ico_footer_02.gif\" class=\"ico_line\" />\n"
	if (HomeObj.FinanceName && HomeObj.FinanceName != "") {
		dat[57] = "			<span id=\"curraccount\" style='display:none;' title='" + HomeObj.FinanceRangeTitle + "'><img src=\"@SYSA/skin/default/images/ico_footer_02.gif\"  class=\"ico_line\" />"
									+ "<span style='display:none;' id=\"curraccountname\">" + HomeObj.FinanceName + " </span >"
									+ "<img style='display:none;' onclick='ShowFinaceYearList(this)'  id='finacelistico' src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/u16.png'>"
									+"</span>"
	}
	else {
		dat[57] = "			<span style='display:none;' id=\"curraccount\" style=\" display:none; \"><img src=\"@SYSA/skin/default/images/ico_footer_02.gif\"  class=\"ico_line\" />"
									+ "<span style='display:none;' id=\"curraccountname\"></span>"
									+ "<img style='display:none;' onclick='ShowFinaceYearList(this)' style='display:none'  id='finacelistico' src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/u16.png'>"
									+ "</span>"
	}
	dat[57]  = dat[57]  + "<img style='display:none;' src=\"@SYSA/skin/default/images/ico_footer_02.gif\"  class=\"ico_line\" /><a href='javascript:void(0)' id='UserStWords' onclick='setStimulusWords();return false;' title='鼠标单击设置您的激励语'>" + HomeObj.EWords + "</a>\n"
    dat[58] = "			\n"
    dat[59] = "			</div>\n"
    dat[60] = "			<div style='display:none;' class=\"copyright\">\n"
    var version = "";
    try {
        version = document.getElementsByName("version")[0].getAttribute("content");
    } catch (e) { }
    dat[61] = "            <a style='display:none;' href='javascript:void(0)' onclick=\"window.open('@SYSA/china2/help.asp?V=424709046064815', 'helpwindow', fwAttr());return false\"  class='bottomlink'>帮助</a>"
                + "<img style='display:none;' src=\"@SYSA/skin/default/images/ico_footer_02.gif\"  class=\"ico_line\" />"
                + "<a style='display:none;' href=\"javascript:void(0);\" onClick=\"toDesktop(document.title);return false;\" class='bottomlink'>创建快捷方式</a>"
                + "<img style='display:none;' src=\"@SYSA/skin/default/images/ico_footer_02.gif\"  class=\"ico_line\" />"
                + "<a style='display:none;' href='http://www.zbintel.com/product/advice_cus.asp?uid=" + HomeObj.UniqueName + "' target='_blank'  class='bottomlink'>提交建议</a>"
                + (window.SysConfig.IsBetaModel == 1 ? "<img src=\"@SYSA/skin/default/images/ico_footer_02.gif\"  class=\"ico_line\" /><a href='javascript:void(0)' onclick='showBetaBugPage(); return false;' class='bottomlink'>反馈问题</a>" : "")
                + "<img src=\"@SYSA/skin/default/images/ico_footer_02.gif\"  class=\"ico_line\" /><span title='点击查看版本详情' id='verlinkbox' onclick='window.ShowAutoMeDlg()'>V" + version  + "</span>" + (window.SysConfig.IsBetaModel == 1 ? " <span style='color:yellow;text-shadow: 0px 0px 1px #111188'>(公测版)</span>" : "");
    dat[62] = "			<img style='display:none;' src=\"@SYSA/skin/default/images/ico_footer_02.gif\"  class=\"ico_line\" /><img value='0' onclick='zoomfBox(this)' title='点击界面全屏' id='zoomf' src='@SYSA/skin/default/images/hometop/allp.png'>\n"
    dat[63] = "			</div>\n"
    dat[64] = "		</div>\n"
    dat[65] = "  </div>\n"
    dat[66] = "</div>\n"
    dat[67] = "\n"
    dat[68] = "<input type='hidden' name='I1' id='I1'><!-- 兼容老代码对框架名称为I1的错误，防止报错 -->\n"
    dat[69] = "\n"
    dat[70] = "<form method=\"post\"  id=\"txmfrom\"  name=\"txmfrom\" style=\"width:0; height:0;border:0 0 0 0;margin: 0px;padding: 0px;\">\n"
    dat[71] = "	<input name=\"txm\" autocomplete=\"off\" type=\"text\" style=\" width:0px; height:0px; border:0 0 0 0;margin: 0px;padding: 0px;\" onkeypress=\"if(event.keyCode==13) {TopScan('topmenu',this);this.value='';unEnterDown();}\" onFocus=\"this.value=''\" size=\"10\">\n"
    dat[72] = "</form>\n"
    document.write(dat.join("").replace(/\@SYSA/g, window.SysConfig.VirPath + "SYSA"));

    var tmsobj = $ID("srcitem0");
    if (tmsobj) { srTypeChane(tmsobj); }
    if (HomeObj.NeedShowGuidePage) {
    	var h = document.documentElement.offsetHeight || 800;
    	var div = app.createWindow("guiddlg", "系统启用及配置引导", '', '', parseInt(h * 0.05), 1100, parseInt(h * 0.90), '', 1, '#E3E7F0')
    	div.style.overflow = "hidden";
    	div.innerHTML = "<iframe style='width:100%;height:100%;background-color:white;border:1px solid #ccc' scrolling='yes' src='guide.ashx' frameborder='0'></iframe>";
    }
}
window.showSubSort = function(){
    var e = window.event;
    if(e.stopPropagation){
        e.stopPropagation();
    }else{
        e.cancelBubble = true;
    }
    $('.subNav-box').hide();
    $('.keysort-list').show();
    $('#topnavMarker').show();
    changeMainSort(window.lastMainSort || $('.keysort-main-item')[0]);
}
/*
@@ 创建顶部搜索栏分类
@ params 
    data 数据源
*/ 
window.createSortItem = function(data){
    var html = ''
    for(var i = 0;i<data.length;i++){
        html += '<li class="keysort-item keysort-main-item" datalist="'+ data[i].Children.join('__') +'" onclick="changeMainSort(this)">'+ data[i].Name +'</li>';
    }
    return html;
}
window.changeMainSort = function(self){
    var e = window.event;
    if(e.stopPropagation){
        e.stopPropagation();
    }else{
        e.cancelBubble = true;
    }
    window.lastMainSort = $(self);
    var data = $(self).attr('datalist').split('__');
    var html = '';
    $(self).addClass('active').siblings().removeClass('active')
    for(var i = 0;i<data.length;i++){
        html += '<li class="keysort-item keysort-sub-item" onclick="selectSort(\''+ data[i]+'\',\''+ $(self).text() +'\')">'+ data[i] +'</li>';
    }
    $('.keysort-sub-list').html(html);
    $('.keysort-sub-list').show();
}
window.selectSort = function(subName,mainName){
    window.currsearchCls = mainName;
    $('.key-sort').text(subName);
    $('.key-sort').attr('title',subName)
}
/*
@@ 创建顶部导航子菜单
@ params 
    data 数据源
    type 类型
        '工具' 0
        '日程' 1
        '换肤' 2
        '帮助' 3
        '个人信息' 4
*/ 
window.createSubNav = function(data,type){
    var datas = data.Children
    var html = '<div class="subNav-box subNav-box'+ type +'"><img class="sub-arrow-up sub-arrow-up'+ type +'" src="@SYSA/skin/default/images/hometop/arrow-up.png"/>';
    switch(type){
        case 0:
            html+= '<ul class="subnav-list">';
            for(var i = 0;i<datas.length;i++){
                html+='<li class="subnav-item" title="'+ datas[i].Name +'"><a target="mainFrame" href="../../../SYSA/'+ datas[i].Url.replace('../','') +'"><img src="@SYSA/skin/default/images/toolbar/'+ datas[i].Icon +'" />'+ datas[i].Name +'</a></li>';
            }
            html+='</ul><div class="subnav-item last-subnav-item" style="padding:0;"><a style="color:inherit!important;line-height:inherit!important;text-align:center;" target="mainFrame" href="../../../SYSA/china2/homeseting/homeSet.html?type=2"><img src="@SYSA/skin/default/images/hometop/setting.png" />管理</a></div>';
            break;
        case 2:
            var colors = [{
                color1:'#1A58AA',
                color2:'#114893',
                name:'经典蓝',
                skinname:'default'
            },{
                color1:'#409669',
                color2:'#328B5B',
                name:'护眼绿',
                skinname:'green'
            },{
                color1:'#865AA7',
                color2:'#79479E',
                name:'淡雅紫',
                skinname:'purple'
            },{
                color1:'#B451AB',
                color2:'#AA419E',
                name:'少女粉',
                skinname:'pink'
            }]
            var zoom = window.uizoom;

            html+= '<div class="skin-ctx">';
            html+= '<div class="skin-font">切换字号：<span class="small-font font-item '+ (zoom == 1?'active':'') +'" onclick="formconfigc(1)"><img src="@SYSA/skin/default/images/hometop/font.png" /><img class="active" src="@SYSA/skin/default/images/hometop/font-active.png" /></span><span class="middle-font font-item '+ (zoom == 1.13?'active':'') +'" onclick="formconfigc(1.13)"><img src="@SYSA/skin/default/images/hometop/font.png" /><img class="active" src="@SYSA/skin/default/images/hometop/font-active.png" /></span><span class="big-font font-item '+ (zoom == 1.3?'active':'') +'" onclick="formconfigc(1.3)"><img src="@SYSA/skin/default/images/hometop/font.png" /><img class="active" src="@SYSA/skin/default/images/hometop/font-active.png" /></span></div>';
            html+='<div class="skin-box">切换皮肤:<ul class="skin-colors">';
            for(var i = 0;i<colors.length;i++){
                html+='<li class="skin-color-item" onclick="changeSkin(\''+ colors[i].skinname +'\')"><div class="color-block"><div class="inside-color" style="background:'+ colors[i].color1 +'"></div><div class="inside-color" style="background:'+ colors[i].color2 +'"></div></div>'+ colors[i].name +'</li>'
            }
            html+= '</ul></div></div>';
            break;
        case 3:
            html+= '<ul class="subnav-list help-list">';
            for(var i = 0;i<datas.length;i++){
                var url =  datas[i].Url;
                var isInLink = datas[i].Url.indexOf('http') == -1; // 是不是内部链接
                if(isInLink){
                    html += '<li class="subnav-item" title="'+ datas[i].Name +'"><a href="javascript:void(0)" onclick="window.open(\'@SYSA/china2/help.asp?V=424709046064815\', \'helpwindow\', fwAttr());return false;" class="bottomlink">'+ datas[i].Name  +'</a></li>'
                }else{
                    html+='<li class="subnav-item" title="'+ datas[i].Name +'"><a target="_blank" href="'+ url +'">'+ datas[i].Name +'</a></li>';
                }
            }
            html +='</ul><div class="subnav-item last-subnav-item" style="text-align:center;padding:0;"><a href="javascript:window.ShowAutoMeDlg();">V'+ document.getElementsByName("version")[0].getAttribute("content") +'</a></div>';
            break;
        case 4:
            html+= '<div class="subnav-ctx"><div class="person-info"><img class="p-avatar" style="margin:0 auto 10px;display:block;" src="@SYSA/skin/default/images/hometop/p-avatar.png"><div style="text-align:center">'+window
            .UserInfo.Name+'</div><div id="UserStWords" onclick="setStimulusWords();return false;" title="鼠标单击设置您的激励语" style="color:#999;display:block;white-space:pre-wrap;word-break:break-all;width:100%;min-height:24px;">'+ window.PageInitParams[0].EWords +'</div></div>';
            html+= '<ul class="user-options">';
            for(var i = 0;i<datas.length;i++){
                html+='<li class="user-option-item"><a '+ (datas[i].Url?'target="mainFrame"':'')+' href="'+ (datas[i].Url || '../../../SYSA/inc/logout.asp') +'" '+ (datas[i].Url?'':'onclick="return doExit()"') +'><img src="@SYSA/skin/default/images/hometop/'+ datas[i].Icon +'">'+ datas[i].Name +'</a></li>'
            }
            html+='</ul></div>';
            break;
    }
    html+= '</div>';
    return html;

}
window.showSubNav = function(dom){
    var e = window.event;
    if(e.stopPropagation){
        e.stopPropagation();
    }else{
        e.cancelBubble = true;
    }
    $('.subNav-box').hide();
    $('.keysort-list').hide();
    $('.keysort-sub-list').hide();
    $(dom).find('.subNav-box').show();
    $('#topnavMarker').show();
}
window.changeSkin = function(skinname){
    window.skinname = skinname;
    ajax.regEvent("",  window.virpath + "SYSN/view/init/home.ashx?__msgid=SetSkin&skinname=" + skinname);
    ajax.send(function(data){
        ajax.regEvent("",  window.virpath + "SYSA/checkin2.asp?__msgid=refreshskin");
        ajax.send(function(data){
            console.log(data);
            refreshCss();
        });
    });
}

window.refreshctc = 1000;
window.refreshCss = function ()
{
	window.refreshctc++;
    var allwins = getAllFrames(window,[window]);
    for(var i = 0;i<allwins.length;i++)
	{
		var win = allwins[i];
        window.refreshLinks(win);
    }
}
window.refreshLinks = function(iwin){
	var doc = iwin.document;
	var lks = [];
	var links = doc.getElementsByTagName('link');
	var cccc = links.length;
	for(var i=0; i<cccc; i++) { lks.push(links[i]); }
    for(var i = 0;i<cccc;i++){
        var newurl = "";
		var oldlink = lks[i];
		var  pheader = oldlink.parentNode;
        var  newurl = oldlink.href.indexOf('WebSource')>-1 ?  oldlink.href.replace(/(skin\/default|skin\/purple|skin\/pink|skin\/green)/ , 'skin/'+window.skinname) : (oldlink.href.split('?')[0]+'?t=' + window.refreshctc);
        var newlink  = doc.createElement("link");
		oldlink.id = "S" + window.refreshctc + "I" + i;
        newlink.setAttribute("rel", "stylesheet");
        newlink.setAttribute("type", "text/css");
		newlink.href = newurl;
		newlink.setAttribute("repid", oldlink.id);
		newlink.onload = function(e) { 
			var nlink = e.srcElement;  
			var oid = nlink.getAttribute("repid"); 
			var olk = doc.getElementById(oid);
			olk.parentNode.removeChild(olk);
		}
        pheader.appendChild(newlink);
    }
}
/*
@@ 隐藏顶部导航子菜单
*/
window.hideTopNav = function(){
    $('.keysort-list').hide();
    $('.keysort-sub-list').hide();
    $('.subNav-box').hide();
    $('#topnavMarker').hide();
}
if(window.addEventListener){
    window.addEventListener('click',window.top.hideTopNav);
}else{
    window.attachEvent('onclick',window.top.hideTopNav);
}
/*
@@ 添加顶部导航的遮罩层

*/
function craeteTopNavMarker(){
    $('#homebody').append('<div id="topnavMarker" style="position:absolute;z-index:998;width:100%;top:60px;left:0;right:0;bottom:0;display:none;"></div>')
}
function getAllFrames(targetWindow,result){
    var result = result || [];
    for(var i = 0;i<targetWindow.frames.length;i++){
     result.push(targetWindow.frames[i]);
      getAllFrames(targetWindow.frames[i],result);
    }
    return result;
}
window.ShowAutoMeDlg = function () {
	var cs = HomeObj.CopyRightText.split("—");
	var verinfodiv = $ID("versioninfodlg");;
	if (verinfodiv) { return; }
	verinfodiv = document.createElement("div");
	verinfodiv.id = "versioninfodlg";
	var bcss = app.getIEVer() < 9 ? "border-left:1px solid #ccc;border-right:1px solid #ccc;" : "";
	verinfodiv.style.cssText = bcss + "box-shadow: 0px 0px 6px #333355;position:absolute;width:500px;height:300px;bottom:32px;right:16px;background-color:white;display:block;z-index:1000000";
	verinfodiv.innerHTML = "<div class='skinBg' style='height:120px;'>&nbsp;</div>"
	+ "<div style='position:absolute;left:24px;top:16px;font-size:15px;color:#fff;line-height:15px'>版本</div>"
	+ "<div style='position:absolute;right:16px;top:16px;font-family:宋体;font-size:18px;color:#fff;line-height:16px;cursor:pointer;' title='关闭'  onclick='$(\"#versioninfodlg\").remove()'>×</div>"
	+ "<div style='position:absolute;top:52px;font-size:21px;color:#fff;line-height:21px;text-align:center;width:100%'>" + HomeObj.ProductVersionName + "</div>"
	+ "<table  style='position:absolute;top:150px;width:100%;'>"
	+ "<tr class='tableHead' style='height:40px;font-weight:bold'><td>版本</td><td>当前版本</td><td>最新版本</td></tr>"
	+ "<tr style='height:5px;'><td></td></tr>"
	+ "<tr style='height:35px;'><td>PC版本</td><td>" + HomeObj.AppVersionDetails + "</td><td class='newver'><a target=_blank href='http://www.zbintel.com/service-center/exchange2.shtml'>" + (HomeObj.NewAppVersionDetails || "") + "<span class=jt2>&nbsp;&nbsp;&nbsp;</span></a></td></tr>"
	+ "<tr style='height:35px;'><td>移动版本</td><td>" + HomeObj.MobileAppVersion + "</td><td  class='newver'><a target=_blank href='http://www.zbintel.com/service-center/exchange2.shtml'>" + (HomeObj.NewMobileAppVersion  ||"") + "<span class=jt2>&nbsp;&nbsp;&nbsp;</span></a></td></tr>"
	+ "</table>"
	document.body.appendChild(verinfodiv);
}

window.setFinanceName = function( name, title){
    $('.account-btn').show();
    window.PageInitParams[0].FinanceName = name;
}

app.stopDomEvent = function (e) { e = e || window.event; e.stopPropagation ? e.stopPropagation() : window.event.cancelBubble = true; return false; }
function ShowFinaceYearList(box) {
	if($('.account-btn').find('.subNav-box').length == 0){
        var html = '<div class="subNav-box account-box"><img class="sub-arrow-up" src="../../../SYSA/skin/default/images/hometop/arrow-up.png"/><div class="account-ctx"><div class="account-head">当前账套：'+ window.PageInitParams[0].FinanceName +'<span id="account-name"></span></div><ul class="account-list"></ul></div></div>';
        $('.account-btn').append(html);
    }
    ajax.regEvent("GetFinaceYearList");
	var finacelist = eval("(" + ajax.send() + ")");
    console.log(finacelist);
    var html = '';
    for(var i = 0;i<finacelist.length;i++){
        var fitem = finacelist[i];
		if (fitem.iscurryear==1) {
			html = html + "<li class='curr account-item'>" + fitem.year + "年</li>";
		} else {
			html = html + "<li class='account-item' onmousedown='' onclick='ChaneCurrFinaceYear(" + fitem.year + ")'>" + fitem.year + "年</li>";
		}
    }
    $('.account-list').html(html);
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
  var fram=document.getElementById('frmbody');
  if(fram){
   var box=fram.contentWindow.document.getElementById('borderFrame');
   if(box){box.style.width="0px"}
   var spliter=fram.contentWindow.document.getElementById("spliter");
   if(spliter){$(spliter).addClass("childremenu0").removeClass("childremenu1");}
  }
}

function showBetaBugPage() {
    window.open("http://2018.zbintel.com/SYSN/view/kfgl/addissue.ashx?basemsg=" + HomeObj.BetaBugKey,"asdasdasd", "width=860px, height=600px, left=200px, top=100px")
}

$(document).ready(function () {
    if(!window.XMLHttpRequest){
		body_resize();
	}
    craeteTopNavMarker();
	$(window).bind("resize", body_resize);
    $(document.body).bind("scroll", function () { window.scrollTo(0, 0) });
})


function LeftGotoUserMenu() {
	var lfbox = $ID("frmbody").contentWindow.document.getElementById("leftFrame");
	var leftwin = lfbox.contentWindow;
	var tds = leftwin.document.getElementsByTagName("TD");
	for (var i = 0; i < tds.length; i++) {
		if (tds[i].className == "menuitemmid") {
			var td = tds[i];
			if (td.innerHTML == "账号") {
				app.fireEvent(td, "onmousedown");
				leftwin.cMenuPag(0);
			}
		}
	}
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

//设置激励语
function setStimulusWords() {
    var div = app.createWindow("StimulusWords", "自我激励语设置", "", "", "", 400, 200, 0, 1, "white");
    if (div.children.length == 0) {
        ajax.regEvent("setStimulusWords", window.virpath + "SYSA/china2/topsy.asp");
        div.innerHTML = ajax.send();
    }
}

//保存激励语
function saveStimulusWords() {
    var newword = document.getElementById("StimulusWordsBox").value.replace(/\n/g,"");
    if (newword.length >= 100) {
        alert("激励语不能超过100字");
        return;
    }
    ajax.regEvent("saveStimulusWords", window.virpath + "SYSA/china2/topsy.asp")
    ajax.addParam("word", newword)
    r = ajax.send();
    if (r.length > 0) { alert(r); return; }
    document.getElementById("UserStWords").innerHTML = (newword || "未设置激励语");
    app.closeWindow("StimulusWords");
}
//我的导航分类界面切换
function VisibleaddMenuClsPenel(v) {
    if (v == true) {
        document.getElementById("addMenuClsPanel").style.display = "inline";
        document.getElementById("addMenuClsPanel_s").style.display = "none";
    }
    else {
        document.getElementById("addMenuClsPanel").style.display = "none";
        document.getElementById("addMenuClsPanel_s").style.display = "inline";
    }
}
//保存我的导航分类
function addMenuClsSave() {
    var txt = trim(document.getElementById("MenuClsText").value);
    if (txt == "") {
        //alert("目录名称不能为空");
        document.getElementById("tit_3").style.display = '';
        return;
    }
    ajax.regEvent("form:addMyMenuCls", window.virpath + "SYSA/china2/topsy.asp");
    ajax.addParam("utf8", "1");
    ajax.addParam("clsName", encodeURIComponent(txt));
    ajax.send(
	function (r) {
	    if (isNaN(r) == false) {
	        if (r > 0) {
	            var clsbox = document.getElementById("Amm_MenuCls");
	            var opt = document.createElement("option");
	            opt.value = r;
	            opt.innerText = txt;
	            opt.text = txt;
	            try {
	                clsbox.options.appendChild(opt);
	            } catch (e) {
	                clsbox.options.add(opt);

	            }
	            clsbox.selectedIndex = clsbox.options.length - 1;
	        }
	        else {
	            alert("您要添加的目录已经存在。")
	        }
	    }
	    else {
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
    if (document.getElementById("Amm_MenuCls").value * 1 <= 0) {
        alert("请选择目录");
        return;
    }
    ajax.regEvent("form:addMyMenu", window.virpath + "SYSA/china2/topsy.asp");  //此处采用表单方式模拟ajax提交
    ajax.addParam("utf8", "1");
    ajax.addParam("mtit", encodeURIComponent(document.getElementById("mymenutit").value));
    ajax.addParam("mcls", encodeURIComponent(document.getElementById("Amm_MenuCls").value));
    ajax.addParam("murl", encodeURIComponent(document.getElementById("mymenuurldata").value));
    ajax.addParam("mord", encodeURIComponent(mord));
    ajax.send(
		function (r) {
		    if (r == 1) {
		        app.closeWindow("addmymen");
		        try { window.frames[0].frames[0].onMyMenuUpdate(); } catch (e) { }
		    }
		    else {
		        alert(r);
		    }
		}
	);
}

function DelMenuClsPenel() {
	var clsbox = $ID("Amm_MenuCls");
	if(clsbox.value == 0) { app.Alert("目前没有可以删除的分类。");  return; }
	ajax.regEvent("GetMyMenuClsInfos", window.virpath + "SYSA/china2/topsy.asp");
	ajax.addParam("clsid", clsbox.value);
	var r = ajax.send();
	if(isNaN(r)==false && r*1>0) {
		if(window.confirm("温馨提示：分类【" + clsbox.options[clsbox.selectedIndex].text + "】下还有您的" + r + "个网址收藏，确定要一起删除吗？")==false) {
			return;
		}
	}
	ajax.regEvent("deleteMyMenuCls", window.virpath + "SYSA/china2/topsy.asp");
	ajax.addParam("clsid", clsbox.value);
	var r = ajax.send();
	if(r=="1") {
		clsbox.options.remove(clsbox.selectedIndex);
	} else {
		app.Alert(r);
	}
}


//打开连接
function GoURL(url, type) {
    if (url.toLowerCase().indexOf("sysn/") == -1 && url.toLowerCase().indexOf("http")!=0) {
        url = "../../../SYSA/" + url.replace("../", "");
    } else {
		url = url.toLowerCase();
		if(url.indexOf("/sysn/")>=0) {
			url = window.SysConfig.VirPath  + "sysn/" + url.split("/sysn/")[1];
		}
	}
	if(type=="undefined") { type=0; }
	url = url + (url.indexOf("?")>=0 ? "&" : "?") + "FromHomeTopMenu=" + ((type || 0)*1+1);
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

//菜单点击事件
window.onMenuItemClick = function (id, srcElement) {
    if (id == "topmenu") {
        var vArray = srcElement.getAttribute("value").split("??");
        var url = srcElement.innerText.indexOf("设置顶部导航") >= 0 ? "../china2/homeseting/homeSet.html?type=1" : "";
        if (url) { vArray[0] =url}
        if (vArray[0].length > 0) {
            GoURL(vArray[0], vArray[1])
        } else {
            if (vArray[3] == "%sysMore") {
                //点击更多
                var rootindex = vArray[2]-1;
                var currindex = vArray[1]-1;
                var rdata = HomeObj.TopMenus.Nodes[rootindex];
                HomeObj.TopMenus.Nodes[rootindex] = HomeObj.TopMenus.Nodes[currindex];
                HomeObj.TopMenus.Nodes[currindex] = rdata;
                document.getElementById("TopMenuBg").innerHTML = GetTopMenuHTML();
            }
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

function showMoreSearch(a) {
    var vs = a.getAttribute("value").split("#$");
    var m = new ContextMenuClass();
    m.id = "srtypes";
    m.onitemclick = function (li) {
        var bar = document.getElementById("srcitem2");
        if (!bar) { bar = document.getElementById("srcitem1"); }
        if (!bar) { bar = document.getElementById("srcitem0"); }
        if (!bar) { return false; }
        var rvalue = bar.innerHTML + "|" + bar.getAttribute("value");
        var ntext = li.getAttribute("text");
        bar.setAttribute("value", li.getAttribute("value"));
        bar.innerHTML = ntext;
        var s = a.getAttribute("value").split("#$");
        for (var i = s.length - 1; i >= 0 ; i--) {
            if (s[i].indexOf(ntext + "|") == 0) {
                s.splice(i, 1);
                break;
            }
        }
        s[s.length] = rvalue;
        a.setAttribute("value", s.join("#$"));
        srTypeChane(bar);
    }
    for (var i = 1 ; i < vs.length ; i++) {
        var item = vs[i].split("|");
        var txt = item[0];
        item.splice(0, 1)
        m.menus.add(txt, item.join("|"), window.sysskin + "/images/ico16/cl2.gif");
    }
    m.show();
    m.BindElement(a, -108, a.offsetHeight + 2); //绑定在bn旁边显示
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
        ajax.regEvent("GetSearchDefFields",  window.virpath + "SYSA/china2/SearchDef.asp");
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


function showsrfields(bn) {
    var sv = document.getElementById("currsrfield").getAttribute("value");
    //没有启用任何检索栏的情况下，直接退出。
    if (!sv) return false;
    if (sv.indexOf("自定义*") >= 0) {
        ajax.regEvent("GetSearchDefFields",  window.virpath + "SYSA/china2/SearchDef.asp");
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

function sKeyText_onkeydow(v) {
    if (window.event.keyCode == 13 || v == 1) {
        var k = document.getElementById("key-sort").innerText;
        if (!k) { if (!window.currsearchCls) { return; } }
        if (k.length == 0) { alert("无法进行检索", window.currsearchCls + "栏目下没有设置可检索的字段"); return false; }
        document.getElementById("s_cls1").value = encodeURIComponent(window.currsearchCls);
        document.getElementById("s_fld1").value =  encodeURIComponent (k);
        document.getElementById("s_fname1").value = encodeURIComponent(document.getElementById("key-sort").innerText);
        document.getElementById("s_key1").value = encodeURIComponent(document.getElementById("search-txt").value);
        document.getElementById("s_form").submit();
        return false;
    }
}

function doExit() {
    if (window.confirm("您确定要退出吗？")) {
        if (top.saveMenuHistory) {
            try { top.saveMenuHistory(); } catch (e) { }
        }
        return true;
    }
    else { window.returnValue = false; return false; }
}


function goHome() {
    try {
        $ID('frmbody').contentWindow.document.getElementsByTagName("iframe")[0].contentWindow.cMenuPag(0);
    }
    catch (e) { }
    $ID('frmbody').contentWindow.document.getElementsByTagName("iframe")[2].contentWindow.location.href = window.virpath + "SYSA/china2/main.asp";
}

//初始化短消息提醒
var oldPropmResponeText = "";
function ResultPromp(ResponeText) {
    if (ResponeText) {
        var tagFrame = window.location.href.toLowerCase().indexOf("/home.ashx") < 0 ? "I1" : "mainFrame"
        if (window.disPrompValue == true) { return; }
        if (oldPropmResponeText == ResponeText) {
            window.setTimeout("InitPromp()", window.propmTimer);
            return;
        }
        else {
            oldPropmResponeText = ResponeText;
        }
        try {
            var o = eval("var x=" + ResponeText + ";x");
        } catch (e) { return; }
        console.log(o)
        var dat = o.data;
        if (o.sound == 1) {
            app.playMedia( window.virpath + "SYSA/images/security.wav");
            var sound_check = 'checked';
        }
        var allnum = 0;
        if($('.msgtips-btn').find('.subNav-box').length == 0){
            var html = '<div class="subNav-box"><img class="sub-arrow-up" src="../../../SYSA/skin/default/images/hometop/arrow-up.png"/><ul class="subnav-list auto-height"></ul></div>';
            $('.msgtips-btn').append(html);
        }
        var html = ''

        for (var i = 0; i < dat.length ; i++) {
            if (dat[i][0] == "allnum") {
                allnum = dat[i][1]>99?'99+':dat[i][1];
                if(allnum){
                    $('.msgTips').text(allnum);
                    $('.msgTips').show();
                }else{
                    $('.msgTips').hide();
                }
            }else if(i>=5){
                continue;
            }else{
                html+='<li class="subnav-item msg-subnav-item"><a href="' + dat[i][2].replace("../", window.virpath + "SYSA/") + '" target="' + tagFrame + '" style="color:red;cursor:pointer;">'+ dat[i][0] + '<span class="msg-num">' + dat[i][1] + '</span></a></li>';
            }
        }
        html += '<li class="subnav-item msg-subnav-item" style="text-align:center;"><a style="color:inherit!important;line-height:inherit!important;" target="' + tagFrame + '" href="../../../SYSA/china/topalt.asp" onclick="showallPropm()">查看全部</a></li>'
        $('.msgtips-btn .subnav-list').html(html);
        $('.msgtips-btn').show();
        if (window.disPrompValue == false) { window.setTimeout("InitPromp()", window.propmTimer); }
    }
}


function InitPromp() {
    var t = new Date();
    var r = Math.round(Math.random() * 100);
    var s = document.getElementById("allowPop").value;
    if (s == 1 || 1) {
        ajax.regEvent("",  window.virpath + "SYSA/china/cu.asp?timestamp=" + t.getTime() + "&date1=" + r + "&ver=new");
        ajax.send(ResultPromp);
    }
}

function showallPropm() {
    app.closeWindow("propmDiv");
}

function alt_SetDisPromp() {//--设置今日不再提醒session
    var url = "../../../SYSA/inc/ReminderDisPromp.asp?act=SetDisPromp&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
	try{xmlHttp.send(null);}catch(e){}
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
    try{xmlHttp.send(null);}catch(e){}
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
    div.children[0].src =  window.virpath + "SYSA/ATools/wnl/index.htm";
}

function autosizeframe() {
    if (window.tmp00124) { window.clearTimeout(window.tmp00124) };
    window.tmp00124 = setTimeout(function () {
        try {
            var bodydiv = $ID("bodydiv");
            var h1 = document.body.offsetHeight;
            var h2 = 0;
            var h3 = $ID("topdiv").offsetHeight;
            var h4 = $ID("frmbody");
            bodydiv.style.height = (h1 - h2 - (h3 == 0 ? 6 : h3)) + "px";
            h4.style.height = bodydiv.style.height;
        } catch (e) {
            alert(e)
        }
    }, 10);
    window.NewChangeGuide.resize();
}

//创建电话组件
function initphonectl() {
    var url = window.location.href
    var si = url.toLowerCase().indexOf("sysn/view/init/home.ashx")
    url = url.substr(0, si - 1) + "/SYSA"
    ajax.regEvent("getObjectHTML",  window.virpath + "SYSA/ocx/ctlevent.asp?date1=" + Math.round(Math.random() * 100));
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

window.onload = function() { //topsy.asp加载
    try { if (window.addPhone == 1) { initphonectl(); }; } catch (e) { }
    window.setTimeout("InitPage()", 2000);//初始系统加载项，例如库存备份等...
	setTimeout(function(){
		 try { window.disPrompValue = (alt_GettDisPromp() == "True") ? true : false; } catch (e) { }
		 InitPromp()  //初始化提示
	},3000);
    try { initUserTimeoutTest(); } catch (e) { }  //初始化默认退出时间设置功能
    window.setTimeout("try{getSession()}catch(ex){}", 1000);
    if (localStorage && !localStorage.getItem(window.UserInfo.Id+"_homeGuide")) {
        var leftlinks = HomeObj.LeftLinkBars;
        var height1 = leftlinks.length * 44;
        var height2 = (leftlinks[0].ChildMenus.length+1) * 45;
        var maxheight = height1 > height2 ? height1 : height2;
        window.PageInitParams.NewChangeGuide.homeGuide.homeGuideStep[0].areaHeight = maxheight; 
        window.NewChangeGuide.creatGuideHtml(NewChangeGuide.startText());
        $("#new_guide_panel").show();
    }
}

function initUserTimeoutTest() {  //初始化默认退出时间设置功能
    UserTimeout = UserTimeout * 1; //类型转化
    if (UserTimeout <= 0) { return; }
    window.UserTimeoutI = parseInt(UserTimeout * 60 / 10);  //设置的超时时间的十分之1作为定时间隔时间，如果定时间隔时间超过1.5分钟，这设置为1.5分钟，小于5s则，为5s
    if (window.UserTimeoutI < 6) { window.UserTimeoutI = 5; }
    if (window.UserTimeoutI > 90) { window.UserTimeoutI = 90; }
    setTimeout("UserTimeoutTest()", window.UserTimeoutI * 1000);
}

window.utHttp = new window.XmlHttp();
window.userTimeoutState = 0
function UserTimeoutTest() { //提交超时验证请求
    var t = new Date();
    var ax = utHttp;
    ax.regEvent("",  window.virpath + "SYSA/china2/UserTimeoutTest.asp?tt=" + t.getTime());
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
        ajax.url =  window.virpath + "SYSA/inc/logout.asp?tryloginout=1&data=" + (new Date()).getTime()
        ajax.regEvent("", ajax.url);
        ajax.send();
    }
}

function formconfig() {
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

function zoomfBox(box) {
    var v = ((box.getAttribute("value") + "") == "0");
	var ifm=$ID("frmbody");
	if(ifm){
	  var oImg=ifm.contentWindow.document.getElementById("spliterimg");
		 if(oImg){
		   ifm.contentWindow.toggleMenu()
		}
	}
	
    if(box.tagName!="BUTTON"){
        box.src = window.sysskin + "/images/hometop/" + (v ? "allp_s.png" : "allp.png");
        box.title = v ? "点击界面还原" : "点击界面全屏";
        box.setAttribute("value", v ? "1" : "0");
    }else{
        v = ((box.getAttribute("avalue") + "") == "0");
    }
    if (v) {
        $ID("logoBox").style.display = "none";
        $ID("topmenuarea").style.display = "none";
        $ID("topbararea").style.display = "none";
        $ID("topdiv").style.display = "none";
        $ID("bodydiv").style.top = "6px";
        if (window.CHiddenLeftMenu) { window.CHiddenLeftMenu(); }
    } else {
        $ID("logoBox").style.display = "block";
        $ID("topmenuarea").style.display = "block";
        $ID("topbararea").style.display = "block";
        $ID("topdiv").style.display = "block";
        $ID("bodydiv").style.top = "";
        if (window.CShowLeftMenu) { window.CShowLeftMenu(); }
    }
    body_resize();
}

window.showHelp = function (ord) {
    if (!window.virpath) { window.virpath = "../" }
    app.showHelp(ord);
}