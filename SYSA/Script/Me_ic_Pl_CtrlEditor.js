
function EditorStyle(){//--
	myEditer.document.body.style.margin = "0px";
	myEditer.document.body.style.padding = "5px";
	myEditer.document.body.style.fontSize = "12px";
	myEditer.document.body.style.lineHeight = "2em";
}

function Bold(){//--粗体
myEditer.focus();
myEditer.document.execCommand("Bold")
}

function Italic(){//--斜体
myEditer.focus();
myEditer.document.execCommand("Italic")
}

function Underline(){//--下划线
myEditer.focus();
myEditer.document.execCommand("Underline")
}

function StrikeThrough(){//--删除线
myEditer.focus();
myEditer.document.execCommand("StrikeThrough")
}

function fontFamily(input){//--字体
myEditer.focus();
myEditer.document.execCommand("fontname","",input.value)
}

function fontSize(input){//--字号
myEditer.focus();
myEditer.document.execCommand("fontsize","",input.value)
}

function fontBlock(input){//--段落
myEditer.focus();
myEditer.document.execCommand("FormatBlock","",input.value)
}

function Olist(){//--有序列表
myEditer.focus();
myEditer.document.execCommand("InsertOrderedList")
} 

function Ulist(){//--无序列表
myEditer.focus();
myEditer.document.execCommand("InsertUnorderedList")
}

function Indent(){//--增加缩进
myEditer.focus();
myEditer.document.execCommand("Indent")
}

function Outdent(){//--减少缩进
myEditer.focus();
myEditer.document.execCommand("Outdent")
}

function sp(){//--上标
myEditer.focus();
myEditer.document.execCommand("SuperScript")
}

function sb(){//--下标
myEditer.focus();
myEditer.document.execCommand("SubScript")
}

function LText(){//--居左
myEditer.focus();
myEditer.document.execCommand("JustifyLeft")
}

function RText(){//--居右
myEditer.focus();
myEditer.document.execCommand("JustifyRight")
}

function CText(){//--居中
myEditer.focus();
myEditer.document.execCommand("JustifyCenter")
}

function FText(){//--两端对齐
myEditer.focus();
myEditer.document.execCommand("JustifyFull")
}

function Cut(){//--剪切
myEditer.document.execCommand("Cut")
}

function Copy(){//--复制
myEditer.document.execCommand("Copy")
}

function Paste(){//--粘贴
myEditer.focus();
myEditer.document.execCommand("Paste")
}

function Undo(){//--撤销
myEditer.document.execCommand("Undo")
}

function Redo(){//--重做
myEditer.document.execCommand("Redo")
}

function RemoveFormat(){//--移除格式
myEditer.document.execCommand("RemoveFormat")
}

