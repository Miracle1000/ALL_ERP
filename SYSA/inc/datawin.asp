<html style='margin:0px;padding:0px;overflow:auto'>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7">
<meta name="vs_targetSchema" content="http://schemas.microsoft.com/intellisense/ie5"/>
</head>
<!-- BUG.2601.binary.2013.10.10 通过该页面，隐藏URL. 该页面不要轻易添加回车，容易造成空文档节点 -->

<body style='margin:0px;overflow:auto;padding:0px;'><script type="text/javascript">
if (opener.currOpenNoUrl.toLowerCase().indexOf("printerresolve.asp") >= 0){
	window.location.href = opener.currOpenNoUrl;
}
document.write("<iframe id='frm' src='" + opener.currOpenNoUrl + "' style='width:100%;height:100%;background-color:white' onload='document.title=this.contentWindow.document.title' frameborder=0></iframe>");
</script>
<script>
<!--调用客户端接口-->
(async function () {
    await CefSharp.BindObjectAsync("zbDeskClientAPI");
    zbDeskClientAPI.batchPrint(window.location.origin, GetUrlQueryValue1("sort",opener.currOpenNoUrl), GetUrlQueryValue1("ord",opener.currOpenNoUrl));
})();
function GetUrlQueryValue1(queryName,urlStr) {
    var urlParamStr = urlStr.substring(urlStr.indexOf('?') + 1);
    var reg = new RegExp("(^|&)" + queryName + "=([^&]*)(&|$)", "i");
    var r = urlParamStr.match(reg);
    if (r != null) {
        return decodeURI(r[2]);
    } else {
        return null;
    }
}
</script>
</body></html>
