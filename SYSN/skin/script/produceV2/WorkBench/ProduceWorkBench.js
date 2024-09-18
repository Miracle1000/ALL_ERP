function GetTitle(title)
{
    if (title == '待完成')
    { return '<span style="color:red">' + title + '<span>' }
    else { return '<span>' + title + '<span>' }
}

$(function () {
    if ($("[dbname=aaaaa_ProduceOrder_0_5]") && $("[dbname=aaaaa_ProduceOrder_0_5] a")) {
        $("[dbname=aaaaa_ProduceOrder_0_5]").append("<div title='待完成订单包含：（1）未完全生成订单的物料分析结果（2）未完全生成订单的排产分析结果（3）未完全生成订单的生产计划'>" + $("[dbname=aaaaa_ProduceOrder_0_5] a").text() + "</div>");
        $("[dbname=aaaaa_ProduceOrder_0_5] a").remove();
    }
});

//function IsOrNotZero(CompleteType, Number,ColName)
//{
//    if (CompleteType == 2 && Number == 0) {
//        return '<span style="color:gray">' + Number + '<span>'
//    }
//    else { return '<a href="javascript:void(0)" onclick="Bill.ShowThroughLinkPage(this,"'+ColName+'")" class="throughlink">' + Number + '</a>' }
//}

CardLayout.OnCardTopHtml = function (jpart) {
    /**
     * linkgroup
     produceworkbench.js?ver=3178:17 prevent
     produceworkbench.js?ver=3178:17 mattergroup
     produceworkbench.js?ver=3178:17 workAssignpart
     produceworkbench.js?ver=3178:17 ComReportgroup
     */
    switch (jpart.dbname) {
        case "linkgroup": return GetEnterTopHtml(jpart);
        case "mattergroup":
            if (jpart.topbar) {
                return "<div class='date_box_par' ><table id='dateBoxParBox'><tr><td style='border:0;padding:0' class='fcell sub-title' billfield=1 uitype='" + jpart.topbar.uitype + "'>" + Bill.GetFieldHtml(jpart.topbar) + "</td></tr></table></div>";
            }
    }
}
function GetEnterTopHtml(jpart) {
    var htm = [];
    var sel = jpart.topbar[0].source.options;
    htm.push("<div class='select' onclick='ShowOption()'>");
    htm.push("<span class='selected'>"+ (sel.length>0?sel[0].n:"") +"</span>");
    if(sel.length>0){
        htm.push("<div class='select_dom'>");
        htm.push("<div class='sel_border_top'></div>");
        htm.push("<div class='sel_border_left'></div>");
        htm.push("<div class='sel_border_cont'><ul>");
        for(var i=0;i<sel.length;i++){
            htm.push("<li onclick='SearchSelect(this)' value='"+ sel[i].v +"'>"+ sel[i].n +"</li>");
        }
        htm.push("</ul></div>");
        htm.push("<div class='sel_border_right'></div>");
        htm.push("<div class='sel_border_bottom'></div>");
        htm.push("</div>");
    }
    htm.push("</div>");
    return htm.join("");
}
function SearchSelect(box) {
    var v=box.getAttribute("value");
    $(".selected").html(box.innerHTML);
    app.ajax.regEvent("linkgroupCallBack");
    app.ajax.addParam("value", v);
    app.ajax.send(function(r) {
        app.OpenUrl(r)
    });
}
function ShowOption(){
    if($('.select_dom').css('visibility') == "visible"){
        $('.select_dom').css('visibility','hidden');
        $(".selBg").remove();
    }else{
        $('body').append("<div class='selBg'></div>");
        $('.select_dom').css('visibility','visible');
    }
    $('.selBg').click(function(e){
        $('.select_dom').css('visibility','hidden');
        $(this).remove();
    })
}
//加载内容
CardLayout.OnCardItemHtml = function (jpart) {
    switch (jpart.dbname) {
        case "linkgroup"://
            return GetEnterItemHtml(jpart);
        case "prevent":
            return GetWarningItemHtml(jpart);
        case "preventnotice":
            return GetNoticeItemHtml(jpart);
        case "ComReportgroup":
            return GetCommonBillHtml(jpart);
        case "mattergroup":
            return GetMatterHtml(jpart)
    }
}
//本日事项
function GetMatterHtml(jpart) {
    return "<div style='height:50px;line-height:50px;text-align: center;color:red'>"+(jpart.info.data||"")+"</div>"
}
//生产进入
function GetEnterItemHtml(obj) {
    var data=obj.info.data;
    var htm=[];
    if(data.length>0){
        htm.push("<ul class='top1_con'>");
        for(var i=0,len=data.length;i<len;i++){
            var cur=data[i];
            htm.push('<li onclick="app.OpenUrl(\''+(window.SysConfig.VirPath+cur.linkurl)+'\')" '+(i==len-1?' style="background:none"':'')+'>');
            htm.push("<div class='top1_con_inner'>");
            htm.push("<div class='top1_con_inner_img_par'><img class='top1_con_inner_img' src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/station/"+cur.ico+".png' alt=''></div>");
            htm.push("<div class='top1_con_txt'>"+cur.title+"</div>");
            htm.push("</div>");

            htm.push("</li>");
        }
        htm.push("</ul>");
    }else{
        htm.push("<div class='nodata'>无权限进行添加，请赋予各栏目添加权限</div>")
    }
    return htm.join("")
}
//生产预警
function GetWarningItemHtml(obj) {
    var htm=[];
    var data=obj.info.data;
    var lD=data[0];
    var rD = data[1];
   // htm.push("<button id ='PreReferesh_btn' display:none onclick='PreReferesh()'><button>");
    htm.push("<div class='top2_item left'>");
    htm.push("<ul>");
    for(var i=0,len=lD.length;i<len;i++){
        var cur=lD[i];
        htm.push("<li class='top2_box'>");
        htm.push('<div class="top2_ico" ' + (i == 2 ? 'id="setChangeSpan"' : '') + ' style="cursor:' + (cur.canclick ? 'pointer' : 'default') + ';background-image: url(' + window.SysConfig.VirPath + 'SYSN/skin/default/img/station/' + cur.color + '.png)"' + (cur.canclick ? ' onclick="app.OpenUrl(\'' + window.SysConfig.VirPath + cur.url + '\',null,null,\'afv_existssql\')"' : '') + '>' + cur.info + '</div>')
      //  htm.push("<div class='' " + (i == 2 ? "id='setChangeSpan'" : "") + " style='cursor:pointer;background-image: url(" + window.SysConfig.VirPath + "SYSN/skin/default/img/station/" + cur.color + ".png);' onclick='app.OpenUrl(\'" + () + "\',)'>" + cur.info + "</div>");
        htm.push("<div class='top2_txt'><span >"+cur.title+"</span>"+(cur.canset?"<span onclick='showWorkTip(event,"+app.GetJSON(cur.suspend)+")' class='notice_set'><img src='"+ window.SysConfig.VirPath + "SYSN/skin/default/img/station/set.png' alt=''></span>":"")+"</div>");
        htm.push("</li>");
    }
    htm.push("</ul>");
    htm.push("</div>");
    htm.push("<div class='top2_item right'>");
    htm.push("<ul>");
    for(var i=0,len=rD.length;i<len;i++){
        var cur=rD[i];
        htm.push('<li class="item'+i+(cur.canclick?'':' gray')+'"  '+(cur.canclick?'onclick="app.OpenUrl(\''+(window.SysConfig.VirPath+cur.url)+'\')"':'')+' >'+cur.text+'</li>');
    }
    htm.push("</ul>");
    htm.push("</div>");
    return htm.join("")
}
function showWorkTip(e, o) {
    e=e||window.event;
    var tar=e.target||e.srcElement;
    var t=$(tar).offset().top+30;
    var l=$(tar).offset().left+30;
    var div=document.getElementById("work_station_tip");
    if(!div){
       div=document.createElement("div");
       div.id="work_station_tip";
       document.body.appendChild(div);
       var str="";
        str+="<div class='toparea'>" + o.title + "</div>";
        str+=("<ul class='top2_set_box'>");
        str+=("<li class='top2_set_box_body'><div style='width:160px;margin: 0 auto;float: none'>");
                str+="<div>" + o.textbefore + "</div>";
                str += ("<div><input class='billfieldbox ' id='setDayInp' value = '" + (o.text) + "'  uitype='intbox' min=0 max='" + o.textmax + "' type='text'/></div>");
                str+=("<div>" + o.textbehind + "</div>");
        str+=("</div></li>");
        str+=("<li><div style='width:108px;margin:0 auto'><input onclick='saveSet()' type='button' class='zb-button' value='保存'/>&nbsp;<input type='button' class='zb-button' onclick=\"document.getElementById('work_station_tip').style.display='none'\" value='关闭'/></div></li>");
        str+=("</ul>");
        div.innerHTML=str;
    }
  
    if(!window.hasBindBodyEvent){
        $("body").find("input.billfieldbox[uitype='intbox']").unbind("blur input propertychange",app.InputVerifyAtOnce).bind("blur input propertychange", app.InputVerifyAtOnce);
        window.hasBindBodyEvent=true;
    }
    $(div).css({
            "left":l,
            "top":t
         }).toggle();
}
function saveSet() {
    var btn=document.getElementById("setDayInp");
    var v=btn.value*1;
    var max=btn.getAttribute("max")*1;
    if(v<0){alert("亲，天数不能少于0");return}
    if(v>max){alert("亲，天数不能大于"+max);return}
    app.ajax.regEvent("SaveNoticeData");
    app.ajax.addParam("day", v);
    app.ajax.send(function(r) {
        var obj = eval("(" + r + ")");
        if(obj.success){
            $("#setChangeSpan").html(obj.result);
            $("#setDayInp").val(obj.text);
        }
        alert(obj.message);
        $("#work_station_tip").hide()
    });

}
//通知
function GetNoticeItemHtml(obj) {
    var htm=[];
    var topBar=obj.topbar;
    htm.push("<div class='toparea notice_top'>");
    htm.push("<div class='notice_top_left'>");
    htm.push("<span class='notice_bold'>"+topBar.title+"</span>");
    if(topBar.canadd){
        htm.push("<span>(<span style='color:red;cursor:pointer' onclick='app.OpenUrl(\"" + (window.SysConfig.VirPath + topBar.number.url) + "\",null,null,\"existssql\")'>" + topBar.number.text + "</span>)</span>");
        htm.push("<span style='color:#aaa;margin-left: 10px'>"+(topBar.remark||"")+"</span>");
        htm.push('<span class="notice_add" style="*margin-top:-28px" onclick="app.OpenUrl(\''+topBar.addurl+'\')">');
            htm.push("<img src='"+ window.SysConfig.VirPath + "SYSN/skin/default/img/station/add.png' alt=''>");
        htm.push("</span>");
    }
    htm.push("</div>");
    htm.push("</div>");
    var data=obj.info.data;
    var items=data.data;
    var url=data.dturl;
    htm.push("<div class='top2_rigth_top'>");
    var flag;
    for(var i=0,len=items.length;i<len;i++){
      if(items[i].ico){flag=true;break}
    }
    htm.push("<ul class='top2_rigth_top_left' "+(flag?"style='width:70%'":"")+">");
    for(var i=0,len=items.length;i<len;i++){
        if(i==5)break;
        var cur=items[i];
        htm.push('<li onclick="app.OpenUrl(\''+(window.SysConfig.VirPath+url+'?view=details&ord='+cur.value)+'\')"><div class="notice_item_left"><a href="javascript:;">'+(cur.text||"")+'</a></div>'+(cur.ico?'<div style="line-height:14px;"><img style="vertical-align: middle;margin-bottom:-12px;" src="'+window.SysConfig.VirPath+'SYSN/skin/default/img/station/bgico.png" alt=""></div>':'')+'</li>')
    }
   
    htm.push("</ul>");
    if (items.length == 0) {
        htm.push("<div style='text-align: center;color:red;height:50px;line-height:50px;'><img src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/ico_main_nodate.gif' style='padding-top:40px;' alt=''></div>")
    }
    if(items.length>0){
        htm.push("<ul class='top2_rigth_top_left right'>");
        for(var i=0,len=items.length;i<len;i++){
            if(i==5)break;
            var cur=items[i];
            htm.push('<li>');
            if(cur.ico){
                htm.push('<div class="notice_item_left">');
                var btn=cur.handelbtn;
                htm.push('<input type="button" class="zb-button" value="'+btn.text+'"  onclick="app.OpenUrl(\''+(window.SysConfig.VirPath+btn.url)+'\')">');
                htm.push('</div>');
            }
            htm.push('</li>');
        }
        htm.push("</ul>");
    }

    htm.push("</div>");
    if(len>5){
        htm.push('<div class="notice_more"><span style="cursor:pointer"  onclick="app.OpenUrl(\'' + (window.SysConfig.VirPath + data.more.url) + '\',null,null,\'existssql\')">更多</span><span>>></span></div>')
    }
    return htm.join("")
}
//常用报表
function GetCommonBillHtml(obj) {
    var htm=[];
    var data=obj.info.data.linklist;
    for(var i=0,len=data.length;i<len;i++){
        var cur=data[i];
        var bgImg="style='background-image: url("+ window.SysConfig.VirPath + "SYSN/skin/default/img/station/bluet.png);'";
        switch(i){
            case 1: bgImg="style='background-image: url("+ window.SysConfig.VirPath + "SYSN/skin/default/img/station/oranget.png);'";break;
            case 2: bgImg="style='background-image: url("+ window.SysConfig.VirPath + "SYSN/skin/default/img/station/redt.png);'";break;
            case 3: bgImg="style='background-image: url("+ window.SysConfig.VirPath + "SYSN/skin/default/img/station/greent.png);'";break;
        }
        htm.push("<div class='bill_item'>");
        htm.push("<div class='bii_item_box box"+i+"'>");
        htm.push("<div class='bill_item_top' "+bgImg+">"+cur.title+"</div>");
        htm.push("<ul >");
        var ary=cur.linkclasslist;
        for(var j=0;j<ary.length;j++){
            var curr=ary[j];
            htm.push('<li onclick="app.OpenUrl(\''+(window.SysConfig.VirPath+curr.linkurl)+'\')" class="bill_item_bill"><a>'+curr.title+'</a></li>')
        }
        htm.push("</ul>");
        htm.push("</div>");
        htm.push("</div>");
    }
    return htm.join("")
}
//计算通知部分li的长度
$(function () {

    setInterval("PreReferesh()", 1000*300);
    $(".notice_item_left").each(function () {
        var w=this.scrollWidth
        if(navigator.userAgent.indexOf("MSIE")>-1) {
            if (w > 180) {
                this.style.width = 150 + "px"
            }
        }else{
            if (w> 200) {
                this.style.width = 200 + "px"
            }
        }

    })
    $(window).on("scroll",function () {
        var div=document.getElementById("work_station_tip");
        if(div){
            div.style.display="none"
        }
    })
//控制下拉框弹出部分的高度
    var height = $('.sel_border_cont').height();
    $(".sel_border_left").css("height",height);
    $(".sel_border_right").css("height",height);
    $("body").append("<div class='list_item_layout'></div>");
    $("#dateBoxParBox").find("input").each(function () {
        this.onchange = function () {
            var val=this.value;
            if(val.replace(/ /g,"")=="")return;
            if(!/^(\d{1,4})(-|\/)(\d{1,2})\2(\d{1,2})$/.test(val)){alert("请输入正确的日期格式");return;}
            CardLayout.CCallBack({"date":val})
        }

    })
    $("#dateBoxParBox").find("input.billfieldbox[uitype='datebox']").unbind("blur focus  input propertychange", app.InputCheckDate).bind("blur focus  input propertychange", app.InputCheckDate);

})


function PreReferesh()
{
    CardLayout.CCallBack({
        type: "PreReferesh"
    })
}
$(function () {
    var w=$("body").width();
    if(w<=190*4){
        $(".bii_item_box").each(function (index,item) {
             var ww=w/4-50;
            this.style.width=ww+"px";
            $(".bill_item_top").eq(index).width(ww)
        })
    }
    setTimeout(ProcMatterGroupLvwForWorkBench,300)
})

function ProcMatterGroupLvwForWorkBench(){
	$("#lvw_tablebg_aaaaa").css("overflow-x","auto");
	if(app.IeVer == 7){ ListView.SetlvwHeightWithIESuit("aaaaa")};
}
