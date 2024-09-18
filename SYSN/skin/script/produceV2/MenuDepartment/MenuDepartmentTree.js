function Getlinktitle(NodeText, NodeId, fullpath, BaseID) {
    if (BaseID == '1') {
        return ("<a href='javascript:void(0)' onclick='doOrgsSel(" + NodeId + ",\"" + fullpath + "\")'>" + NodeText + "<a>");
    } else {
        return ("<span style='color:#aaa'>" + NodeText + "</span>");
    }
}

function doOrgsSel(id, fullpath) {
    Report.FieldAutoCompleteCallBack(id, window.event.srcElement.innerHTML, { "fullpath": fullpath });
}