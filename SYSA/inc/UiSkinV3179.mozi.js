jQuery(document).ready(function(){
	var $=jQuery;

        /*下面这句话因前面语句的异常没有执行，合同详情页面img显示不正常,使用try语句规避错误；*/
        try {
            $("td[width='5%']").find("img").height(41).css({ "padding": "0", "margin": "0" }).parent().css({ "padding": "0", "margin": "0", "height": "42px", "overflow": "hidden" }).parent().siblings().css({ "padding": "0", "margin": "0" }).parent().css({ "padding": "0", "margin": "0" })

        } catch (e) { }

        try {//使用try语句规避异常；
            var place2Tb = $(".place2").parent().parent().parent();
            var p2H = $(".place2").html();
            if (p2H != "销售年报表" && p2H != "销售月报表" && p2H != "银行账户明细表" && p2H != "现金流明细表" && p2H != "电话统计汇总" && p2H != "短信统计汇总" && p2H.indexOf("现金流量每") < 0) {
                place2Tb.css({ "background": "url(../skin/default/images/MoZihometop/content/content_tab.png) no-repeat " });
            }
            if ($(".place").html() == "正式报价清单") {

                $(".place").next().width(800).next().width(0);
            }
            $(".place2").next().next().find("img").remove();/*售后设置-客户建议-建议分类设置-添加分类-注释该行 */
            $("td[colspan='3'][height='30px'][valign='middle']").parent().parent().parent().css({ "background": "#e7e7e7" });
            $(".place2").height(43);
            if (p2H == "销售年报表" || p2H == "销售月报表") {
                $(".place2").height(41);
            }
            if ($(".place2")) {
                switch (p2H) {
                    case "老板控制台":
                        $(".place2").css({ "background": "url(../skin/default/images/MoZihometop/content/content_tab.png) no-repeat", "width": "217px", "height": "42px" });
                        place2Tb.css({ "background": "#e7e7e7" });
                        $(".place2").parent().parent().parent().parent().parent().next().find("table").css({ "margin": "0" }); break;
                    case "销售周报表":
                        $(".place2").css({ "background": "url(../images/m_mplace2.gif) no-repeat", "height": "42px" });
                        place2Tb.css({ "background": "#e7e7e7" }); break;
                    case "龙虎榜（业绩）":
                        $(".place2").css({ "background": "url(../skin/default/images/MoZihometop/content/content_tab.png) no-repeat" });
                        place2Tb.css({ "background": "#e7e7e7" }); break;
					case "部门业绩年对比": $(".place2").next().width(420);
                    case "客户购买产品汇总":
                    case "客户购买价格分析":
                    case "挑战纪录":
                    case "部门业绩周对比":
                    case "小组业绩周对比":
                    case "小组业绩月对比":
                    case "小组业绩年对比":
                    case "人员业绩周对比":
                    case "客户购买汇总表":
                    case "今日提醒":
                    case "盘点明细表":
                    case "每月龙虎榜（业绩）":
                    case "每年龙虎榜（业绩）":
                    case "人员业绩月对比":
                    case "人员业绩年对比":
                    case "现金流明细表":
                        $(".place2").css({ "background": "url(../skin/default/images/MoZihometop/content/content_tab.png) no-repeat", "width": "277px", "height": "43px" })
                        place2Tb.css({ "background": "#e7e7e7" }); break;
                    case "入库汇总表":
                    case "入库明细表":
                    case "出库汇总表":
                    case "已发货明细表":
                    case "出库明细表": $(".place2").height(42);
                    case "调拨明细表":
                        $(".place2").css({ "background": "url(../skin/default/images/MoZihometop/content/content_tab.png) no-repeat", "width": "277px" })
                        place2Tb.css({ "background": "#e7e7e7" }); break;
                    case "银行账户明细表": $(".place2").height(42).width(290); break;
                    case "部门业绩月对比": $(".place2").next().width(298); $(".place2").css({ "background": "url(../skin/default/images/MoZihometop/content/content_tab.png) no-repeat", "width": "217px", "height": "42px" })
                        place2Tb.css({ "background": "#e7e7e7" }); break;
                    case "销售日报表": $(".place2").height(42).css({ "background": "url(../skin/default/images/MoZihometop/content/content_tab.png) no-repeat top right", "height": "42px" }); place2Tb.css({ "background": "#e7e7e7" }); break;
                }
                var thrid = $(".place2").next().next();
                if (thrid && thrid.length > 0) {
                    var btnnn = thrid.find("input[value='检索']");
                    if (btnnn && btnnn.length > 0) {
                        thrid.addClass("top_btns")
                    }
                }
            }
        } catch (e) { }
    try {
		$("#rightmenuall").find("td[id='placeInfo']").css({"background":"#d6d6d6 url(../skin/default/images/MoZihometop/content/m_placebg1.png) left center no-repeat"});
		var topTR=$("tr.top");
		if(topTR.hasClass("content-split-bar")){
		  topTR.find("div").has("input[type='button']").css({"margin-bottom":"9px"});
		}
		$("#td460").find("tr[style='background-color:#F0F4FD; cursor:pointer']").css({"background":"url(../images/tb_top_td_bg.gif)"});//生产订单-生产订单列表-详情-费用-添加使用明细-表头背景
		$("#td460").find("tr[style='cursor: pointer; background-color: rgb(240, 244, 253);']").css({"background":"url(../images/tb_top_td_bg.gif)"});//生产订单-生产订单列表-详情-费用-添加使用明细-表头背景
		if($("#zbmxlist")){
			$("#zbmxlist").find("table").eq(1).css({"background":"none"}).find("td").css({"padding-top":"0","padding-bottom":"0"});//组装拆装-添加组装-添加组装明细-子件清单table
			$("#zbmxlist").parent().find("table").eq(1).css({"background":"none"});//组装拆装-添加组装-添加组装明细-父件清单table
		}
		var tdBg = $("td[background='../images/112.gif']")
		tdBg.css({ "height": "50px", "background": "#fff" })/*.parent().css({ "margin-top": "-1px" });*/
		if (tdBg.attr("class").indexOf("top_btns") < 0 && tdBg.prop("class").indexOf("top_btns")<0) {
		    tdBg.parent().css({ "margin-top": "-1px" });/*出库汇总表上边框没有，所以去掉td类名为top_btns的元素,196行是根据这个属性给table加margin-top：-1*/
		}
		//处理按钮的高度
		$("td[background='../images/112.gif']").addClass("top_btns"); 
		$("a:contains('排序规则'):has(img)").css({"font-weight":"bold","color":"#345593"});
		$("img[width='18'][height='7']").each(function(index,item){
			$(item).css({"width":"6px","margin":"0 3px"});
		});
		var khTd=$("input.anniu").parent().prev().prev()
		if(khTd.html()=="客户分类设置"){
		   khTd.height(40)
		}
		$("table[width='150'][bgcolor='#ecf5ff'][height='115']").find("td").css({"height":"24px"})//排序规则table
		$('td[colspan="3"][style="background: url(../images/112.gif) #ebf2ff repeat-x;"]').css({"background":"rgb(244, 250, 254)","border-top":"0","border-right":"0"});//批量操作区域
		$('td[colspan="4"][background="../images/112.gif"]').css({"background":"none","border-top":"0","border-right":"0"});//批量操作区域
		$("strong:contains('仓库分类：所有分类')").parent().parent().css({"height":"55px","line-height":"55px"}).attr("valign","middle");/* 库存设置-仓库查看设置-设置仓库名称-检索区域*/
		$("#TBSr_tb1_1")&&$("#TBSr_tb1_1").parent().height(40).find("td").height(20);
        $("tr.top td").attr("valign","middle");
		var xmTd= $("td[width='5%'][height='27']:has(div):has(img)");//设置项目池权限顶部的标题的td
		$("td[width='40%'][background='../images/contentbg.gif'][style='padding-right:5px;']:has(input)").css({"background":"none"});
		$("td[width='195'][valign='top'][align='center']").height('100%');//知识库分类左边的树
		$("#dongjie").parent("td").css({"height":"55px","line-height":"55px"}).addClass("top_btns");
		$("span:contains('待办事宜')").parent().parent().css({"height":"auto"});
		$("td[width='14%'][height='30'][align='center']").css({"height":"54px","background":"rgb(244, 250, 254)"});
		$('td[height="30"][width="14%"][align="middle"][background="../images/m_table_top.jpg"]:contains("字段原名")').css({"background":"url(../images/m_table_top.jpg)","border":"1px solid #ccc"});
		$("#a44").parent().parent().css({"margin-left":"15px","background":"#fff","width":"100%"});//客户区域设置页面的树
		var leftTopImg=$("img[src='../images/contenttop.gif']");
		if($(".place2").html()=="今日提醒"){$(".place2").height(43)}
		$("#content").parent().each(function(index,item){
		    if (item.id != "table_container" && item.id != "loading_top" && item.tagName != "CENTER" && item.innerHTML.indexOf("选择统计条件") < 0) {//销售模块最后两个表，有一个加载的滚动条,不能加高度 
			  item.style.cssText="height:auto!important"
			};
			if(item.tagName=="CENTER"){
			  item.style.height='110%'
			}
		});
		$("#currpage").height(20);
		$("#sear").height(21);
		$("#thtb").find("tr").eq(0).find("td").css({"border-top":0,"height":"30px","background": "url(../images/m_table_top.jpg);"});
		$("#gd1[class='zdy']").find("tr").eq(1).find("td").css({"height":"50px"});//客户列表检索区域设置高度以后，检索区域下方的单元格在ie下会被隐藏一部分
		var khDiv=$("div[id='kh']");
		if(khDiv){
			if(khDiv.parent().parent().find("td.place").length==0&&!khDiv.attr("height")){
			  khDiv.css({"height":"50px"});//营销-短信管理-短信地址-检索区域-去掉下边框
			}else{
			 // khDiv.css({"height":"42px","line-height":"42px"}).find("select").css({"margin-top":"10px"});//办公-公告查看-所有公告列表-打印，但是此区域为下拉框时，不能垂直居中（财务-销售退款-退款明细）
			}
			if(khDiv.find("td[background='../images/112.gif']").length>0){ khDiv.css({"height":"auto","line-height":"auto"})}
		}
		if(khDiv.parent().tagName=="TD"&&khDiv.parent().parent().find("td.place").length>0){
		   khDiv.css({"height":"22px","line-height":"22px"})
		}
		if(khDiv.hasClass("hei_42")){khDiv.height("auto")}
        if(navigator.userAgent.indexOf("MSIE")>0){khDiv.css({"height":"23px","line-height":"20px"})}
		$("td::contains('没有信息')").css({"background":"#fff"});
		$("td::contains('没有信息')").parents("table").prev().parents("body").css({"background":"#fff"});//库存-组装拆装-组装清单列表-去掉border-bottom
		$(".pro-menu-search").parent().css({"height":"55px","background":"#fff"}).find("td").css({"height":"55px","line-height":"55px"}).attr("valign","middle");
		$("img[src='../image/pixel.gif']").attr("src","../images/pixel.gif")
		$("#billtopbardiv").find("table.full").next().height(42);//售后管理-客户观怀-客户关怀列表--表头
		$("input[value='修改模板']").parents("td").css({"height":"40px"})//客户设置-信封打印模板-修改模板按钮的下边框去掉
		$("#productTree").css({"background":"#fff"});//营销-微信管理-商品管理-商品添加-左边的树的背景
		var searTd=$("#daysOfMonth2Pos").parent().parent();
		var iHT=$("#daysOfMonth2Pos").parent().prev().html();
		
		if(!iHT||(iHT&&iHT.indexOf("预计日期")==-1&&iHT.indexOf("终止日期：")==-1)){
			
		  if(searTd.parent().find("td.place").length==0&&searTd[0].tagName!="FORM"&&!searTD.attr("noheight")){searTd.css({"height":"55px","line-height":"55px","border-top":"0"}).attr("valign","middle");}
		   if(searTd.parent().find("td.place").length==0&&searTd[0].tagName=="TR"){searTd.find("td").css({"height":"55px","line-height":"22px","background":"#fff"}).attr("valign","middle");}
		  if(searTd.parent().find("td.place").length==0&&searTd[0].tagName=="FORM"){//此时是统计栏目的检索区域
			  searTd.find("td")
				  .css({"height":"55px","line-height":"55px","border-top":"0","background":"#fff"})
				  .addClass("top_btns").
				  attr("valign","middle");
			  $('select').each(function(){if(this.innerText.indexOf("图宽=")>-1){$(this).parent().addClass("top_btns")}})}
		}
		 if($("#daysOfMonth2Pos").html().indexOf("选择统计条件")>-1){searTd.css({"height":"auto","line-height":"auto"});$("#daysOfMonth2Pos").parent()[0].style.cssText="padding-top:5px!important;line-height:26px"}//办公-常用工具-备忘录-备忘录列表-paddng-top:5px;
		if(searTd.find("td.place2").length>0){
		   searTd.css({"height":"42px","line-height":"42px","background":"url(../images/m_mpbg.gif)"});$(".place2").height(42).css({"background":"url(../skin/default/images/MoZihometop/content/content_tab.png) no-repeat","padding-top":"0","width":"216px"})
		}
		if(searTd[0]&&searTd[0].tagName.toLowerCase()=="div"){searTd.css({"height":"auto","line-height":"23px"})}
		
		if(pHtml=="公司收入明细表"||pHtml=="公司支出明细表"||pHtml=="公司收支明细表"){
		 place.parent().next().find("td").height(55).css({"border-top":"1px solid #C0CCDD"});
		}
		if(pHtml=="客户预收款统计分析"){
		 place.parent().next().find("td").height(55).css({"background":"none"});
		}
		
		$("input[value='删除字段']").parent().css({"margin-top":"8px"});//库存-采购设置-采购扩展自定义-右上角删除字段
		$("font:contains('入库详细内容')").parent().parent().prev().find("div").eq(0).height(42).parent().parent().parent().parent().height(42);//库存-仓库管理-入库管理-入库汇总表-详情-表头
		$("#ListContent").find("div").eq(0).css({"height":"42px","line-height":"42px"});//库存-出库管理-直接出库-出库明细-table
		$("#forSeach").parent().parent().css({"height":"55px","line-height":"55px"})//办公-办公用品库存-办公用品台账-检索
		$("strong:contains('状态状态：所有状态')").parent().parent().height(55).attr("valign","middle").next().height(55).attr("valign","middle");//办公-固定资产管理-固定资产设置-设置资产状态-状态
		$("#jmppage1").parent().parent().height("55");//人资-招聘管理-招聘报表-招聘完成比例-检索
		if(place&&place.html()=="盘点列表"||place.html()=="盘点历史表"){
		   topTb.css({"border-bottom":"none"});
		}
		if($(".place2")&&$(".place2").html()=="电话统计汇总"|| $(".place2").html()=="短信统计汇总"){
		   $(".place2").width(220).next().css({"height":"42px","line-height":"42px","background":"url(../images/m_mpbg.gif) repeat-x"}).attr("valign","middle");
		}
		$("#rightmenuall").find("td[id='placeInfo']").addClass("tree_title_td");
		$("#ListContent").find("div").eq(0).height(40); 
		
		
	} catch (e) { }

    try{
        var trs = $("tr[style]");
        for(var i = 0; i<trs.length; i++){
            if (trs[i].style.marginTop == "-1px") {
                trs[i].parentNode.parentNode.style.marginTop = "-1px";
            }
        }
     }
    catch (e) { }

    try {
        setTimeout(function () {
            if (window.frameResize != undefined) {
                $(window).unbind("resize", window.frameResize).bind("resize", window.frameResize);
            }
        }, 2000);
    } catch (ex) { }

    try{
    	var table = $('table[background="../images/m_mpbg.gif"]')[0];
    	var tb = $(table).next("table");
    	if (tb[0] && !tb[0].style.marginTop) {
    		tb.css("margin-top", "-1px");
    	}
        $(table).next("form").children("table")[0].style.marginTop="-1px"
    }catch(e){}

	// 替换排序规则后的下三角
	try{
		$('img[src="../images/i10.gif"]:not(.resetElementHidden)').addClass('resetElementHidden').after($('<img class="resetElementShowNoAlign" style="display:none" src="../skin/default/images/MoZihometop/content/r_down2.png" width="9" height="5" border="0">'))
	}catch(e){}

	// 替换上一页下一页按钮的图片
	try{
		$('img[src="../images/main_2.gif"]:not(.resetElementHidden)').attr('src','../skin/default/images/ico16/lvwbar_1_1.png')
		$('img[src="../images/main_1.gif"]:not(.resetElementHidden)').attr('src','../skin/default/images/ico16/lvwbar_4_1.png')
	}catch(e){}
	
	// 替换添加明细旁边的蓝色小箭头
	try{
		$('img[src="../images/jiantou.gif"]').css({'verticalAlign':'-4px','width':'16px','height':'16px'})
		$('img[src="../images/jiantou.gif"]').attr('src','../skin/default/images/MoZihometop/content/lvw_addrow_btn.png')
	}catch(e){}

	// 把短信页面左侧菜单栏的图片背景去掉
	try{
		$('td[background="../images/m_leftbg.gif"]').attr('background','');
		$('img[src="../images/m_leftb.gif"]').hide();
	}catch(e){}

	// 把高级检索左侧的蓝色小箭头替换成黑色 把高级检索的红色字变成蓝色
	try{
		$('img[src="../images/icon_title.gif"]').attr('src','../skin/default/images/MoZihometop/leftNav/expand.png');
	}catch(e){}

	// SYSA/store/top6.asp中修改表格的背景和边框颜色
	try{
		$('td[background="../images/m_table_top.jpg"]').css({'background':'#ebebeb','borderColor':'#dcdcdc'})
	}catch(e){}

})
