<%@ Page Language="C#" AutoEventWireup="true" %><!DOCTYPE html>
<html style='padding:0px;margin:0px;'>
<head>
<!--[if gte IE 10]>
<script language='javascript'>
top.IsIE10 = true;
</script>
<![endif]-->
<!--[if gte IE 11]>
<script language='javascript'>
top.IsIE10 = true;
</script>
<![endif]-->
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" id='cFF'/>
<title id='I1'></title><!--title ID为 I1有特殊用途，勿删-->
<% 
	string sk = ZBServices.SystemInfoClass.AppVersion.Replace(".", "").Replace("_", "").Replace(")", "").Replace(" ", "");
	Response.Cookies.Remove("ZBNETU");
%>
<link type="text/css" href="../../SYSA/skin/default/css/defaultaspx.css?ver=10230220601" rel="stylesheet">
<script>window.curruserid="<%=ZBServices.SessionInfoClass.CurrUserID%>";</script>
<script type="text/JavaScript" src="../inc/jquery-1.4.2.min.js?ver=<%=sk%>"></script>
<script type="text/JavaScript" src="../skin/default/js/comm.js?ver=<%=sk%>"></script>
<script type="text/javascript" src='default.js?ver=<%=sk%>'></script>
</head>
<script type="text/JavaScript">
	var zoomcss = "";
	window.CurrPageZoom = parent.UserInfo ? parent.UserInfo.Zoom : 1;
	if (window.parent != window) {
		if (window.parent.app && window.parent.app.IeVer >= 100) {
			window.CurrPageZoom = (window.parent.document.body.style.zoom || 1) * 1;
			if (window.CurrPageZoom != 1) {
				document.write("<style>html{zoom:" + window.CurrPageZoom + "}</style>");
			}
		}
	}
	document.write("<body onresize='pageload()' onscroll='document.body.scrollTop=\"0px\"' " + zoomcss + ">");
	//阻止事件冒泡
	function stopPop(e) {
	    var e = e || window.event;
	    e.stopPropagation ? e.stopPropagation() : window.event.cancelBubble = true;
	}

    //导航面板隐藏
	$('#navPanelMask').live('click', function () { $(this).hide()})
</script>
<table id='frame-body'>
<tr>
    <%
        if (ZBServices.SystemInfoClass.SystemType == ZBServices.SystemTypeEnum.SystemMoZi)
        {
    %>
	       <td style='width:230px;transition:width 0.3s'  id='mleftbody' valign='top'>
    <%
        }
        else { 
    %>
           <td style='width:212px;'  id='mleftbody' valign='top'>
    <%
        }
    %> 
    <%
        if (ZBServices.SystemInfoClass.SystemType == ZBServices.SystemTypeEnum.SystemMoZi)
        {
            Response.Write("  <iframe src='leftmenu.html?v=20210423' onload='closeproc()' name='leftFrame' frameborder='no' scrolling='No' noresize=true id='leftFrame'></iframe>");
        }
        else
        {
            Response.Write("  <iframe src='leftmenu.html?20220519' onload='closeproc()' name='leftFrame' frameborder='no' scrolling='No' noresize=true id='leftFrame'></iframe>");
        }
    %>
	   </td>
    <%
        if (ZBServices.SystemInfoClass.SystemType == ZBServices.SystemTypeEnum.SystemMoZi)
        {
    %>
	        <td style='width:1px;background-color:#ccc;'  valign='top'  class="disselect"  id='borderFrame'>
    <%
        }
        else { 
    %>
            <td style='width:0px;background-color:#3085cb;'  valign='top'  class="disselect"  id='borderFrame'>
    <%
        }
    %> 
    <%
        if (ZBServices.SystemInfoClass.SystemType != ZBServices.SystemTypeEnum.SystemMoZi)
        {
    %>
	        <div id='borderFramedivbg' style="display:none">&nbsp;</div>
	        <div id='borderFramediv' style="display:none" ondblclick='if(this.offsetHeight > (event.offsetY + 30)){return;} try{document.getElementById("mainFrame").contentWindow.document.body.oncontextmenu=null}catch(e){}'>&nbsp;</div>
	        <img src="../skin/default/images/btn_left.gif" id="spliterimg" onclick='toggleMenu()' style="display:none">
    <%
        }
    %>
    
	        <iframe src="btn-border.html"  class='childremenu0' scrolling="no" frameborder="no" id="spliter"></iframe>
    <%--<%
        if (ZBServices.SystemInfoClass.SystemType != ZBServices.SystemTypeEnum.SystemMoZi)
        {
    %>
            <iframe src="btn-border.asp"  class='childremenu0' frameborder="no" id="spliter"></iframe>
    <%
        }
    %>--%>
	</td>
	<td style='width:auto;'  id='mmainbody' valign='top'>
    <%
        if (ZBServices.SystemInfoClass.SystemType == ZBServices.SystemTypeEnum.SystemMoZi)
        {
    %>
            <iframe  frameborder="no" onresize='this.style.height="100%"' src="home.html?v=20210423" onload='pageload();pageload2()'  style='background-color:white;height:100%;' name="mainFrame" id="mainFrame" scrolling="auto" noresize=true></iframe>
    <%
        }
        else { 
     %>
            <iframe src="main.asp?t=0" frameborder="no" onresize='this.style.height="100%"' onload='pageload();pageload2()'  style='box-sizing: border-box;padding: 0px 0px 10px;background-color: #efefef!important;' name="mainFrame" id="mainFrame" scrolling="auto" noresize=true></iframe>
      <%
          }
      %>  
        
	</td>
	
</tr>
</table>
<%
    var sqlcn = new ZBServices.SQLClass();
    var uid = ZBServices.SessionInfoClass.CurrUserID;
    if (uid == 0)
    {
        #region 64位模式下SYSA验证支持
        if (ZBServices.sdk.Bit64.Bit64Handler.RunModel == ZBServices.sdk.Bit64.Bit64RunMode.Run_OnlySysA && !ZBServices.sdk.Redis.RedisCacheHelper.IsOpenRedis)
        {
            ZBServices.UserManagerClass.RecoveryUserByCookie();
            uid = ZBServices.SessionInfoClass.CurrUserID;
        }
        #endregion
    }

    if (ZBServices.SQLClass.ExistsRecord("select 1 from gate where callModel=1 and ord=" + uid.ToString(), sqlcn))
    {
        if (ZBServices.SystemPowerClass.ExistsModule(32000))
        {
            if (ZBServices.SystemPowerClass.ExistsPowerCls((ZBServices.SQLPowerTypeEnum)74))
            {
                var ut = ZBServices.UserManagerClass.ForEach(x => x.GetExtAttribute("phb") == "1" && x.Uid != uid).Count();
                var t = ZBServices.SystemAPIClass.GetMoudlesItem(ZBServices.SystemMoublesItemTypeEnum.MC_LimitT);
                if ((ut >= t && t > 0) || t < 0)
                {
                    Response.Write("<script>");
                    if (t < 0)
                    { Response.Write("setTimeout(function(){alert('电话使用用户数上限为0，请联系智邦国际开通。')},2000); //max=" + t.ToString() + "\r\n"); }
                    else
                    { Response.Write("setTimeout(function(){alert('电话使用用户数超过上限" + t + "，请联系智邦国际开通。')},2000); //max=" + t.ToString() + "\r\n"); }
                    Response.Write("</script>");
                }
                else
                {
                    ZBServices.UserManagerClass.SetAttribute("phb", "1");
                    Response.Write("<script>parent.addPhone=1;  //max=" + t.ToString() + "</script>");
                }
                Response.Write("<script>if(parent.document.getElementById('onlinenumber')){parent.document.getElementById('onlinenumber').innerHTML=" + ZBServices.UserManagerClass.GetUsersCount() + "}</script>");
            }
        }
    }
%>
<script>
	parent.UserUniqueID="<%=uid%>";
    parent.UserUniqueSID = "";
    window.sysTypeIsMoZi = window.top.SysConfig && window.top.SysConfig.SystemType == 3 ? true : false;
    //计算点击次数
    function countNum(a, n) {
        var index = a.getAttribute("data-index");
        var leftLinksBars = window.top.PageInitParams[0] && window.top.PageInitParams[0].LeftLinkBars ? window.top.PageInitParams[0].LeftLinkBars : [];
        var arr = [];
        var indexArr = index.split("-");
        var m,n=0;
        for (var i = 0; i < indexArr.length; i++) {
            m = indexArr[i].split("_");
            m&&m[1]?arr.push(m[1]):"";
        }
        var thirdItem;
        while (n < arr.length) {
            if (n == 0) {
                thirdItem = leftLinksBars[arr[0]]
            } else {
                thirdItem = thirdItem.ChildMenus[arr[n]]
            }
            n++;
        }
        thirdItem.ClickNum = thirdItem.ClickNum * 1 + 1;
        $.ajax({
            type: "GET",
            url: "../../sysn/json/comm/Home.ashx",
            data: { actionName: "InsertUserHobby", menuId:a.id},
            success: function (res) {
                console.log(res);
            }
        })
    }
    
    //末级菜单面板
    window.creatMunePanel = function (a,htm) {
        var mask_div = window.document.getElementById("navPanelMask");;
        if (!mask_div) {
            mask_div = document.createElement("div");
            mask_div.id = "navPanelMask";
            mask_div.style.display = "none";
            mask_div.innerHTML = "<div id='navPanel' onclick='stopPop()'><div id='navPanelLayer1' style='overflow:auto;'></div><div id='panelColseIcon' onclick='$(\"#navPanelMask\").hide()'></div></div>";
            window.document.body.appendChild(mask_div);
        }
        var divPanel = mask_div.children[0];
        var div = divPanel ? divPanel.children[0] : "";
        if (!div) { return; }
        div.innerHTML = htm.length ? htm.join("") : "<div class='noNavInfo'>暂无导航信息</div>";
        mask_div.style.display = "block";
        resetPos(a, divPanel);
    }

    //面板定位
    function resetPos(a, div) {
        var z = window.top.uizoom ? window.top.uizoom : 1;
        var pos = a;
        var height = (div.offsetHeight ? div.offsetHeight : ($(div).height() < 0 ? 0 : $(div).height())) * z;
        var top = pos.top * z - height / 2;
        var wh = document.documentElement.clientHeight;
        if (top < 43) {
            top = 43
        }
        if (wh <= top + height) {
            top = wh - height - 43;
            top = top >= 0 ? top : 0
        }
        var borderFrame = window.document.getElementById("borderFrame");
        left = borderFrame ? (borderFrame.offsetLeft * 1) : 230
        div.style.top = top / z + "px";
        div.style.left = (sysTypeIsMoZi ? 1 : 10) + "px";
        div.parentNode.style.left = left + "px";
    }

    //展开导航
    function expandNav() {
        var mleftbody = document.getElementById("mleftbody");
        mleftbody.style.width = "212px";
        $("#expandIcon").fadeOut();
    }
</script>
<%
	if (ZBServices.SystemInfoClass.SaasCompany > 0) {
		var updatetime = "2018-1-13";
		if (!ZBServices.SQLClass.ExistsRecord("select 1 from ExcepStrategies  where gdate>='" + updatetime + "'", sqlcn))
		{
%>
	<script>
		var doc = parent.document;
		var obj = doc.getElementById("UserStWords");
		if(obj)  {
			var pobj = obj.parentNode;
			var span = doc.createElement("span");
			span.innerHTML = "| <span style='color:yellow;background-color:red;display:inline-block;border:1px solid yellow;padding:3px;line-height:12px'><b>【注意：数据版本可能较低，请及时升级】</b></span>"
			pobj.appendChild(span);
		}
	</script>
<%
		}
	}
%>
</body>
</html>