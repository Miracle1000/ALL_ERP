
function CommonException(message, code) {
    this.message = message;
    this.code = code;
}

window.OnFieldAutoCompleteCallBackBreak = function (obj, inputs) {
    var val = obj.value;
    var ret = false;
    var dbname = obj.keys.dbname;
    var cell = $("td[autocompleSignKey=\"" + dbname + "\"]")[0];
    var inpname = cell.attributes.dbname.textContent;
    if (typeof (inpname) == "undefined") { inpname = ""; }
    if (inpname.indexOf("_company_") > -1) {
        var lvw = window["lvw_JsonData_companylist"];
        if (lvw) {
            if (lvw.rows.length > 0) {
                for (var i = 0; i < lvw.rows.length; i++) {
                    if (lvw.rows[i].length > 1) {
                        var khord = lvw.rows[i][1].fieldvalue;
                        if (khord + "" == val + "") {
                            var tip = '请不要重复选择同一个客户';
                            ret = true;
                            break;
                        }
                    }
                }
            }
        }
    }
    return ret;
}
