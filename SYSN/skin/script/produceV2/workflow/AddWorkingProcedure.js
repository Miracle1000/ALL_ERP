function ProshowDetailHtml(ord, canDetail, title, isdel)
{
    var htmlStr = title;
    var url = "";
    if (canDetail == "1") {
        if (isdel == 1) {
            url = "sysn/view/producev2/workcenter/AddWorkingCenter.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1";
        }
        else {
            url = "sysn/view/producev2/workcenter/AddWorkingCenter.ashx?ord=" + app.pwurl(ord) + "&view=details";
        }
        var htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:app.OpenUrl('";
        htmlStr += window.SysConfig.VirPath;
        htmlStr += url;
        htmlStr += "')\">" + title + (isdel == 1 ? "<span style=color:red>(已删除)</span>" : "") + "</a>";
    }
    return htmlStr
}