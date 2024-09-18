$(document).ready(function(){
	if (datedlg.showDateTime)
	{
		var __showDateTime = datedlg.showDateTime;
		datedlg.showDateTime = function(){
			$("html").css({"overflow":"hidden"});
			__showDateTime();
			$("html").css({"overflow":"auto"});
		}
	}
});