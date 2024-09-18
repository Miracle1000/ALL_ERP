//时间日期再次检查
window.__Report_Date_Check = function(d1 ,d2 ,stype){
	if (window.__Report_Fields_OK == true)
	{
		if (d1 ==undefined || d2 ==undefined )
		{
			app.Alert("温馨提示：\n\n请选择【起始日期】和【截止日期】。\n");
			window.__Report_Fields_OK = false;
		}else if (d1.getFullYear() != d2.getFullYear())
		{
			app.Alert("温馨提示：\n\n【起始日期】和【截止日期】必须在同一个自然年内。\n" );
			window.__Report_Fields_OK = false;
		}	
	}
}