


function openDiv()
{
	$('#ddd').dialog('open');
	$('#ddd').dialog('move',{left:100,top:150});
}
function setcarid(id,name)
{
	document.getElementById('rep_carname').value=name;
	document.getElementById('rep_carname').style.color="black";
	document.getElementById('rep_carid').value=id;
	
}

