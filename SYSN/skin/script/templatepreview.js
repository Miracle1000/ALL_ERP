window.IsUseDocView = function () {
	if (window.location.href.indexOf("pdfview") == -1 && (!!window.ActiveXObject || "ActiveXObject" in window)) {
		return true;
	} else {
		return false;
	}
}

window.OnCTextBaseFieldHtml = function (field, html) {
    if (field.dbname == "@pdfboxdiv") {
    	if ( window.IsUseDocView() ) {
            html.push("<OBJECT id='docbox' classid='clsid:00460182-9E5E-11d5-B7C8-B8269041DD57' style='width:99%;height:600px;border:1px solid #aaa' CODEBASE='../../ocx/dsoframer.ocx#version=2,2,0,8'>");
			html.push("<param name='Titlebar' value='0'>")
			html.push("<param name='BorderStyle' value='0'>")
			html.push("<param name='FrameHookPolicy' value='1'>");
			html.push("</object>");
        }
    }
}

window.OnBillLoad = function () {
    var pdfUrl = window.PageInitParams[0].tag[0].value;
    var docUrl = window.PageInitParams[0].tag[1].value;
    if (window.IsUseDocView() ) {
        if (docUrl != "NO.doc") {
            // $("#pdfbox")[0].innerHTML=("<button onclick='window.ShowPrintDlg()'>打印</button><OBJECT id='docbox' classid='clsid:00460182-9E5E-11d5-B7C8-B8269041DD57' style='width:1000px;height:600px' CODEBASE='../../ocx/DSOframer.CAB#version=1,0,0,0'></object>");
            window.DocActiveXLoad(docUrl);
        }
        else {
            alert("没有找到您的模板文件，请上传模板文件后重试！");
        }
    }
    else {
        if (pdfUrl != "NO.pdf") {
            //alert("温馨提示：如果不能正常预览，请安装PDF阅读器后再来查看。");
            if ($('a.media').length > 0) {
                $('a.media').attr('href', "GetFileStream.ashx?type=pdf&url=" + pdfUrl + "");
            }
            else {
                $("div.media").find("iframe").attr('src', "GetFileStream.ashx?type=pdf&url=" + pdfUrl + "")
            }

            $('a.media').media({
                width: "100%",
                height: 600
            });
        }
        else {
            alert("没有找到您的模板文件，请上传模板文件后重试！");
        }
    }
}

window.ShowPrintDlg = function () {
	if ( window.IsUseDocView() ) {
        var f1 = document.getElementById("docbox").object;
        try{ f1.ShowDialog(4); } catch(ex){}
    }
    else {
        alert("非IE浏览器请点击下方预览中的打印按钮进行打印。");
    }
}

window.DocActiveXLoadFirst = true;
window.DocActiveXLoad = function (url) {
	window.lastvisitdocurl = url;
    try {
        setTimeout(function () {
            var f1 = document.getElementById("docbox").object;
            if (!f1) {
            	var url2 = window.location.href;
            	if (app.getIEVer() >= 9 && url2.indexOf("pdfview")==-1) {
            		window.location.href = window.location.href + "&pdfview=1";
            		return;
            	}
            	alert("Office组件加载失败，请您设置浏览器相关权限后重试。"); return;
            }
            if (window.DocActiveXLoadFirst == true) {
                f1.Menubar = false;
                f1.Toolbars = false;
                f1.EnableFileCommand(0) = false;
                f1.EnableFileCommand(1) = false;
                f1.EnableFileCommand(3) = false;
                f1.EnableFileCommand(4) = false;
                window.DocActiveXLoadFirst = false;
            } else {
                f1.Close();
            }
            setTimeout(function () {
            	f1.Open(window.location.href.toLowerCase().split('/sysn/')[0] + "/SYSN/view/comm/GetFileStream.ashx?type=doc&url=" + window.lastvisitdocurl + "", true, "Word.Document");
                try{f1.ActiveDocument.Protect(3, true, "asdasdads", false, true);}catch(ee){}
            }, 500);
        }, 500);
    } catch (ex) {
        alert(ex.message)
    }
}

window.DownloadFile = function (filename, fileurl) {
    if (fileurl != "NO.doc")
        window.location.href = "GetFileStream.ashx?type=doc&oldname=" + filename + "&url=" + fileurl;
    else
        alert("您没有设置任何模板！");
}

window.ExportExcelFile = function (filename, fileurl) {
    if (fileurl != "NO.xls")
        window.location.href = "GetFileStream.ashx?type=xls&oldname=" + filename + "&url=" + fileurl;
    else
        alert("您没有设置任何模板！");
}

var currId;
window.loadSignImage = function (box) {
    if (box.value != "" && box.value != "0") {
        document.getElementById("Hsignature").value = 0;
        document.body.appendChild(document.getElementById("dlgdiv"));
        document.getElementById("dlgdiv").style.display = "block";
        document.getElementById("dlgtit").innerHTML = "请输入" + box.options[box.selectedIndex].text + "的使用密码";
        document.getElementById("s_pwd").value = "";
        currId = box.value;
    }
    else {
        //隐藏域赋值
        document.getElementById("Hsignature").value = 0;
        document.getElementById("SureClick_btn").click();
    }
}
window.signPwdCheckfunction = function () {
    var pwd = document.getElementById("s_pwd").value;
    $.ajax({
        url: "../../../SYSA/setjm/signupload.asp?__msgid=ckpwd&id=" + currId + "&value=" + pwd + "&t=" + new Date().getTime(),
        type: 'GET',
        async: true,
        timeout: 3000,
        success: function (data) {
            if (data != 'ok') {
                document.getElementById("Hsignature").value = 0;
                alert(data);
            }
            else {
                document.getElementById("Hsignature").value = currId;
                document.getElementById("dlgdiv").style.display = "none";
                document.getElementById("SureClick_btn").click();
            }
        }
    })
}
window.cloase = function () {
    $("select[name='signature']").val("0");
    $("select[name='signature']").next(".select_dom").text($("select[name='signature'] option[selected]").attr('title'));
    document.getElementById("Hsignature").value = 0;
    document.getElementById("dlgdiv").style.display = "none"
}

window.templateSwitch = function (sel) {  
    app.ajax.regEvent("TemplateChange");
    app.ajax.addParam("selectID", sel.value);
    var circleCnt = 0;
    var printType = 0;
    var returnvalue = app.ajax.send();
    if (!(returnvalue == "" || returnvalue == undefined))
    {
        var n = returnvalue.split("|");
        if (n.length == 2) {
            circleCnt = n[0];
            printType = n[1];
        }
    }
    if (document.getElementsByName("circleCnt")[0]) { document.getElementsByName("circleCnt")[0].value = circleCnt; }
    if (document.getElementsByName("rule")[0]) { $("#rule_0").val(printType); $("#rule_0 + .select_dom").html($("#rule_0 option:selected").html()) }
}
