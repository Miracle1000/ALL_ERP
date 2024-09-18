
	window.onerror = function(){return true;}
	function body_load(){
		try{var wBorder = window.dialogWidth.replace("px","")-document.body.offsetWidth;}
		catch(e){var wBorder=0}
		document.body.onresize = function(){
			try{
				document.body.style.width = (window.dialogWidth.replace("px","") - wBorder ) + "px"
			}catch(e){}
		}
		window.focus();
		loadprintConfig();
	}

	function Setting(){
		var div = window.DivOpen("xx_set","打印设置",400,240)
		div.innerHTML = "<fieldSet style='border:1px solid #aaa;margin:8px;padding:10px'><legend>页面布局</legend><table cellSpacing=5><tr><td><input onclick='setprintFx(0)' " + (printFx==0 ? "checked" : "") + " type=radio name='printFx' id='printFx1'></td><td><label for='printFx1'>纵向</label></td><td>&nbsp;</td><td><input onclick='setprintFx(1)' " + (printFx==1 ? "checked" : "") + " type=radio id='printFx2' name='printFx'></td><td><label for='printFx2'>横向</label></td></tr></table></fieldSet>"
	}

	function loadprintConfig(){
		if(!window.dialogArguments) {
			window.dialogArguments = opener.showModalDialogPrintObj;
		}
		if(window.dialogArguments){
			var win = dialogArguments.win;
			var typ = dialogArguments.typ
			if(typ=="bill"){//单据打印
				loadBillPage(win)
			}
		}else{
			if(window.opener) {
				var win = opener.win;
				var typ = opener.typ
				if(typ=="bill"){//单据打印
					loadBillPage(win)
				}
			}
		}
	}

	function loadBillPage(win){
		var bTitle = win.document.getElementById("billtitle").innerText
		document.title = bTitle + "打印";
		var page = win.document.getElementById("MainTable").cloneNode(true);
		page.style.width = "100%";
		var img = page.getElementsByTagName("img");
		for(var i= img.length-1;i>=0;i--){
			if($(img[i].parentElement).attr("class")!="billfieldright"){
				img[i].parentElement.removeChild(img[i])
			}
		}
		var span = page.getElementsByTagName("span")
		for(var i= span.length-1;i>=0;i--){
			if(span[i].innerText == "*"){
				span[i].innerText = ""
			}
		}

		var txt = page.getElementsByTagName("input")
		for(var i = txt.length-1;i>=0;i--){
			if(txt[i].dbname&&txt[i].type!="hidden") {
				if(txt[i].type=="checkbox") {
					txt[i].outerHTML = txt[i].checked ? "是" : "否"
				}
				else{
					txt[i].outerHTML = txt[i].value
				}
			}
			else{
				txt[i].parentElement.removeChild(txt[i])
			}
		}
		if(page.all) {
			for(var i = 0 ;i<page.all.length;i++){
				page.all[i].onclick = function(){}
				page.all[i].onmouseover = function(){}
				page.all[i].onmouseout = function(){}
			}
		}else {
			var objs = page.querySelectorAll("div, td, span, input, button");
			for (var i = 0; i < objs.length ; i ++ )
			{
				objs[i].onclick = function(){}
				objs[i].onmouseover = function(){}
				objs[i].onmouseout = function(){}
			}
		}
		var s = page.outerHTML;
		s = s.replace(/\sonmouseover[ ]*\=/g," a=");
		s = s.replace(/\sonmouseout[ ]*\=/g," a=");
		s = s.replace(/\sonmousemove[ ]*\=/g," a=");
		s = s.replace(/\sonmousedown[ ]*\=/g," a=");
		s = s.replace(/\sonmouseup[ ]*\=/g," a=");
		s = s.replace(/\sonmousewheel[ ]*\=/g," a=");
		s = s.replace(/\sonscroll[ ]*\=/g," a=");
		s = s.replace(/lvc\sedt0\scenter/g,"lvw_edt0_center");
		var cbody = document.getElementById("wPage1").contentWindow.document.body;
		cbody.style.width = printFx==1 ? "277mm" : "190mm";
		document.getElementById("wPage1").contentWindow.document.getElementById("PageBody").innerHTML = "" +
		"<center><span style='font-size:16px;font-family:黑体'>" + bTitle + "</span></center><br><br>" + s;
		var doc = document.getElementById("wPage1").contentWindow.document;
		var tb = doc.getElementById("PageBody").getElementsByTagName("table")[0];
		var trs = new Array();
		var tds = tb.cells?tb.cells:tb.querySelectorAll("td");
		for(var i = 0;i<tds.length;i++)
		{
			var tv = tds[i].innerText.replace(/\s/g,"");
			if (tv == "关联单据" || tv == "下级关联单据") {
				if(tds[i].colSpan==6)
				{
					trs[trs.length] = tds[i].parentNode;
					trs[trs.length] = tds[i].parentNode.nextSibling;
				}
			}
			if(tds[i].colSpan==6) {
				tds[i].style.width = "100%";
			}
			if(tds[i].colSpan==5) {
				tds[i].style.width = parseInt(800/9) + "%";
			}
			if(tds[i].colSpan==4) {
				tds[i].style.width = "66%";
			}


		}
		for(i=0;i<trs.length;i++){
			trs[i].style.display = "none";
		}
		var sbox = tb.getElementsByTagName("select");
		for(var i = sbox.length-1 ; i>=0  ; i -- )
		{
			try{sbox[i].outerHTML = sbox[i].options[sbox[i].selectedIndex].text;}catch(e){}
		}
		sbox = tb.getElementsByTagName("Input");
		for(var i = sbox.length-1 ; i>=0  ; i -- )
		{
			if(sbox[i].type=="hidden"){
				sbox[i].value = "";
			}
		}
		sbox = tb.getElementsByTagName("iframe");
		for(var i = sbox.length-1 ; i>=0  ; i -- )
		{

			var id = sbox[i].id;
			if(id.indexOf("WebEditor")>0)
			{
				var id = id.replace("eWebEditor_","");
				var html = doc.getElementsByName(id)[0].value;
				sbox[i].outerHTML  = "<div >" + html + "</div>";
			}
			else
			{
				var p = sbox[i].parentElement;
				url = sbox[i].src;
				var ax = new xmlHttp();
				var xhttp = ax.getHttp();
				xhttp.open("get",url,false);
				xhttp.send();
				var s = xhttp.responseText;
				s = s.replace(/\sonmouseover[ ]*\=/g," a=");
				s = s.replace(/\sonmouseout[ ]*\=/g," a=");
				s = s.replace(/\sonmousemove[ ]*\=/g," a=");
				s = s.replace(/\sonmousedown[ ]*\=/g," a=");
				s = s.replace(/\sonmouseup[ ]*\=/g," a=");
				s = s.replace(/\sonmousewheel[ ]*\=/g," a=");
				s = s.replace(/\sonscroll[ ]*\=/g," a=");
				s = s.replace(/\sonclick[ ]*\=/g," a=");
				s = s.replace(/lvc\sedt0\scenter/g,"lvw_edt0_center");
				s = s.replace(/\<scrip/g,"<div style='display:none' x#");
				s = s.replace(/x\#t/g,"");
				s = s.replace(/\<\/script\>/g,"</div>");
				s = s.replace(/\<link\s/g,"<uuuu ");
				s = s.replace(/absolute/g,"");
				sbox[i].outerHTML = "<div >" +  s + "</div>";
			}
		}
	}

	function doPrint(){
		var Win = document.getElementById("wPage1").contentWindow
		Win.focus();
		Win.print();
	}

	function loadPageBody(){

	}
