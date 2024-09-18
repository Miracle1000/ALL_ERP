window.leftBarLinks = [];
window.treeObj = null;
window.uizoom=top.uizoom?top.uizoom:1;//页面缩放比例
window.activeBarIdx=window.top.leftNavIndex?window.top.leftNavIndex:0;
window.sysTypeIsMoZi=window.top.SysConfig&&window.top.SysConfig.SystemType==3?true:false;//判断系统类型
window.top.PageInitParams && window.top.PageInitParams[0]&&(leftBarLinks = window.top.PageInitParams[0].LeftLinkBars);

//创建左侧导航html
window.createNavHtml=function(){
  var t=sysTypeIsMoZi,dat="";
  var navHtml=creatLeftNavHtml();
  dat = "";
  //导航
  dat += "  <div id=\"leftMuneNav\">"
  dat += "    <div id=\"leftMune\">"
  dat+=   "      <ul class=\"leftmune\"" + (leftBarLinks.length * 44 > (leftBarLinks[0]["ChildMenus"].length+1) * 45 ? " home-data-step='1'" : "") + ">"+ navHtml.leftNav1 +"</ul>";
  dat+= "    </div>"
  var version = "";
  try { version = window.top.document.getElementsByName("version")[0].getAttribute("content"); } catch (e) { }
  dat += t ? "    <div id=\"verisonNum\"><span title=\"点击查看版本详情\" id=\"verlinkbox\" onclick=\"top.window.ShowAutoMeDlg()\">" + version.slice(1, version.length) + "</span></div>" : 
          "<div id='commUsed'  home-data-step='2' used-data-step='1' title='常用' onclick='showMyComNav()'><div class='nav_icon'><img src='../skin/default/images/leftNav/cused.png'></div><h1>常用</h1></div>";
  dat += "    <div id=\"muneMainNav\">"
  dat += "       <div class='menuPanel menuPanel1'" + (leftBarLinks.length * 44 > (leftBarLinks[0]["ChildMenus"].length + 1) * 45 ? "" : " home-data-step='1'") + ">" + navHtml.leftNav2 + "</div>"
  dat+=   "    </div>"
  dat+=   "  </div>"
  dat+=   "  <div class=\"munePage\">"+(t?"":creatCommNav())+"</div>";
  return dat;
}

//生成左侧一级(html)和二级导航(html2)的html;
function creatLeftNavHtml() {
    if (!leftBarLinks || !leftBarLinks.length) {return { leftNav1: "", leftNav2: "" } }
  var html = [],html2 = [];
  for (var i = 0; i < leftBarLinks.length; i++) {
    var nav1 = leftBarLinks[i];
    var tit = nav1.Title;
    var childs = nav1.ChildMenus;
    if ((sysTypeIsMoZi && tit == "账号"||tit == "参数设置" || tit == "更多") && !nav1.Parentid) {continue;}    
    html.push(creatLeftNavLiBar(nav1,i))//创建一级导航html
    html2.push(creatLeftNavLiItem(childs,i))//创建二级导航html
  }
    var topBar = "<div class='foldNav' id='leftNavFoldIcon' " + (sysTypeIsMoZi ? " onclick='pickup(this)' title='收起左侧导航'" : " onclick='pickUpNav(this)' title='收起左侧导航'") + ">" + getNavBarTitleHtm() +
                "<div id='foldBorder'></div>"+
                "<div class='fold'>"+
                  "<span class='foldIcon'></span>"+
                "</div>"+
              "</div>"
  
  html2 = topBar + html2.join("")
  return {leftNav1:html.join(""),leftNav2:html2}
}

//左侧一级导航bar
function creatLeftNavLiBar(obj,idx){//v,id,i,icon;
  var str='';
  str = "<li id='bar_" + obj.ID + "' data-index='0_" + idx + "' class='" + (activeBarIdx==idx?"navActived":"") +"'>"
    if (sysTypeIsMoZi) {
        str +=
            "<div class='nav_icon icon" + idx + "'>" +
            "<img class='" + (idx == activeBarIdx ? "hiddenImg" : "") + "' src='../skin/default/images/MoZihometop/leftNav/" + (obj.Ico ? obj.Ico : "01.png") + "'>" +
            "<img class='" + (idx == activeBarIdx ? "" : "hiddenImg") + "' src='../skin/default/images/MoZihometop/leftNav/" + (obj.Ico ? obj.Ico.replace("0", "") : "1.png") + "'>" +
            "</div>"
    } else {
        str += "<div class='nav_icon'>" +
            "<img class='" + (idx == activeBarIdx ? "hiddenImg" : "") + "' src='../skin/default/images/leftNav/" + (obj.Ico ? obj.Ico : "01.png") + "'>" +
            "<img class='" + (idx == activeBarIdx ? "" : "hiddenImg") + "' src='../skin/default/images/leftNav/" + (obj.Ico ? (obj.Ico.replace(".png","") + "_s.png") : "01_s.png") + "'>" +
            "</div>"
    }
  str +=    "<h1>" + (obj.Title || "") + "</h1>"+
          "</li>";
  return str; 
}

//左侧二级导航
function creatLeftNavLiItem(childs,idx){
  var isTJ=idx&&leftBarLinks[idx].Title=="统计"?true:false;//统计做特殊处理
  var str="<ul class='muneMainNav" + (activeBarIdx==idx?"":" hidden") + "'>";
  for(var j=0;j<childs.length;j++){
      var child = childs[j];
      var title = (child.Title || "")
      title = !window.sysTypeIsMoZi && title.length > 5 ? (title.slice(0, 4) + "<br>" + title.slice(4, title.length)) : title
      str += "<li id='bar_" + child.ID + "' data-index='0_" + idx + "-1_" + j + "' " + (isTJ ? "onclick='scrollToColumn(this)'" : "onclick='updatePanel(this)'") + ">" +
            "<h1>" + title +(sysTypeIsMoZi ? "<div class='arrow_icon_div'><span class='arrow_icon'></span></div>":"")+
            "</h1>"+
           "</li>";    
  }
  str+="</ul>";
  return str
}

//获取二级导航顶部标题
function getNavBarTitleHtm(){
  if(!window.sysTypeIsMoZi){
      return "<span id='showNavTitleBar'>" + "" + "</span>"
  }else{
    return  "<span id='showNavTitleBar'>" + leftBarLinks[activeBarIdx].Title + "</span>"
  }
}

//常用导航创建
function creatCommNav(){
    var str = "<div id='commUsedNavBar'><span class='barTitle'>常用导航</span><span class='setIcon' onclick='window.open(\"./myNavSetting.html\",\"setMyTree\",\"height=800,width=1200,left=50,top=30,z-look=yes,status=no,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes\")'></span></div>" +
        "<div id='commUsedNavTree'></div>" +
        "<div id='goBackNav' onclick='goBackStaNav()'><span class='gobacktext'>返回标准导航</span></div>";
    return str;
}

//我的常用导航
function showMyComNav() {
    if (window.sysTypeIsMoZi) { return ""; }
    var mleftbody = window.parent.document.getElementById("mleftbody");
    var expandIcon = window.parent.document.getElementById("expandIcon");
    $(mleftbody).width(212);
    $(expandIcon).fadeOut();
    window.treeObj ? "" : "";
    $.ajax({
        type: 'get',
        dataType:'text',
        url: "../../SYSN/json/comm/MyMenuApi.ashx?actionName=ReloadMyMenu",
        beforeSend: function () {
            $("#commUsedNavTree").html("<div class='getInfoTips'><div class='onRunTime'></div>数据正在加载中...</div>")
        },
        success: function (res) {
            if (res) { window.treeObj = eval("("+res+")") }
            var html = []; 
            html.push("<div class='myNavTree'>"+ creatTreeHtml() +"</div>")
            $("#commUsedNavTree").html(html.join(""));
        },
        error: function (e) {
            console.log(e);
        },
        complete: function (r) {
            //console.log(r)
        }
    })
    $("#navContain .munePage").css("top", "0px");
    var namestg = window.top.UserInfo.Id + "_commUsedGuide";
    var usedstorage = localStorage.getItem(namestg);
    if (localStorage && !usedstorage) {
        top.NewChangeGuide.creatGuideHtml();
        top.NewChangeGuide.nextGuide("commUsedGuide")
    }
}

function goBackStaNav() {
    $("#navContain .munePage").css("top", "100%");
    var leftMuneActived = $("#leftMune li.navActived h1").html();
    if (leftMuneActived == "设置" || leftMuneActived == "回收站") {
        var mleftbody = window.parent.document.getElementById("mleftbody");
        $(mleftbody).width(92);
    }
}

 function creatTreeHtml(){
  var str=window.treeObj;
  if(!str||!str.length){
      return "<div class='noInfo'></div><span class='navInfo'>没有内容～</span><a class='add' onclick='window.open(\"./myNavSetting.html\",\"setMyTree\",\"height=800,width=1200,left=50,top=30,z-look=yes,status=no,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes\")' href='javascript:void(0);'>去设置</a>"
  }else{
      //console.log(str);
      var event1 = "onclick='toggleNavList(this)'";
      var btnGroup = { count: 1, classTxt: ["toggleBtn"], event: [event1]};
      if (drawTree) { return drawTree(str, { ID: 0, Name: "根节点", Children: [], Open: false }, { btnGroup: btnGroup,open:false}) }
  }
 }

//阻止事件冒泡
function stopPop(e) {
    var e = e || window.event;
    e.stopPropagation ? e.stopPropagation() : window.event.cancelBubble = true;
}

function resetleftnav(){
  var w=window.screen.width;
  var h=window.screen.height;
  if(w<1390){
   $("body").addClass("screenl1400").removeClass("screenl1600");
  }else if(w<1601){
  $("body").addClass("screenl1600").removeClass("screenl1400").addClass("screenl1600");
  }
  if(h>900){ $("body").removeClass("screenl1400").removeClass("screenl1600")}
}

/*
**@dec 信湖三级导航生成
**@param data-index:0_0-1_0-2_0,节点级数_下标-节点级数_下标
**@method updatePanel
*/
function updatePanel(a) {
  stopPop();
  $(a).addClass("listActived").siblings().removeClass("listActived");
  var index = a.getAttribute("data-index");
  var  htm = [];
  var content=formatNavData(index,leftBarLinks);//格式化json数据
  htm=creatPanelHtml(index,content)//html
  //创建面板容器
  window.parent.creatMunePanel($(a).offset(), htm);
}

//格式化末级导航数据
function formatNavData(index,leftBarLinks){
  var m = index.split("-");
  var idx1 = m[0].split("_")[1];
  var idx2 = m[1].split("_")[1];
  var secondItem = leftBarLinks[idx1]["ChildMenus"][idx2];
  var content = secondItem.ChildMenus;
  if(sysTypeIsMoZi){creatComHandle(content);}//常用操作
  var obj = {},
    arr = [];
  for (var i = 0; i < content.length; i++) {
      if (content[i].ChildMenus.length === 0 && !!content[i].Url) {
      arr.push(content.splice(i, 1)[0]);
      i--;
    }
  }
  if (arr.length > 0) {
    obj.Title = secondItem.Title;
    obj.ChildMenus = arr;
    content.unshift(obj);
  }
  return content
}

//末级导航面板html生成
function creatPanelHtml(index,childs){
  var html=[]
  var content=childs,index3,idx0,createFanTree;
  for (var j = 0; j < content.length; j++) {
    var t = content[j]
    title = "<h1 style='*display:inline;" + (sysTypeIsMoZi ? "font-family:\"微软雅黑\";font-size:14px;" : "") + "'>" +t.Title + "</h1>";
    listContent = "";
    index3 = index+"-2_" + j;
    if (!t.ChildMenus || !t.ChildMenus.length) {continue;}
    for (var i = 0; i < t.ChildMenus.length; i++) {
      var thirdNav = t.ChildMenus[i];
      if (!thirdNav.Title) {continue;}
      idx0 = index3 + "-3_" + i;
      if (thirdNav.Url == '@menu2link') {//财务-生成凭证左侧树结构生成；
        createFanTree =
          '$("#borderFrame").css({ width: "200px" });$("#borderFrame #spliter").addClass("childremenu1").removeClass("childremenu0");window.top.createFinanceTree();';
      } else {
        createFanTree = 'window.top.hideLeftNav()'
      }
      listContent += "<a title='"+thirdNav.Title+"' style='" + (sysTypeIsMoZi ? "font-family:\"微软雅黑\";font-size:14px;" : "") + "' id='" + thirdNav.ID + "' data-index='" + idx0 + "' class='bills' " + eventAndOpenMode(createFanTree, thirdNav) + ">" + thirdNav.Title + "</a>";
    }
    html.push("<div>");
    html.push(title);
    html.push("<div class='billList' style='" + (sysTypeIsMoZi ? "margin-bottom:10px;" : "") + "'>" + listContent + "</div>");
    html.push("</div>");
  }
  return html;
}

function eventAndOpenMode(ev,obj) {
    var event = "onclick='" + ev + (sysTypeIsMoZi ? ";countNum(this," + obj.ClickNum + ");" : "");
    var openStyle = "";
    if (obj.Url && obj.Url != "@menu2link") {
        switch (obj.OPenMode) {
            case "JS":
                var l=(window.screen.width-1200)/2
                openStyle = ";window.open(\"" + ("../../" + obj.Url) + "\",\"\",\"height=800,width=1200,scrollbars=1,resizable=1,top=100,left="+l+"\")";
                event += openStyle + ";$(\"#navPanelMask\").hide();'"
                break;
            case "超链接":
                event += ";$(\"#navPanelMask\").hide();'";
                openStyle = " href='" + ("../../" + obj.Url) + "' target='_blank'";
                event += openStyle;
                break;
            default:
                event += ";$(\"#navPanelMask\").hide();'";
                openStyle = " href='" + ("../../" + obj.Url) + "' target='mainFrame'";
                event += openStyle;
                break;
        }
    } else {
        event += ";$(\"#navPanelMask\").hide();'";
        openStyle = " href='javascript:void(0);'";
        event += openStyle;
    }

    return event;
} 

//updatePanel 结束

//信湖一级导航图标切换
function changeNavIcon(dom){
  var imgs = $(dom).siblings().find("div.nav_icon img");
  var t;
  for (var i = 0; i < imgs.length; i++) {
    var img = imgs[i];
    t = $(img).attr("class").indexOf("hiddenImg") >= 0;
    if (i % 2 == 0 && t) {
      $(img).removeClass("hiddenImg")
    } else if (i % 2 > 0 && !t) {
      $(img).addClass("hiddenImg")
    }
  }
  var activeImgs = $(dom).find("div.nav_icon img");
  activeImgs.eq(0).addClass("hiddenImg");
  activeImgs.eq(1).removeClass("hiddenImg");
}

//处理二级导航title,以及右侧子框架内的首页页面
function changeBarHome(text){
  !sysTypeIsMoZi||$("#showNavTitleBar").html(text);
  $("#showNavTitleBar").parent()[0].href = (text&&text!="账号") ? (text != "统计" ? "childhome.asp?key=" + escape(text) : "../../SYSN/view/Statistics/default.ashx") : "javascript:void(0);";
  sysTypeIsMoZi||setTab(text);
}

//切换右侧子导航首页（zb）
function setTab(txt){
  if(parent.frames["mainFrame"]){
	var key = txt.replace(/\n/g,"").replace(/\r/g,"");
	if("销售,营销,采购,库存,财务,办公,人资,生产,参数设置".indexOf(key) >= 0){
        //加载完成以后才能做2级导航跳转
        var setMsg = top.document.getElementById("sd0003");
        if(!setMsg || setMsg.style.display!="block"){
            parent.frames["mainFrame"].location.href = "childhome.asp?key=" + escape(key);
        }
	}
  }
}

/*****mz专属开始******/
//创建常用操作
function creatComHandle(c) {
  var arr = [];
  for (var i = 0; i < c.length; i++) {
    var child = c[i];
    if (child.Title == "常用操作") {continue;}
    child && child.ChildMenus ? arr = arr.concat(child.ChildMenus) : "";
  }
  arr.sort(compare);
  arr = arr.slice(0, 4);
  var len = arr.length;
  if (len) {
    if (arr[0] && arr[0].ClickNum < 5) {
      arr = []
    } else if (arr[0] && arr[0].ClickNum >= 5) {
        while (arr[len - 1] && arr[len - 1].ClickNum < 5 && len > 0) {
        arr = arr.splice(0, len - 1)
        len--;
      }
    }
  }
  if (c[0] && c[0].Title == "常用操作") {
      c[0].ChildMenus = arr
  } else {
    var obj = {
      "Title": "常用操作",
      "ChildMenus": arr
    };
    c.unshift(obj);
  }
}

//数组对象排序
function compare(a, b) {
  return a.ClickNum - b.ClickNum < 0 ? 1 : -1;
}

//顶部菜单折叠
function pickup(a) {
  var divIcon = $(a).find("div.fold span");
  if (!divIcon[0] || !divIcon[0].offsetHeight) {return }
  var names = divIcon.attr("class");
  var flag = names.indexOf("expandIcon") >= 0;
  var td = window.parent.document.getElementById("mleftbody");
  if (!td) {return}
  if (!flag) {
    divIcon.addClass("expandIcon");
    td.style.width = "66px";
    $(a).attr("title","展开左侧导航")
    $("#foldBorder").css({
      "height": $("#leftMune").height(),
      "display": "block"
    })
  } else {
    $(a).attr("title","收起左侧导航")
    divIcon.removeClass("expandIcon");
    td.style.width = "230px";
    $("#foldBorder").css({
      "display": "none"
    })
  }
}

function pickUpNav() {
    var pwin = window.parent;
    var doc = pwin ? pwin.document : "";
    var isExpandom = doc.getElementById("expandIcon");
    if (!isExpandom) { $(doc.body).append("<div id='expandIcon' onclick='expandNav()' title='展开左侧导航'></div>") }
    var leftnavcon = doc.getElementById("mleftbody");
    leftnavcon.style.width = "92px";
    $(doc.getElementById("expandIcon")).fadeIn();
}


/*****mz专属结束*****/

//统计点击左侧导航滚动到对应栏目
function scrollToColumn(a){
  $(a).addClass("listActived").siblings().removeClass("listActived");
  var text=$(a).text();
  var mainFrame=window.parent.document.getElementById("mainFrame");
  var contentWUrl=mainFrame?mainFrame.contentWindow.location.href:"";
  if(mainFrame&&contentWUrl.indexOf("Statistics/default.ashx?MenuIndex=1")>0){
    mainFrame?mainFrame.contentWindow.ViewScrollTo(text):""
  }else{
    if(mainFrame&&contentWUrl.indexOf("Statistics/default.ashx")>0){
      mainFrame.contentWindow.location.href=contentWUrl.split("?")[0]+"?MenuIndex=1&id="+text;
    } else {
        mainFrame.contentWindow.location.href = "../../SYSN/view/Statistics/default.ashx?MenuIndex=1&id=" + text;
    }
  }
}

//初始化时转到活跃的导航的位置
function resetActNavPos(){
  var index = window.top.leftNavIndex;
    if (typeof index == 'number') {
        $('.leftmune>li')[index].click();
    }
}

//页面初始化
window.onpageinit = function(){
    if ((top == window || (top.app && top.app.IeVer >= 100)) && uizoom != 1) {
        $("body").css({ "position": "relative", "zoom": window.uizoom })
  }
  if(window.onCommPageInit){ window.onCommPageInit(); }

  var htm=window.createNavHtml();
  $("#navContain").html(htm);
  resetleftnav();
  resetActNavPos();

  //事件绑定
  //一级导航点击事件监听;
  $(document).on("click", "#leftMune ul.leftmune li", function () {
      changeBarHome($(this).text());
      window.top.hideLeftNav();
      var mleftbody = window.parent.document.getElementById("mleftbody");
      var expandIcon = window.parent.document.getElementById("expandIcon");
      $(mleftbody).width(212);
      $(expandIcon).fadeOut();
    $(this).addClass("navActived").siblings().removeClass("navActived");
    changeNavIcon(this);
    if (this.innerText.indexOf("统计") >= 0) {
      var mainHome = window.parent.document.getElementById("mainFrame");
      mainHome.src = "../../SYSN/view/Statistics/default.ashx?MenuIndex=1";
    }
      if (this.innerText.indexOf("设置") >= 0) {
          $(mleftbody).width(92);
        var mainHome = window.parent.document.getElementById("mainFrame");
        mainHome.src = "../../SYSA/china2/homeseting/homeSet.html";
        return;
    }
      if (this.innerText.indexOf("回收站") >= 0) {
          $(mleftbody).width(92);
        var mainHome = window.parent.document.getElementById("mainFrame");
        mainHome.src = "../../SYSN/view/comm/RecycleBin.ashx";
        return;
    }
    var index = $(this).index();
    var ul = $("#muneMainNav ul.muneMainNav").eq(index);
    ul.children().removeClass("listActived");//删除上次选中的节点
    ul.removeClass("hidden").siblings().addClass("hidden");//展示相应的二级导航
    window.top.leftNavIndex = index;//保存当前选中的节点,框架内刷新保持节点处于选中状态

  })

  $(document).click(function () {
    var divlay = window.parent.document.getElementById("navPanelMask");
    if (!divlay) {return;}
    if (divlay.offsetHeight) {
        divlay.style.display = 'none';
    }
  });

}
//常用导航打开关闭事件
function toggleNavList(a) {
    var p = a.parentNode;
    if (toggleExpand) { toggleExpand(p);}
}
//常用导航的点击
$(function () {
    $("#navContain").on("mousedown", "#commUsedNavTree ul.tree_view1 a.text", function () {
        $(".myNavTree ul.tree_view1 a.text").parent().removeClass("actived");
        $(this).parent().addClass("actived");
    })
})