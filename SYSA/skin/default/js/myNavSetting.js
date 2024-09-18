window.my_navSeting={};
window.DataSource={};
window.defaultSelect=undefined;
window.saveMuneListCheck=true;
window.navLeftActived=0;
my_navSeting.LeftRootNode={ID:0,Name: "根节点",Children:[]}
my_navSeting.MenuRootNode={ID:0,Name: "根节点",Children:[]}
my_navSeting.MiddleRows=[];
my_navSeting.TreeMap={};

my_navSeting.creatNavAndTree=function(){
 formatStdData(DataSource.MenuSourceList,my_navSeting.LeftRootNode,1);
 formatStdData(DataSource.MyMenuList,my_navSeting.MenuRootNode);
  this.getMyMenuList();
  this.getStandarNavView();
  this.getMyNavView();
  this.getMyNavModel();
  resizeWindow();
  $("div.addNavBtn").show();
  $("#treeNav").show();
  initChooseStatus();
}
my_navSeting.getMyNavModel=function(){
 var data=DataSource.MyModelList;
 var model=["<ul>"];
 for(var i=0;i<data.length;i++){
   var dat=data[i];
   model.push("<li class='modelBox'><input id='model_"+dat.ID+"' onclick='getModelNode(this)' type='checkbox' class='box' name='model'>"+"<label>"+dat.ModelName+"</label></li>")
 }
 if (!data.length) {model.push("<li class='modelBox' style='text-align:center;'>暂无模板信息</li>") }
 model.push("</ul>")
 $("#multipleModel").html(model.join(""))
}
my_navSeting.getMyMenuList=function(){
  var str = my_navSeting.updateSelectMune();
  $(".menuList").html(str);
}

my_navSeting.updateSelectMune=function(selected){//这个与上面的目录更新是一样的，需要服务端更新一下目录的名称，就可以把这个删除
  var options=my_navSeting.MenuRootNode.Children;
  var str='',opt={},flag=false;
  for(var i=0;i<options.length;i++){
    opt=options[i];
    isSelected= selected!=undefined&&selected==opt.ID?"selected":""
    if(isSelected){defaultSelect=selected;flag=true}
    str+="<option value='"+opt.ID+"' "+isSelected+">"+HtmlConvert(opt.Name)+"</option>";
  }
  if(!flag&&options.length){defaultSelect=options[0].ID}
  if (!options || !options.length) { str += "<option value='0'>默认目录</option>"; window.defaultSelect = 0 }
  return str;
}
my_navSeting.getMyNavView=function(){
  var myNavView=my_navSeting.creatMyNav111();
  $("#myNavView").html(myNavView);
}
my_navSeting.getStandarNavView=function(){
  var leftNav= my_navSeting.creatLeftNav();
  $("#leftMenu").html(leftNav.navBar||"");
  $("#treeNav").html(leftNav.navTree||"");

}

my_navSeting.creatLeftNav=function(){
  if(!window.DataSource.MenuSourceList||!window.DataSource.MenuSourceList.length){return}
  var html1=[],html2=[];
  var MenuSourceList=my_navSeting.LeftRootNode.Children;
  for(var i=0;i<MenuSourceList.length;i++){
    var menu=MenuSourceList[i];
    html1.push(this.creatLeftNavHtm(menu,i));
    html2.push(this.creatTreeNav(menu,i));
  }
  return {navBar:html1.join(""),navTree:html2.join("")};
}

my_navSeting.creatTreeNav=function(obj,idx){
  var html=[]
  html.push("<div class='menuPanel "+(idx==window.navLeftActived?"":"hidden")+"'>");
  html.push("<div class='topNav'>"+obj.Name+"功能菜单</div>");
  data=obj.Children;
  creatTreeHtmls(data,html,{openStyle:1,open:true,btnGroup:{count:1,classTxt:["add_btn"],event:["onclick='add(this)'"]}});
  html.push("</div>");
  return html.join("");
}

my_navSeting.creatMyNav111=function(){
  var event1="onmouseover='viewOriName(this)' onmouseout='$(\"#originTips\").hide();'"
  var event2="onclick='changePos(this,\"up\",1)'"
  var event3="onclick='changePos(this,\"down\",1)'"
  var event4="onclick='del(this)'"
  var btnGroup={count:4,classTxt:["view","up","down","del"],event:[event1,event2,event3,event4]}
  var html=["<div class='my_nav_tree_view'>"];
  var data=my_navSeting.MenuRootNode.Children;
  creatTreeHtmls(data,html,{isEdit:1,btnGroup:btnGroup,open:true})
  html.push("</div>");
  return html.join("");
}
my_navSeting.creatLeftNavHtm=function(obj,idx){
  return "<li class='"+(idx==window.navLeftActived?"navActived":"")+"' onclick='setTab(this)'>"+obj.Name+"</li>"
}
my_navSeting.updateMiddleNavNodeJson=function(){
  this.MiddleRows.push({sortid:id,rowindex:i,title:title,url:url,nodeId:""});
}
function refreshSelect(){
  var trs=$("#add_table_body").find("tr");
  var data=my_navSeting.MiddleRows,str;
  $("#Ztl_MenuList").html(my_navSeting.updateSelectMune())
  for(var i=0;i<data.length;i++){
    str=my_navSeting.updateSelectMune(data[i].sortid);
    $(trs[i]).find("select").html(str);
    data[i].sortid=window.defaultSelect;
  }
  window.saveMuneListCheck=true;
}
function resetSelectBoxPos(a){
  var posL=a.offsetLeft;
    var posT = a.offsetTop + a.offsetHeight;
  var w = a.offsetWidth*1+2;
  $("#multipleModel").css({left:posL+"px",top:posT+"px",width:w+"px"})
}
function setTab(a){
  $(a).addClass("navActived").siblings().removeClass("navActived");
  var idx=$(a).index();
  $(".menuPanel").eq(idx).removeClass("hidden").siblings().addClass("hidden")
  window.navLeftActived=idx;
}

function add(a){
  var url=a.parentNode.getAttribute("url");
  var val=a.parentNode.getAttribute("text");
  var id=a.id;
  var tds="<tr>"+
            "<td><div class='cancle' onclick='cancle(this,\""+id+"\")'></div></td>"+
            "<td class='menuSelect'>"+
              "<select class='menuList'>"+my_navSeting.updateSelectMune(window.defaultSelect)+"</select>"+
              "<span style='display:none' class='tipMessage' onclick='inputFocus(this)'>目录不允许为空</span>"+
            "</td>"+
            "<td class='notnull'>"+
              "<input class='nodeTitle' maxlength='50' url='"+(url?url:"")+"' value='"+val+"' oninput='watchValLength(this)' onpropertychange='watchValLength(this)'>"+
              "<span class='tipMessage' onclick='inputFocus(this)' style='display:none'>不允许为空</span>"+
            "</td>"+
            "<td>"+
              "<span onclick='changePos(this,\"up\")' class='node_up'></span><span onclick='changePos(this,\"down\")' class='node_down'></span>"+
            "</td>"+
          "</tr>"
  $(a).addClass("duihao")
  $("#add_table_body").append(tds);
  var h=$("#add_table_body").height();
  var h2=$("#addNavDataContainer").height();
  $("#scrollBar").height(h)
  if(h>h2){$("#rightScrollBar").height(h2).show()}else{$("#rightScrollBar").hide()}
  my_navSeting.MiddleRows.push({sortid:defaultSelect+"",rowindex:$("#add_table_body tr").length-1,title:val,url:url,nodeId:id})
}

//超过50不允许录入
function watchValLength(a){
var val=a.value
  if(val>50){
    a.value=val.slice(0,50);
  }
}
function inputFocus(a){
  var tagName=$(a).prev()[0].tagName;
  if(tagName=="INPUT"){$(a).hide().prev().show().focus();return}
  if (tagName == "SELECT") { $(a).hide().prev().show(); return }
}
function cancle(a,id){
  var index=$(a).parents("tr").eq(0).index();
  var count=0,flag=true;
  var url=my_navSeting.MiddleRows[index].url;
  my_navSeting.MiddleRows.splice(index,1);
  var data=my_navSeting.MiddleRows;
  for(var i=0;i<data.length;i++){
    var nodeId=data[i].nodeId;
     if(nodeId==id){count++}
     if(count>0){flag=false;break;}
  }
  $(a).parent().parent().remove();
  var h=$("#add_table_body").height();
  var h2=$("#addNavDataContainer").height();
  $("#scrollBar").height(h)
  if(h>h2){$("#rightScrollBar").height(h2).show()}else{$("#rightScrollBar").hide()}
  var rightMune=my_navSeting.TreeMap[url].rightMune;
  if(flag&&rightMune&&rightMune.length){flag=false}
  if(!flag){return}
  $("#"+id).removeClass("duihao")
}
function changeMenu(v){
 $("select.menuList").val(v);
 $("td.menuSelect span.tipMessage").hide();
 var data=my_navSeting.MiddleRows;
 for(var i=0;i<data.length;i++){
  data[i].sortid=v;
 }
}

$("#addNavContainer").on("change","select.menuList",function(){
  var val=$(this).val();
  var index=$(this).parents("tr").index();
  window.defaultSelect=val;
  my_navSeting.MiddleRows[index].sortid=val;
})

//添加导航节点
var addFlag = false;
function addMyMenuView() {
  if (addFlag) { return }
  addFlag = true;
  var tr,input,sel;
  var menuStr=getNewMenu();
  var data=my_navSeting.MiddleRows;
  for(var i=0;i<data.length;i++){
    var obj=data[i];
    tr=$("#add_table_body tr").eq(i);
    input=tr.find("input");
    sel=tr.find("select");
    obj.rowindex=i;
    if(!obj.title){input.hide();input.next().show();window.saveMuneListCheck=false}
    if ((obj.sortid != 0 && menuStr.indexOf("," + obj.sortid + ",") < 0) || (obj.sortid == 0 && menuStr)) { sel.hide();sel.next().show(); window.saveMuneListCheck = false; }
  }

  if (!data || !data.length || !window.saveMuneListCheck) { refreshSelect(); addFlag = false;return }
  var postbody=JSON.stringify(data);
  $.ajax({
    url:"../../SYSN/json/comm/MyMenuApi.ashx?actionName=SaveMyMenuByJsonString",
    data:{postbody:postbody},
    dataType:"text",
    type:"POST",
    success: function (res) {
        addFlag = false;
      if(res){
        var s=eval("("+res+")");
        if(s.Sucess==1){
          $("#add_table_body tbody").empty();
          my_navSeting.MiddleRows=[];
          updateMyNavView();
        }
      }
    }
  })
}

//模板添加节点
function getModelNode(a){
  if(a.checked){
      var id=a.id.split("_")[1];
      $(a).parents("#multipleModel").hide();
      $("#mask").hide();
    $.ajax({
      url:"../../SYSN/json/comm/MyMenuApi.ashx?actionName=SaveMyMenuByTemplate",
      data:{"templateid":id},
      success:function(res){
          if (res == 1) {
              updateMyNavView("", "", refreshSelect);
        }
      }
    })
  }
}

//我的导航目录集合字符串
function getNewMenu(){
  var data=my_navSeting.MenuRootNode.Children;
  var str="";
  for(var i=0;i<data.length;i++){
    str+=data[i].ID+",";
  }
  str=str.length?","+str:"";
  return str;
}
function cleanAll(){
  $("#add_table_body .cancle").trigger("click")
  my_navSeting.MiddleRows=[];
}

//节点移动
function changePos(a,s,m){
  if(m){
    var li=$(a).parents("li")[0];
    var ismenu=a.id.indexOf("_0_")>=0?1:0;//1 是目录，0是叶子节点
    switch(s){
      case "up":
        var preLi=$(li).prev();
        if(!preLi[0]){alert("已到顶了");}else{
            var id=a.id.split("_")[2];
            var preId=preLi.children(".title").children("input.nodeText")[0].id.split("_")[2];
            //alert(id+"===="+preId)
            updateNodePos(ismenu,id,preId);
        }
      break
      case "down":
        var nextLi=$(li).next();
        if(!nextLi[0]){alert("已到底了")}else{
          var id=a.id.split("_")[2];
          var nextId=nextLi.children(".title").children("input.nodeText")[0].id.split("_")[2];
          updateNodePos(ismenu,id,nextId);
        }
        break
    }  
    return
  }
  var tr=a.parentNode.parentNode;;
  switch(s){
    case "up":
      var preTr=$(tr).prev();
      if(!preTr[0]){alert("已经到顶了")}else{
        var idx=$(tr).index();
        var idx2=preTr.index();
        var obj=my_navSeting.MiddleRows[idx];
        my_navSeting.MiddleRows[idx]=my_navSeting.MiddleRows[idx2]
        my_navSeting.MiddleRows[idx2]=obj;
          $(tr).insertBefore(preTr)
      }
    break
    case "down":
      var nextTr=$(tr).next();
      if(!nextTr[0]){alert("已经到底了")}else{
        var idx=$(tr).index();
        var idx2=nextTr.index();
        var obj=my_navSeting.MiddleRows[idx];
        my_navSeting.MiddleRows[idx]=my_navSeting.MiddleRows[idx2]
        my_navSeting.MiddleRows[idx2]=obj;
        $(tr).insertAfter(nextTr)
      }
      break
  }
}

//导航视图删除;
function del(a){
  var id=a.id;//id中间拼接的是层级Level;id=btn+下标+层级+节点ID
  var ids=id.split("_")[2]+"";
  var isMenu=1;//默认是目录；
  isMenu=id.indexOf("_0_")>=0?1:0;
  $.ajax({
    url:"../../SYSN/json/comm/MyMenuApi.ashx?actionName="+(isMenu?"DelMySort":"DelMyMenu"),
    type:"POST",
    data:{ids:ids},
    success:function(res){
      if(res){
        if(isMenu){
          updateMuneNodeJson(ids)
        }else{
          updateLeafNodeJson(ids)
        }
        my_navSeting.getMyNavView();
        refreshSelect();
        initChooseStatus();
      }else{alert("节点未能成功删除！")}
    },
    error:function(e){console.log(e)}
  })
}

function updateMuneNodeJson(ids){
  var data=my_navSeting.MenuRootNode.Children
  for(var i=0;i<data.length;i++){
    var mune=data[i];
    if(mune.ID==ids){data.splice(i,1);break;}
  }
}

function updateLeafNodeJson(ids){
  var data=my_navSeting.MenuRootNode.Children
  for(var i=0;i<data.length;i++){
    var mune=data[i].Children;
    for(var ii=0;ii<mune.length;ii++){
      var child=mune[ii];
      if(child.ID==ids){mune.splice(ii,1);break;}
    }
  }
}

function updateNodePos(type,fromid,toid){
$.ajax({
  url:"../../SYSN/json/comm/MyMenuApi.ashx?actionName="+(type?"ReplaceMyMenuSortPosion":"ReplaceMyMenuPosion"),
  type:"POST",
  data:{fromid:fromid,toid:toid},
  success:function(res){
    if(res){
      if(type){updateMenuPosJson(fromid,toid);refreshSelect()}else{updateLeafPosJson(fromid,toid)}
      my_navSeting.getMyNavView();
    }else{console.log("位置更新失败")}
  }
})
}

function updateMenuPosJson(id,cid){
  var data=my_navSeting.MenuRootNode.Children
  var arr=[],idx;
  for(var i=0;i<data.length;i++){    
    idx=data[i].ID;
    if(idx==id||idx==cid){
      arr.push(i);
      if(arr.length>1){break;}
    }
  }
  if(arr.length<2){return}
  var obj=data[arr[0]];
  data[arr[0]]=data[arr[1]];
  data[arr[1]]=obj;
}

function updateLeafPosJson(id,cid){
  var data=my_navSeting.MenuRootNode.Children;
  var arr=[],idx,children,menu=undefined;
  for(var i=0;i<data.length;i++){
    if(arr.length>1){break;}
    children=data[i].Children;
    for(var ii=0;ii<children.length;ii++){
      idx=children[ii].ID;
      if(idx==id||idx==cid){
        if(menu==undefined){
          menu=i;
          arr.push(ii);
        }else{
          if(menu==i){//判断是否是同一目录下的子节点
            arr.push(ii);
          }
        }
      }
      if(arr.length>1){break;}
    }
  }
  if(arr.length<2){return}
  var menuChildren=data[menu].Children;
  var obj=menuChildren[arr[0]];
  menuChildren[arr[0]]=menuChildren[arr[1]];
  menuChildren[arr[1]]=obj; 
}

//添加目录弹层
function addMune(){
  if(!$("#add_menu_container")[0].offsetHeight){
    $("#mask").show();
    $("#add_menu_container").show();
  }
}

//添加目录
function addMuneSave(a){
  var mune = $("#addMuneText").val().replace(/(^\s*)|(\s*$)/g, "");
  if(!mune){alert("不允许为空");return}
  if(mune.length>50){alert("目录名称不能超过50个字符");return}
  $.ajax({
    url:"../../SYSN/json/comm/MyMenuApi.ashx?actionName=SaveMyMenuSort",
    type:"POST",
    data:{sort1:mune},
    success:function(res){
        if (res) {
        $("#addMuneText").val("");
        if (!a) {
            $("#mask").hide();
            $("#add_menu_container").hide();
        }
        updateMyNavView("", 1, refreshSelect);
      }
    }
  })
}

//重填
function addMuneClean(){
  $("#addMuneText").val("");
}

//更新右侧导航视图
function updateMyNavView(disrefresh,t,call){
  $.ajax({
    url:"../../SYSN/json/comm/MyMenuApi.ashx?actionName=GetMyMenuList",
    success:function(res){
      if(res){
        my_navSeting.MenuOldRootNode=my_navSeting.MenuRootNode;
        my_navSeting.MenuRootNode={ID:0,Name: "根节点",Children:[]}
        formatStdData(res,my_navSeting.MenuRootNode);
        if(!t){initChooseStatus()}
        if(!disrefresh){my_navSeting.getMyNavView();}
        if(call){call()}
      }
    }
  })
}

//查看原名
function viewOriName(a,e) {
  var oldname=a.getAttribute("oldname");
  if(oldname){
    $("#originName").text(oldname);
    resetOriNamePos(a);
    $("#originTips").show();
    return;
  }
  var url=$(a).parent().prev().attr("url");
  if (window.$requestSign) { window.$requestSign.abort() };
  window.$requestSign=$.ajax({
    url:"../../SYSN/json/comm/MyMenuApi.ashx?actionName=GetOldTitle",
    data: { url: url },
    async:false,
    success:function (res) {
      if(res){
        $("#originTips #originName").html(res);
        $(a).attr("oldname",res);
        resetOriNamePos(a);
      }
    }
  })
  $("#originTips").show();
}

//查看原名弹层位置
function resetOriNamePos(a){
 var w=$("#originTips").text().length*12,l,t,l1;
 var targetPos=a.getBoundingClientRect?a.getBoundingClientRect():getElementPos(a);
 var left=targetPos.left;
 var top=targetPos.top;
 var docw=document.documentElement.clientWidth-20;
 var isexp=(left+7+w/2)>docw?true:false;
  if(isexp){l=docw-w-10}else{l=left+7-w/2-10}
  t=top-28-12;
  l1=left-l;
  $("#originTips .arrow").css("left",l1+"px")
 $("#originTips").css({left:l+"px",top:t+"px"})
 $("#originTips").width(w);
}

//修改视图节点名称
$('#myNavView').on('blur','input.nodeText',function(){
  var val = $(this).val().replace(/(^\s*)|(\s*$)/g, "");
  $("#checkTreeName").attr("linkId",this.id);
  var title=this.getAttribute("title");
  var oldtitle=this.getAttribute("oldTitle");
  if(!val){
    this.value=oldtitle?oldtitle:title;
    if(oldtitle){this.setAttribute("title",oldtitle);}
    return ;
  }
  if(val.length>50){
    $(this).css("opacity",0);
    $("#checkTreeName").text("节点名称不能超过50个字符").show();
    var pos=$(this)[0].getBoundingClientRect?$(this)[0].getBoundingClientRect():getElementPos(this);
    $("#checkTreeName").css({"left":pos.left+"px","top":pos.top+"px"});
    if(!oldtitle){this.setAttribute("oldTitle",title);}
    this.setAttribute("title",val);
    return ;
  }
  this.setAttribute("title",val);
  var nodeId=this.id;
  var type=nodeId.indexOf("_0_")>=0?true:false;
  var id=nodeId.split("_")[2];
  $.ajax({
    url:"../../SYSN/json/comm/MyMenuApi.ashx?actionName="+(type?"UpdateMyMenuSort":"UpdateMyMenu"),
    data:{id:id,title:val},
    type:"POST",
    success:function(res){
      if(res){
        $("#"+nodeId).attr("oldTitle",val);
        updateMyNavView(true, 1, type?refreshSelect:"");
      }else{
        alert("节点名称修改失败");
        $("#"+nodeId).val(oldtitle||"");
      }
    }
  })
})

//修改中部节点名称*不允许为空校验
$("#addNavContainer").on("blur","input.nodeTitle",function(){
  var val=$(this).val();
  var index=$(this).parents("tr").index();
  if (!val.length) {
    $(this).hide();
    $(this).next().show();
    window.saveMuneListCheck=false;
  }
  my_navSeting.MiddleRows[index].title=val;
})

$("input.model_role").click(function(){
  if (!$("#multipleModel")[0].offsetHeight) {
      $("#mask").show();
      resetSelectBoxPos(this)
    $("#multipleModel").show();
  }
})

$("#mask,span.closeMenu").click(function () {
   $("#add_menu_container").hide();
   $("#multipleModel").hide();
   $("#mask").hide();
})

//修改节点校验信息
function hideCheckTips(a){
  var linkId=$(a).attr("linkId");
  if(!linkId){return;}
  $(a).hide();
  $("#"+linkId).css("opacity",1).focus();
}

//获取元素位置
function getElementPos(ele) {
  if (!ele) { return; }
  var actualTop = ele.offsetTop;
  var actualLeft = ele.offsetLeft;
  var current = ele.offsetParent;
  while ((current && current.tagName != "BODY")) {
      actualTop += current.offsetTop;
      actualLeft += current.offsetLeft
      current = current.offsetParent;
  }
  return {left:actualLeft,top:actualTop};
}


//左侧树勾选状态维护
my_navSeting.KeepChooseStatus=function(){
  var maptree=my_navSeting.TreeMap;
  for (var n in maptree) {
      if (!maptree[n]["leftMune"]) {continue }
    for(var ii=0;ii<maptree[n]["leftMune"].length;ii++){
      if(maptree[n]["rightMune"]&&maptree[n]["rightMune"].length){
        maptree[n]["leftMune"][ii].IsChoose=true
      }else{
        var flag=true
        for(var iii=0;iii<my_navSeting.MiddleRows.length;iii++){
          if(n==my_navSeting.MiddleRows[iii].url){
            flag=false;break;
          }
        }
        if(flag){maptree[n]["leftMune"][ii].IsChoose=false}else{maptree[n]["leftMune"][ii].IsChoose=true} 
      }
    }
  }
  my_navSeting.getStandarNavView()
}

function initChooseStatus(){
  my_navSeting.TreeMap=[];
  InitMapTree(my_navSeting.MenuRootNode.Children,"rightMune")
  InitMapTree(my_navSeting.LeftRootNode.Children,"leftMune")
  my_navSeting.KeepChooseStatus();
}

$("#treeNav").on("click","div.pTitle>.tvw_icon,div.pTitle>.text",function(){
  var title=$(this).parent();
  var indexArr=title.attr("data-index").split("-");
  var idx=$(".navActived").index();
  var data=my_navSeting.LeftRootNode.Children[idx];
  for(var i=0;i<indexArr.length;i++){
    data=data.Children[indexArr[i]]
  }
  data.Open=!data.Open;
})

$("#myNavView").on("click","div.pTitle>.tvw_icon",function(){
  var title=$(this).parent();
  var indexArr=title.attr("data-index");
  var data=my_navSeting.MenuRootNode.Children[indexArr];
  data.Open=!data.Open;
})


function InitMapTree(data,key){
  for(var i=0;i<data.length;i++){
    var url=data[i].Url;
    if(url){
      if(my_navSeting.TreeMap[url]){
        my_navSeting.TreeMap[url][key]?my_navSeting.TreeMap[url][key].push(data[i]):my_navSeting.TreeMap[url][key]=[data[i]]
      }else{
        my_navSeting.TreeMap[url]=[];
        my_navSeting.TreeMap[url][key]=[data[i]];
      }
    }else{
      InitMapTree(data[i].Children,key)
    }
  }
}

function resetTablePos(a) {
  if (!a) {return}
  var h=a.scrollTop;
  $("#add_table_body")[0].style.marginTop=-+h+"px"
}

function resizeWindow() {
    var h = document.documentElement.clientHeight;
    $("#comm_navSet_panle").height(h - $("#comm_itembarbg")[0].offsetHeight);
    var h=$("#add_table_body").height();
    var h2=$("#addNavDataContainer").height();
    $("#scrollBar").height(h)
    if (h > h2) { $("#rightScrollBar").height(h2).show() } else { $("#rightScrollBar").hide() }
    $("#mask").hide();
    $("#multipleModel").hide();
    $("#add_menu_container").hide();
}
$(window).resize(function () {
    resizeWindow()
})

//帮助弹层
my_navSeting.showHelpExplan = function (ele, e) {
    e = e || window.event;
    var div = $("#bill_help_expaln");
    var wid = document.documentElement.clientWidth || document.body.clientWidth;
    var wHei = document.documentElement.clientHeight || document.body.clientHeight;
    var maxw = parseInt(wid * 0.8) > 700 ? 700 : parseInt(wid * 0.8);
    var maxh = parseInt(wHei * 0.8) > 600 ? 600 : parseInt(wHei * 0.8);
    if (div) { $(div).remove(); div = null; }
    if (!div) {
        div = document.createElement("div");
        div.id = "bill_help_expaln";
        var txt = "";
        if (ele.getAttribute) {
            txt = (ele.getAttribute('text') || "");
        } else {
            txt = (ele['text'] || "");
        }
        if (txt.length < 500) { if (maxw > 500) { maxw = 500; } }
        div.innerHTML = "<div id='bill_help_expaln_text' class='bill_help_expaln_text'  style='max-height:" + maxh + "px;overflow-y:auto;'>"
            + "<div class='bill_help_expaln_top'><a href='javascript:;' class='bill_help_expaln_close'></a></div>"
            + txt + "</div>";
        document.body.appendChild(div)
    } else {
        var txt = "";
        if (ele.getAttribute) {
            txt = (ele.getAttribute('text') || "");
        } else {
            txt = (ele['text'] || "");
        }
        $("#bill_help_expaln_text").innerHTML = txt;
    }
    div.style.maxWidth = maxw + "px";
    var os = $(ele)[0].getBoundingClientRect();
    var hei = $(div).height();
    var myw = $(div).width();
    var winw = document.documentElement.clientWidth || document.body.clientWidth;
    var arrow = $("div.bill_help_expaln_top");
    var arrowwid = arrow.width();
    var arrowhei = arrow.height();
    var otop = os.top - hei - arrowhei;
    if (otop < 0) { otop = os.top + $(ele).height() + arrowhei; arrow.removeClass("up"); } else { arrow.addClass("up"); }
    var oLeft = os.left + $(ele).width() / 2 - myw / 2;
    if (oLeft < 10) { oLeft = 10; }
    if (oLeft + myw > winw) { oLeft = winw - myw - 10 }

    div.style.top = otop + "px";
    div.style.left = oLeft + "px";
    div.style.display = "block";
    /***箭头的位置***/
    var arrowleft = os.left + $(ele).width() / 2 - oLeft - arrowwid / 2;
    if (arrow[0]) { arrow[0].style.left = arrowleft + "px"; }
    $(window).off("scroll", my_navSeting.closeHelpExplan).on("scroll", my_navSeting.closeHelpExplan);
    $(document).unbind("click", my_navSeting.closeHelpExplan).bind("click", my_navSeting.closeHelpExplan)
}

my_navSeting.closeHelpExplan = function () {
    setTimeout(function () {
        $("#bill_help_expaln").remove();
    }, 10);
}
