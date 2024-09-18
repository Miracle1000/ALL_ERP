<html>
 <head>
  <title> Reload </title>
	<script language='javascript'>
		window.onerror = function(){return true;};
	</script>
	<link href="skin/default/css/home.css?ver=<%=Application("sys.info.jsver")%>" rel="stylesheet" type="text/css"/>
	<link href="skin/default/css/comm.css?ver=<%=Application("sys.info.jsver")%>" rel="stylesheet" type="text/css"/>
	<link href="skin/default/css/leftmenu.css?ver=<%=Application("sys.info.jsver")%>" rel="stylesheet" type="text/css"/>
	<script type="text/JavaScript" src="skin/default/js/comm.js?ver=<%=Application("sys.info.jsver")%>"></script>
	<script type="text/JavaScript" src="skin/default/js/home.leftmenu.2.0.js?ver=<%=Application("sys.info.jsver")%>"></script>
	<script type="text/JavaScript" src="skin/default/js/home.js?ver=<%=Application("sys.info.jsver")%>"></script>
	<script type="text/JavaScript" src="skin/default/js/c2_homelinks.js?ver=<%=Application("sys.info.jsver")%>"></script>
	<script type="text/javascript" language='javascript' src="skin/default/js/dateCalender.js?ver=<%=Application("sys.info.jsver")%>"></script>
	<script type="text/JavaScript" src="inc/jquery-1.4.2.min.js?ver=<%=Application("sys.info.jsver")%>"></script>
	<script src='inc/CheckOnLine.js?ver=<%=Application("sys.info.jsver")%>' language='javascript' type='text/javascript'></script>
	<script type="text/javascript" src="inc/jquery.bgiframe.js?ver=<%=Application("sys.info.jsver")%>"></script>	
 </head>

 <body>
<img src="skin/default/images/logobg.gif"/>
<img src="skin/default/images/ico16/rc.gif"/>
<img src="skin/default/images/ico_top_menu_line.gif"/>
<img src="skin/default/images/ico_top_menu_01.gif"/>
<img src="skin/default/images/ico_top_menu_02.gif"/>
<img src="skin/default/images/ico_top_menu_03.gif"/>
<img src="skin/default/images/ico16/004.gif"/>
<img src="skin/default/images/toolbar/ico_sub_m_10.gif"/>
<img src="skin/default/images/toolbar/ico_sub_m_03.gif"/>
<img src="skin/default/images/toolbar/ico_sub_m_04.gif"/>
<img src="skin/default/images/toolbar/ico_sub_m_05.gif"/>
<img src="skin/default/images/toolbar/ico_sub_m_06.gif"/>
<img src="skin/default/images/ico_footer_01.gif"/>
<img src="skin/default/images/ico_footer_02.gif"/>
<img src="skin/default/images/ico_footer_03.gif"/>
<img src="skin/default/images/ico_footer_04.gif"/>
<img src="skin/default/images/11.gif"/>
<img src="skin/default/images/12.gif"/>
<img src="skin/default/images/tree_line1.gif"/>
<img src="skin/default/images/tree_line2.gif"/>
<img src="skin/default/images/tree_line3.gif"/>
<img src="skin/default/images/tree_line4.gif"/>
<img src="skin/default/images/tree_line20.gif"/>
<img src="skin/default/images/tree_line30.gif"/>
<img src="skin/default/images/tree_line40.gif"/>
<img src="skin/default/images/tree_line50.gif"/>
<img src="skin/default/images/tree_line50_s.gif"/>
<img src="skin/default/images/tree_line60.gif"/>
<img src="skin/default/images/tree_line60_s.gif"/>
<img src="skin/default/images/tree_line70.gif"/>
<img src="skin/default/images/lmStabItem_mid.gif">
<img src="skin/default/images/lmStabItem_bnt2.gif">
<img src="skin/default/images/lmStabItem_top.gif">
<img src="skin/default/images/bg_top.gif">
<img src="skin/default/images/bg_block_title.gif">
<%
For i = 1 To 9
	Response.write "<img src='skin/" & Info.skin & "/images/menuico/bg/" & i & ".gif'>"
Next
For i = 1 To 6
	Response.write "<img src='skin/" & Info.skin & "/images/menuico/ck/" & i & ".gif'>"
Next
For i = 1 To 7
	Response.write "<img src='skin/" & Info.skin & "/images/menuico/cw/" & i & ".gif'>"
Next
For i = 1 To 8
	Response.write "<img src='skin/" & Info.skin & "/images/menuico/rs/" & i & ".gif'>"
Next
For i = 1 To 10
	Response.write "<img src='skin/" & Info.skin & "/images/menuico/rz/" & i & ".gif'>"
Next
For i = 1 To 11
	Response.write "<img src='skin/" & Info.skin & "/images/menuico/sc/" & i & ".gif'>"
Next
For i = 1 To 12
	Response.write "<img src='skin/" & Info.skin & "/images/menuico/xs/" & i & ".gif'>"
next
%>
</body>
</html>