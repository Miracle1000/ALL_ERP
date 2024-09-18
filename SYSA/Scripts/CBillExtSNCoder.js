window.BillExtSN = new Object();
window.BillExtSN.CodeType = 0;
window.BillExtSN.BHFieldID = "";
//初始化编号设置，  catchFields = "title,pym,cpsort"
window.BillExtSN.Reg = function (codeType,  bhField, isupdated) {
    window.BillExtSN.CodeType = codeType;
    window.BillExtSN.BHFieldID = bhField;
    if (!window.jQuery) { alert("window.BillExtSN.Reg方法依赖JQuery文件！"); return; }
    if (isupdated == true) { return; }
    window.BillExtSN.BeginAutoGetValue();
}

window.BillExtSN.ReBindEvt = function () {
    jQuery("input[type=text]").unbind("blur", window.BillExtSN.Refresh).bind("blur", window.BillExtSN.Refresh);
    jQuery("input[type=checkbox]").unbind("click", window.BillExtSN.Refresh).bind("click", window.BillExtSN.Refresh);
    jQuery("input[type=radio]").unbind("click", window.BillExtSN.Refresh).bind("click", window.BillExtSN.Refresh)
    jQuery("select").unbind("change", window.BillExtSN.Refresh).bind("change", window.BillExtSN.Refresh);
    jQuery("textarea").unbind("blur", window.BillExtSN.Refresh).bind("blur", window.BillExtSN.Refresh);
    window.BillExtSN.Refresh(null);
}

window.BillExtSN.BeginAutoGetValue = function () {
    jQuery(window.BillExtSN.ReBindEvt);
}



window.BillExtSN.Refresh = function (evt) {
    if (window.BillExtSN.BindKeys != undefined && window.BillExtSN.BindKeys.length == 0)  return;
    if (evt != null) {
        var obj = evt.target;
        if (obj.name == window.BillExtSN.BHFieldID || obj.id == window.BillExtSN.BHFieldID) {
            return;
        }
        var ks = ("," + (window.BillExtSN.BindKeys || "") + ",").toLowerCase();
        if (ks.indexOf("," + obj.name.toLowerCase() + ",") == -1 && ks.indexOf("," + obj.id.toLowerCase() + ",") == -1) {
            return;
        }
    }

    var data = [];
    var CatchFields = [];
    var frm = document.getElementsByTagName("form")[0];
    if (!frm) { return; }
    var boxs = jQuery(frm).serializeArray();
    for (var i = boxs.length - 1; i >= 0; i--) {
        if (i > 0 && boxs[i].name == boxs[i - 1].name) {
            boxs[i - 1].value = boxs[i - 1].value + "," + boxs[i].value;
            boxs[i].name = "";
        } else {
            var n = boxs[i].name;
            var box = document.getElementsByName(n)[0];
            if (box.tagName == "SELECT") {
                boxs.push({ name: boxs[i].name + "_selectvalue", value: (boxs[i].value + "") });
                boxs[i].value = box.options[box.options.selectedIndex].text;
            }
        }
    }
    for (var i = 0; i < boxs.length; i++) {
        var ibox = boxs[i];
        var n = ibox.name;
        if (n) {
            CatchFields.push(n);
            if (ibox.value.length < 200) { //200字限制
                data.push(n + "=" + encodeURIComponent(encodeURIComponent(ibox.value)));
            } else {
                data.push(n + "=");
            }
        }
    }
    data.push("__CatchFields=" + encodeURIComponent(CatchFields.join("|")));
    data.push("__BillTypeId=" + window.BillExtSN.CodeType);
    var xhttp = window.XMLHttpRequest ? (new XMLHttpRequest()):(new ActiveXObject("Microsoft.XMLHTTP"));
    xhttp.open("POST", ((window.sysCurrPath ? (window.sysCurrPath + "../") : window.SysConfig.VirPath) + "SYSN/view/comm/GetBHValue.ashx?GB2312=1"), false);
    xhttp.setRequestHeader("content-type", "application/x-www-form-urlencoded");
    xhttp.send(data.join("&"));
    var obj = eval("(" + xhttp.responseText + ")");
    window.BillExtSN.BindKeys = obj.keys;
    document.getElementById(window.BillExtSN.BHFieldID).value = "" + obj.code + "";
    if (window.BillExtSN.AfterRefresh) { window.BillExtSN.AfterRefresh();}
}

// SYSN/view/comm/GetBHValue.ashx




//document.onclick = function () {
 //   var t = window.event.srcElement;
 //   if (t.className != "place") { return; }
 //   window.BillExtSN.Refresh();
//}