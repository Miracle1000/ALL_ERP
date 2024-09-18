

function getEditorBody(){
	if(parent.window.editor){
		if(parent.window.editor.editorBody){
			return parent.window.editor.editorBody;
		}else{
			return false;
		}
	}else{
		return false;
	}
}

function getEditorRange(){
	if(parent.window.editor){
		if(parent.window.editor.editorRange){
			return parent.window.editor.editorRange;
		}else{
			return false;
		}
	}else{
		return false;
	}
}

var SpanExp = /<SPAN( class="*CtrlData"*| contentEditable="*false"*| unselectable="*on"*| dbname="*\d+.\w+"*){4}>[a-zA-Z_0-9\u4e00-\u9fa5]+<\/SPAN>/g;

function ReplaceData(){//--标签替换，并返回隐藏选区
	var hidEditor = document.getElementById("HiddenEditorBody");
	hidEditor.focus()
	var hidRange = document.selection.createRange();//==创建选区
	var editorRange = getEditorRange();
	hidEditor.innerHTML = editorRange.htmlText;//==获取原选区内容
	//window.EditorSpan = hidEditor.innerHTML.match(SpanExp);
	//hidEditor.innerHTML = hidEditor.innerHTML.replace(/<img>/g,"");
	//hidEditor.innerHTML = hidEditor.innerHTML.replace(SpanExp,"<img>");
	return hidRange;
}
function RestoreData(){
	var EditorSpan = window.EditorSpan;
	var hidEditor = document.getElementById("HiddenEditorBody");
	html = hidEditor.innerHTML;
	if(EditorSpan){
		for(var i = 0; i < EditorSpan.length; i++){
			if(html.match(/<(img|IMG)>/)){
				html = html.replace(/<(img|IMG)>/,EditorSpan[i])
			}
		}
		hidEditor.innerHTML = html;
	}
}

function Bold(){//--粗体
	var myEditer = getEditorBody()
	if(myEditer){
//		var hidRange = ReplaceData();
//		hidRange.select();
//		hidRange.execCommand("Bold");
//		var editorRange = getEditorRange();
//		editorRange.select();
//		editorRange.pasteHTML( document.getElementById("HiddenEditorBody").innerHTML )
		myEditer.focus();
		parent.document.execCommand("Bold");
	}
}

function Italic(){//--斜体
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("Italic");
	}
}

function Underline(){//--下划线
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("Underline");
	}
}

function StrikeThrough(){//--删除线
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("StrikeThrough");
	}
}

function fontFamily(input){//--字体
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("fontname","",input.value);
	}
}

function fontSize(input){//--字号
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("fontsize","",input.value);
	}
}

function fontBlock(input){//--段落
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("FormatBlock","",input.value);
	}
}

function Olist(){//--有序列表
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("InsertOrderedList");
	}
} 

function Ulist(){//--无序列表
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("InsertUnorderedList");
	}
}

function Indent(){//--增加缩进
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("Indent");
	}
}

function Outdent(){//--减少缩进
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("Outdent");
	}
}

function sp(){//--上标
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("SuperScript");
	}
}

function sb(){//--下标
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("SubScript");
	}
}

function LText(){//--居左
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("JustifyLeft");
	}
}

function RText(){//--居右
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("JustifyRight");
	}
}

function CText(){//--居中
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("JustifyCenter");
	}
}

function FText(){//--两端对齐
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("JustifyFull");
	}
}

function Cut(){//--剪切
	var myEditer = getEditorBody()
	if(myEditer){
		parent.document.execCommand("Cut");
	}
}

function Copy(){//--复制
	var myEditer = getEditorBody()
	if(myEditer){
		parent.document.execCommand("Copy");
	}
}

function Paste(){//--粘贴
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("Paste");
	}
}

function Undo(){//--撤销
	var myEditer = getEditorBody()
	if(myEditer){
		parent.document.execCommand("Undo");
	}
}

function Redo(){//--重做
	var myEditer = getEditorBody()
	if(myEditer){
		parent.document.execCommand("Redo");
	}
}

function RemoveFormat(){//--移除格式
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		parent.document.execCommand("RemoveFormat");
	}
}


