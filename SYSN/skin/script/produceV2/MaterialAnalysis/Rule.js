window.OnFieldAutoCompleteCallBackBreak = function (obj, inputs) {

    var val = obj.value;
    var ret = false;
    var dbname = obj.keys.dbname;
    var cell = $("td[autocompleSignKey=\"" + dbname + "\"]")[0];
    var inpname = cell.attributes.dbname.textContent;
    if (typeof (inpname) == "undefined") { inpname = ""; }
    if (cell.getAttribute("uitype") == "linkbox" && obj.value.length>0) {
        var objvalues = "," + obj.value + ",";
        if (objvalues.indexOf(",0,") > -1) {
            inputs[0].value = "0";
            inputs[0].setAttribute("texts", "全部仓库");
            if (inputs[1]) inputs[1].value = "全部仓库";
        } else {
            inputs[0].value = obj.value;
            inputs[0].setAttribute("texts", obj.text.replace(/\s/g, "~?"));
            if (inputs[1]) inputs[1].value = obj.text.split(" ").join(",");
        }
        ret = true;
       
    }
    return ret;
}
