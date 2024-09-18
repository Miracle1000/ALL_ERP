//全局对象
window.BusiMarketJson = {
  timeFrame: "本年",
  refreshTime: 600000,
  costomer: {
    comStaticDim: "区域",
    xdata: [],
    ydata: []
  },
  finance: {
    finCostDim: "费用",
    line: {
      xdata: [],
      ydata: []
    },
    pie: {
      data: []
    }
  },
  goods: {
    pie: {
      data: []
    }
  },
  product: {
    xdata: [],
    ydata: []
  }
}
var saleOption = {
  title: {
    show: false
  },
  grid: {
    top: 50,
    bottom: 50,
    right: 50,
    left: 90
  },
  tooltip: {},
  legend: {
    show: false
  },
  xAxis: {
    data: [],
    axisLine: {
      lineStyle: {
        color: '#2A396C'
      }
    },
    axisLabel: {
      color: '#A4C3F6',
      interval: 0,
      formatter: function (value) {
          var l = getClipTextLen();
          if (value.length > l) { return (value + "").slice(0, l) + "..." }
          return value
      }
    },
    name:BusiMarketJson.costomer.comStaticDim,
    nameTextStyle: {
      color: '#ccc'
    }
  },
  yAxis: {
    name:"金额/万元",
    nameTextStyle: {
      color: '#ccc'
    },
    axisLine: {
      lineStyle: {
        color: 'transparent'
      }
    }, //坐标轴线颜色
    splitLine: {
      lineStyle: {
        color: '#2A396C'
      }
    }, //y分割线颜色
    axisLabel: {
      color: '#A4C3F6'
    } //y轴文字颜色
  },
  series: [{
    type: 'bar',
    data: [],
    name: "区域",
    smooth: true,
    symbolSize: 5,
    itemStyle: {
      normal: {
        color: new echarts.graphic.LinearGradient(0, 1, 0, 0, [{
          offset: 0,
          color: "#017EFF" // 0% 处的颜色
        }, {
          offset: 1,
          color: "#00D8FE" // 100% 处的颜色
        }], false)
      }
    },
    barMaxWidth: '60%',
    barMaxWidth: '30'
  }]
};
var fCashOption = {
  tooltip: { //提示
    trigger: 'axis',
  },
  grid: {
    top: 50,
    bottom: 50,
    right: 60,
    left: 90
  },
  color: ["#A1FF4D", "#00EAFF", "#A800FF"],
  legend: {
    orient: 'horizontal',
    show: true,
    x: 'right',
    y: 'top',
    data: ['收入', '支出', '余额'],
    textStyle: {
      color: '#ccc'
    }
  },
  xAxis: {
    name: '月份',
    type: 'category',
    boundaryGap: false,
    data: [],
    axisLine: {
      lineStyle: {
        color: '#2A396C'
      }
    },
    axisLabel: {
      color: '#A4C3F6',
      interval: 0
    },
    nameTextStyle: {
      color: '#ccc',
      fontStyle: 'normal'
    }
  },
  yAxis: {
    name: '金额/万元',
    axisLine: {
      lineStyle: {
        color: 'transparent'
      }
    }, //坐标轴线颜色
    splitLine: {
      lineStyle: {
        color: '#2A396C'
      }
    }, //y分割线颜色
    axisLabel: {
      color: '#A4C3F6'
    }, //y轴文字颜色
    nameTextStyle: {
      color: '#ccc',
      fontStyle: 'normal'
    } //坐标轴名称文字样式
  },
  series: [{
    name:'收入',
    data: [],
    type: 'line',
    symbolSize: 5
  }, {
    name:'支出',
    data: [],
    type: 'line',
    symbolSize: 5
  }, {
    name:'余额',
    data: [],
    type: 'line',
    symbolSize: 5
  }]
}
var fCostOption = {
  tooltip: {
    // show:false,
    trigger: 'item',
    formatter: '{a} <br/>{b}: {c} ({d}%)'
  },
  legend: {
    show: false
  },
  color: ["#F28B37", "#C260E7", "#5BBD2B", "#4472E8", "#A800FF"],
  series: [{
    name: '费用',
    type: 'pie',
    radius: ['34%', '50%'],
    center: ['50%', 120],
    label: {
      show: true,
      normal: {
          formatter: function (obj) {
              var reg = /[^\x00-\xff]/;
              var v = "\n◼" + " " + obj.name, l = v.replace(/[^\x00-\xff]/g, "__").length;
              var snum = getClipTextLen(1)
              if (l > snum) {
                  for (var i = 0, c = 0; i < v.length; i++) {
                      if (reg.test(v[i])) { c += 2 } else { c++ }
                      if (c > snum) { v = v.slice(0, i - 1) + "..."; break }
                  }
              }
              var value = v + "\n" + obj.value + "，" + obj.percent + "%";
              return value;
          },
      },
      lineHeight: 56
    },
    emphasis: {
      label: {
        show: true
      }
    },
    data: []
  }]
}
var goodsOption = {
    tooltip: {
        // show:false,
        trigger: 'item',
        formatter: '{b}: {c} ({d}%)'
    },
    color: ["#F28B37", "#C260E7", "#5BBD2B", "#4472E8", "#FF7F6A"],
    legend: {
        show: false
    },
    series: [{
        type: 'pie',
        radius: ['34%', '50%'],
        center:['50%',190],
        label: {
            show: true,
            normal: {
                formatter: function (obj) {
                    var reg=/[^\x00-\xff]/;
                    var v = "\n◼" + " " + obj.name, l = v.replace(/[^\x00-\xff]/g, "__").length;
                    var snum = getClipTextLen(1)
                    if (l > snum) {
                        for (var i = 0, c = 0; i <v.length; i++) {
                            if (reg.test(v[i])) { c += 2 } else { c++ }
                            if (c > snum) { v = v.slice(0, i-1) + "..."; break }
                        }
                    }
                    var value = v + "\n" + obj.value + "，" + obj.percent + "%";
                    return value;
                }
      },
      lineHeight: 15,
    },
    emphasis: {
      label: {
        show: true
      }
    },
    data: []
  }]
};
var productOPtion = {
  title: {
    show: false
  },
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'line'
    }
  },
  color: ["#2AF2FF"],
  legend: {
    show: false
  },
  grid: {
    left: '3%',
    right: '8%',
    bottom: '2%',
    top: '8',
    containLabel: true
  },
  xAxis: [{
    type: 'category',
    boundaryGap: false,
    data: [],
    axisLine: {
      lineStyle: {
        color: '#2A396C'
      }
    },
    axisLabel: {
      color: '#A4C3F6',
      interval: 0
    }
  }],
  yAxis: [{
    type: 'value',
    axisLine: {
      lineStyle: {
        color: 'transparent'
      }
    }, //坐标轴线颜色
    splitLine: {
      lineStyle: {
        color: '#2A396C'
      }
    }, //y分割线颜色
    axisLabel: {
      color: '#A4C3F6'
    } //y轴文字颜色
  }],
  series: [{
    type: 'line',
    stack: '总量',
    areaStyle: {},
    smooth: true,
    symbolSize: 5,
    showSymbol: false,
    data: []
  }]
}

//全屏
function fullScreen(){
  var el = document.documentElement;
  var rfs = el.requestFullScreen || el.webkitRequestFullScreen || el.mozRequestFullScreen;//|| el.msRequestFullscreen;ie11、ie10全屏
      if(typeof rfs != "undefined" && rfs) {
          rfs.call(el);
      }else {
          alert("该浏览器暂不支持全屏方法，请使用'F11'完成全屏操作。")
      }
  return;
}
//退出全屏
function exitScreen(){ 
  if (document.exitFullscreen) {  
      document.exitFullscreen();  
  }  
  else if (document.mozCancelFullScreen) {  
      document.mozCancelFullScreen();  
  }  
  else if (document.webkitCancelFullScreen) {  
      document.webkitCancelFullScreen();  
  } else { alert("请按'F11'退出全屏。") }//document.msExitFullscreen,ie11、ie10退出全屏
}
//ie低版本的全屏，退出全屏都这个方法，暂不使用
//注：ie调用ActiveX控件，需要在ie浏览器安全设置里面把 ‘未标记为可安全执行脚本的ActiveX控件初始化并执行脚本’ 设置为启用
function iefull(){
    if(typeof window.ActiveXObject != "undefined") {
        //这的方法 模拟f11键，使浏览器全屏
        var wscript = new ActiveXObject("WScript.Shell");
        if (wscript != null && wscript.SendKeys) {
            wscript.SendKeys("{F11}");
        }
    }
}

//全屏非全屏切换
function changeScreen(a){
  var a=$("#conFulScrebtn")
  var className=a.attr("class");
  if(className.indexOf("nofullscreen")>=0){
    exitScreen();
    a.removeClass("nofullscreen");
  }else{
    fullScreen();
    a.addClass("nofullscreen");
  }
}
//设置时间校验
function checkValue(a) {
    var value=a.value.replace(/[^\d]/g, '');
    if (a.value != value) { a.value = value;}
}
//格式化小数位数
function formatData(v,t) {
    if (isNaN(v + "0")) {
        v = v + ""
        return v;
    }
    //转换单位为万元
    t?"":v = (v * 1 / 10000).toFixed(2);
    var s = (v + "").split(".");
    var result = '', counter = 0;
    s[0] = (s[0] || 0).toString();
    for (var i = s[0].length - 1; i >= 0; i--) {
        counter++;
        result = s[0].charAt(i) + result;
        if (result.indexOf("-,") == 0) { result = result.replace(",", "") }
        if (!(counter % 3) && i != 0) { result = ',' + result; }
    }
    var rs = result + (s[1] ? "." + s[1] : "");
    if (rs.indexOf("-") == 0 && rs * 1 == 0) {
        rs = rs.replace("-", ""); //过滤-0.0000 的情况
    }
    return rs;
}

//浏览器类型以及版本判断
function getBrowerVer () {
    var userAgent = navigator.userAgent; 
    var isIE = userAgent.indexOf("compatible") > -1 && userAgent.indexOf("MSIE") > -1;
    var isIE11 = userAgent.indexOf('Trident') > -1 && userAgent.indexOf("rv:11.0") > -1;
    if (isIE) {
        var reIE = new RegExp("MSIE (\\d+\\.\\d+);");
        reIE.test(userAgent);
        var fIEVersion = parseFloat(RegExp["$1"]);
        if (fIEVersion == 7) {
            return 7;
        } else if (fIEVersion == 8) {
            return 8;
        } else if (fIEVersion == 9) {
            return 9;
        } else if (fIEVersion == 10) {
            return 10;
        }
    } else if (isIE11) { return 11 } else { return 100 }
};

//label数据显示
function getClipTextLen(t) {
    var w = window.document.documentElement.clientWidth;
    if (t) {
        if (w < 1360) { return 16 } else if (w < 1500) { return 18 } else if (w < 1610) { return 24 } else if (w < 1840) { return 26 } else if (w < 2000) { return 28 } else { return 34 }
    };
    if (w >= 1920) { return 4 } else if (w >= 1850) { return 3 } else if (w >= 1500) { return 2 } else { return 1 }
}

//数组对象排序
function compare(a, b) {
    return a.TotalMoney - b.TotalMoney < 0 ? 1 : -1;
}
/*接口逻辑*************************************************************************************************** */
//刷新时间设置
//设置刷新时间间隔事件
function setRefime(){
  if($("#setTimeLayer")[0].offsetHeight){
    $("#rTime").val("");
    $("#setTimeLayer").css({display:"none"})
  }else{
    BusiMarketJson.preRefreshTime=BusiMarketJson.refreshTime
    $("#rTime").val(BusiMarketJson.preRefreshTime/60000);
    $("#setTimeLayer").css({display:"block"});
    $("#setTimeLayer .exTips").css({display:"none"})
  }
}

//保存
function saveRefTime(){
  var t=$("#rTime").val();
  if (t < 1 || t > 60) { var txt = t < 1 ? "不能小于1" : "不能大于60"; $("#setTimeLayer .exTips").html(txt).css({ display: "block" }); return }
  $("#setTimeLayer .exTips").css({display:"none"})
  if(t*60000==BusiMarketJson.preRefreshTime){$("#setTimeLayer").css({display:"none"}); return}
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=SaveRefreshIterval", { RefreshIterval:t}, function(data, status) {
      if (data) { $("#setTimeLayer").css({ display: "none" }); BusiMarketJson.refreshTime =t*60000}
  })
}

function getRefreshTime(){
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetRefreshIterval",function(data,status){
      BusiMarketJson.refreshTime = data * 1 * 60000 || BusiMarketJson.refreshTime;
      BusiMarketJson.refreshData();
  })
}

//获取时间范围
function getTimeCom() {
    var date = new Date();
    var year = date.getFullYear();
    var month = date.getMonth() * 1 + 1;
    month = month > 12 ? 1 : month;
    month = month > 9 ? month : '0' + month;
    var day = date.getDate();
    day = day > 9 ? day : '0' + day
    var hours=date.getHours();
    hours = hours > 9 ? hours : '0' + hours;
    var minutes=date.getMinutes();
    minutes = minutes > 9 ? minutes : '0' + minutes;
    var seconds = date.getSeconds();
    seconds = seconds > 9 ? seconds : '0' + seconds;
    var obj = BusiMarketJson.timeFrame == "本年" ?
  { start: year + "-" + "01-01", end: year + "-" + month + "-" + day + " " + "23:59:59", now: year + "-" + month + "-" + day + " " + hours + ":" + minutes + ":" + seconds } : { start: year + "-" + month + "-01", end: year + "-" + month + "-" + day + " " + "23:59:59", now: year + "-" + month + "-" + day + " " + hours + ":" + minutes + ":" + seconds };
    return obj
}

/*****************客 */
//客总额数据获取
function getCustomTotal(){
  var time=getTimeCom();
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetTotalSaleMoney",{StartTime:time.start,EndTime:time.end},function(data,status){
      $("#saleTotal").html(formatData(data.TotalMoney));
  });
}
//柱状图数据获取
function getCustomBar(){
  var w=BusiMarketJson.costomer.comStaticDim=="区域"?1:2;
  var time=getTimeCom();
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetSaleMoneyCompare",{StartTime:time.start,EndTime:time.end,CompareType:w},function(data,status){
    var isnull=handleData(data);
    slaeChart.hideLoading();
    if (isnull) { slaeChart.dispose(); $("#chartContainer").html("<div style='height:270px;line-height:280px;text-align:center;color:#ccc'><div style='line-height:1.5;display:inline-block;font-size:9px;'><img src='../skin/default/images/busiMarket/nomes.png'><br>暂无数据</div></div>"); return } else {
        if (!$("#chartContainer")[0].getAttribute('_echarts_instance_')) {
            slaeChart = echarts.init(document.getElementById('chartContainer'));
            slaeChart.setOption(saleOption);
        }
    }
    slaeChart.setOption({
      xAxis: {
        name:BusiMarketJson.costomer.comStaticDim,
        data: BusiMarketJson.costomer.xdata
      },
      series: [
        {
          // 根据名字对应到相应的系列
          name: BusiMarketJson.costomer.comStaticDim,
          data: BusiMarketJson.costomer.ydata
        }
      ]
    });
  });
}

//排名列表
function getCusTops3(){
  var time=getTimeCom();
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetSaleBestCustomer",{StartTime:time.start,EndTime:time.end},function(data,status){
    $("#customRank").html(handleRankData(data));
  });
}


/************人 */
//总额数据
function getPersonData() {
  var time = new Date().getFullYear();
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetHumanEffect", { StartTime: time+"-01-01", EndTime: time*1+1+"-01-01 00:00:00" }, function (data, status) {
      $("#perSaleTotal").html(formatData(data.TotalMoney));
      $("#perSaleTotal2").html(formatData(data.TotalMoney)).attr('title', formatData(data.TotalMoney)+"万元");
      $("#peopleTol").html(formatData(data.TotalPeople,1) + " 人").attr('title', formatData(data.TotalPeople, 1) + "人");
      $("#average").html(formatData(data.AverageMoney)).attr('title', formatData(data.AverageMoney) + "万元");
  });
}
//排名列表
function getStaffTop() {
    var time = new Date().getFullYear();
    $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetHumanEffectBest", { StartTime: time + "-01-01", EndTime: time * 1 + 1 + "-01-01 00:00:00" }, function (data, status) {
    $("#personRank").html(handleRankData(data));
  });  
}

/************财*/
//总额
function getCashTotal() {
    $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetCurrentCash", function (data, status) {
      $("#cashBankTotal").html(formatData(data.CashTotal));
      $("#receivableTotal").html(formatData(data.ShouldRecevice));
      $("#payableTotal").html(formatData(data.ShouldPay));
  }); 
}

//折线图
function getCashLine() {
    $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetCashTrend", function (data, status) {
    var isnull=handleLineData(data);
    fCashChart.hideLoading();
    if (isnull) { fCashChart.dispose(); $("#chartContainer_cash").html("<div style='height:250px;line-height:260px;text-align:center;color:#ccc'><div style='line-height:1.5;display:inline-block;font-size:9px;'><img src='../skin/default/images/busiMarket/nomes.png'><br>暂无数据</div></div>"); return } else {
        if (!$("#chartContainer_cash")[0].getAttribute('_echarts_instance_')) {
            fCashChart = echarts.init(document.getElementById('chartContainer_cash'));
            fCashChart.setOption(fCashOption);
        }
    }
    fCashChart.setOption({
      xAxis:{
        data:BusiMarketJson.finance.line.xdata
      },
      series:BusiMarketJson.finance.line.ydata
    })
  });  
}

//饼图
function getCashPie(){
  var time=getTimeCom();
  var wp = BusiMarketJson.finance.finCostDim=="费用"?1:(BusiMarketJson.finance.finCostDim=="收入"?2:3);
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetFeeDistribute", { StartTime: time.start, EndTime: time.end, Type: wp }, function (data, status) {
   var isnull=handlefPieData(data);
   fCostChart.hideLoading();
   if (isnull) { fCostChart.dispose(); $("#chartContainer_cost").html("<div style='height:220px;line-height:250px;text-align:center;color:#ccc'><div style='line-height:1.5;display:inline-block;font-size:9px;'><img src='../skin/default/images/busiMarket/nomes.png'><br>暂无数据</div></div>"); return; } else {
       if (!$("#chartContainer_cost")[0].getAttribute('_echarts_instance_')) {
           fCostChart = echarts.init(document.getElementById('chartContainer_cost'));
           fCostChart.setOption(fCostOption);
       }
   }
    fCostChart.setOption({
      series:{
        name:BusiMarketJson.finance.finCostDim,
        data:BusiMarketJson.finance.pie.data
      }
    })
  });  
}

//利润分析
function getProfitData() {
    var t = BusiMarketJson.timeFrame == "本年" ? 2 : 1;
    $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetProfitAnalysis", {Type:t}, function (data, status) {
      var unit = "万元"
      var dat = [];
      var str=t==1?"月":"年"
    if (data && status == "success") {
        dat[0] = "                  <tr>\n"
        dat[1] = "                    <td class=\"firstCell\">\n"
        dat[2] = "                      <div class=\"analysis\">\n"
        dat[3] = "                        <p>本" + str + "收入</p>\n"
        dat[4] = "                        <p><span id=\"monIncome\" class=\"blue\" title='"+formatData(data.CurIncome)+"万元'>" + formatData(data.CurIncome) + "</span>&nbsp;<span class=\"blue\">万元</span></p>\n"
        dat[5] = "                        <p>比上" + str + ": <span class=\"analyTrend " + (data.IncomeChange >= 0 ? "up" : "down") + "\"></span> <span id=\"monIncomeAnaly\" class=\"" + (data.IncomeChange >= 0 ? "green" : "orange") + "\" title='" + formatData(data.IncomeChange) + "万元'>" + formatData(Math.abs(data.IncomeChange)) + "万元</span></p>\n"
        dat[6] = "                      </div>\n"
        dat[7] = "                    </td>\n"
        dat[8] = "                    <td>\n"
        dat[9] = "                      <div class=\"analysis\">\n"
        dat[10] = "                        <p>本" + str + "成本</p>\n"
        dat[11] = "                        <p><span class=\"blue\" id=\"monCost\" title='" + formatData(data.CurCost) + "万元'>" + formatData(data.CurCost) + "</span>&nbsp;<span class=\"blue\">万元</span></p>\n"
        dat[12] = "                        <p>比上" + str + ": <span class=\"analyTrend " + (data.CostChange >= 0 ? "up" : "down") + "\"></span> <span id=\"monCostAnaly\" class=\"" + (data.CostChange >= 0 ? "green" : "orange") + "\" title='" + formatData(data.CostChange) + "万元'>" + formatData(Math.abs(data.CostChange)) + "万元</span></p>\n"
        dat[13] = "                      </div>\n"
        dat[14] = "                    </td>\n"
        dat[15] = "                    <td>\n"
        dat[16] = "                      <div class=\"analysis\">\n"
        dat[17] = "                        <p>本" + str + "利润</p>\n"
        dat[18] = "                        <p><span  id=\"monProfit\" class=\"blue\" title='" + formatData(data.CurProfit) + "万元'>" + formatData(data.CurProfit) + "</span>&nbsp;<span class=\"blue\">万元</span></p>\n"
        dat[19] = "                        <p>比上" + str + ": <span class=\"analyTrend " + (data.ProfitChange >= 0 ? "up" : "down") + "\"></span> <span id=\"monProfitAnaly\" class=\"" + (data.ProfitChange >= 0 ? "green" : "orange") + "\" title='" + formatData(data.ProfitChange) + "万元'>" + formatData(Math.abs(data.ProfitChange)) + "万元</span></p>\n"
        dat[20] = "                      </div>\n"
        dat[21] = "                    </td>\n"
        dat[22] = "                    <td class=\"lastCell\">\n"
        dat[23] = "                      <div class=\"analysis\">\n"
        dat[24] = "                        <p>本" + str + "利润率</p>\n"
        dat[25] = "                        <p><span id=\"monProfitMargin\" class=\"blue\" title='" + data.CurProfitRatio.toFixed(2) + "%'>" + data.CurProfitRatio.toFixed(2) + "</span>&nbsp;<span class=\"blue\">%</span></p>\n"
        dat[26] = "                        <p>比上" + str + ": <span class=\"analyTrend " + (data.ProfitRatioChange >= 0 ? "up" : "down") + "\"></span> <span id=\"monProfitMarginAnaly\" class=\"" + (data.ProfitRatioChange >= 0 ? "green" : "orange") + "\" title='" + data.ProfitRatioChange.toFixed(2) + "%'>" + Math.abs(data.ProfitRatioChange).toFixed(2) + "%</span></p>\n"
        dat[27] = "                      </div>\n"
        dat[28] = "                    </td>\n"
        dat[29] = "                  </tr>\n"

        $("table.profitAnalysisTable").html(dat.join(""));
    }
  });   
}

/************货 */
//总额
function getGoodsTotal() {
    var time = getTimeCom();
    $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetAllCost", { StartTime: time.start, EndTime: time.end }, function (data, status) {
      $("#stockTurnover").html(data.InventoryTurnover.toFixed(2));
      $("#storeTotalCost").html(formatData(data.StockAllCost))
  }); 
}

//饼图
function getGoodsPie() {
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetStockCostDistribute", { StartTime: "1990-01-01", EndTime: "2121-01-01 00:00:00" }, function (data, status) {
    var isnull = handlefPieData(data,1);
    goodsChart.hideLoading();
    if (isnull) { goodsChart.dispose(); $("#chartContainer_goods").html("<div style='height:220px;line-height:260px;text-align:center;color:#ccc'><div style='line-height:1.5;display:inline-block;font-size:9px;'><img src='../skin/default/images/busiMarket/nomes.png'><br>暂无数据</div></div>"); return } else {
        if (!$("#chartContainer_goods")[0].getAttribute('_echarts_instance_')) {
            goodsChart = echarts.init(document.getElementById('chartContainer_goods'));
            goodsChart.setOption(goodsOption);
        }
    }
    goodsChart.setOption({
      series:{
        data:BusiMarketJson.goods.pie.data
      }
    })
  });  
}
//排名列表
function getGoodsTop() {
    var time = getTimeCom();
    $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetBestSellers", { StartTime: time.start, EndTime: time.end }, function (data, status) {
    $("#goodsTop").html(handleRankData(data,1));
  }); 
}

/******************产 */
//总额
function getProductOrd() {
  var time = new Date().getFullYear();
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetOrderRemind", { StartTime: time + "-01-01", EndTime: time * 1 + 1 + "-01-01 00:00:00" }, function (data, status) {
      $("#overOrdNum").html(data.OverDueOrders||0);
      $("#urgetOrdNum").html(data.RushOrders||0)
      $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=CanAccessOrderList", function (data2, status) {
          if (data2 * 1) { $("#urgetOrdNum").html("<div class='blue2' style='cursor:pointer;display:inline-block;padding:0 4px;' onclick='window.open(\"../../SYSN/view/produceV2/ManuOrders/ManuOrdersList.ashx?ProduceBoardType=2\",\"\",\"height=800,width=1200,scrollbars=1,resizable=1,top=100,left=60\")'>" + (data.RushOrders||0) + "</div>"); }
      })
  }); 
}

//面积图
function getProductVity(){
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetProductivity",function(data,status){
    var isnull=handleAreaData(data);
    productChart.hideLoading();
    if (isnull) { productChart.dispose(); $("#productChart").html("<div style='height:160px;line-height:180px;text-align:center;color:#ccc'><div style='line-height:1.5;display:inline-block;font-size:9px;'><img src='../skin/default/images/busiMarket/nomes.png'><br>暂无数据</div></div>"); return } else {
        if (!$("#productChart")[0].getAttribute('_echarts_instance_')) {
            productChart = echarts.init(document.getElementById('productChart'));
            productChart.setOption(productOPtion);
        }
    }
    productChart.setOption({
      xAxis: {
        data: BusiMarketJson.product.xdata
      },
      series: [
        {
          data: BusiMarketJson.product.ydata
        }
      ]
    })
  }); 
}

/***************预警 */
function getRiskWarn(){
  var time=getTimeCom();
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=GetRiskWarn",function(data,status){
    $("#warnShow").html(handleWarnHtml(data))
  }); 
}


/**统计图形数据处理 */
function handleData(datas){
    if (!datas || !datas.length) { return true;}
 var data = {}; x = []; y = [];
 var len = datas.length > 10 ? 10 : datas.length;
 datas.sort(compare);
 for (var i = 0; i < len; i++) {
  data=datas[i];
  x.push(data.CompareName||"");
  y.push((data.TotalMoney*1/10000).toFixed(2) || 0);
 }
 BusiMarketJson.costomer.xdata=x;
 BusiMarketJson.costomer.ydata=y
}

//排名数据处理t=0,1((客/人=0)，货)
function handleRankData(obj, t) {
  if (!obj || !obj.length) { return "<tr><td><div style='height:100px;line-height:166px;text-align:center;color:#ccc'><div style='line-height:1.5;display:inline-block;font-size:9px;'><img src='../skin/default/images/busiMarket/nomes.png'><br>暂无数据</div></div></td></tr>" }
  var str="",ord,name,money,percent;
  for(var i=0;i<obj.length;i++){
    ord=obj[i]["Order"];
    if(t){
      name=obj[i]["ProductName"];
      percent=(obj[i]["InventoryDays"]).toFixed(2)+"天/次";
    }else{
      name=obj[i]["Name"];
      money=obj[i]["TotalMoney"];
      percent=obj[i]["Ratio"];
    }
    str  += "<tr>\n"
    str  += "   <td class='rank'><div class='tableText'><span class=\"topRank ranking"+(i*1+1)+"\"></span>0"+ord+"</div></td>\n"
    str  += "   <td class='name'><div class='tableText' title='"+(name||"")+"'>"+ (name||"") +"</div></td>\n"
    str += t ? "" : ("   <td class='money'><div class='tableText' title='" + formatData(money) + "万元'>" + formatData(money) + " 万元</div></td>\n")
    str += "   <td class='other'><div class='tableText' title='" + (t ? percent : "贡献：" + (percent * 100).toFixed(2) + "%") + "'>" + (t ? percent : "贡献：" + (percent * 100).toFixed(2) + "%") + "</div></td>\n"
    str  += "</tr>\n"
  }
  return str
}

//折线数据处理
function handleLineData(datas){
  if(!datas||!datas.length){return true;}
  var month=[],income=[],expense=[],balance=[],data,m,y="";
  for(var i=0;i<datas.length;i++){
    data=datas[i];
    m = data.Month.split("-");
    if (i == 0) { y = m[0] + "年" } else { y = "" };
    m=y+(m[1][0]==0?m[1].replace("0",""):m[1])+"月"
    month.push(m);
    income.push((data.Income*1/10000).toFixed(2)||0);
    expense.push((data.Expense * 1 / 10000).toFixed(2));
    balance.push((data.Balance * 1 / 10000).toFixed(2));
  }
  BusiMarketJson.finance.line.ydata=[{data:income},{data:expense},{data:balance}]
  BusiMarketJson.finance.line.xdata=month;
}

//财务饼图数据处理
function handlefPieData(datas,t){
 if (!datas || !datas.length) { return true;}
 var data=[];
 for(var i=0;i<datas.length;i++){
     data.push(t ? { value: (datas[i].Cost * 1 / 10000).toFixed(2) || 0, name: datas[i].ProductSort } : { value: (datas[i].TypeItemMoney* 1 / 10000).toFixed(2) || 0, name: datas[i].TypeItemName, ratio: datas[i].Ratio })
 }
 t?BusiMarketJson.goods.pie.data=data:BusiMarketJson.finance.pie.data=data;
}

//面积图数据处理
function handleAreaData(datas){
  if(!datas||!datas.length){return true}
  var x=[],y=[],m,year;
  for (var i = 0; i < datas.length; i++) {
    m = datas[i].Month.split("-");
    if (i == 0) { year = m[0] + "年" } else { year = ""; }
    m = year + (m[1][0] == 0 ? m[1].replace("0", "") : m[1]) + "月"
    x.push(m);
    y.push((datas[i].Money * 1 / 10000).toFixed(2) || 0)
  }
  BusiMarketJson.product.xdata=x;
  BusiMarketJson.product.ydata=y
}


//预警处理
function handleWarnHtml(datas){
    if (!datas || !datas.length) { return "<div style='height:100px;line-height:136px;text-align:center;color:#ccc'><div style='line-height:1.5;display:inline-block;font-size:9px;'><img src='../skin/default/images/busiMarket/nomes.png'><br>暂无数据</div></div>" }
 var str="<table class='warnTable'><tr>",name,target;
 for(var i=0;i<datas.length;i++){
  name=datas[i].WarnFlag==1?"normal":(datas[i].WarnFlag==2?"danger":"warning");
  target = datas[i].TargetName;
  str += " <td><div class=\"" + name + " con\">\n"
  var u = target.indexOf("生产逾期") >= 0 ? "个" : (target.indexOf("库存周转") >= 0?"次":"万元");
  var value = (u == "次" ? (datas[i].Actual * 1).toFixed(2) : datas[i].Actual)
  var actualValue = formatData(value, u == "万元" ? 0 : 1);
  str += "       <p class=\"completeNum warnMoneyStyle\" title='" + actualValue + u + "'>" + actualValue + "<span style='font-size:12px;transform:scale(0.8)'>&nbsp;" + u + "</span></p>\n"
  var isSale = target.indexOf("销售目标") >= 0 ? true : false;
  str += "       <p class='warnMoneyStyle' title='" + (isSale ? "目标：" + formatData(datas[i].Target, 1) + datas[i].UnitName : target) + "'>" + (isSale ? "目标：" + formatData(datas[i].Target, 1) + datas[i].UnitName : target) + "</p>\n"
  str += " </div></td>"
 }
 str +="</tr></table>"
 return str
}

/*切换刷新逻辑********************************************************************** */
BusiMarketJson.getRefreshTime=function(){
  getRefreshTime();
}
BusiMarketJson.getCustomData=function(){
  getCustomTotal();
  getCustomBar();
  getCusTops3();
}

BusiMarketJson.getPersonData=function(){
  getPersonData();
  getStaffTop();
}

BusiMarketJson.getFinaceData=function(){
  getCashTotal();
  getCashLine();
  getCashPie();
  getProfitData();
}

BusiMarketJson.getGoodsData=function(){
  getGoodsTotal();
  getGoodsPie();
  getGoodsTop();
}

BusiMarketJson.getProductData=function(){
  getProductOrd();
  getProductVity();
}

BusiMarketJson.getWarnData=function(){
  getRiskWarn();
}

//单选按钮切换--年/月
function changeTimeDim(a){
  //处理一下起始时间
  BusiMarketJson.timeFrame=a.value;
  BusiMarketJson.getCustomData();
  getCashPie();
  getProfitData();
  getGoodsTotal();
  getGoodsTop();
}

//单选按钮切换--柱形图
function changeDim(a){//客户
  BusiMarketJson.costomer.comStaticDim=a.value;
  getCustomBar();
}

//单选按钮切换--财务饼图
function changeCost(a){
  BusiMarketJson.finance.finCostDim=a.value;
  getCashPie();
}

BusiMarketJson.initPage = function () {
  BusiMarketJson.getCustomData();
  BusiMarketJson.getPersonData();
  BusiMarketJson.getFinaceData();
  BusiMarketJson.getGoodsData();
  BusiMarketJson.getProductData();
  BusiMarketJson.getWarnData();
  $("#lastRefreshTime").html(getTimeCom().now)
}

BusiMarketJson.refreshData=function(){
  BusiMarketJson.initPage();
  setTimeout(function(){BusiMarketJson.refreshData()},BusiMarketJson.refreshTime)
}


//图标自适应事件
window.onresize = function () {
    slaeChart.resize();
    fCashChart.resize();
    fCostChart.resize();
    goodsChart.resize()
    productChart.resize();
}

function initDoc(){
  $.get("../../SYSN/json/comm/MoZiBoardApi.ashx?actionName=InitAlarmSetting",function(data,status){
    BusiMarketJson.getRefreshTime();
  })
}
initDoc()

$(function () {
    if (getBrowerVer() < 100) { $("div.topContainer").css('height', '90px'); $(".areaboxs .manageWarn .title").css("marginBottom", "14px"); $(".manageWarn .manageStatus>div").css("marginBottom","0px") }
})