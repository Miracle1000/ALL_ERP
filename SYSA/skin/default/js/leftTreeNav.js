var nodeEvent = {};

function creatTreeHtml() {
  var nav = getNavHtmlObj()
  var dat = [];
  dat[0] = "  <div id=\"navContain\">"
  dat[1] = "    <div class=\"navTitle\" id=\"navTitle\">"
  dat[2] = "      <ul>"
  dat[3] = "        <li class=\"standardNav actived\"> <span>标准导航</span> </li>"
  dat[4] = "    </div>"
  dat[5] = "    <div id=\"leftMuneNav\">"
  dat[6] = "      <div id=\"leftMune\">"
  dat[7] = "        <ul class=\"leftmune\">"
  dat[8] =           (nav.navBar || "")
  dat[9] = "        </ul>"
  dat[10] = "      </div>"
  dat[11] = "      <div id=\"muneMainNav\">"
  dat[12] =          (nav.NavTreeMune || "")
  dat[13] = "      </div>"
  dat[14] = "    </div>"
  dat[15] = "  </div>"
  $("body").html(dat.join(""));
  $("span.tvw_icon.leaf").next().bind("click", nodeEvent.changeNodeName)
}

function getNavHtmlObj(obj) {
  var datas = obj || window.treeData.Children;
  var html1 = [],
    html2 = [],
    dat;
  for (var i = 0; i < datas.length; i++) {
    dat = datas[i];
    html1.push(creatNavBarHtml(datas[i], i))
    html2.push(creatNavTreeMuneHtml(dat.Children, dat.Name, i))
  }
  return {
    navBar: html1.join(""),
    NavTreeMune: html2.join("")
  }
}

function creatNavBarHtml(obj, idx) {
  var str = "          <li id=\"bar_" + obj.ID + "\"  onclick='setTab(this)'  class=\"" + (idx == 0 ? "navActived" : "") + "\">" +
            "            <h1>" + (obj.Name || "") + "</h1>" +
            "          </li>"
  return str;
}

function creatNavTreeMuneHtml(obj, title, idx) {
  //resetUrl(obj);
  var html = [];
  creatTreeHtmls(obj, html, {
    open: true,
    urlInvalid: 1
  })
  var url = (title && title != "账号") ? (title != "统计" ? "childhome.asp?key=" + escape(title) : "../../SYSN/view/Statistics/default.ashx") : "javascript:void(0);";
  var cursor=url=="javascript:void(0);"?true:false;
  var str = "        <div class=\"menuPanel menuPanel" + (idx || "") + (idx == 0 ? "" : " hide") + "\">" +
            "          <div class=\"foldNav\" id=\"leftNavFoldIcon\"><a " + (cursor?" style='cursor:text'":"") + " class=\"secondBarTitle\" target=\"mainFrame\"" +
            "              href=\"" + url + "\"><span id=\"showNavTitleBar\">" + (title || "") + "</span>功能菜单</a>" +
            "          </div>" +
    html.join("") +
            "        </div>"
  return str;
}

function resetUrl(data) {
  if (!data || !data.length) {
    return;
  }
  var dat = "";
  for (var i = 0; i < data.length; i++) {
    dat = data[i]
    if (dat.Url) {
      dat.Url = ""
    }
    if (dat.Children && dat.Children.length) {
      resetUrl(dat.Children)
    }
  }
}

/**dom事件 */
function setTab(a) {
  $(a).addClass("navActived").siblings().removeClass("navActived");
  var idx = $(a).index();
  $(".menuPanel").eq(idx).removeClass("hide").siblings().addClass("hide")
}

nodeEvent.changeNodeName = function () {
  var title = this.innerText;
  var url = this.getAttribute("url");
  if (url.indexOf("@menu2link") >= 0 || !url) {
    alert("该导航菜单不允许添加到顶部菜单进行收藏。");
    return
  }
  if(parent.menutvwnodeclick){
    var o={};
    o.text=title;
    o.value=url;
    parent.menutvwnodeclick(o);
  }
  if (top.LeftMenuFun) {
    top.LeftMenuFun(title, url, "")
  }
}

top.LeftNavUrlChange = function () {
  var leftFrame = window.parent.document.getElementById("leftFrame");
  if (!leftFrame) {
    return false
  }
  var src = leftFrame.src
  if (src.indexOf("leftTreeNav") >= 0) {
    leftFrame.src = src.replace("leftTreeNav", "leftmenu");
  }
  top.LeftNavUrlChange = null;
}