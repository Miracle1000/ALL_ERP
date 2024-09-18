
function resetForm()
{
	var wobj=document.getElementById("dd").getElementsByTagName("input");
	for(var i=0;i<wobj.length;i++)
	{
		if(wobj[i].name)
		{
			if(wobj[i].type=="checkbox"&&wobj[i].checked)
			{
				wobj[i].click();
			}
			else if(wobj[i].type!="hidden"&&wobj[i].type!="checkbox")
			{
				wobj[i].value="";
			}
		}
	}	
	$("select").val("");
	open1();
}

$(document).on("click", "#submit-btn", function () {
	$("#searchForm").submit();	
});

