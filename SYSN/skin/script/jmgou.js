function CheckData(NT120Client, inputjmg, tishi) {
    try {
        //查找NT120锁
        var rtn = NT120Client.NTFind();
        if (rtn != 0) {
            tishi.children[0].innerHTML = "没有找到加密锁！";
            tishi.style.display = '';
            return false;
        }
    }
    catch (e) {
        inputjmg.innerHTML = "<a href='javascript:void(0)' onclick='OnlineSetup(inputjmg)'>在线安装NT插件</a>&nbsp;<a href='" + window.SysConfig.VirPath + "SYSA/ocx/NT120Client.exe'>下载插件安装</a>"//
        return false;
    }
    return true;
}
function OnlineSetup(inputjmg) {
    inputjmg.innerHTML = "<object CLASSID=clsid:EA3BA67D-8F11-4936-B01B-760B2E0208F6 CODEBASE='../../../SYSA/ocx/NT120Client.CAB#Version=1,00,0000' BORDER=0 VSPACE=0 HSPACE=0 ALIGN=TOP HEIGHT=0 WIDTH=0></object><input name='jmgpwd' type='password' class='login_1' oncopy='return false' oncut='return false' onpaste='return false'/><input id='guid' name='guid' type='hidden' /><input id='miyao' name='miyao' type='hidden' />"

}
function CheckPWD(jmgpwd, NT120Client, guid, miyao, tishi) {
    try {
        if (jmgpwd.value != "") {
            var rtn = NT120Client.NTFind();
            if (rtn != 0) {
                tishi.children[0].innerHTML = "没有找到加密锁！";
                tishi.style.display = '';
                return false;
            }
            else {
                var result = NT120Client.NTLogin(jmgpwd.value);
                if (result != 0) {
                    tishi.children[0].innerHTML = "加密锁密码错误！";
                    tishi.style.display = '';
                    return false;
                }
                else {
                    var GUID = NT120Client.NTGetHardwareID();
                    var Digesg = NT120Client.NTMD5(GUID);
                    guid.value = GUID;
                    miyao.value = Digesg;
                    return true;
                }
            }
        }
        else {
            tishi.children[0].innerHTML = "请输入加密锁密码！";
            tishi.children[0].style.display = '';
            return false;
        }
    }
    catch (e) {
        tishi.children[0].innerHTML = "加密锁组件加载失败！";
        tishi.style.display = '';
        return false;
    }
}
function SetJmgPWD(jmgpwdold, NT120Client, jmgpwdnew, tishi) {
    try {
        if (jmgpwdold.value != "" && jmgpwdnew.value != "") {
            var rtn = NT120Client.NTFind();
            if (rtn != 0) {
                tishi.children[0].innerHTML = "没有找到加密锁！";
                tishi.style.display = '';
                return false;
            }
            else {
                var result = NT120Client.NTLogin(jmgpwdold.value);
                if (result != 0) {
                    tishi.children[0].innerHTML = "登录加密锁密码错误！";
                    tishi.style.display = '';
                    return false;
                }
                else {

                    var ret = NT120Client.NTSetUserPin(jmgpwdnew.value);
                    if (ret != 0) {
                        tishi.children[0].innerHTML = "加密锁组件加载失败！";
                        tishi.style.display = '';
                        return false;
                    }
                }
            }
        }
        else {
            tishi.children[0].innerHTML = "请输入加密锁密码！";
            tishi.style.display = '';
            return false;
        }
    }
    catch (e) {
        tishi.children[0].innerHTML = "加密锁组件加载失败！";
        tishi.style.display = '';
        return false;
    }
    return true;
}
function CheckJmgOnline(NT120Client, jmgpwd) {
    try {
        //查找NT120锁
        //top.document.title=(new Date()).getTime();
        var rtn = NT120Client.NTFind();
        if (rtn != 0) {
            //没有找到加密锁！;
            hWnds.DisableWindow();
            var curwin = hWnds.FindActiveWindow();
            setTimeout(DialogFun("-5", curwin, 1), 500);//未检测到加密锁
        }
        else {
            var result = NT120Client.NTLogin(jmgpwd);
            if (result != 0) {
                //登录加密锁密码错误！;
                hWnds.DisableWindow();
                var curwin = hWnds.FindActiveWindow();
                setTimeout(DialogFun("-6", curwin, 1), 500);//检测加密锁不匹配
            }
            else {
                //验证通过
                if (document.getElementById("sTimeroutAlertDiv")) {
                    document.getElementById("sTimeroutAlertDiv").style.display = "none";
                }
                hWnds.EnableWindow();
                setTimeout("CheckJmgOnline(NT120Client,jmgpwd)", 6000);
            }
        }
    }
    catch (e) {
        hWnds.DisableWindow();
        var curwin = hWnds.FindActiveWindow();
        setTimeout(DialogFun("-5", curwin, 1), 500);//未检测到加密锁
    }
}
function CheckJMGLogin(NT120Client, pwdstr) {
    if (NT120Client) {
        try {
            //查找NT120锁
            var rtn = NT120Client.NTFind();
            if (rtn != 0) {
                alert("没有找到加密锁！");
                top.window.location.href = window.SysConfig.VirPath + "sysn/view/init/login.ashx";
            }
            else {
                var result = NT120Client.NTLogin(pwdstr);
                if (result != 0) {
                    alert("加密锁密码错误！");
                    top.window.location.href = window.SysConfig.VirPath + "sysn/view/init/login.ashx";
                }
            }
        }
        catch (e) {
            alert("没有找到加密锁！");
            top.window.location.href = window.SysConfig.VirPath + "sysn/view/init/login.ashx";
        }
    }
}