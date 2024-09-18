window.createPage = function () {
    //此处编写渲染代码
    var obj = window.PageInitParams[0];
    var htmls = [];
    htmls.push("<style>");
    htmls.push("#mxbody *{font-size:14px}  #mtab {margin-top:20px;width:100%;border-collapse:collapse} ");
    htmls.push("#mtab td, #mtab th{color:#000; border:1px dotted #aaa;padding:5px;} ");
    htmls.push("span.statbar {display:inline-block;color:#fff;padding:2px 5px; width:80px;text-align:center}");
    htmls.push("</style>");
    htmls.push("<div id='mxbody' style='width:700px;margin: 0 auto;padding-top:80px'>");
    htmls.push("<span style='font-size:22px;color:#000;font-family:微软雅黑'>系统Net子模块64位初始化设置</span>");
    htmls.push("<div style='border-top:1px dashed #ccc;margin-top:20px;height:20px'>&nbsp;</div>")
    htmls.push("<span style='color:#000'>当前web.config配置文件中，设置了<span style='color:red;'> appSettings.OpenNetModel64Bit=1</span>, 但是由于以下环境条件未满足，Net子模块64位模式未正常启用，仍需要手工配置解决以下环境问题。</span>");
    htmls.push("<table id='mtab'>")
    htmls.push("<tr><td style='width:70%;font-weight:bold'>环境项</td><td style='width:30%;font-weight:bold;text-align:center'>状态</td></tr>");
    htmls.push("<tr><td>SYSN/SYSC目录建立单独的应用程序池</td><td align=center >" + (obj.ExistsPool ? "<span class='statbar' style='background-color:#009900'>正常</span>" :"<span class='statbar'  style='background-color:#ff0000'>未建立</span>") + "</td></tr>");
    htmls.push("<tr><td>当前应用程序池32位</td><td align=center>" + (obj.Exists64BitPool ? "<span class='statbar' style='background-color:#009900'>正常</span>" : "<span class='statbar'  style='background-color:#ff0000'>未启用</span>") + "</td></tr>");
    htmls.push("<tr><td>启用redis会话模式</td><td align=center>" + (obj.OpenRedis ? "<span class='statbar' style='background-color:#009900'>正常</span>" : "<span class='statbar'  style='background-color:#ff0000'>未启用</span>") + "</td></tr>");
    htmls.push("</table>")
    htmls.push("<div style='padding-top:20px'><button class=button style='padding:5px 10px' onclick='window.location.reload()'>重新检测</button></div>");
    htmls.push("</div>");
    document.write(htmls.join(""));
}