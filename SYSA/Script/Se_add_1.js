
function Jsuan(){
	if (document.getElementById("manyidu"))
	{
		var allpoint=0;
		var radios=$('#content input[type="radio"]:checked');
		var cmanyi=0;
		for (var i=0;i<radios.length ;i++ )
		{
			cmanyi=radios[i].value;
			if(cmanyi!=""&&!isNaN(cmanyi))
			{
				allpoint=parseFloat(allpoint)+parseFloat(cmanyi);
			}
		}
		var checkboxs=$('input[type="checkbox"]:checked');
		for (var ii=0;ii<checkboxs.length ;ii++ )
		{
			cmanyi=checkboxs[ii].value;
			if(cmanyi!=""&&!isNaN(cmanyi))
			{
				allpoint=parseFloat(allpoint)+parseFloat(cmanyi);
			}
		}
		if (document.getElementById("allpoint"))
		{		
			var oldpoint=document.getElementById("allpoint").value;
			if ((oldpoint==0)||(oldpoint==null)||(oldpoint.length==0))
			{
				document.getElementById("manyidu").value=0
			}
			else
			{
				if (!isNaN(oldpoint))
				{
					document.getElementById("manyidu").value=allpoint/parseFloat(oldpoint.replace(/\,/g,""))*100;
				}
				else
				{
					document.getElementById("manyidu").value=0			
				}
			}
			checkDot('manyidu','2');
		}
		else
		{
			document.getElementById("manyidu").value=0;
		}
	}
}
function Jsuanall(){
	if (document.getElementById("manyidu"))
	{
		var allpoint=0;
		var radios=$('#content input[type="radio"]');
		var cmanyi=0;
		for (var i=0;i<radios.length ;i++ )
		{
			cmanyi=radios[i].value;
			if(cmanyi!=""&&!isNaN(cmanyi))
			{
				allpoint=parseFloat(allpoint)+parseFloat(cmanyi);
			}
		}
		var checkboxs=$('input[type="checkbox"]');
		for (var ii=0;ii<checkboxs.length ;ii++ )
		{
			cmanyi=checkboxs[ii].value;
			if(cmanyi!=""&&!isNaN(cmanyi))
			{
				allpoint=parseFloat(allpoint)+parseFloat(cmanyi);
			}
		}
		if (document.getElementById("allpoint")){document.getElementById("allpoint").value=allpoint;}
		checkDot('manyidu','2');
	}
}
function gethtml(){
	$("#content").find("input[type='checkbox']:checked").each(function(){
		$(this)[0].setAttribute("checked","true");
	});
	$("#content").find("input[type='radio']:checked").each(function(){
		$(this)[0].setAttribute("checked","true");
	});
	$("#content").find("textarea").each(function(){
		$(this).text($(this).val());
	});
	$("#Ccontent").val($("#content").parent().html());
}
