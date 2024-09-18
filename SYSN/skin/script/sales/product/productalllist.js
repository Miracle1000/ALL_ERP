window.onload = function () {
    var btns = $("#topareafieldtable").find("button");
    var btnJson = Report && Report.Data && Report.Data.commandbuttons ? Report.Data.commandbuttons : "";
    var htm = [],str="",bn;
    for (var i = 0; i < btns.length; i++) {
        var btn=btns[i];
        var text = btn.innerText;
        var index =text.indexOf("导入");
        for (var ii = 0; ii < btnJson.length; ii++) {
            var btnj = btnJson[ii]
            if (index > 0 && text == btnj.title) {
                htm.push("<option value='" + btnj.cmdkey.replace(/'/g, '"') + "'>" + text + "</option>");
                btn.style.display = "none";
            } else if (index == 0 && text == btnj.title) {
                bn = $(btn);
                $(btn).css({"margin":"0px"})
                str = "<option value=''>导入</option><option  value='" + btnj.cmdkey.replace(/'/g, '"') + "'>" + "产品导入" + "</option>";
                $(btn).wrap("<div id='doImports' style='width:auto;position:relative;display:inline-block;zoom:1;*display:inline;overflow:hidden;vertical-align:top;margin:1px 3.5px;'></div>")
            }
        }
    }
    var listHtml = "<select id='importSelectList' onclick=doImport(this) style='z-index:999999;opacity:0;filter: progid:DXImageTransform.Microsoft.Alpha(opacity=0);;position:absolute;height:22px;line-height:20px;left:0px;top:0px'>" + str + htm.join("") + "</select>"
    if (bn) { bn.after(listHtml) }
}
function doImport(dom) {
    var v = $(dom).val();
    $("#importSelectList").val("");
    if (!v) { return } else {
        eval(v);
    }
}

window.showPriceInfoDlg = function (srcbox) {
    var jObj = $(srcbox);
    var pid = jObj.attr('pid');
    var cateid = jObj.attr('cateid');


    var x = jObj.offset().left,                      // 当前横坐标
             y = jObj.offset().top,                       // 当前纵坐标
             sTop = $('body').scrollTop(),                   // 滚动条高度
             bodyHeight = $('body').prop('scrollHeight'),    // 页面实际高度
             curH = jObj.height(),                        // 当前元素的高度
             curToBottomH = bodyHeight - y - curH;           // 当前元素距离底部距离
    var cwidth = document.documentElement.clientWidth;
    var cheight = document.documentElement.clientHeight;

    var box = $("#popDiv");

    // 返回价格信息
    var url = window.SysConfig.VirPath + 'SYSA/product/priceInfoAjax.asp';
    $.post(url, { proID: pid, cateid: cateid }, function (data) {
        var div = document.getElementById("popDiv");
        if (div == null) {
            div = document.createElement("div");
            div.id = "popDiv";
            document.body.appendChild(div);
        }
        // 控制弹出层
        $('#popDiv').hide();
        $('#popDiv').html(data);
        var leftx = (x - 350 - 20 + $('#popDiv').width()) > cwidth ? (cwidth - $('#popDiv').width() - 20) : (x - 350 - 20);
        var topy = (y + curH + $('#popDiv').height()) > cheight ? (cheight - $('#popDiv').height() - 5) : (y + curH);
        $('#popDiv').css({ 'left': leftx, 'top': topy }).show();

        $('#popDiv.pop-close').click(function () {
            $('#popDiv').hide();
        });
        //
        var w = $('#popDiv #content3').width();
       if (w > 688) {
            $('#popDiv #listWrap').css('overflow-x', 'scroll');
       };
       $("#popDiv").click(function (e) {
           var evt = e || window.event;
           if (evt.stopPropagation) {
               evt.stopPropagation();
           }
           else {
               evt.cancelBubble = true;
           }
       });
       $("#popDiv a.pop-close").click(function () {
           $("#popDiv").hide();
       });
    });

    $("html,body").click(function () {
        $("#popDiv").hide();
    })
    $("body,#lvw_tbodybg_MainList").scroll(function () { $("#popDiv").hide(); })
}

