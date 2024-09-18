// CardLayout.Ui.currWidth =$('#comm_itembarbg').width()-20;
CardLayout.OnCardTopHtml = function (jpart) {
    // switch (jpart.dbname) {
    // }
}
CardLayout.OnCardItemHtml = function (jpart) {
    switch (jpart.dbname) {
        case "navContent": return GetBodyHtml(jpart);
        case "list": return GetListHtml(jpart);
        case "report": return GetListHtml (jpart);
    }
}
//生成右边的图标
function creatRightItem(cur) {
    var htm = [];
    if (cur.data.length > 0) {
        for (var j = 0, len = cur.data.length; j < len; j++) {
            if (!cur.data[j]) break;
            var itemdata = cur.data[j].mmolist;
            htm.push("<ul class=''>");
            for (var ii = 0; ii < itemdata.length; ii++) {
                var idata = itemdata[ii];
                var flag = idata.canclick;
                htm.push("<li class='item urlitem" + (flag ? "" : "Gray") + "' " + (flag ? "onclick=\"app.OpenUrl('" + idata.url + "')\"" : "") + ">");
                htm.push("<div class='imgItem'><img src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/navigation/" + idata.image + "'/></div>");
                htm.push("<div class='textItem'>" + idata.text + "</div>");
                htm.push("</li>");
            }
            htm.push("</ul>");
        }
    }
    return htm.join("");
}

function GetListHtml(obj) {
    var ary=obj.info.data.programs;
    var htm=[];
    htm.push("<ul class='nav_list'>");
    var num=0;
    for(var i=0,len=ary.length;i<len;i++){
        var cur=ary[i];
        num++;
        htm.push('<li class="list_item" title="'+(cur.title||'')+'" onclick="app.OpenUrl(\''+cur.url+'\')"><a href="javascript:;">'+cur.title+'</a></li>');
    }
    htm.push("</ul>");
    if(num==0){
        return "<div style='text-align: center;height:40px;line-height:40px;'>没有信息!</div>"
    }
    return htm.join("");
}
function GetBodyHtml(jpart) {
    var htm = [];
    var data = jpart.info.data||[];
    htm.push('<div class="tn_body">');
    htm.push('<div class="tn_box">');
    //生成圆和向下的箭头
    htm.push("<ul class='ul_out'>");
    for(var i=0;i<data.length;i++){
        var cur=data[i];
        if(!cur.data[0])break;
        htm.push("<li class='li_out'>");
        var hei=cur.data.length*90;
        var str="";
        htm.push("<div class='down_jt' style='"+(i==0?"height:5px;background:none":"")+str+"'>&nbsp;</div>");
        htm.push("<div class='containers items_container clearfix'><div class='item item_title color"+(i%5)+"' " + str + "><div class='text'>" + cur.title + "</div></div>" + creatRightItem(cur)+"</div>");
        htm.push("</li>");
    }
    htm.push("</ul>");

    htm.push('</div>');
    htm.push(' </div>');
    htm.push("<div style='border-top:0px solid #c0ccdd;background: #FFF;padding-top:40px;padding-bottom:10px'>");
    htm.push("<ul style='padding:5px 0;float:left;width:94px;height:53px;'>");
    htm.push("<li style='height:50px;border-right:0px solid #c0ccdd;padding-left:30px;color:#ccc'>温馨提示：</li>");
    htm.push("</ul>");
    htm.push("<ul>");
    htm.push("<li style='height:24px;line-height:24px;padding-left:10px;color:#ccc'>1、鼠标点击各个按钮可直接进行相应的操作；</li>");
    htm.push("<li style='height:24px;line-height:24px;padding-left:10px;color:#ccc'>2、图标为灰色时，表示没有此功能的操作权限。</li>");
    htm.push("</ul>");
    htm.push("</div>");
    return htm.join("");

}

window.onresizeSub=function () {
    try{
        var winW=document.documentElement.clientWidth||document.body.clientWidth;
        var per=0.78;
        var div=$ID("MainCard_R0_C0");
        var par=$ID("MainCard_R0");
        $('#MainCard').width("auto");
        $("#MainCard_R0").width("100%");
        var pW=$(par).width();
        var w=pW*per;
        //if(w<875){w=875}
        div.style.width=w+"px";
        $ID("MainCard_R0_C1").style.width=pW-w-20+"px";
        $ID("MainCard_R0_C1_C0").style.width="100%";
        if(navigator.userAgent.indexOf("MSIE")>-1){
            $("#pro_top_title").width($("body").width()-17)
        }

        if($(".item_title").length==0){$(".tn_box").height(20).html("没有信息！").css("text-align","center")}

    }catch (e){}

};
window.onresize=function () {

    window.onresizeSub()
};
$(window).on("load",function () {
    //左边的宽度正常情况下是972px;页面宽度是1166
    CardLayout.CResizeWidths=function(){};
    window.onresizeSub()


});
(function () {
    var htm=[];
    htm.push("<div id='pro_top_title'  class='pro_top_title'>");
    htm.push("<div class='pro_top_title_title'>生产导航</div>");
    htm.push("</div>");
    document.write(htm.join(""))
})()


