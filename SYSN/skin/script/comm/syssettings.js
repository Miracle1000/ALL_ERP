/*
    备注：系统设置js
    添加出处：SYSC/view/comm/SysSetting.ashx
    使用源：SYSN/skin/script/comm/syssettings.js 
*/
var SHome = new Object;

// Header的html
function CHeaderHtml() {
    var html = new Array();
    var left = parseInt((window.screen.width - 1200) / 2);
    var top = parseInt((window.screen.height - 780) / 2)-100;
    html.push("<div id='comm_itembarbg' style='display:" + (SHome.isTitleHide?"none":"") + "'>\n");
    html.push("<div id='comm_itembarICO'></div><div id='comm_itembarText' title='" + SHome.title + "'><span>" + SHome.title + "</span></div>\n");
    html.push("<div id='comm_itembarspc'></div>\n");
    html.push("</div>");
    html.push("<div id='comm_itembarbg2' style='margin-top:20px;'>\n");
    html.push("<div id='comm_itembarICO2'></div><div style='display:inline-block;position: relative'>");
    html.push("<a onclick='OnSearchEvent()' class='searchIco'>🔍</a>");
    html.push("<input onkeydown='EnterSearch()' type='text'  id='searchText' placeholder='请输入设置名称'/>");
    html.push("<input type='button' id='searchedBtn' value='搜索' onclick='OnSearchEvent()'/></div>\n");
    html.push("<button id='comm_itembarspc2' class='zb-button' onclick='window.open(\"../../../SYSN/view/init/guide/AttrSettingChildHome.ashx\",\"sysIntro\",\"width=1200px,height=780px,top="+ top +"px,left=" + left + "px,fullscreen =no,scrollbars=1,toolbar=0,resizable=1\")'>系统参数说明</button>\n");
    html.push("</div>");
    html.push("<div class='lnkgp_nav'>");
    html.push("<div class='lnkgp_hidden' style='height:10px;width:100%;'></div>");
    html.push("</div>");
    var menuslength = 0;
    document.write(html.join(""));
}

// 回车搜索
function EnterSearch() {
    var event = window.event || arguments.callee.caller.arguments[0];
    if (event.keyCode == 13) {
        OnSearchEvent();
    }
}

// 点击查询按钮进行搜索
function OnSearchEvent() {
    var MenuName = $("#searchText").val();
    $.ajax({
        type: "post",
        url: "SysSettings.ashx?MenuName=" + encodeURI(MenuName),//值传过去
        dataType: "html",
        success: function (html) {
            var str1 = html.split("window.PageInitParams[0]=")[1];
            var str2 = str1.split(";")[0]
            var data = eval(str2);
            CBodyHtml(data);
            BindOnResize();
        },
        error: function (data) {
            console.log(data);
        }
    });
}

//基础设置与自定义页面导航
function CBodyHtml(data) {
    var html = "";
    var linkV = 0;
    var linkhref = "";
    if (data.length > 0) {
        for (var i = 0; i < data.length; i++) {
            var gp_1 = data[i];
            html += "<div class='lnkgp_cont'>";
            html += "<div class='lnkgpheader'>";
            html += "<div class='group-fold_0'><img class='bill_group_eximg' id='bill_group_eximg_" + i + "' height='15' chang_flod='true' onclick='foldGroup(this)' title='点击折叠' src='" + window.SysConfig.VirPath + (SHome.sysType == 3 ? "SYSA/skin/default/images/MoZihometop/content/r_down.png" : "SYSA/images/r_down.png") + "'></div>";
            html += "<div class='group-title_1' isgroupobj='1'>" + gp_1.Title + "</div>";
            html += "</div>";
            if (gp_1.ChildMenus.length > 0) {
                for (var ii = 0; ii < gp_1.ChildMenus.length; ii++) {
                    var gp_2 = gp_1.ChildMenus[ii];
                    if (gp_2.Title == "生产设置(旧)") { continue; }
                    html += "<div class='lnkgp_cont_2'>";
                    html += "<div class='lnkgpheader'>";
                    html += "<div class='group-title'>" + gp_2.Title + "</div>";
                    html += "<div class='group-fold'><img class='bill_group_eximg' id='bill_group_eximg_" + ii + "' height='15' chang_flod='true' onclick='foldGroup(this)' title='点击折叠' src='" + window.SysConfig.VirPath + (SHome.sysType == 3 ? "SYSA/skin/default/images/MoZihometop/content/r_down.png" : "SYSA/images/r_down.png") + "'></div>";
                    html += "</div>";
                    if (gp_2.ChildMenus.length > 0) {
                        html += "<div class='lnkgplnks'>";
                        for (var iii = 0; iii < gp_2.ChildMenus.length; iii++) {
                            linkhref = "";
                            var lnk = gp_2.ChildMenus[iii];
                            if (lnk.Url) {
                                linkhref = lnk.Url;
                            }
                            html += "<div class='lnk'>";
                            if (linkhref != "") {
                                if (linkhref.indexOf("sysn/") >= 0 ) {
                                    linkhref = "sysn/" + linkhref.split("sysn/")[1]
                                } else if(linkhref.indexOf("SYSN/")>=0){
                                    linkhref = "sysn/" + linkhref.split("SYSN/")[1]
                                }else if (linkhref.indexOf("sysa/") >= 0) {
                                    linkhref = "sysa/" + linkhref.split("sysa/")[1]
                                } else if (linkhref.indexOf("SYSA/") >= 0) {
                                    linkhref = "SYSA/" + linkhref.split("SYSA/")[1]
                                }else {
                                    linkhref = "SYSA/" + linkhref.split("../")[1]
                                }
                                html += "<a href='javascript:;' onclick='javascript:app.OpenUrl(\"" + window.SysConfig.VirPath + linkhref + "\")'>" + lnk.Title + "</a>";
                            } else {
                                html += lnk.Title;
                            }
                            html += "</div>";
                        }
                        html += "</div>";
                    }
                    html += "</div>";
                }
            }
            html += "</div>";
        }
    }
    $('.lnkgp_nav').html(html);
}

// 当浏览器页面变化时，会出大BindOnResize函数
$(window).on("resize", BindOnResize);

// 折叠隐藏以及动态追加样式
function BindOnResize() {
    var _w = $('#comm_itembarbg2').width();
    $('.lnkgp_hidden').css("display", "none")
    $('.lnkgp_cont').css({ "width": _w - 20, "margin-top": 10, "margin-left": 10 });
    //$('.lnkgp_cont').css({ "width": _w - 20, "margin-top": 10 });
}

// 设置点击三级目录时弹出打开窗口
function openStatWin(url, sign) {
    window.open(url, 'newstat' + sign + 'win', 'width=' + 1000 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')
}

// 单据折叠以及伸缩
function foldGroup(box) {
    var c = 1;
    if (box.src.indexOf("r_down.png") > 0) {
        box.src = box.src.replace("r_down.png", "r_up.png");
        box.title = "点击展开";
        c = 1;
    } else {
        box.src = box.src.replace("r_up.png", "r_down.png");
        box.title = "点击折叠";
        c = 2;
    }
    var h = box.parentNode.parentNode;
    var cont = $(h).next('.lnkgplnks');
    var cont1 = $(h).next('.lnkgp_cont');

    if (c == 1) {
        $(cont).css("display", "none");
        $(cont1).css("display", "none");
    } else {
        $(cont).css("display", "block");
        $(cont1).css("display", "block");
    }
};

// createPage函数
window.createPage = function () {
    SHome.sysType = window.SysConfig.SystemType;
    SHome.Data = window.PageInitParams[0];
    SHome.isTitleHide = app.getRequestParamVal("isTitleHide") ? true : false;
    SHome.title = SHome.sysType == 3 ? "系统设置" : "系统参数设置";
    CHeaderHtml();
    CBodyHtml(SHome.Data);
    BindOnResize();
}

//悬浮工具栏
$(function () {
    var html = new Array();
    var titles = $("div.group-title_1");
    var x = 0;
    var titleObj, title;
    for (var i = 0; i < titles.length; i++) {
        titleObj = titles[i];
        title = titleObj.innerText.replace("设置","");
        if (titleObj.getAttribute("isgroupobj") == 1 && title) {
            html.push("<div class='item' onclick='ViewScrollTo(\"" + i + "\")'>" + title + "</div>");
            x++;
        }
    }
    var div = document.createElement("div");
    div.innerHTML = html.join("");
    div.id = "menugrouplink";
    document.body.appendChild(div);
})

function ViewScrollTo(index) {
    var box = $("div.group-title_1").length ? $("div.group-title_1")[index] : "";
    window.scrollTo(0, parseInt($(box).offset().top));
}