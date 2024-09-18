document.write("<style>#List_View_Tool_Bar, #List_View_Tool_Bar table{padding:0px;margin:0px;height:22px;table-layout:fixed;border-collapse:collapse;overflow:hidden}\r\n")
document.write("#List_View_Tool_Bar textarea{height:20px !important;padding:0px;}\r\n")
document.write("#List_View_Tool_Bar{margin-top:1px;_margin-top:2px;}\r\n")
document.write("#List_View_Tool_Bar td {word-break:break-all;padding:0px;padding-top:12px;margin:0px; height:20px;overflow:hidden;display:table-cell}\r\n .vertical-middle input{vertical-align:middle;}</style>")

function CommListDefAttrExt() {
    var ExtAttrs = ["obj", "datatype"];
	window.IEObjArrayAttrExtL = new Array();
	function ExtAttrFun(t, name){
		return (t==0?(function(){
			for(var i = 0; i<window.IEObjArrayAttrExtL.length;i++) {
				if(window.IEObjArrayAttrExtL[i].id==this &&  window.IEObjArrayAttrExtL[i].nm == name) {
					return window.IEObjArrayAttrExtL[i].obj;
				}
			}
			var v = this.getAttribute(name);
			if(v=="true") {return true;}
			if(v=="false") {return false;}
			return v;
		}):(function(v){
			var s = (v && v.constructor) ? v.constructor.toString() : "" ;
			if(s.indexOf("Array")>=0 || s.indexOf("Element")>=0 || s.indexOf("function Object")>=0 ) {
				for(var i = 0; i<window.IEObjArrayAttrExtL.length;i++) {
					if(window.IEObjArrayAttrExtL[i].id==this && window.IEObjArrayAttrExtL[i].nm == name) {
						window.IEObjArrayAttrExtL[i].obj = v;
						return;
					}
				}
				window.IEObjArrayAttrExtL[i] = { "id": this, "obj": v, "nm": name};
				return;
			}
			this.setAttribute(name,v);
		}));
	}
	for (var i = 0 ; i < ExtAttrs.length ; i++ )
	{
		HTMLElement.prototype.__defineGetter__(ExtAttrs[i],ExtAttrFun(0,ExtAttrs[i]));
		HTMLElement.prototype.__defineSetter__(ExtAttrs[i],ExtAttrFun(1,ExtAttrs[i]));
	}
}
if(!window.ActiveXObject) { CommListDefAttrExt(); }


//整体录入的单元格对象
function UnitinCell(cellobj , lvw , header ,td){
	var obj = new Object();
	obj.text = "";
	obj.value = "";
	obj.defvalue = cellobj.value;
	obj.datatype = cellobj.datatype;
	obj.otype = "datacell";
	obj.type = header.type;
	obj.header = header;
	obj.cellIndex = cellobj.cellIndex;
	obj.getParent = function(){
		var pobj = new Object();
		pobj.getParent = function(){
			var ppobj = new Object();
			ppobj.Headers = lvw.Headers;
			ppobj.RefreshContent = function(){
				//刷新；
				var oRow =  lvw.EditRow;
				lvw.EditRow = td.parentElement.rowIndex;
				lvw.ShowCell(td,obj);
				lvw.EditRow = oRow;
			}
			return ppobj;
		}
		var rowIndex = 0;
		return pobj;
	}
	return obj;
}

function JSListView(lvid)
{
	var me=new Object();
	me.id=lvid;
	me.CanMark=true;//是否有标记列
	me.ShowIDX=true;//是否有序号列
	me.CanAdd=true;//是否显示添加行按钮
	me.CanCheckAll=true;//是否显示全选
	me.CanReverse=true;//是否显示反选按钮
	me.CanDelete=true;//是否显示删除按钮
	me.CanSwapRow=true;//是否允许改变明细的顺序
	me.CanCopyRow=false;//是否允许复制选中行
	me.CanSum=true;//是否显示总计
	me.Container=null;
	me.RowsPerPage=10;
	me.startIdx=0;
	me.IndexMap=new Array();
	me.Identity=0;
	me.EditRow=null;
	me.Rows=new Array();
	me.loadztlr = false;		//是否已经加载整体录入
	me.Headers=new Array();
	me.toolbar = {				//工具栏信息
		config : false,			//设置项目,待扩展
		visible : function()
		{
			return this.config;
		}
	};
	me.IndexOfByInnerHTML = function(html){
		for(var i = 0; i<me.Headers.length; i++){
			var ix = (me.Headers[i].innerHTML||"").indexOf(html);
			if(ix>=0){ return  i; }
		}
		return -1;
	};

	me.HeaderHTMLByIndex = function(cellIndex){
		if(cellIndex>=0 && cellIndex<me.Headers.length){
			return me.Headers[cellIndex].innerHTML;
		}
		return "";		
	};

	me.Headers.Add=function(h)
	{
		me.Headers[me.Headers.length] = (h&&h.oType=="header")?h:new Headers();
		return me.Headers[me.Headers.length-1]; 
	};

	me.Headers.Load=function(o)
	{
		with(me.Headers.Add(new Header("选择","40",-100,me.CanMark?1:0))){
			unitin = 0;
		}
		with(me.Headers.Add(new Header("序号","40",-10,me.ShowIDX?1:0))){
			unitin = 0;
		}
		for(var i=0;i<o.length;i++) me.Headers.Add(new Header(o[i].innerHTML,o[i].width,o[i].sort,o[i].display,o[i].height,o[i].className,o[i].cssText));
	};

	me.Rows.Add = function(row)
	{
		if(row && row.otype=="datarow")
		{
			me.Rows[me.Rows.length] = row;
		}
		else
		{
			me.Rows[me.Rows.length] = new Row(me);
		}
		me.Rows[me.Rows.length-1].rowIndex=me.Rows.length-1;
		return me.Rows[me.Rows.length-1];
	};

	me.Rows.insertRow = function(insertIdx)
	{
		var idx=insertIdx==undefined?0:insertIdx;
		var newrow=new Row(me);
		me.Rows.splice(insertIdx,0,newrow);
		for(var i=insertIdx;i<me.Rows.length;i++){me.Rows[i].rowIndex=i;}
		return newrow;
	};

	me.Rows.SwapRow = function(ridx1,ridx2)
	{
		var tmpRow=me.Rows[ridx1];
		var idx=me.Rows[ridx1].Cells[1].value;
		me.Rows[ridx1].rowIndex=ridx2;
		me.Rows[ridx2].rowIndex=ridx1;
		me.Rows[ridx1].Cells[1].value=me.Rows[ridx2].Cells[1].value;
		me.Rows[ridx2].Cells[1].value=idx;
		me.Rows[ridx1]=me.Rows[ridx2];
		me.Rows[ridx2]=tmpRow;
	};

	me.Rows.Load = function(jsobj,refreshFlg)
	{
		var values=jsobj.RowsList;
		for(j=0;j<values.length;j++)
		{
			var cells = me.Rows.Add().Cells;
			for(var i=0;i<me.Headers.length;i++)
			{
				if(i==1) cells[i].value=values[j][i].value;
				if(i<=1) continue;
				var cell=cells.Add();
				cell.text=values[j][i].text;
				cell.value=values[j][i].value;
				cell.datatype=values[j][i].datatype;
			}
		}

		if(refreshFlg==undefined)
		{
			me.startIdx=me.Rows.length>me.RowsPerPage?me.Rows.length-me.RowsPerPage:0;
			me.RefreshContent();
		}
		else if(refreshFlg==true)
		{
			me.startIdx=0;
			me.RefreshContent();
		}
	};

	me.Show=function()
	{
		me.ShowHeads();
		me.ShowContent();
		me.ShowSum();
		me.ShowFooters();
		me.Container.onclick=function()
		{
			me.ReCalculateSum();
		};
	};
	
	me.headerResizeEvent =
	{
		obj : null, 
		oldcellwidth : 0, 
		oldtablewidth: 0,
		mouseDownX : 0,
		tb :  null
	};
	
	me.cellIndex = function(td)
	{
		var tr = td.parentElement.cells;
		for (var i = 0; i < tr.length ; i ++ )
		{
			if(tr[i]==td){
				return i;
			}
		}
	};

	me.setHeaderColBorder = function(mHeader,isBold)
	{
		if(!mHeader){return}
		var tb = mHeader.parentElement.parentElement;
		var cellIndex = me.cellIndex(mHeader);
		var b = isBold ? "3px solid #0000aa" : "0px solid #ccccee" ;
		for (var i=0;i<tb.rows.length-2 ; i ++ )
		{
			tb.rows[i].cells[cellIndex].style.borderRight = b;
		}
	};

	me.headermousedown = function()
	{
		if(!window.ActiveXObject) {return;}
		var mHeader = window.event.srcElement;
		var w = mHeader.offsetWidth;
		var x = window.event.offsetX;
		var dw = 6
		if ( w-x > dw || mHeader.resize != "1"){
			return false;
		}
		//lvw.setHeaderColBorder(mHeader,true)
		mHeader.style.display = "block";
		me.headerResizeEvent.mouseDownX   = window.event.clientX;
		me.headerResizeEvent.obj = mHeader;
		me.headerResizeEvent.oldcellwidth = mHeader.offsetWidth;
		me.headerResizeEvent.tb =  mHeader.parentElement.parentElement.parentElement;
		me.headerResizeEvent.oldtablewidth = me.headerResizeEvent.tb.offsetWidth;
		//me.headerResizeEvent.tb.style.tableLayout = "fixed"
		mHeader.setCapture();
		var t = new Date();
		mHeader.currTime = t.getTime();
		me.setHeaderColBorder(me.headerResizeEvent.obj,true);
		mHeader.onmouseup = function()
		{
			me.setHeaderColBorder(me.headerResizeEvent.obj,false);
			me.headerResizeEvent.mouseDownX   = 0;
			me.headerResizeEvent.obj = null;
			me.headerResizeEvent.oldcellwidth = 0;
			me.headerResizeEvent.tb = null;
			me.headerResizeEvent.oldtablewidth = 0;
			mHeader.releaseCapture();
		};
	};

	me.headermousemove = function(event)
	{
		event = event || window.event;
		if(!window.ActiveXObject) {
			var thead = event.srcElement ? event.srcElement : event.target;
			$(thead).TableColResize(function(e){
				//lvw.saveColSizeData(e.data.tb);  还有问题，暂时放过
			});
			return true;
		}
		if(!me.headerResizeEvent.obj)
		{
			thead = event.srcElement ? event.srcElement : event.target;
			var w = thead.offsetWidth;
			var x = event.offsetX;
			var dw = 6
			if((w-x)<dw){if(thead.resize == "1"){thead.style.cursor = "w-resize";return;}}
			thead.style.cursor = "default";
		}
		else
		{
			var thead = me.headerResizeEvent.obj;
			var dt = (event.clientX*1-me.headerResizeEvent.mouseDownX);
			var newWidth=me.headerResizeEvent.oldcellwidth*1 + dt;
			if(newWidth > 0)
			{	
				var tbwidth =  ((newWidth-me.headerResizeEvent.oldcellwidth) + me.headerResizeEvent.oldtablewidth*1)
				me.headerResizeEvent.tb.style.width = tbwidth + "px";
				thead.style.width = newWidth;
				me.FixHeight();
			}	
		}
	};

	me.ShowHeads=function()
	{
		try{
			var pdiv = me.Container.parentNode;
			var pobj = pdiv.parentNode; //获取组件的父对象；
			pobj.onresize = function() {
				if(pobj.offsetWidth - pdiv.offsetWidth>14) {
					pdiv.style.width = (pobj.offsetWidth - 14) + "px";
				}
			}
		}catch(e){}
		me.ShowToolbar();
		me.setSort();
		//创建表头
		for(var i=0;i<me.Headers.length;i++)
		{
			var realIdx=-1;
			for(var k=0;k<me.Headers.length;k++){if(me.Headers[k].sort==i){realIdx=k;break;}}
			var col = document.createElement("col");
			var h = me.Headers[realIdx];
			if(h.display == "0") {
				col.style.display = "none";
			}
			col.style.width = h.width + "px";
			me.Container.appendChild(col);			
		}

		var tr=me.Container.insertRow(-1);
		tr.obj=me.Headers;
		me.Headers.obj=tr;
		tr.className="top";
		var w=0;
		for(var i=0;i<me.Headers.length;i++)
		{
			var realIdx=-1;
			for(var k=0;k<me.Headers.length;k++){if(me.Headers[k].sort==i){realIdx=k;break;}}
			if(realIdx==-1){alert('格式错误，请刷新后重试');return;}
			var td=tr.insertCell(-1);
			td.obj=me.Headers[realIdx];
			td.resize = td.obj.resize;
			me.Headers[realIdx].obj=td;
			if(me.Headers[realIdx].display!=1) td.style.display="none";
			td.style.paddingRight = "1px";
			td.style.cursor = "w-resize";
			td.innerHTML="<div onmousemove='event.cancelBubble=true;return false;' onmousedown='event.cancelBubble=true;return false;' style='height:100%;position:relative1;left:-2px;cursor:default;line-height:30px;text-align:"+(me.Headers[realIdx].align?me.Headers[realIdx].align:'center')+";overflow:hidden' align='center'><pre>"+me.Headers[realIdx].innerHTML+"</div>";
			if(me.Headers[realIdx].width.length>0) td.width=me.Headers[realIdx].width;
			if(me.Headers[realIdx].height.toString().length>0) td.height=me.Headers[realIdx].height;
			if(me.Headers[realIdx].className.length>0) td.className=me.Headers[realIdx].className;
			if(me.Headers[realIdx].cssText.length>0) td.cssText=me.Headers[realIdx].cssText;
			//td.title=realIdx;
			w+=me.Headers[realIdx].display==1?parseInt(me.Headers[realIdx].width):0;
			if(window.ActiveXObject) {
				td.onmousedown = me.headermousedown;
				td.onmousemove = me.headermousemove;
			}else {
				td.onmousemove = me.headermousemove;
				if(td.children[0]){
					td.children[0].onmousemove = null;
					td.children[0].style.width = "99%";
				}
			}
		}
		var td=tr.insertCell(-1);
		td.width=18;
		td.obj=me;
		td.cssText="font-size:9px;text-align=cener;font-weight:bold;padding-left:0px;padding-right:0px;line-height=10px";
		td.vAlign="top";
		td.innerHTML="<div id='LV_Scroll_Bar' style='position:relative;cursor:n-resize;left:0px;top:0px;width:15px;height:15px;background-color:#f0f0ff;border:1px outset #f0f0ff;line-height=15px'></div>";
		td.style.display="none";
		w = w+parseInt(td.width);
		me.Container.width = w;
		if (me.toolbardiv) me.toolbardiv.style.width = w + "px";
	};
	
	//编号生成规则
	me.UnitinSNCreator = function(tb,td)
	{
		var obj = td.obj;
		return function()
		{
			var dlg = new window.DlgClass();
			dlg.title = "生成编号/序列";
			dlg.width = 320;
			dlg.height = 170;
			dlg.onload = function()
			{
				var v = obj.defvalue + "";
				var amode = obj.amode ? obj.amode : 1;
				var tnum =  obj.tnum ? obj.tnum : 1;
				var basevalue = "";
				var numvalue =  v;
				for (var i=v.length; i>0 ;i--)
				{
					if(isNaN(v.substr(i-1,1)))
					{
						basevalue = v.substring(0,i)
						numvalue = v.substring(i,v.length)
						break;
					}
				}
				basevalue = obj.basevalue  ? obj.basevalue  : basevalue;
				numvalue = obj.numvalue ? obj.numvalue : numvalue;
	
				dlg.body.style.cssText = "background-Color:buttonface;border:2px groove;margin:5px;overflow:hidden;"
				dlg.body.innerHTML = "<table style='font-size:12px;font-familay:宋体' align=center>" +
									 "	<tr><td align=right height=27>常量码：</td><td><input id='t1' value='" + basevalue + "' type=text style='font-size:12px;font-family:宋体;height:16px;line-height:16px'></td></tr>" +
									 "	<tr><td align=right height=27>基数码：</td><td><input id='t2' value='" + numvalue + "' type=text style='font-size:12px;font-family:宋体;height:16px;line-height:16px' value='0000'></td></tr>" +
									 "	<tr><td align=right height=27>递更模式：</td><td>" +
									 "			<input type=radio id='v1' value=1 name='t3' " + (amode==1?"checked":"") + "><lable for=v1>＋</label>&nbsp;" + 
									 "			<input type=radio id='v2' value=2 name='t3' " + (amode==2?"checked":"") + "><lable for=v2>－</label>&nbsp;" + 
									 "	</td></tr>" +
									 "	<tr><td align=right height=27>递更值：</td><td><input id=t4 type=text value=" + tnum + " style='font-size:12px;font-family:宋体;height:16px;line-height:16px'></td></tr>" +
									 "	<tr><td align=center colspan=2 height='30px'><button onclick='dialogArguments.save();window.close()' class=wavbutton style='color:#000;height:22px;width:40px;line-height:20px'>确定</button>" +
									 "		&nbsp;<button  style='color:#000;height:22px;width:40px;line-height:20px' class=wavbutton onclick='window.close()'>取消</button></td></tr>" +
									 "</table>"
			};

			dlg.save = function()
			{
				obj.basevalue = dlg.document.getElementById("t1").value;
				obj.numvalue =  dlg.document.getElementById("t2").value;
				obj.amode = 1
				var exp = "";
				var ts = dlg.document.getElementsByName("t3")
				for (var i = 0 ; i< ts.length ; i++ )
				{
					if(ts[i].checked)
					{
						obj.amode = i*1+1;
						switch(i)
						{
							case 0 : exp = "+";	break;
							case 1 : exp = "-";	break;
							case 2 : exp = "*";	break;
							case 3 : exp = "/";	break;
							default: exp = "";
						}
						break;
					}
				}
				obj.tnum = dlg.document.getElementById("t4").value;
				obj.value = "序列={\"" + obj.basevalue + "\" + me.cexpum(\"" + obj.numvalue + "\",(" + obj.numvalue + exp + "(n*" + obj.tnum + ")))}"
				obj.text = "序列={\"" + obj.basevalue + "\" + me.cexpum(\"" + obj.numvalue + "\",(" + obj.numvalue + exp + "(n*" + obj.tnum + ")))}"
				me.UnitinData(obj);
				if(me.EditRow || me.EditRow==0)
				{
					me.RefreshRow(me.EditRow);
				}
				me.RefreshContent();
			};
			dlg.show();
		};
	};

	me.cexpum = function(n,v)
	{
		v = v + "";
		return "0000000000".substr(0,n.length-v.length) + v;
	};

	//序列化数据
	me.sndatalist = function(code , i)
	{
		var c = code.replace("序列={","") + "yyy";
		c = c.replace("}yyy","").replace("n",i);
		try
		{
			return eval(c);
		}
		catch(e)
		{
			return "";
		}
	};

	//将整体录入值写入表格
	me.UnitinData = function(cobj)
	{
		var cellIndex = cobj.cellIndex;
		if(me.EditRow>me.Rows.length)me.EditRow=me.Rows.length;
		var currRowIndex = me.EditRow ? me.Container.rows[me.EditRow].obj.rowIndex : 0;
		var  v = cobj.value;
		if (v.replace(/序列\=\{.+\}/,"")=="")	//序列化模式
		{
			for(var i = 0 ; i<me.Rows.length ; i++)
			{
				var v = me.sndatalist(cobj.value,(i+1));
				me.Rows[i].Cells[cellIndex].value = v
				me.Rows[i].Cells[cellIndex].text= v;
			}
		}
		else
		{
			for(var i = 0 ; i<me.Rows.length ; i++)
			{
				var tvalue,ttext;
				if(me.Headers[cellIndex].digit)
				{
					tvalue=FormatNumber(cobj.value,me.Headers[cellIndex].digit);
					ttext=FormatNumber(cobj.text,me.Headers[cellIndex].digit);
				}
				else
				{
					tvalue=cobj.value;
					ttext=cobj.text;
				}
				me.Rows[i].Cells[cellIndex].value = tvalue;
				me.Rows[i].Cells[cellIndex].text= ttext;
				if(typeof(CustomBatchRow)!='undefined'){CustomBatchRow(me,i+1,cellIndex);};
			}
		}
	};

	//保存整理录入值
	me.UnitInEvent = function(oldfun,td,tdobj,tg)
	{
		return function()
		{
			if(tg=="td" && window.event.propertyName !="innerHTML" ){return;}
			if(oldfun){if(oldfun()=="cancelBubble") return;}
			var exitfdtype = ["decimal-price","rknum","rkmoney"];
			for (var i=0; i < exitfdtype.length ; i ++ )
			{
				if(exitfdtype[i]==tdobj.datatype) {return;}
			}
			window.setTimeout(
				function ()
				{
					var ov = td.getAttribute("ov");
					if(ov!=tdobj.value)
					{
						if(tdobj.value=="") { 
							var vav = td.children[0].value;
						}
						me.UnitinData(tdobj);
						if(me.EditRow || me.EditRow==0)
						{
							me.RefreshRow(me.EditRow);
						}
						me.RefreshContent();
						td.setAttribute("ov",tdobj.value);
					}
				},
			50);
		};
	};

	//显示整体录入区域
	me.ShowUintinTool = function (v)
	{
		if (v == false)
		{
			me.ztlrDiv.innerHTML = ""
			me.Container.onresize = function (){me.ztlrDiv.parentElement.style.width = me.Container.offsetWidth + "px";};
			return false;
		}
		if(me.Container.rows.length<3) return false;
		var html = "", rCount = 0
		var tb = document.createElement("table");
		tb.style.cssText = ";width:100%;";
		tb.id="List_View_Tool_Bar";
		tb.cellSpacing = 0;
		tb.cellPadding = 0;
		tb.borderColor = "transparent";
		tb.border = 0;
		tr = tb.insertRow(-1);
		var currRowIndex = me.EditRow;
		me.EditRow = tr.rowIndex;
		var currRow = me.Container.rows[1].obj;
		for(var i = 0; i < me.Headers.length; i++){ tr.insertCell(-1).innerHTML = "&nbsp;"; }
		for(var i = 0; i < me.Headers.length; i++)
		{
			var cIndex = me.IndexMap[i];
			var dIndex = i;
			var h = me.Headers[i];
			td = tr.cells[cIndex];
			var tdobj = currRow.Cells[dIndex];
			var strDisplay="";
			td.title = me.Headers[dIndex].innerHTML;
			//alert(td.title)
			if(me.Headers[dIndex].display!=1) strDisplay=";display:none";
			var txtAlign=me.Container.rows[1].cells[cIndex].align?me.Container.rows[1].cells[cIndex].align:"center";
			td.style.cssText = "padding:0px;text-align:"+txtAlign+";background-color:transparent;border:0px;width:" + tdobj.obj.offsetWidth + "px" + strDisplay;
			td.vAlign = "middle";
			if(me.Headers[dIndex].display!=1) continue;
			if(me.Headers[dIndex].unitin == true)
			{
				td.obj = new UnitinCell(tdobj, me, me.Headers[dIndex], td);
				me.ShowCell(td, td.obj, true);
				if(td.getElementsByTagName("textarea").length == 0 &&td.getElementsByTagName("select").length == 0 &&
					td.getElementsByTagName("button").length == 0 &&td.getElementsByTagName("img").length == 0)
				{
					var hs = false;
					var inputs = td.getElementsByTagName("input");
					for (var ii = 0; ii < inputs.length; ii++)
					{
						if (inputs[ii].type != "hidden")
						{
							hs = true;
							ii = inputs.length;
						}
					}
					if (hs == false)
					{
						td.innerHTML = "&nbsp;";
						td.style.borderLeft = "0px";
						td.style.borderRight = "0px";
					}
					else
					{
						//触发事件
						var boxs = td.getElementsByTagName("textarea");
						for(var ii = 0 ; ii < boxs.length ; ii ++)
						{
							boxs[ii].onchange = me.UnitInEvent(boxs[ii].onchange,td,td.obj);
							boxs[ii].onkeyup = me.UnitInEvent(boxs[ii].onkeyup,td,td.obj); 
						}
						boxs = td.getElementsByTagName("select");
						for(var ii = 0 ; ii < boxs.length ; ii ++)
						{
							boxs[ii].onchange = me.UnitInEvent(boxs[ii].onchange,td,td.obj);
						}
						boxs = td.getElementsByTagName("input");
						for(var ii = 0 ; ii < boxs.length ; ii ++)
						{
							boxs[ii].onchange = me.UnitInEvent(boxs[ii].onchange,td,td.obj);
							boxs[ii].onkeyup = me.UnitInEvent(boxs[ii].onkeyup,td,td.obj);
							boxs[ii].ondblclick =  me.UnitinSNCreator(tb,td);
						}
						td.onpropertychange =  me.UnitInEvent(null,td,td.obj,"td");
					}
				}
				else
				{
					var boxs = td.getElementsByTagName("textarea");
					for(var ii = 0 ; ii < boxs.length ; ii ++)
					{
						boxs[ii].onchange = me.UnitInEvent(boxs[ii].onchange,td,td.obj);
						boxs[ii].onkeyup = me.UnitInEvent(boxs[ii].onkeyup,td,td.obj); 
					}
					boxs = td.getElementsByTagName("select");
					for(var ii = 0 ; ii < boxs.length ; ii ++)
					{
						boxs[ii].onchange = me.UnitInEvent(boxs[ii].onchange,td,td.obj);
					}
					boxs = td.getElementsByTagName("input");
					for(var ii = 0 ; ii < boxs.length ; ii ++)
					{
						boxs[ii].onchange = me.UnitInEvent(boxs[ii].onchange,td,tdobj);
						boxs[ii].onkeyup = me.UnitInEvent(boxs[ii].onkeyup,td,td.obj);
						boxs[ii].ondblclick = me.UnitinSNCreator(tb,td);
					}
					td.onpropertychange =  me.UnitInEvent(null,td,td.obj,"td");
				}
			}
		}
		var td = tr.insertCell(-1);
		td.style.cssText="text-align:center;background-color:transparent;border-left:0px;border-right:0px;width:18px"
		td.innerHTML="<div style='width:18px'></div>";

		td.style.display="block";
		
		me.EditRow = currRowIndex;
		me.ztlrDiv.innerHTML = "";
		tb.align = "left";
		me.ztlrDiv.appendChild(tb);
		me.Container.onresize = function()
		{
			var row = me.Container.rows[1];
			var zrow = tb.rows[0];
			tb.style.width = me.Container.offsetWidth + "px";
			me.ztlrDiv.parentElement.style.width = tb.style.width;
			for (var i = 0; i < row.cells.length; i++)
			{
				if (zrow.cells[i])
				{
					zrow.cells[i].style.width = row.cells[i].offsetWidth;
				}
			}
		};
	};
	
	//显示状态栏
	me.ShowToolbar = function()
	{
		if(!me.toolbardiv)
		{
			var pNode = me.Container.parentElement;
			
			me.toolbardiv= document.createElement("Div");
			me.toolbardiv.style.cssText = "background-repeat:repeat-x;background-image:url(/images/m_table_top.jpg);padding-top:1px;border:1px solid #c0ccdd;border-bottom:0px;height:38px;display:block;overflow:hidden;background-color:#fefeff;filter:wave(strength=0,freq=1,lightstrength=2,phase=90);"
			me.toolbardiv.className = 'resetBorderColor'
			if (me.toolbar.visible() == true)
			{
				me.toolbardiv.style.height = "48px";
				me.toolbardiv.innerHTML = "<div></div><div style='height:20px'></div>"
			}
			else
			{
				me.toolbardiv.innerHTML = "<div style='position:absolute;top:1px;left:0px;padding-left:5px;padding-top:10px;*padding-top:6px;color:#5B7CAE'>共<span id='lv_rec_cnt2' style='color:red'>"+me.Rows.length+"</span>行,显示<select id='lv_pg_sz2'>"+
				"<option value='10'>10</option>"+
				"<option value='15'>15</option>"+
				"<option value='20'>20</option>"+
				"<option value='30'>30</option>"+
				"<option value='50'>50</option>"+
				"<option value='100'>100</option>"+
				"</select>行</div><div style='height:24px'></div>"
			}
			me.ztlrDiv = me.toolbardiv.children[1];
			pNode.insertBefore(me.toolbardiv,me.Container);
		}
	};

	//呈现表格
	me.ShowContent=function()
	{
		var rowspantd;
		for(var i=0;i<me.Rows.length;i++)
		{
			if(i>=me.RowsPerPage){break;}
			var tr=me.Container.insertRow(-1);
			tr.obj=me.Rows[i];
			tr.onclick=function()
			{
				if(me.Container.parentElement.disabled==true) return;
				var er=me.EditRow;
				if(er!=null&&er!=this.rowIndex&&er<me.Container.rows.length-2) me.Container.rows[er].style.backgroundColor="";
				me.EditRow=this.rowIndex;
				if(er!=null&&er!=this.rowIndex&&er<me.Container.rows.length-2) me.RefreshRow(er);
				me.Container.rows[me.EditRow].style.backgroundColor="#ecf5ff";
				if(event.srcElement.tagName=="TR") return;
				if(er==null||er!=this.rowIndex) me.RefreshRow(me.EditRow);
			};
			me.Rows[i].obj=tr;
			var j;
			for(j=0;j<me.Headers.length;j++)
			{
				var cell=me.Rows[i].getCellsBySort(j);
				if(!cell){alert('cell对象未找到');return false;}
				var td=tr.insertCell(-1);
				td.obj=cell;
				cell.obj=td;
				if(cell.display!=1) td.style.display="none";
				cell.td=cell.value;
				me.ShowCell(td,cell);
			}

			//补齐未填充的单元格
			if(j<me.Headers.length)
			{
				var td=tr.insertCell(-1);
				td.obj=null;
				td.colSpan=me.Headers.length-j;
				td.innerHTML="";
				alert("格式错误，存在未定义的单元格");
			}
			me.Container.rows[0].cells[me.Container.rows[0].cells.length-1].rowSpan=me.Container.rows.length;
			document.getElementById("lv_rec_cnt").innerHTML=me.Rows.length;
			document.getElementById("lv_rec_cnt2").innerHTML=me.Rows.length;
			me.FixHeight();
		}
	};

	//更新显示界面
	me.RefreshContent=function()
	{
		var tb=me.Container;
		var j=me.startIdx,i;
		while(tb.rows.length-3<me.RowsPerPage){tb.insertRow(tb.rows.length-2);}
		while(tb.rows.length-3>me.RowsPerPage)
		{
			var tmp=tb.rows[tb.rows.length-3];
			for(var mn=0;mn<tmp.cells.length;mn++)
			{
				tmp.cells[mn].obj.obj=null;
				tmp.cells[mn].obj=null;
			}
			tb.deleteRow(tb.rows.length-3);
		}

		for(i=1;i<tb.rows.length-2;i++)
		{
			if(j>=me.Rows.length) break;
			tb.rows[i].obj=me.Rows[j];
			tb.rows[i].style.backgroundColor=(me.EditRow&&me.EditRow==i)?"#ecf5ff":"";
			var tr=tb.rows[i];
			tr.onclick=function(event)
			{
				event = window.event || event;
				if(me.Container.parentElement.disabled==true) return;
				var er=me.EditRow;
				if(er!=null&&er!=this.rowIndex&&er<me.Container.rows.length-2) me.Container.rows[er].style.backgroundColor="";
				me.EditRow=this.rowIndex;
				if(er!=null&&er!=this.rowIndex&&er<me.Container.rows.length-2) me.RefreshRow(er);
				tb.rows[me.EditRow].style.backgroundColor="#ecf5ff";
				var ele = event.srcElement || event.target;
				if(ele.tagName=="TR") return;
				if(er==null||er!=this.rowIndex) me.RefreshRow(me.EditRow);
			};
			while(tr.cells.length<me.Headers.length){tr.insertCell(-1);}
			for(k=0;k<me.Headers.length;k++)
			{
				var c=me.Headers[k];
				if(c.display!=1) tb.rows[i].cells[me.IndexMap[k]].style.display="none";
				tb.rows[i].cells[me.IndexMap[k]].obj=null;

				me.Rows[j].Cells[k].obj=null;
				tb.rows[i].cells[me.IndexMap[k]].obj=me.Rows[j].Cells[k];
				me.Rows[j].Cells[k].obj=tb.rows[i].cells[me.IndexMap[k]];
				me.ShowCell(tb.rows[i].cells[me.IndexMap[k]],me.Rows[j].Cells[k]);
				//tb.rows[i].cells[me.IndexMap[k]].title=me.Rows[j].Cells[k].value+","+me.Rows[j].Cells[k].isError;
			}
			j++;
		}

		while(tb.rows.length+me.startIdx-3>me.Rows.length)
		{
			var tmp=tb.rows[tb.rows.length-3];
			for(var mn=0;mn<tmp.cells.length;mn++)
			{
				tmp.cells[mn].obj.obj=null;
				tmp.cells[mn].obj=null;
			}
			tb.deleteRow(tb.rows.length-3);
		}
		tb.rows[0].cells[tb.rows[0].cells.length-1].rowSpan=tb.rows.length;
		me.ReCalculateSum();
		document.getElementById("lv_rec_cnt").innerHTML=me.Rows.length;
		document.getElementById("lv_rec_cnt2").innerHTML=me.Rows.length;
		me.CalculateScrollBar();
		if(me.loadztlr==false && me.Rows.length>0)
		{
			me.ShowUintinTool(true);
			me.loadztlr = true;
		}
		if(me.loadztlr==true && me.Rows.length==0)
		{
			me.ShowUintinTool(false);
			me.loadztlr = false;
		}
		me.FixHeight();
	};

	me.RefreshRow=function(tdrowidx)
	{
		var tb=me.Container;
		var tr=tb.rows[tdrowidx];
		var rowobj=tr.obj;
        var rowidx=rowobj.rowIndex
		for(var k=0;k<me.Headers.length;k++)
		{
			var c=me.Headers[k];
			if(c.display!=1) tb.rows[tdrowidx].cells[me.IndexMap[k]].style.display="none";
			tb.rows[tdrowidx].cells[me.IndexMap[k]].obj=null;
			me.Rows[rowidx].Cells[k].obj=null;
			tb.rows[tdrowidx].cells[me.IndexMap[k]].obj=me.Rows[rowidx].Cells[k];
			me.Rows[rowidx].Cells[k].obj=tb.rows[tdrowidx].cells[me.IndexMap[k]];
			me.ShowCell(tb.rows[tdrowidx].cells[me.IndexMap[k]],me.Rows[rowidx].Cells[k]);
			//tb.rows[tdrowidx].cells[me.IndexMap[k]].title=me.Rows[rowidx].Cells[k].value+","+me.Rows[rowidx].Cells[k].isError;
		}
		me.ReCalculateSum();
		me.FixHeight();
	};

	me.ReCalculateSum=function()
	{
		var ids = new Array()
		for(var i=0;i<me.IndexMap.length;i++)
		{
			for (var ii= 0; ii< me.IndexMap.length; ii++)
			{
				if(me.IndexMap[ii]==i) {
					ids[i] = ii;
					break;
				}
			}
		}
		var tr=me.Container.rows[me.Container.rows.length-2];
		var csp=tr.cells[0].colSpan;
		var fixi=0;
		for(var i=0;i<me.IndexMap.length;i++)
		{
			if(me.Headers[ids[i]].CanSum==1&&me.Headers[ids[i]].display==1)
			{
				var sum=0;
				for(var j=0;j<me.Rows.length;j++)
				{
					var cv=me.Rows[j].Cells[ids[i]].value;
					if(isNaN(cv)||cv=="") continue;
					sum+=cv.toString().indexOf(".")>=0?parseFloat(cv):parseInt(cv);
				}
				
				var td=tr.cells[i-(csp?csp:1)+1-fixi];
				if(typeof(CustomSumFormat)=='undefined')
				{
					td.innerHTML=sum;
					td.align="right";
					td.style.paddingRight="5px";
				}
				else
				{
					td.innerHTML=CustomSumFormat(sum,ids[i]);
				}
			}
			if(me.Headers[ids[i]].display!=1) fixi++;
		}
	};

	me.setSort=function()
	{
		var arrSort=new Array();
		for(var i=0;i<me.Headers.length;i++)
		{
			if(me.Headers[i].sort=="") me.Headers[i].sort=0
			arrSort[i]=[me.Headers[i].sort,i];
		}
		arrSort=arrSort.sort(sortArrayFun);
		for(var i=0;i<arrSort.length;i++)
		{
			me.Headers[arrSort[i][1]].sort=i;
			me.IndexMap[arrSort[i][1]]=i;
		}
	}

	//根据显示行数及当前行数变更列表框的高度
	me.FixHeight=function()
	{
		me.Container.parentElement.style.height=me.Container.offsetHeight+(me.Container.parentElement.offsetWidth<=me.Container.offsetWidth?22:0) + (me.toolbar.visible()?1:0)*20+48;
		if(frameResize){frameResize();};
	};
	
	me.FixWidth=function()
	{
		me.Container.parentElement.style.width=me.Container.parentElement.parentElement.offsetWidth;
	};

	me.ShowSum=function()
	{
		var ids = new Array()
		var tr=me.Container.insertRow(-1);
		var firstCanSum=-1;
		for(var i=0;i<me.IndexMap.length;i++)
		{
			for (var ii= 0; ii< me.IndexMap.length; ii++)
			{
				if(me.IndexMap[ii]==i) {
					ids[i] = ii;
					break;
				}
			}
		}
		for(var i=0;i<me.IndexMap.length;i++)
		{
			if(me.Headers[ids[i]].CanSum==1&&me.Headers[ids[i]].display==1)
			{
				firstCanSum=i;break;
			}
		}
		if(firstCanSum<0)
		{
			var td=tr.insertCell(-1);
			td.colSpan=me.Headers.length-1;
			tr.style.display="none";
		}
		else
		{
			var td=tr.insertCell(-1);
			td.innerHTML="总计："
			td.align="right";
			td.style.paddingRight="5px";
			var colspan=0;
			for(var j=0;j<firstCanSum;j++){if(me.Headers[ids[j]].display==1) colspan++;}
			td.colSpan=colspan;
			td.style.height=24;
			for(var k=firstCanSum;k<me.IndexMap.length;k++)
			{
				var td=tr.insertCell(-1);
				var h = me.Headers[ids[k]];
				var dindex = ids[k]
				if(h.CanSum==1)
				{
					var sum=0;
					for(var i=0;i<me.Rows.length;i++)
					{
						var cv=me.Rows[i].Cells[dindex].value;
						if(cv==""||isNaN(cv)) continue;
						sum+=cv.indexOf(".")>=0?parseFloat(cv):parseInt(cv);
					}
					if(typeof(CustomSumFormat)=='undefined')
					{
						td.innerHTML=sum;
						td.align="right";
						td.style.paddingRight="5px";
					}
					else
					{
						td.align="right";
						td.style.paddingRight="2px";
						td.innerHTML=CustomSumFormat(sum,dindex);
					}
				}
				if(h.display!=1) td.style.display="none";
			}
		}
	};

	me.ShowFooters=function()
	{
		var tr=me.Container.insertRow(-1);
		var td=tr.insertCell(-1);
		var ids = new Array()
		for(var i=0;i<me.IndexMap.length;i++)
		{
			for (var ii= 0; ii< me.IndexMap.length; ii++)
			{
				if(me.IndexMap[ii]==i) {
					ids[i] = ii;
					break;
				}
			}
		}
		var colspan = 0
		for(var j=0;j<me.Headers.length;j++){if(me.Headers[ids[j]].display==1) colspan++;}
		td.colSpan=colspan;
		td.obj=me;
		var strBtnCheck="",strBtnReverse="",strBtnRemove="",strBtnAdd="",strBtnSwapRowUP="",strBtnSwapRowDown="",strBtnCopyRow="";
		strBtnCheck=me.CanCheckAll?"<input type='checkbox' style='margin-left:5px' onclick=\"LineAction(this,'checkall');\">":"";
		strBtnReverse=me.CanReverse?"<input type='button' style='margin-left:1px' onclick=\"LineAction(this,'reverse');\" class='page' value='反选'>":"";
		strBtnRemove=me.CanDelete?"<input type='button' style='margin-left:1px' onclick=\"LineAction(this,'remove');\" class='page' value='删除'>":"";
		strBtnAdd=me.CanAdd?"<input type='button' style='margin-left:10px;width:50px' onclick=\"LineAction(this,'addrow');\" class='page' value='添加行'>":"";
		strBtnCopyRow=me.CanCopyRow?"<input type='button' class='page' style='width:76px;_width:66px' onclick=\"LineAction(this,'copyrow');\" value='复制所选行' title='将选中的行复制出一份来插入列表'>":"";
		strBtnSwapRowUP=me.CanSwapRow?"<input type='button' style='margin-left:1px' onclick=\"LineAction(this,'rowup');\" class='page' value='上移'>":"";
		strBtnSwapRowDown=me.CanSwapRow?"<input type='button' style='margin-left:1px' onclick=\"LineAction(this,'rowdown');\" class='page' value='下移'>":"";
		td.innerHTML = "<div class='vertical-middle' align='center' style='line-height:26px;text-align:left;width:380px;height:26px;float:left'>" +
		strBtnCheck+
		strBtnAdd+
		strBtnReverse+
		strBtnCopyRow+
		strBtnRemove+
		strBtnSwapRowUP+
		strBtnSwapRowDown+
		"</div>"+
		"<div align='right' style='line-height:26px;height:26px'>共<span id='lv_rec_cnt' style='color:red'>"+me.Rows.length+"</span>行,显示<select id='lv_pg_sz'>"+
		"<option value='10'>10</option>"+
		"<option value='15'>15</option>"+
		"<option value='20'>20</option>"+
		"<option value='30'>30</option>"+
		"<option value='50'>50</option>"+
		"<option value='100'>100</option>"+
		"</select>行</div>";
		document.getElementById("lv_pg_sz").onchange=function()
		{
			me.startIdx=0;
			if(this.id=="lv_pg_sz")
			{
				document.getElementById("lv_pg_sz2").value=this.value
			}
			else
			{
				document.getElementById("lv_pg_sz").value=this.value
			}
			me.RowsPerPage=parseInt(this.value);
			me.RefreshContent();
		};
		document.getElementById("lv_pg_sz2").onchange=document.getElementById("lv_pg_sz").onchange;
		me.Container.rows[0].cells[me.Container.rows[0].cells.length-1].rowSpan=me.Container.rows.length;
		me.CalculateScrollBar();
		var ScrollBar=me.Container.rows[0].cells[me.Container.rows[0].cells.length-1].getElementsByTagName("div")[0];
		ScrollBar.onmousedown=ScrollBarMouseDown;
		me.Container.onmousewheel=function()
		{
			var activeObj=document.activeElement;
			if(activeObj)
			{
				var controls=me.Container.getElementsByTagName("input");
				for(var i=0;i<controls.length;i++)
				{
					if(controls[i]==activeObj)
					{
						me.cantWheel=null;
						activeObj.blur();
						if(me.cantWheel)
						{
							me.cantWheel();
						}
						event.cancelBubble=true;
						return false;
					}
				}
			}
			var rWheel=event.wheelDelta>0?-1:1;
			if((me.startIdx==0&&rWheel<0)||((me.startIdx==me.Rows.length-me.RowsPerPage||me.RowsPerPage>me.Rows.length-1)&&rWheel>0)) return false;
			me.startIdx=me.startIdx+rWheel;
			me.RefreshContent();
			event.cancelBubble=true;
			return false;
		}
		me.FixHeight();
	};

	me.CalculateScrollBar=function()
	{
		var ScrollBar=me.Container.rows[0].cells[me.Container.rows[0].cells.length-1].getElementsByTagName("div")[0];
		//本页显示记录条数除以总记录条数得出百分比，再乘以表格高度得到滚动条高度，
		//然后根据当前显示的第一条记录的位置将滚动条定位到对应位置
		ScrollBar.parentElement.style.display=(me.Rows.length>=me.RowsPerPage)?"block":"none";
		var lvtb=document.getElementById("List_View_Tool_Bar");
		if(lvtb){lvtb.rows[0].cells[lvtb.rows[0].cells.length-1].style.display=ScrollBar.parentElement.style.display;}
		var tbheight=me.Container.rows[0].cells[me.Container.rows[0].cells.length-1].offsetHeight;
		ScrollBar.style.height=tbheight*(me.Rows.length==0?0:(parseFloat(me.RowsPerPage)/parseFloat(me.Rows.length)));
		ScrollBar.style.top=tbheight*(me.Rows.length==0?0:(parseFloat(me.startIdx)/parseFloat(me.Rows.length)));
	};
	
	me.RefreshListByScrollBar=function()
	{
		var ScrollBar=me.Container.rows[0].cells[me.Container.rows[0].cells.length-1].getElementsByTagName("div")[0];
		var newIdx=parseFloat(ScrollBar.style.top)/parseFloat(ScrollBar.parentElement.offsetHeight)*me.Rows.length;
		me.startIdx= parseInt(newIdx<0?0:newIdx>me.Rows.length?me.Rows.length:newIdx);
		me.RefreshContent();
	};
	
	me.ShowCell=function(tdobj,cellobj,isUnitIn)
	{
//		tdobj.style.height=27;
		var tmp=tdobj.children;
		for(var i=0;i<tmp.length;i++)
		{
			try{tmp[i].clearAttributes();}catch(e){};
			tmp[i].onblur=null;
			tmp[i].onclick=null;
			tmp[i].onchange=null;
			tmp[i].onkeyup=null;
			tmp[i].onfocus=null;
			tmp[i].onpropertychange=null;
		}
		tdobj.innerHTML=null;
		var rowidx=tdobj.parentElement.rowIndex;
		if(!isUnitIn) tdobj.style.backgroundColor=cellobj.isError==true?"darkblue":"";
		tdobj.style.fontColor=null;
		switch(cellobj.datatype) 
		{			
			case "checkbox-ckr":
				var ckstr=cellobj.value==1?" checked":"";
				tdobj.innerHTML="<input type='checkbox'"+ckstr+" onclick='SelectRow(this);'>"
				tdobj.align="center";
				break;
			case "idxlabel":
				tdobj.innerHTML=(cellobj.getParent().rowIndex+1)+"<img src='../images/del2.gif' style='cursor:hand' onclick=DeleteRow(this)>";
				tdobj.align="center";
				break;
			case "readonly":
				tdobj.innerHTML=cellobj.text;
				break;
			case "text":
				if(me.EditRow==rowidx)
				{
					var w = "90%"
					if(tdobj.offsetWidth>0) {
						w = parseInt(tdobj.offsetWidth*0.9) + "px"
					}
					tdobj.innerHTML="<input type='text' style='width:" + w + "' value='"+cellobj.value+"'>";
					tdobj.children[0].onblur=function(){tdobj.obj.text=this.value;tdobj.obj.value=this.value;};
					tdobj.children[0].onkeyup=function(){cellobj.text=tdobj.children[0].value;cellobj.value=tdobj.children[0].value;};
				}
				else
				{
					tdobj.innerHTML=cellobj.text;
				}
				tdobj.align="center";
				break;
			case "int":
				if(me.EditRow==rowidx)
				{
					if(isNaN(cellobj.value))cellobj.value=''
					tdobj.innerHTML="<input type='text' name='_int' style='width:90%' value='"+cellobj.value+"' oncontextmenu='window.event.returnValue=false'>";
					tdobj.children[0].onfocus=function(){this.select();};
					tdobj.children[0].onblur=function(){tdobj.obj.text=this.value;tdobj.obj.value=this.value;};
					tdobj.children[0].onkeyup=function(){event.srcElement.value=(isNaN(event.srcElement.value)||event.srcElement.value.indexOf('.')>=0)?'':event.srcElement.value;cellobj.text=tdobj.children[0].value;cellobj.value=tdobj.children[0].value;}
				}
				else
				{
					if(isNaN(cellobj.text))cellobj.text='';
					tdobj.innerHTML=cellobj.text;
				}
				tdobj.align="right";
				break;
			case "decimal":
				if(me.EditRow==rowidx)
				{
					if(isNaN(cellobj.value))cellobj.value=''
					tdobj.innerHTML="<input type='text' name='_decimal' style='width:90%' value='"+cellobj.value+"'  oncontextmenu='window.event.returnValue=false'>";
					tdobj.children[0].onfocus=function(){this.select();};
					tdobj.children[0].onblur=function(){
							cellobj.text=this.value;cellobj.value=this.value;
					};
					tdobj.children[0].onkeyup=function(){event.srcElement.value=(isNaN(event.srcElement.value))?'':event.srcElement.value;cellobj.text=event.srcElement.value;cellobj.value=event.srcElement.value;};
				}
				else
				{
					if(isNaN(cellobj.text))cellobj.text='';
					tdobj.innerHTML=cellobj.text;
				}
				tdobj.align="right";
				break;
			case "multiline":
				if(me.EditRow==rowidx)
				{
					tdobj.innerHTML="<textarea style='width:90%;height:27px'>"+cellobj.value+"</textarea>";
					tdobj.children[0].onblur=function(){
						tdobj.obj.text=(this.value?this.value:this.innerHTML);
						tdobj.obj.value=(this.value?this.value:this.innerHTML);
					};
					tdobj.children[0].onkeyup=function(){
						cellobj.text=tdobj.children[0].value;
						cellobj.value=tdobj.children[0].value;
					};
					tdobj.align="center";
				}
				else
				{
					tdobj.innerHTML=cellobj.text;
				}
				break;
			case "datetime":
				if(me.EditRow==rowidx)
				{
					var ridx=cellobj.cellIndex;
					var cidx=cellobj.getParent().rowIndex;
					tdobj.innerHTML="<input type='text' readonly style='width:90%' value='"+cellobj.value+"' onclick='datedlg.show();' >";
					tdobj.children[0].onchange=function(){cellobj.text=tdobj.children[0].value;cellobj.value=tdobj.children[0].value;};
				}
				else
				{
					tdobj.innerHTML=cellobj.text;
				}
				break;
			default:
				LVCustomShowCell(tdobj,cellobj,me.EditRow , isUnitIn);
		}
	}

	me.checkData = function()
	{
		var rtnvalue=true;
		for (var i=0;i<me.Rows.length;i++)
		{
			var row = me.Rows[i];
			for (var ii = 0 ; ii < row.Cells.length ; ii++)
			{
				var c = row.Cells[ii];
				var wm = {result:true};
				if (c.type)
				{
					wm = c.type.match(c.value);
				}
				else
				{
					wm = me.Headers[ii].type.match(c.value);
				}
				if (wm.result == false )
				{
					me.Rows[i].Cells[ii].isError=true;
					rtnvalue = false;
				}
				else
				{
					me.Rows[i].Cells[ii].isError=false;
				}
			}
		}
		return rtnvalue;
	};

	me.getDataText = function(ignore)
	{ //获取保存的数据
		if(ignore==false||ignore==undefined)
		{
			me.checkData();
			me.RefreshContent();
		}
		var r = "";
		for (var i = 0 ; i<me.Rows.length ;  i++)
		{
			var row = me.Rows[i];
			for (var ii = 0 ; ii < row.Cells.length ; ii++)
			{
				var c = row.Cells[ii];
				var wm = {result:true};
				if (c.type)
				{
					wm = c.type.match(c.value);
				}
				else
				{
					wm = me.Headers[ii].type.match(c.value);
				}
				if (wm.result == false && (ignore==false||ignore==undefined))
				{
					var bubble=true;
					if(window.CustomShowError) {bubble=CustomShowError(wm,c);}
					if(bubble) alert("第"+(i+1)+"行["+me.Headers[ii].innerHTML+"]列数据不合法："+wm.message);
					me.startIdx=(i>(me.Rows.length-me.RowsPerPage))?(me.Rows.length>me.RowsPerPage?me.Rows.length-me.RowsPerPage:0):i;
					me.RefreshContent();
					if(me.Rows[i].Cells[ii].obj)
					{
						var tr=me.Rows[i].Cells[ii].obj.parentElement;
						tr.fireEvent("onclick");
						me.EditRow=tr.rowIndex;
						me.RefreshRow(me.EditRow);
					}
					return "---";
				}
				r = r + (ii > 0 ? "\4\5" : "") + c.value;
				if (c.fznum)
				{
				    r = r + ','+c.fznum;
				}
			}
			if(i<me.Rows.length-1) r = r + "\1\2";
		}
		if(ignore==false||ignore==undefined)
		{
			me.RefreshContent();
		}
		return r;
	};
	return me;
}

function sortArrayFun(p1,p2)
{
	var p3=parseInt(p1[0]);
	var p4=parseInt(p2[0]);
	return (p3>p4?1:p3==p4?0:-1);
}

var ScrollingObj=null;
function ScrollBarMouseDown(event,obj)
{
	obj=obj||this;
	event=event||window.event;
	ScrollingObj=obj;
	obj.mouseDownY=event.clientY;
	obj.oldTop=obj.style.top;
	if(obj.setCapture)
	{
		obj.setCapture();
	}
	else
	{
		event.preventDefault();
	}
}

function ScrollBarMouseMove(event)
{
	if(!ScrollingObj) return;
	var obj=ScrollingObj;
	event=event||window.event;
	if(!obj.mouseDownY) return false;
	var newPos=parseInt(event.clientY)-parseInt(obj.mouseDownY);
	var ot=parseInt(obj.oldTop);
	if(ot+newPos>0)
	{
		if(ot+newPos<obj.parentElement.offsetHeight-obj.offsetHeight)
		{
			obj.style.top=ot+newPos;
		}
		else
		{
			obj.style.top=obj.parentElement.offsetHeight-obj.offsetHeight+"px";
		}
	}
	else
	{
		obj.style.top=0+"px";
	}
	//obj.style.top = parseInt(obj.style.top)+newPos>0?(parseInt(obj.style.top)+newPos<obj.parentElement.offsetHeight-obj.offsetHeight?newPos:obj.parentElement.offsetHeight-obj.offsetHeight):0;
	obj.parentElement.obj.RefreshListByScrollBar();
}

function ScrollBarMouseUP()
{
	if(!ScrollingObj) return;
	if (ScrollingObj.releaseCapture)
	{
		ScrollingObj.releaseCapture();
	}
	ScrollingObj=null;
}

function SelectRow(ckobj)
{
	var tdobj=ckobj.parentElement.obj;
	if(tdobj.otype=="datacell")
	{
		tdobj.value=ckobj.checked?1:0;
	}
}

function DeleteRow(delimg)
{
	var td=delimg.parentElement;
	var c=td.parentElement.parentElement.parentElement.parentElement;
	if(c.disabled==true) return;
	var CellObj=td.obj;
	var RowObj=CellObj.getParent();
	var tbObj=RowObj.getParent();
	tbObj.Rows.splice(RowObj.rowIndex,1);
	for(var i=0;i<tbObj.Rows.length;i++){tbObj.Rows[i].rowIndex=i;}
	if(tbObj.startIdx>0) {tbObj.startIdx--;}
	tbObj.RefreshContent();
	if (window.GetAllMoney)
	{
		GetAllMoney();
	}
	if(window.event && window.event.stopPropagation){
		window.event.stopPropagation();
	}else{
		window.event.cancelBubble = true;
	}
}

function Header(t,w,sort,display,h,c,s,uin,resize)
{
	var me=new Object();
	me.oType="header";
	me.innerHTML=t==undefined?"":t;
	me.width=w==undefined?"100":w;
	me.height=h==undefined?"27":h;
	me.className=c==undefined?"":c;
	me.cssText=s==undefined?"":s;
	me.unitin=uin==undefined?true:uin;
	me.resize = resize==undefined?1:resize;
	me.type = new ValueClass(me);
	me.CanSum=0;
	me.digit=null;

	me.display=display==undefined?1:display;;
	me.sort=sort==undefined?0:sort;
	me.linkid = 0;
	return me;
}

function Row(tb)
{
	var me = new Object();
	me.Cells = new Array();
	me.rowIndex = -1;
	me.otype = "datarow";
	me.getCellsBySort=function(sort){return me.Cells[tb.IndexMap[sort]];};

	me.Cells.Add = function(cell)
	{
		if(me.Cells.length>=tb.Headers.length)
		{
			alert("列数超出");
			return null;
		}
		if(cell && cell.otype=="datacell")
		{
			me.Cells[me.Cells.length] = cell;
		}
		else
		{
			me.Cells[me.Cells.length] = new Cell(me);
		}
		me.Cells[me.Cells.length-1].cellIndex=me.Cells.length-1;
		return me.Cells[me.Cells.length-1]
	};

	me.Cells[me.Cells.length] = new Cell(me);
	me.Cells[me.Cells.length-1].datatype="checkbox-ckr";
	me.Cells[me.Cells.length-1].cellIndex=me.Cells.length-1;
	me.Cells[me.Cells.length-1].value=0;
	me.Cells[me.Cells.length-1].text="";
	me.Cells[me.Cells.length] = new Cell(me);
	me.Cells[me.Cells.length-1].datatype="idxlabel";
	me.Cells[me.Cells.length-1].cellIndex=me.Cells.length-1;
	me.Cells[me.Cells.length-1].text="";
	me.Cells[me.Cells.length-1].value=tb.Identity++;

	me.getParent = function(){return tb;};
	me.insertCell = function(idx){return new Cell(me);}
	return me;
}

function Cell(row)
{
	if(!row || row.otype!="datarow") return null;
	var me=new Object();
	me.text = "";
	me.value = "";
	me.datatype = "";
	me.otype = "datacell";
	me.getParent = function(){return row;}
	me.type = null;
	me.isError = false;
	me.CopyFromCell=function(c)
	{
		me.text = c.text;
		me.value = c.value;
		me.datatype = c.datatype;
		me.type = c.type;
		me.isError = c.isError;
	};
	return me;
}

function LineAction(lkobj,actiontype)
{
	var lvobj=lkobj.parentElement.parentElement.obj;
	switch(actiontype)
	{
		case "addrow":
			var frameobj=document.getElementById("proSelectFrame");
			var proPanel=document.getElementById("productselect");
			if(frameobj.contentWindow.document.location.href.indexOf(".asp")==-1)
			{
				frameobj.contentWindow.document.location="../product/productSelect2.asp";
				proPanel.style.left="300px";
			}
			proPanel.style.top = (document.documentElement.scrollTop + 10) + "px";//仓库直接入库，弹层位置不对，标准文档下用document.documentElement.scrollTop取卷起高度；
			proPanel.style.display="inline";
			proPanel.style.width="240px";//库存——仓库管理——入库管理——直接入库 点击添加行，弹出的框宽度不够
			break;
		case "checkall":
			window._com_lvw_checkallbox = lkobj;
			for(var i=0;i<lvobj.Rows.length;i++)
			{
				lvobj.Rows[i].Cells[0].value=lkobj.checked?1:0;
			}
			var tbobj=lkobj.parentElement.parentElement.parentElement.parentElement.parentElement;
			for(var i=1;i<tbobj.rows.length-2;i++)
			{
				tbobj.rows[i].cells[0].children[0].checked=lkobj.checked;
			}
			break;
		case "remove":
			for(var i=0;i<lvobj.Rows.length;i++)
			{
				if(lvobj.Rows[i].Cells[0].value==1)
				{
					lvobj.Rows.splice(i,1);
					i--;
				}
			}
			for(var i=0;i<lvobj.Rows.length;i++){lvobj.Rows[i].rowIndex=i;}
			lvobj.startIdx=0;
			lvobj.RefreshContent();
			if(window._com_lvw_checkallbox) {
				try{window._com_lvw_checkallbox.checked = false} catch(e){}
			}
			break;
		case "reverse":
			for(var i=0;i<lvobj.Rows.length;i++)
			{
				lvobj.Rows[i].Cells[0].value=lvobj.Rows[i].Cells[0].value==1?0:1;
			}
			var tbobj=lkobj.parentElement.parentElement.parentElement.parentElement.parentElement;
			for(var i=1;i<tbobj.rows.length-2;i++)
			{
				tbobj.rows[i].cells[0].children[0].checked=!(tbobj.rows[i].cells[0].children[0].checked);
			}
			break;
		case "rowup":
			var firstSelect=-1;
			for(var i=0;i<lvobj.Rows.length;i++){if(lvobj.Rows[i].Cells[0].value==1){firstSelect=i;break;}}
			if(firstSelect<0){alert("请先选中要移动的行！");return;}
			for(var i=firstSelect;i<lvobj.Rows.length;i++)
			{
				if(i==0){alert("已移到顶部");return;}
				if(lvobj.Rows[i].Cells[0].value==1) lvobj.Rows.SwapRow(i,i-1);
			}
			lvobj.RefreshContent();
			break;
		case "rowdown":
			var firstSelect=-1;
			for(var i=lvobj.Rows.length-1;i>=0;i--){if(lvobj.Rows[i].Cells[0].value==1){firstSelect=i;break;}}
			if(firstSelect<0){alert("请先选中要移动的行！");return;}
			for(var i=firstSelect;i>=0;i--)
			{
				if(i==lvobj.Rows.length-1){alert("已移到底部");return;}
				if(lvobj.Rows[i].Cells[0].value==1) lvobj.Rows.SwapRow(i,i+1);
			}
			lvobj.RefreshContent();
			break;
		case "copyrow":
			var icnt=0,rcnt=lvobj.Rows.length;
			for(var i=0;i<rcnt;i++)
			{
				if(lvobj.Rows[i].Cells[0].value==1)
				{
					var row=lvobj.Rows.Add();
					row.Cells[0].value = 0;
					row.Cells[1].value = lvobj.Rows[i].Cells[1].value;
					row.rowIndex=lvobj.Rows.length-1;
					for(var j=2;j<lvobj.Rows[i].Cells.length;j++)
					{
						var cell=row.Cells.Add();
						cell.CopyFromCell(lvobj.Rows[i].Cells[j]);
					}
					if(typeof(CustomCopyRow)!='undefined'){CustomCopyRow(lvobj,i,row);};
					icnt++;
				}
			}
			if(icnt==0){alert("请先选中要复制的行！");return;}
			window.ajax.url = "CommonReturn.asp?act=getUniqueNo&ucnt="+icnt;
			window.ajax.regEvent("");
			var s = window.ajax.send();
			if(s!="")
			{
				var v=s.split(",")
				for(var i=0;i<v.length;i++)
				{
				    var currRowIndex = lvobj.Rows.length - icnt--;
				    var yIndex = lvobj.Rows[currRowIndex].Cells[1].value;
				    lvobj.Rows[currRowIndex].Cells[1].value = v[i];
				    if (typeof (CustomCopyRowIndex) != 'undefined') { CustomCopyRowIndex(lvobj, currRowIndex, yIndex, v[i]); };
				}
			}
			lvobj.RefreshContent();
			break;
		default:
			LVAddRow(lkobj);
			break;
	}
}


//遍历FORM（或者任意容器），根据fn函数决定是否将其值组合成URL字符串，用于AJAX提交
//如果没有传入fn，则只要有name属性并且值不为空的，都会加入参数列表
//fn函数名可自定义，参数为控件对象，比如某个input
function LinkUrlParamByForm(frmobj,fn)
{
	if(!frmobj) return "";
	var formpara="";
	//查找INPUT，保存其值
	var obj=frmobj.getElementsByTagName("input");
	for(var i=0;i<obj.length;i++)
	{
		if(fn)
		{
			if(fn(obj[i]))
			{
				formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
			}
		}
		else if(obj[i].name&&obj[i].value!="")
		{
			if(obj[i].type=="radio")
			{
				if(obj[i].checked) formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
			}
			else
			{
				formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
			}
		}
	}
	//查找Select,保存其值
	var obj=frmobj.getElementsByTagName("select");
	for(var i=0;i<obj.length;i++)
	{
		if(fn)
		{
			if(fn(obj[i]))
			{
				formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
			}
		}
		else if(obj[i].name&&obj[i].value!="")
		{
				formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
		}
	}

    //查找textarea,保存其值 //无法保存备注
	var obj = frmobj.getElementsByTagName("textarea");
	for (var i = 0; i < obj.length; i++) {
	    if (fn) {
	        if (fn(obj[i])) {
	            formpara += (formpara == "" ? "" : "&") + obj[i].name + "=" + URLencode(obj[i].value);
	        }
	    }
	    else if (obj[i].name && obj[i].value != "") {
	        formpara += (formpara == "" ? "" : "&") + obj[i].name + "=" + URLencode(obj[i].value);
	    }
	}
	return formpara;
}

function URLencode(data)
{
    //return escape(sStr).replace(/\+/g, '%2B').replace(/\"/g,'%22').replace(/\'/g, '%27').replace(/\//g,'%2F');
        var ascCodev = "& ﹙ ﹚ ﹛ ﹜ ＋ － × ÷ ﹢ ﹣ ≠ ≤ ≥ ≈ ≡ ≒ ∥ ／ ± ＜ ＞ ﹤ ﹥ ≦ ＝ ≧ ≌ ∽ ≮ ≯ ∶ ∴ ∵ ∷ ⊙ ∑ ∏ ∪ ∩ ∈ ⌒ ⊥ ∠ ㏑ ￠ ㏒ ∟ √ ∨ ∧ ∞ ∝ ∮ ∫ ％ ‰ ℅ ° ℃ ℉ ′ ″ 〒 ¤ ○ ￡ ￥ ㏕ ♂ ♀ △ ▽ ● ○ ◇ □ · — ˉ ¨ 々 ～ ‖ 」 「 『 』 ． 〖 〗 【 】 € ‰ ◆ ◎ ★ ☆ § ā á ǎ à ō ó ǒ ò ê ē é ě è ī í ǐ ì ū ú ǔ ù ǖ ǘ ǚ ǜ ü μ μ ˊ ﹫ ＿ ﹌ ﹋ ′ ˋ ― ︴ ˉ ￣ θ ε ‥ ☉ ⊕ Θ ◎ の ⊿ … ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▉ ▊ ▋ ▌ ▍ ▎ ▏ ⌒ ￠ ℡ ㈱ ㊣ ▏ ▕ ▁ ▔ ↖ ↑ ↗ → ← ↙ ↓ ↘ 卍 ◤ ◥ ◢ ◣ 卐 ∷ № § Ψ ￥ ￡ ≡ ￢ ＊ Ю".split(" ");
        //gb2312加密方法：var ascCodec = "%26+%A9v+%A9w+%A9x+%A9y+%A3%AB+%A3%AD+%A1%C1+%A1%C2+%A9%80+%A9%81+%A1%D9+%A1%DC+%A1%DD+%A1%D6+%A1%D4+%A8P+%A1%CE+%A3%AF+%A1%C0+%A3%BC+%A3%BE+%A9%82+%A9%83+%A8Q+%A3%BD+%A8R+%A1%D5+%A1%D7+%A1%DA+%A1%DB+%A1%C3+%A1%E0+%A1%DF+%A1%CB+%A1%D1+%A1%C6+%A1%C7+%A1%C8+%A1%C9+%A1%CA+%A1%D0+%A1%CD+%A1%CF+%A9R+%A1%E9+%A9S+%A8N+%A1%CC+%A1%C5+%A1%C4+%A1%DE+%A1%D8+%A1%D3+%A1%D2+%A3%A5+%A1%EB+%A8G+%A1%E3+%A1%E6+%A8H+%A1%E4+%A1%E5+%A8%93+%A1%E8+%A1%F0+%A1%EA+%A3%A4+%A9T+%A1%E1+%A1%E2+%A1%F7+%A8%8C+%A1%F1+%A1%F0+%A1%F3+%A1%F5+%a1%a4+%a1%aa+%a1%a5+%a1%a7+%a1%a9+%a1%ab+%a1%ac+%a1%b9+%a1%b8+%a1%ba+%a1%bb+%a3%ae+%a1%bc+%a1%bd+%a1%be+%a1%bf+%80+%a1%eb+%a1%f4+%a1%f2+%a1%ef+%a1%ee+%a1%ec+%a8%a1+%a8%a2+%a8%a3+%a8%a4+%a8%ad+%a8%ae+%a8%af+%a8%b0+%a8%ba+%a8%a5+%a8%a6+%a8%a7+%a8%a8+%a8%a9+%a8%aa+%a8%ab+%a8%ac+%a8%b1+%a8%b2+%a8%b3+%a8%b4+%a8%b5+%a8%b6+%a8%b7+%a8%b8+%a8%b9+%a6%cc+%a6%cc+%a8%40+%a9%88+%a3%df+%a9k+%a9j+%a1%e4+%a8A+%a8D+%a6%f5+%a1%a5+%a3%fe+%a6%c8+%a6%c5+%a8E+%a8%91+%a8%92+%a6%a8+%a1%f2+%a4%ce+%a8S+%a1%ad+%a8x+%a8y+%a8z+%a8%7b+%a8%7c+%a8%7d+%a8%7e+%a8%80+%a8%81+%a8%82+%a8%83+%a8%84+%a8%85+%a8%86+%a8%87+%a1%d0+%a1%e9+%a9Y+%a9Z+%a9I+%a8%87+%a8%8a+%a8x+%a8%89+%a8I+%a1%fc+%a8J+%a1%fa+%a1%fb+%a8L+%a1%fd+%a8K+%85d+%a8%8f+%a8%90+%a8%8d+%a8%8e+%85e+%a1%cb+%a1%ed+%a1%ec+%a6%b7+%a3%a4+%a1%ea+%a1%d4+%a9V+%a3%aa+%a7%c0".split("+");
        //utf-8加密方法
        var ascCodec = "%26+%ef%b9%99+%ef%b9%9a+%ef%b9%9b+%ef%b9%9c+%ef%bc%8b+%ef%bc%8d+%c3%97+%c3%b7+%ef%b9%a2+%ef%b9%a3+%e2%89%a0+%e2%89%a4+%e2%89%a5+%e2%89%88+%e2%89%a1+%e2%89%92+%e2%88%a5+%ef%bc%8f+%c2%b1+%ef%bc%9c+%ef%bc%9e+%ef%b9%a4+%ef%b9%a5+%e2%89%a6+%ef%bc%9d+%e2%89%a7+%e2%89%8c+%e2%88%bd+%e2%89%ae+%e2%89%af+%e2%88%b6+%e2%88%b4+%e2%88%b5+%e2%88%b7+%e2%8a%99+%e2%88%91+%e2%88%8f+%e2%88%aa+%e2%88%a9+%e2%88%88+%e2%8c%92+%e2%8a%a5+%e2%88%a0+%e3%8f%91+%ef%bf%a0+%e3%8f%92+%e2%88%9f+%e2%88%9a+%e2%88%a8+%e2%88%a7+%e2%88%9e+%e2%88%9d+%e2%88%ae+%e2%88%ab+%ef%bc%85+%e2%80%b0+%e2%84%85+%c2%b0+%e2%84%83+%e2%84%89+%e2%80%b2+%e2%80%b3+%e3%80%92+%c2%a4+%e2%97%8b+%ef%bf%a1+%ef%bf%a5+%e3%8f%95+%e2%99%82+%e2%99%80+%e2%96%b3+%e2%96%bd+%e2%97%8f+%e2%97%8b+%e2%97%87+%e2%96%a1+%c2%b7+%e2%80%94+%cb%89+%c2%a8+%e3%80%85+%ef%bd%9e+%e2%80%96+%e3%80%8d+%e3%80%8c+%e3%80%8e+%e3%80%8f+%ef%bc%8e+%e3%80%96+%e3%80%97+%e3%80%90+%e3%80%91+%e2%82%ac+%e2%80%b0+%e2%97%86+%e2%97%8e+%e2%98%85+%e2%98%86+%c2%a7+%c4%81+%c3%a1+%c7%8e+%c3%a0+%c5%8d+%c3%b3+%c7%92+%c3%b2+%c3%aa+%c4%93+%c3%a9+%c4%9b+%c3%a8+%c4%ab+%c3%ad+%c7%90+%c3%ac+%c5%ab+%c3%ba+%c7%94+%c3%b9+%c7%96+%c7%98+%c7%9a+%c7%9c+%c3%bc+%ce%bc+%ce%bc+%cb%8a+%ef%b9%ab+%ef%bc%bf+%ef%b9%8c+%ef%b9%8b+%e2%80%b2+%cb%8b+%e2%80%95+%ef%b8%b4+%cb%89+%ef%bf%a3+%ce%b8+%ce%b5+%e2%80%a5+%e2%98%89+%e2%8a%95+%ce%98+%e2%97%8e+%e3%81%ae+%e2%8a%bf+%e2%80%a6+%e2%96%81+%e2%96%82+%e2%96%83+%e2%96%84+%e2%96%85+%e2%96%86+%e2%96%87+%e2%96%88+%e2%96%89+%e2%96%8a+%e2%96%8b+%e2%96%8c+%e2%96%8d+%e2%96%8e+%e2%96%8f+%e2%8c%92+%ef%bf%a0+%e2%84%a1+%e3%88%b1+%e3%8a%a3+%e2%96%8f+%e2%96%95+%e2%96%81+%e2%96%94+%e2%86%96+%e2%86%91+%e2%86%97+%e2%86%92+%e2%86%90+%e2%86%99+%e2%86%93+%e2%86%98+%e5%8d%8d+%e2%97%a4+%e2%97%a5+%e2%97%a2+%e2%97%a3+%e5%8d%90+%e2%88%b7+%e2%84%96+%c2%a7+%ce%a8+%ef%bf%a5+%ef%bf%a1+%e2%89%a1+%ef%bf%a2+%ef%bc%8a+%d0%ae".split("+");
        data = data.replace(/\n/g, "kglllsk9527v10end9528ocv");
        data = data.replace(/\r/g, "kglllsk9527v13end9528ocv");
        data = data.replace(/\s/g, "kglllskjdfsfdsdwerr")//\s会替换掉所有的空白字符包括\n,\r,\f,\t,\v
        data = escape(data);
		if(data.indexOf("%B5")>-1){
			data = data.replace("%B5","%u03BC")
		}
		data = unescape(data);
        if (!isNaN(data) || !data) { return data; }
        for (var i = 0; i < ascCodev.length; i++) {
            var re = new RegExp(ascCodev[i], "g")
            data = data.replace(re, "ajaxsrpchari" + i + "endbyjohnny");
            re = null;
        }
        data = escape(data);
		
        for (var i = ascCodev.length - 1; i > -1; i--) {
            var re = new RegExp("ajaxsrpchari" + i + "endbyjohnny", "g")
            data = data.replace(re, ascCodec[i]);
        }
        data = data.replace(/\+/g, "%2B");
		data = data.replace(/\"/g,'%22');
		data = data.replace(/\'/g, '%27');
		data = data.replace(/\·/g,'%16');
		data = data.replace(/\*/g, "%2A"); 	//置换*		
        data = data.replace(/\-/g, "%2D"); 	//置换-
        data = data.replace(/\./g, "%2E"); 	//置换.
        data = data.replace(/\@/g, "%40"); 	//置换@
        data = data.replace(/\_/g, "%5F"); 	//置换_
        data = data.replace(/\//g, "%2F"); 	//置换/
        data = data.replace(/kglllskjdfsfdsdwerr/g, "%20")
        data = data.replace(/kglllsk9527v13end9528ocv/g, "%0D")
        data = data.replace(/kglllsk9527v10end9528ocv/g, "%0A")
        return data;
}

//ValueClass 内容的约束类
function ValueClass(me){
	var obj = new Object();
	obj.name= "text",			//类型名称
	obj.max	= 1000000000000,	//最大值
	obj.min	=-1000000000000,	//最小值
	obj.notnull= false,			//不允许空
	obj.notmin=false;//最小值判断中不允许等于最小值
	obj.notmax=false;//最大值判断中不允许等于最大值
	obj.notzero=false;//是否允许等于0
	obj.size=-1,				//字段尺寸, -1为不限 , 0为必须不填，数字、日期类型不做大小判断
	obj.matchfun=null,
	obj.match= function(v){
		if(this.matchfun){return matchfun(me,v);}
		var rv = {result : true , message : "" ,errno : 0};
		switch(this.name){
			case "text":
				if(v + "" == "" && this.notnull==true)
				{
					rv.message = "内容不能为空";
					rv.result  = false;
					rv.errno = 0;
					break;
				}
				if (this.size >=0 && v.length > this.size)
				{
					rv.message = "字符内容超过" + this.size + "个字。"
					rv.result = false
					rv.errno = 1;
					break;
				}
				break;
			case "number":
				if(v + "" == "" && this.notnull==true)
				{
					rv.message = "内容不能为空"
					rv.result  = false
					rv.errno = 2;
					break;
				}
				if(isNaN(v)){
					rv.message = "内容不是正确的数字"
					rv.result  = false
					rv.errno = 3;
					break;
				}
				v = parseFloat(FormatNumber(v,8));//Task 2196 Sword 库存显示是1.791，一点保存就是1.79099999了 判断有误
				if(v > this.max || v < this.min ){
					rv.message = "数值超出允许范围（" + this.min + " - " + this.max + "）"
					rv.result  = false
					rv.errno = 4;
					break;
				}
				if(this.notmin==true&&parseFloat(v)-this.min==0)
				{
					rv.message = "数值不允许等于（" + this.min + "）";
					rv.result  = false
					rv.errno = 13;
					break;
				}
				else if(this.notmax==true&&parseFloat(v)-this.max==0)
				{
					rv.message = "数值不允许等于（" + this.max + "）";
					rv.result  = false
					rv.errno = 14;
					break;
				}
				if(this.notzero&&v-0==0)
				{
					rv.message = "数值不允许等于0";
					rv.result  = false
					rv.errno = 15;
					break;
				}
				break;
			case "date":
				if(v + "" == "" && this.notnull==true)
				{
					rv.message = "内容不能为空"
					rv.result  = false
					rv.errno = 5;
					break;
				}
				v = v.replace("-","/")
				var dat = new Date(v)
				if(isNaN(dat)) {
					rv.message = "内容不是正确的日期"
					rv.result  = false;
					rv.errno = 6;
					break;
				}
				if(v.indexOf("/" + dat.getMonth + "/") < 0){
					rv.message = "内容不是正确的日期"
					rv.result  = false;
					rv.errno = 7;
					break;
				}
				break;
			case "int":
				if(v + "" == "" && this.notnull==true)
				{
					rv.message = "内容不能为空"
					rv.result  = false
					rv.errno = 8;
					break;
				}
				if(isNaN(v)){
					rv.message = "内容不是正确的整数"
					rv.result  = false
					rv.errno = 9;
					break;
				}
				if(v > this.max || v < this.min ){
					rv.message = "整数超出允许范围（" + this.min + " - " + this.max + "）"
					rv.result  = false
					rv.errno = 10;
					break;
				}
				if(this.notmin==true&&parseInt(v)==this.min)
				{
					rv.message = "数值不允许等于（" + this.min + "）";
					rv.result  = false
					rv.errno = 16;
					break;
				}
				else if(this.notmax==true&&parseInt(v)==this.max)
				{
					rv.message = "数值不允许等于（" + this.max + "）";
					rv.result  = false
					rv.errno = 17;
					break;
				}
				if(this.notzero&&v-0==0)
				{
					rv.message = "数值不允许等于0";
					rv.result  = false
					rv.errno = 15;
					break;
				}
				if(v.toString().indexOf(".")>=0){
					rv.message = "内容不是正确的整数"
					rv.result  = false
					rv.errno = 11;
				}
				break;
			default:
				rv.message = "未知的属性name"
				rv.result = false
				rv.errno = 12;
		}
		return rv;
	}
	return obj;
};

function formatDot(v,dot)
{
	if((v+"").length==0) return "";
	var varr=v.split('.');
	var strInt=varr[0].length>12?varr[0].substring(0,12):varr[0];
	var strDec="";
	if(varr.length==2) strDec=varr[1].length>dot?varr[1].substring(0,dot):varr[1];
	return v.indexOf('.')>=0?strInt+'.'+strDec:strInt;
}

