/*
*obj后台json
*总刷新时间，间隔刷新时间，单据数据id
*/
//定义变量初值
var dOuter = null;
var billContainer1 = null;
var billContainer2 = null;
var scrollContainer = null;
var pageType, obj1, lastScrollHttp, timer = null, chartsImgCloneObj = {},refreshlvwTimer=null;
//{ id: "ProgressLvw", recordtime: time, totaltime: 600000, intertime: 2000, orderid: ["227", "242", "253", "254", "255", "256", "257", "261", "262", "268", "269", "278", "279", "281", "283", "289", "290", "291", "292", "300", "301", "322", "325", "326", "336", "338", "339", "341", "342", "344", "345"] }

//listview列表刷新；

function beginRefreshOrderDetails() {
    var indexii = obj1.carouselCount;
    $("#BillTitleSelect_0").val(obj1.orderid[indexii])
    window.recordCount0 = obj1.carouselCount;
    obj1.callbacktype = "refreshOrderDetails";
    obj1.eventElementType = "dispatchEvent";
    if ($("#BillTitleSelect_0")[0].fireEvent) {
        lastScrollHttp = $("#BillTitleSelect_0")[0].fireEvent("onchange")
    }
    else {
        var ev = document.createEvent("HTMLEvents");
        ev.initEvent("change", false, true);
        lastScrollHttp = $("#BillTitleSelect_0")[0].dispatchEvent(ev);
    }
}

app.ajax.onResultHandled = function () {
    if (obj1.eventElementType == "eventSources") { window.scrollLeftBySelect(); }
    if (!obj1.callbacktype) { return; }
    switch (obj1.callbacktype) {
        case "refreshOrderDetails":
            setTimeout(completeRefreshOrderDetails, 10);
            obj1.callbacktype = "";
            break;
        default:
            obj1.callbacktype = "";
            break;
    }
}

function completeRefreshOrderDetails() {
    if (obj1.isCarouselScroll) { moveLeftOrRight(); } else { obj1.isCarouselScroll = true; obj1.carouselCount = obj1.count; }
    var lvw = window["lvw_JsonData_" + obj1.id];
    if (!lvw) { return; }
    var pagesizes = Math.ceil(lvw.page ? lvw.page.recordcount / 10 : 1);
    var speed = parseInt(obj1.intertime / pagesizes);
    if (pagesizes > 1) {
        obj1.CurrDetailsListview = lvw;
        obj1.CurrDetailsSpeed = speed;
        refreshlvwlist();
    }
}

function refreshlvwlist() {
    var jlvw = obj1.CurrDetailsListview;
    ___RefreshListViewByJson(jlvw);
    jlvw.page.startpos = jlvw.page.startpos ? jlvw.page.startpos : 0;
    if (jlvw.page.startpos >= jlvw.rows.length - (10 - 1)) {
        if (refreshlvwTimer) { clearTimeout(refreshlvwTimer) }
        return;
    }
    jlvw.page.startpos = jlvw.page.startpos ? (jlvw.page.startpos + 10 - 1) : (10 - 1);
    refreshlvwTimer = setTimeout(function () { UpdateResetChartUI(obj1);refreshlvwlist() }, obj1.CurrDetailsSpeed);
    
}

//500毫秒内防止重复点击；
window.execfun = function (fun) {
    if (fun.runing) {
        return;
    }
    fun.runing = true;
    fun();
    setTimeout(function () { fun.runing = false }, 300);
}

//大刷新控制
window.mainTimerTick = function () {
    if (obj1.pageType) { return; }
    var isordermshover = obj1.isOrderMouseHover;  //是不是单据鼠标悬浮状态
    var isselectmshover = obj1.isSelectMouseHover;  //是不是下拉框选鼠标悬浮
    var isoncallback = obj1.callbacktype ? 1 : 0;
    var isEmptyTruns = obj1.stopAutoScrollExe;

    if (isordermshover || isselectmshover || isoncallback || isEmptyTruns) {
        window.setTimeout(mainTimerTick, obj1.intertime);
        return;
    }
    obj1.stopAutoScrollExe = false;
    try {
        obj1.TickCount++;
        if (obj1.TickCount % obj1.totalPlus == 0) {
            $("#RefreshBtn").trigger("click");
        }
        else {
            obj1.isMoveTORight = false;
            MoveToCarouselPos(obj1.carouselCount + 1);
            beginRefreshOrderDetails();
        }
    } catch (ex) {
        console.log("mainTimerTick.Error:" + ex.message);
    }
    window.setTimeout(mainTimerTick, obj1.intertime);
}


window.OrderClick = function ($dom) {
    if (obj1.pageType) {
        return;
    }
    var id = $dom[0].id, indexm;
    for (var j = 0; j < obj1.orderid.length; j++) {
        if (id == obj1.orderid[j]) {
            indexm = j; break;
        }
    }

    obj1.count = obj1.carouselCount;
    obj1.carouselCount = indexm;
    obj1.isCarouselScroll = false;
    beginRefreshOrderDetails();
}

window.InitGlobalAttr = function () {
    pageType = app.FindUrlParam(window.location.href, "pagetype") == 4 ? true : false;
    obj1 = window.jsonObj;
    obj1.totaltime = obj1.totaltime ? obj1.totaltime : 600000;   //页面级刷新
    obj1.intertime = obj1.intertime ? obj1.intertime : 10000;     //单据滚动间隔
    obj1.totalPlus = parseInt(obj1.totaltime / obj1.intertime);
    obj1.TickCount = 0;
    obj1.recordtime = new Date(new Date()).getTime();
    obj1.pageType = pageType;
    obj1.count = 0;
    obj1.charts = chartsImgCloneObj;
    obj1.carouselCount = 0;
    obj1.isCarouselScroll = true;
    obj1.isMoveTORight = false;
    obj1.isResetCarouselStyle = isResetCarouselStyle();
    if (!pageType) {
        obj1.CurrDetailsListview = window["lvw_JsonData_ProgressLvw"];
        var lvw = obj1.CurrDetailsListview;
        var pgs = Math.ceil(lvw.page ? lvw.page.recordcount / 10 : 1);
        obj1.CurrDetailsSpeed = parseInt(obj1.intertime / pgs);
    }
}

window.BindEvents = function () {
    //listview列表翻页刷新;
    if (!pageType) { refreshlvwlist() }
    //按钮点击事件；
    $("div#leftbtn").click(function () { window.execfun(leftBtnClick) });
    $("div#rightbtn").click(function () { window.execfun(rightBtnClick) });

    //单据绑定鼠标悬浮事件；
    $("div.orderForm").mouseenter(function () {
        $(this).addClass("hover");
        $(this).siblings().removeClass("hover");
        obj1.isOrderMouseHover = true;
        if (obj1.pageType) { clearInterval(timer); }
    });

    $("div.orderForm").mouseleave(function () {
        $(this).removeClass("hover");
        obj1.isOrderMouseHover = false;
        if (obj1.pageType) { workShopScroll(); }
    });

    $("div.orderForm").click(function () {
        window.OrderClick($(this));
    });
    $("div#selectList select").mouseenter(function () {
        obj1.isSelectMouseHover = true;
    })
    $("div#selectList select").mouseleave(function () {
        obj1.isSelectMouseHover = false;
    })
    if (obj1.pageType) { if (timer) {clearTimeout(timer) }; workShopScroll() }
}

function selectMouseChange(status) {
    if (status) { obj1.isSelectMouseHover = true; } else {
        obj1.isCarouselScroll = true;
        obj1.eventElementType = "eventSources";
        /*window.scrollLeftBySelect();*/
        obj1.isSelectMouseHover = false;
    }
}


//dom元素初始化；
window.triggerRefreshInitDom = function () {

    scrollContainer = $ID('carousel')
    billContainer1 = $ID('orderCarousel');
    billContainer2 = $ID('orderCarousel2');
    if (!isResetCarouselStyle()) {
        billContainer2.innerHTML = billContainer1.innerHTML;
        billContainer2.style.width = billContainer1.style.width;
        scrollContainer.style.marginLeft = "0px";
    }
    $(billContainer1).children().eq(0).addClass("hover");
    //构建json结构；
    window.InitGlobalAttr();

    window.BindEvents();
    window.setTimeout(mainTimerTick, obj1.intertime); //开定时器
}

//页面初始化加载
window.onload = function () {
	triggerRefreshInitDom();
}

//委外/派工/订单定义左侧按钮点击函数
function leftBtnClick() {
    obj1.isMoveTORight = false;
    if (obj1.callbacktype == "btnclicking" && !obj1.pageType) { return; }
    obj1.callbacktype = "btnclicking";
    MoveToCarouselPos(obj1.carouselCount + 1);
    if (obj1.pageType) { moveLeftOrRight() } else {
        moveLeftOrRight(function () {
            beginRefreshOrderDetails();
            obj1.callbacktype = "";
        });
    }
}

function rightBtnClick() {
    obj1.isMoveTORight = true;
    if (obj1.callbacktype == "btnclicking" && !obj1.pageType) { return; }
    obj1.callbacktype = "btnclicking";
    MoveToCarouselPos(obj1.carouselCount - 1);
    if (obj1.pageType) { moveLeftOrRight() } else {
        moveLeftOrRight(function () {
            beginRefreshOrderDetails();
            obj1.callbacktype = "";
        });
    }
}

function MoveToCarouselPos(newpos) {
    var len = obj1.orderid.length;
    if (obj1.isResetCarouselStyle) {
        newpos = newpos < 0 ? (len - 1) : (newpos > (len - 1) ? 0 : newpos);
    } else {
        newpos = newpos < 0 ? (len - 1) : (newpos > len ? 1 : newpos);
    }
    obj1.carouselCount = newpos;
}

//轮播向左移动；
function moveLeftOrRight(completefun) {
    var len = obj1.orderid.length;
    var newIndex = obj1.carouselCount;                // 假如有10个： 范围 0 ~  10   ---0000000 （3）
    var domIndex = (obj1.domCarouselCount || 0);       // 假如有10个： 范围 0 ~  10   --00000000 （2）
    if (len.length == 0) {
        return;
    }
    if (obj1.isResetCarouselStyle) {
        updateResetCaStyleDomUI(newIndex);
    } else {
        obj1.stopAutoScrollExe = true;
        if (obj1.isMoveTORight && newIndex == len - 1) { scrollContainer.style.marginLeft = -len * 290 + "px"; }
        if (!obj1.isMoveTORight && (newIndex == 1 || 0)) { scrollContainer.style.marginLeft = 0 + "px"; }
        var newleft = (-newIndex) * 290 + "px";
        //document.title = "Tc=" + obj1.TickCount + ";domI=" + domIndex + ";newI=" + newIndex + ";len=" + len;
        obj1.domCarouselCount = newIndex;
        domUIUpdate()
        $(scrollContainer).animate(
            {
                marginLeft: newleft
            },
            function () {
                obj1.stopAutoScrollExe = false;
                if (!obj1.isMoveTORight && newIndex == len) {
                    scrollContainer.style.marginLeft = "0px";
                }
                if (obj1.isMoveTORight && newIndex == 0) { scrollContainer.style.marginLeft = -len * 290 + "px"; }
                if (completefun) { completefun(); }
            });
    }
}

function domUIUpdate() {
    if (!obj1.isMoveTORight) {
        if (obj1.carouselCount == obj1.orderid.length) { $(billContainer1).children().eq(0).addClass("hover").siblings().removeClass("hover") } else {
            $(billContainer1).children().eq(obj1.carouselCount).addClass("hover").siblings().removeClass("hover");
        }
    } else {
        if (obj1.carouselCount == 0) { $(billContainer2).children().eq(0).addClass("hover").addClass("hover").siblings().removeClass("hover") } else {
            $(billContainer2).children().eq(0).addClass("hover").removeClass("hover")
            $(billContainer1).children().eq(obj1.carouselCount).addClass("hover").siblings().removeClass("hover")
        }
    }
}

function updateResetCaStyleDomUI(dex) {
    $(billContainer1).children().eq(dex).addClass("hover").siblings().removeClass("hover");
}

//车间轮播;
function workShopScroll() {
    if (!obj1.pageType) { return; }
    //leftBtnClick();
    timer = setInterval(function () {
        leftBtnClick();
    }, obj1.intertime)
}

//选择框回调底部滚动；
window.scrollLeftBySelect = function () {
    var selId = document.getElementById("BillTitleSelect_0");
    if (!selId) { return; }
    var value = selId.value;
    for (var i = 0; i < obj1.orderid.length; i++) {
        if (value == obj1.orderid[i]) {
            obj1.carouselCount = i;
            completeRefreshOrderDetails();
            break;
        }
    }
}

//单据总长度短;轮播图背景轮播；
function isResetCarouselStyle() {
    var viewArea = document.documentElement.clientWidth || document.body.clientWidth;
    var scrollArea = scrollContainer.style.width.replace("px", "");
    if (scrollArea / 2 > (viewArea - 100)) { return false } else { return true; }
}

var OnFullScreen = function (_this) {
	var u = navigator.userAgent;
	if (/Mac OS/i.test(u) && /safari/i.test(u) && window.top.location.href != window.location.href) {
		window.open(window.location.href,'_blank')
	}
    var src = $(_this).prop("src");
    var isFullScreen = $(_this).attr('isFullScreen');
    if (isFullScreen == "1") {
        exitFullscreen();
        $(_this).attr('isFullScreen', '0');
        $(_this).attr('src', src.replace("p_closescreen_1.png", "p_fullscreen_1.png"));
        $("table.headline td div.headline").removeClass("title_fullscreen")
        return;
    }

    handleFullScreen();
    $(_this).attr('isFullScreen', '1');
    $(_this).attr('src', src.replace("p_fullscreen_1.png", "p_closescreen_1.png"));
    $("table.headline td div.headline").addClass("title_fullscreen")
}

//调用各个浏览器提供的全屏方法
var handleFullScreen = function () {
    var de = document.documentElement;

    if (de.requestFullscreen) {
        de.requestFullscreen();
    } else if (de.mozRequestFullScreen) {
        de.mozRequestFullScreen();
    } else if (de.webkitRequestFullScreen) {
        de.webkitRequestFullScreen();
    } else if (de.msRequestFullscreen) {
        de.msRequestFullscreen();
    }
    else {
        alert("当前浏览器不支持全屏！");
    }

}

//调用各个浏览器提供的退出全屏方法
var exitFullscreen = function () {
    if (document.exitFullscreen) {
        document.exitFullscreen();
    } else if (document.mozCancelFullScreen) {
        document.mozCancelFullScreen();
    } else if (document.webkitExitFullscreen) {
        document.webkitExitFullscreen();
    }
}

$(function () {
    $("body").on("change", ":radio[name='BillTypeRadio']", function () {
        var value = $(":radio[name='BillTypeRadio']:checked").val();
        $("[name='grapdiv']").hide();
        $("#grap" + value).show();
    });
})

//统计图宽度自适应,内容随翻页更新;
window.OnBillchartGraphLoad = function (obj) {
    chartGraphShowItems(obj, chartsImgCloneObj);
    if (!obj.autoScreen) {//设置统计图不同分辨率下宽度;
        chartGraphAutoZoom(obj);
        obj.autoScreen=1;
    }
}

function chartGraphAutoZoom(jsonObj) {
    if(!jsonObj||!jsonObj.type){return;}
    var type=app.FindUrlParam(window.location.href, "pagetype")*1
    var w = window.screen.width;
    switch (type) {
        case 4:
            var fields = jsonObj.fieldobject ? jsonObj.fieldobject : "";
            if (!fields) { return; }
            var daname = fields.dbname||"";
            var chartBar = fields.uiskin || "";
            var widthArr = [];
            if (w > 2000) {
                widthArr = [1200, 1200, 1200, 1200];
                setChartWidth(widthArr);
            } else if (w > 1800) {
                widthArr = [1000, 800, 800, 1060];
                setChartWidth(widthArr);
            } else if (w > 1560) {
                widthArr = [800, 700, 700, 900];
                setChartWidth(widthArr);
            } else if (w > 1300) {
                widthArr = [700, 560, 560, 700];
                setChartWidth(widthArr);
            } else {
                widthArr = [700, 500, 500, 700];
                setChartWidth(widthArr);
            }
            break;
        default:
            if (w > 2000) { jsonObj.width = 1200 } else
                if (w > 1800) { jsonObj.width = 800 } else
                    if (w > 1560) { jsonObj.width = 700 } else
                        if (w > 1300) { jsonObj.width = 600 } else { jsonObj.width = 560 }
            break;
    }

    function setChartWidth(arr) {
        if (arr.length < 4 || !arr) { return;}
        daname.toLocaleLowerCase() == "chartgraph" && chartBar == "bar" ? jsonObj.width = arr[0] : "";
        daname.toLocaleLowerCase() == "chartgraphline" && chartBar == "line" ? jsonObj.width = arr[1] : "";
        daname.toLocaleLowerCase() == "chartgraphpie" && chartBar == "annularpie" ? jsonObj.width = arr[2] : "";
        daname.toLocaleLowerCase() == "chartgrapharealine" && chartBar == "arealine" ? jsonObj.width = arr[3] : "";
    }
}

function chartGraphShowItems(json,chartsobj) {
    var type = app.FindUrlParam(window.location.href, "pagetype");
    if (type != 4) {
        if (json.treedatas.nodes.length>10) {
            chartsobj["DatasClone_" + json.type] = app.CloneObject(json.treedatas.nodes, 2);
            json.treedatas.nodes = json.treedatas.nodes.slice(0, 10);
            json.treedatas.nodescount = json.treedatas.nodes.length;
            chartsobj["fieldsClone_" + json.type] = app.CloneObject(json, 2);
            }
        }
}

//统计柱状堆积数量更新
function UpdateResetChartUI(obj) {
    var lvw = obj.CurrDetailsListview;
    var startpos = lvw.page.startpos;
    var typeArr=["stackbar","bar"]
    for (var i = 0; i < typeArr.length;i++){
        var type = typeArr[i];
        var datas = obj.charts["DatasClone_" + type];
        var field = obj.charts["fieldsClone_" + type];
        if (obj.charts && datas) {
            var lastpos = datas.length - 10 ;
            starpos = startpos >= lastpos ? lastpos : startpos;
            field.treedatas.nodes = datas.slice(starpos, startpos + 10);
            window.ChartImages.Colors.ItemFillColors = field.fieldobject.uiforgraph.itemfillcolors.split(",").slice(0, 7);
            var html = ChartImages.GetHtml(field);
            $("div.chart_graph_box#chart_" + field.fieldobject.dbname).html(html);
        }
    }
}

/*
*ie78下vml绘制的图像回调显示不出来，重新获取dom重新复制，后期要优化到框架中，本次先针对看板处理（框架处理注意html children的层级，这里只处理一层）
*/
window.reDrawVmlCharts = function (groups) {
    for (var i = 0; i < groups.length; i++) {
        var group = groups[i];
        var filelds = group.fields;
        for (var ii = 0; ii < filelds.length; ii++) {
            var fd = filelds[ii];
            if (fd.uitype == "htmlfield") {
                for (var iii = 0; iii < fd.children.length; iii++) {
                    var child = fd.children[iii];
                    if (child.uitype == "chartgraph") {
                        if (!$ID(fd.dbname + "_fbg")) { continue; }
                        $ID(fd.dbname + "_fbg").innerHTML = $ID(fd.dbname + "_fbg").innerHTML;
                        break;
                    }
                }
            }
        }
    }
}
