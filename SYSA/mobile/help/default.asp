<html style='margin:0px;padding:0px;height:100%;overflow:auto;'>
<head>
    <title></title>
    <style>
        a {font-family:宋体;font-size:14px;}
    </style>
</head>
<body style='margin:0px;padding:0px;height:100%;background-color:buttonface;overflow:hidden'>
<div style='width:14%;float:left;height:100%'>
    <ul style='font-size:12px;margin-top:5px;line-height:30px'>
        <li><a href='../MacBinding.asp' target='ccc'>移动设备号绑定</a></li>
        <li><a href='../UserPower.asmx' target='ccc'>用户权限接口</a></li>
        <li><a href='../Sale.asmx' target='ccc'>销售管理接口</a></li>
        <li><a href='../office.asmx' target='ccc'>办公管理接口</a></li>
        <li><a href='../Search.asmx' target='ccc'>检索接口</a></li>
        <li><a href='../Store.asmx' target='ccc'>库存接口</a></li>
        <li><a href='../Bank.asmx' target='ccc'>银行财务接口</a></li>
        <li><a href='../Approve.asmx' target='ccc'>审批接口</a></li>
        <li>验证码：<input type='text' id='yzmc' size='5'><input onclick='ccc.location.href="../RndCodeImage.aspx?code=" + yzmc.value '
            type='button' value='OK'></li>
        <li><a href='../KickOffPC.asp' target='ccc'>踢下线</a></li>
        <li><a href='autoLogin.htm' target='ccc'>自动登录（李洪涛）</a></li>
        <li><a href='autoLogin.htm' target='ccc'>自动登录（张慧）</a></li>
    </ul>
    <hr>
    <ul style='font-size:12px;margin-top:5px;line-height:30px'>
        <li><a href='help.xml'  target='ccc'>接口说明</a>
        <li><a href='ErrorDef.htm'  target='ccc'>错误号说明</a>
		<li><a href='enum.htm'  target='ccc'>枚举类型说明</a>
    </ul>
</div>
<iframe src='../MacBinding.asp' id='ccc' name='ccc' frameborder=0 style='width:86%;height:100%;margin:0px' scrolling='auto'></iframe>
</body>
</html>
