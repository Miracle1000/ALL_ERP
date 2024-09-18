var vml_currup_pie = null;
var vml_pieup_count = 0;
var vml_pieup_deep = 0;
var vml_pieup_otop = 0;
var vml_pieup_thwnd = 0;
function vml_pieupTimer() {
	var id = vml_currup_pie.id;
	var tobj = document.getElementById(id + "_txt");
	if(vml_pieup_deep>=vml_pieup_count ) { 
		__vmtxtv(tobj,1);
		return; 
	}
	vml_pieup_deep ++;
	vml_pieup_otop --;
	vml_currup_pie.style.top = vml_pieup_otop + "px";
	var ntop = (tobj.getAttribute("oTop")*1 - vml_pieup_deep) + "px";
	tobj.style.top = ntop;
	document.getElementById(id + "_l1").style.top = ("-" + vml_pieup_deep + "px");
	document.getElementById(id + "_l2").style.top = ("-" + vml_pieup_deep + "px");

	vml_pieup_thwnd = setTimeout("vml_pieupTimer()",20); 
}

function vml_pieover(shape) {
	vml_currup_pie = shape;
	vml_pieup_count = parseInt(shape.getAttribute("deep")*0.6);
	vml_pieup_otop = parseInt(shape.getAttribute("oTop"));
	vml_pieup_deep = 0;
	vml_pieup_thwnd = setTimeout("vml_pieupTimer()",20);
}

function vml_pieout(shape) {
	clearTimeout(vml_pieup_thwnd);
	var id = shape.id;
	shape.style.top = shape.getAttribute("oTop") + "px";
	var tobj = document.getElementById(id + "_txt");
	var ntop = (tobj.getAttribute("oTop")*1) + "px";
	tobj.style.top = ntop;
	document.getElementById(id + "_l1").style.top = ("0px");
	document.getElementById(id + "_l2").style.top = ("0px");
	__vmtxtv(tobj,0);
}
function __vmtxtv(item, t){
	if(t==1) {
		item.style.backgroundColor = "#fff";
		item.style.zIndex = 200001;
		item.style.border = "1px solid #aaaabb";
		item.style.cursor = "default";
	}else{
		item.style.backgroundColor = "transparent";
		item.style.zIndex = 100001;
		item.style.border = "0px";
		item.style.cursor = "";
	}
}
function vmp_focus(div) {
	var objs = document.getElementsByTagName("div");
	for (var i = 0; i < objs.length ; i++ )
	{
		var item = objs[i];
		if(item.name == div.name) {
			if(item==div) {
				item.style.zIndex = 100;
			}
			//else{
				//item.style.zIndex = 0;
			//}
		}
	}
}


// 调用统计图插件
// sType : 统计图类型 1.柱形图；2.折线图；3.饼图
// xName : 类目名称
// xValue : 值
function showECharts(sType,xName,xValue,charsID){
		var o = eval("("+ xValue +")");
        // 基于准备好的dom，初始化echarts实例
        var myChart = echarts.init(document.getElementById(charsID));

        // 指定图表的配置项和数据
        var option = {
            title: {
                text: ''
            },
            tooltip: {
				formatter: '{b}：{c}'
			},
//          legend: {
//				data:['销量']
//          },
			color: ['#5dc901','#4899eb','#6f36db','#d42ad1','#8b531a','#f35a4a','#999999','#cd0300','#f48f01','#f0e100'],
			calculable : true,
            xAxis: {
				name : "",
				type : 'category',
				axisTick: {
					interval : 0
				},
				axisLabel: {
					interval:0,
					rotate: 45	// 类目名称倾斜度
				},
                data: ["中国","日本"]
            },
            yAxis: {
				name : ""
			},

			grid: {
				left: '50px',
				right: '10%',
				bottom: '100px',
				containLabel: true
			},
            series: [
				{
					name: '销量',
					type: sType,
//					barMinHeight: 2,
					barWidth : '40',
					itemStyle : {
						normal : {
							color : "#7cb5ed",
							label : {
								show: true, 
								position: 'top'
							}
						},
						emphasis: {
							shadowBlur: 10,
							shadowOffsetX: 0,
							shadowColor: 'rgba(0, 0, 0, 0.5)'
						}
					},


					data:o

				}
			]
        };
		
		

		// 饼图特殊设置
		if(sType == "pie"){
			option.xAxis = null;
			option.yAxis = null;
			option.series[0].itemStyle.normal = null;
			option.series[0].radius = "60%";
			option.tooltip.formatter = '{b}：{c}({d}%)';
		};
		// 使用刚指定的配置项和数据显示图表。
        myChart.setOption(option);
		//console.log(myChart)

        function eConsolePieClick(e) {
			//console.log(e); // 3.0 e有嵌套结构，不可以JSON.stringify
			if(e.data.url){
				window.location.href = e.data.url
			};
        }
        myChart.on('click',  eConsolePieClick); // 点击事件绑定 与2.0不同

};