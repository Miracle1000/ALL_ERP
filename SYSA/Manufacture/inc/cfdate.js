var dlistReadMode = false //是否是只读模式
var js = document.createElement("script")
js.language = "javascript"
js.src= "nldate.js"
document.getElementsByTagName("head")[0].appendChild(js)

var works = [["默认上级","white","#000",0],["正常工作","#ffeeee","#000",1],["普通加班","#00ff00","#000",2],["周末加班","#ffdd44","#000",3],["节日加班","#ffff66","#000",4],["周末放假","#0000cc","#fff",5],["法定假日","#333388","#fff",6],["其它假日","#6666aa","#fff",7]]
var Fl = new Array()  //阳历生日
Fl[0] = [[1,"元旦"]]
Fl[1] = [[14,"情人节"]]
Fl[2] = [[8,"妇女节"],[12,"植树节"],[15,"消费者日"]]
Fl[4] = [[1,"劳动节"],[4,"中国青年节"]]
Fl[5] = [[1,"儿童节"]]
Fl[6] = [[1,"建党节"]]
Fl[7] = [[1,"建军节"],[12,"国际青年节"]]
Fl[8] = [[10,"中国教师节"],[27,"世界旅游日"]]
Fl[9] = [[1,"国庆节"],[5,"世界教师节"],[31,"万圣节"]]
Fl[11] = [[25,"圣诞节"]]

var Nl = new Array()
Nl[0] = [[1,"春节"],[15,"元宵节"]]
Nl[4] = [[5,"端午节"]]
Nl[6] = [[7,"迄巧节"]]
Nl[7] = [[15,"中秋节"]]
Nl[9] = [[9,"重阳节"]]

//界面级刷新
function bill_onLoad(){

	dlistReadMode = document.getElementById('Bill_Info_readonly').value*1 > 0 

	var p = document.getElementById("rlSetPanel");
	if(!p){return false}
	var cRow = p.parentElement.parentElement
	cRow.previousSibling.cells[0].style.display = "none"

	p.innerHTML = "<div style='display:block'><div style='height:10px;overflow:hidden'></div><div>" + WorkDayTypePanel() + "</div><div style='height:10px;overflow:hidden'></div><div id='datelistTable'></div></div><div style='height:10px;overflow:hidden'></div>";
	//p.parentElement.style.backgroundImage = "url(../../images/m_tbg5.gif)";
	p.onmousedown = function(){window.currwcursorselect = 1;}
	//p.onmouseout = function(){if(window.event.srcElement.)window.currwcursorselect = 0; }
	p.onmouseup = function(){window.currwcursorselect = 0;}
	window.currwcursor = 0  //刷子类型
	window.currwtypebutton = document.getElementsByName("wtypebutton")[0]

	var d1 = document.getElementsByName("MT5")[0]
	var d2 = document.getElementsByName("MT6")[0]

	d1.attachEvent("onpropertychange",UpdateFcDateList);
	d2.attachEvent("onpropertychange",UpdateFcDateList);
	

	

	if(document.getElementById("MT9_MFRadio0")){ 

		document.getElementById("MT9_MFRadio0").onmouseup = function(){
			document.getElementsByName("MT10")[0].value = ""
			document.getElementsByName("MT10")[0].title = ""
			window.UpdateFcDateList();
		}

		document.getElementById("MT9_MFRadio1").onmouseup = function(){
			document.getElementsByName("MT10")[0].value = ""
			document.getElementsByName("MT10")[0].title = ""
			window.UpdateFcDateList();
		}

		document.getElementById("MT9_MFRadio2").onmouseup = function(){
			document.getElementsByName("MT10")[0].value = ""
			document.getElementsByName("MT10")[0].title = ""
			window.UpdateFcDateList();
		}

		document.getElementById("MT9_MFRadio3").onmouseup = function(){
			document.getElementsByName("MT10")[0].value = ""
			document.getElementsByName("MT10")[0].title = ""
			window.UpdateFcDateList();
		}
	}
	window.currseldate1 = ""
	window.currseldate2 = ""
 	window.UpdateFcDateList();

	Bill.onsave = updatelvwArrayByDateList
}
//从列表获取数据
function GetArrayDataFromListView(){
	var div = document.getElementById("listview_71")
	lvw.TryCreateHiddenPageDataToArray(div);
	window.wdlistArray = new Array() //用于存放列表数据
	for (var i=0;i<div.hdataArray.length ;i++ )
	{
		window.wdlistArray[i] = div.hdataArray[i].slice(2,6)
		for(var ii=0;ii<4;ii++){
			window.wdlistArray[i][ii]=window.wdlistArray[i][ii].replace(lvw.sBoxSpr,"")
		}
	}
	
}

//列表级刷新
function UpdateFcDateList(){
	var d1 = document.getElementsByName("MT5")[0]
	var d2 = document.getElementsByName("MT6")[0]
	var oTag = 0;
	if(!window.currseldate1){ window.currseldate1= d1.value;oTag=1;}
	if(!window.currseldate2){ window.currseldate2= d2.value;oTag=1;}
	if(window.currseldate1==d1.value && window.currseldate2==d2.value&&oTag!=1){
		return ;
	}
	window.currseldate1= d1.value
	window.currseldate2= d2.value

	var p = document.getElementById("datelistTable");
	if(d1.value.IsDate() ==false || d2.value.IsDate()==false){
		p.innerHTML = "<span>需要选择或输入正确的起始日期和截止日期，然后才能设置日历。</span>"
		return;
	}
	var d1 = new Date(d1.value.replace(/\-/g,"/").replace(/\./g,"/"))
	var d2 = new Date(d2.value.replace(/\-/g,"/").replace(/\./g,"/"))
	if(d1 > d2){
		p.innerHTML = "<span>起始日期必须小于截止日期。</span>"
		return;
	}

	GetArrayDataFromListView() //获取listview中的数据

	var html = "<table cellSpacing=4>"
	var iii = 0
	var index = 0
	var onlyOne =  d1.getMonth() == d2.getMonth() && d1.getYear() == d2.getYear()
	for (var i = d1.getYear() ; i <= d2.getYear() ; i ++ )
	{
		for (var ii=(i==d1.getYear() ? d1.getMonth() : 0) ;ii<= (i==d2.getYear() ? d2.getMonth() : 11) ; ii ++ )
		{
			if (iii==0)
			{
				html = html + "<tr>"
			}
			html = html + "<td>" + GetOneMonthDateList(i,ii,d1,d2,index,1) + "</td>"
			iii = iii + 1
			index = index + 1
			if(iii==1){  //用于控制一行显示几列，此处表示一行显示1列
				html = html + "</tr>"
				iii = 0;
			}
		}
	}
	if(iii==1){
		html = html + "</tr>"
	}
	html = html + "</table>"
	p.innerHTML = html

}


//显示日历刷子
function showBrush(button){
	if(dlistReadMode){return }
	var bn = document.getElementsByName("wtypebutton")
	for (var i = 0 ; i < bn.length ; i ++ )
	{
		if(bn[i]!==button){
			bn[i].style.border = "2px outset"
		}
	}
	button.style.border = "2px inset"
	window.currwcursor = button.typeIndex
	window.currwtypebutton = button
	button.blur();
}

//日历类型选择界面
function WorkDayTypePanel(){
	var html = "&nbsp;"
	for(var i = 0 ; i < works.length ; i ++){
		html = html  + "<button " + (dlistReadMode == true ? "onfocus='this.blur()'" : "") + " wtype='" + i +"' style='" + (i==0?"border:2px inset;":"") + "color:" + works[i][2] + ";background-color:" + works[i][1]  + ";' class='wtypebutton' onclick='showBrush(this)' name='wtypebutton'>" + works[i][0] + "</button>&nbsp;" 
	}
	//html = html + "<button onclick='updatelvwArrayByDateList()'>xxx</button>"
	return html;
}

//选中单元格
function selectDayItem(td){
	if(dlistReadMode){return }
	td.style.backgroundColor =  window.currwtypebutton.style.backgroundColor;
	td.children[0].children[0].style.color = window.currwtypebutton.style.color;
	td.wtype = window.currwtypebutton.wtype
	td.title = window.currwtypebutton.innerText;
}

//生成单日的界面
function getonedayHTML(year,month,day,dis,wIndex){
	var d = nlCls.getnlDay(year,month,day)
	var jr = ""

	m = d.month-1
	if(Nl[m]){
		for (var i = 0;i<Nl[m].length ; i++ )
		{
			if(Nl[m][i][0]==d.day){
				jr = Nl[m][i][1]
				break;
			}
		}
	}
	if(jr.length==0) {
		m = month-1
		if(Fl[m]){//节日判断
			for (var i = 0;i<Fl[m].length ; i++ )
			{
				if(Fl[m][i][0]==day){
					jr = Fl[m][i][1]
					break;
				}
			}
		}
	}
	if(dis==0){
			return "<div style='height:100%'><div style='text-align:right;font-size:13px;padding-right:5px;color:" + works[wIndex][2] + "'><b>"  + day + "</b></div>" +
			"<div style='padding-left:4px;text-align:left;color:#9999cc;font-family:arial;font-size:12px'>"  +
			(jr.length==0 ? d.smpDay : "<img src='../../images/smico/study.gif'><span style='color:red'>" + jr + "</span>" ) + "</div></div>"
	}
	else{
			return "<div><div style='text-align:right;font-size:13px;padding-right:5px'><b>"  + day + "</b></div>" +
			"<div style='padding-left:4px;text-align:left;color:#ddd;font-family:arial;font-size:12px'>"  +
			(jr.length==0 ? d.smpDay : "<img src='../../images/smico/study.gif'>" + jr ) + "</div></div>"
	}
			//(jr.length==0 ? "": "<input type=image src='../../images/smico/study.gif' title='" + jr + "' onclick='alert(\"" + jr + "    \")' style='cursor:pointer'>" ) + "</div></div>"
}

//生成一个月列表 month 已经减1
function GetOneMonthDateList(year, month, d1, d2, index , onlyOne){
	var w = onlyOne ? 600 : 320
	var weeks = new Array("一","二","三","四","五","六","日")
	var html =  "<div style='font-family:arial;width:" + w + "px;border:1px solid #ceceee;background-color:#f3f2f1'><div onclick='dlistexp(this)' tag=1 class='datelistjtbutton'><img src='../../images/smico/jt6.gif'></div><div style='text-align:center;height:24px;line-height:24px'><b>"  + year + "年" + (month+1) + "月</b></div>" +
				"<table id='dlItem" + index + "' style='table-layout:fixed;font-family:arial;text-align:center;width:" + (w-10) + "px;margin-left:5px;border-left:1px solid white;border-top:1px solid white'><tr>"
	for (var i = 0;i<weeks.length; i++ ){html = html + "<th class=fcdlcell>" + weeks[i] + "</th>";}
	html = html + "</tr>"
	var cdat = new Date(year,month,1)
	var wday = cdat.getDay()
	html = html + "<tr>"
	var x = 1
	for (var i=1;i< (wday==0?7:wday) ; i++ )
	{
		x ++;
		html  = html + "<td class=fcdlcell></td>"
	}
	var d = 1;
	var dat = new Date((month*1+1) +"/"+ d + "/" + year)
	while(dat.getDate()==d && d <= 31){
		if(dat.getTime()<d1.getTime() || dat.getTime() > d2.getTime()){
			html  = html + "<td class=fcdlcell title='不属于设置范围' style='color:#ccc' overflow=1>" + getonedayHTML(year,month+1,d,1,0) + "</td>"
		}
		else{
			var wIndex = 0
			for (var i=0;i<window.wdlistArray.length ;i++ )
			{
				var d01 = new Date(window.wdlistArray[i][1].replace(/\-/g,"/"))
				var d02 = new Date(window.wdlistArray[i][2].replace(/\-/g,"/"))
				if(dat.getTime()>=d01.getTime() && dat.getTime() <=d02.getTime()){
					wIndex = window.wdlistArray[i][0];
					i = window.wdlistArray.length;
				}
			}
			html  = html + "<td wkdat=1 title='" + works[wIndex][0] + "' cY=" + year + " cM=" + month + " cD=" + d + "  wtype=" + wIndex + " class=fcdlcell style='background-Color:" + works[wIndex][1] + ";" +  (dlistReadMode ? "" : "cursor:url(../../images/smico/wCursor.cur)") + "' onmouseover = 'if(window.currwcursorselect==1){selectDayItem(this)}' onmousedown='selectDayItem(this)'>" + getonedayHTML(year,month+1,d,0,wIndex) + "</td>"
		}

		d ++ ;
		if(dat.getDay()==0){
			html  = html + "</tr>"
			dat = new Date((month*1+1) +"/"+ d + "/" + year)
			
			if(dat.getDate()==d){html  = html + "<tr>";}
		}
		else{
			dat = new Date((month*1+1) +"/"+ d + "/" + year)
		}
		x ++;
	}
	d --;
	dat = new Date((month*1+1) +"/"+ d + "/" + year)
	wday = dat.getDay()
	wday = wday==0 ? 7 : wday 
	for (var i=wday;i<7 ;i++ )
	{
		html  = html + "<td class=fcdlcell></td>"
		x ++
	}
	if (x<43)
	{
		html = html + "</tr><tr>"
		for (var i=1;i<=7 ;i++ )
		{html  = html + "<td class=fcdlcell></td>";}
	}
	
	html = html + "</tr>"
	html = html + "</table><div style='height:5px;overflow:hidden'></div></div>"
	return html
}

//显示和折叠日历
function dlistexp(div){
	div.tag = div.tag == "1" ? "0" : "1"
	div.parentElement.children[2].style.display = div.tag == "0" ? "none" : "";
	div.parentElement.children[0].children[0].src = div.tag == "0" ? "../../images/smico/jt5.gif" : "../../images/smico/jt6.gif";
}

//根据日历设置刷新
function updatelvwArrayByDateList(){
	var cY = 0
	var cM = 0
	var cD = 0
	var cW = 0
	var d0 = new Date(1970,1,1)
	var cells = document.getElementById("rlSetPanel").getElementsByTagName("td")
	window.wdlistArray = new Array()
	var ii = -1
	for (var i=0;i<cells.length ; i ++ )
	{
		var td = cells[i]
		if(td.wkdat && td.wtype!=0){

			var d1 = new Date(td.cY,td.cM,td.cD)
			if(Date.DateDiff("d",d0,d1)!=1 || cW !=td.wtype)
			{
				cW = td.wtype
				ii = ii + 1
				window.wdlistArray[ii] = new Array("","0", cW , td.cY + "-" + (td.cM*1+1) + "-" + td.cD, td.cY + "-" + (td.cM*1+1) + "-" + td.cD , cells[i].remark ? cells[i].remark : "")
			}
			else{
				window.wdlistArray[ii][4] = td.cY + "-" + (td.cM*1+1) + "-" + td.cD
			}
			d0 = d1
			
		}
	}
	var div = document.getElementById("listview_71")
	div.hdataArray = window.wdlistArray;
	lvw.Refresh(div)
}