window.onTreeViewNodeClick = function (eobj) {
    $ID("bodyurlpage").src = "../../../SYSA/hrm/personList.asp?orgid=" + eobj.node.id;
}