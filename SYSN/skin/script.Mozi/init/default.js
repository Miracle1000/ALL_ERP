var logoUrl = top.location.href;
if (logoUrl.indexOf(".ashx") < 0) { top.location.href = logoUrl + "sysn/view/init/login.ashx" }//地址重定向到登录页
window.PageTimerProc = function () {
    resetClearBtnPos()
    if (window.passwordfocus == 1 || $('#password').val() != "") {
        $('#fa_password').css('display', 'none');
    } else {
        var top=$ID("password").getBoundingClientRect().top - $ID("formall").getBoundingClientRect().top
        $('#fa_password').css({ 'display': 'block', top: top +"px"});
    }
    if ($('#jmgpwd')[0] && (window.jmgpasswordfocus == 1 || $('#jmgpwd').val() != "")) {
        $('#fa_p_password').css('display', 'none');
    } else if ($('#jmgpwd')[0]) {
        var top = Math.ceil($ID("jmgpwd").getBoundingClientRect().top - $ID("formall").getBoundingClientRect().top)+1
        $('#fa_p_password').css({ 'display': 'block', top: top + "px" });
    }
    var box = $ID("username");
    if (box) {
        var uv = box.value;
        if (uv.indexOf("请输入用户名") >= 0 || uv == "") {
            if (box.style.color == "black") {
                box.style.color = "#666";
            }
        } else {
            if (box.style.color != "black" && box.getAttribute("setcolor") != "true") {
                box.style.color = "black";
            }
        }
    }
    box = $ID("xcode");
    if (box) {
        var uv = box.value;
        if (uv.indexOf("请输入验证码") >= 0 || uv == "") {
            if (box.style.color == "black") {
                box.style.color = "#666";
            }
        } else {
            if (box.style.color != "black") {
                box.style.color = "black";
            }
        }
    }
    box = $ID("ieShadow");
    if (box) {
        var lgbox = $ID("main_login_body");
        var r = lgbox.getBoundingClientRect();
        if (!window.pscctext) { window.pscctext = "" }
        var newstr = "left:" + (r.left - 7) + "px;top:" + (r.top - 7) + "px;width:" + lgbox.offsetWidth + "px;height:" + lgbox.offsetHeight + "px";
        if (newstr != window.pscctext) {
            window.pscctext = newstr;
            box.style.cssText = newstr;
        }
    }
}

function resetClearBtnPos() {
    var top1 = getElementTop($ID("username"))//用户名清除定位;
    var top2 = getElementTop($ID("password"))//密码清除定位;
    var topj = getElementTop($ID("jmgpwd"))//加密狗清除定位;
    if (!top1 || !top2 || !getElementTop($ID("xcode"))) { return; }
    var top3 = getElementTop($ID("xcode")) - getElementTop($ID("xcode").parentNode);
    $('#clearUserName').css({top: top1 + "px" });
    $('#clearPassWord').css({top: top2 + "px" });
    $('#clearCode').css({ top: top3 + "px" });
    if ($ID("jmgpwd") && $ID("jmgpwd").offsetHeight && topj) {
        $('#clearJmgPw').css({ top: topj + "px" });
    }
}

function getElementTop(ele) {
    if (!ele) { return; }
    var actualTop = ele.offsetTop;
    var current = ele.offsetParent;
    while ((current && current.tagName != "FORM")) {
        actualTop += current.offsetTop;
        current = current.offsetParent;
    }
    return actualTop;
}

window.UserBoxFocus = function (etype) {
    var sbox = window.event.srcElement;
    if ($(sbox).val() == '请输入用户名') {
        $(sbox).val('');
    }
    if (etype != 1) {
        $('#user_icon').css('background-position', 'left bottom');
    }
};

$(function () {
    //顶部设置&下载
    $('#settings').on('click', function () {
        if ($('.set_list').css('display') == 'none') {
            $('.set_list').slideDown("fast");
            $('#settings').addClass('down_click');
            $('#set_bg').css('background-position', 'center bottom');
        } else {
            $('.set_list').css('display', 'none');
            $('#settings').removeClass('down_click');
            $('#set_bg').css('background-position', 'center top');
        }
        $('.scan').css('display', 'none');
        $('#download').removeClass('down_click');
        $('#down_bg').css('background-position', 'center top');
    })
    $('#download').on('click', function () {
        if ($('.scan').css('display') == 'none') {
            $('.scan').slideDown("fast");
            $('#download').addClass('down_click');
            $('#down_bg').css('background-position', 'center bottom');
            var url = window.PageInitParams[0].AppQrCodeLinks[0].Url.replace("two_dimension_code.png", "mozi_dimension_code.png");
            $('#QrCode').find('img').attr('src', url)
        } else {
            $('.scan').css('display', 'none');
            $('#download').removeClass('down_click');
            $('#down_bg').css('background-position', 'center top');
        }
        $('.set_list').css('display', 'none');
        $('#settings').removeClass('down_click');
        $('#set_bg').css('background-position', 'center top');
    })
    $(document).bind('click', function (e) {
        var e = e || window.event; //浏览器兼容性
        var elem = e.target || e.srcElement;
        while (elem) { //循环判断至跟节点，防止点击的是div子元素
            if (elem.id && elem.id == 'settings' || elem.id && elem.id == 'download' || elem.id && elem.id == 'set_list' || elem.id && elem.id == 'down_comm' || elem.id && elem.id == 'down_classify') {
                return;
            }
            elem = elem.parentNode;
        }
        $('.set_list').css('display', 'none');//点击的不是div或其子元素
        $('#settings').removeClass('down_click');
        $('#set_bg').css('background-position', 'center top');
        $('.scan').css('display', 'none');
        $('#download').removeClass('down_click');
        $('#down_bg').css('background-position', 'center top');
    });
    //用户名点击提醒
    var checkPass;
    $('#username').blur(function () {
        if ($(this).val() == '') {
            $(this).val('请输入用户名');
        }
        $('#user_icon').css('background-position', 'left top');
    })

    //密码为空提醒
    window.passwordfocus = 0;
    //加密狗为空提醒
    window.jmgpasswordfocus = 0;
    
    $('#fa_password').click(function () {
        $(this).css('display', 'none');
        $('#password').focus();
    });
    $('#password').focus(function () {
        window.passwordfocus = 1;
        $('.pass_icon').css('background-position', 'left bottom');
    });
    $('#password').blur(function () {
        window.passwordfocus = 0;
        $('.pass_icon').css('background-position', 'left top');
    });

    setInterval(window.PageTimerProc, 100);

    //密码锁为空提醒
    $('#formall').on("click", "#fa_p_password", function () {
        $(this).css('display', 'none');
        $('#jmgpwd').focus();
    })
    //验证码为空提醒
    $('#xcode').focus(function () {
        if ($(this).val() == '请输入验证码') {
            $(this).val('');
        }
    })
    $('#xcode').blur(function () {
        if ($(this).val() == '') {
            $(this).val('请输入验证码');
        }
    })
    //重置
    //$('#reset').click(function(){
    //	$('#fa_password').css('display','block');
    //	$('#fa_p_password').css('display','block');
    //})

    $('#updatelinker').click(function () {
        setTimeout(function () {
            try { $('#shadow').css({ "height": height + "px", "width": width + "px" }); } catch (exx) { }
        }, 500)
        $('#execLoginDiv').css('display', 'block');
        $('#shadow').css("display", 'block');
    })
    var obj;

    $("#rem_name").click(checkRemName);
    $("#crem_name").click(checkRemName);
    $("#rem_password").click(checkRemPass);
    $("#crem_pass").click(checkRemPass);
    $("#xcode, #password, #username").bind("keydown", function (et) {
        if (et.keyCode == 13) {
            var box1 = $ID("username");
            var box2 = $ID("password");
            var box3 = $ID("jmgpwd");
            var box4 = $ID("xcode");
            if (box1 && (box1.value == "" || box1.value == "请输入用户名")) { box1.focus(); return; }
            if (box2 && (box2.value == "" || box1.value == "请输入密码")) { box2.focus(); return; }
            if (box3 && (box3.value == "")) { box3.focus(); return; }
            if (box4 && (box4.value == "" || box4.value == "请输入验证码")) { box4.focus(); return; }
            DoLogin();
        }
    });
})

function checkRemName() {
    if ($("#rem_name").is(':checked') == false) {
        $('#rem_password').prop("checked", false);
    }
}

function checkRemPass() {
    if ($("#rem_password").is(':checked') == true) {
        $('#rem_name').prop("checked", true);
    }
}

var clearIconTimer;
//输入框检测清除图标是否出现；
function clearIconStatus(a) {
    clearInterval(clearIconTimer);
    if (a) {
        clearIconTimer = setInterval(function () {
            switch (a.id) {
                case "username": (a.value+"").length<1 ? $ID("clearUserName").style.display = "none" : $ID("clearUserName").style.display = "block"; break;
                case "password": (a.value + "").length < 1 ? $ID("clearPassWord").style.display = "none" : $ID("clearPassWord").style.display = "block"; break;
                case "xcode": (a.value + "").length < 1 ? $ID("clearCode").style.display = "none" : $ID("clearCode").style.display = "block"; break;
                case "jmgpwd": (a.value + "").length < 1 ? $ID("clearJmgPw").style.display = "none" : $ID("clearJmgPw").style.display = "block"; break; break;
            }
        }, 100)
    } else {
        $ID("clearUserName").style.display = "none";
        $ID("clearPassWord").style.display = "none";
        $ID("clearCode").style.display = "none";
        $ID("clearJmgPw")?$ID("clearJmgPw").style.display = "none":"";
    }
}

//清空输入框内容
$(document).on("mousedown", "span.clearContentIcon", function () {
    switch (this.id) {
        case "clearUserName": $ID("username").value = ""; break;
        case "clearPassWord": $ID("password").value = ""; break;
        case "clearCode": $ID("xcode").value = ""; break;
        case "clearJmgPw": $ID("jmgpwd").value = ""; break;
    }
})

//加密锁焦点与失焦事件
function jmgFocusEvent(a) {
    window.jmgpasswordfocus = 1;
    $(a).css('background-position', 'left bottom');
}
function jmgBlurEvent(a) {
    window.jmgpasswordfocus = 0;
    $(a).css('background-position', 'left top');
}

window.createPage = function () {
    obj = window.PageInitParams[0];
    if (obj.SubSystemKey) {
        document.write("<div id='subloginmark' style='position:absolute;z-index:10000;top:0px;left:0px;width:100%;height:100%;"
		 + "background:transparent url(../../../SYSN/skin/default/img/bg.png) repeat-x center center;text-align:center'>"
		 + "<div style='position:relative;text-align:center;top:40%;color:white;font-size:16px;font-family:微软雅黑'>正在进入子系统，请稍后....</div>"
		 + "</div>");
        setTimeout(function () { $($ID("subloginmark")).remove() }, 3500);
    }
    if (window.parent && window.parent != window) {
        //检测重登录情况
        var purl = window.parent.location.href;
        if (purl.toLowerCase().indexOf("relogin.ashx") > 0) {
            parent.$ID("tishi").children[0].innerHTML = obj.Message;
            obj.Message ? parent.$ID("tishi").style.display = '' : "";
            parent.$ID("codes").click();
            var s = window.ActiveXObject + "";
            var userAgent = navigator.userAgent;
            var isEdge = userAgent.indexOf("Edge") > -1; //判断是否IE的Edge浏览器
            if (s == "undefined" && isEdge != true) { return true; }
            parent.$ID("username").style.color = "";
            parent.$ID("password").style.color = "";
            parent.$ID("username").value = decodeURIComponent(parent.$ID("username").value);
            parent.$ID("password").value = decodeURIComponent(parent.$ID("password").value);
            return;
        }
    }

    var IsLoginPage = window.location.href.toLowerCase().indexOf("login.ashx") > 0;
    window.html = new Array();//设置
    var existsQrLink = obj.AppQrCodeLinks && obj.AppQrCodeLinks.length > 0;
    html.push("<div class='notice' style='" + (existsQrLink ? "" : "width:80px") + "'>");
    if (obj.Menus && obj.Menus.length > 0) {
        if (window.location.href.indexOf("127.0.0.1") > 0) {
            obj.Menus.push({ Url: "javascript:document.getElementById(\"updatelinker\").click()", Title: "数据库升级" });
        }
        html.push("<div class='settings' id='settings'><div class='set_bg' id='set_bg'></div></div>");
        html.push("<ul class='set_list' id='set_list'>");
        for (var i = 0; i < (obj.Menus ? obj.Menus.length : 0) ; i++) {
            html.push("<li><a href='" + obj.Menus[i].Url + "'>" + obj.Menus[i].Title + "</a></li>")
        }
        html.push("</ul>");
    }
    //扫描用户名下载
    if (existsQrLink) {
        html.push("<div class=\"download\" id=\"download\"><div class=\"down_bg\" id=\"down_bg\"></div></div>")
        html.push("<div class=\"down_comm scan\" id=\"down_comm\">");
        html.push("<p class=\"down_comm_scan\" id=\"QrCode\"><img src=''></p>");
        html.push("<p class=\"down_comm_titl\">信湖客户端</p>");
        html.push("<dl class=\"down_comm_pho\"><dt><img src='../../../SYSN/skin/default/img/pic_iphone.png'></dt><dd>iPhone</dd></dl>");
        html.push("<dl class=\"down_comm_pho\"><dt><img src='../../../SYSN/skin/default/img/pic_android.png'></dt><dd>Android</dd></dl>");
        html.push("</div>\n");
    }
    //obj.LogoUrl = "../../../SYSA/skin/default/images/MoZihometop/mozilogin/244-50.png"
    html.push("</div>\n");
    html.push("<div class='main' id='maincn'>");
    html.push("<div class='main_imgbox' id='magicBoxs'><div id='mozimagic1'><img src='../../../SYSA/skin/default/images/MoZihometop/mozilogin/magic.png'></div><div id='mozimagic2'><img src='../../../SYSA/skin/default/images/MoZihometop/mozilogin/magic2.png'></div><div id='mozimagic3'><img src='../../../SYSA/skin/default/images/MoZihometop/mozilogin/magic3.png'></div></div>");
    html.push("<div class='main_login' id='main_login'><div id='main_login_body'>");
    html.push("<div class='cont_top'><div class='top_center' id='top_center'><img id='logoimg' src='" + obj.LogoUrl + "'></div></div>");
    html.push("<div id='cont_body'>");
    (IsLoginPage ? WriteLoginPageHTML : WriteDefaultPageHTML)();
    html.push("</div>");
    if (IsLoginPage) { WriteMobLoginSignHTML(); }
    html.push("</div><div class='white_space' id='white_space'></div>");
    html.push("<div class='mian_login_bottom' id='mb_cont'> <span>&copy;</span>" + obj.CopyRight.replace("—", "-").replace("0", "<a href=\"" + obj.DBUpdateUrl + "\" target='setframe' id='updatelinker'>0</a>") + "&nbsp;&nbsp;&nbsp;" + (obj.CompanyFullName || "北京怀英阁科技有限公司"))
    var bahStr = "";
    if (obj.ICPNo && obj.GXBURL) { bahStr = "<div class='mian_login_bottom2' id='bah_cont'>备案/许可证号：<a href='" + obj.GXBURL + "' target='_blank'>" + obj.ICPNo + "</a></div>" } else if (obj.ICPNo) {
        bahStr = "<div class='mian_login_bottom2' id='bah_cont'>备案/许可证号：" + obj.ICPNo + "</div>"
    }
    html.push(bahStr);
    html.push("<div id='bottomdeskappdiv'>&nbsp;&nbsp;&nbsp;<div>温馨提示：无法获取本机环境参数，请使用<a href='downdesktop.ashx?t=" + (new Date()).getTime() + "' title='点击下载快捷客户端程序'>快捷客户端</a>登录。</div></div></div>");
    html.push("</div>");
    if (window.ActiveXObject && app.getIEVer() <= 8) {
        html.push("<div id='ieShadow'>&nbsp;a</div>");
    }
    html.push("</div>");
    html.push("<iframe name='setframe' style='width:1px;height:1px;position:absolute;left:-100px;'></iframe>");
    html.push("<img id='mainbg' src='../../../SYSA/skin/default/images/MoZihometop/mozilogin/bg1.png" + "'>")
    if (window.TimeFormatCheck && window.TimeFormatCheck.neediisrestart == 1) {
        html.push("<div style='position:absolute;bottom:20px;left:0px;text-align:center;color:#fff;z-index:1000000000;width:100%'>注意：当前应用日期格式不符合常规设置，系统已自动修复，需要手动重启应用程序池生效</div>");
    }
    document.write(html.join(""));
    if (IsLoginPage) {
        if (obj.mustUpdateDB == true) {
            setTimeout(function () {
                alert('系统版本与数据库版本不匹配，请升级系统！');
                document.getElementById("updatelinker").click();
            }, 2000);
        }
    }
    window.PageTimerProc();
    window.WatchSiteInfo(obj);
    if (obj.SubSystemKey) {
        DoLogin();
    }
}

window.WatchSiteInfo = function (obj) {
    if (!obj.ServerSiteUrl) { return; }
    var url1 = window.location.href.toLowerCase().split("sysn/view/init/")[0];
    var url2 = obj.ServerSiteUrl.toLowerCase().split("sysn/view/init/")[0];
    if (url1 != url2) {
        app.ajax.regEvent("regClientSiteInfo");
        app.ajax.addParam("clienturl", url1);
        app.ajax.send();
    }
}

function OpenLoginPage() {
    var wname = 'W' + window.location.href.split("/")[2].replace(":", "").replace(/\./g, "").replace(/\-/g, "");
    var w = screen.width;
    var h = ((window.screen.availHeight < window.screen.height ? screen.availHeight : screen.height) - 55);
    var win = window.open('login.ashx', wname, 'width=' + w + ',height=' + h + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=0');
    win.focus();
}


function WriteDefaultPageHTML() {
    html.push("<div class='cont_btm'><div class='cont_center'>正在加载中，请稍后...</div></div>");
}

function _dp_msv(obj, t) {
    obj.style.color = (t == 1 ? "#1975c4" : "");
}

//function _pg_mu(obj, t){
//	obj.style.backgroundColor = ( t==1? "#1474ab" : "");
//}

function _pg1_mu(obj, t) {
    obj.style.backgroundColor = (t == 1 ? "#e76706" : "");
}

//登录
function DoLogin(attrobj) {
	//校验客户端加密狗
	var idata = window.PageInitParams[0];
	if (window.SysConfig.IsDebugModel != true && (idata.OpenClientDogCheck == true && CheckJMG() == false) && !idata.SubSystemKey) {
        return;
    }
    attrobj = attrobj || {};
    app.ajax.regEvent("DoLogin");
    app.ajax.addParam("usname", $ID("username").value);
    app.ajax.addParam("password", $ID("password").value);
    app.ajax.addParam("subsystemkey", idata.SubSystemKey);
    app.ajax.addParam("subsystemuid", idata.SubSystemUid);
    app.ajax.addParam("yzmcode", $ID("xcode").value);
    app.ajax.addParam("jmgpwd", ($ID("jmgpwd") ? $ID("jmgpwd").value : ""));
    app.ajax.addParam("jmgguid", ($ID("guid") ? $ID("guid").value : ""));
    app.ajax.addParam("jmgmiyao", ($ID("miyao") ? $ID("miyao").value : ""));
    app.ajax.addParam("remberus", ($ID("rem_name").checked ? 1 : 0));
    app.ajax.addParam("remberps", ($ID("rem_password").checked ? 1 : 0));
    app.ajax.addParam("MACAddr", ($ID("MACAddr") ? $ID("MACAddr").value : ""));
    app.ajax.addParam("mobileloginkey", (attrobj.mobileloginkey || ""));
    app.ajax.addParam("clientrndsign", window.clientrndsign);
    app.ajax.addParam("loginUrl", (window.location.href));
    app.ajax.encode();
    var r = app.ajax.send();
    try {
        var IsreLoginPage = window.location.href.toLowerCase().indexOf("relogin.ashx") > 0;
        var obj = eval("(" + r + ")");
        if (obj.result == 0 || (window.SysConfig.IsDebugModel == true && obj.result != 20)) {  //20是升级
            app.ajax.regEvent("");
            app.ajax.setUrl("../../../SYSA/checkin2.asp");
            app.ajax.addParam("sign", obj.message);
            app.ajax.addParam("loginUrl", window.location.href);
            app.ajax.addParam("systemType", window.SysConfig.SystemType);
            var r = app.ajax.send();
            if (window.SysConfig.SystemType == 100) {
                if (IsreLoginPage) {
                    window.parent.reLoginOK("");
                } else {
                    window.location.href = "../../../sysc/view/center/Home.ashx";
                }
                return;
            }
            try {
                var obj = eval("(" + r + ")");
                if (obj.result == 0 || window.SysConfig.IsDebugModel == true) {
                    var IsreLoginPage = window.location.href.toLowerCase().indexOf("relogin.ashx") > 0;
                    if (IsreLoginPage) {
                        if (window.top == window) {
                            window.returnValue = 1;
                            window.close();
                        }
                        else {
                            if (parent.OnreloadOk) {
                                parent.OnreloadOk()
                            }
                        }
                    } else {
                        window.location.href = "home.ashx";
                    }
                } else {
                    var box = $ID("lgstatusbox");
                    if (box && box.getAttribute("lgstatus") == 1) {
                        box.click();  //切换回密码登录，方便显示提示语
                    }
                    $ID("tishi").children[0].innerHTML = obj.message;
                    obj.message ? $ID("tishi").style.display = '' : "";
                    $ID("codes").click();
                    $ID("xcode").value = "";
                }
            } catch (rx) {
                if (r.indexOf("<html>") > 0 && r.toLowerCase().indexOf("savecode.asp") > 0) {
                    window.location.href = "../../../SYSA/checkin2.asp"; //一般此种情况下签名损坏,重新定向到checkin2,由checkin2定向到错误页
                    return;
                }
                document.write(r);
            }
        } else {
            var box = $ID("lgstatusbox");
            if (box && box.getAttribute("lgstatus") == 1) {
                box.click();  //切换回密码登录，方便显示提示语
            }
            $ID("tishi").children[0].innerHTML = obj.message.replace(/\n/g, "<br>").replace("系统需要升级", "系统需要<a style='color:blue' title='点击升级' href='javascript:void(0)' onclick='$ID(\"updatelinker\").click()'>升级</a>");
            $ID("tishi").style.display = "";
            $ID("codes").click();
            $ID("xcode").value = "";
        }
    }
    catch (ex) {
        if (r) { document.write(r); }
    }
}

window.clientrndsign = ((Math.random() + "").replace(".", "") * 1 + "");
function WriteLoginPageHTML() {
    var logintype = (window.location.href.toLowerCase().indexOf("relogin.ashx") > 0 ? "relogin" : "login");
    html.push("<form " + (logintype == "relogin" ? " target='reloginfrm' " : "") + " id='formall' onsubmit='return false'>");
    var msg = ((!obj.Message || obj.Message == "您已正常退出系统") ? "" : obj.Message);
    html.push("<div id='passLogoIn'>密码登录</div><table style='width:100%;border-collapse:collapse;'><tr><td id='tishi'" + (!msg ? " style='display:none'" : "") + " valign=middle><div class='info'>" + msg + "</div></td></tr></table>");
    html.push("<input type='hidden' id='chinese' name='chinese'><input type='hidden' id='usernameid' name='usernameid'><input type='hidden' id='userpassid' name='userpassid'>");
    html.push("<input type='text' style='width:100%' name='username' maxlength='50' " + (logintype == "relogin" ? " style='background-color:#f2f2f2' readonly onkeydown='return false;' " : " onkeydown='window.UserBoxFocus(1)' onmousedown='window.UserBoxFocus(1)' onfocus='this.style.borderColor=\"#dbdbdb\";this.style.backgroundColor=\"#fff\";window.UserBoxFocus();clearIconStatus(this)' onblur='this.style.borderColor=\"#fff\";this.style.backgroundColor=\"#f3f3f3\";clearIconStatus()'") + " id='username' autocomplete=\"off\" value='" + (obj.DefaultUser ? obj.DefaultUser : "请输入用户名") + "'  >");
    html.push("<input type='password' style='width:100%' id='password' name='password' maxlength='50' onfocus='this.style.borderColor=\"#dbdbdb\";this.style.backgroundColor=\"#fff\";clearIconStatus(this)' onblur='this.style.borderColor=\"#fff\";this.style.backgroundColor=\"#f3f3f3\";clearIconStatus()' autocomplete=\"off\" value='" + (obj.DefaultPwd || "") + "' oncopy='return false' oncut='return false' onpaste='return false'><span id='clearUserName' class='clearContentIcon'>X</span><span id='clearPassWord' class='clearContentIcon'>X</span><span id='fa_password'>请输入密码</span>");
    html.push("<div id='jmgou'></div>");
    html.push("<div class='code'><INPUT type='hidden' name='yz'><input ");
    if (window.SysConfig.IsDebugModel == true) {
        html.push(" value='调式模式' style='background-color:#eee;'  readonly ");
    }
    html.push(" maxlength='4'  type='text' style='width:100%' onfocus='this.style.borderColor=\"#dbdbdb\";this.style.backgroundColor=\"#fff\";clearIconStatus(this)' onblur='this.style.borderColor=\"#fff\";this.style.backgroundColor=\"#f3f3f3\";clearIconStatus()'  name='yzm' id='xcode' value='请输入验证码'><span id='clearCode' class='clearContentIcon'>X</span>")
    html.push("<span class='code_img' id='code_img'><IMG src='rndcode.ashx?S=" + clientrndsign + "&S1=" + Math.random() + "'  onclick=\"javascript:this.src='rndcode.ashx?S=" + clientrndsign + "&S1='+Math.random();\" id=codes title=\"看不清?点一下\" border=0></span></div>");
    html.push("<div class='remem_infor'><div class='remem_dom'><INPUT type='checkbox' value='1' " + (obj.HasDefUserID ? "checked" : "") + " name='recUid' id='rem_name'><label for='rem_name' id='crem_name' onmouseover='_dp_msv(this,1)'  onmouseout='_dp_msv(this,0)'>记住用户名</label></div><div class='remem_dom' style='text-align:right;'><INPUT type='checkbox' value='1' name='recPwd' " + (obj.HasDefPassWd ? "checked" : "") + " id='rem_password'><label for='rem_password' id='crem_pass' onmouseover='_dp_msv(this,1)'  onmouseout='_dp_msv(this,0)'>记住密码</label></div></div>");
    html.push("<div class='bottom_button'><input type='button' onclick='DoLogin()' name='Submit' value='登录' id='login'><a id='exitSys' href='javascript:void(0);' onclick='window.top.location.href=\"" + window.SysConfig.VirPath + "SYSN/view/init/login.ashx\"'><b>直接退出系统</b></a><input  id='MACAddr' type='hidden' name='MACAddr' value='" + (obj.MacAddress || "") + "'></div>");
    html.push("</form>");
    if (obj.OpenMacCheck && (obj.MacAddress || "") == "") {  //MacAddress不等于空是来自客户端加载
        html.push("<OBJECT id='locator' classid='CLSID:76A64158-CB41-11D1-8B02-00600806D9B6' VIEWASTEXT style='pisition:absolute;top:-100px;height:1px;width:1px'></OBJECT>");
        html.push("<OBJECT id='foo' name='foo' classid='CLSID:75718C9A-F029-11d1-A1AC-00C04FB6C223'  style='pisition:absolute;top:-100px;height:10px;width:10px'></OBJECT>");
        html.push("<script>MacServerInit()</script><script event='OnObjectReady(objObject,objAsyncContext)' for='foo'>foo_OnObjectReady(objObject,objAsyncContext)</script>");
    }
    setTimeout(function () {
        document.getElementById("password").value = "****";
        setTimeout(function () {
            document.getElementById("password").value = obj.DefaultPwd || "";
        }, 10);
    }, 10);

    if (obj.OpenMacCheck && (obj.MacAddress || "") == "") {
        setTimeout(function () {
            if ($ID("MACAddr").value.length == 0) {
                $ID("bottomdeskappdiv").style.display = "block";
            }
        }, 500);
    }
}

window.WriteMobLoginSignHTML = function () {
    if(window.SysConfig.SystemType !=100){
        html.push("<div id='logQrcode'>"
		+ "<img style='width:100%;height:100%;cursor:pointer' src='../../../SYSA/skin/default/images/MoZihometop/mozilogin/qrcode.png' "
		+ "onmouseover='$ID(\"lgpopsign\").style.display=\"block\"' "
		+ "onmouseout='$ID(\"lgpopsign\").style.display=\"none\"' "
		+ "onclick='window.CLoginType(this)' lgstatus=0 id='lgstatusbox'></div>"
		+ "<div style='position:absolute;z-index:100;color:#61A9D4;line-height:28px;overflow:hidden;padding:0px;text-align:center;"
		+ "display:none;top:46px;right:76px;width:90px;height:28px;background:url(../../skin/default/img/lgtypepopbg.png);"
		+ "font-size:11px;' id='lgpopsign'>"
		+ "扫码登录</div>");
    }

    html.push("<div id='ScanfLoginDiv' style='display:none;position:absolute;width:100%;top:110px;bottom:3px;z-index:90;background-color:white;left:0px;'>");
    html.push("<table style='width:256px;border-collapse:collapse;margin:0 auto' align=center>");
    html.push("<tr><td id='phoneScanQR' style='padding-top:100px;padding-bottom:40px'>");

    html.push("<div style='width:240px;height:240px;border:0px solid #eee;margin:0 auto;overflow:hidden;background-position:center;background-repeat:no-repeat' id='loginQrCode'>");
    html.push("<div id='moblgtimeoutdiv' style='width:100%;height:100%;background:url(../../skin/default/img/transbg.png);overflow:hidden;background-size:100%100%;display:none'>");
    html.push("<div style='text-align:center;margin-top:70px;width:100%'>"
					+ "<span style='font-weight:bold; font-family:微软雅黑, 黑体; font-size:16px; color:#000;'>二维码已失效</span><div style='height:15px;overflow:hidden'>&nbsp;</div>"
					+ "<button style='background-color:#0F83C6;width:120px;height:30px;font-family:微软雅黑, 黑体; font-size:16px; color:white;border:0px;cursor:pointer' onclick='window.MobLgRefresh()'>点击刷新</button></div>");
    html.push("</div>");
    html.push("</div>");
    html.push("</td></tr>");
    html.push("<tr><td style='text-align:center;background: transparent url(../../skin/default/img/mozilogin/scanf.png) no-repeat 10px 16px;"
		+ ";font-size:16px;line-height:26px;padding:0px;height:36px;color:#aaa'  id='moblgbottomtxt'><div style='height:10px;overflow:hidden'></div>");
    html.push("<button style='border:0px;height:2px;background-color:transparent;width:35px' onfocus='this.blur()'>&nbsp;</button>"
		+ "打开 <span style='color:#1076ff;font-size:16px;'>信湖APP</span> 扫码登录</td></tr>");
    html.push("</table></div>");
}

window.MobTimerHwnd = 0;

window.MobLgRefresh = function () {
    window.MobLoginQrCodeRefresh();
    window.MobTimerHwnd = window.setTimeout(window.MobLoginWatch, 1000);
}

window.CLoginType = function (sbox) {
    var lgstatus = sbox.getAttribute("lgstatus") * 1;
    if (lgstatus == 0) {
        sbox.setAttribute("lgstatus", 1);
        sbox.src = "../../../SYSA/skin/default/images/MoZihometop/mozilogin/pccode.png";
        $ID("ScanfLoginDiv").style.display = "block";
        $ID("lgpopsign").innerHTML = "密码登录";
        $ID("moblgbottomtxt").innerHTML = "<div style='height:10px;overflow:hidden'></div>"
			+ "<button style='border:0px;height:2px;background-color:transparent;width:35px' onfocus='this.blur()'>&nbsp;</button>"
			+ "打开 <span style='color:#1076ff;font-size:16px;'>信湖APP</span> 扫码登录";
        $ID("moblgbottomtxt").style.backgroundImage = "url(../../../SYSA/skin/default/images/MoZihometop/mozilogin/scanf.png)";
        $ID("loginQrCode").style.height = "240px";
        window.MobLoginQrCodeRefresh();
        window.MobTimerHwnd = window.setTimeout(window.MobLoginWatch, 1000);
    } else {
        sbox.setAttribute("lgstatus", 0);
        sbox.src = "../../../SYSA/skin/default/images/MoZihometop/mozilogin/qrcode.png";
        $ID("ScanfLoginDiv").style.display = "none";
        $ID("lgpopsign").innerHTML = "扫码登录";
        if (window.MobTimerHwnd > 0) {
            window.clearTimeout(window.MobTimerHwnd);
            window.MobTimerHwnd = 0;
        }
    }
}

window.MobLoginQrCodeRefresh = function () {
    $ID("moblgtimeoutdiv").style.display = "none";
    app.ajax.regEvent("GetLoginQrCode");
    window.CurrMobLoginKey = app.ajax.send();
    //			Response.Write(VirPath + "SYSA/code2/view.asp?sn=view&data=" + data.URLEncode() + "&width=200&errorh=1&t=" + DateTime.Now.ToString().URLEncode());
    $ID("loginQrCode").style.backgroundImage = "url(" + window.SysConfig.VirPath + "SYSA/code2/view.asp?sn=view&data="
		+ encodeURIComponent(window.CurrMobLoginKey) + "&width=200&errorh=1&t=" + encodeURIComponent((new Date()).getTime() + "") + ")";
    //$ID("loginQrCode").style.backgroundSize="100% 100%"	
}

window.MobLoginWatch = function () {
    app.ajax.regEvent("MobLoginWatch");
    app.ajax.addParam("key", window.CurrMobLoginKey);
    var r = app.ajax.send();
    window.MobLoginWatchResult(r);
}

window.MobLoginWatchResult = function (r) {
    if (window.MobTimerHwnd > 0) { window.clearTimeout(window.MobTimerHwnd); } //防止调用重复
    //等待PC扫码
    if (r.indexOf("waitscanf") >= 0) {
        if (window.lastMobLoginWatchResult && window.lastMobLoginWatchResult.indexOf("waitsure") >= 0) {
            var box = $ID("lgstatusbox");
            box.setAttribute("lgstatus", 0);
            window.CLoginType(box)
        }
        window.MobTimerHwnd = window.setTimeout(window.MobLoginWatch, 1000);
        window.lastMobLoginWatchResult = r;
        return;
    }
    //移动端已经扫码，等待点击确认
    if (r.indexOf("waitsure") >= 0) {
        $ID("loginQrCode").style.background = "transparent url(../../skin/default/img/mobloginok.png) center center no-repeat";
        $ID("moblgbottomtxt").innerHTML = "<div style='color:#aaa;text-align:center;font-size:16px;'>扫描成功 !</div>"
							+ "<span style='color:#000;font-size:16px;'>请在</span> "
							+ "<span style='color:#3a83fb;font-size:16px;'>信湖APP</span> "
							+ "<span style='color:#000;font-size:16px;'>确认登录</span>";
        $ID("moblgbottomtxt").style.backgroundImage = "none";
        $ID("loginQrCode").style.height = "200px";
        window.MobTimerHwnd = window.setTimeout(window.MobLoginWatch, 1000);
        window.lastMobLoginWatchResult = r;
        return;
    }
    if (r.indexOf("execsure") >= 0) {
        DoLogin({ mobileloginkey: window.CurrMobLoginKey });
        window.lastMobLoginWatchResult = r;
        return;
    }

    //其它结果统统归为失效
    window.clearTimeout(window.MobTimerHwnd);
    window.MobTimerHwnd = 0;
    $ID("moblgtimeoutdiv").style.display = "block";
    window.lastMobLoginWatchResult = r;
    return;

}

function MacServerInit() {
    try {
        var service = $ID('locator').object.ConnectServer();
        service.Security_.ImpersonationLevel = 3;
        service.InstancesOfAsync($ID('foo').object, 'Win32_NetworkAdapterConfiguration');
    }
    catch (e1) {
    }
}

function foo_OnObjectReady(objObject) {
    if (objObject.MACAddress != null && objObject.MACAddress != "undefined") {
        if ($ID("MACAddr").value != "") { return; }
        $ID("MACAddr").value = objObject.MACAddress;
    }
}

//页面校验
function CheckJMG() {
    var jmgpwd = $ID("jmgpwd");
    if (jmgpwd) {
        var NT120Client = $ID("NT120Client");
        var guid = $ID("guid");
        var miyao = $ID("miyao");
        var inputjmg = $ID("inputjmg");
        var tishi = $ID("tishi");
        return CheckPWD(jmgpwd, NT120Client, guid, miyao, tishi);
    }
    var namestr = $ID("username").value;
    var pwdstr = $ID("password").value;
    app.ajax.regEvent("DoCheckJMG");
    app.ajax.addParam("username", $ID("username").value);
    app.ajax.addParam("password", $ID("password").value);
    app.ajax.encode();
    var r = app.ajax.send();
    switch (r) {
        case "0": $ID("tishi").children[0].innerHTML = ""; $ID("tishi").style.display = 'none'; return true;
        case "1": $ID("tishi").children[0].innerHTML = "用户名密码错误或账号已被冻结！"; $ID("tishi").style.display = ''; return false;
        case "2": $ID("tishi").children[0].innerHTML = "请输入正确的账号密码！"; $ID("tishi").style.display = ''; return false;
        case "200":
            if (app.getIEVer() > 11) {
                $ID("jmgou").innerHTML = "<div style='background-color:yellow;border:1px solid #ccc;padding:10px;margin-top:6px;border-radius:2px;color:red'>"
    			+ "当前浏览器不支持加密锁功能，请用<a style='color:blue' title='什么是IE浏览器？' href='https://baike.baidu.com/item/Internet%20Explorer' target=_blank >"
				+ "IE浏览器</a>访问。</div>";
                return false;
            }
            var htmls = [];
            htmls.push('<OBJECT classid=clsid:EA3BA67D-8F11-4936-B01B-760B2E0208F6 id=NT120Client name=NT120Client  STYLE="LEFT: 0px; TOP: 0px;display:none" width=50 height=50></OBJECT>');
            htmls.push('<span id="inputjmg">');
            htmls.push('<input id="jmgpwd" name="jmgpwd" onfocus="jmgFocusEvent(this);clearIconStatus(this)" onblur="jmgBlurEvent(this);clearIconStatus()" type="password" class="login_1" oncopy="return false" oncut="return false" onpaste="return false"/>');
            htmls.push('<input id="guid" name="guid" type="hidden" />');
            htmls.push('<input id="miyao" name="miyao" type="hidden" />');
            htmls.push('<span id="fa_p_password">请输入加密锁密码</span></span>');
            htmls.push('<span class="clearContentIcon" id="clearJmgPw">X</span></span>');
            $ID("jmgou").innerHTML = htmls.join("");
            var NT120Client = $ID("NT120Client");
            var inputjmg = $ID("inputjmg");
            var tishi = $ID("tishi");
            CheckData(NT120Client, inputjmg, tishi);
            //setTimeout(function () { $ID("jmgpwd").focus(); }, 100);//信湖中若初始获取焦点提示文本将消失
            $("#jmgpwd").bind("keydown", function (et) { if (et.keyCode == 13) { DoLogin(); } });
            return false;
        default:
            if (r.indexOf("input") != -1) {
                $ID("jmgou").innerHTML = r;
                $ID("jmgpwd").focus();
                var NT120Client = $ID("NT120Client");
                var inputjmg = $ID("inputjmg");
                var tishi = $ID("tishi");
                CheckData(NT120Client, inputjmg, tishi);
            } else {
                $ID("tishi").children[0].innerHTML = r;
                r ? $ID("tishi").style.display = '' : "";
            }
            return false;
    }
}

function OnlineSetup(inputjmg) {
    inputjmg.innerHTML = "<object CLASSID=clsid:EA3BA67D-8F11-4936-B01B-760B2E0208F6 CODEBASE='../../../SYSA/ocx/NT120Client.CAB#Version=1,00,0000' BORDER=0 VSPACE=0 HSPACE=0 ALIGN=TOP HEIGHT=0 WIDTH=0></object><input name='jmgpwd' type='password' class='login_1' oncopy='return false' oncut='return false' onpaste='return false'/><input id='guid' name='guid' type='hidden' /><input id='miyao' name='miyao' type='hidden' />"

}

function CheckPWD(jmgpwd, NT120Client, guid, miyao, tishi) {
    try {
        if (jmgpwd.value != "") {
            var rtn = NT120Client.NTFind();
            if (rtn != 0) {
                tishi.children[0].innerHTML = "没有找到加密锁！";
                tishi.style.display = '';
                return false;
            }
            else {
                var result = NT120Client.NTLogin(jmgpwd.value);
                if (result != 0) {
                    tishi.children[0].innerHTML = "加密锁密码错误！";
                    tishi.style.display = '';
                    return false;
                }
                else {
                    var GUID = NT120Client.NTGetHardwareID();
                    var Digesg = NT120Client.NTMD5(GUID);
                    guid.value = GUID;
                    miyao.value = Digesg;
                    return true;
                }
            }
        }
        else {
            tishi.children[0].innerHTML = "请输入加密锁密码！";
            tishi.style.display = '';
            return false;
        }
    }
    catch (e) {
        tishi.children[0].innerHTML = "加密锁组件加载失败！";
        tishi.style.display = '';
        return false;
    }
}

function SetJmgPWD(jmgpwdold, NT120Client, jmgpwdnew, tishi) {
    try {
        if (jmgpwdold.value != "" && jmgpwdnew.value != "") {
            var rtn = NT120Client.NTFind();
            if (rtn != 0) {
                tishi.children[0].innerHTML = "没有找到加密锁！";
                tishi.style.display = '';
                return false;
            }
            else {
                var result = NT120Client.NTLogin(jmgpwdold.value);
                if (result != 0) { tishi.children[0].innerHTML = "登录加密锁密码错误！"; tishi.style.display = ''; return false; }
                else {
                    var ret = NT120Client.NTSetUserPin(jmgpwdnew.value);
                    if (ret != 0) {
                        tishi.children[0].innerHTML = "加密锁组件加载失败！";
                        tishi.style.display = '';
                        return false;
                    }
                }
            }
        }
        else {
            tishi.children[0].innerHTML = "请输入加密锁密码！";
            tishi.style.display = '';
            return false;
        }
    }
    catch (e) {
        tishi.children[0].innerHTML = "加密锁组件加载失败！";
        tishi.style.display = '';
        return false;
    }
    return true;
}

function CheckJmgOnline(NT120Client, jmgpwd) {
    try {
        //查找NT120锁
        //top.document.title=(new Date()).getTime();
        var rtn = NT120Client.NTFind();
        if (rtn != 0) {
            //没有找到加密锁！;
            hWnds.DisableWindow();
            var curwin = hWnds.FindActiveWindow();
            setTimeout(DialogFun("-5", curwin, 1), 500);//未检测到加密锁
        }
        else {
            var result = NT120Client.NTLogin(jmgpwd);
            if (result != 0) {
                //登录加密锁密码错误！;
                hWnds.DisableWindow();
                var curwin = hWnds.FindActiveWindow();
                setTimeout(DialogFun("-6", curwin, 1), 500);//检测加密锁不匹配
            }
            else {
                //验证通过
                if (document.getElementById("sTimeroutAlertDiv")) {
                    document.getElementById("sTimeroutAlertDiv").style.display = "none";
                }
                hWnds.EnableWindow();
                setTimeout("CheckJmgOnline(NT120Client,jmgpwd)", 6000);
            }
        }
    }
    catch (e) {
        hWnds.DisableWindow();
        var curwin = hWnds.FindActiveWindow();
        setTimeout(DialogFun("-5", curwin, 1), 500);//未检测到加密锁
    }
}

function CheckJMGLogin(NT120Client, pwdstr) {
    if (NT120Client) {
        try {
            //查找NT120锁
            var rtn = NT120Client.NTFind();
            if (rtn != 0) {
                alert("没有找到加密锁！");
                top.window.location.href = window.SysConfig.VirPath + "sysn/view/init/login.ashx";
            }
            else {
                var result = NT120Client.NTLogin(pwdstr);
                if (result != 0) {
                    alert("加密锁密码错误！");
                    top.window.location.href = window.SysConfig.VirPath + "sysn/view/init/login.ashx";
                }
            }
        }
        catch (e) {
            alert("没有找到加密锁！");
            top.window.location.href = window.SysConfig.VirPath + "sysn/view/init/login.ashx";
        }
    }
}

$(window).resize(window.PageTimerProc);

window.onUpdateProc = function (ctype) {
    try { $ID("main_login_body").style.backgroundColor = (ctype == 1 ? "#0f83c6" : "white"); } catch (ex) { }
    try { $ID("white_space").style.display = (ctype == 1 ? "none" : "block"); } catch (ex) { }
    try { $ID("mb_cont").style.display = (ctype == 1 ? "none" : "block"); } catch (ex) { }
}

if (window.opener && screen.availWidth && screen.availWidth > 800) {
    window.moveTo(0, 0);
    window.resizeTo(screen.availWidth, screen.availHeight);
}

if (window.location.href.toLowerCase().indexOf("relogin.ashx") > 0) {
    var wnd = window.dialogArguments;
    if (!wnd) {
        wnd = parent;
    }
    if (wnd.RootOBJ) {
        wnd.RootOBJ.CurrentDialog = window;
        window.opener = wnd;
        wnd.reloginSign = 1;
    }
}