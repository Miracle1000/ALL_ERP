/*简单数据结构构建树*/
window.rootNode={ID:0,Name: "根节点",Children:[],Open:true};
window.setConfigure={line:"",isEdit:0,openStyle:0,btnGroup:{},index:"",open:true}
window.treeObjSimple={};



//简单数据转成标准结构
function formatStdData(data,node,l,nodepoen){
  if(!data||!data.length){return}
  var node =node||rootNode;
  for(var i=0;i<data.length;i++){
    if(data[i].ParentID==node.ID&&(data[i].Level!=node.Level||l)){
      data[i].Children=[];
        data[i].Open = nodepoen == undefined ? true : nodepoen;
      node.Children.push(data[i]);
      formatStdData(data,data[i]);
    }   
  }
}

//绘制树开始
function drawTree(data, node1, set) {
  var node =node1||rootNode;
  formatStdData(data,node,"",false);
  var treeNodes=node.Children;
  var html=[];
  var set=intSetting(set);
  creatTreeHtmls(treeNodes,html,set);
  return "<div class='my_nav_tree_view'>"+html.join("")+"</div>";
}

/*
*@desc 创建树结构DOM 
*@param nodes 树结构标准数据带有(Children和Level),treeArr 数组生成的html存放的容器
*@param set 设置树结构中的配置{line:"",isEdit:0,openStyle:0,btnGroup:{}}
*@param line-有连接线的节点，不用关注；isEdit是否是可编辑的，只读模式 0 默认 不可编辑，编辑模式 1，叶子节点不可跳转可编辑节点名称；
*@param openStyle叶子节点链接的打开方式（只读模式生效） 弹窗 1,框架内 0 默认；btnGroup {count:number/string,classTxt:[],txt:[],event:[]}
*@param count按钮数量；classTxt 按钮名字；txt 按钮文本；event 按钮事件；
*/
function creatTreeHtmls(nodes,treeArr,set,father){
  var father = father || {};
  var htmArr=treeArr||[];
  var set=set||window.setConfigure;
  var line=set.line||"";
  htmArr.push("<ul class='tree_view"+ (nodes[0]&&nodes[0].Level>=0?" tree_view"+nodes[0].Level:"")+(set.open?"":" hidden") +"'>")
  for(var i=0;i<nodes.length;i++){
    var node=nodes[i];
    var islast=i==nodes.length-1?true:false;
    var isfrist=i==0?true :false;
    var isleaf=(node.Level>0&&node.Children.length<=0||node.Url=="@menu2link")?true:false;
    node.Isleaf=isleaf;
    node.index = father.index === undefined?i:father.index+'-'+i;
    htmArr.push("<li class=''>")
    htmArr.push("<div data-index='"+ node.index +"' class='title"+(isleaf?"":" pTitle")+(node.Open&&!isleaf?"":" shink")+"'>")
    handleSpace(node,htmArr,line);//处理节点位置
    htmArr.push("<span  class='tvw_icon icon_n" + node.Level + (isfrist?" first":"") + (islast ? " last" : "") + (isleaf ? " leaf" : "") + "' " + (!isleaf ? "onclick='toggleExpand(this)'" : "") + "></span>");
    htmArr.push(creatNodeHtml(node,set,i))
    htmArr.push(creatHandleBtn(node,set,i))//节点的操作按钮
    htmArr.push("</div>")
    set.line=handleLine(node,islast,line);//处理层级背景线
    set.open=node.Open;
    if(!isleaf&&node.Children&&!node.Url){creatTreeHtmls(node.Children,htmArr,set,node)}
    htmArr.push("</li>")
  }
  htmArr.push("</ul>")
}

//初始化配置
function intSetting(obj){
  var configure={};
  if(!obj){
    configure=window.setConfigure
  }else{
    configure.line=obj.line||setConfigure.line;
    configure.isEdit=obj.isEdit||setConfigure.isEdit;//isEdit 节点的展现形式 只读0默、编辑1模式
    configure.openStyle=obj.openStyle||setConfigure.openStyle;//openStyle 链接的 打开模式 框架内0默、弹窗1
    configure.btnGroup=obj.btnGroup||setConfigure.btnGroup//节点的按钮操作  0默右侧无按钮 1右侧有按钮
    configure.index=obj.index||setConfigure.index
    configure.open=obj.open||setConfigure.open//节点的状态
  }
  return configure
}

//处理空格和线
function handleSpace(node,arr,l){
  var t,line=l||"";
  if(!node||!arr){return}
  for(var ii=0;ii<node.Level;ii++){
    t=line.indexOf(","+ii+",")>=0?"tvw_l":"tvw_nl";//tvw_l 有连接线；tvw_nl无连接线
    arr.push("<span class='aspectSpace n"+ ii  +" "+ t +"'></span>")
  }
}

//处理层级线
function handleLine(node,islast,l){
  var result=l||"";
  switch(node.Level){
  case 0:
    result=islast? "" : ","+node.Level+","
    break
  default:
    if(islast){
      result=result.replace(","+node.Level+",",",");
    }else{
      result.indexOf(","+node.Level+",")<0&&
      (result+=node.Level+",")&&(result=result[0]==","?result:","+result)         
    }
    break
  }
  return result;
}

//点击收缩
function toggleExpand(a,l){
  var pTitle=$(a).parent()
  var ul=pTitle.next();
  var classNames=ul.attr("class")||"";
  var title0=pTitle.children(".text");
  var nameStr=title0?title0.attr("class"):"";
  if(classNames.indexOf("hidden")>=0){
    ul.removeClass("hidden");pTitle.removeClass("shink");
    if(nameStr&&nameStr.indexOf("tvw_pnode_")>=0){title0.removeClass("tvw_pnode_close").addClass("tvw_pnode_open")}
  }else{
    ul.addClass("hidden");pTitle.addClass("shink")
    if(nameStr&&nameStr.indexOf("tvw_pnode_")>=0){title0.removeClass("tvw_pnode_open").addClass("tvw_pnode_close")}
  }
  var id=pTitle.find("tvw_icon").next()[0];
  // if(window.updateNodeOPenJson){window.updateNodeOPenJson(id,l)}
}

//只读模式下节点的dom形态
function creatNodeHtml(node,obj){
 var str="",isleaf=node.Isleaf;
 if(obj.isEdit){ 
   var name=HtmlConvert(node.Name)
   str= "<input  "+(isleaf?"url='"+node.Url+"'":"")+" id='tvw_"+node.Level+"_"+node.ID+"_"+"' title='"+name+"' class='nodeText' value='"+(name||"")+"'>"
  }else{
   if(obj.urlInvalid){
     str="<a id='tvw_"+node.Level+"_"+node.ID+"' class='text "+(!isleaf&&!node.Level?"tvw_pnode_open":"tvw_pnode_close")+"' url='"+ (node.Url?"../../"+node.Url:"") +"'"+(!isleaf?"onclick='toggleExpand(this)'":"")+" href='javascript:void(0);'>"+HtmlConvert(node.Name||"")+"</a>"
     return str;
   }
   if(obj.openStyle){//叶子节点链接打开方式处理
       str = "<a id='tvw_"+node.Level+"_"+node.ID+"' title='" + HtmlConvert(node.Name || "") + "' class='text "+(!isleaf && !node.Level?"tvw_pnode_open":"tvw_pnode_close")+"' href='javascript:void(0);' "+(node.Url&&node.Url!="@menu2link"?"onclick='window.open(\"../../"+ node.Url +"\",\"\",\"height=800,width=1200,left=410,top=30,scrollbars=yes\")'":(!isleaf?"onclick='toggleExpand(this)'":""))+">"+HtmlConvert(node.Name||"")+"</a>"
    }else{
     str = "<a id='tvw_"+node.Level+"_"+node.ID+"' class='text "+(!isleaf&&!node.Level?"tvw_pnode_open":"tvw_pnode_close")+"' "+(node.Url?"target='mainFrame'":"")+" "+(!isleaf?"onclick='toggleExpand(this)'":"")+" href='"+(node.Url?"../../"+ node.Url:"javascript:void(0);") +"'>"+HtmlConvert(node.Name||"")+"</a>"
    }
 }
 return str
}

//节点的操作按钮
function creatHandleBtn(node,obj){
  if(!obj.btnGroup||node.Url=="@menu2link"){return "";}
  var str="",btn=obj.btnGroup,classTxt,txt,event;
  if(!btn.count){return ""}
  if(node.IsChoose!==undefined){
    str+="<span id='btn1"+"_"+node.Level+"_"+node.ID+"' class='add_btn "+(node.IsChoose?"duihao":"")+"' onclick='add(this)'></span>"
  }else{
    for(var i=0;i<btn.count;i++){
      classTxt=btn.classTxt&&btn.classTxt[i]?btn.classTxt[i]:"";
      txt=btn.txt&&btn.txt[i]?btn.txt[i]:"";
      event=btn.event&&btn.event[i]?btn.event[i]:"";
      str+="<span id='btn"+i+"_"+node.Level+"_"+node.ID+"' class='"+(classTxt?classTxt:"")+ "' "+(event?event:"") +">"+(txt?txt:"") +"</span>"
    }
  }

  str=str?"<span class='node_handle' "+(node.Url?"url='"+node.Url+"'":"")+" text='"+HtmlConvert(node.Name||"")+"'>"+str+"</span>":"";
  return str
}

window.HtmlConvert = function (html) {
	var isnull = (html == undefined || html == null);
	html = ((isnull ? "" : html) + "");
	var u = 0;
	try {
		var chars = [
				["&sup2;", "²"], ["&sup3;", "³"], ["&reg;", "®"], ["&copy;", "©"], ["&Oslash;", "Ø"], ["&sup2;", "ø"],
				["&oslash;", ""], ["&micro;", "μ"], ["&szlig;", "ß"], ["&nbsp;", " "]
		];
		var stoped = false;
		while (html.indexOf("&") >= 0 && stoped == false && u < 1000) {
			var l1 = html.length;
			for (var i = 0; i < chars.length; i++) { html = html.replace(chars[i][0], chars[i][1]); }
			if (html.length == l1) { stoped = true; }
			u++;
		}
	} catch (e) { }
	var htmls = html.split("&#");
	if (htmls.length <= 1) {
		html = html.replace(/\&/g, "&amp;");
	} else {
		for (var i = 1; i < htmls.length; i++) {
			var c = htmls[i].indexOf(";");
			if (c > 0 && isNaN(htmls[i].substr(0, c)) == false) {  //&#xxx;的形式不转义
				htmls[i] = "&#" + htmls[i].replace(/\&/g, "&amp;");
			} else {
				htmls[i] = "&amp;#" + htmls[i].replace(/\&/g, "&amp;");
			}
		}
		html = htmls.join("");
	}
	html = html.replace(/\</g, "&lt;");
	html = html.replace(/\>/g, "&gt;");
	html = html.replace(/\"/g, "&quot;");
	html = html.replace(/\'/g, "&#39;");
	return html
};
window.getRequestParamVal = function (name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
    var r = window.location.search.substr(1).match(reg);
    if (r != null) return unescape(r[2]); return "";
}