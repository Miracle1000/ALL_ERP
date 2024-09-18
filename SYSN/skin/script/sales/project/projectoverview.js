var PView = new Object();
PView.part2TabKey = 0;

PView.CHeaderHtml = function(){
	document.write("<div id=\"pcomm_itembarbg\" style=\"width: 100%;\"><div id=\"pcomm_itembarICO\"></div><div id=\"pcomm_itembarText\" style=\"width:208px;\"><span>"+ PView.Data.ui.title +"</span></div><div id=\"comm_itembarspc\"></div><span class='pview-name'>"+ PView.Data.name +"</span></div>")
}

PView.getPartHeader = function(gp){
	return "<div  class='psub-thead'>"
				+"<div class='pfcell'>"
					+"<div class=\"pgroup-fold\"><img  src=\"../../../../" + (window.SysConfig.SystemType == 3 ? "SYSA/skin/default/images/MoZihometop/content/r_down.png" : "SYSA/images/r_down.png") + "\"></div>"
					+"<div class=\"pgroup-title\">"+ gp.title +"</div>"
					+ (gp.cmdbuttons && gp.cmdbuttons.length > 0?"<div class='pgroup-addbtn' onclick=\""+ gp.cmdbuttons[0].cmdkey +"\"></div>":"")
				+"</div>"
			+"</div>";
}

PView.part1 = function(gp){
	var htm = [];
	htm.push(PView.getPartHeader(gp));
	htm.push("<table id='part1_tb'>");
	htm.push("<colgroup><col width='9%'><col width='24%'><col width='9%'><col width='24%'><col width='9%'><col width='24%'></colgroup>");
	var fds = gp.fields;
	for(var i = 0; i<fds.length; i++){
		if(fds[i].uitype == "nullspace"){ continue; }
		if((i%3)==0)htm.push("<tr>");
		htm.push("<td class='part1_tb_tle' align='center'>"+ fds[i].title +"：</td><td class='part1_tb_val'>"+ Bill.GetFieldHtml(fds[i]) +"</td>");
		if((i+1)%3 == 0)htm.push("</tr>");
	}
	htm.push("</table>");
	$("#window_part1").html(htm.join(""));
}

PView.part2 = function(gp){
	var htm = [];
	htm.push(PView.getPartHeader(gp));
	htm.push("<div id='part2_tab'>");
	var tabs = gp.fields[0].source.options;
	for(var i = 0; i<tabs.length; i++){
		htm.push("<div class='p2_tab_part'><div class='p2_tab_btn "+ (i==0?"clicked leftNavBg":"") +"' id='p2_tab_btn_"+ i +"' valk='"+ tabs[i].v +"' onclick='PView.ChangePart2View(this)'>"+ tabs[i].n +"</div></div>");
	}
	htm.push("</div>");
	htm.push("<div id='p2_li_cont'>");
	htm.push("<ul class='p2_ul' id='p2_ul'>");
	var lvw = gp.fields[3].listview;
	htm.push(PView.GetPart2LvwHtml(lvw,gp.fields[4]));
	htm.push("</ul>");
	htm.push("</div>");
	$("#window_part2").html(htm.join(""));
}

PView.GetPart2LvwHtml = function(lvw,linkfd){
	var htm = [];
	var rows = lvw.rows;
	if(rows.length == 0){
		htm.push("<div id='p2_li_no_info'>暂无信息</div>");
	}else{
		var len = rows.length>5?5:rows.length;
		for(var i = 0;i<len; i++){
			htm.push("<li class='p2_li'><span class='p2_li_date' title='"+ rows[i][2] +"'>"+ rows[i][2] +"</span><span class='p2_li_txt'>"+ rows[i][3] +"</span><span class='p2_li_per' title='"+ rows[i][4] +"'>"+ rows[i][4] +"</span></li>");
		}
		if(linkfd.formathtml)htm.push(linkfd.formathtml);
	}
	return htm.join("");
}

window.ajaxRefreshPage = function(){
	PView.RefreshPart2View(PView.part2TabKey);
}

PView.RefreshPart2View = function(val){
	var url = window.location.href;
	app.ajax.regEvent("sys.global.runstaticSub");
	app.ajax.addParam("fullname","ZBServices.view.SYSN.view.sales.project.ProjectOverView.GetChancePlanForProjectView");
	app.ajax.addParam("ChancePlanType",val);
	app.ajax.send(function(data){
		var obj = eval("("+data+")");
		var lvw = obj.groups[0].fields[0].listview;
		var linkfd = obj.groups[0].fields[1];
		$("#p2_ul").html(PView.GetPart2LvwHtml(lvw,linkfd));
	});
}

PView.ChangePart2View = function(el){
	$(el).addClass("clicked leftNavBg");
	$(el).attr("Chs",1);
	$(el).parent().siblings().children(".p2_tab_btn").removeClass("clicked leftNavBg");
	$(el).parent().siblings().children(".p2_tab_btn").attr("Chs",0);
	var val = $(el).attr("valk");
	PView.part2TabKey = val;
	PView.RefreshPart2View(PView.part2TabKey);
}

PView.GetDateTimeVal = function (s) {
	if (s == null) { return "";}
	var ds = s.split(" ");
	var tm = "";
	if(new Date(ds[0].replace(/\-/g,"/")).getTime() == new Date("1900/01/01").getTime()){ return  "";}
	if(ds.length == 1){ return s; }
	if(ds.length > 1){
		var ts = ds[1].split(":");
		ts.splice(2,1);
		tm = ts.join(":");
	}
	return ds[0]+" "+tm;
}

PView.getProcessHtml = function(lvw){
	var htm = [];
	var rows = lvw.rows;
	var hds = lvw.headers;
	if(rows.length == 0){return;}
	var exs = 0;
	var time = 0;
	var name = 0;
	var sp = 0;
	var btn = 0;
	for(var i = 0; i<hds.length; i++){
		if(hds[i].dbname.toLowerCase() == "execstatus"){ exs = i; }
		if(hds[i].dbname.toLowerCase() == "name"){ name = i; }
		if(hds[i].dbname.toLowerCase() == "sp"){ sp = i; }
		if(hds[i].dbname.toLowerCase() == "billid"){ btn = i; }
		if(hds[i].dbtype.toLowerCase() == "datetime"){ time = i; }
	}
	function getNodeState(val) {
		var cl = "";
		switch(val+""){
			case "0":
			case "2":cl = "noapprove";break;
			case "3":cl = "state3";break;
			case "4":cl = "state4";break;
			default:break;
		}
		return cl;
	}
	function getNodeTopVal(val){
		var ts = "";
		switch (val+"") {
			case "1":
			case "3":
			case "4":ts = rows[i][time]!=undefined && rows[i][time]!=null?PView.GetDateTimeVal(rows[i][time]):"";break;
			case "2":ts = rows[i][btn];break;
			default:break;
		}
		return ts;
		
	}
	
	htm.push("<div class='p3_item_cont_pres'>");
	for(var i = 0; i<rows.length; i++){
		htm.push("<div class='p3_pres_item "+ getNodeState(rows[i][exs]) +"'>");
		htm.push("	<div class='p3_pres_item_time'>"+ getNodeTopVal(rows[i][exs]) +"</div>");
		htm.push("	<div class='p3_pres_item_cont'>");
		htm.push("      <div class='p3_pres_item_point'></div>");
		htm.push("      <div class='p3_pres_item_txt' title='"+ (rows[i][sp]!=null?rows[i][sp]:"") +"'>"+ (rows[i][sp]!=null?rows[i][sp]:"") +"</div>");
		htm.push("      <div class='p3_pres_item_per' title='"+ (rows[i][name]!=null?rows[i][name]:"") +"'>"+ (rows[i][name]!=null?rows[i][name]:"") +"</div>");
		htm.push("	</div>");
		if(!(i==rows.length-1))htm.push("	<div class='p3_pres_item_arrow'></div>");
		htm.push("</div>");
	}
	htm.push("</div>");
	return htm.join("");
}

PView.GetP3ContTopHtml = function(fd){
	var rval = fd.value;
	switch(fd.uitype){
		case "moneybox":rval = fd.title +"："+ (fd.fronttext?fd.fronttext+" ":"") +app.NumberFormat(app.FormatNumber(fd.value,fd.uitype));
	}
	return rval;
}

PView.getP3ItemConttype1 = function(fd){
	var htm = [];
	var clds = fd.children;
	for(var i = 0;i<clds.length;i++){
		if(clds[i].uitype == "button"){ continue; }
		htm.push("<div class='p3_item_cont'>");
		var iclds = clds[i].children;
		var itm = [];
		if(iclds && iclds.length>0){
			var hasInfo = false;
			for(var ii = 0; ii < iclds.length; ii++){
				if(iclds[ii].uitype == "listview"){ continue;}
				var events = iclds[ii].throughlink && iclds[ii].throughlink.linkurl.length>0?"onclick='app.OpenUrl(\""+ iclds[ii].throughlink.linkurl +"\")'":"";
				itm.push("<span class='p3_item_cont_top_span "+ (iclds[ii].throughlink && iclds[ii].throughlink.linkurl.length>0?"hpointer":"") +"' title='"+ PView.GetP3ContTopHtml(iclds[ii]) +"' "+ events +">"+ PView.GetP3ContTopHtml(iclds[ii]) +"</span>");
				
			}
			if(itm.length > 0){
				hasInfo = true;
				htm.push("<div class='p3_item_cont_top'>"+ itm.join("") +"</div>");
			}
			for(var ii = 0; ii < iclds.length; ii++){
				if(iclds[ii].uitype == "listview"){ 
					if(iclds[ii].listview.rows.length > 0){ hasInfo = true; }
					htm.push(PView.getProcessHtml(iclds[ii].listview));
				}
			}
			if(!hasInfo){ htm.push("<div class='p3_item_cont_noinfo'>暂无信息</div>"); }
		}
		htm.push("</div>");
	}
	return htm.join("");
}

PView.GetP3ContTpye2Html = function(fd){
	var rval = fd.value;
	switch(fd.uitype){
		case "moneybox":rval = app.NumberFormat(app.FormatNumber(fd.value,fd.uitype));
		case "numberbox":rval = app.NumberFormat(app.FormatNumber(fd.value,fd.uitype));
	}
	if(fd.fronttext){ rval = fd.fronttext +" " + rval;}
	return rval;
}

PView.getP3ItemContType2Event = function(cld){
	return cld.throughlink && iclds[ii].throughlink.linkurl.length>0?"onclick='app.OpenUrl(\""+ cld.throughlink.linkurl +"\")'":"";
}

PView.getP3ItemConttype2 = function(fd){
	var htm = [];
	htm.push("<div class='p3_item_cont'>")
	var clds = fd.children;
	if(clds.length == 4){
		htm.push("<div class='p3_item2_title bg_"+ fd.dbname +"'><div class='p3_item2_title_bg ico_"+ fd.dbname +"'></div><span class='p3_item2_title_txt'>"+ clds[0].value +"</span></div>");
		htm.push("<div class='p3_item2_dom'><div class='p3_item2_dom_top'>"+ clds[1].title +"</div><span class='p3_item2_dom_btm color_"+ fd.dbname +"' "+ PView.getP3ItemContType2Event(clds[1]) +">" + PView.GetP3ContTpye2Html(clds[1]) +"</span></div>");
		htm.push("<div class='p3_item2_dom2'><div class='p3_item2_dom2_top'>"+ clds[2].title +"</div><span class='p3_item2_dom2_btm "+ (clds[2].throughlink?"pointer":"") +"' "+ PView.getP3ItemContType2Event(clds[2]) +">"+ PView.GetP3ContTpye2Html(clds[2]) +"</span></div>");
		htm.push("<div class='p3_item2_dom2'><div class='p3_item2_dom2_top'>"+ clds[3].title +"</div><span class='p3_item2_dom2_btm "+ (clds[2].throughlink?"pointer":"") +"' "+ PView.getP3ItemContType2Event(clds[3]) +">"+ PView.GetP3ContTpye2Html(clds[3]) +"</span></div>");
	}else{
		htm.push("<div class='p3_item2_title bg_"+ fd.dbname +"'><div class='p3_item2_title_bg ico_"+ fd.dbname +"'></div><span class='p3_item2_title_txt'>"+ clds[0].value +"</span></div>");
		htm.push("<div class='p3_item2_dom'><div class='p3_item2_dom_top'>"+ clds[1].title +"</div><span class='p3_item2_dom_btm color_"+ fd.dbname +"' "+ PView.getP3ItemContType2Event(clds[1])+">" + PView.GetP3ContTpye2Html(clds[1]) +"</span></div>");
		htm.push("<div class='p3_item2_dom2'>"
					+"<div class='p3_item2_dom2_top'>"+ clds[2].title +"：<span "+ PView.getP3ItemContType2Event(clds[2]) +">"+ PView.GetP3ContTpye2Html(clds[2]) +"</span></div>"
					+"<div class='p3_item2_dom2_btm'>"+ clds[3].title +"：<span "+ PView.getP3ItemContType2Event(clds[3]) +">"+ PView.GetP3ContTpye2Html(clds[3]) +"</span></div>"
				+"</div>");
		htm.push("<div class='p3_item2_dom2'>"
					+"<div class='p3_item2_dom2_top'>"+ clds[4].title +"：<span "+ PView.getP3ItemContType2Event(clds[4]) +">"+ PView.GetP3ContTpye2Html(clds[4]) +"</span></div>"
					+"<div class='p3_item2_dom2_btm'>"+ clds[5].title +"：<span "+ PView.getP3ItemContType2Event(clds[5]) +">"+ PView.GetP3ContTpye2Html(clds[5]) +"</span></div>"
				+"</div>");
	}
	htm.push("</div>");
	return htm.join("");
}

PView.getP3ItemConttype3 = function(fd){
	var htm = [];
	var cld = fd.children;
	htm.push("<div class='p3_item_cont'>")
	htm.push("	<div class='p3_item3_times'><span class='p3_item3_times_num'>"+ cld[0].value +"</span><div class='p3_item3_times_title'>"+ cld[0].title +"</div></div>");
	htm.push("	<div class='p3_item3_arrow'></div>");
	htm.push("	<div class='p3_item3_cont it1'><div class='p3_item3_cont_val'>"+ parseInt(cld[1].value*1)+"%" +"</div><div class='p3_item3_cont_title'>"+ cld[1].title +"</div></div>");
	htm.push("	<div class='p3_item3_cont it2'><div class='p3_item3_cont_val'>"+ parseInt(cld[2].value*1)+"%" +"</div><div class='p3_item3_cont_title'>"+ cld[2].title +"</div></div>");
	htm.push("	<div class='p3_item3_cont it3'><div class='p3_item3_cont_val'>"+ parseInt(cld[3].value*1)+"%" +"</div><div class='p3_item3_cont_title'>"+ cld[3].title +"</div></div>");
	htm.push("	<div class='p3_item3_cont it4'><div class='p3_item3_cont_val'>"+ parseInt(cld[4].value*1)+"%" +"</div><div class='p3_item3_cont_title'>"+ cld[4].title +"</div></div>");
	htm.push("</div>");
	return htm.join("");
}

PView.getP3ItemCont = function(fd){
	var str = ""
	switch(fd.dbname){
		case "chanceProcess":													//项目流程
		case "chanceDesign":													//设计
		case "chanceContract":												    //合同
		case "chanceYugou":                                                     //预购
		case "chanceCaigou":                                                    //采购
		case "chanceService":                                                   //售后
		case "chancePrice":                                                     //报价
		case "chancePrePlan":													//预生产计划
		case "chanceApprove":str = PView.getP3ItemConttype1(fd);break;		    //项目审批
		case "chancePaybackInvoice":                                            //开票
		case "chancePayoutInvoice":                                             //收票
		case "chanceKuout":                                            			//出库
		case "chanceKuin":                                            			//入库
		case "chanceSend":                                            			//发货
		case "chancePayout":                                            		//付款
		case "chancePayback":	str = PView.getP3ItemConttype2(fd);break;		//收款
		case "chanceReturnVisit":	str = PView.getP3ItemConttype3(fd);break;	//回访
	}
	return str;
}

PView.getGroupAddBtnHtml = function(ch){
	var htm = [];
	var ev = ch.callback[0];
	var event = "on"+ev.eventtype +"=\""+ ev.procname.replace("client:","") +"\"";
	htm.push("<div class='p3_item_addbtn' "+ event +">添加</div>");
	return htm.join("");
}

PView.part3 = function(gp){
	var htm = [];
	htm.push(PView.getPartHeader(gp));
	htm.push("<div id='p3_dom'>");
	var fds =gp.fields;
	for(var i = 0;i<fds.length;i++){
		var state = (fds[i].children.length == 0) || (fds[i].children.length == 1 && fds[i].children[0].uitype == "button");
		htm.push("<div class='p3_item'>");
		htm.push("	<div class='p3_item_left' id='p3_item_left_"+ i +"'>")
		htm.push("  <div class='p3_item_node "+ (state?"ngray":"") +"'></div>");
		if(i!= (fds.length-1))htm.push("  <div class='p3_line "+ (state?"bgray":"") +"' id='p3_line_"+ i +"'></div>");
		htm.push("  <div class='p3_item_left_dom'>");
		htm.push("  <div class='p3_item_title'>"+ fds[i].title +"</div>");
		if(fds[i].children[0] && fds[i].children[0].uitype == "button"){ htm.push(PView.getGroupAddBtnHtml(fds[i].children[0]))}
		htm.push(" 	</div>");
		htm.push(" </div>");
		htm.push("	<div class='p3_item_dom' id='p3_item_dom_"+ i +"'>");
		if(state){
			htm.push("<div class='p3_item_cont'><div class='p3_item_cont_noinfo'>暂无信息</div></div>");
		}else{
			htm.push(PView.getP3ItemCont(fds[i]));
		}
		htm.push("	</div>");
		htm.push("</div>");
	}
	htm.push("</div>");
	$("#window_btm").html(htm.join(""));
	setTimeout(function(){
		PView.procNodeLineHeight();
	},300)
}

PView.procNodeLineHeight = function(){
	var dm = $(".p3_item_dom");
	for(var i = 0;i < dm.length; i++){
		var h = $("#p3_item_dom_"+i).height();
		if($("#p3_line_"+i))$("#p3_line_"+i).css({"height":h,"visibility":"visible"});
		$("#p3_item_left_"+i).css("height", h - 15);
	}
}

PView.OnResizeCSub = function(){
   	var w = $("#window_line").width();
   	var ids = $(".p3_item_dom");
   	for(var i = 0;i < ids.length; i++){
   		$(ids[i]).css("width",w - 141);
   	}
   	PView.procNodeLineHeight();
};
PView.BindOnResizeHwnd = 0;
//单据加载时的对应UI处理入口
PView.BindOnResize = function(){
		if(PView.BindOnResizeHwnd>0) { clearTimeout(PView.BindOnResizeHwnd); PView.BindOnResizeHwnd=0;  }
		PView.BindOnResizeHwnd=setTimeout(PView.OnResizeCSub,100);
};
$(window).on("resize",PView.BindOnResize);
window.OnPageResizeExecEnd = PView.OnResizeCSub;

PView.ProcScrollBarEvent = function(){
	var h = $(".Pview-scrollBar").height();
	$(".Pview-scrollBar").css({"margin-top":(h/2)*-1,"visibility":"visible"});
}

PView.SpreadBar = function(el){
	var sv = $(el).attr("sv");
	if(sv == 1){
		$(el).attr("sv","0");
		$("#spreadbtntxt").html("展开");
		$('.spreadbtnbg').addClass("turn-left");
		$(".Pview-scrollBar").animate({'width':30},300)
	}else{
		$(el).attr("sv","1");
		$("#spreadbtntxt").html("收缩");
		$('.spreadbtnbg').removeClass("turn-left");
		$(".Pview-scrollBar").animate({'width':110},300)
	}
}

PView.CreateScrollBar = function(gp){
	var fds = gp.fields;
	var htm = [];
	htm.push("<div class='Pview-scrollBar'>");
	htm.push("<div id='spreadbtn' onclick='PView.SpreadBar(this)' sv='1'><div id='spreadbtntxt' >收缩</div><div class='spreadbtnbg'></div></div>");
	htm.push("<table id='scrollviewDom'>")
	for(var i = 0; i<fds.length; i++){
		htm.push("<tr><td onclick='PView.goAnchor(\"p3_item_left_"+ i +"\")'>"+ fds[i].title +"</td></tr>");
	}
	htm.push("<tr><td onclick='PView.goAnchor(\"goTop\")'>回到顶部</td></tr>");
	htm.push("</table>");
	htm.push("</div>");
	$('body').append(htm.join(""));
	PView.ProcScrollBarEvent();
}

PView.goAnchor = function(id){
	if(id == "goTop"){
		$("html,body").animate({'scrollTop':0},500)
	}else{
		$("html,body").animate({'scrollTop':$("#"+id).offset().top},500)
	}
}

window.createPage = function(){
	PView.Data = window.PageInitParams[0];
	PView.CHeaderHtml();
	var gps = PView.Data.groups; 
	document.write("<div id='window_line'></div><div id='window_top'><div id='window_part1'></div><div id='window_part2'></div></div></div><div id='window_btm'></div>");
	PView.part1(gps[0]);
	PView.part2(gps[1]);
	PView.part3(gps[2]);
	PView.CreateScrollBar(gps[2]);
	PView.BindOnResize();
}


//设计流程执行
function designDoHandle(cmd, ord, sort1, cateid){
	switch (cmd){
		case "申请":
			jQuery.ajax({
				url:'../../../../SYSA/Design/pool.asp?__msgid=doApply',
				data:{command:cmd,ord:ord},
				type:'post',
				success:function(r){
					window.location.reload();	
				},error:function(XMLHttpRequest, textStatus, errorThrown){
					alert(errorThrown);
				}
			});
			break;
		case "start":
		case "end":
			jQuery.ajax({
				url:'../../../../SYSA/Design/content.asp?__msgid=doHandle',
				data:{command:cmd,value:ord},
				type:'post',
				success:function(r){
					window.location.reload();	
				},error:function(XMLHttpRequest, textStatus, errorThrown){
					alert(errorThrown);
				}
			});
			break;
		case "提交审批":
			spclient.GetNextSP('Design',ord,0,sort1,cateid,"",false,350,450,"../../../../");			
			break;
	}
}

//项目流程执行
function ChanceProcRunAct(cmd, logid){
	switch (cmd){
		case "启动":
			if (window.confirm("确定启动此工作？")){
				jQuery.ajax({
					url:'../../../../SYSA/chance/procitemlist.asp?__msgid=InitLog',
					data:{logid:logid},
					type:'post',
					success:function(r){
						window.location.reload();	
					},error:function(XMLHttpRequest, textStatus, errorThrown){
						alert(errorThrown);
					}
				});
			}			
			break;
		case "审核":
			window.open("../../../../SYSA/chance/ChanceitemReviewPage.asp?ord=" + logid, "citemexec","width=1000,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=100");
			break;
		case "执行":
			window.open("../../../../SYSA/chance/ChanceitemExecPage.asp?ord=" + logid, "citemexec","width=1100,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=50");
			break;
	}
}


window.ShowNetSpDlg = function (url) {
    var div = app.createWindow("__sys_sp_clientDiv", "审批", {width:700, height:400});
    div.innerHTML = "<iframe src='" + url + "' frameborder='0' scrolling='no' style='width:100%;height:97%'></iframe>"
}

$(window).scroll(function () { $(".createWindow_popoBox").remove(); });