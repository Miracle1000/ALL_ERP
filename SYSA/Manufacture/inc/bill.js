var Bill = { // 单据基本操作
    OrderId: 0 //单据编号
	,
	canconfig : 0 //是否有设置权限
	,
    ParentID: 0 //父单据编号
	,
	disUserDef : 0 //是否有用户自定义字段
	,
	hsAutoCode : 1 //是否用自动编号字段
	,
	pasteAlert : "" //粘贴时的提示
	,
    showunderline: function (obj, c) {
        obj.style.textDecoration = "underline";
        if (c) {
			obj.style.color = c
            //obj.style.color = "#2F49a1";
        }
    }
	,
	getInputByDBName : function(dbname) {
		//bug.3238.binary.新增函数，根据dbname获取对应的表单元素。
		var dbname = dbname.toLowerCase();
		var inputs = document.getElementsByTagName("input");
        for (var i = 0; i < inputs.length; i++) {
            var input = inputs[i]
			var db = input.getAttribute("dbname");
            if (db && (db + "").toLowerCase()==dbname) {
				return input;
            }
        }
		inputs = document.getElementsByTagName("select");
        for (var i = 0; i < inputs.length; i++) {
            var input = inputs[i]
			var db = input.getAttribute("dbname");
            if (db && (db + "").toLowerCase()==dbname) {
				return input;
            }
        }
		return null;
	}
	,
    hideunderline: function (obj, c) {
        obj.style.textDecoration = "none";
         if (c) {
             c = c.toLowerCase();
			 if (c=="blue" || c == "#0000ff") {
				c = "#2F496E";
			 }
			 obj.style.color = c
         }
    }
	,
    getdbInputData: function () {
        var v = new Array();
        var inputs = document.getElementsByTagName("input")
        for (var i = 0; i < inputs.length; i++) {
            var input = inputs[i]
            if (input.dbname) {
				var vl = v.length;
				if (input.title.length>0)
				{
					if (input.title.length < 50) {
						v[vl] = escape("dbf_" + input.dbname) + "=" + escape(input.title.replace(/\+/, "#-add"));
					}
					else {
						v[vl] = escape("dbf_" + input.dbname) + "=" + escape(input.title.substring(0, 30).replace(/\+/, "#-add"));
					}
				}
				else{
					if (input.value.length < 50) {
						v[vl] = escape("dbf_" + input.dbname) + "=" + escape(input.value.replace(/\+/, "#-add"));
					}
					else {
						v[vl] = escape("dbf_" + input.dbname) + "=" + escape(input.value.substring(0, 30).replace(/\+/, "#-add"));
					}
				}
				if(input.getAttribute("dType")=="number") {
					if(isNaN(v[vl].replace("dbf_" + input.dbname + "=",""))) {
						v[vl] = "dbf_" + input.dbname + "=0";
					}
				}	
			
            }
        }
        var sels = document.body.getElementsByTagName("select")
        for (var i = 0; i < sels.length; i++) {
            var sel = sels[i]
            if (sel.dbname) {
                if (sel.value.length < 30) {
                    v[v.length] = escape("dbf_" + sel.dbname) + "=" + escape(sel.value.replace(/\+/, "#-add"));
                }
                else {
                    v[v.length] = escape("dbf_" + sel.dbname) + "=" + escape(sel.value.substring(0, 30).replace(/\+/, "#-add"));
                }
            }
        }
        return v.join("&")
    }
	,
	getbillselectv : function(input){ //转换billselectname值
		if(input.sBoxArray){
			var  sBoxArray = input.sBoxArray.split(";")
			for (var i = 0; i < sBoxArray.length ; i++)
			{
				var item = sBoxArray[i].split("=")
				if(item.length==2){
					var v = item[0].replace(/\$“/g,"\"").replace(/\$\-/g,"=").replace(/\$\；/g,";")
					var tag = item[1].replace(/\$“/g,"\"").replace(/\$\-/g,"=").replace(/\$\；/g,";")				
					if(v==input.value){
						input.value = tag;
						input.title = v;
					}
				}
			}
		}
	}
	,
	billcanRead : function(oid, bid){ //是否有权限查看单据
		ajax.regEvent("GetReadPower");
		ajax.addParam("oid",oid);
		ajax.addParam("bid",bid);
		r = ajax.send();
	}
	,
    RefreshDetail: function (disalert, listid) { //binary.2014.01.04.增加参数listid，只刷新指定的明细
		var code = "",sIndex = 0 ,eIndex = 0
        if (!disalert) {
            if (!window.confirm("该操作将重新生成明细资料，是否要继续？")) { return; }
        }
        ajax.url = window.location.pathname
        ajax.regEvent("")
        ajax.sendText = ajax.sendText + "&" + Bill.getdbInputData();
        if (ajax.sendText.toLowerCase().indexOf("&id=") < 0)
        { ajax.addParam("ID", document.getElementById("Bill_Info_id").value); }
        if (ajax.sendText.toLowerCase().indexOf("&parentid=") < 0)
        { ajax.addParam("ParentID", Bill.ParentID); }
        if (ajax.sendText.toLowerCase().indexOf("&orderid=") < 0)
        { ajax.addParam("OrderId", Bill.OrderId); }
        var r = ajax.send();
		code = r;
		if (r.indexOf("<error>")>=0)
		{
			sIndex = r.indexOf("<error>")
			eIndex = r.indexOf("</error>")
			alert( r.substring(sIndex, eIndex + 8).replace("<error>","").replace("</error>",""))
			return false
		}

		var error = (r.indexOf("</html>")<0);
        sIndex = r.indexOf("<body");
        eIndex = r.indexOf("</body>");
        r = r.substring(sIndex, eIndex + 7);
        var doc = document.createElement("body")
		if(error){
			doc.innerHTML = r.substring(117)
			if(doc.innerText.length<4){
				doc.innerHTML = code;
			}
			alert(doc.innerText) //错误信息
		}
		else{
			doc.innerHTML = r
			var tbs = doc.getElementsByTagName("table")
			for (var i = 0; i < tbs.length; i++) {
				if (tbs[i].className.indexOf("listviewframe")>=0) {
					var id = tbs[i].parentElement.id;
					hs = true;
					if (listid && listid > 0)
					{
						hs =  false
						var divs = document.getElementById(id).getElementsByTagName("DIV");
						for (var ii = 0; ii< divs.length ; ii++ )
						{
							if(divs[ii].id == ("listview_"+ listid)){
								hs = true;
								break;
							}
						}
				
					}
					if(hs==true)
					{
						if (id.length > 0) {
							document.getElementById(id).innerHTML = tbs[i].outerHTML;
						}
					}
				}
			}
		}
        doc = null;
        lvw.UpdateAllScroll();
		if(Bill.cpZdyIDKey!="") {
			if(window.billzdyTimeout>0) { window.clearTimeout(window.billzdyTimeout); }
			window.billzdyTimeout = window.setTimeout(
			function(){
				ajax.regEvent("BillGetZdyMsg")
				ajax.addParam("Bill_Info_type", $ID("Bill_Info_type").value);
				ajax.addParam("bill_info_id",  $ID("Bill_Info_id").value);
				var s = Bill.cpZdyIDKey.split("|");
				for (var i = 0; i < s.length ; i++)
				{
					ajax.addParam(s[i], Bill.getInputByDBName(s[i]).value)
				}
				var data = ajax.send().split("\3\3");
				var r = data[0];
				if(r.indexOf("\1\1")>=0) {
					r = r.split("\1\1");
					for (var i = 1; i<=6 ;i++ )
					{
						var item = Bill.getInputByDBName("sys_cp_zdy" + i);
						if(item) { item.value = r[i-1]; }
					}
					item = Bill.getInputByDBName("sys_parent_remark");
					if(item) { item.value = r[6]; }
				}
				if (data.length>=2)
				{
					r = data[1];
					r = r.split("\2\2");
					for (var i = 0; i < r.length-1; i++)
					{
						var s = r[i].split("\1\1");
						var item = Bill.getInputByDBName(s[0]);
						if(item) { item.value = s[1]; }

					}
				}
				window.billzdyTimeout = 0;
			}, 50);
		}
		if (Bill.onRefreshDetail)
		{
			Bill.onRefreshDetail()
		}
    }
	,
    GroupHide: function (img) { //展开或收缩组
		span = img.parentNode;
        var dsp = "none";
        if (span.hidden == 0) {
            span.hidden = 1;
			img.src = "../../images/r_up.png";
        }
        else {
            span.hidden = 0;
            dsp = "inline";
			img.src = "../../images/r_down.png";
        }
        var tr = span.parentElement.parentElement;
        while (tr.nextSibling) {
            tr = tr.nextSibling;
            if (tr.cells[0].className == "billgrouptool") {
				billbodyResize();
                return;
            }
            tr.style.display = dsp;
			for (var i = 0; i<tr.cells.length ;i++ )
			{
				tr.cells[i].style.display = dsp;
			}
        }
		billbodyResize();
    }
	,
    showDateDlg: function (obj) {
        datedlg.show();
    }
	,
    showDateTimeDlg: function (obj) {
        datedlg.showDateTime();
    }
	,
	getTableCells : function(tb) {
		var rows = tb.rows;
		var cells = new Array();
		for (var i = 0; i < tb.rows.length ; i ++ )
		{
			for (var ii = 0 ; ii < tb.rows[i].cells.length ; ii++ )
			{
				cells[cells.length] = tb.rows[i].cells[ii];
			}
		}
		return cells;
	}
    ,
    SpTest: function (ckFieldName, uid) { //对审批人进行检测，是自己则不显示
        var mtb = document.getElementById("MainTable");
		var cells = this.getTableCells(mtb);
        for (var i = 0; i < cells.length; i++) {
            var td = cells[i]
            if (td.getAttribute("vTag") == ckFieldName) {
                var nexttd = td.nextSibling;
                if (nexttd) {
                    var selBox = nexttd.children[0]
                    if (selBox.tagName == "SELECT") {
                        if (selBox.options.length == 1 && selBox.value == uid) {
                            td.style.visibility = "hidden"
                            nexttd.style.visibility = "hidden"
                            var nexttd = nexttd.nextSibling
                            if (nexttd && nexttd.innerText.indexOf("选择单据对应的审核人") > 0) {
                                nexttd.innerHTML = "<span class=c_g>尊敬的用户，由于您目前具备审批权限，本次数据保存后默认由您自己审批通过。</span>"
                            }
                        }
                    }
                }
                break;
            }
        }
    }
	,
    NextCell: function (input) {  //根据当前输入框获取下一个输入框
        var td
        if (!input) { return false; }
        if (input.tagName == "SELECT") {
            td = input.parentElement;
        }
        else {
            td = input.parentElement.parentElement.parentElement.parentElement.parentElement;
        }
        var tr = td.parentElement;
        var tb = tr.parentElement.parentElement;
        while (td && (td.nextSibling || tr.nextSibling)) {
            td = td.nextSibling;
            if (!td) {
                tr = tr.nextSibling;
                td = tr.cells[1];
            }
            if (td) {
                if (td.children.length > 0) {
                    if (td.children[0].tagName == "TABLE") {
                        var cellBody = td.children[0].rows[0].cells[0];
                        if (cellBody.children.length > 0) {
                            return cellBody.children[0];
                        }
                    }
                    else {
                        if (td.children[0].tagName == "SELECT") {
                            return td.children[0];
                        }
                    }
                }
            }
        }
        return null;
    }
	,
	FocusNextCell : function(nextInput){
		try
		{
			 nextInput.focus();
			if (nextInput.tagName != "SELECT") {
				nextInput.select();
			}
		}
		catch (e)
		{
			nextInput = Bill.NextCell(nextInput);
			if(nextInput){
				Bill.FocusNextCell(nextInput);
			}
		}
	}
	,
    ItemKeyDown: function (input) { // 实现
		if(input.dType=="number"){
			if(!input.sBoxArray || input.sBoxArray.length==0){
				if(isNaN(input.value)==true){ 
					try{
						window.event.keyCode = 0;
						window.event.returnValue = 0;
					}catch(e){}
					return false;
				}
				input.oldvalue = input.value
				if(!input.onpropertychange){
					input.onpropertychange = function(){
						if(window.event.propertyName=="value" && input.valuelock!=1){
							var v  = input.title?input.title:input.value;
							input.valuelock = 1
							if(isNaN(v) || v.length == 0){
								if(v.length == 0)
								{
									setTimeout(function() {
										if(input.value.length > 0) {return;}
										input.value = 0;
										input.select();
									},50);
								}
								else
								{
									input.value = input.oldvalue;
								}
							}
							else{
								var vi = (v + "").split(".");
								if(vi.length>1)
								{
									if(vi[1].length>window.floatnumber)
									{
										v = vi[0] + "." + vi[1].substr(0,window.floatnumber);
										input.value = v;
									}
								}
							}
							input.oldvalue = input.value;
							input.valuelock = 0
						}
					}
				}
				
			}
		}
		
        if (window.event.keyCode == 39) {
            if (input.dType == 'date') {
                if (input.parentElement.nextSibling) {
                    try { input.parentElement.nextSibling.children[0].click(); } catch (e) { }
                }
            }
            return false;
        }
        if (window.event.keyCode == 13) {
            window.event.keyCode = 0;
            window.event.returnValue = false;
            var nextInput = Bill.NextCell(input);
            if (nextInput) {
				Bill.FocusNextCell(nextInput);
            }
            else {
                input.focus();
                if (input.tagName != "SELECT") {
                    input.select();
                }
            }
            if (input.RefreshChild == "1") {
                Bill.RefreshDetail(true); //在服务端写入onchange事件，所以此处重复执行，防止漏刷新
            }
        }
    }
	,
	ItemKeyUpDoSearch : function(sel) {
		sel.isKey = true;
        sel.click();  //触发查询功能
        sel.isKey = false;
	} 
	,
    ItemKeyUp: function (obj) { //实现自动下拉
        switch (window.event.keyCode) {
            case 13: //回车 , 移动到下一个
                return false;
            case 40:  //移动到下一行
                return false;
                break;
            case 38:  //移动到上一行
                return false;
                break;
            default:
                if (obj.value.indexOf("#oc") >= 0) { obj.value = obj.value.replace("#oc", ""); return false }  //置换特殊分隔符号
                if (obj.value.indexOf("#or") >= 0) { obj.value = obj.value.replace("#or", ""); return false }
                if (obj.value.indexOf("#ot") >= 0) { obj.value = obj.value.replace("#ot", ""); return false }
                break;
        }
		//binary.2014.07.18.增加延时，优化性能
        var sel = obj.parentElement.nextSibling.children[0];
        if (sel) {
			if(window.ItemKeyUpHwnd>0) {
				window.clearTimeout(window.ItemKeyUpHwnd);
				window.ItemKeyUpHwnd = 0;
			}
			window.ItemKeyUpHwnd = window.setTimeout(function() { Bill.ItemKeyUpDoSearch(sel); }, 300);
        }
    }
	,
	showTreeBoxDlg: function(selId , selType , defvalue ,objname) {
		window.open("treeSelect.asp?selId="+selId+"&selType="+selType+"&defvalue="+defvalue +"&objname="+objname,"newwin","width=200,height=500,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100");
	}
	,
    spMsgTest: function () { // 审批人检测
        var selBoxs = document.getElementsByTagName("select")
        for (var i = 0; i < selBoxs.length; i++) {
            if (selBoxs[i].tag == "splist") {
                if (selBoxs[i].value.length == 0) {
					Bill.showFieldAlert(selBoxs[i].name.replace("MT",""),"请选择审批人")
					try{
						selBoxs[i].focus();
                    }catch(e){}
					//return false;
                }
            }
        }
        return true;
    }
	,
    spButtonStatus: function (creator) {
        //binary.此处代码已经删除，判断挪到billpage.asp中去了，见getCanSpUpdate函数
	}
	,
    IsReadOnly: function (isRead, canAdd) {  //根据只读状态，设置相关命令按钮的禁用状态
        var cssStyle = isRead ? "disbillcmdButton" : "billcmdButton";

		if(document.getElementById("bcButton2")){document.getElementById("bcButton2").className = cssStyle;}
		if(document.getElementById("bcButton3")){document.getElementById("bcButton3").className = cssStyle;}
		if(document.getElementById("bcButton4")){document.getElementById("bcButton4").className = cssStyle;}
		if(document.getElementById("bcButton2")){document.getElementById("bcButton2").disabled = isRead;}
		if(document.getElementById("bcButton3")){document.getElementById("bcButton3").disabled = isRead;}
		if(document.getElementById("bcButton4")){document.getElementById("bcButton4").disabled = isRead;}
        var ftd = document.getElementById("refreshdetailtd")
        if (ftd) { ftd.style.display = isRead ? "none" : "" } //没有明细的时候refreshdetailtd元素不存在
        var spckbox = document.getElementById("spselbox");
        var mSpan = document.getElementById("topmsg")
        if (spckbox) {
            spckbox.disabled = isRead;
            document.getElementById("spselboxlabel").disabled = isRead;
        }
        if (mSpan) {
            if (isRead) { mSpan.innerHTML = "<b style='color:red'>您目前没有编辑的权限，数据只读。</b>&nbsp;&nbsp;" }
            else { mSpan.innerHTML = "" }
        }
        cssStyle = canAdd ? "billcmdButton" : "disbillcmdButton";
		if(document.getElementById("bcButton1")){
			document.getElementById("bcButton1").className = cssStyle;
			document.getElementById("bcButton1").disabled = !canAdd;
		}
    }
	,
    showRulesConfig: function () {
        var div = window.DivOpen("sphand", "审批处理", 540, 300, 'a', 'a', true, 18)
        div.innerHTML = "<ol style='margin:20px;margin-left:40px;line-height:22px;color:#006600'>"
                        + "<li>用Field[*]表示主表字段, 如 Field[1] 或者 Field[\"Creator\"]"
                        + "<li>用Tab[*].Col[*]表示第*个明细栏的第*列 , 如Tab[0].Col[0]"
                        + "<li>用表达式的返回值为true表示符合条件,如：Field[1]>Field[2]"
                        + "<li>多组条件用分号隔开；如Field[1]>Fields[2];Field[3]*Field[4]>Fields[5]"
                        + "</ol>"
    }
	, ShowSpdlg: function () { // 显示审批对话框
	    var ax = new xmlHttp()
	    ax.url = "check.asp";
			var spHeight=400;
			var spWidth=640;
			if (Bill.OrderId==1034){spHeight=500;spWidth=640;}
	    var div = window.DivOpen("sphand", "审批处理", spWidth, spHeight, 'a', 'a', true, 18)
	    ax.regEvent("CreateSpDailog"); //创建对话框
	    ax.addParam("orderid", Bill.OrderId);
	    ax.addParam("billid", document.getElementById("Bill_Info_id").value);
	    ax.addParam("spid", document.getElementById("Bill_Info_curridsp").value);
	    //ax.addParam("spid",spid);
	    ax.addParam("logId", document.getElementById("Bill_Info_SplogId").value);
	    div.innerHTML = ax.send();
	    lvw.UpdateAllScroll();


	   	var spResults = document.getElementsByName("spResult");
		var spResult = 0;
		for (var i=0;i< spResults.length; i++ )
		{
			if(spResults[i].checked){
				spResult = spResults[i].value;
				break;
			}
		}
		ck.spResultChange(spResult,document.getElementById("Bill_Info_creator").value);  //默认审批状态
	}
	,
	iframesSave : function(button){
		var frms = document.getElementsByTagName("iframe")
		for (var i = 0 ; i < frms.length ; i ++)
		{
			var cwindow = frms[i].contentWindow;
			if(cwindow.location.href.toLowerCase().indexOf("treeedit.asp")>0){
			
				if(cwindow.Bill.cmdButtonClick){
					cwindow.Bill.cmdButtonClick(button,"noalert")
					if(cwindow.BillCmdSuccess*1==0){
						return false;
					} 
				}
			}
		}
		return true;
	}
	,
	createAlertText: function(textbox, alertmsg) {
		var alertRow = null
		if(textbox && textbox.tagName != "INPUT"){
			if(textbox.tagName=="SELECT" || textbox.tagName=="TEXTAREA"){
				var td = textbox.parentElement;
				var txts = td.getElementsByTagName("span")
				for (var i=0;i<txts.length ;i++ )
				{	
					if(txts[i].name == "BillalertText"){
						txts[i].innerText = " " + alertmsg;
						return false
					}
				}
				var txt = document.createElement("span")
				txt.setAttribute("name","BillalertText")
				txt.className = "c_red";
				td.appendChild(txt);
				txt.innerText = " " + alertmsg;
			}
			return false
		}
		if(textbox && textbox.parentElement.tagName=="TD"){
			alertRow = textbox.parentElement.parentElement
			if(alertRow.cells[alertRow.cells.length-1].name != "BillalertText"){
				var newtd = document.createElement("td")
				newtd.setAttribute("name","BillalertText")
				newtd.style.cssText = "color:red"
				alertRow.appendChild(newtd);
			}
			else{
				var newtd = alertRow.cells[alertRow.cells.length-1];
			}
			newtd.innerText = " " + alertmsg
		}
	} 
	,
	showFieldAlert : function(fIndex, alertmsg, ywname){
		//BUG.3283.binary.2013.12.28.该函数逻辑有点问题，已经改写。
		var textbox = document.getElementsByName("MT" + fIndex)[0];			//存在无效值的表单元素
		var ywname = (!ywname ? textbox.getAttribute("ywname") : ywname);
		var hs = false;
		if(!textbox) { alert((window.currallywname ? "【" + window.currallywname + "】" : "") + alertmsg); return; }
		if(textbox.className=="editorArea") 
		{
			document.getElementById("fms_" + textbox.getAttribute("dbname")).innerHTML = alertmsg;
			return;
		}
		if(textbox.className=="billreadonlytext") { return; }
		try{
			if(textbox.type=="hidden") {
				var boxCell = textbox.parentNode;
				if( boxCell.tagName=="TD") {
					if(boxCell.className.indexOf("billfield")==0) {
						//类似单选按钮的隐藏值，当前单元格提示
						Bill.createAlertText(textbox, alertmsg);
						return;
					}
					else {
						if (boxCell.id=="BillMainInfo" || window.ControlVisible(textbox) == false )
						{
							//对于非单选按钮隐藏值，提示前一个单元格
							if(!window.currallywname)
							{ 
								//由于存在递归调用，当递归到尽头时，通过currallywname获取错误的递归源。
								window.currallywname = ywname;
								hs = true;
							}

							Bill.showFieldAlert(fIndex-1, alertmsg, null);  //递归调用

							if(hs==true) {
								window.currallywname = null;
							}
							return;
						}
					}
				}
			}
			Bill.createAlertText(textbox, alertmsg);
		}
		catch(e){ alert(e.message); }
	}
	,
	clearfieldalert : function() { //清除字段的提示
		var tds = document.getElementsByTagName("td");
		for (var i = 0; i < tds.length ; i++ )
		{
			if(tds[i].getAttribute("name")=="BillalertText"){
				tds[i].innerText = "";
			}
		}
		var tds = document.getElementsByTagName("span");
		for (var i = 0; i < tds.length ; i++ )
		{
			if(tds[i].getAttribute("name")=="BillalertText"){
				tds[i].innerText = "";
			}
		}
		var tboxs = document.getElementsByTagName("textarea")
		for (var i = 0 ; i < tboxs.length ; i++ )
		{
			if(tboxs[i].style.color=="red" && tboxs[i].value=="该项必填。" && tboxs[i].dbname ){
				tboxs[i].value = ""
			}
		}
	}
	,
	FocusField : function(fIndex){
		try{
		var textbox = document.getElementsByName("MT" + fIndex)[0]
		if(textbox){
			textbox.focus();
			textbox.select();
		}}catch(e){}
	}
	,
    cmdButtonClick: function (button,tag) { //命令按钮
		if(window.oncmdButtonClick) {
			if(window.oncmdButtonClick(button, tag)==true) {
				return;
			}
		}
		Bill.clearfieldalert()
        var cmd = button.innerText.replace(/\s/g, "");
		if(cmd == "打印"){
			if(window.location.href.toLowerCase().indexOf("readbill.asp")>0){
				var t = new Date()
				t = t.getTime().toString().replace(".","")
				if(window.showModalDialog){
					window.showModalDialog("../../manufacture/inc/printer.asp?oid=" + Bill.OrderId  + "&t=" + t,{win:window,typ:"bill"},"dialogHeight:" + (screen.availHeight-80) + "px;dialogWidth:" + (screen.availWidth-80) + "px;center:1;status:0;resizable:1");
				} else {
					window.showModalDialogPrintObj = {win:window,typ:"bill"};
					window.open("../../manufacture/inc/printer.asp?wopenmodel=1&oid=" + Bill.OrderId  + "&t=" + t, "manuprint" ,"height=" + (screen.availHeight-80) + "px,width=" + (screen.availWidth-80) + "px,center=1,status=0,resizable=1");
				}
			} else {
				window.focus();
				window.print();
			}
			return;
		}
		if(cmd == "模板打印"){
			if(window.location.href.toLowerCase().indexOf("readbill.asp")>0){
				var sortID = 0; 
				switch(Bill.OrderId)
				{
					case '2' : sortID = 30;break;
					case '8' : sortID = 31;break;
					case '12' : sortID = 32;break;
					case '13' : sortID = 33;break;
					case '17' : sortID = 34;break;
				}
				window.showModalDialogPrintObj = {win:window,typ:"bill"};
				window.open("../../../SYSN/view/comm/TemplatePreview.ashx?sort="+ sortID +"&ord=" + document.getElementById("Bill_Info_id").value, "manuprint" ,"height=" + (screen.availHeight-80) + "px,width=" + (screen.availWidth-80) + "px,center=1,status=0,resizable=1");
			} else {
				window.focus();
				window.print();
			}
			return;
		}
		if(cmd == "导出"){
			window.PageOpen("../../manufacture/inc/billoutExcel.asp?oid=" + Bill.OrderId + "&bid=" + document.getElementById("Bill_Info_id").value,300,100,"cdxcel")
			return;
		}

		if(cmd == "变更"){
			window.location.href = "bill.asp?changeModel=1&orderid=" + Bill.OrderId + "&id=" + document.getElementById("Bill_Info_id").value
			return;
		}

		if(cmd=='导入'){
			if (!window.importHandler){
				alert('未能找到导入处理程序，请检查单据的js文件是否定义importHandler');
				return;
			}
			window.importHandler(Bill.OrderId,document.getElementById("Bill_Info_id").value);
			return;
		}
		if(cmd=="新建") {
			cmd = "保存"
			tag = "noalert"
		}
        if (cmd == "审批" || cmd == "改批")
        { Bill.ShowSpdlg(); return; }
        if (cmd == "删除" && !window.confirm("确定要删除吗？")) { return false }
        ajax.regEvent("CommandHand");
        ajax.addParam("CommandName", cmd);
        ajax.addParam("OrderId", Bill.OrderId);
        ajax.addParam("ParentID", Bill.ParentID);
		ajax.addParam("ParentTag",Bill.queryItem_ParentTag);
        if(tag){
			ajax.addParam("tag",tag)
		}
		ajax.addParamsById("Bill_Info_div")
		
        if (cmd == "暂存" || cmd == "保存") {  //暂存定义  TempSave = 1 表示暂存
			if(Bill.iframesSave(button)==false){return;}
            if (!Bill.spMsgTest()) { return false }
			if(Bill.onsave){
				Bill.onsave()
			}
            ajax.addParam("DetailData", lvw.GetSaveDetailData());
			ajax.addParam("ChangeModel", document.getElementById("Bill_Info_ChangeModel").value);
        }
        var inputs = document.getElementsByTagName("INPUT")
		var hasalert = 0 //是否出现提示信息
        for (var i = 0; i < inputs.length; i++) {
            if (inputs[i].name.indexOf("MT") == 0) {
				var v =  inputs[i].title.length > 0 ? inputs[i].title : inputs[i].value
                if(v.length==0){
					if(inputs[i].notnull=="True" || inputs[i].notnull=="true"){
						var lb = window.getParent(inputs[i],5).previousSibling;
						if(lb.className=="billfieldleft"){
							if(inputs[i].tagName == "INPUT"){
								if(hasalert==0){hasalert = inputs[i].name.replace("MT","");}
								Bill.showFieldAlert(inputs[i].name.replace("MT",""),"该项必填。")
								try{
									inputs[i].focus();
									inputs[i].select();
								}
								catch(e){}
							}
						}
					}
				}
				ajax.addParam(inputs[i].name,v)
				ajax.addParam(inputs[i].name + "_db", inputs[i].getAttribute("dbname"))
            }
        }
		
        var inputs = document.getElementsByTagName("SELECT")
        for (var i = 0; i < inputs.length; i++) {
            if (inputs[i].name.indexOf("MT") == 0) {
                ajax.addParam(inputs[i].name, inputs[i].value)
				ajax.addParam(inputs[i].name + "_db", inputs[i].dbname)
            }
        }

        var inputs = document.getElementsByTagName("TEXTAREA")
        for (var i = 0; i < inputs.length; i++) {
            if (inputs[i].name.indexOf("MT") == 0) {
				if(document.getElementById("fms_" + inputs[i].getAttribute("dbname")) ) {
					document.getElementById("fms_" + inputs[i].getAttribute("dbname")).innerHTML = "";
				}
                var webEditId = "eWebEditor_" + inputs[i].name;
                var wFrame = document.getElementById(webEditId);
                if (wFrame) {
                    var html = wFrame.contentWindow.getHtmlValue();
                    html = html == "<br>" ? "" : html;//编辑器默认有一个<br>标签，如果进行非空验证需要过滤掉
                    ajax.addParam(inputs[i].name, Bill.KeyCharConvert(html))
					ajax.addParam(inputs[i].name + "_db", inputs[i].dbname)
                }
                else {
					var html = inputs[i].value;
                    ajax.addParam(inputs[i].name, Bill.KeyCharConvert(inputs[i].value))
					ajax.addParam(inputs[i].name + "_db", inputs[i].dbname)
                }
				if( inputs[i].getAttribute("dbname").indexOf("{us") == 0 )
				{
					if(html.length>2000)
					{
						var ywname =  inputs[i].getAttribute("ywname");
						if(!window.confirm("扩展字段【" + ywname + "】的内容字数超过了2000，您是否允许系统将截断该字段的值然后保存。\n\n允许继续保存点击确认，否则点击取消。"))
						{
							return false;
						}
					}
				}
				if( inputs[i].getAttribute("notnull")=="1"  && inputs[i].value.replace(/\s/g,"").replace(/\n/g,"")==""){
						if(hasalert==0){hasalert = inputs[i].name.replace("MT","");}
				    //Bill.showFieldAlert(inputs[i].name.replace("MT",""),"该项必填。") //添加此句文本域则会提示两遍，下方的ajax.exec()也会给予提示
						try{
							inputs[i].focus();
							inputs[i].select();
						}
						catch(e){}
				}
            }
        }
		ajax.addParam("hasalert",hasalert);
		window.BillCmdSuccess = 0
        ajax.exec()
		if (window.BillCmdSuccess == 1 && button.innerText.replace(/\s/g, "")=="新建")
		{
			var urls = window.location.href.split("?")
			if(urls.length==0){
				window.location.href = "bill.asp?orderid=" + Bill.OrderId
				return
			}
			else{
				var newurl = new Array()
				var parms = urls[1].split("&")
				for (var i= 0; i < parms.length ; i++ )
				{
					if(parms[i].toLowerCase().indexOf("id=")!=0){
						newurl[newurl.length] = parms[i]
					}
				}
			}
			window.location.href = "bill.asp?" +  newurl.join("&")
		}
		if(Bill.AfterCommand){
			Bill.AfterCommand(cmd)
		}
		if( isNaN(Bill.OrderId) == false && (Bill.OrderId+"").length > 0) {
			if (Bill.hasList>0){
				var disArray = [5,6,30];
				if (window.BillCmdSuccess == 1 && button.innerText.replace(/\s/g, "")=="保存" && window.ArrayExists(disArray,Bill.OrderId)==false)
				{
					try{
						if(window.opener && window!=window.opener && !window.opener.opener && window.opener.location.href.indexOf("childhome.asp")==0){
							window.opener.location.href = "billlist.asp?orderid=" + Bill.OrderId + "&newaddKey=" + document.getElementById("Bill_Info_id").value
							window.opener = null;
							window.open('','_self'); //IE7,8不弹出提示框
							window.close();
						}
						else{
							if(window.opener && window!=window.opener && window.opener.location.href.indexOf("content.asp")>0) {
								window.opener.location.reload();
							}
							window.location.href = "billlist.asp?orderid=" + Bill.OrderId + "&newaddKey=" + document.getElementById("Bill_Info_id").value
						}
					}catch(e){}
				}
			}
			else{
				if(window.BillCmdSuccess == 1){
					window.location.href = "readbill.asp?orderid=" + Bill.OrderId + "&id=" + document.getElementById("Bill_Info_id").value;
				}
			}
		}
    }
	,
	mainFieldSelect : function(dbname) {  //根据dbname选择字段
		var srcElems = document.getElementByTagName("input");
		for (var i=0; i<srcElems.length; i++)
		{
			if(srcElems[i].getAttribute("dbname")==dbname){
				try{
					document.all[i].focus();
					document.all[i].select();
				}catch(e){}
			}
		}

		srcElems = document.getElementByTagName("SELECT");
		for (var i=0; i<srcElems.length; i++)
		{
			if(srcElems[i].getAttribute("dbname")==dbname){
				try{
					document.all[i].focus();
					document.all[i].select();
				}catch(e){}
			}
		}
	}
	,
    KeyCharConvert: function (v) {
        v = v.replace(/\+/g, '#-add');
        //v = v.replace(/\=/g,'#-dyh');
        //v = v.replace(/\?/g,'#-wfh');
        //v = v.replace(/\//g,"#-yxh");
        return v
    }
	,
    autoTextAreaHeight: function () { //自动调整textarea高度
        var tBoxs = document.getElementsByTagName("textarea")
        for (var i = 0; i < tBoxs.length; i++) {
            if (tBoxs[i].name.indexOf("MT") == 0) {
                if (!tBoxs[i].defHeight) { tBoxs[i].defHeight = tBoxs[i].parentElement.offsetHeight; }
				if(window.ActiveXObject) {
					tBoxs[i].onpropertychange = function () {
						var nHeight = this.scrollHeight > 140 ? 140 : this.scrollHeight;
						nHeight = this.defHeight > nHeight ? this.defHeight : nHeight;
						if(nHeight<40) { nHeight = 40;}
						this.style.height = nHeight + "px";
					}
				} else {
					tBoxs[i].oninput = function () {
						var nHeight = this.scrollHeight > 140 ? 140 : this.scrollHeight;
						nHeight = this.defHeight > nHeight ? this.defHeight : nHeight;
						if(nHeight<40) { nHeight = 40;}
						this.style.height = nHeight + "px";
					}
				}
                tBoxs[i].onfocus = function () {
                    var nHeight = this.scrollHeight > 140 ? 140 : this.scrollHeight;
                    nHeight = this.defHeight > nHeight ? this.defHeight : nHeight;
					if(nHeight<40) { nHeight = 40;}
                    this.style.height = nHeight + "px";
                }
                var nHeight = tBoxs[i].scrollHeight > 140 ? 140 : tBoxs[i].scrollHeight;
                nHeight = tBoxs[i].defHeight > nHeight ? tBoxs[i].defHeight : nHeight;
				if(nHeight<40) { nHeight = 40;}
                tBoxs[i].style.height = nHeight + "px";
            }
        }
    }
	,
	setAutoFieldList : function(input,cells){
		
		var refresh = 0
		if (cells[0] != "$0x-null") {
			if(cells[0] == "$0x-space")
			{input.value = "";}
			else
			{input.value =cells[0];}
			if(input.onchange){input.fireEvent("onchange");} //触发onchange事件
			//refresh = refresh + (input.RefreshChild == "1" ? 1 : 0)
		}
		if(!input) {return false}
		for (var i = 1; i < cells.length; i++) {
			if (input) {
				var newindex = input.name.replace("MT","")
				input = document.getElementsByName("MT" + (newindex*1+1))[0]
				if (cells[i] != "$0x-null") {
					if(cells[i] == "$0x-space"){input.value = ""; }
					else{input.value = cells[i];} 
				}
				if(input.onchange){input.fireEvent("onchange");}
				//refresh = refresh + (input.RefreshChild == "1" ? 1 : 0)
			}
		}
		if (input) {
			var newindex = input.name.replace("MT","");
			input = document.getElementsByName("MT" + (newindex*1+1))[0];
			if(input){
				window.autofocusText = input;
				window.setTimeout("try{window.autofocusText.focus();window.autofocusText.select();}catch(e){}",100);
			}
		}
		//if(refresh>0){
		//	Bill.RefreshDetail(1);
		//}
	}
	,
    mFieldSelReturn: function (tb, td, rows) { //主字段获取对话框选择的大量数据
		var cells = rows[0]
		if (!cells) { return false }
		var input = td.children[0].rows[0].cells[0].children[0];
		Bill.setAutoFieldList(input,cells);
    }
	,
    ListSelDataConvert: function (tr, dat, sIndex) {  //将包含selectbox模式的数据转换出来
        if (dat.length == 0) { return dat }
        var col = dat[0].length
        var heads = tr.parentElement.rows[0].cells
        for (var i = sIndex; i < col * 1 + sIndex * 1; i++) {
            var HCell = heads[i]
            if (HCell && HCell.sboxArray && HCell.sboxArray.length > 0) {
                for (var ii = 0; ii < dat.length; ii++) {
					if (!dat[ii][i - sIndex] && dat[ii][i - sIndex]!== "$0x-null")
					{
						var r = lvw.getCellselBoxValue(tr.cells[i], dat[ii][i - sIndex])
						dat[ii][i - sIndex] = r.name + lvw.sBoxSpr + r.value
					}
                    
                }
            }
        }
        return dat;
    }
	,
    ListSelReturn: function (tb, td, rows) { //明细表获取对话框选择的大量数据
		if(tb.getAttribute("forList") && tb.getAttribute("forList").length>0){ //整体录入情况
			var tbox = td.children[0].rows[0].cells[0].children[0]
			row = rows[0]
			var vs = row[0].split("^tag~");
			if(vs.length>1){
				tbox.value = vs[0];
				tbox.title = vs[1];
			}
			else{
				tbox.value = row[0];
			}
			if(row.length>1){
				tbox.JoinList = row;
			}
			return
		}
        var tr = td.parentElement;
        var div = tb.parentElement;
        var sIndex = lvw.getDataCellIndexByTD(td);
        rows = Bill.ListSelDataConvert(tr, rows, sIndex)
        lvw.updateDataRow(tr, rows[0], sIndex)
        if (tb.canadd != "0") {
			for (var i = 1; i < rows.length; i++)
            {
					lvw.addDataRow(div, rows[i], sIndex-2) 
			}
        }
		
        lvw.Refresh(div);
    }
	,
    AddBill: function (id , postType) { //根据树节点选择重新加载单据信息
        if(!window.ActiveXObject) {
			//非IE模式考虑到兼容性，直接跳转加载
			window.location.href = window.location.href.split("?")[0] + "?OrderId=" +  Bill.OrderId + "&ID=" + id + "&ParentID=" + Bill.ParentId
				+ "&PowerReadOnly=" + document.getElementById("Bill_Info_readonly").value + "&readmode=" + document.getElementById("Bill_Info_readbillmode").value;
			return;
		}
		ajax.regEvent("");
        ajax.addParam("OrderId", Bill.OrderId);
        ajax.addParam("ID", id);
        ajax.addParam("ParentID", Bill.ParentID);
		try{
			ajax.addParam("PowerReadOnly",document.getElementById("Bill_Info_readonly").value); //只读状态
			ajax.addParam("readmode",document.getElementById("Bill_Info_readbillmode").value);  //是否通过billRead调用
        }catch(e){}
		if (!postType)	//模式用异步，粘贴时需要用同步
		{
			ajax.send(Bill.OnAddBillHandle);
		}
		else{
			Bill.OnAddBillHandle(ajax.send());
		}
		
	}
	,
	OnAddBillHandle : function(r){
		var JScript  = ""
		var sIndex = r.indexOf("<script callback=1 language=javascript>")
		var eIndex = 0
		var signLen = "<script callback=1 language=javascript>".length;
		if (sIndex>0)
		{  
			var c = r.substr(sIndex);
			eIndex = c.indexOf("</script>")
			JScript = c.substring(signLen, eIndex);
		}
        sIndex = r.indexOf("<!--单据编辑区域开始-->")
        eIndex = r.indexOf("<!--单据编辑区域结束-->")
        if (sIndex < 0 || eIndex < 0) {
            var div = window.DivOpen("billgeterr", "获取数据失败", 600, 400);
            var mdiv = document.createElement("div")
            mdiv.innerHTML = r;
            div.innerHTML = "<span class=c_r style='margin:4px'>" + mdiv.innerText.replace(/。/g, "<br>").replace(/\n/g, "<br>") + "</span>";
            return false;
        }
		
		sIndex1 = r.indexOf("<!--单据顶部区域开始-->")
        eIndex1 = r.indexOf("<!--单据顶部区域结束-->")
		signLen1 = "<!--单据顶部区域结束-->".length;
		if(eIndex1>0 && sIndex1>0) {
			tophtml = r.substring(sIndex1 + signLen1, eIndex1);
			document.getElementById("billtopbardiv").innerHTML = tophtml;
		}

        signLen = "<!--单据编辑区域结束-->".length;
        r = r.substring(sIndex + signLen, eIndex)
        var cPan = document.getElementById("BillMainInfo");
        cPan.innerHTML = r;
        var script = cPan.getElementsByTagName("script")
        for (var i = 0; i < script.length; i++) {
            eval("(function(){" + script[i].innerHTML + "})()");
        }
		if (JScript.length>0)
		{
			eval("(function(){" + JScript + "})()");
		}
        lvw.UpdateAllScroll();
        window.BillSpManTest();
		Bill.autoFrameHeight();
    }
	,
    setDefCheckMan: function (checkbox) { //设置默认审批人
        var selBox = checkbox.parentElement.previousSibling.children[0];
        var selhand = checkbox.checked ? 1 : 0;
        var selMan = selBox.value;
        if (selMan.length == 0) {
            alert("您还没有选择审批人。");
            checkbox.checked = !checkbox.checked;
            return;
        }
        ajax.regEvent("SetDefCheckMan")
        ajax.addParam("spMan", selMan); 											 //审批人
        ajax.addParam("bSign", document.getElementById("Bill_Info_sign").value); 	 //单据类型
        ajax.addParam("bSpId", document.getElementById("Bill_Info_nextspid").value);  //审批级别
        ajax.addParam("defType", selhand);
        ajax.exec()
    }
	,
    toSpPageBySpType: function (index) {  //跳转到审批界面
        ajax.regEvent("");
        ajax.addParam("sType", index)
        r = ajax.send()
        var sIndex = r.indexOf("<!--审批主表格-->")
        var eIndex = r.indexOf("<!--主表格结束-->")
        if (eIndex < 0 || sIndex < 0) {

            var div = window.DivOpen("spgeterr", "获取数据失败", 500, 320, 50, 120);
            var mdiv = document.createElement("div")
            mdiv.innerHTML = r;
            div.innerHTML = "<span class=c_r style='margin:4px'>" + mdiv.innerText.replace(/。/g, "<br>").replace(/\n/g, "<br>") + "</span>";
            return false;
        }
        var signLen = "<!--主表格结束-->".length;
        r = r.substring(sIndex + signLen, eIndex)
        var cPan = document.getElementById("billbody")
        cPan.innerHTML = r;
        var script = cPan.getElementsByTagName("script")
        for (var i = 0; i < script.length; i++) {
			window.eval("(function(){" + script[i].innerHTML + "})()");
        }
        lvw.UpdateAllScroll();
    }
	,
	NumEnCode : function(theNumber) //产品编号编码  
	{
		if(!theNumber){theNumber = ""}
		if(theNumber == ""){ theNumber = 0}
		var n_url, szEnc_url, t_url, HiN_url, LoN_url, i_url,szEnc;
		n_url =( (theNumber*1 + 1772570)*(theNumber*1 + 1772570) - 7 * (theNumber*1 + 1772570) - 450)*1.0;
		szEnc =  n_url*1 < 0  ? "R" :"A" ;
		n_url = Math.abs(n_url) + ''
		for(i_url = 1 ; i_url <=n_url.length ;i_url=i_url*1 +  2){
		  t_url = n_url.substr(i_url-1, 2)
		  if(t_url.length == 1){
			   szEnc = szEnc + t_url
			   break;
		  }
		  else{
			  HiN_url = ((t_url)*1 & 240) / 16
			  LoN_url = (t_url)*1 & 15
			  szEnc = szEnc + String.fromCharCode(("M").charCodeAt(0) + HiN_url) + String.fromCharCode(("C").charCodeAt(0) + LoN_url) + "%D6%C7%B0%EE"
		  }
		}
		return szEnc
	}
	,
    ShowReplaceOrder: function () {
        var a, b
        var div = window.DivOpen("orDiv", "单据参数<span class=c_r>一般</span>替换规则", 550, 300, a, b, true, 26)
        div.innerHTML = "<ol style='line-height:20px'>"
						+ "<li><span class='RplOrderAttr'>@bill_ID:</span><span class=c_c>当前单号</span></li>"
						+ "<li><span class='RplOrderAttr'>@bill_ParentID:</span><span class=c_c>当前上级单号</span></li>"
						+ "<li><span class='RplOrderAttr'>@uid:</span><span class=c_c>当前用户编号</span></li>"
						+ "<li><span class='RplOrderAttr'>@uname:</span><span class=c_c>当前用户姓名</span></li>"
						+ "<li><span class='RplOrderAttr'>@*:</span><span class=c_c>获取主表中*字段的值,如:@creator</span></li>"
						+ "<li><span class='RplOrderAttr'>@cell[*]:</span><span class=c_c>获取子表界面显示的第*列的值</span></li>"
						+ "<li><span class='RplOrderAttr'>@asp.eval[*]:</span><span class=c_c>将*当做ASP代码执行，获取其返回值，等同VBS中的Eavl函数</span></li>"
						+ "<li><span class='RplOrderAttr'>@asp.form[*]:</span><span class=c_c>获取Request.Form(*)的值</span></li>"
						+ "<li><span class='RplOrderAttr'>@asp.querystring[*]:</span><span class=c_c>获取Request.QueryString(*)的值</span></li>"
						+ "<li><span class='RplOrderAttr'>$*1[*2]:</span><span class=c_c>*1表示SQL函数名，*2表示当前作用表的字段，如$Max(ID)</li>"
						+ "</ol>&nbsp;&nbsp;&nbsp;&nbsp;<span class=c_g>说明:并非所有参数都支持其中的所有替换。</span>"
    }
	,
    EditSplitText: function (obj, heads, Spliter) { //编辑分隔字符
        if (!Spliter) {
            Spliter = "|$;".split("$")
        }
        var td = obj
        var box = null;
        while (td.tagName != "TD" && td) {
            td = td.parentElement;
            if (td.tagName == "TD") {
                if (td.children[0].tagName == "TEXTAREA" || (td.children[0].tagName == "INPUT" && td.children[0].type == "text")) {
                    box = td.children[0];
                    break;
                }
                else {
                    if (td.previousSibling) {
                        var pTd = td.previousSibling;
                        if (pTd.children[0].tagName == "TEXTAREA" || (pTd.children[0].tagName == "INPUT" && td.children[0].type == "text")) {
                            box = pTd.children[0];
                            break;
                        }
                    }
                }
                td = td.parentElement;
            }
        }
        if (!box) { alert("没有找到内容编辑容器"); }
        var id = box.name.length > 0 ? box.name : box.id;
        var w = parseInt(heads.length * 18.5)
        var div = window.DivOpen(id, "数据编辑", w > screen.availWidth ? screen.availWidth : w, 420, 'a', 'b', true, 18)
        if (div.isOpen) { return false; }
        if (heads.length == 0) {
            div.innerHTML = "没有定义数据项含义。"
            return;
        }
        ajax.regEvent("GetListViewByArray")
        ajax.addParam("heads", heads)
        ajax.addParam("state", "smp_edit")
        ajax.addParam("listviewid", "arrlist" + id )
        r = ajax.send();
        div.innerHTML = r
        div.children[0].style.border = "0px"
        var lw = document.getElementById("listview_arrlist" + id)
        var boxv = box.value;
        if (Spliter[1] == ";") { boxv = boxv.replace(/\,/g, ";") }
        var rows = boxv.split(Spliter[0])
        for (var i = 0; i < rows.length; i++)
        { lvw.addDataRow(lw, rows[i].split(Spliter[1])) }
        lw.PageSize = 10
        lvw.Refresh(lw);
        lvw.UpdateScrollBar(lw)
		lvw.Refresh(lw);
        //lw.id = "splitlist_" + id
        lw.parentElement.style.textAlign = "center";
        lw.disSave = false
        lw.style.width = "99%";
        var win = div.parentElement.parentElement.parentElement.parentElement.parentElement;
        win.onclose = function () {
            r = lvw.GetSaveDetailData(lw);
            r = r.replace(/\#or/g, Spliter[0])
            r = r.replace(/\#oc/g, Spliter[1])
            box.value = r
        }
        //lw.onkeyup = function() {
        //	r = lvw.GetSaveDetailData(lw);
        //	r = r.replace(/\#or/g,Spliter[0])
        //	r = r.replace(/\#oc/g,Spliter[1])
        //	box.value = r
        //}
    }
	,
    UIFixCell: function (o) { //固定表头
		return false ; //存在问题，暂时禁用
        if (!o.oLeft) { o.oLeft = 0; }
        var oLeft = o.oLeft;
        var left = o.scrollLeft;
        if (oLeft - left == 0) { return; }
        else { o.oLeft = left }
        var rPos = left > 0 ? "relative" : "static"
        var LeftFix = 1
        if (!o.Table) {
            var lFrame = o.children[0];
            o.Table = lFrame.rows[1].cells[0].children[0].children[0]
            if (o.Table.LeftFixCount) {
                LeftFix = o.Table.LeftFixCount;
            }
        }
        for (var i = 0; i < LeftFix; i++) {
            for (var ii = 0; ii < o.Table.rows.length; ii++) {
                o.Table.rows[ii].cells[i].style.position = rPos;
                o.Table.rows[ii].cells[i].style.left = (left - 2) + "px";
            }
        }
    }
	,
    SpliterBarEvent: function (bar, eType) {
        var id
        switch (eType) {
            case 1: //mouseover
                bar.style.backgroundPositionX = bar.oldWidth == 0 ? -40 : -60;
                break;
            case 0: //mouseout
                bar.style.backgroundPositionX = bar.oldWidth == 0 ? 0 : -20;
                break;
            case 2: //click
                id = document.getElementById("LeftTreeArea")
                if (id.style.display != "none") {
                    bar.oldWidth = id.offsetWidth;
                    id.style.display = "none"
					bar.style.backgroundImage = "url(../../skin/default/images/btn_right.gif)";
                }
                else {
                    bar.oldWidth = 0;
                    id.style.display = ""
					bar.style.backgroundImage = "url(../../skin/default/images/btn_left.gif)";
                }
				window.event.cancelBubble = true;
                break;
            case 3: // resize-down
				if (bar.dm=="1")
				{return false}
                id = document.getElementById("LeftTreeArea");
                if (id.style.display == "none") { return false; }
                bar.mving = true;
                bar.currWidth = id.offsetWidth;
                bar.currX = window.event.x;
                bar.setCapture(false);
                break;
            case 4: // resize-move
				if (bar.dm=="1")
				{return false}
                id = document.getElementById("LeftTreeArea");
                if (bar.mving) {
                    var nw = (window.event.clientX - 5);
                    nw = nw > 0 ? nw : 0;
                    id.style.width = nw + "px";
                }
                break;
            case 5: // resize-up
				if (bar.dm=="1")
				{return false}
                bar.mving = false;
                bar.releaseCapture();
				ajax.regEvent("SaveLeftTreeWidth");
				ajax.addParam("width",bar.offsetLeft);
				ajax.addParam("orderid",Bill.OrderId);
				ajax.send();
                break;
        }
        try{ window.event.cancelBubble = true; }catch(e){}
		setFrameSize();
    }
}

Bill.getLinkFieldValue = function(fielddbname){
	fielddbname = fielddbname.toLowerCase();
	if(fielddbname.indexOf(".")< 0){ //主表字段
		var box = document.getElementById("billBodyTable").getElementsByTagName("input")
		for (var i = 0; i < box.length ; i ++  )
		{		
				var dbname = box[i].getAttribute("dbname");
				if(dbname){
					if(dbname.toLowerCase()==fielddbname){
						if ((fielddbname == 'company' || fielddbname == 'person') && ',2001,2002,2004,'.indexOf(','+Bill.OrderId+',')>=0){
							return box[i].title;
						}else{
							return box[i].title.length > 0 ? box[i].title : box[i].value;
						}
					}
				}
		}
		box = document.getElementById("billBodyTable").getElementsByTagName("select")
		for (var i = 0; i < box.length ; i ++  )
		{
				var dbname = box[i].getAttribute("dbname");
				if(dbname){
					if(dbname.toString().toLowerCase()==fielddbname){
						return  box[i].value
					}
				}
		}
		return "";
	}
}

Bill.LinksPeople = function(v){  //获取人员信息
		var ax=new xmlHttp()  //实例化xmlhttp对象
		ax.url="Bill.asp";
		ax.regEvent("GeManMessage");
		ax.addParam("key",v);
		var r = ax.send();
		var div = window.DivOpen("ppplinkdlg","人员信息 - " + v,500,200,100)
		div.innerHTML = r
		window.getParent(div,5).style.zIndex = 500000
		lvw.UpdateAllScroll();
		var box = div.getElementsByTagName("select")
		if(box.length>0){
			try{box[0].parentElement.parentElement.style.display="none";}
			catch(e){}

		}
}

Bill.setMainFieldsLink = function(id,lnkCode,readonly,uitype,hasListPower) { //设置主表字段的链接
	uitype = uitype || '';
	hasListPower = hasListPower === undefined ? true : hasListPower;
	if(readonly=="1" || readonly=="True"){
		var v = "" , lk = "" , exp = ""
		if (id.length==0)
		{return false;}
		var td = document.getElementById(id);
		var box = td.getElementsByTagName("input");
		if(box.length==0){box = td.getElementsByTagName("select");}
		if(box.length>0){
			v = box[0].value;
		}
		var key = lnkCode.split("@")
		for (var i=0;i<key.length ; i ++ ){
			if (key[0].toString().replace(/\s/g,"")=='1' && i==3 || key[0].toString().replace(/\s/g,"") == '3' && i == 2) continue;
			exp = key[i].replace(/\[/g,"Bill.getLinkFieldValue(\"").replace(/\]/g,"\")")
			key[i] = eval(exp)
		}

		switch(key[0].toString().replace(/\s/g,"")){
			case "1":	//单据链接
				var status = ""
				if(!key[2]) {key[2]=v;}
				if(key[1]==2){
					//对于生产订单，获取生产订单的状态
					ajax.regEvent("GetMOrderStatus")
					ajax.addParam("ID",key[2])
					status  = ajax.send();
				}
				lk = "readbill.asp?orderid=" + key[1] + "&id=" + key[2] 
				v = (v.length == 0 ? "查看" : v)
				var vName;
				switch (key[1].toString()){
				case '-9' :
					vName = td.innerText.replace(/\s/g,"").length>0?td.innerText:'';
					break;
				case '-10':
					vName = td.innerText.replace(/\s/g,"").length>0?td.innerText:'';
					break;
				default:
					vName=(td.innerText.replace(/\s/g,"")).length>0?td.innerText:v;
					break;
				}
				if (uitype==''){
					if(hasListPower) { 
						td.innerHTML = "<a href='" + lk + "' target=_blank class=com style='margin-left:5px'>" + vName + "</a>" + status;
					}
				}else if (uitype=='fullRow'){
					if (vName.length == 0 || td.innerHTML.length == 0 || !hasListPower){//没列表权限（体现为内容为空）的时候整行都不显示
						td.parentElement.style.display = 'none';
					}else{
						td.innerHTML = '<span style="width:100%;">'+
											'<span style="float:left;padding-left:5px">' + vName + status + '</span>' +
											'<span style="float:right;padding-right:5px">' +
											'<a href="' + lk + '" target="_blank" class="red" style="color:red">查看'+key[3]+'详情</a>' + 
											'</span>' +
										'</span>';
					}
				}else if (uitype=='cell'){
					if (vName.length > 0 && td.innerHTML.length > 0 && hasListPower){//列表权限（体现为内容为空）
						td.innerHTML = '<span style="width:100%;">'+
											'<span style="float:left;padding-left:1px">' + vName + status + '</span>&nbsp;' +
											'<span style="padding-right:5px">' +
											'<a href="' + lk + '" target="_blank" class="red" style="color:red">查看</a>' + 
											'</span>' +
										'</span>';
					}
				}
				return ;
			case "2":  //用户资料
				//td.innerHTML =  "<table><tr><td><a href='###' class=com onclick='Bill.LinksPeople(\"" + v + "\")'>" + v + "</a></td><td></td></tr></table>"
				return; 
			case "3": //产品资料
				if(!key[1]) {key[1]=v;}
				lk = "../../product/content.asp?ord=" + Bill.pwurl(key[1])
				if (uitype==''){
					td.innerHTML = "<a href='" + lk + "' target=_blank class=com>" + v + "</a>"
				}else if (uitype=='fullRow'){
					if (v.length == 0 || td.innerHTML.length == 0 || !hasListPower){//没列表权限（体现为内容为空）的时候整行都不显示
						td.parentElement.style.display = 'none';
					}else{
						td.innerHTML = '<span style="width:100%;">'+
											'<span style="float:left;padding-left:5px">' + td.innerText + '</span>' +
											'<span style="float:right;padding-right:5px">' +
											'<a href="' + lk + '" target="_blank" class="red" style="color:red">查看'+key[2]+'详情</a>' + 
											'</span>' +
										'</span>';
					}
				}else if (uitype=='cell'){
					if (v.length > 0 && td.innerHTML.length > 0 && hasListPower){//列表权限（体现为内容为空）
						td.innerHTML = '<span style="width:100%;">'+
											'<span style="float:left;padding-left:1px">' + td.innerText + '</span>&nbsp;' +
											'<span style="padding-right:5px">' +
											'<a href="' + lk + '" target="_blank" class="red" style="color:red">查看</a>' + 
											'</span>' +
										'</span>';
					}
				}
				return ;
		}
		
	}
}


Bill.TreeEditSaveHook = function(sheetno,id ,orderid){
	Bill.cmdClickEvent = Bill.cmdButtonClick
	Bill.cmdButtonClick = function(button){
		var cmd = button.innerText.replace(/\s/g, "");
		Bill.cmdClickEvent(button);
		if(cmd=="保存" || cmd=="暂存") {
			try{
				if(ajax.Http.responseText.indexOf("成功")>0){
					var tPanel = document.getElementById(id).parentElement;
					tPanel.innerHTML = "<iframe src='treeedit.asp?orderid=" + orderid +"&parentid=" + sheetno + "&PowerReadOnly=0' style='position:relative;width:100%;height:550px;top:-1px;left:-2px;z-index:5000' frameborder=no></iframe>"
					Bill.cmdButtonClick =  Bill.cmdClickEvent;
				}
			}catch(e){}
		}
	}
}

Bill.autoFrameHeight = function(){
	try{
		var h = document.getElementById("bill_bottom_div_sign").offsetTop*1+500;
		if(!Bill.ParentFrame){
			var p = window.parent;
			if(p!=window){
				var fm = p.document.getElementsByTagName("iframe")
				for (var i = 0 ; i < fm.length ; i++)
				{
					if(fm[i].contentWindow==window){
						Bill.ParentFrame = fm[i];
						break;
					}
				}
			}
		}
		if(Bill.ParentFrame){
			Bill.ParentFrame.style.height = h + "px"
		}
	}
	catch(e){alert(e.message)}
}

Bill.SetParentFieldValue = function(id,pTag,pbid){
	var td = document.getElementById(id)
	if(td){
		var ipt = td.getElementsByTagName("input");
		if(ipt.length>0){
			//if(pbid==3){ //上级预测单
				//document.getElementsByName("MT8")[0].value = 2
			//}
			if (ipt[0].title!=pTag && ipt[0].value!=pTag)
			{
				ipt[0].value = pTag;
			}
			Bill.RefreshDetail(true);
		}
	}
}

Bill.detailAlertOnSave = function(msg){  // 弹出保存时明细的错误提示
	var rows = msg.split("\n");
	var html = "<div style='width:380px;height:200px;overflow:auto;border:1px solid #eeeeff;margin:0 auto'>"
	var divBody = window.DivOpen("xxsdresdda","明细有误",420,270)
	var fDiv = window.getParent(divBody,5)
	try{
		fDiv.style.filter = fDiv.style.filter + " Alpha(opacity=100,finishOpacity=70,style=3)"
	}catch(e){}
	var p_col = -1;
	for (var  i=0;i<rows.length;i++ )
	{
		var cells = rows[i].split("|")
		if(cells.length > 4){
			var div = document.getElementById("listview_" + cells[0])
			var colIndex = cells[2]*1 + 1
			var rowIndex = cells[1]*1
			var hCell = div.children[0].rows[0].cells[colIndex]
			var edit = $(hCell).attr("edit");
			var selid =  $(hCell).attr("selid");
			if (edit!="1" && (!selid||selid.length==0))
			{
				while (hCell.previousSibling && edit!= "1"&&(!selid||selid.length==0))
				{
					hCell = hCell.previousSibling;
					edit = $(hCell).attr("edit");
					selid =  $(hCell).attr("selid");
					colIndex = colIndex - 1
				}
				if(hCell){
					cells[4] = hCell.innerText + "不正确。"
				}
				else{
					cells[4] = ""
				}
			}
			var hcelIndex = colIndex;
			if(selid && selid.length>0){
				cells[4] = "请选择正确的" + hCell.innerText
				hcelIndex = hCell.cellIndex*1+1;
			}
			if(p_col!=hcelIndex) {
				html = html + "<div class=datailalertRow onmouseover='this.style.backgroundColor=\"yellow\"' onmouseout='this.style.backgroundColor=\"#fff\"'>"
				if(cells[4].length>0){
					html = html + "<div onmouseover='Bill.showunderline(this,\"red\")' onmouseout='Bill.hideunderline(this,\"#1111FF\")' style='color:#1111FF;width:60px;float:right;cursor:pointer' onclick='Bill.FocusListViewCell(\"" + cells[0] + "\"," + rowIndex + "," + colIndex + ")'>转到编辑</div>"
					html = html + "第" + rowIndex + "行、"
					html = html + "" + hcelIndex + "列&nbsp;&nbsp;"
					html = html + "<span style='color:#ff0000'>" + cells[4] + "</span>"
				}
				html = html + "</div>"
				p_col = hcelIndex;
			}
		}
	}
	divBody.innerHTML =html + "</div>"
	
}

Bill.FocusListViewCell = function(id,rowIndex,cellIndex){
	var div = document.getElementById("listview_" + id)
	var HRow = div.children[0].rows[0]
	div.PageStartIndex = rowIndex;
	
	lvw.Refresh(div)
	lvw.UpdateScrollBar(div)
	lvw.Refresh(div)
	var cell = div.children[0].rows[rowIndex-div.PageStartIndex+1].cells[0]
	cell.innerText = "★" + cell.innerText
	lvw.editfocus(div.children[0].rows[rowIndex-div.PageStartIndex+1].cells[cellIndex])
	return;
}

Bill.autoIframePos = function()
{
	var iframe=document.getElementsByTagName("iframe");
	for(var i=0;i<iframe.length;i++)
	{
		if(iframe[i].tag)
		{
			iframe[i].style.position="";
		}
	}
}

Bill.parseSheet = function(){ //粘贴单据
	var dat = GetCookie("sheetcopydata")
	if(dat)
	{
		dat = dat.split(",")
		if(dat.length==2 && dat[0]==document.getElementById("Bill_Info_type").value){ //同类型单据才可以粘贴
			if(Bill.onSheetPaste){
				Bill.onSheetPaste(dat[1]);
				return;
			}
			if(dat[1]==document.getElementById("Bill_Info_id").value){
				alert("系统目前不允许复制一张单据，然后又粘贴覆盖在该单据自身。");
				return;
			}
			var inputs = document.getElementById("BillMainInfo").getElementsByTagName("input");
			for (var i =  0 ; i < inputs.length ; i ++ )
			{
				var ibox = inputs[i]
				if(ibox.dbname){
					switch(ibox.dbname.toLowerCase()){
						case "id"			: var fv1 = ibox.value; break;
						case "prefixcode"	: var fv2 = ibox.value; break;
						case "creator"		: var fv3 = ibox.value; break;
						case "status"		: var fv4 = ibox.value; break;
						case "id_sp"		: var fv5 = ibox.value; break;
						case "cateid_sp"	: var fv6 = ibox.value; break;
					} 
				}
			}

			var key0  = document.getElementById("Bill_Info_id").value
			var key1  = document.getElementById("Bill_Info_pid").value
			var key2  = document.getElementById("Bill_Info_sign").value
			var key3  = document.getElementById("Bill_Info_curridsp").value
			var key4  = document.getElementById("Bill_Info_user").value
			var key5  = document.getElementById("Bill_Info_readonly").value
			var key6  = document.getElementById("Bill_Info_SplogId").value
			var key7  = document.getElementById("Bill_Info_readonly").value
			var key8  = document.getElementById("Bill_Info_readbillmode").value
			var key9  = document.getElementById("Bill_Info_creator").value
			var key10 = document.getElementById("Bill_Info_del").value
			if(document.getElementById("Bill_Info_nextspid")){var key11 = document.getElementById("Bill_Info_nextspid").value}
			if(document.getElementById("Bill_Info_outspid")){var key12 = document.getElementById("Bill_Info_outspid").value}
			if(Bill.pasteAlert.length>0){
				if(!window.confirm(Bill.pasteAlert)){
					return false;
				}
			}
			ajax.regEvent("BillPaste");
			ajax.addParam("oid",dat[0]);
			ajax.addParam("fromid",dat[1]);
			ajax.addParam("toid",key0);
			var r = ajax.send();
			if (r.length==0){r = dat[1]}
			if (isNaN(r)) {
				var rtext = r.split("|");
				if(rtext.length==2 && !isNaN(rtext[0])){
					r = rtext[0];
					if(rtext[1].length>0) { alert(rtext[1]) }
				}
				else{
					alert(r)
					r = dat[1] 
				} 
				
			}
			if(r=="0") {return false}
			Bill.AddBill(r,1); //1表示同步提交
			document.getElementById("Bill_Info_id").value			= key0
			document.getElementById("Bill_Info_pid").value			= key1
			document.getElementById("Bill_Info_sign").value			= key2
			document.getElementById("Bill_Info_curridsp").value		= key3
			document.getElementById("Bill_Info_user").value			= key4
			document.getElementById("Bill_Info_readonly").value		= key5
			document.getElementById("Bill_Info_SplogId").value		= key6
			document.getElementById("Bill_Info_readonly").value		= key7
			document.getElementById("Bill_Info_readbillmode").value = key8
			document.getElementById("Bill_Info_creator").value		= key9
			document.getElementById("Bill_Info_del").value			= key10
			if(document.getElementById("Bill_Info_nextspid")){document.getElementById("Bill_Info_nextspid").value	= key11}
			if(document.getElementById("Bill_Info_outspid")){document.getElementById("Bill_Info_outspid").value		= key12}
			var inputs = document.getElementById("BillMainInfo").getElementsByTagName("input");
			for (var i =  0 ; i < inputs.length ; i ++ )
			{
				var ibox = inputs[i]
				if(ibox.dbname){
					switch(ibox.dbname.toLowerCase()){
						case "id"			: ibox.value = fv1; break;
						case "prefixcode"	: ibox.value = fv2; break;
						case "creator"		: ibox.value = fv3; break;
						case "status"		: ibox.value = fv4; break;
						case "id_sp"		: ibox.value = fv5; break;
						case "cateid_sp"	: ibox.value = fv6; break;
					} 
				}
			}

		}
		else{
			alert("数据结构已经改变，无法粘贴。")
		}
	}
}
Bill.getinputbyywname = function(ywname){
	var inputs = document.getElementById("billBodyTable").getElementsByTagName("input")
	for (var i=0;i<inputs.length ; i ++ )
	{
		if(inputs[i].ywname==ywname){
			return inputs[i];
		}
	}

}

Bill.controlTimerHwnd = 0;

Bill.controlStatusHandle = function()
{
	var biinfotype = document.getElementById("Bill_Info_type");
	var biinfoid = document.getElementById("Bill_Info_id");
	if(window.location.href.toLowerCase().indexOf("readbill.asp")>0) {return;}
	ajax.regEvent("controlStatusHandle");
	ajax.addParam("oid",biinfotype ? biinfotype.value : 0);
	ajax.addParam("bid",biinfoid?biinfoid.value:0);
	ajax.addParam("sctype","1");						//sctype=1表示删除和修改
	if(Bill._tmp_lockcacheMsg) {
		ajax.addParam("ca_nm", Bill._tmp_lockcacheMsg[0]);
		ajax.addParam("ca_cid", Bill._tmp_lockcacheMsg[1]);
	}
	var button = document.getElementById("bcButton3"); //保存按钮
	if(!button || button.style.display=="none")
	{ajax.addParam("lock",0);}
	else{
		ajax.addParam("lock",1);//是否需要锁定	
	}
	var url = ajax.url;
	ajax.url = "billstatuscontrol.asp";
	ajax.send(Bill.controlStatusResult);
	ajax.url = url;
}

Bill.controlStatusResult = function(r)
{
	var button = document.getElementById("bcButton3"); //保存按钮
	var button1 = document.getElementById("bcButton2"); //暂存按钮
	var button3 = document.getElementById("bcButton4"); //删除按钮
	var button2 = document.getElementById("billupdatecmd");
	if(r.length>0){
		var dat = r.split("|");
		if(dat.length==3)
		{
			if(button) {
				button.setAttribute("controled","1");
				button.disabled = true;
				if(button1) {button1.disabled = true;}
				if(button2) {button2.disabled = true;}
				if(button3) {button3.disabled = true;}
				Bill._tmp_lockcacheMsg = [dat[1],dat[2]];
				Bill.showlockMsg("用户【" + dat[1] + "】正在锁定编辑该单据",true);
			}
		}
	}
	else{
		if(button && button.getAttribute("controled")=="1") {
			button.setAttribute("controled","");
			if(button2) {button2.disabled = false;}
			if(button3) {button3.disabled = false;}
			Bill.showlockMsg("",false);
		}
	}
	Bill.controlTimerHwnd  = window.setTimeout(Bill.controlStatusHandle,5000);
}

Bill.showlockMsg = function(title, v)
{
	var div = document.getElementById("billlockmsg");
	div.innerHTML = title;
	div.style.display = v ? "block" : "none";
}

Bill.controlTimer = function(){  //定时检测单据被占用情况，防止互相窜改
	window.clearInterval(Bill.controlTimerHwnd);
	Bill.controlStatusHandle();
}

Bill.showsheetbaseinfo = function()
{
	var div = window.DivOpen("jsdifhsf","单据基本参数",400,305,'a','b',1,30)
	var html = document.getElementById("Bill_Info_div").innerHTML.toLowerCase();
	html = html.replace(/\<input\sid\=/g,"<div style='border-bottom:1px dotted #eee;line-height:18px;font-size:14px;font-family:arial'>").replace(/value\=/g,"= ").replace(/type\=hidden\>/g,"</div>")
	div.innerHTML =  html
}

Bill.treechildlist = function(){
	var div = window.DivOpen("jsdifhsfa","子单集合","800","570",'30',"b",1,20,'assa',1)
    div.innerHTML = "<iframe style='width:100%;height:100%' frameborder=0 src='../../manufacture/inc/billpage.asp?__msgId=getChildBillTree&oid=" + Bill.OrderId + "&bid=" + document.getElementById("Bill_Info_id").value + "'></iframe>"
}
Bill.inithref = window.location.href.toLowerCase().split("/sysa/manufacture/")[0] + "/sysa";
Bill.BillContextMenuClick = function(txt,tag){
	Bill.contextBodyMenu.hide();
	if(isNaN(Bill.OrderId)){Bill.OrderId = "0";}
	switch(tag){
		case "copy_page":
			document.execCommand("Copy");
			window.focus();
			break;
		case "refresh_page":
			window.location.reload();
			window.focus();
			break;
		case "attrDlg":
			showdebugdlg();
			break;
		case "sheetconfig":
			window.open(Bill.inithref + "/manufacture/inc/billcreator.asp?ID=" + Bill.OrderId);
			break;
		case "sheetlistconfig":
			window.open(Bill.inithref + "/manufacture/inc/BillCreator.list.asp?parentID=" + Bill.OrderId);
			break;
		case "listconfig":
			window.open(Bill.inithref + "/manufacture/inc/listcreator.asp?ID=1");
			break;
		case "back_page":
			break;
		case "copy_sheet":
			var dat = document.getElementById("Bill_Info_type").value + "," + document.getElementById("Bill_Info_id").value;
			SetCookie("sheetcopydata",dat);
			break;
		case "copy_pase": //粘贴单据
			Bill.parseSheet();
			break;
		case "sheetbaseinfo":
			Bill.showsheetbaseinfo();
			break;
		case "get_historysheet":
			break;
		case "tospconfig":
			window.open(Bill.inithref + "/manufacture/inc/spconfig.asp?ID=" + Bill.OrderId ,"_self");
			break;
		case "autocodeconfig":
			document.write("<html><body style='margin:0px'><iframe style='height:100%;width:100%' frameborder=0 src='../../sort3/set_khbh.asp?sort1=" + (Bill.OrderId*1 + 5000) +"'></iframe></body></html>")
			//window.open("../../sort3/set_khbh.asp?sort1=" + (Bill.OrderId*1 + 5000),"_self");
			break;
		case "zdyfieldconfig":
			window.open(Bill.inithref + "/manufacture/inc/fdconfig.asp?ID=" + Bill.OrderId ,"_self");
			break;
		case "tobilllist":
			window.open(Bill.inithref + "/manufacture/inc/billlist.asp?orderID=" + Bill.OrderId);
			break;
		case "tree_child_list":
			Bill.treechildlist();
			window.focus();
			break;
		case "showhidefield":
			Bill.showhidefield();
			window.focus();
			break;
		default:
			if(tag.indexOf("$")>0){tag = tag.split("$")[0]}
			var obj = document.getElementById(tag);
			if(obj){
				obj.click();
			}
	}
}

Bill.showhidefield = function(){
	var inputs = document.getElementById("billBodyTable").getElementsByTagName("input")
	for (var i=0;i<inputs.length ;i++ )
	{
		if(inputs[i].ywname && inputs[i].type=="hidden"){
			inputs[i].outerHTML = ((i>0 && i%5==0)?"<br><br>":"") + "<span style='color:#555588'>" + inputs[i].ywname + ":</span>" + inputs[i].outerHTML.replace("hidden","text").replace(">"," style='width:100px;font-size:12px;border:1px solid #aaa;color:#333388'>&nbsp;&nbsp;&nbsp;&nbsp;")
		}
	}
	var  td = document.getElementsByTagName("td")
	for (var i=0;i< td.length ; i++ )
	{
		if(td[i].className.indexOf("lvc")>=0 && td[i].style.display == "none"){
			td[i].style.display = "";
			td[i].style.width = "100px"
		}
	}
	var  td = document.getElementsByTagName("th")
	for (var i=0;i< td.length ; i++ )
	{
		if(td[i].className.indexOf("lvc")>=0 && td[i].style.display == "none"){
			td[i].style.display = "";
			td[i].style.width = "100px"
			td[i].style.color = "red"
		}
	}
}

//Task.1232.binary.2013.12.20 增加了单选按钮字段的点击事件也能触发子单刷新机制
Bill.radioFieldClick = function(value, box) {
	var forid = box.getAttribute("forid");
	document.getElementsByName(forid)[0].value = value;
	if((box.getAttribute("RefreshChild") + "")=="1") {
		Bill.RefreshDetail(true);
	}
	if(Bill.onRadioFieldClick) {
		Bill.onRadioFieldClick(box);
	}
}

Bill.ScriptHttp = function (){ //获取脚本目录下的js文件调用
	var htp = new xmlHttp();
	htp.url = "../../manufacture/inc/bscript/callback.asp"
	return htp;
}

Bill.ControlMenu = function(){
	document.body.oncontextmenu = function(){
		if(window.event.ctrlKey && !window.event.ctrlLeft) { //禁用个性菜单菜单
			return ;
		}
		var sElement = window.event.srcElement
		var itemMenu = null;
		var tg = window.event.srcElement.tagName
		if(tg=="INPUT"){
			var ty = window.event.srcElement.type.toLowerCase();
			if (ty=="text" || ty=="password")
			{return true;}
		}
		if(tg=="TEXTAREA"){
			return true;
		}
		var tp = "--xs--";
		Bill.contextBodyMenu = new contextmenu(Bill.BillContextMenuClick)
		var m = Bill.contextBodyMenu;
		if(document.selection && document.selection.type.toLowerCase()!="none"){
			itemMenu = m.add();
			itemMenu.text = "复制(<u>C</u>)";
			itemMenu.tag = "copy_page"
			itemMenu.imageurl = "../../images/smico/ico_li.gif"
		}
		

		itemMenu = m.add();
		itemMenu.text = "页面刷新(<u>R</u>)";
		itemMenu.tag = "refresh_page"
		itemMenu.imageurl = "../../images/smico/pgref.gif"

		var topDiv = document.getElementById("billtopbardiv")
		if (topDiv)
		{
			var itemMenu = null;
			var buttons = topDiv.getElementsByTagName("Button")
			for (var i = 0 ; i < buttons.length ; i ++ )
			{	
				var itemButton = buttons[i]
				if(itemButton.id.length==0){
					if(!window.autobuttonidx) { window.autobuttonidx = 1}
					window.autobuttonidx ++;
					itemButton.id = "a_btn_id_" + window.autobuttonidx;
				}
				if(itemButton.offsetHeight>0 && itemButton.style.display.toLowerCase() !="none" && !itemButton.disabled && itemButton.style.visibility.toLowerCase() !="hidden"){
					var po = itemButton.style.cssText + "--" + itemButton.className
					if(tp!=po){
						tp = po;
						itemMenu = m.add();
						itemMenu.tag = "menu_split_item"
					}
					itemMenu = m.add();
					itemMenu.text = itemButton.innerText.length ==0 ?  itemButton.title : itemButton.innerText
					itemMenu.tag = itemButton.id
					var imgs = itemButton.getElementsByTagName("img");
					if(imgs.length>0){
						itemMenu.imageurl = imgs[0].src
					}else {
						itemMenu.imageurl = "";	
					}
					if (itemMenu.text=="流程")
					{
						itemMenu.tag = itemButton.id + "$" + Bill.OrderId + "$" + document.getElementById("Bill_Info_id").value
						itemMenu.childmenu = new contextmenu(Bill.BillContextMenuClick);

						itemMenu_c = itemMenu.childmenu.add();
						itemMenu_c.text = "流程图";
						itemMenu_c.imageurl =  itemMenu.imageurl
						itemMenu_c.tag = itemMenu.tag
						itemMenu.tag = "sscss"
						
						itemMenu_c = itemMenu.childmenu.add();
						itemMenu_c.tag = "menu_split_item"

						itemMenu_c = itemMenu.childmenu.add();
						itemMenu_c.text = "子单集合";
						itemMenu_c.tag = "tree_child_list"
						itemMenu_c.imageurl = "../../images/smico/r0.gif"

						itemMenu.imageurl = ""
					}
				}
			}	
		}

		if(Bill.canCopy==true && Bill.cantextCopy==1){
			itemMenu = m.add();
			itemMenu.tag = "menu_split_item"
			itemMenu = m.add();
			itemMenu.text = "单据信息";
			itemMenu.tag = "copy_edit"
			itemMenu.childmenu = new contextmenu(Bill.BillContextMenuClick);
			itemMenu_c = itemMenu.childmenu.add();
			itemMenu_c.text = "复制(C)";
			itemMenu_c.tag = "copy_sheet"
			itemMenu_c.imageurl = "../../images/smico/copy.gif"

			if(document.getElementById("Bill_Info_readonly").value!=1){
				var d = GetCookie("sheetcopydata")
				if(d)
				{
					d = d.split(",")
					if(d.length==2 && d[0]==document.getElementById("Bill_Info_type").value){ //同类单据可以粘贴
						itemMenu_c = itemMenu.childmenu.add();
						itemMenu_c.text = "粘贴";
						itemMenu_c.tag = "copy_pase"
					}
				}
			}
		}	
		
		if (!isNaN(Bill.OrderId) && Bill.OrderId>0 && Bill.canconfig==1 )
		{
			
			if(Bill.needsp==1 || Bill.hsAutoCode==1 || Bill.disUserDef=="0"){
				if(Bill.canCopy==false){	
					itemMenu = m.add();
					itemMenu.tag = "menu_split_item"
				}
				itemMenu = m.add();
				itemMenu.text = "设置向导";
				itemMenu.tag = "xxconfig"
				itemMenu.childmenu = new contextmenu(Bill.BillContextMenuClick);
				if (Bill.needsp==1)
				{
					itemMenu_c = itemMenu.childmenu.add();
					itemMenu_c.text = "审批流程设置";
					itemMenu_c.tag = "tospconfig"
					itemMenu_c.imageurl = "../../images/smico/561.gif"
				}
				if(Bill.hsAutoCode==1){
					itemMenu_c = itemMenu.childmenu.add();
					itemMenu_c.text = "自动编号设置";
					itemMenu_c.tag = "autocodeconfig"
				}
				if(Bill.disUserDef=="0")
				{
					itemMenu_c = itemMenu.childmenu.add();
					itemMenu_c.text = "自定义字段设置";
					itemMenu_c.tag = "zdyfieldconfig"
					itemMenu_c.imageurl = "../../images/smico/attrib.gif"
				}
			}
		}


		if(window.event.ctrlKey){
			
			if (Bill.attrtop1==false || Bill.canCopy ==true){ //管理权限
				itemMenu = m.add();
				itemMenu.tag = "menu_split_item"
			}
			itemMenu = m.add();
			itemMenu.text = "调试";
			itemMenu.tag = "dbug"
			itemMenu.childmenu = new contextmenu(Bill.BillContextMenuClick);

			itemMenu_c = itemMenu.childmenu.add();
			itemMenu_c.text = "数据";
			itemMenu_c.tag = "attrDlg"
			itemMenu_c.imageurl = "../../images/smico/50.gif"

			itemMenu_c = itemMenu.childmenu.add();
			itemMenu_c.text = "基本参数";
			itemMenu_c.tag = "sheetbaseinfo"

			if(window.location.href.indexOf("127.0.0")>=0 || window.location.href.indexOf("10.148.")>=0){
				itemMenu_c = itemMenu.childmenu.add();
				itemMenu_c.tag = "menu_split_item"

				itemMenu_c = itemMenu.childmenu.add();
				itemMenu_c.text = "主单据配置";
				itemMenu_c.tag = "sheetconfig"
				itemMenu_c = itemMenu.childmenu.add();
				itemMenu_c.text = "明细单配置";
				itemMenu_c.tag = "sheetlistconfig"
				itemMenu_c.imageurl = "../../images/smico/r0.gif"
				itemMenu_c = itemMenu.childmenu.add();
				itemMenu_c.text = "检索配置";
				itemMenu_c.tag = "listconfig"
				itemMenu_c = itemMenu.childmenu.add();
				itemMenu_c.tag = "menu_split_item"
				itemMenu_c = itemMenu.childmenu.add();
				itemMenu_c.text = "转到列表页";
				itemMenu_c.tag = "tobilllist"	
			}
			itemMenu_c = itemMenu.childmenu.add();
			itemMenu_c.text = "显示隐藏字段";
			itemMenu_c.tag = "showhidefield"
		}

		itemMenu = m.add();
		itemMenu.tag = "menu_split_item"
		itemMenu = m.add();
		itemMenu.text = "<a  href='javascript:void(0)' onclick='history.back()' style='color:#000'>后退</a>&nbsp;&nbsp;<a href='javascript:void(0)' onclick='history.forward()' style='color:#000'>前进</a>";
		itemMenu.tag = "back_page"
		
		if(Bill.onContextMenu) {Bill.onContextMenu(m);}  //菜单扩展接口

		m.width = 140
		m.show(); 
		window.event.returnValue = 0;
		return false;
	} 
}

document.onpaste = function(){

}

window.onunload = function(){
	var url = window.location.href;
	if(url != ""){
		if(url.indexOf("manufacture/inc/Bill.asp") > -1){
			try{
				this.opener.ck.currRefresh(100); //定时延缓刷新，防止卡住线程
			}catch(e){}
		}
	}
}

function setFrameSize() {
	//调整页面的宽度，自适应有无左侧导航的情况
	var obj = $ID("billbody");
	if(obj) {
		var sw = obj.scrollHeight - obj.clientHeight;
		var nw = obj.clientWidth*1 //- (sw>0?18:0);
		var lw = $ID("SpliterBar") ? ($ID("SpliterBar").offsetWidth + $ID("SpliterBar").offsetLeft) : 0;
		obj.style.left = lw + 10 + "px";
		obj.style.width = (document.body.clientWidth - lw- 20) + "px";
		var topNoticeDiv = $ID("topNoticeDiv");
		var topH = 0;
		if (topNoticeDiv){topH =topNoticeDiv.clientHeight;}
		obj.style.height = (document.body.clientHeight-topH) + "px";
		billbodyResize();
	}
}

function billbodyResize() {
	var obj = $ID("billbody");
	var scroll =  obj.scrollHeight- obj.offsetHeight;
	var w = (obj.offsetWidth-(scroll>0?17:0));
	if(w<=0) {w=0}
	w = w + "px";
	if($ID("billBodyTable")) { $ID("billBodyTable").style.width =w; }
	if($ID("MainTable")) { $ID("MainTable").style.width = w;}
	if($ID("bill_bottom_div_sign")) { $ID("bill_bottom_div_sign").style.width =w; }
	if($ID("blistbottomarea")) {$ID("blistbottomarea").style.width =w;}
}

function ListFrameResize(box) {
	if(box.scrollWidth - box.offsetWidth>0) {
		box.style.paddingBottom = "20px";
	}else {
		box.style.paddingBottom = "6px";
	}
}

Bill.showChangePage = function(logid){
	window.open("?orderid=" + document.getElementById("Bill_Info_type").value + "&id=" + document.getElementById("Bill_Info_id").value + "&changelogid=" + logid );
}

Bill.openWindowDialog = function(url ,winid , width , height ){
	if (!winid || winid==""){ winid = "newwin";}
	if(!width){width=1100;}
	if(!height){height=600;}
	window.open(url , winid , "width="+width+",height="+height+",fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150");
}

Bill.TexTxmFocus = function(event){
	event = event? event: window.event
	if(!event) return;
	var obj = event.srcElement ? event.srcElement:event.target; 
	if(!obj) return ;
	if(obj.name==undefined){
		var eo = null;
		try{
			eo = document.getElementsByName("txm")[0];
			eo.focus();
		}catch(e1){
			try{
				eo = parent.document.getElementsByName("txm")[0];
				eo.focus();
			}catch(e1){}
		}
	}
}

Bill.onScanComplete = null;

Bill.txmAjaxSubmit = function(obj){
	var TxmText=obj.value;
	if (TxmText.length ==0){return;}
	if(Bill.onScanComplete){
		Bill.onScanComplete(TxmText);
	}else{
		alert("开启了扫描录入功能，请定义Bill.onScanComplete方法，详情见bill.js");
	}
	obj.value = "";
}

Bill.base64 = {};
Bill.base64.map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
Bill.base64.encode = function (s) {
	if (s == undefined || s == "") { return ""; }
	s += '';
	if (s.length === 0) { return s; }
	s = escape(s).replace(/\+/g, "%2b");
	var i, b, x = [], map = Bill.base64.map, padchar = Bill.base64.map.substr(64);
	var len = s.length - s.length % 3;
	for (i = 0; i < len; i += 3) {
		b = (s.charCodeAt(i) << 16) | (s.charCodeAt(i + 1) << 8) | s.charCodeAt(i + 2);
		x.push(map.charAt(b >> 18));
		x.push(map.charAt((b >> 12) & 0x3f));
		x.push(map.charAt((b >> 6) & 0x3f));
		x.push(map.charAt(b & 0x3f));
	}
	switch (s.length - len) {
		case 1:
			b = s.charCodeAt(i) << 16;
			x.push(map.charAt(b >> 18) + map.charAt((b >> 12) & 0x3f) + padchar + padchar);
			break;
		case 2:
			b = (s.charCodeAt(i) << 16) | (s.charCodeAt(i + 1) << 8);
			x.push(map.charAt(b >> 18) + map.charAt((b >> 12) & 0x3f) + map.charAt((b >> 6) & 0x3f) + padchar);
			break;
	}
	return x.join('');
};
Bill.pwurl = function (num) { return "PW2_" + Bill.base64.encode((num + "").split("").reverse().join("")); }