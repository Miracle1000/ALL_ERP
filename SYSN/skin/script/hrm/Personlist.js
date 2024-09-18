function GetSelectid() {
    var tb = document.getElementById("tableid");
    var SelectIds = $("[name='selectid']");
    var ids = [];
    SelectIds.each(function () {
        if ($(this).attr("checked")) {
            ids.push($(this).val())
        }
    });
    if (ids.length == 0) {
        ids.push(0)
    }
    var url = "" + window.SysConfig.VirPath + "SYSA/code2/inc/getCode2.asp?c2type=2&selectid=" + ids.join(",")
    window.location.href = url;
}

function inExcel() {
    window.open(' '+ window.SysConfig.VirPath +'SYSN/view/hrm/PersonListImport.ashx', 'newload', 'width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=100,top=100')
}

//批量导入方法
function batchExcel() {
    window.open(' ' + window.SysConfig.VirPath + 'SYSN/view/hrm/PersonListBatchImport.ashx', 'newload', 'width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=100,top=100')
}

function UsertoPerson() {
    window.open('' + window.SysConfig.VirPath + 'SYSA/hrm/person_load.asp', 'newload', 'width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=100,top=100')
}


function batchPrint(isSum) {
    var selectid = document.getElementsByName("selectid");
    var ids = "";
    for (var i = 0; i < selectid.length; i++) {
        if (selectid[i].checked) {
            ids = ids + "," + selectid[i].value;
        }
    }
    ids = ids.replace(",", "");
    if (ids.length == 0) {
        alert("您没有选择任何信息，请选择后再打印！");
        return false;
    }
    ids = ids.split(",");
    if (ids.length > 50) { alert("选择的单据数量不要超过50个！"); return false; }
    window.OpenNoUrl('../Manufacture/inc/printerResolve.asp?formid=' + ids + '&sort=2001&isSum=' + isSum, 'newwin77', 'width=' + 850 + ',height=' + (screen.availHeight - 80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth - 850) / 2 + ',top=0')
}

function ButAdd() {
    window.open('' + window.SysConfig.VirPath + 'SYSA/hrm/personAdd.asp', 'newload', 'width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=100,top=100')
}