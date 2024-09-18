var boardData = new Object;
var _body = null;
var interval = null;


$(function () {
    PageLoad();
    _body = $("body");
    _body.css("zoom", boardData.actualboardscheme.multiple);
    SetSkins();
    $(".bottomdiv").hide();
    BindBtnFunc();
    $(document).keyup(function (e) {
        var keyCode;
        if (window.event) {
            keyCode = event.keyCode;
        } else if (e.which) {
            keyCode = e.which;
        }

        if (keyCode == 122)
            OnFullScreen($("#fullScreenTd img"));
    });

    //配置滚屏
    if (boardData.actualboardscheme.showtype == 1) {
        $("#tableMain").css("max-height", (parseInt($("body").css("height")) - 128).toString() + 'px');
        var div = document.getElementById("tableMain");
        IntervalConfig();
    } else {//配置翻页
        var timeout = boardData.actualboardscheme.timeout * (boardData.actualboardscheme.timeoutunit == 0
            ? 1000
            : 60000);

        interval = setInterval(function () {
            RowsLoad();
        },
            timeout);
    }
})

var tempScrollTop = 0;
var scrollv = 0;
var div = null;

var IntervalConfig = function () {
    if (div == null) div = document.getElementById("tableMain");
    if (scrollv == 0) scrollv = boardData.actualboardscheme.multiple < 1 ? Math.ceil(1.00 / boardData.actualboardscheme.multiple) : 1;
    interval = setInterval(function () {
        tempScrollTop = div.scrollTop;
		div.scrollTop += scrollv;
        if (div.scrollTop == tempScrollTop) {
            //滚屏模式下滚到底之后停顿30秒再刷新滚动
            window.clearInterval(interval);
            setTimeout(function () {
                //因为滚屏只需要重新渲染一下全部数据(第一页),所以此处直接改为页码0,在RowsLoad方法中会+1;
                boardData.searchinfo.pageindex = 0;
                RowsLoad();
                div.scrollTop = 0;
                IntervalConfig();
            }, 15000);
        }
    },
        boardData.actualboardscheme.rollspeed);
}

var PageLoad = function () {
    app.ajax.regEvent("PageLoad");
    app.ajax.addParam("schemeId", $("#SchemeSel_0").val());
    boardData = JSON.parse(app.ajax.send());
}

var RowsLoad = function () {
    var inDate = $(":text[name='InDate']");
    boardData.searchinfo.indate_0 = inDate.eq(0).val();
    boardData.searchinfo.indate_1 = inDate.eq(1).val();
    boardData.searchinfo.workshop = $("#WorkShop_0").val();
    boardData.searchinfo.wcenter = $("#WCenter_0").val();
    boardData.searchinfo.userid = $("#UserID_0").val();
    boardData.searchinfo.flag = $("#Flag_0").val();

    app.ajax.regEvent("RowsLoad");
    app.ajax.addParam("schemeId", boardData.actualboardscheme.id);
    app.ajax.addParam("pageIndex", boardData.searchinfo.pageindex + 1);
    app.ajax.addParam("updateTime", boardData.actualboardscheme.updatetime);
    app.ajax.addParam("InDate0", boardData.searchinfo.indate_0);
    app.ajax.addParam("InDate1", boardData.searchinfo.indate_1);
    app.ajax.addParam("WorkShop", boardData.searchinfo.workshop);
    app.ajax.addParam("WCenter", boardData.searchinfo.wcenter);
    app.ajax.addParam("UserID", boardData.searchinfo.userid);
    app.ajax.addParam("Flag", boardData.searchinfo.flag);
    var result = app.ajax.send();

    //判断返回结果是否有指示刷新当前页面
    //(如果当前方案不存在了, 则刷新当前页面(不带参), 否则带参重新加载页面)
    if (result == 'reload' || result == 'refresh' || result == 'reloadSearch') {

        if (result == 'reloadSearch') {
            $("#searchBtn").trigger("click");
            return;
        }

        var params = '';
        if (result == 'reload')
            params = '?schemeId=' + app.pwurl(boardData.actualboardscheme.id);
        window.location.href = window.SysConfig.VirPath +
            'SYSN/view/produceV2/ProduceBoard/ActualBoardNow.ashx' +
            params;
        return;
    }

    boardData = JSON.parse(result);
    $("#tableMain tbody").html(boardData.innerhtml);

    $("#lastRefreshTd span").html(boardData.lastrefreshtime);
}

var OnSearch = function () {
    boardData.searchinfo.pageindex = 0;
    RowsLoad();
}

var OnOpenDetail = function (waid) {
    app.OpenUrl(window.SysConfig.VirPath +
        'sysn/view/producev2/WorkAssign/WorkAssignDetail.ashx?ord=' +
        waid +
        '&view=details');
}

//设置皮肤
var SetSkins = function () {
    _body.prop("class", "style" + boardData.actualboardscheme.skins);
}

var BindBtnFunc = function () {
    $("body").on("click", "#saveSchemeBtn", function () {
        var schemeId = $("#SchemeSel_0").val();
        window.location.href = window.SysConfig.VirPath + 'SYSN/view/produceV2/ProduceBoard/ActualBoardNow.ashx?schemeId=' + app.pwurl(schemeId);
    });

    $("body").on("click", "#searchBtn", function () {
        OnSearch();
    });
}

var SetUrgent = function (waid) {
    app.ajax.regEvent("SetUrgent");
    app.ajax.addParam("waid", waid);
    app.ajax.send();
    window.location.href = window.SysConfig.VirPath + 'SYSN/view/produceV2/ProduceBoard/ActualBoardNow.ashx?schemeId=' + app.pwurl(boardData.actualboardscheme.id);
}

var setTitle = function () {
    var workShopVal = $("#WorkShop_0 option:checked").val();
    var wCenterVal = $("#WCenter_0 option:checked").val();
    var workshop = $("#WorkShop_0 option:checked").html();
    var wcenter = $("#WCenter_0 option:checked").html();

    if (workShopVal == 0)
        workshop = '';

    if (wCenterVal == 0)
        wcenter = '';

    $(".searchDiv_title").html(workshop + wcenter + "实时看板");
}

var OnFullScreen = function (_this) {
    var src = _this.prop("src");
    var isFullScreen = _this.attr('isFullScreen');
    if (isFullScreen == "1") {
        exitFullscreen();
        _this.attr('isFullScreen', '0');
        _this.attr('src', src.replace(/close/, "open"));
        setTitle();
        $(".searchDiv_child").show();
        $(".searchDiv_child_left").show();
        $(".searchDiv_child_right").show();
        $(".searchDiv_title").hide();
        //因全屏会导致高度变化,所以需要重新调整高度
        setTimeout(function () {
            $("#tableMain").css("max-height", (window.screen.availHeight - 128).toString() + 'px');
        },
        300);
        return;
    }

    handleFullScreen();
    _this.attr('isFullScreen', '1');
    _this.attr('src', src.replace(/open/, "close"));
    setTitle();
    $(".searchDiv_child").hide();
    $(".searchDiv_child_left").hide();
    $(".searchDiv_child_right").hide();
    $(".searchDiv_title").show();
    $("#editbody").attr("style", "");
    //因全屏会导致高度变化,所以需要重新调整高度
    setTimeout(function () {
        $("#tableMain").css("max-height", (window.screen.availHeight - 128).toString() + 'px');
    },
        300);
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