function frameResize() {
    document.getElementById("mxlist").style.height = I3.document.body.scrollHeight + 0 + "px";
}

function setFromType(obj) {
    var dataType = ""
    switch (designType) {
        case "1":
            dataType = "chance";
            break;
        case "2":
            dataType = "contract";
            break;
        case "3":
            dataType = "xunjia";
            break;
        case "4":
            dataType = "M_ManuOrders";
            break;
        default:
            break;
    }
    setFromId(dataType, 0, "", 0);
    $("#fromid").value(0);
    $("#fromname").thml("");
}

function getFromID() {
    var fromType = $("#fromtype").val();
    if (fromType == "0") {
        alert("请选择预购来源");
        return;
    }
    var url = "";
    switch (fromType) {
        case "1":
            url = "../event/result2.asp?act=yg";
            break;
        case "2":
            url = "../event/result2ht.asp?act=yg"
            break;
        case "3":
            url = "../event/result2xj.asp?act=yg"
            break;
        case "4":
            url = "../event/resultbill.asp?datatype=M_ManuOrders&act=yg";
            break;
        default:
            break;
    }
    if (url.length > 0) { window.open(url, 'yg', 'width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100'); }
}

function setFromId(dataType, ord, name, user, dataTypeName) {
    $("#fromid").val(ord);
    $("#fromname").val(name);
    $("#ywname").html(user);
    if (dataTypeName != "" && name != "") {
        $("#title").val("转自" + dataTypeName + "：" + name);
    } else {
        $("#title").val("");
    }
    var json = {};
    json.__msgid = "getMxListByOrder";
    json.dataType = dataType;
    json.ord = ord;
    var aj = $.ajax({
        type: 'post',
        url: 'getMxListByOrder.asp',
        cache: false,
        dataType: 'html',
        data: json,
        success: function (data) {
            $('#mxlist').attr('src', $('#mxlist').attr('src'));
        },
        error: function (data) { }
    });
}

function doSaveAdd(ord) {
    document.all.date.action = "save3_yg.asp?sort=2&ord=" + ord;
    beforeSave(ord);
}

function doSave(ord, isBatch) {
    document.all.date.action = "save3_yg.asp?ord=" + ord;
    if (isBatch&&isBatch == 1) {
        beforeSave(ord, 1);
        return;
    }
    beforeSave(ord);
}

function beforeSave(ord, status) {
    var fromobj = document.getElementById("demo");
    if (Validator.Validate(fromobj, 2) && DelUnusedFilesBeforeSubmit()) {
        var mxobj = document.getElementById("mxlist").contentWindow.document.getElementsByTagName("table")[0];
        if (mxobj.rows.length < 3) { alert('请添加产品明细！'); return false; }
        var moneyobj = document.getElementById("ygmoney");
        var bzobj = document.getElementById("bz");
        var json = {};
        json.ord = ord;
        json.money1 = moneyobj.value;
        var aj = $.ajax({
            type: 'post',
            url: 'checkMxListPrice.asp',
            cache: false,
            dataType: 'html',
            data: json,
            success: function (data) {
                if (data == "") {
                    fromobj.submit();//不需要审批
                } else if (data.indexOf("ok=") == 0) {
                    //document.getElementById("sptype").value = sort1;
                    if (status && status == 1) {
                        fromobj.submit();//待审批单据修改 不需要审批
                    }else {
                        var sort1 = document.getElementById("sort1").value;//--预购分类
                        if (sort1 == "") { sort1 = 0; }
                        spclient.GetNextSP('yugou', 0, moneyobj.value, sort1, 0, "", fromobj);
                    }
                } else if (data.indexOf("err=") == 0) {
                    alert(data.replace("err=", ""));
                }
            },
            error: function (e) {
                alert(e.responseText);
            }
        });
    }
}
