//IE特有函数扩展
window.HasActiveXObject = ((window.ActiveXObject + "") == "undefined" ? false : true);
window.getIEVer = function () {
	var browser = navigator.appName;
	if (window.ActiveXObject && top.document.compatMode == "BackCompat") { return 5; }
	var b_version = navigator.appVersion;
	var version = b_version.split(";");
	if (window.HasActiveXObject) {
		var v = version[1].replace(/[ ]/g, "");
		if (v == "MSIE9.0") { return 9; }
		if (v == "MSIE8.0") { return 8; }
		if (v == "MSIE7.0") { return 7; }
		if (v == "MSIE6.0") { return 6; }
		if (v == "MSIE5.0") { return 5; }
		if (window.navigator.userAgent.indexOf("rv:11.0")) { return 11; }
		else { return 10 }
	}
	else {
		return 100;
	}
};
window.IEVer = window.getIEVer();
function __firefox() {
	HTMLElement.prototype.__defineGetter__("runtimeStyle", __element_style);
	window.constructor.prototype.__defineGetter__("event", __window_event);
	Event.prototype.__defineGetter__("srcElement", __event_srcElement);
}
function __element_style() { return this.style; }
function __window_event() { return __window_event_constructor(); }
function __event_srcElement() { return this.target; }
function __window_event_constructor() {
	if (document.all) { return window.event; }
	var _caller = __window_event_constructor.caller;
	while (_caller != null) {
		var _argument = _caller.arguments[0];
		if (_argument) {
			var _temp = _argument.constructor;
			if (_temp.toString().indexOf("Event") != -1) { return _argument; }
		}
		_caller = _caller.caller;
	}
	return null;
}
if (window.addEventListener && HTMLElement.prototype.__defineGetter__) { __firefox(); }
// 当前模式
var sCurrMode = null;
var bEditMode = null;
// 连接对象
var oLinkField = null;

// 浏览器版本检测
window.BrowserInfo = new Object();
try {
	BrowserInfo.MajorVer = navigator.appVersion.match(/MSIE (.)/)[1];
	BrowserInfo.MinorVer = navigator.appVersion.match(/MSIE .\.(.)/)[1];
} catch (e) {
	if (BrowserInfo.MajorVer == 1) {
		BrowserInfo.MajorVer = 10;
		BrowserInfo.MinorVer = 1;
	}
}
BrowserInfo.IsIE55OrMore = true;// BrowserInfo.MajorVer >= 6 || ( BrowserInfo.MajorVer >= 5 && BrowserInfo.MinorVer >= 5 ) ;
var yToolbars = new Array();  // 工具栏数组

// 当文档完全调入时，进行初始化
var bInitialized = false;
window.NotIE = false;
//window.eWebEditor = null;

window.SessionExt = function () {
	var obj = new Object();
	obj = window.eWebEditor.document.getSelection();
	obj.createRange = function () {
		//var sObj = obj.anchorNode;
		var rRange = null;
		try {
			rRange = obj.getRangeAt(0);
		} catch (e) {  //edge会进这个分支
			var nullobj = new Object();
			nullobj.pasteHTML = function (html) {
				format("insertHTML", html);/**/
				/*var  span = window.eWebEditor.document.createElement("span");
				span.innerHTML = html;
				var pobj = (obj.anchorNode && obj.anchorNode.parentElement)?obj.anchorNode.parentElement:null;
				(pobj?pobj:window.eWebEditor.document.body).appendChild(span);*/
			}
			return nullobj;
		}
		var allchildrens = rRange.commonAncestorContainer.children; //tagName=="BODY"?sObj.children:sObj.parentElement.children;
		var items = new Array();
		if (allchildrens) {
			for (var i = 0; i < allchildrens.length ; i++) {
				allchildrens[i].setAttribute("edwsign", "x" + i);
			}
			var tmpDoc = rRange.cloneContents();
			var selchildrens = tmpDoc.children ? tmpDoc.children : tmpDoc.childrenNodes;
			for (var i = 0; i < (selchildrens ? selchildrens.length : 0) ; i++) {
				var v = selchildrens[i].getAttribute("edwsign");
				if (v && v.indexOf("x") == 0) {
					var iobj = allchildrens[v.replace("x", "") * 1];
					if (iobj.tagName != "BODY" && iobj.tagName != "HTML" && iobj.tagName != "HEAD") {
						items[items.length] = iobj;
					} else {
						for (var ii = 0; ii < iobj.children.length ; ii++) {
							items[items.length] = iobj.children[ii];
						}
					}
				}
			}
			if (items.length == 0 && obj.anchorNode && obj.anchorNode.tagName != "BODY")
			{ items[0] = obj.anchorNode; }
			selchildrens = null;
		} else {
			if (obj.anchorNode && obj.anchorNode.toString().indexOf("Text") > 0) {
				var pelem = obj.anchorNode.parentElement;
			}
		}
		tmpDoc = null;
		items.getBookmark = function () { return ""; }
		items.queryCommandValue = function () { return ""; }
		items.parentElement = function () {
			return items[0] ? items[0].parentElement : (obj.anchorNode ? obj.anchorNode : null);
		}
		items.pasteHTML = function (html) {  //在当前选中区插入html
			format("insertHTML", html);/**/
		}
		items.execCommand = function (cmdtxt, cmdstate, cmdval) {
			format(cmdtxt, cmdval)
		}
		items.item = function (index) {
			return items[index];
		}
		return items;
	}
	obj.queryCommandValue = function () { return ""; }
	obj.clear = function () {
		obj.deleteFromDocument();
	}
	return obj;
}

window.GetCurrSession = function () {
	if (window.HasActiveXObject) {
		if (window.IEVer == 11) {
			return window.SessionExt();
		} else {
			return document.getElementById("eWebEditor").contentWindow.document.selection;
		}
	} else {
		return window.SessionExt();
	}
}

document.onreadystatechange = function () {
	if (document.readyState != "complete") return;
	if (!window.eWebEditor) { window.eWebEditor = document.getElementById("eWebEditor"); } else {
		if (!window.eWebEditor.contentWindow) { window.eWebEditor.contentWindow = window.eWebEditor; }
	}
	if (!window.eWebEditor.document) { window.eWebEditor.document = window.eWebEditor.contentWindow.document; }
	if (!window.eWebEditor.document.selection) {
		window.NotIE = true;
		Object.defineProperties(
			window.eWebEditor.document,
			{
				selection: {
					get: window.SessionExt,
					enumerable: true,
					configurable: true
				}
			}
		);
	}
	if (bInitialized) return;
	bInitialized = true;

	var i, s, curr;

	$("div.yToolbar").each(function () {
		var div = $(this)[0];
		InitTB(div);
		yToolbars[yToolbars.length] = div;
	})

	oLinkField = parent.document.getElementsByName(sLinkFieldName)[0];
	if (!oLinkField) {
		oLinkField = parent.document.getElementById(sLinkFieldName);
	}
	if (!config.License) {
		try {
			eWebEditor_License.innerHTML = "&copy; <a href='http://www.zbintel.com' target='_blank'><font color=#000000>zbintel.com</font></a>";
		}
		catch (e) {
		}
	}

	// IE5.5以下版本只能使用纯文本模式
	if (!BrowserInfo.IsIE55OrMore) {
		config.InitMode = "TEXT";
	}
	if (ContentFlag.value == "0" && oLinkField) {
		var html = oLinkField.value;
		if (html.replace(/\s/g, "").length == 0 && !window.HasActiveXObject) {
			html = "<br>";
		}
		ContentEdit.value = html;
		ContentLoad.value = html;
		ModeEdit.value = config.InitMode;
		ContentFlag.value = "1";
	}

	setMode(ModeEdit.value);
	setLinkedField();
}

// 初始化一个工具栏上的按钮
function InitBtn(btn) {
	var YUSERONCLICK = btn.onclick;
	$(btn).unbind()
		  .bind("mouseover", function (e) { BtnMouseOver.call(this, [e]); })
		  .bind("mouseout", function (e) { BtnMouseOut.call(this, [e]); })
		  .bind("mousedown", function (e) { BtnMouseDown.call(this, [e]); })
		  .bind("mouseup", function (e) { BtnMouseUp.call(this, [e]); })
		  .bind("dragstart", function (e) { YCancelEvent.call(this, [e]); })
		  .bind("selectstart", function (e) { YCancelEvent.call(this, [e]); })
		  .bind("select", function (e) { YCancelEvent.call(this, [e]); });
	if (!YUSERONCLICK) {
		$(btn).bind("click", function (e) {
			return YCancelEvent.call(this, [e]);
		});
	}
	if (!window.HasActiveXObject) {
		$("#FindReplace").hide();
	}
	return true;
}

//Initialize a toolbar. 
function InitTB(y) {
	// Set initial size of toolbar to that of the handle
	y.TBWidth = 0;

	// Populate the toolbar with its contents
	if (!PopulateTB(y)) return false;

	// Set the toolbar width and put in the handle
	y.style.posWidth = y.TBWidth;

	return true;
}


// Hander that simply cancels an event
function YCancelEvent() {
	event.returnValue = false;
	event.cancelBubble = true;
	return false;
}

// Toolbar button onmouseover handler
function BtnMouseOver() {
	if (event.srcElement.tagName != "IMG") return false;
	var image = event.srcElement;
	var element = image.parentElement;

	// Change button look based on current state of image.
	if (image.className == "Ico") element.className = "BtnMouseOverUp";
	else if (image.className == "IcoDown") element.className = "BtnMouseOverDown";

	event.cancelBubble = true;
}

// Toolbar button onmouseout handler
function BtnMouseOut() {
	if (event.srcElement.tagName != "IMG") {
		event.cancelBubble = true;
		return false;
	}

	var image = event.srcElement;
	var element = image.parentElement;
	yRaisedElement = null;

	element.className = "Btn";
	image.className = "Ico";

	event.cancelBubble = true;
}

// Toolbar button onmousedown handler
function BtnMouseDown() {
	if (event.srcElement.tagName != "IMG") {
		event.cancelBubble = true;
		event.returnValue = false;
		return false;
	}

	var image = event.srcElement;
	var element = image.parentElement;

	element.className = "BtnMouseOverDown";
	image.className = "IcoDown";

	event.cancelBubble = true;
	event.returnValue = false;
	return false;
}

// Toolbar button onmouseup handler
function BtnMouseUp() {
	if (event.srcElement.tagName != "IMG") {
		event.cancelBubble = true;
		return false;
	}

	var image = event.srcElement;
	var element = image.parentElement;

	//try{ 
	//if (element.YUSERONCLICK) eval(element.YUSERONCLICK + "anonymous()"); 
	//} 
	//catch(e){ 
	//if (element.YUSERONCLICK) eval(element.YUSERONCLICK + "onclick(event)"); 
	//}



	element.className = "BtnMouseOverUp";
	image.className = "Ico";

	event.cancelBubble = true;
	return false;
}

// Populate a toolbar with the elements within it
function PopulateTB(y) {
	var i, elements, element;

	// Iterate through all the top-level elements in the toolbar
	elements = y.children;
	for (i = 0; i < elements.length; i++) {
		element = elements[i];
		if (element.tagName == "SCRIPT" || element.tagName == "!") continue;

		switch (element.className) {
			case "Btn":
				if (element.YINITIALIZED == null) {
					if (!InitBtn(element)) {
						alert("Problem initializing:" + element.id);
						return false;
					}
				}

				element.style.left = y.TBWidth + "px";
				y.TBWidth += element.offsetWidth + 1;
				//console.log(element.style.left)
				break;

			case "TBGen":
				element.style.left = y.TBWidth + "px";
				y.TBWidth += element.offsetWidth + 1;
				break;

			case "TBSep":
				element.style.left = y.TBWidth + 2 + "px";
				y.TBWidth += 5;
				break;

			case "TBHandle":
				element.style.left = 2 + "px";
				y.TBWidth += element.offsetWidth + 7;
				break;

			default:
				alert("Invalid class: " + element.className + " on Element: " + element.id + " <" + element.tagName + ">");
				return false;
		}
	}

	y.TBWidth += 1;
	return true;
}


// 设置所属表单的提交或reset事件
function setLinkedField() {
	if (!oLinkField) return;
	var oForm = oLinkField.form;
	if (!oForm) return;
	// 附加submit事件
	$(oForm).bind("submit", function (e) { AttachSubmit.call(this, [e]) });
	if (!oForm.doneAutoRemote) oForm.doneAutoRemote = 0;
	if (!oForm.submitEditor) oForm.submitEditor = new Array();
	oForm.submitEditor[oForm.submitEditor.length] = AttachSubmit;
	if (!oForm.originalSubmit) {
		oForm.originalSubmit = oForm.submit;
		oForm.submit = function () {
			if (this.submitEditor) {
				for (var i = 0 ; i < this.submitEditor.length ; i++) {
					this.submitEditor[i]();
				}
			}
			this.originalSubmit();
		}
	}
	// 附加reset事件
	$(oForm).bind("reset", function (e) { AttachReset.call(this, [e]) });
}

// 附加submit提交事件,大表单数据提交,远程文件获取,保存eWebEditor中的内容
var bDoneAutoRemote = false;
function AttachSubmit() {
	var oForm = oLinkField.form;
	if (!oForm) return;

	if ((config.AutoRemote == "1") && (!bDoneAutoRemote)) {
		parent.event.returnValue = false;
		bDoneAutoRemote = true;
		remoteUpload();
	} else {
		var html = getHTML();
		ContentEdit.value = html;
		if (sCurrMode == "TEXT") {
			html = HTMLEncode(html);
		}
		splitTextField(oLinkField, html);
	}
}

// 提交表单
function doSubmit() {
	var oForm = oLinkField.form;
	if (!oForm) return;
	oForm.submit();
}

// 附加Reset事件
function AttachReset() {
	if (bEditMode) {
		eWebEditor.document.body.innerHTML = ContentLoad.value;
	} else {
		eWebEditor.document.body.innerText = ContentLoad.value;
	}
}

// 显示帮助
function onHelp() {

}

// 粘贴时自动检测是否来源于Word格式
function onPaste() {
	if (sCurrMode == "VIEW") return false;

	if (sCurrMode == "EDIT") {
		var sHTML = GetClipboardHTML();
		if (config.AutoDetectPasteFromWord && BrowserInfo.IsIE55OrMore) {
			var re = /<\w[^>]* class="?MsoNormal"?/gi;
			if (re.test(sHTML)) {
				if (confirm("你要粘贴的内容好象是从Word中拷出来的，是否要先清除Word格式再粘贴？")) {
					cleanAndPaste(sHTML);
					convertPasteImgUrl();
					return false;
				}
			}
		}
		eWebEditor.document.selection.createRange().pasteHTML(sHTML);
		convertPasteImgUrl();
		return false;
	} else {
		eWebEditor.document.selection.createRange().pasteHTML(HTMLEncode(clipboardData.getData("Text")));
		convertPasteImgUrl();
		return false;
	}
}

//转换粘贴的图片路径，防止自带http
function convertPasteImgUrl() {
	var imgs = eWebEditor.document.getElementsByTagName("img")
	for (var i = 0 ; i < imgs.length; i++) {
		var im = imgs[i];
		var u = im.getAttribute("PasteUrl");
		if (u && u.length > 0) {
			im.src = u;
			im.setAttribute("PasteUrl", "")
		}
	}
}

// 快捷键
function onKeyDown(event) {
	var key = String.fromCharCode(event.keyCode).toUpperCase();
	// F2:显示或隐藏指导方针
	if (event.keyCode == 113) {
		showBorders();
		return false;
	}
	if (event.ctrlKey) {
		// Ctrl+Enter:提交
		if (event.keyCode == 10) {
			doSubmit();
			return false;
		}
		// Ctrl++:增加编辑区
		if (key == "+") {
			sizeChange(300);
			return false;
		}
		// Ctrl+-:减小编辑区
		if (key == "-") {
			sizeChange(-300);
			return false;
		}
		// Ctrl+1:代码模式
		if (key == "1") {
			setMode("CODE");
			return false;
		}
		// Ctrl+2:设计模式
		if (key == "2") {
			setMode("EDIT");
			return false;
		}
		// Ctrl+3:纯文本
		if (key == "3") {
			setMode("TEXT");
			return false;
		}
		// Ctrl+4:预览
		if (key == "4") {
			setMode("VIEW");
			return false;
		}
	}

	switch (sCurrMode) {
		case "VIEW":
			return true;
			break;
		case "EDIT":
			if (event.ctrlKey) {
				// Ctrl+V:粘贴
				if (key == "V") {
					PasteWord();
					return false;
				}
				// Ctrl+D:从Word粘贴
				if (key == "D") {
					PasteWord();
					return false;
				}
				// Ctrl+R:查找替换
				if (key == "R") {
					findReplace();
					return false;
				}
				// Ctrl+Z:Undo
				if (key == "Z") {
					goHistory(-1);
					return false;
				}
				// Ctrl+Y:Redo
				if (key == "Y") {
					goHistory(1);
					return false;
				}
			}
			if (!event.ctrlKey && event.keyCode != 90 && event.keyCode != 89) {
				if (event.keyCode == 32 || event.keyCode == 13) {
					saveHistory()
				}
			}
			return true;
			break;
		default:
			if (event.keyCode == 13) {
				var sel = eWebEditor.document.selection.createRange();
				sel.pasteHTML("<BR>");
				event.cancelBubble = true;
				event.returnValue = false;
				sel.select();
				sel.moveEnd("character", 1);
				sel.moveStart("character", 1);
				sel.collapse(false);
				return false;
			}
			// 屏蔽事件
			if (event.ctrlKey) {
				// Ctrl+B,I,U
				if ((key == "B") || (key == "I") || (key == "U")) {
					return false;
				}
			}

	}
}

function GetEditXmlHttp() {
	//创建http对象
	var MSXML = ['Msxml2.XMLHTTP',
					'Microsoft.XMLHTTP',
					'Msxml2.XMLHTTP.5.0',
					'Msxml2.XMLHTTP.4.0',
					'Msxml2.XMLHTTP.3.0'
	];
	if (window.XMLHttpRequest) { try { return new XMLHttpRequest(); } catch (e) { } }
	for (var i = 0; i < MSXML.length; i++) { try { return new ActiveXObject(MSXML[i]); } catch (e) { } }
}


function getClipboard() {
	if (window.clipboardData) {
		return (window.clipboardData.getData('Text'));
	}
	else if (window.netscape) {
		try {
			netscape.security.PrivilegeManager.enablePrivilege('UniversalXPConnect');
		} catch (e) {
			alert("您的粘贴操作因设置问题而未生效，请依以下步骤进行设置\n1. 请在地址栏输入 about:config 并按下enter\n2. 请于[signed.applets.codebase_principal_support]首选项点击鼠标右键切换值为true\n\n然后重试粘贴！");
			return false;
		}
		var clip = Components.classes['@mozilla.org/widget/clipboard;1'].createInstance(Components.interfaces.nsIClipboard);
		if (!clip) return;
		var trans = Components.classes['@mozilla.org/widget/transferable;1'].createInstance(Components.interfaces.nsITransferable);
		if (!trans) return;
		trans.addDataFlavor('text/unicode');
		clip.getData(trans, clip.kGlobalClipboard);
		var str = new Object();
		var len = new Object();
		try {
			trans.getTransferData('text/unicode', str, len);
		}
		catch (error) {
			return;
		}
		if (str) {
			if (Components.interfaces.nsISupportsWString) str = str.value.QueryInterface(Components.interfaces.nsISupportsWString);
			else if (Components.interfaces.nsISupportsString) str = str.value.QueryInterface(Components.interfaces.nsISupportsString);
			else str = null;
		}
		if (str) {
			return (str.data.substring(0, len.value / 2));
		}
	}
}
// 取剪粘板中的HTML格式数据
function GetClipboardHTML() {
	var oDiv = document.getElementById("eWebEditor_Temp_HTML")
	oDiv.innerHTML = "";
	if (!document.body.createTextRange) { return; } //暂未实现
	var oTextRange = document.body.createTextRange();
	oTextRange.moveToElementText(oDiv);
	oTextRange.execCommand("Paste");
	var isAllowPasteImage = document.getElementById("isAllowPasteImage");
	if (isAllowPasteImage.value == 1) {
		try {
			var imgs = oDiv.getElementsByTagName("imagedata")
			var obj = document.getElementById("EditImgPaseCtl")
			if (!obj) {
				var obj = document.createElement("object");
				//{AB0716CF-4472-487C-BC6C-29C649542831}--{35A2D64D-531A-468C-A128-BED5150A3312}
				//F91A9769-0B6C-43AC-B5EB-1152FE7D2048  ---------- 0B837A6B-51EC-477A-82E3-CB6935D19C3F
				obj.setAttribute("classid", "clsid:35A2D64D-531A-468C-A128-BED5150A3312")
				obj.setAttribute("CODEBASE", "../ocx/zbFileSys.ocx#version=1,0,0,16")
				obj.style.cssText = "height:10px;width:10px;position:absolute;top:1px;left:1px"
				obj.id = "EditImgPaseCtl";
				document.body.appendChild(obj);
			}
			if (imgs.length == 0) {
				src = obj.object.GetClipboard(1, "GIF");
				if (src.length > 0) {

					var srclist = src.split(".");
					data = "data=" + escape(obj.object.ReadBinaryFile(src)).replace(/\+/g, "%2B") + "&fname=" + srclist[srclist.length - 1];
					var xhttp = GetEditXmlHttp();
					xhttp.open("post", "../edit/include/saveTmpFile.asp?t=" + (new Date()).getTime(), false)
					xhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
					xhttp.setRequestHeader("Content-Length", data.length + "");
					xhttp.send(data);
					src = xhttp.responseText;  //上传后的路径
					if (src.indexOf("ok=") == 0) {
						src = src.replace("ok=", "")
						oDiv.innerHTML = "<img PasteUrl='" + src + "' >";
					}
					else {
						alert(src);
					}
				}
			}
			else {
				for (var i = imgs.length - 1; i >= 0 ; i--) {
					var src = imgs[i].src;
					var srclist = src.split(".");
					data = "data=" + escape(obj.object.ReadBinaryFile(src)).replace(/\+/g, "%2B") + "&fname=" + srclist[srclist.length - 1];
					var xhttp = GetEditXmlHttp();
					xhttp.open("post", "../edit/include/saveTmpFile.asp?t=" + (new Date()).getTime(), false)
					xhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
					xhttp.setRequestHeader("Content-Length", data.length + "");
					xhttp.send(data);
					src = xhttp.responseText;  //上传后的路径
					if (src.indexOf("ok=") == 0) {
						src = src.replace("ok=", "")
					}
					var pEm = imgs[i].parentNode;
					var w = parseInt((pEm.style.width + "").replace("px", "")); w = w < 10 ? 10 : w;
					var h = parseInt((pEm.style.height + "").replace("px", "")); h = h < 10 ? 10 : h;
					pEm.outerHTML = "<img PasteUrl='" + src + "' width='" + w + "' height='" + h + "'>";
				}
			}
		}
		catch (e) { }
	}

	var sData = oDiv.innerHTML;
	oDiv.innerHTML = "";
	if (sData.length > 0) {
		if (confirm("你要粘贴的内容带有HTML格式，可能无法保存，是否要先清除Word格式再粘贴？")) {
			cleanAndPaste(sData);
			convertPasteImgUrl();
			return "";
		}
		else {
			return sData;
		}
	}

	else {
		return "";
	}
}

// 清除WORD冗余格式并粘贴
function cleanAndPaste(html) {
	// Remove all SPAN tags
	html = html.replace(/<\/?SPAN[^>]*>/gi, "");
	// Remove Class attributes
	html = html.replace(/<(\w[^>]*) class=([^ |>]*)([^>]*)/gi, "<$1$3");
	// Remove Style attributes
	html = html.replace(/<(\w[^>]*) style="([^"]*)"([^>]*)/gi, "<$1$3");
	// Remove Lang attributes
	html = html.replace(/<(\w[^>]*) lang=([^ |>]*)([^>]*)/gi, "<$1$3");
	// Remove XML elements and declarations
	html = html.replace(/<\\?\?xml[^>]*>/gi, "");
	// Remove Tags with XML namespace declarations: <o:p></o:p>
	html = html.replace(/<\/?\w+:[^>]*>/gi, "");
	// Replace the &nbsp;
	html = html.replace(/&nbsp;/, " ");
	// Transform <P> to <DIV>
	var re = new RegExp("(<P)([^>]*>.*?)(<\/P>)", "gi");	// Different because of a IE 5.0 error
	html = html.replace(re, "<div$2</div>");
	insertHTML(html);
}

// 在当前文档位置插入.
function insertHTML(html) {
	if (isModeView()) return false;
	var selection = window.GetCurrSession();
	if (!selection.type || selection.type.toLowerCase() != "none") {
		selection.clear();
	}
	if (sCurrMode != "EDIT") {
		html = HTMLEncode(html);
	}
	selection.createRange().pasteHTML(html);
}

// 设置编辑器的内容
function setHTML(html) {
	ContentEdit.value = html;
	try { eWebEditor.document.charset = "gb2312"; } catch (e) { }
	switch (sCurrMode) {
		case "CODE":
			eWebEditor.document.designMode = "On";
			eWebEditor.document.open();
			eWebEditor.document.write(config.StyleEditorHeader);
			eWebEditor.document.body.innerText = html;
			eWebEditor.document.body.contentEditable = "true";
			eWebEditor.document.close();
			bEditMode = false;
			break;
		case "EDIT":
			eWebEditor.document.designMode = "On";
			eWebEditor.document.open();
			eWebEditor.document.write(config.StyleEditorHeader + html);
			eWebEditor.document.body.contentEditable = "true";
			eWebEditor.document.execCommand("2D-Position", true, true);
			eWebEditor.document.execCommand("MultipleSelection", true, true);
			eWebEditor.document.execCommand("LiveResize", true, true);
			eWebEditor.document.close();
			doZoom(nCurrZoomSize);
			bEditMode = true;
			eWebEditor.document.onselectionchange = function () { doToolbar(); }
			break;
		case "TEXT":
			eWebEditor.document.designMode = "On";
			eWebEditor.document.open();
			eWebEditor.document.write(config.StyleEditorHeader);
			eWebEditor.document.body.innerText = html;
			eWebEditor.document.body.contentEditable = "true";
			eWebEditor.document.close();
			bEditMode = false;
			break;
		case "VIEW":
			eWebEditor.document.designMode = "off";
			eWebEditor.document.open();
			eWebEditor.document.write(config.StyleEditorHeader + html);
			eWebEditor.document.body.contentEditable = "false";
			eWebEditor.document.close();
			bEditMode = false;
			break;
	}

	eWebEditor.document.body.onpaste = onPaste;
	eWebEditor.document.body.onhelp = onHelp;
	eWebEditor.document.onkeydown = new Function("return onKeyDown(eWebEditor.event?eWebEditor.event:eWebEditor.contentWindow.event);");
	if (window.HasActiveXObject) {
		eWebEditor.document.oncontextmenu = new Function("return showContextMenu(eWebEditor.event?eWebEditor.event:eWebEditor.contentWindow.event);");
	}
	if ((borderShown != "0") && bEditMode) {
		borderShown = "0";
		showBorders();
	}

	initHistory();
}

// 取编辑器的内容
function getHTML() {
	var html;
	if ((sCurrMode == "EDIT") || (sCurrMode == "VIEW")) {
		html = eWebEditor.document.body.innerHTML;
	} else {
		html = eWebEditor.document.body.innerText;
	}
	if (sCurrMode != "TEXT") {
		if ((html.toLowerCase() == "<p>&nbsp;</p>") || (html.toLowerCase() == "<p></p>")) {
			html = "";
		}
	}
	if (html == "<br>") { html = ""; }
	return html;
}

// 在尾部追加内容
function appendHTML(html) {
	if (isModeView()) return false;
	if (sCurrMode == "EDIT") {
		eWebEditor.document.body.innerHTML += html;
	} else {
		eWebEditor.document.body.innerText += html;
	}
}

// 从Word中粘贴，去除格式
function PasteWord() {
	if (!validateMode()) return;
	eWebEditor.focus();
	if (BrowserInfo.IsIE55OrMore) {
		insertHTML(GetClipboardHTML());
		convertPasteImgUrl();
	}
	else if (confirm("此功能要求IE5.5版本以上，你当前的浏览器不支持，是否按常规粘贴进行？")) {
		format("paste");
	}
	eWebEditor.focus();
}

// 粘贴纯文本
function PasteText() {
	if (!validateMode()) return;
	eWebEditor.focus();
	var sText = HTMLEncode(clipboardData.getData("Text"));
	insertHTML(sText);
	eWebEditor.focus();
}

// 检测当前是否允许编辑
function validateMode() {
	if (sCurrMode == "EDIT") return true;
	alert("需转换为编辑状态后才能使用编辑功能！");
	eWebEditor.focus();
	return false;
}

// 检测当前是否在预览模式
function isModeView() {
	if (sCurrMode == "VIEW") {
		alert("预览时不允许设置编辑区内容。");
		return true;
	}
	return false;
}

// 格式化编辑器中的内容
function format(what, opt) {
	var existserror = false;
	try {
		var r = eWebEditor.document.queryCommandEnabled(what);
		existserror = false;
	} catch (ex) {
		existserror = true;
	}
	if (what != "insertHTML") {
		var html = window.getHTML();
		switch (what) {
			case "InsertInputText":
				format("insertHTML", "<input type='text'>");
				return;
			case "InsertTextArea":
				format("insertHTML", "<textarea></textarea>");
				return;
			case "InsertInputRadio":
				format("insertHTML", "<input type='radio'>");
				return;
			case "InsertInputCheckbox":
				format("insertHTML", "<input type='checkbox'>");
				return;
			case "InsertSelectDropdown":
				format("insertHTML", "<select><option></select>");
				return;
			case "InsertButton":
				format("insertHTML", "<input type='button' value='新按钮'>");
				return;
			case "delete":
				format("insertHTML", "");
				return;
			case "cut":
				window.currCopyHtml = window.getHTML();
				format("insertHTML", "");
				return;
			case "copy":
				if (html) { window.currCopyHtml = html; }
				return;
			case "paste":
				if (window.currCopyHtml) { format("insertHTML", window.currCopyHtml); }
				return;
				/*case "RemoveFormat":
					if(html) {
						var div = document.createElement("div");
						div.innerHTML = html;
						format("insertHTML", div.innerText);
						div = null;
					}
					return;*/
			case "bold":
				if (html) { format("insertHTML", "<B>" + html + "</B>"); }
				return;
			case "italic":
				if (html) { format("insertHTML", "<i>" + html + "</i>"); }
				return;
			default:
				//alert(what)
				break;
		}
	}
	if (!validateMode()) return;
	EditAreaFocus();
	if (opt == "RemoveFormat") {
		what = opt;
		opt = null;
	}
	var docobj = eWebEditor.document;
	if (existserror == true) {
		IE11InsertHtml(opt);
		return;
	}
	if (opt == null) {
		var result = docobj.execCommand(what);
	}
	else {
		var result = docobj.execCommand(what, "", opt);
	}
	EditAreaFocus();
	return result;
}

function IE11InsertHtml(html) {
	var docobj = eWebEditor.document;
	var s = docobj.getSelection();
	if (s.rangeCount == 0) {
		s.addRange(docobj.createRange());
	}
	var r = s.getRangeAt(0);
	var obj = r.createContextualFragment(html);
	try {
		r.insertNode(obj);
	} catch (ex) {
		docobj.body.appendChild(obj);
	}
}

// 确保焦点在 eWebEditor 内
function VerifyFocus() {
	if (eWebEditor)
		EditAreaFocus();
}

// 改变模式：代码、编辑、文本、预览
function setMode(NewMode) {
	if (NewMode != sCurrMode) {

		if (!BrowserInfo.IsIE55OrMore) {
			if ((NewMode == "CODE") || (NewMode == "EDIT") || (NewMode == "VIEW")) {
				alert("HTML编辑模式需要IE5.5版本以上的支持！");
				return false;
			}
		}

		if (NewMode == "TEXT") {
			if (sCurrMode == ModeEdit.value) {
				if (!confirm("警告！切换到纯文本模式会丢失您所有的HTML格式，您确认切换吗？")) {
					return false;
				}
			}
		}

		var sBody = "";
		switch (sCurrMode) {
			case "CODE":
				if (NewMode == "TEXT") {
					eWebEditor_Temp_HTML.innerHTML = eWebEditor.document.body.innerText;
					sBody = eWebEditor_Temp_HTML.innerText;
				} else {
					sBody = eWebEditor.document.body.innerText;
				}
				break;
			case "TEXT":
				sBody = eWebEditor.document.body.innerText;
				sBody = HTMLEncode(sBody);
				break;
			case "EDIT":
			case "VIEW":
				if (NewMode == "TEXT") {
					sBody = eWebEditor.document.body.innerText;
				} else {
					sBody = eWebEditor.document.body.innerHTML;
				}
				break;
			default:
				sBody = ContentEdit.value;
				break;
		}

		// 换图片
		try {
			document.all["eWebEditor_CODE"].className = "StatusBarBtnOff";
			document.all["eWebEditor_EDIT"].className = "StatusBarBtnOff";
			document.all["eWebEditor_TEXT"].className = "StatusBarBtnOff";
			document.all["eWebEditor_VIEW"].className = "StatusBarBtnOff";
			document.all["eWebEditor_" + NewMode].className = "StatusBarBtnOn";
		}
		catch (e) {
		}

		sCurrMode = NewMode;
		ModeEdit.value = NewMode;
		setHTML(sBody);
		disableChildren(eWebEditor_Toolbar);

	}
}

// 使工具栏无效
function disableChildren(obj) {
	if (obj) {
		obj.disabled = (!bEditMode);
		for (var i = 0; i < obj.children.length; i++) {
			disableChildren(obj.children[i]);
		}
	}
}

function EditAreaFocus() {
	try {
		if (navigator.userAgent.indexOf("Edge") > 0 || navigator.userAgent.indexOf("Chrome") > 0) {
			eWebEditor.document.body.focus();
		} else {
			eWebEditor.focus();
		}
	} catch (e) { }
}

// 显示无模式对话框
function ShowDialog(url, width, height, optValidate) {
	if (optValidate) {
		if (!validateMode()) return;
	}
	if (url.indexOf("backimage.htm") > 0) { height = 240; }
	if (url.indexOf("fieldset.htm") > 0) { height = 220; }

	url = url + (url.indexOf("?") > 0 ? "&" : "?") + "timev=" + (new Date()).getTime();// 防止缓存
	EditAreaFocus();
	if (window.HasActiveXObject) {
		//IE模式，直接用对话框，性能更好；
		var arr = showModalDialog(url, window, "dialogWidth:" + width + "px;dialogHeight:" + height + "px;help:no;scroll:no;status:no");
		eWebEditor.focus();
		return;
	}
	var virpath = null;
	virpath = (top.sysCurrPath ? top.sysCurrPath : (top.virpath ? top.virpath : ""));
	if (top.location.href.toLowerCase().indexOf("sysn/") > 0) {
		virpath = virpath + "sysa/";
	}
	url = (virpath ? (virpath + "edit/") : "") + url + "&isdivModel=1";
	//非IE模式，用div模拟showModalDialog
	width = width + 10;
	height = height + 40;
	var doc = top.document;
	var dbody = doc.body ? doc.body : doc.documentElement;
	var w = dbody.clientWidth > 0 ? dbody.clientWidth : dbody.offsetWidth;
	var h = dbody.clientHeight;
	l = parseInt((w - width) / 2);
	t = parseInt((h - height) / 2);
	var div = doc.getElementById("eWebEditor_dlgdiv");
	if (!div) {
		bgdiv = doc.createElement("div");
		bgdiv.id = "eWebEditor_dlgdiv_bg";
		bgdiv.style.cssText = "z-index:900000;position:fixed;top:0px;left:0px;width:100%;height:100%;background-color:rgba(153,153,170,0.5)";
		div = doc.createElement("div");
		div.id = "eWebEditor_dlgdiv";
		dbody.appendChild(div);
		dbody.appendChild(bgdiv);
	}
	top.curreWebEditorFrame = eWebEditor;
	top.curreWebEditorFrame.GetCurrSession = window.GetCurrSession;
	top.curreWebEditorFrame.format = window.format;
	top.curreWebEditorFrame.setMode = window.setMode;
	top.curreWebEditorFrame.setHTML = window.setHTML;
	top.curreWebEditorFrame.getHTML = window.getHTML;
	top.curreWebEditorFrame.TableRowSplit = window.TableRowSplit;
	top.curreWebEditorFrame.TableColSplit = window.TableColSplit;
	top.curreWebEditorFrame.insertHTML = window.insertHTML;
	var tobj = window.selectedTable;
	if (tobj && tobj.tagName == "TBODY") { tobj = tobj.parentNode; }
	top.curreWebEditorFrame.selectedTable = tobj;
	top.curreWebEditorFrame.config = config;
	top.curreWebEditorFrame.parentDocument = document;
	top.curreWebEditorFrame.opener = eWebEditor.contentWindow.parent;
	top.curreWebEditorFrame.DefSessionExt = window.SessionExt;
	top.curreWebEditorFrame.divdlgClick = function () {
		top.document.getElementById("eWebEditor_dlgdiv_bg").style.display = "none";
		top.document.getElementById("eWebEditor_dlgdiv").style.display = "none";
	}
	div.innerHTML = "<div style='height:30px;margin:5px 5px 0px 5px'>"
					+ "<div id='eWebEditor_dlgdiv_title' style='color:#000;font-size:12px;float:left;padding:6px 0px 0px 6px;'>&nbsp;</div>"
					+ "<div id='eWebEditor_dlgdiv_btn' title='关闭' onclick='top.curreWebEditorFrame.divdlgClick()' onmouseout='this.style.backgroundColor=\"#8EA1C1\";this.style.borderColor=\"#6e81a1\"'"
					+ " onmouseover='this.style.backgroundColor=\"#E76E82\";this.style.borderColor=\"#B74e6e\"' "
					+ "style='line-height:15px;cursor:pointer;color:white;text-align:center;font-weight:bold;width:14px;height:14px;"
					+ "border-radius:8px;margin-top:3px;margin-right:5px;float:right;background-color:#8EA1C1;border:1px solid #6e81a1'>×</div>"
					+ "</div>"
					+ "<iframe onload='document.getElementById(\"eWebEditor_dlgdiv_title\").innerHTML=this.contentWindow.document.title' "
					+ "frameborder=0 src='" + url + "' style='background-color:buttonface;border-radius:3px;border:1px solid #609cba;margin:0px 5px 5px 5px;width:" + (width - 12) + "px;height:" + (height - 42) + "px'></iframe>"
	div.style.cssText = "z-index:1000000;position:fixed;left:" + l + "px;top:" + t + "px;width:" + width + "px;height:" + height + "px;"
						+ "border:1px solid #fff;background-color:#E3E7F0;border-radius:3px;-webkit-box-shadow: 0px 0px 15px;-moz-box-shadow:0px 0px 15px;box-shadow: 0px 0px 15px;";
	bgdiv.style.display = "block";
	var scrolltop = dbody.scrollTop;
	var scrollleft = dbody.scrollLeft;
	$(div).mousedown(
		function (e)//e鼠标事件 
		{
			$(this).css("cursor", "move");//改变鼠标指针的形状 
			var offset = $(this).offset();//DIV在页面的位置 
			var x = e.pageX - offset.left;//获得鼠标指针离DIV元素左边界的距离 
			var y = e.pageY - offset.top;//获得鼠标指针离DIV元素上边界的距离 
			$(doc).bind("mousemove", function (ev)//绑定鼠标的移动事件，因为光标在DIV元素外面也要有效果，所以要用doucment的事件，而不用DIV元素的事件 
			{
				$(".show").stop();//加上这个之后 
				var _x = ev.pageX - x - scrollleft;//获得X轴方向移动的值 
				var _y = ev.pageY - y - scrolltop;//获得Y轴方向移动的值 
				div.style.left = _x + "px";
				div.style.top = _y + "px";
			});
			$(doc).mouseup(
				function () {
					$(div).css("cursor", "default");
					$(this).unbind("mousemove");
				}
			);
		}
	);
}

// 全屏编辑
function Maximize() {
	if (!validateMode()) return;
	window.open("dialog/fullscreen.htm?style=" + config.StyleName, 'FullScreen' + sLinkFieldName, 'toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,fullscreen=yes');
}

// 创建或修改超级链接
function createLink() {
	if (!validateMode()) return;

	if (eWebEditor.document.selection.type == "Control") {
		var oControlRange = eWebEditor.document.selection.createRange();
		if (oControlRange(0).tagName.toUpperCase() != "IMG") {
			alert("链接只能是图片或文本");
			return;
		}
	}

	ShowDialog("dialog/hyperlink.htm", 350, 170, true);
}

// 替换特殊字符
function HTMLEncode(text) {
	text = text.replace(/&/g, "&amp;");
	text = text.replace(/"/g, "&quot;");
	text = text.replace(/</g, "&lt;");
	text = text.replace(/>/g, "&gt;");
	text = text.replace(/'/g, "&#146;");
	text = text.replace(/\ /g, "&nbsp;");
	text = text.replace(/\n/g, "<br>");
	text = text.replace(/\t/g, "&nbsp;&nbsp;&nbsp;&nbsp;");
	return text;
}

// 插入特殊对象
function insert(what) {
	if (!validateMode()) return;
	EditAreaFocus();
	var sel = eWebEditor.document.selection.createRange();

	switch (what) {
		case "excel":		// 插入EXCEL表格
			insertHTML("<object classid='clsid:0002E510-0000-0000-C000-000000000046' id='Spreadsheet1' codebase='file:\\Bob\software\office2000\msowc.cab' width='100%' height='250'><param name='HTMLURL' value><param name='HTMLData' value='&lt;html xmlns:x=&quot;urn:schemas-microsoft-com:office:excel&quot;xmlns=&quot;http://www.w3.org/TR/REC-html40&quot;&gt;&lt;head&gt;&lt;style type=&quot;text/css&quot;&gt;&lt;!--tr{mso-height-source:auto;}td{black-space:nowrap;}.wc4590F88{black-space:nowrap;font-family:宋体;mso-number-format:General;font-size:auto;font-weight:auto;font-style:auto;text-decoration:auto;mso-background-source:auto;mso-pattern:auto;mso-color-source:auto;text-align:general;vertical-align:bottom;border-top:none;border-left:none;border-right:none;border-bottom:none;mso-protection:locked;}--&gt;&lt;/style&gt;&lt;/head&gt;&lt;body&gt;&lt;!--[if gte mso 9]&gt;&lt;xml&gt;&lt;x:ExcelWorkbook&gt;&lt;x:ExcelWorksheets&gt;&lt;x:ExcelWorksheet&gt;&lt;x:OWCVersion&gt;9.0.0.2710&lt;/x:OWCVersion&gt;&lt;x:Label Style='border-top:solid .5pt silver;border-left:solid .5pt silver;border-right:solid .5pt silver;border-bottom:solid .5pt silver'&gt;&lt;x:Caption&gt;Microsoft Office Spreadsheet&lt;/x:Caption&gt; &lt;/x:Label&gt;&lt;x:Name&gt;Sheet1&lt;/x:Name&gt;&lt;x:WorksheetOptions&gt;&lt;x:Selected/&gt;&lt;x:Height&gt;7620&lt;/x:Height&gt;&lt;x:Width&gt;15240&lt;/x:Width&gt;&lt;x:TopRowVisible&gt;0&lt;/x:TopRowVisible&gt;&lt;x:LeftColumnVisible&gt;0&lt;/x:LeftColumnVisible&gt; &lt;x:ProtectContents&gt;False&lt;/x:ProtectContents&gt; &lt;x:DefaultRowHeight&gt;210&lt;/x:DefaultRowHeight&gt; &lt;x:StandardWidth&gt;2389&lt;/x:StandardWidth&gt; &lt;/x:WorksheetOptions&gt; &lt;/x:ExcelWorksheet&gt;&lt;/x:ExcelWorksheets&gt; &lt;x:MaxHeight&gt;80%&lt;/x:MaxHeight&gt;&lt;x:MaxWidth&gt;80%&lt;/x:MaxWidth&gt;&lt;/x:ExcelWorkbook&gt;&lt;/xml&gt;&lt;![endif]--&gt;&lt;table class=wc4590F88 x:str&gt;&lt;col width=&quot;56&quot;&gt;&lt;tr height=&quot;14&quot;&gt;&lt;td&gt;&lt;/td&gt;&lt;/tr&gt;&lt;/table&gt;&lt;/body&gt;&lt;/html&gt;'> <param name='DataType' value='HTMLDATA'> <param name='AutoFit' value='0'><param name='DisplayColHeaders' value='-1'><param name='DisplayGridlines' value='-1'><param name='DisplayHorizontalScrollBar' value='-1'><param name='DisplayRowHeaders' value='-1'><param name='DisplayTitleBar' value='-1'><param name='DisplayToolbar' value='-1'><param name='DisplayVerticalScrollBar' value='-1'> <param name='EnableAutoCalculate' value='-1'> <param name='EnableEvents' value='-1'><param name='MoveAfterReturn' value='-1'><param name='MoveAfterReturnDirection' value='0'><param name='RightToLeft' value='0'><param name='ViewableRange' value='1:65536'></object>");
			break;
		case "nowdate":		// 插入当前系统日期
			var d = new Date();
			insertHTML(d.toLocaleDateString());
			break;
		case "nowtime":		// 插入当前系统时间
			var d = new Date();
			insertHTML(d.toLocaleTimeString());
			break;
		case "br":			// 插入换行符
			insertHTML("<br>")
			break;
		case "code":		// 代码片段样式
			insertHTML('<table width=95% border="0" align="Center" cellpadding="6" cellspacing="0" style="border: 1px Dotted #CCCCCC; TABLE-LAYOUT: fixed"><tr><td bgcolor=#FDFDDF style="WORD-WRAP: break-word"><font style="color: #990000;font-weight:bold">以下是代码片段：</font><br>' + HTMLEncode(sel.text) + '</td></tr></table>');
			break;
		case "quote":		// 引用片段样式
			insertHTML('<table width=95% border="0" align="Center" cellpadding="6" cellspacing="0" style="border: 1px Dotted #CCCCCC; TABLE-LAYOUT: fixed"><tr><td bgcolor=#F3F3F3 style="WORD-WRAP: break-word"><font style="color: #990000;font-weight:bold">以下是引用片段：</font><br>' + HTMLEncode(sel.text) + '</td></tr></table>');
			break;
		case "big":			// 字体变大
			insertHTML("<big>" + sel.text + "</big>");
			break;
		case "small":		// 字体变小
			insertHTML("<small>" + sel.text + "</small>");
			break;
		default:
			alert("错误参数调用！");
			break;
	}
	sel = null;
}

// 显示或隐藏指导方针
var borderShown = config.ShowBorder;
function showBorders() {
	if (!validateMode()) return;
	var allForms = eWebEditor.document.body.getElementsByTagName("FORM");
	var allInputs = eWebEditor.document.body.getElementsByTagName("INPUT");
	var allTables = eWebEditor.document.body.getElementsByTagName("TABLE");
	var allLinks = eWebEditor.document.body.getElementsByTagName("A");

	// 表单
	for (a = 0; a < allForms.length; a++) {
		if (borderShown == "0") {
			allForms[a].style.border = "1px dotted #FF0000"
		} else {
			allForms[a].style.cssText = ""
		}
	}

	// Input Hidden类
	for (b = 0; b < allInputs.length; b++) {
		if (borderShown == "0") {
			if (allInputs[b].type.toUpperCase() == "HIDDEN") {
				allInputs[b].style.border = "1px dashed #000000"
				allInputs[b].style.width = "15px"
				allInputs[b].style.height = "15px"
				allInputs[b].style.backgroundColor = "#FDADAD"
				allInputs[b].style.color = "#FDADAD"
			}
		} else {
			if (allInputs[b].type.toUpperCase() == "HIDDEN")
				allInputs[b].style.cssText = ""
		}
	}

	// 表格
	for (i = 0; i < allTables.length; i++) {
		if (borderShown == "0") {
			allTables[i].style.border = "1px dotted #BFBFBF"
		} else {
			allTables[i].style.cssText = ""
		}

		allRows = allTables[i].rows
		for (y = 0; y < allRows.length; y++) {
			allCellsInRow = allRows[y].cells
			for (x = 0; x < allCellsInRow.length; x++) {
				if (borderShown == "0") {
					allCellsInRow[x].style.border = "1px dotted #BFBFBF"
				} else {
					allCellsInRow[x].style.cssText = ""
				}
			}
		}
	}

	// 链接 A
	for (a = 0; a < allLinks.length; a++) {
		if (borderShown == "0") {
			if (allLinks[a].href.toUpperCase() == "") {
				allLinks[a].style.borderBottom = "1px dashed #000000"
			}
		} else {
			allLinks[a].style.cssText = ""
		}
	}

	if (borderShown == "0") {
		borderShown = "1"
	} else {
		borderShown = "0"
	}

	scrollUp()
}

// 返回页面最上部
function scrollUp() {
	try { eWebEditor.scrollBy(0, 0); } catch (e) { }
}

// 缩放操作
var nCurrZoomSize = 100;
var aZoomSize = new Array(10, 25, 50, 75, 100, 150, 200, 500);
function doZoom(size) {
	if (navigator.userAgent.indexOf("Firefox") == -1) {
		eWebEditor.document.body.style.zoom = size + "%";
	} else {
		var v = (size / 100);
		eWebEditor.document.body.style.transform = "scale3d(" + v + "," + v + ",1)";
		eWebEditor.document.body.style.transformOrigin = "top left";
	}
	nCurrZoomSize = size;
}

// 拼写检查
function spellCheck() {
	ShowDialog('dialog/spellcheck.htm', 300, 220, true)
}

// 查找替换
function findReplace() {
	ShowDialog('dialog/findreplace.htm', 320, 165, true)
}

// 相对(absolute)或绝对位置(static)
function absolutePosition() {
	var objReference = null;
	var RangeType = eWebEditor.document.selection.type;
	if (RangeType != "Control" && window.NotIE == false) return;
	var selectedRange = eWebEditor.document.selection.createRange();
	for (var i = 0; i < selectedRange.length; i++) {
		objReference = selectedRange.item(i);
		if (objReference && objReference.style) {
			if (objReference.style.position != 'absolute') {
				objReference.style.position = 'absolute';
			} else {
				objReference.style.position = 'static';
			}
		}
	}
}

// 上移(forward)或下移(backward)一层
function zIndex(action) {
	var objReference = null;
	var RangeType = eWebEditor.document.selection.type;
	if (RangeType != "Control" && window.NotIE == false) return;
	var selectedRange = eWebEditor.document.selection.createRange();
	for (var i = 0; i < selectedRange.length; i++) {
		objReference = selectedRange.item(i);
		if (objReference && objReference.style) {
			var zi = objReference.style.zIndex * 1;
			if (action == 'forward') {
				objReference.style.zIndex = zi + 1;
			} else {
				objReference.style.zIndex = zi - 1;
			}
			objReference.style.position = 'absolute';
		}
	}
}

// 是否选中指定类型的控件
function isControlSelected(tag) {
	if (eWebEditor.document.selection.type == "Control" && window.NotIE == false) {
		var oControlRange = eWebEditor.document.selection.createRange();
		if (oControlRange(0).tagName.toUpperCase() == tag) {
			return true;
		}
	}
	return false;
}

// 改变编辑区高度
function sizeChange(size) {
	if (!BrowserInfo.IsIE55OrMore) {
		alert("此功能需要IE5.5版本以上的支持！");
		return false;
	}
	for (var i = 0; i < parent.frames.length; i++) {
		if (parent.frames[i].document == self.document) {
			var obj = parent.frames[i].frameElement;
			var height = parseInt(obj.offsetHeight);
			if (height + size >= 300) {
				obj.height = height + size;
				try { parent.parent.frameResize(size); } catch (e) { }
			}
			break;
		}
	}
}

// 热点链接
function mapEdit() {
	if (!validateMode()) return;

	var b = false;
	if (eWebEditor.document.selection.type == "Control") {
		var oControlRange = eWebEditor.document.selection.createRange();
		if (oControlRange(0).tagName.toUpperCase() == "IMG") {
			b = true;
		}
	}
	if (!b) {
		alert("热点链接只能作用于图片");
		return;
	}

	window.open("dialog/map.htm", 'mapEdit' + sLinkFieldName, 'toolbar=no,location=no,directories=no,status=not,menubar=no,scrollbars=no,resizable=yes,width=450,height=300');
}

// 上传文件成功返回原文件名、保存后的文件名、保存后的路径文件名，提供接口
function addUploadFile(originalFileName, saveFileName, savePathFileName) {
	doInterfaceUpload(sLinkOriginalFileName, originalFileName);
	doInterfaceUpload(sLinkSaveFileName, saveFileName);
	doInterfaceUpload(sLinkSavePathFileName, savePathFileName);
}

// 文件上传成功接口操作
function doInterfaceUpload(strLinkName, strValue) {
	if (strValue == "") return;

	if (strLinkName) {
		var objLinkUpload = parent.document.getElementsByName(strLinkName)[0];
		if (objLinkUpload) {
			if (objLinkUpload.value != "") {
				objLinkUpload.value = objLinkUpload.value + "|";
			}
			objLinkUpload.value = objLinkUpload.value + strValue;
			objLinkUpload.fireEvent("onchange");
		}
	}
}

// 大文件内容自动拆分
function splitTextField(objField, html) {
	var strFieldName = objField.name;
	var objForm = objField.form;
	var objDocument = objField.ownerDocument;
	objField.value = html;

	//表单限制值设定，限制值是102399，考虑到中文设为一半
	var FormLimit = 50000;

	// 再次处理时，先赋空值
	for (var i = 1; i < objDocument.getElementsByName(strFieldName).length; i++) {
		objDocument.getElementsByName(strFieldName)[i].value = "";
	}

	//如果表单值超过限制，拆成多个对象
	if (html.length > FormLimit) {
		objField.value = html.substr(0, FormLimit);
		html = html.substr(FormLimit);

		while (html.length > 0) {
			var objTEXTAREA = objDocument.createElement("TEXTAREA");
			objTEXTAREA.name = strFieldName;
			objTEXTAREA.style.display = "none";
			objTEXTAREA.value = html.substr(0, FormLimit);
			objForm.appendChild(objTEXTAREA);

			html = html.substr(FormLimit);
		}
	}
}

// 远程上传
function remoteUpload() {
	if (sCurrMode == "TEXT") return;

	var objField = document.getElementsByName("eWebEditor_UploadText")[0];
	splitTextField(objField, getHTML());

	divProcessing.style.top = (document.body.clientHeight - parseFloat(divProcessing.style.height)) / 2;
	divProcessing.style.left = (document.body.clientWidth - parseFloat(divProcessing.style.width)) / 2;
	divProcessing.style.display = "";
	eWebEditor_UploadForm.submit();
}

// 远程上传完成
function remoteUploadOK() {
	divProcessing.style.display = "none";

	if (oLinkField) {
		var oForm = oLinkField.form;
		oForm.doneAutoRemote++;
		if (oForm.doneAutoRemote >= oForm.submitEditor.length) {
			//doSubmit();
		}
	}
}

// 修正Undo/Redo
var history = new Object;
history.data = [];
history.position = 0;
history.bookmark = [];

// 保存历史
function saveHistory() {
	if (bEditMode) {
		if (history.data[history.position] != eWebEditor.document.body.innerHTML) {
			var nBeginLen = history.data.length;
			var nPopLen = history.data.length - history.position;
			for (var i = 1; i < nPopLen; i++) {
				history.data.pop();
				history.bookmark.pop();
			}

			history.data[history.data.length] = eWebEditor.document.body.innerHTML;
			if (eWebEditor.document.selection) {
				if (eWebEditor.document.selection.type != "Control") {
					history.bookmark[history.bookmark.length] = eWebEditor.document.selection.createRange().getBookmark();
				} else {
					var oControl = eWebEditor.document.selection.createRange();
					history.bookmark[history.bookmark.length] = oControl[0];
				}
			}
			if (nBeginLen != 0) {
				history.position++;
			}
		}
	}
}

// 初始历史
function initHistory() {
	history.data.length = 0;
	history.bookmark.length = 0;
	history.position = 0;
}

// 返回历史
function goHistory(value) {
	saveHistory();
	// undo
	if (value == -1) {
		if (history.position > 0) {
			eWebEditor.document.body.innerHTML = history.data[--history.position];
			setHistoryCursor();
		}
		// redo
	} else {
		if (history.position < history.data.length - 1) {
			eWebEditor.document.body.innerHTML = history.data[++history.position];
			setHistoryCursor();
		}
	}
}

// 设置当前书签
function setHistoryCursor() {
	if (history.bookmark[history.position]) {
		r = eWebEditor.document.body.createTextRange()
		if (history.bookmark[history.position] != "[object]") {
			if (r.moveToBookmark(history.bookmark[history.position])) {
				r.collapse(false);
				r.select();
			}
		}
	}
}
// End Undo / Redo Fix

// 工具栏事件发生
function doToolbar() {
	if (bEditMode) {
		saveHistory();
	}
}

//用于手动同步编辑器和表单中的隐藏文本框的内容 by cm
function syncText() {
	parent.document.getElementsByName(sLinkFieldName)[0].value = getHTML();
}

var winbodysize = function () {
	var tb = document.getElementsByTagName("table")[0]; //主table
	if (!tb) { return; }
	tb.rows[1].cells[0].style.height = (document.body.offsetHeight - tb.rows[0].cells[0].offsetHeight - tb.rows[2].cells[0].offsetHeight) + "px";
	if (window.IEVer < 10) {
		document.getElementById("eWebEditor").style.marginBottom = "-6px";
	}
	if (window.IEVer < 8) {
		document.documentElement.style.height = "99%";
	}
}
setTimeout(winbodysize, 300);
window.onresize = function () { winbodysize(); }