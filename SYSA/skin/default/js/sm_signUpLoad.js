
function check() {
	
    document.getElementsByName("data_name")[0].value = document.getElementsByName("data_name")[0].value.replace(/\"/g, "").replace(/\'/g, "");
    if (document.getElementsByName("data_name")[0].value.replace(/\s/g, "").length == 0) {
        app.Alert("请输入签章名称");
        document.getElementsByName("data_name")[0].focus();
        return false;
    }
    var pwbox = document.getElementsByName("data_password")[0];
    if (pwbox.value!="----------" && pwbox.value.replace(/[0-9]/g, "").replace(/[A-Z]/g, "").replace(/[a-z]/g, "").length > 0)
    {
        app.Alert("签章使用密码只能由数字和字母a-z组成。");
        pwbox.focus();
        return false;
    }
    if (pwbox.type!="hidden" && pwbox.value.replace(/\s/g, "").length == 0) {
        app.Alert("请输入签章使用密码");
        pwbox.focus();
        return false;
    }
	try{
		if (document.getElementsByName("data_path")[0].value.replace(/\s/g, "").length == 0 && document.getElementById("updatemessage").style.display == "none") {
			app.Alert("请选择需要上传的文件");
			document.getElementsByName("data_path")[0].focus();
			return false;
		}
	}
	catch(e){
		app.Alert("请选择需要上传的文件");
		return false;
	}
    var url = document.getElementsByName("data_path")[0].value;
    if (url.length > 0) {
        var typ = url.split(".");
        typ = typ[typ.length - 1].toLowerCase();
        if (typ != "jpg" && typ != "gif" && typ != "bmp" && typ != "png") {
            app.Alert("请选择正确的图片文件。\n\n目前支持的文件格式为 jpg、gif、bmp、png。  ")
            return false;
        }
        else {
            document.getElementsByName("data_type")[0].value = typ;
        }
    }
    return true;
}

window.onuploadComplete = function (msg) {
    if (isNaN(msg)) {
        try { top.app.Alert(msg); } catch (e) { app.Alert(msg); }
    }
    else {
        app.Alert("保存成功");
        document.forms[0].reset();
        lvw_refresh("signlvw");  //刷新列表
        document.getElementById("dlgdiv").style.display = "none";
    }
}

function ShowPic(id, title, pw) {  //显示预览 
	try{
		var div = top.document.getElementById("aaaaaaaaaa");
        if (!div) { div = top.document.createElement("div"); div.id = "aaaaaaaaaa"; top.document.body.appendChild(div); }
        var signlvw = top.document.getElementById("iframerows") || {};
        var signlvwPos = signlvw.getBoundingClientRect();
        var stop = (top.document.documentElement.scrollTop || top.document.body.scrollTop);
        var ttop = stop + (signlvwPos.top || 0);
        ttop = ttop >= 400 ? ttop : 400;
        div.style.cssText = "position:absolute;top:" + (ttop-400)+"px;width:600px;height:400px;left:20%;display:block;border:1px solid #b0b0c0;background-color:#FaFcFf;z-index:1000"
		var upath = (top.sysCurrPath ||   top.virpath ||  top.sys_verPath ||  top.SysConfig.VirPath );
		if(top.location.href.toLowerCase().indexOf("/sysn/")>0){
			upath = upath + "sysa/";
		}
		div.innerHTML = "<div align=right><button class='zb-button' onclick='top.document.getElementById(\"aaaaaaaaaa\").style.display=\"none\"'>关闭</button></div>" 
				+ "<table width='100%' height='375px'><tr><td align='center' style='height:375px;overflow:hidden;' valign='center'><img style='height:100%' onerror='this.outerHTML=\"加载公章图片失败。\"' src='" + upath + "sdk/getdata.asp?id=" + id + (pw?"&pw=" + ajax.UrlEncode(pw):"") + "'><br><br><br></td></tr></table>";
		//parent.document.body.appendChild(div);
	}catch(e){}
}

//添加界面
window.listview_onaddnew = function () {
    document.forms[0].reset();
    document.getElementById("dlgtit").innerText = "添加公章";
    document.getElementsByName("data_id")[0].value = 0;
    document.getElementsByName("data_password")[0].value = "";
    document.getElementById("updatemessage").style.display = "none";
    document.getElementById("dlgdiv").style.display = "block";
}

function ShowUpdateDiv(id,title) {
    document.forms[0].reset();

    document.getElementById("dlgtit").innerText = "修改公章";
    document.getElementsByName("data_name")[0].value = title;
    document.getElementsByName("data_password")[0].value = "----------";
    document.getElementsByName("data_password")[0].onfocus = function () { window.event.srcElement.select(); }
    document.getElementsByName("data_id")[0].value = id;
    document.getElementById("updatemessage").style.display = "inline";
    document.getElementById("dlgdiv").style.display = "block";
}

function DelPic(id, usetmode) {
    if (window.confirm("确定要删除吗？")) {
        ajax.regEvent("delpic");
        ajax.addParam("id", id);
        var r = ajax.send();
        if (r == "ok") {
            app.Alert("删除成功。");
			if(usetmode=="1") {
				//人名签章删除
				window.location.reload();
			}
			else {
				//公章删除
				lvw_refresh("signlvw");  //刷新列表
			}
        }
        else {
            app.Alert(r);
        }
    }
}