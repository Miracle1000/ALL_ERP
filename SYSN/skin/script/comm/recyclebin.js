/*
    备注：回收站js
    添加出处：SYSC/view/comm/RecycleBin.ashx
    使用源：SYSN/skin/script/comm/recyclebin.js 
*/
var SHome = new Object;

// Header的html
function CHeaderHtml() {
    var html = new Array();
    html.push("<div id='comm_itembarbg'>\n");
    html.push("<div id='comm_itembarICO'></div><div id='comm_itembarText' title='回收站'><span>回收站</span></div>\n");
    html.push("<div id='comm_itembarspc'></div>\n");
    html.push("</div>");
    html.push("<div id='comm_itembarbg2' style='margin-top:20px;'>\n");
    html.push("<div id='comm_itembarICO2'></div><div style='display:inline-block;position: relative'>");
    html.push("<a onclick='OnSearchEvent()'  class='searchIco'>🔍</a>");
    html.push("<input onkeydown='EnterSearch()' id='searchText' type='text' placeholder='请输入回收站名称'/>");
    html.push("<input class='leftNavBg' id='searchedBtn' type='button' value='搜索' onclick='OnSearchEvent()'/></div>\n");
    html.push("<div id='comm_itembarspc2'></div>\n");
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
        url: "RecycleBin.ashx?MenuName=" + encodeURI(MenuName),//值传过去
        dataType: "html",
        success: function (html) {
            var str1 = html.split("window.PageInitParams[0]=")[1];
            var str2 = str1.split(";")[0]
            var data = eval(str2);
            CBodyHtml(data);
            BindOnResize();
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
            var gp = data[i];
            html += "<div class='lnkgp_cont'>";
            html += "<div class='lnkgpheader'>";
            html += "<div class='group-title' isgroupobj='1' >" + gp.Title + "</div>";
            html += "<div class='group-fold'><img class='bill_group_eximg' id='bill_group_eximg_" + i + "' height='15' chang_flod='true' onclick='foldGroup(this)' title='点击折叠' src='" + window.SysConfig.VirPath + (SHome.sysType == 3 ? "SYSA/skin/default/images/MoZihometop/content/r_down.png" : "SYSA/images/r_down.png") +"'></div>";
            html += "</div>";
            if (gp.ChildMenus.length > 0) {
                html += "<div class='lnkgplnks'>";
                for (var iii = 0; iii < gp.ChildMenus.length; iii++) {
                    linkhref = "";
                    var lnk = gp.ChildMenus[iii];
                    if (lnk.Url) {
                        linkhref = lnk.Url;
                    }
                    html += "<div class='lnk'>";
                    if (linkhref != "") {
                        if (linkhref.indexOf("sysn/") >= 0) {
                            linkhref = "sysn/" + linkhref.split("sysn/")[1]
                        } else if (linkhref.indexOf("SYSN/") >= 0) {
                            linkhref = "SYSN/" + linkhref.split("SYSN/")[1]
                        } else if (linkhref.indexOf("sysa/") >= 0) {
                            linkhref = "sysa/" + linkhref.split("sysa/")[1]
                        } else if (linkhref.indexOf("SYSA/") >= 0) {
                            linkhref = "SYSA/" + linkhref.split("SYSA/")[1]
                        } else {
                            linkhref = "SYSA/" + linkhref.split("../")[1]
                        }
                        html += "<a href='javascript:;' onclick='javascript:app.OpenUrl(\"" + linkhref + "\")'>" + lnk.Title + "</a>";
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
    $('.lnkgp_nav').html(html);
}

// 当浏览器页面变化时，会出大BindOnResize函数
$(window).on("resize", BindOnResize);

// 折叠隐藏以及动态追加样式
function BindOnResize() {
    var _w = $('#comm_itembarbg').width();
    $('.lnkgp_hidden').css("display", "none")
    $('.lnkgp_cont').css({ "width": _w - 20, "margin-top": 10, "margin-left": 10 });
}

// 设置点击二级目录时弹出打开窗口
function openStatWin(url, sign) {
    window.open(url, 'newstat' + sign + 'win', 'width=' + 1000 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')
}

//单据折叠
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
    if (c == 1) {
        $(cont).css("display", "none");
    } else {
        $(cont).css("display", "block");
    }
};

// createPage函数
window.createPage = function () {
    SHome.sysType = window.SysConfig.SystemType;
    SHome.Data = window.PageInitParams[0];
    CHeaderHtml();
    CBodyHtml(SHome.Data);
    BindOnResize();
}

//悬浮工具栏
$(function () {
    var html = new Array();
    var titles = $("div.group-title");
    var x = 0;
    var titleObj,title;
    for (var i = 0; i < titles.length; i++) {
        titleObj = titles[i];
        title = titleObj.innerText;
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
    var box =$("div.group-title").length? $("div.group-title")[index]:"";
    window.scrollTo(0, parseInt($(box).offset().top));
}