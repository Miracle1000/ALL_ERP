

//订单检索区域
function GetSearchItemHtmlOrder(jpart){
    var htm = [];
    htm.push("<div class='shop_search order'>");
    htm.push(" <div class='shop_search_top'>");
    htm.push(GetSearchAreaHtmlOrder(jpart));
    htm.push(" </div>");
    htm.push(" <div class='shop_search_list'>");
    htm.push(GetSearchListHtmlOrder(jpart));
    htm.push(" </div>");
    htm.push("</div>");
    return htm.join("");
}

function GetSearchAreaHtmlOrder(jpart) {
    var htm = [];
    var data = jpart.info.data;
    var sel = data.searchstopbarsel;
    var link = data.searchstopbarlink;
    var ddType=data.iswy;
    htm.push('<div class="pro_search_top">');
    htm.push(' <ul class="pro_search_tab">');
    var tabs = data.billprogresstype;
    for (var i = 0, len = tabs.length; i < len; i++) {
        var cur = tabs[i];
        htm.push("<li onclick='changeTab(this,"+(ddType?1:0)+")' class='tab_item " + (cur.select ? "sd" : "") + "' v='" + cur.value + "'>" + tabs[i].key + "</li>");
    }
    htm.push(' </ul>');
    htm.push(' </div>');
    htm.push("<div class='select order' onclick='ShowOption()'>");
    htm.push("<span class='selected'>" + (sel.length > 0 ? sel[0].key : "") + "</span>");
    if (sel.length > 0) {
        htm.push("<div class='select_dom' style='width:110px;'>");
        htm.push("<div class='sel_border_top order' style='width:110px;'></div>");
        htm.push("<div class='sel_border_left'></div>");
        htm.push("<div class='sel_border_cont' style='width:98px;'><ul>");
        for (var i = 0; i < sel.length; i++) {
            htm.push("<li onclick='SearchSelectOrder(this)' style='width: 100%' value='" + sel[i].value + "'>" + sel[i].key + "</li>");
        }
        htm.push("</ul></div>");
        htm.push("<div class='sel_border_right'></div>");
        htm.push("<div class='sel_border_bottom' style='width:105px;'></div>");
        htm.push("</div>");
    }
    htm.push("</div>");
    if (data.isshowsearchstext) {
        htm.push("<span class='checkedall'><input type='text' class='sear_text_inp' id='sear_text_inp'/><input onclick='searchByServer("+(data.iswy?'1':'')+")' type='button' class='zb-button' value='检索'/></span>");
    }
    return htm.join("");
}

function GetSearchListHtmlOrder(jpart) {
    var htm = [];
    var sli = jpart.info.data.searchscontent;
    var iswy=jpart.info.data.iswy;
	var ispg = jpart.info.data.ispg;
    htm.push("<ul>");
    for (var i = 0; i < sli.length; i++) {
        htm.push("<li><a "+(!sli[i].cannotclick?"onclick='refreshPageByOrd(this,"+(iswy||0)+",undefined,"+(ispg||0)+")'":"")+"  value='" + sli[i].value + "'>" + sli[i].key + "</a></li>");
    }
    htm.push("</ul>");
    return htm.join("");
}

//订单看板内容部分展示区域
function GetContentItemHtmlOrder(jpart){
    /**
     * icotype:0：既有自制又有委外；1：自制；2：委外；
     */
    var htm = [];
    var data=jpart.info.data;
    var dateType=data.datetype;//0:月；1：周
    window.productBoardRefreshDataDatetype=dateType;
    window.productBoardRefreshDataCurdate=data.curdate;
    var bars=data.billbars,
        nowDate=new Date(jpart.info.data.curdate.split(" ")[0].replace(/-/g,"/")+" 00:00:00"),
        nowTime=nowDate.getTime(),
        year=nowDate.getFullYear(),
        mon=nowDate.getMonth(),
        dat=nowDate.getDate(),
        ary=jpart.info.data.curdate.split(" ")[0].replace(/-/g,"/").split("/");
    ary[2]="01";
    var curStart=new Date(ary.join("/")+" 00:00:00").getTime();
    var daies=[31,year%4?28:29,31,30,31,30,31,31,30,31,30,31];
    ary[2]=daies[mon];
    var curEnd=new Date(ary.join("/")+" 00:00:00").getTime();
    var lenn=daies[mon],
        wid=780/lenn;
    if(dateType==1){//此时按周显示
       curStart=nowTime-(1000*60*60*24*3);//当前时间减3天
       curEnd=nowTime+(1000*60*60*24*3);//当前时间加3天
       wid=780/7;
    }
    if(navigator.userAgent.indexOf("Firefox")>-1){
        wid=wid-0.01
    }
    htm.push("<div class='Mainbody_Cont order'>");
    htm.push("<div class='Mainbody_Cont_top'>");
    htm.push("<span style='font-weight: bold;float:left;margin-top: 3px;margin-left: 23px'>"+(jpart.title||'')+"</span>");
    htm.push("<ul>");
    htm.push("<li class='con_bar_btn "+(dateType==0?"sd":"")+"' value='0' onclick='changeMonOrWeek(this)' style='border-right:1px solid #c0ccdd'>本月</li>");
    htm.push("<li class='con_bar_btn "+(dateType==1?"sd":"")+"'  value='1'  onclick='changeMonOrWeek(this)' >本周</li>");
    htm.push("</ul>");
    htm.push("</div>");
    htm.push("<div class='Mainbody_Cont_top2'>");
    htm.push("<ul class='top_notice'>");
    var icos=data.station.stationico;
    for(var i=0;i<icos.length;i++){
         var cur=icos[i];
         var src="";
        switch (cur.ico*1){
            case 0:src="qbbh";break;//全部包含；
            case 1:src="zz";break;//订单自制；
            case 2:src="ww";break;//订单委外；
            case 3:src="cp";break;//派工单成品；
            case 4:src="bcp";break;//派工单半成品；
            case 5:src="zdww";break;//整单委外；
            case 6:src="gxww";break;//工序委外；
        }
        htm.push("<li class='top_notice_btn'><div><img src='"+ window.SysConfig.VirPath +"sysn/skin/default/img/board/"+src+".png' ></div><div>"+cur.title+"</div></li>");
    }
    htm.push("</ul>");
    htm.push("</div>");
    htm.push("<div class='bar_con' >");
    htm.push("<div class='top_con'>");
    htm.push("<ul class='top_con_bars'>");
    for(var i=0,len=bars.length;i<len;i++){
        /**每一条开始的地方是计划开工期；
         * 实际开工期晚于计划开工期的，前面留白
         * 实际完工期早于计划完工期的后面留白
         */
        var cur=bars[i],
            ps=new Date(cur.plandatestart.replace(/-/g,"/")).getTime(),
            pe=new Date(cur.plandateend.replace(/-/g,"/")).getTime(),
            ds=new Date(cur.datestart.replace(/-/g,"/")).getTime();
        var m=mon+1;
        var sy=new Date(cur.plandateend.split(" ")[0].replace(/-/g,"/")+" 00:00:00").getTime()-new Date(year+"/"+(m<9?("0"+m):m)+"/"+(dat<10?("0"+dat):dat)+" 00:00:00");
        sy=sy/1000/60/60/24;
        var ml=ps-curStart>0?((ps-curStart)/1000/60/60/24*wid):0,
            mr=curEnd-pe>0?(((curEnd-pe)/1000/60/60/24)*wid):0;
        if(bars.length>6){
            mr=mr-17//滚动条的宽度
        }
        mr=mr+wid;
        if(cur.icotype==2){noPro=";height:30px;line-height:30px";}
        else{noPro=""}
       // if(ml>=780||mr>=780)continue;//不在当前显示范围内的不显示
        var src="";
        var isww=false;
        switch(cur.icotype){
            case 0:src="qbbh2";break;//全部包含；
            case 1:src="zz2";break;//订单自制；
            case 2:src="ww2";isww=true;break;//订单委外；
            case 3:src="cp2";break;//派工单成品；
            case 4:src="bcp2";break;//派工单半成品；
            case 5:src="zdww2";isww=true;break;//整单委外；
            case 6:src="gxww2";isww=true;break;//工序委外；
        }
        var jh=isww?"下个交货日期":"";
        htm.push("<li class='bar_item' icotype="+cur.icotype+" isww='"+isww+"' value='"+cur.id+"'  "+(cur.isleaf?"":"onclick='refreshPageByOrd(this,"+(isww?1:0)+",1)'")+"  style='"+(i==0?"margin-top:0":"")+";margin-left:"+ml+"px;margin-right: "+mr+"px"+noPro+"' "+(cur.timeprogress*100?"pro='"+cur.timeprogress*100+"'":"")+"  pe='"+cur.plandateend+"' ps='"+cur.plandatestart+"' ds='"+cur.datestart+"' de='"+cur.dateend+"' sy='"+sy+"' ddtip='"+app.GetJSON(cur.tip)+"' billTitle='"+cur.title+"' onmouseover='barItemShowTip(this,event)' onmouseout='barItemHideTip(event)' onmousemove='barItemMoveTip(event)'>");
        var dds='';
        var dds2;
        var noPro;

        if(ps<curStart){
            htm.push("<span icotype="+cur.icotype+" datetype='"+dateType+"' style='color:"+(ds>curStart?"#2F496E":"#fff")+"' class='order_btn pre'  curstart='"+curStart+"' onclick='changeCurtime(this,0,event)' ><<</span>")
        }
        if(pe>curEnd){
            htm.push("<span icotype="+cur.icotype+" datetype='"+dateType+"'    class='order_btn next' curend='"+curEnd+"' onclick='changeCurtime(this,1,event)' >>></span>")
        }

        var rightW=0;
        if(ds>ps){
            if(ds>ps){
                if(ps>curStart){
                    dds=(ds-ps)/1000/60/60/24*wid-1;
                }else{
                    if(ds>curStart){
                        dds=(ds-curStart)/1000/60/60/24*wid-1;
                    }else{
                        dds=0
                    }
                }
                rightW=778-ml-mr-dds;
                if(bars.length>6){
                    rightW=rightW-17//滚动条的宽度
                }
                if(rightW>0){
                    htm.push("<div class='bar_item_left' style='width:"+dds+"px;"+noPro+"'></div>");

                    htm.push("<div class='bar_item_right' style='width:"+(rightW)+"px;*width:"+(rightW-24)+"px;"+noPro+"'><img src='"+ window.SysConfig.VirPath +"sysn/skin/default/img/board/"+src+".png'/>"+cur.title+"&nbsp;"+(cur.datedelivery?(""+jh+"："+cur.datedelivery+""):"")+"</div>");
                    }
                }
            // if(pe>de){
            //     dds2=(pe-de)/1000/60/60/24*wid;
            //     rightW=778-dds2-ml-mr;
            //     if(rightW>0){
            //         htm.push("<div class='bar_item_right' style='width:"+(778-dds-dds2-ml-mr)+"px;"+noPro+"'><img src='"+ window.SysConfig.VirPath +"sysn/skin/default/img/board/"+src+".png'/>"+cur.title+"&nbsp;交货日期：xxxxxx</div>");
            //         htm.push("<div class='bar_item_left'  style='width:"+dds2+"px"+noPro+"'></div>");
            //     }
            // }
        }else{
            htm.push("<div class='bar_item_right' style='width:"+(778-ml-mr)+"px;"+noPro+"'><img src='"+ window.SysConfig.VirPath +"sysn/skin/default/img/board/"+src+".png'/>"+cur.title+"&nbsp;"+(cur.datedelivery?""+jh+"："+cur.datedelivery+"":"")+"</div>");
        }
        var type=cur.tip.billtermtype*1;
        var bg='';
        switch(type){
            case 1:bg="rgb(90, 171, 252)";break;//提前
            case 2:bg="#5AAB5A";break;//正常
            case 3:bg="#fc7b53";break;//延期
        }
        if(cur.icotype!=2){//2是委外的，不需要进度条
            var pro=cur.timeprogress*100;
            htm.push("<div style='float:left;width: 100%;position:relative;'>");
			var widd=0;
			if(cur.countprogress!='null'){widd=cur.countprogress*100+'%'}
            htm.push("<div class='bar_item_bot'  "+(cur.countprogress!='null'?"countprogress='"+(cur.countprogress*100).toFixed(2)+"'":"")+"  style='background:"+bg+";width: "+widd+";position:relative;'></div>");
           // if(pro<=90){
			//    if(cur.timeprogress!='null'&&cur.countprogress!='null')
           //      htm.push("<div class='bar_item_bot_num'>"+(pro+'%')+"</div>");
			//    if(cur.timeprogress!='null'&&cur.countprogress=='null')
			// 	    htm.push("<div class='bar_item_bot_num'>"+(pro+'%')+"</div>");
			    if(cur.countprogress!='null')
				    htm.push("<div class='bar_item_bot_num'>"+((cur.countprogress*100).toFixed(2)+'%')+"</div>");
            //}
            htm.push("</div>");
        }

        htm.push("</li>")
    }
    if(bars.length==0){
        htm.push("<li class='bar_item' style='border:0;text-align: center;' >没有信息</li>");
    }
    htm.push("</ul>");
    htm.push("</div>");
    htm.push("<ul class='bot_rulur'>");
    var len;
    if(dateType==1){
        len=7;
        var d=dat-4;
        //var mmm=mon-1<1?12:[mon-1];
        var m=mon+1;
         m=m<10?("0"+m):m;
        for(var i=0;i<len;i++){
            var hasBor=true;
            d=d*1+1;
            if(d<1){d=daies[mon];m=m-1<1?12:(m-1)};
            if(d>daies[mon]){d=1;m=m*1+1<1?12:(m*1+1);}
            d=d<10?("0"+d):d;
            htm.push("<li class='bot_rulur_items ' style='width:"+wid+"px;"+((i==len-1)?"border-bottom:0":"")+"'>"+(hasBor?"<span class='bot_rulur_items_num_ date'>"+(m+"."+d)+"</span><span class='rulur_bor'></span>":"")+"</li>")
        }
    }else{
        len=daies[mon] ;
        for(var i=0;i<len;i++){
            var hasBor=(i+1)%5?false:true;
            if(i==len-1||i==0)hasBor=true;
            if(i==len-2&&hasBor)hasBor=false;
            htm.push("<li class='bot_rulur_items' style='width:"+wid+"px;"+((i==len-1)?"border-bottom:0":"")+"'>"+(hasBor?"<span class='bot_rulur_items_num_'>"+(i+1)+"</span><span class='rulur_bor'></span>":"")+"</li>")
        }
    }
    htm.push("</ul>");
    if(dateType==0){
        htm.push("<div class='drag_line' len='"+len+"'  year='"+(year)+"' mon='"+(mon+1)+"' dat='"+dat+"' dateType='"+dateType+"' wid='"+wid+"' style='left:"+(Math.round(wid*dat)-wid)+"px' id='drag_line'><div class='drag_line_top'>"+(mon+1+"."+dat)+"</div></div>");
    }else{
        htm.push("<div class='drag_line' len='"+len+"' year='"+(year)+"'  mon='"+(mon+1)+"' dat='"+dat+"' dateType='"+dateType+"' wid='"+wid+"' style='left:"+(780/7*3)+"px' id='drag_line'><div class='drag_line_top'>"+(mon+1+"."+dat)+"</div></div>");
    }
    htm.push("</div>");
    htm.push("</div>");
    return htm.join("");
}
//委外看板进度条区域
function GetContentItemHtmlOrderWy(jpart) {
    /**
     * icotype:0：既有自制又有委外；1：自制；2：委外；
     */
    var htm = [];
    var data=jpart.info.data;
    var dateType=data.datetype;//0:月；1：周
    window.productBoardRefreshDataDatetype=dateType;
    window.productBoardRefreshDataCurdate=data.curdate;
    var bars=data.billbars,
        nowDate=new Date(jpart.info.data.curdate.split(" ")[0].replace(/-/g,"/")+" 00:00:00"),
        nowTime=nowDate.getTime(),
        year=nowDate.getFullYear(),
        mon=nowDate.getMonth(),
        dat=nowDate.getDate(),
        ary=jpart.info.data.curdate.split(" ")[0].replace(/-/g,"/").split("/");
    ary[2]="01";
    var curStart=new Date(ary.join("/")+" 00:00:00").getTime();
    var daies=[31,year%4?28:29,31,30,31,30,31,31,30,31,30,31];
    ary[2]=daies[mon];
    var curEnd=new Date(ary.join("/")+" 00:00:00").getTime();
    var lenn=daies[mon],
        wid=650/lenn;
    if(dateType==1){//此时按周显示
        curStart=nowTime-(1000*60*60*24*3);//当前时间减3天
        curEnd=nowTime+(1000*60*60*24*3);//当前时间加3天
        wid=650/7;
    }
    htm.push("<div class='Mainbody_Cont order'>");
    htm.push("<div class='Mainbody_Cont_top'>");
    htm.push("<ul>");
    htm.push("<li class='con_bar_btn "+(dateType==0?"sd":"")+"' value='0' onclick='changeMonOrWeek(this,1)' style='border-right:1px solid #c0ccdd'>本月</li>");
    htm.push("<li class='con_bar_btn "+(dateType==1?"sd":"")+"'  value='1'  onclick='changeMonOrWeek(this,1)' >本周</li>");
    htm.push("</ul>");
    htm.push("</div>");
    htm.push("<div class='Mainbody_Cont_top2'>");
    htm.push("<ul class='top_notice'>");
    var icos=data.station.stationico;
    for(var i=0;i<icos.length;i++){
        var cur=icos[i];
        var src="";
        switch (cur.ico*1){
            case 0:src="qbbh";break;//全部包含；
            case 1:src="zz";break;//订单自制；
            case 2:src="ww";break;//订单委外；
            case 3:src="cp";break;//派工单成品；
            case 4:src="bcp";break;//派工单半成品；
            case 5:src="zdww";break;//整单委外；
            case 6:src="gxww";break;//工序委外；
        }
        htm.push("<li class='top_notice_btn'><div><img src='"+ window.SysConfig.VirPath +"sysn/skin/default/img/board/"+src+".png' ></div><div>"+cur.title+"</div></li>");
    }
    // htm.push("<li class='top_notice_btn'><div><img src='"+ window.SysConfig.VirPath +"sysn/skin/default/img/board/zdww.png' ></div><div>整单委外</div></li>");
    // htm.push("<li class='top_notice_btn'><div><img src='"+ window.SysConfig.VirPath +"sysn/skin/default/img/board/gxww.png' ></div><div>工序委外</div></li>");
    htm.push("</ul>");
    htm.push("</div>");
    htm.push("<div class='bar_con' >");
    htm.push("<div class='top_con'>");
    htm.push("<ul class='top_con_bars' style='width: 650px;float:left;margin-top: 0'>");
    for(var i=0,len=bars.length;i<len;i++){
        /**每一条开始的地方是计划开工期；
         * 实际开工期晚于计划开工期的，前面留白
         * 实际完工期早于计划完工期的后面留白
         */
        var cur = bars[i],
            ds = new Date(cur.datestart.replace(/-/g, "/")).getTime(),
            de = new Date(cur.datedelivery.replace(/-/g, "/")).getTime();//交货日期
        var m=mon+1;
        var ml=ds-curStart>0?((ds-curStart)/1000/60/60/24*wid):0,
            mr=curEnd-de>0?(((curEnd-de)/1000/60/60/24)*wid):0;
        mr=mr+wid;
        var noPro=";height:30px;line-height:30px";
        if(ml>=650||mr>=650)continue;//不在当前显示范围内的不显示
        htm.push("<li class='bar_item' ds='"+cur.datestart+"' de='"+cur.dateend+"' value='"+cur.id+"' "+(cur.isleaf?"":"onclick='refreshPageByOrd(this,1,1)'")+" style='margin-left:"+ml+"px;margin-right: "+mr+"px;height:30px;line-height:30px'     tip='"+cur.title+"' tip2='交货日期："+(cur.datedelivery||"")+" ' onmouseover='barItemShowTip(this,event)' onmouseout='barItemHideTip(event)' onmousemove='barItemMoveTip(event)'   billTitle='"+cur.title+"'>");
        var src="";
        if(ds<curStart){
            htm.push("<span datetype='"+dateType+"' class='order_btn pre' style='color:#fff' curstart='"+curStart+"' onclick='changeCurtime(this,0,event,1)' ><<</span>")
        }
        if(de>curEnd){
            htm.push("<span datetype='"+dateType+"' class='order_btn next' style='color:#fff'  curend='"+curEnd+"' onclick='changeCurtime(this,1,event,1)' >>></span>")
        }
        switch(cur.icotype){
            case 0:src="qbbh2";break;//全部包含；
            case 1:src="zz2";break;//订单自制；
            case 2:src="ww2";break;//订单委外；
            case 3:src="cp2";break;//派工单成品；
            case 4:src="bcp2";break;//派工单半成品；
            case 5:src="zdww2";break;//整单委外；
            case 6:src="gxww2";break;//工序委外；
        }
        var type=cur.delaystatus*1;
        var bg='';
        switch(type){
            case 1:bg="rgb(90, 171, 252)";break;//提前
            case 2:bg="#5aabfc";break;//正常
            case 3:bg="#fc7b53";break;//延期
        }
        var barLen=(cur.title.length+(cur.datedelivery||"").length+6-10)*10;
        var barWid=650-ml-mr;
            htm.push("<div class='bar_item_right' style='width:"+barWid+"px;"+noPro+";background:"+bg+"'><img src='"+ window.SysConfig.VirPath +"sysn/skin/default/img/board/"+src+".png'/>"+cur.title+"&nbsp;交货日期："+(cur.datedelivery||"")+"</div>");
        htm.push("</li>")
    }
    if(bars.length==0){
        htm.push("<li class='bar_item' style='border:0;text-align: center;' >没有信息</li>");
    }
    htm.push("</ul>");
    htm.push("<ul class='top_con_bars' style='float:left;width: 110px;margin-top: 0'>");
    for(var i=0,len=bars.length;i<len;i++){
        var cur=bars[i];
        var type=cur.delaystatus*1;
        var bg='';
        switch(type){
            case 1:bg="rgb(90, 171, 252)";break;//提前
            case 2:bg="#5aabfc";break;//正常
            case 3:bg="#fc7b53";break;//延期
        }
        htm.push("<li class='bar_item' style='color:"+bg+";height:32px;line-height:32px;border-color:#fff;'>"+(cur.delayday||"")+"</li>")
    }
    htm.push("</ul>");
    htm.push("</div>");
    htm.push("<ul class='bot_rulur' style='width:650px;'>");
    var len;
    if(dateType==1){
        // len=7;
        // for(var i=0;i<len;i++){
        //     var hasBor=true;
        //     htm.push("<li class='bot_rulur_items' style='width:"+wid+"px;"+((i==len-1)?"border-bottom:0":"")+"'>"+(hasBor?"<span class='bot_rulur_items_num_'>"+(i+1)+"</span><span class='rulur_bor'></span>":"")+"</li>")
        // }
        len=7;
        var d=dat-4;
        //var mmm=mon-1<1?12:[mon-1];
        var m=mon+1;
        m=m<10?("0"+m):m;
        for(var i=0;i<len;i++){
            var hasBor=true;
            d=d*1+1;
            if(d<1){d=daies[mon];m=m-1<1?12:(m-1)};
            if(d>daies[mon]){d=1;m=m*1+1<1?12:(m*1+1);}
            d=d<10?("0"+d):d;
            htm.push("<li class='bot_rulur_items ' style='width:"+wid+"px;"+((i==len-1)?"border-bottom:0":"")+"'>"+(hasBor?"<span class='bot_rulur_items_num_ date'>"+(m+"."+d)+"</span><span class='rulur_bor'></span>":"")+"</li>")
        }
    }else{
        len=daies[mon] ;
        for(var i=0;i<len;i++){
            var hasBor=(i+1)%5?false:true;
            if(i==len-1||i==0)hasBor=true;
            if(i==len-2&&hasBor)hasBor=false;
            htm.push("<li class='bot_rulur_items' style='width:"+wid+"px;"+((i==len-1)?"border-bottom:0":"")+"'>"+(hasBor?"<span class='bot_rulur_items_num_'>"+(i+1)+"</span><span class='rulur_bor'></span>":"")+"</li>")
        }
    }
    htm.push("</ul>");
    if(dateType==0){
        htm.push("<div class='drag_line' wy='1'  len='"+len+"' year='"+(year)+"'  mon='"+(mon+1)+"' dat='"+dat+"' dateType='"+dateType+"' wid='"+wid+"' style='left:"+(Math.round(wid*dat)-wid)+"px' id='drag_line'><div class='drag_line_top'>"+(mon+1+"."+dat)+"</div></div>");
    }else{
        htm.push("<div class='drag_line' wy='1'  len='"+len+"' year='"+(year)+"'  mon='"+(mon+1)+"' dat='"+dat+"' dateType='"+dateType+"' wid='"+wid+"' style='left:"+((780-110)/7*3-9)+"px' id='drag_line'><div class='drag_line_top'>"+(mon+1+"."+dat)+"</div></div>");
    }
    htm.push("</div>");
    htm.push("</div>");
    return htm.join("");
}
function changeProType(box,e) {
    e=e||window.event;
	if(box.tagName=="SPAN"){box=box.parentNode}
    e.stopPropagation? (e.stopPropagation()):(e.cancelBubble=true);
    var proType=box.getAttribute("proType");
    var pro;
	var span=box.getElementsByTagName("span")[0];
    if(proType=="count"){
        pro=box.getAttribute("timeprogress");
        box.setAttribute("proType","time")
    }else{
        pro=box.getAttribute("countprogress");
        box.setAttribute("proType","count")
    }
    box.style.width=(pro)+"%";
    var wid=$(box).width();
    var img=box.getElementsByTagName("img")[0];
    img.src=window.SysConfig.VirPath +"sysn/skin/default/img/board/change"+(wid>20?"":"O")+".png";
    $(box).next().html(pro+"%");
}


function barItemShowTip(box,e) {
    e=e||window.event;
    var left=e.clientX;
    var t=$(box).offset().top;
    if(document.documentMode==7){t=t+document.body.scrollTop}
    var div=document.getElementById("bar_item_tip");
    if(!div){
        div=document.createElement("div");
        div.id="bar_item_tip";
        document.body.appendChild(div);
    }
    var tip=box.getAttribute("tip");
	var ddtip=box.getAttribute("ddtip");
    if(!ddtip){
	  var str="<div class='bar_item_tip_item'>"+tip+"</div>";
         str+="<div class='bar_item_tip_item'>"+box.getAttribute('tip2')+"</div>";
        div.innerHTML=str;
        div.style.height='50px';
        div.onmousemove=function () {
            barItemMoveTip(event)
        };
        left=left+30;
        var wid=document.documentElement.clientWidth||document.body.clientWidth;
        if(left>wid-250){left=wid-530}
        $(div).css({
            left:left,
            top:t-10,
            display:"block"
        })
        return;
	 }else{
        div.style.height='110px';
    }
   
    var obj=eval("("+(box.getAttribute("ddtip")||"{}")+")");
    var isww=box.getAttribute("isww");
	if(box.getAttribute('sy')*1<0){
		var str="<div class='bar_item_tip_top'>"+(isww=='true'?'完结日期':'目标日期')+"："+box.getAttribute('pe')+"，已滞期<span style='color:#fe5454;padding:0 2px'>"+Math.abs(box.getAttribute('sy')*1)+"</span>天</div>";
	}else{
		var str="<div class='bar_item_tip_top'>"+(isww=='true'?'完结日期':'目标日期')+"："+box.getAttribute('pe')+"，剩余"+box.getAttribute('sy')+"天</div>";
	}
    
    var stat="",s = "",showDay=false,days="-1";
    var pe=new Date(box.getAttribute("pe").replace(/-/g,"/")+" 00:00:00").getTime();//计划开工
    var ps=new Date(box.getAttribute("ps").replace(/-/g,"/")+" 00:00:00").getTime();//计划结束
    var de=new Date(box.getAttribute("de").replace(/-/g,"/")+" 00:00:00").getTime();//实际开工
    var ds=new Date(box.getAttribute("ds").replace(/-/g,"/")+" 00:00:00").getTime();//实际结束
    switch(obj.billtermtype*1){
        case 1:stat="【提前】";
            s="实际开工早于计划";
            showDay=true;
            days=(ps-ds)/1000/60/60/24;
            break;
        case 2:stat="【正常】";
            s="实际开工和计划一致";
            break;
        case 3:stat="【滞后】";
            s="实际开工晚于计划";
            showDay=true;
            days=(ds-ps)/1000/60/60/24;
            break;
    }
    str+="<div class='bar_item_tip_item'><span class='bar_tip_title'>单据主题：</span>"+box.getAttribute('billTitle')+"</div>"
	if(s.length>0&&showDay&& isNaN(days)== false &&days!="-1" &&isww=="false"){
		str+="<div class='bar_item_tip_item'><span class='bar_tip_title'>开工状况：</span>"+s+"<span class='bar_tip_red'>"+days+"</span>"+(showDay?"天":"")+"</div>";
	}
	var pro=box.getAttribute("pro");
    str+="<div class='bar_item_tip_item'><span class='bar_tip_title'>当前达成：</span>"+obj.funishcount+"/"+obj.billcount+"</div>";
    str+="<div class='bar_item_tip_item'><span class='bar_tip_title'>达成率：</span><span class='bar_tip_red'>"+((obj.funishcount/obj.billcount*100)||0).toFixed(2)+"%&nbsp;"+stat+"</span></div>";
    div.innerHTML=str;
    div.onmousemove=function () {
        barItemMoveTip(event)
    }
    left=left+30;
    var wid=document.documentElement.clientWidth||document.body.clientWidth;
    if(left>wid-250){left=wid-530}
    $(div).css({
        left:left,
        top:t-40,
        display:"block"
    })
}
function barItemMoveTip(e) {
    var div=document.getElementById("bar_item_tip");
    if(!div)return;
    e=e||window.event;
    var left=e.clientX;
    left=left+30;
    var wid=document.documentElement.clientWidth||document.body.clientWidth;
    if(left>wid-250){left=wid-530}
    document.getElementById("bar_item_tip").style.left=left+'px';
}
function barItemHideTip(e) {
    document.getElementById("bar_item_tip").style.display='none';
}
function lineDragBefore(e) {
    e=e||window.event;
    var box=e.target||e.srcElement;
    if(box&&box.className=="drag_line"){
        box.style.borderLeft=' 3px solid #a36af9';
        box.setAttribute("candrag",1);
        window.dragLinePageLeft=e.clientX;
        window.gragLineLeftPos=parseFloat($(box).css("left"));
        window.dragLineCanDrag=1;
        window.bordtotalWid=$(".bot_rulur").width()-$(".bot_rulur_items").width();
    }
}
function computDate(year,mon,dat) {
    var ary=[31,year%4?28:29,31,30,31,30,31,31,30,31,30,31];
    if(dat<1){dat=ary[mon-2];mon=mon-1};
    if(dat>ary[mon-1]){dat=1;mon=mon+1};
    if(mon>12){mon=1;year=year+1}
    if(mon<1){mon=12;year=year-1}
    window.productBoardRefreshDataCurdate=year+"-"+(mon<10?("0"+mon):mon)+"-"+(dat<10?("0"+dat):dat);
    return mon+"."+dat
}
function lineDragMove(e) {
    var box = document.getElementById("drag_line");
    if (!box) return;
    if (box.getAttribute("candrag") == 1) {
        e = e || window.event;
        var x = e.clientX;
        var wid = box.getAttribute("wid"),
            year=box.getAttribute("year")*1,
            dat = box.getAttribute("dat")*1,
            mon = box.getAttribute("mon")*1;
        var left = x - window.dragLinePageLeft + window.gragLineLeftPos;
        if (left < 0)left = 0;
        var totalWid=window.bordtotalWid;
        var totalWid=$(".bot_rulur").width()-$(".bot_rulur_items").width();
        if (left > totalWid)left = totalWid;
        $(box).css("left", left);
        if(box.getAttribute("dateType")==0){
            box.innerHTML = "<div class='drag_line_top'>" + computDate(year,mon,(Math.round(left / wid)+1)) + "</div>"
        }else{
            box.innerHTML = "<div class='drag_line_top'>" + computDate(year,mon,(dat+Math.round(left / wid)-3))  + "</div>"
        }
    }

}
function lineDragEnd() {
    if(window.dragLineCanDrag) {
        var box=document.getElementById("drag_line");
        box.style.borderLeft = ' 1px dashed  #bbb';
        box.setAttribute("candrag", 0);
        window.dragLineCanDrag=0;
        var curdate=window.productBoardRefreshDataCurdate;
        var timeAry=curdate.replace(/-/g,"/").split("/");
        var year=timeAry[0];
        var dateAry=$(".drag_line_top").html().split(".");
        // box.setAttribute("mon", dateAry[0]);
        // box.setAttribute("dat", dateAry[1]);
        var curDate=year+"-"+(dateAry[0]<10?("0"+dateAry[0]):dateAry[0])+"-"+(dateAry[1]<10?("0"+dateAry[1]):dateAry[1]);
        window.productBoardRefreshDataCurdate=curDate;
        var obj={
            "datetype":window.productBoardRefreshDataDatetype||0,
            "searchkey":window.productBoardRefreshDatasearchkey||"",
            "searchvalue":document.getElementById("sear_text_inp")&&document.getElementById("sear_text_inp").value||"",
            "curdate":curDate,
            "ordertype":$("li.Tab_selected").attr("key"),
            "progressState":window.productBoardRefreshDataTabValue||"",
            "orderid":window.productBoardRefreshDataOrderId||"-1"
        };
        if(box.getAttribute("wy")){
            bordAjax("",obj,refreshLeftBotAndRight,1)
        }else{
            bordAjax("",obj,refreshLeftBotAndRight)
        }

    }
}
function changeCurtime(box,type,e,bordType) {//bordType:有值时是委外看板
    e==e||window.event;
    if(e.stopPropagation){
        e.stopPropagation()
    }else{
        e.cancelBubble=true;
    }
    var dateType=box.getAttribute("datetype");
    var changeDate="";
    var changeTime="";
    var start="";
    if(dateType==0){//月
        changeTime=1000*60*60*24;
        if(type==0){//上一月 (最后一天)
         start=box.getAttribute("curstart")*1;
         changeDate= start- changeTime;
        }else{//下一月（第一天）
            start=box.getAttribute("curend")*1;
            changeDate= start+ changeTime;
        }
    }else{//周
        changeTime=1000*60*60*24*4;
        if(type==0){//上一周 (第一天减4）
            start=box.getAttribute("curstart")*1;
            changeDate= start- changeTime;
        }else{//下一周（最后一天加4）
            start=box.getAttribute("curend")*1;
            changeDate= start+ changeTime;
        }
    }
    changeDate=new Date(changeDate);
    var year=changeDate.getFullYear();
    var mon=changeDate.getMonth()+1;
    mon=mon<10?("0"+mon):mon;
    var day=changeDate.getDate();
    day=day<10?("0"+day):day;
    var curDate=year+"-"+mon+"-"+day;
    var obj={
        "datetype":window.productBoardRefreshDataDatetype||0,
        "searchkey":window.productBoardRefreshDatasearchkey||"",
        "searchvalue":document.getElementById("sear_text_inp")&&document.getElementById("sear_text_inp").value||"",
		"icotype":box.getAttribute("icotype"),
		"ordertype":$("li.Tab_selected").attr("key"),
        "curdate":curDate,
        "progressState":window.productBoardRefreshDataTabValue||"",
        "orderid":window.productBoardRefreshDataOrderId||"-1"
    };
      bordAjax("",obj,refreshLeftBotAndRight,bordType)

}
function CResizeContentWidths(){
    var w = $('.contlist').width();
    var clis = $('.cont_li');
    for(var i=0;i<clis.length;i++){
        $(clis[i]).css('width',w-20);
    }
}
function computSearchHei() {//控制检索高度
    var height = $('.sel_border_cont').height();
    $(".sel_border_left").css("height",height);
    $(".sel_border_right").css("height",height);
}
$(function(){
    computSearchHei()
    setTimeout(function() {
        CResizeContentWidths();
    },100);
    $("body").bind("mousedown",function(){lineDragBefore(event)})
              .bind("mousemove",function(){lineDragMove()})
              .bind("mouseup",function(){lineDragEnd()})
              .bind("scroll",function () {$("#bar_item_tip").hide();$("#bill_help_expaln").hide()  });
    //记下尺子的宽度

});


/*
 订单看板回调方法及参数说明
 App_OrderBarClickCallBack
 curdate   //当前日期  不带时分秒
 datetype   //月：0；周：1
 progressState// 选项卡的值
 ordertype//订单类型 (右边的选项卡的值)：生产订单-》DD  派工单：PGD 委外单：WWD
 searchkey // 下拉框的值
 searchvalue //文本框的值
 orderid  ////单个订单的value（检索区域下面的li，或者右边的条条）
 */
//点击单个订单  "ordertype":window.productBoardRefreshDataOrderType
function refreshPageByOrd(box,type,aa, ispg) {//type==1 委外看板 aa点击订单的条条时会穿的参数
    var v=box.getAttribute("value");
	var itp=box.getAttribute("icotype")||"";
    window.productBoardRefreshDataOrderId=v;
    var obj={
		"icotype":itp,
        "orderid":v,
        "datetype":  (ispg ? 2 : (window.productBoardRefreshDataDatetype||0)),
        "curdate":window.productBoardRefreshDataCurdate,
        "ordertype":$("li.Tab_selected").attr("key")
    };
    if(aa){obj.barhandle=1 }
    bordAjax("",obj,refreshRight,type)
}
//切换周或月
function changeMonOrWeek(box,type) {
    if(box.className.indexOf("sd")>-1)return;
    $(box).addClass("sd").siblings().removeClass("sd");
    var value=box.getAttribute("value");
    var obj={
        "datetype":value,
        "searchkey":window.productBoardRefreshDatasearchkey||"",
        "searchvalue":document.getElementById("sear_text_inp")&&document.getElementById("sear_text_inp").value||"",
        "curdate":window.productBoardRefreshDataCurdate,
        "ordertype":$("li.Tab_selected").attr("key"),
        "progressState":window.productBoardRefreshDataTabValue||"",
        "orderid":window.productBoardRefreshDataOrderId||"-1"
    };
    bordAjax("",obj,refreshLeftBotAndRight,type)
}
//刷新右边
function refreshRight(obj,type) {//type==1  委外看板
    var o2=obj.contentarea;
    if(type){
        $(".bottomCont").eq(2).html(GetContentItemHtmlOrderWy(o2))
    }else{
        $(".bottomCont").eq(2).html(GetContentItemHtmlOrder(o2))
    }

}
//点击检索按钮   "ordertype":window.productBoardRefreshDataOrderType
function searchByServer(type) {
    var v=document.getElementById("sear_text_inp").value;
    var obj={
        "datetype":window.productBoardRefreshDataDatetype||0,
        "searchkey":window.productBoardRefreshDatasearchkey||"",
        "searchvalue":v,
        "curdate":window.productBoardRefreshDataCurdate,
        "ordertype":$("li.Tab_selected").attr("key"),
        "progressState":window.productBoardRefreshDataTabValue||""
    };
    bordAjax("",obj,refreshLeftBotAndRight,type)
}
//刷新左边的列表和右边
function refreshLeftBotAndRight(obj,type) {
    var o=obj.searcharea;
    $(".shop_search_list").html(GetSearchListHtmlOrder(o));
    var o2=obj.contentarea;
    if(type){
        $(".bottomCont").eq(2).html(GetContentItemHtmlOrderWy(o2));
    }else{
        $(".bottomCont").eq(2).html(GetContentItemHtmlOrder(o2));
    }

}

function changeTab(box,type) {
    var v=box.getAttribute("v");
    $(box).addClass("sd").siblings().removeClass("sd");
    window.productBoardRefreshDataTabValue = v;
    var obj={
        "progressState":v,
        "datetype":window.productBoardRefreshDataDatetype||0,
        "curdate": window.productBoardRefreshDataCurdate,
        "orderType": $("li.Tab_selected").attr("key")
    };
    bordAjax("",obj,refreshLeft,type)
}
//切换选项卡时刷新检索区域和看板进度条区域
function refreshLeft(obj,type) {
    var o=obj.searcharea;
    $(".shop_search_list").html(GetSearchListHtmlOrder(o))  ;
    var o2=obj.contentarea;
    if(type){
        $(".bottomCont").eq(2).html(GetContentItemHtmlOrderWy(o2));
    }else{
        $(".bottomCont").eq(2).html(GetContentItemHtmlOrder(o2));
    }
}

//点击订单左侧下拉框
function SearchSelectOrder(s){
    var key = $(s).text();
    var val	= $(s).attr("value");
    $('.selected').text(key);
    window.productBoardRefreshDatasearchkey=val;
}

function bordAjax(callName, param, callBack, type) {
    app.ajax.regEvent(callName||"OrderBarClickCallBack");
    for(var key in param){
        app.ajax.addParam(key, param[key]);
    }
    app.ajax.send(function(r) {
        if(r){
            var obj = eval("(" + r + ")");
            callBack(obj,type);
        }

    });
   
}

window.setInterval(function () {window.location.reload();}, 1000*60*10);