function dcshow(title, dc, kuid, kcnum, productord, ckid, unitid)
{
    return title + (dc == 1 ? '<a href="javascript:;" onclick="MyLinkHtml(' + kuid + ',' + kcnum + ',' + productord + ',' + ckid + ',' + unitid + ')" style="color:#5b7cae;"><img src=../../../../sysa/images/jiantou.gif />对冲</a>' : '')
}
function MyLinkHtml(kuid, kcnum, productord, ckid, unitid)
{

    app.OpenUrl(window.SysConfig.VirPath + 'SYSN/view/store/kuin/KuinchAdd.ashx?id=' + app.pwurl(kuid) + '&kcnum=' + kcnum + '&cpid=' + app.pwurl(productord) + '&ckid=' + app.pwurl(ckid) + '&unitid=' + app.pwurl(unitid) + '', kuid);
}