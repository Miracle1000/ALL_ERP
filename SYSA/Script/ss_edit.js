
<!--
    function MM_jumpMenu(targ, selObj, restore) { //v3.0
        eval(targ + ".location=\'" + selObj.options[selObj.selectedIndex].value + "\'");
        if (restore) selObj.selectedIndex = 0;
    }

    function setEnable(id, isStop) {
        if (document.getElementById("sID"+id).value=="停用") {
            if (!confirm("停用可能影响该类型对应的单据!是否继续操作?")) { return false; };
        }
        if (id.length == 0) { return false; };
        var url = "setPUEnable.asp?id=" + id + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
        xmlHttp.open("GET", url, false);
        xmlHttp.onreadystatechange = function () {
            refState(id);
        };
        xmlHttp.send(null);
    }
    function refState(id) {
        var objTD = document.getElementById("tdID" + id);
        var objBT = document.getElementById("sID" + id);
        if (xmlHttp.readyState < 4) {
            objTD.innerHTML = "loading...";
        }
        if (xmlHttp.readyState == 4) {
            var response = xmlHttp.responseText;
            objTD.innerHTML = response;
            if (response.indexOf("启用")>= 0) {
                objBT.value = "停用";
            }
            else {
                objBT.value = "启用";
            }
            
            xmlHttp.abort();
        }
    }
//-->


