function SetFinanceQCBody(dbname) {
    var ary = ["+", "-", "*", "/", "(", ")"];
    var win = app.createWindow(dbname + "_formula", "期初现金金额设置", { closeButton: true, height: 530, width: 560, top: 20, canMove: true });
    win.innerHTML = "<table><tr><td colspan='2'><div id='top_items' style='position:relative;height:76px;overflow: auto;width: 100%;border:1px solid #CCC'></div></td></tr><tr><td><iframe id='chooseIframe' style='height:393px;border:1px solid #b6c0c9;' src='" + window.SysConfig.VirPath + "SYSN/view/finan/finance/Settings/GetFinanceInfo.ashx?cashflow=0'></iframe></td><td valign='top'><div id='right_items'>" + addItem(ary) + "</div><div style='text-align: center;height:40px;line-height: 40px;clear: both'><button class='zb-button' onclick=\"GetFormula('"+ dbname +"')\">确认</button><button class='zb-button' onclick=\"app.closeWindow('"+dbname + "_formula',true)\">取消</button></div></td></tr></table>";
    win.style.overflow = "hidden";
    setTimeout(function () {
        var ifr = document.getElementById('chooseIframe').contentWindow.document;
        $(ifr).on("mouseup", function () {
            var ele = document.getElementById("movingItemDiv");
            $(ele).remove();
        })
    }, 1000)

    var e = window.event.target || window.event.srcElement;
    if (e.value == "") return;
    var arr = computValueStr(e.value);
    for (var i = 0; i < arr.length; i++) {
        var cur = arr[i];
        addItemsToTop(cur);
    }
}

function GetFormula(dbname) {
    var v = document.getElementById("top_items").getAttribute("true_value") || "";
    $("#" + dbname + "_0").val(v.replace(/,/g, ""));
    app.closeWindow(dbname + "_formula", true)
}

function SetFinanceReport(rowindex, dbname, lvwDbname, ary) {
    var e = window.event.target || window.event.srcElement;
    rowindex = e.id.split('_')[3];
    window.SetFinanceReportObjDbname = dbname;
    window.SetFinanceReportObjRowIndex = rowindex;
    window.SetFinanceReportObjLvwDbname = lvwDbname;
    var lvw = window["lvw_JsonData_" + lvwDbname];
    var rows = lvw.rows;
    var arr1 = [];
    for (var i = 0; i < rows.length; i++) {
        if (i == rows.length - 1)break;
        arr1.push("H" + (i + 1));
    };
    var arr2 = ["+", "-", "*", "/", "(", ")"];
    var isCashFlow = "0";
    if (ary.arry.length < 5) { isCashFlow = "1"; }
    ary = ary.arry.concat(arr1, arr2);
    var win = app.createWindow("FinanceReport", "报表公式设置", { closeButton: true, height: 530, width: 700, top: 20, canMove: true });
    win.innerHTML = "<table><tr><td colspan='2'><div id='top_items' style='position:relative;height:76px;overflow: auto;width: 100%;border:1px solid #CCC'></div></td></tr><tr><td><iframe id='chooseIframe' style='height:393px;border:1px solid #b6c0c9;' src='" + window.SysConfig.VirPath + "SYSN/view/finan/finance/Settings/GetFinanceInfo.ashx?cashflow=" + isCashFlow + "'></iframe></td><td valign='top'><div id='right_items'>" + addItem(ary) + "</div><div style='text-align: center;height:40px;line-height: 40px;clear: both'><button class='zb-button' onclick='getFinaSetsaveData()'>确认</button><button class='zb-button' onclick=\"app.closeWindow('FinanceReport',true)\">取消</button></div></td></tr></table>";
    win.style.overflow = "hidden";
    setTimeout(function () {
        var ifr=document.getElementById('chooseIframe').contentWindow.document;
        $(ifr).on("mouseup",function () {
            var ele= document.getElementById("movingItemDiv");
            $(ele).remove();
        })
    },1000)

    if(e.value=="")return;
    var arr=computValueStr(e.value);
    for(var i=0;i<arr.length;i++){
        var cur=arr[i];
        addItemsToTop(cur);
    }

}
function  computValueStr(str) {//根据文本框的值，生成相应的数组，用于在弹层中展示
    var reg=/[\+\-\*\/\(\)]/;
    var ary=str.split("");
    var arr=[];
    var a=[];
    for(var i=0;i<ary.length;i++){
        var cur=ary[i];
        if(reg.test(cur)){
            if(arr.length>0){
                a.push(arr.join(""),cur);
                arr=[];
            }else{
                a.push(cur);
            }

        }else{
            arr.push(cur)
        }
        if(i==ary.length-1&&arr.length>0){
            a.push(arr.join(""));
        }
    }
    return a;
}
function getFinaSetsaveData() {//点击确定的时候，给相应的文本框赋值
    var dbname = window.SetFinanceReportObjDbname;
    var rowIndex = window.SetFinanceReportObjRowIndex;
    var id = window.SetFinanceReportObjLvwDbname;
    var v = document.getElementById("top_items").getAttribute("true_value")||"";
    var lvw = window["lvw_JsonData_" + id];
    var headers = lvw.headers;
    var cellindex;
    for (var i = 0; i < headers.length; i++) {
        var cur = headers[i];
        if (cur.dbname == dbname) {
            cellindex = i
        }
    }
    lvw.rows[rowIndex][cellindex] = v.replace(/,/g,"");
    ___RefreshListViewByJson(lvw);
    app.closeWindow('FinanceReport', true)
}
function addItem(ary) {//往左下角添加数据
    var str = "<div>";
    for (var i = 0; i < ary.length; i++) {
        var cur = ary[i];
        var w = comutItemWidth(cur);
        str += "<div  style='width:" + w + "px;height:30px;padding:0 3px;text-align: center;line-height: 30px;float:left;border:1px solid #CCC;margin:3px;cursor: pointer' onclick='addItemsToTop(this.innerHTML)'>" + cur + "</div>"
    }
    str += "</div>";
    //  document.getElementById("right_items").innerHTML=str;
    return str
}
function addItemsToTop(cur) {//点击左下角的方格,往上面的div添加数据
    var div = document.getElementById("top_items");

    var v = div.getAttribute("true_value") || "";
    v += ","+cur;
    if(v.indexOf(",")==0){
        v=v.replace(",","");
    }
    div.setAttribute("true_value", v);
    var ary=v.split(",");
    var str="";
    for(var i=0;i<ary.length;i++){
        cur=ary[i];
        var w = comutItemWidth(cur);
      str += "<div index='"+i+"' true_value='"+cur+"' onmousedown='setFinItemReadyMove(this)' onmousemove='setFinItemMove(this)' onmouseup='setFinItemStopMove(this)' onmouseover=\"$(this).find('span').show()\" onmouseout=\"$(this).find('span').hide()\" style='width:" + w + "px;position:relative;height:30px;padding:0 3px;text-align: center;line-height: 30px;float:left;border:1px solid #CCC;margin:3px;cursor: pointer'>" + cur + "<span true_value='"+v+"' txt='"+cur+"' onclick='refreshTopItems(this)' index='"+i+"' style='display: none;position: absolute;top:-9px; right:2px;color:#FF1427;'>✖</span></div>"
    }
    div.innerHTML = str
}
function setFinItemReadyMove(box) {//准备移动
    box.setAttribute("ready_move","1");
    box.setAttribute("moving","");
    window.appendedNode=0;
}
function setFinItemMove(box) {//移动
    var ready=box.getAttribute("ready_move");
    if(ready){
        var div = document.getElementById("top_items");
        box.setAttribute("moving","1");
        var v = div.getAttribute("true_value") || "";
        var w=$(div).width();
        var h=76;
        var pObj=div.getBoundingClientRect();
        var l=pObj.left;
        var t=pObj.top;
        if(!window.appendedNode){
            var n=$(box).clone();
            window.appendedNode=1;
        var e=window.event;
        var x=e.clientX-$(box).width()/2;
        var y=e.clientY-15;
        n.css({
            "position":"absolute",
            "backgroundColor":"rgba(28,255,255,0.3)",
            "left":x,
            "top":y,
            "zIndex":100000,
            "cursor":"move"
        });
        n[0].id="movingItemDiv";
        n[0].removeAttribute("onmousedown");
        n[0].removeAttribute("onmousemove");
        n[0].removeAttribute("onmouseup");
        n[0].removeAttribute("onmouseout");
        n[0].removeAttribute("onmouseover");
        $("body").append(n);
        }
    }
}
function setFinItemStopMove(box) {//停止移动
    var moving=box.getAttribute("moving","");
    if(moving){

    }
    box.setAttribute("ready_move","");
}
function refreshTopItems(box) {//删除上面的项
    var txt=box.getAttribute("txt");
    var index=box.getAttribute("index");
    var trueV=box.getAttribute("true_value");
    var div = document.getElementById("top_items");
    div.setAttribute("true_value","");
    div.innerHTML="";
    var ary=trueV.split(",");
    for(var i=0;i<ary.length;i++){
        var cur=ary[i];
        if(i==index){
           continue
        }
        addItemsToTop(cur)
    }
}
function comutItemWidth(str) {
    var ary = str.split("");
    var num = 6;
    for (var i = 0; i < ary.length; i++) {
        var cur = ary[i];
        if (/[\u3002|\uff1f|\uff01|\uff0c|\u3001|\uff1b|\uff1a|\u201c|\u201d|\u2018|\u2019|\uff08|\uff09|\u300a|\u300b|\u3008|\u3009|\u3010|\u3011|\u300e|\u300f|\u300c|\u300d|\ufe43|\ufe44|\u3014|\u3015|\u2026|\u2014|\uff5e|\ufe4f|\uffe5]/.test(cur) || /[\u4e00-\u9fa5]/.test(cur)) {
            //一个汉字和一个汉字标点都是14px；
            num += 15
        } else {
            //一个英文或一个英文标点都是7px；
            num += 8;
        }
    }
    return num < 30 ? 30 : num
}
$(function () {//给body绑定事件，用于小方块的拖拽
    $("body").on("mousemove",function (e) {
        e=e||window.event;
        var tag=e.target||e.srcElement;
        var ele=document.getElementById("movingItemDiv");
        if(ele){
            var div = document.getElementById("top_items");
            var ary=(div.getAttribute("true_value")||"").split(",");
            if(ary.length==1){return}
            var w=$(div).width();
            var h=76;
            var pObj=div.getBoundingClientRect();
            var l=pObj.left;
            var t=pObj.top;
            var ew=$(ele).width();
            var ex=e.clientX-ew/2;
            var ey=e.clientY-15;
            var nL=ex;
            var nT=ey;
            if(nL+ew+13>l+w){nL=l+w-ew-13}
            if(nL<l){nL=l}
            if(nT+30+6>t+h){nT=t+h-30-6}
            if(nT<t){nT=t}
            $(ele).css({
                left:nL,
                top:nT
            })
            document.body.onselectstart = document.body.ondrag = function () {
                return false;
            }
        }
    });
    $(document).on("mouseup", function (e) {
        var ele = document.getElementById("movingItemDiv");
        document.body.onselectstart = document.body.ondrag = function () { }
        if (ele) {
            var div = document.getElementById("top_items");
            var wids=$(ele).width();
            var txt=ele.getAttribute("true_value");
            var index=ele.getAttribute("index");
            var v = div.getAttribute("true_value") || "";
            e = e || window.event;
            var ex = e.clientX;
            var ey = e.clientY;
            var ary = v.split(",");
            var len=ary.length;
            if(ary.length>1){
                var arr = [];
                var pObj=div.getBoundingClientRect();
                var w=$(div).width();
                var l=pObj.left;
                var t=pObj.top;
                var num={w:0,h:1};
                ary.splice(index,1);
                for (var i = 0; i < ary.length; i++) {
                    var cur = ary[i];
                    var obj={
                        txt: cur,
                        w: comutItemWidth(cur) + 6
                    };
                    num.w+=obj.w;
                    var x;
                    if(i==0){x=l}
                    else{x=l+arr[i-1].w}
                    if(x>l+w){
                        x=l;
                        num.w=0;
                        num.h+=1
                    }
                    var y=33*(num.h)+t;
                    obj.x=x;
                    obj.y=y;
                    arr.push(obj);
                };
             for(var i=0;i<arr.length;i++){
                 var cur=arr[i];
                 if(cur.y+30>ey){//此时锁定要替换的行
                     if(cur.x<=ex&&cur.x+wids>=ex){
                         var c=ary[i];
                         ary.splice(i,0,txt);
                         break;
                     }else if(cur.x>=ex&&cur.x>=ex-wids){
                         var c=ary[i];
                         ary.splice(i,0,txt);
                         break;
                     }
                 }
             }
                if(ary.length<len){
                    ary.splice(ary.length,0,txt)
                }
                div.setAttribute("true_value","");
                div.innerHTML="";
                for(var i=0;i<ary.length;i++){
                    var cur=ary[i];
                    addItemsToTop(cur)
                }
            }

            $(ele).remove();
        }
    });

})
