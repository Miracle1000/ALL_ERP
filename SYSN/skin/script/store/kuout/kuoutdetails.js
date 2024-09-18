window.SerialNumberBoxHtml = function (field, datas, numbers) {
    var htm = [];
    htm.push("<span dbname='" + field.dbname + "' uitype='" + field.uitype + "' name='" + field.dbname + "' id='" + field.dbname + "' value='" + datas.SerialNumbers + "'>" + numbers[0]);
    field.typejson = field.typejson.replace("editable", "readonly");
    htm.push("<img name='serial' src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/percent100.png' onclick='Bill.openSerialNumberPage(" + field.typejson + ",$(this)," + datas.CreateType + ",\"" + encodeURIComponent(field.dbname) + "\"," + datas.SerialNumbers.split(',').length + "," + JSON.stringify(datas) + ")' alt='点击显示更多' style='margin-left:5px;width:12px;height:18px;cursor:pointer;' >");
    htm.push("</span>");
    return htm.join("");
}

//查看二维码
function OpenCode(str) {
    window.open(window.SysConfig.VirPath + "SYSA/inc/img.asp?url=" + escape(str) + "");
}