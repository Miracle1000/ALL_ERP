function JSONColor(jsCode) {
    jsCode = jsCode.replace(/\s\s\s\s\"/g, "    <span style='color:red'>\"")
    jsCode = jsCode.replace(/\":/g, "\"</span>:")
    jsCode = jsCode.replace(/:\s\"/g, ": <span style='color:#ff00ff'>\"");
    jsCode = jsCode.replace(/\"\,/g, "\"</span>,");
    jsCode = jsCode.replace(/\"\n/g, "\"</span>\n");
    return jsCode;
}
var defJSPath = window.location.href.split("?")[0];
if ( defJSPath.substr(defJSPath.length-1,1)=="/" ) {
    defJSPath = defJSPath + "default.ashx";
}
document.body.style.backgroundColor = "#ccc";
var iscc = window.SysConfig.SystemType == 100;
try {
	defJSPath = defJSPath.toLowerCase().split("/" +(iscc?"sysc":"sysn") + "/view/")[1].replace(".ashx", ".js");
} catch (ex) { }
document.write("<div style='margin:40px auto;width:900px;overflow:hidden;'>");
document.write("<div class='nodefalertdiv' style='border:1px solid #999;background:#e3e4e8;color:#880000;font:bold 22px 微软雅黑;padding:45px;text-shadow:4px 2px 4px #bbb'>呀！前小端太忙，没来得及渲染此页面......</div>");
document.write("<div class='nodefalertdiv' style='height:20px;'>&nbsp;</div>");
document.write("<div class='nodefalertdiv' style='margin:0px 0px;padding:15px 22px;background-color:#e3e4e8;border:1px solid #999;border-bottom:0px'><b>渲染方式</b></div>");
document.write("<div class='nodefalertdiv' style='background-color:white;border:1px solid #999;'><pre style='margin:0px 0px;padding:28px;line-height:20px'>");
document.writeln("请在该页面的外带js文件(即：<a href='javascript:void(0)'>" + (iscc ? "SYSC" : "SYSN") + "/skin/script/" + defJSPath + "</a>)中重定义window.createPage函数.\n如下所示：\n")
document.writeln("<span style='color:red'>window</span>.createPage = <span style='color:blue'>function</span>(){");
document.writeln("    <span style='color:#009900'>//此处编写渲染代码</span>");
document.writeln("    <span style='color:red'>document</span>.write(<span style='color:#ff00ff'>\" hello zbintel ! \"</span>);");
document.writeln("}");
document.write("</pre></div><br><br>");
document.write("<div style='margin:0px 0px;padding:15px 22px;display:block;background-color:#e3e4e8;border:1px solid #999;border-bottom:0px'><b>页面数据</b></div>");
document.write("<div style='background-color:white'><pre style='margin:0px 0px;padding:28px;display:block;border:1px solid #999;line-height:20px;'>");
for (var i = 0 ; i < window.PageInitParams.length; i++)
{
    document.writeln(" <span style='color:red'>window</span>.PageInitParams[" + i + "] = " + JSONColor(JSON.stringify(window.PageInitParams[i], null, 4)));
    if (i < window.PageInitParams.length - 1) { document.writeln(""); }
}
document.write("</pre></div><br><br><br></div>");