<?xml version="1.0" encoding="gb2312"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 
<xsl:template match="/"> 
<html> 
<title><xsl:value-of select="help/@title"/>Xml版</title>
<meta http-equiv="Content-Type" content="text/html;charset=gb2312"/>
<style>
  *{font-family:Verdana;}
  table.params {border-collapse:collapse;line-height:16px;font-size:12px}
  table.params th{background-color:#c3c7cf;padding:4px;border:1px solid white;}
  table.params td{background-color:#e3e7ef;padding:4px;border:1px solid white;}
</style>
<script>
	function expItem(item) {
		var p = item.parentNode.parentNode.parentNode.children;
		for(var i = 0 ; i&lt; p.length ; i ++) {
			if(p[i].name == "itemhide") {
				p[i].style.display = p[i].style.display == "none" ? "" : "none";
			}
		}
	}

	function openobjectRemark(item) {
		var t = item.innerHTML;
		t = t.indexOf("数组")==-1 ? t + ".xml" : t.replace("数组","") + ".xml?array=1";
		window.open("objects/" + t, "_blank", "width=820px,height=600px,resizable=1");
	}
</script>
<body style='background-color:buttonface;'>
  <div style='width:800px;margin:0 auto;overflow:visible'>
	<div style='margin:10px;background-color:#5C87B2;padding:5px;color:white;border:1px solid #f0f0f0f'><center><h3><xsl:value-of select="help/@title"/></h3></center></div>
	<xsl:for-each select="help/Models/Model">
		<div style='margin:10px;background-color:white;padding:5px;border:1px solid #aaa;'>
			<div style='font-size:14px;background-color:#f0f0f0;padding:5px;border:1px solid #ddd'>
			<div style='float:right'>URL：<a href='../{@url}' target="_blank"><xsl:value-of select="@url"/></a></div>
			<div>模块描述：<b><xsl:value-of select="@remark"/></b></div>
			</div>

			<div style='font-size:12px;padding:5px;'>
				<xsl:for-each select="function">
					<div style='margin:10px;margin-top:20px;background-color:#f6f6f8;border:4px solid #f2f2f3'>
						<div style='font-size:12px;background-color:#e8e9ef;padding:5px;border:0px solid #bbb'>
						<div style='float:left;width:200px'>函数：<a href='javascript:void(0)' onclick='expItem(this)'><xsl:value-of select="@name"/></a></div>
						<div style='float:right'><a href='javascript:void(0)' onclick='expItem(this)'>收展</a><input type='button' style='height:2px;width:4px;background-color:transparent;border:0'/><a href='../{../@url}?op={@name}' target="_blank">打开</a></div>
						<div >功能：<xsl:value-of select="remark"/></div>
						</div>
						<br/>
						<div name='itemhide' style='margin-left:20px;display:none'>传入参数：</div>
						<div name='itemhide' style='margin:10px;padding-left:20px;display:none'>
							<table class='params'>
							<tr><th style='width:100px'>参数名称</th><th style='width:100px'>数据类型</th><th>描述</th></tr>
							<xsl:for-each select="params/param">
								<tr><td align='center'><xsl:value-of select="@name"/></td><td align='center'>
								<a href='javascript:void(0)' onclick='openobjectRemark(this)'><xsl:value-of select="@type"/></a>
								</td><td><xsl:value-of select="@remark"/></td></tr>
							</xsl:for-each>
							</table>
						</div>
						<div name='itemhide' style='margin:20px;display:none'>返回对象：<b><xsl:value-of select="result/@type"/></b></div>
						<div name='itemhide' style='margin:10px;padding-left:20px;display:none'>
              <xsl:value-of select="result/@remark"/>
              <xsl:if test="result/@IsValue = 0">
							  <table class='params'>
							  <tr><th style='width:100px'>属性名称</th><th style='width:100px'>数据类型</th><th>描述</th></tr>
							  <xsl:for-each select="result/object/Attribute">
								  <tr><td align='center'><xsl:value-of select="@name"/></td><td align='center'>
									<a href='javascript:void(0)' onclick='openobjectRemark(this)'><xsl:value-of select="@type"/></a>
								  </td><td><xsl:value-of select="@remark"/></td></tr>
							  </xsl:for-each>
							  </table>
              </xsl:if>
						</div>
					</div>
				</xsl:for-each>
			</div>
		</div>
	</xsl:for-each>
  </div>
</body> 
</html> 
</xsl:template> 
</xsl:stylesheet>