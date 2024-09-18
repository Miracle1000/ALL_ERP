
function Cancel()
{
	hideElement("daysOfMonth3");
}

function clearkcbzMsg()
{
	var spans = document.getElementsByTagName("SPAN")
	for (var i = 0 ; i < spans.length ; i ++ )
	{
		if(spans[i].innerText == "库存不足")
		{
			spans[i].innerHTML = "";
		}
	}
}
