
function changeperson(obj)
{
	$("#phone").html($(obj).children(":selected").attr("phone"));
	$("#mobile1").html($(obj).children(":selected").attr("mobile1"));
	$("#mobile2").html($(obj).children(":selected").attr("mobile2"));
}

function checkEndtype()
{
	var endtype = $('input[name="endtype"]:checked').eq(0).val();
	var nextprojdID = window.nextprojdID;
	if (endtype=="1")
	{
		if (nextprojdID!="0")
		{
			$("#nextTr1").show();
			$("#nextTr2").show();
			$("#nextTr3").show();
			$("#autoNext").val(1);
			$("#person_hf").attr("min",1);
			$("#nexttitle").attr("min",1);
		}
		$("#endTr").hide();
	}
	else if (endtype=="0")
	{
		if (nextprojdID!="0")
		{
			if (confirm("是否触发下阶段回访？"))
			{
				$("#nextTr1").show();
				$("#nextTr2").show();
				$("#nextTr3").show();
				$("#autoNext").val(1);
				$("#person_hf").attr("min",1);
				$("#nexttitle").attr("min",1);
			}
			else
			{
				$("#nextTr1").hide();
				$("#nextTr2").hide();
				$("#nextTr3").hide();
				$("#autoNext").val(0);
				$("#person_hf").attr("min",0);
				$("#nexttitle").attr("min",0);
			}
		}
		$("#endTr").hide();
	}
	else if (endtype=="2")
	{
		$("#endTr").show();
		if (nextprojdID!="0")
		{
			$("#nextTr1").hide();
			$("#nextTr2").hide();
			$("#nextTr3").hide();
			$("#autoNext").val(0);
			$("#person_hf").attr("min",0);
			$("#nexttitle").attr("min",0);
		}
	}	
}
//Jsuanall();
function Jsuan(){
	if (document.getElementById("manyidu"))
	{
		var allpoint=0;
		var radios=$('input[type="radio"][name!="endtype"]:checked');
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
			document.getElementById("manyidu").value=allpoint/oldpoint*100;
			checkDot('manyidu','2');
		}
		else{
			document.getElementById("manyidu").value=0;
		}
	}
}
function gethtml(){
	if($("input[name='endtype']:checked").size()==0){
		alert("请选择回访结果！");
		return false;
	}
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
	return true;
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
