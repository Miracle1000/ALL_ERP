
function test()
{
	  if(!confirm('确认删除吗？')) { return false; }
}
 
function mm()
{
   var a = document.getElementsByTagName("input");
   if(a[0].checked==true){
   for (var i=0; i<a.length; i++)
      if (a[i].type == "checkbox") a[i].checked = false;
   }
   else
   {
   for (var i=0; i<a.length; i++)
      if (a[i].type == "checkbox") a[i].checked = true;
   }
}

function ponload() {
	var box = document.getElementsByName("selectid");
	  for (var i = 0; i < box.length ; i ++ )
	  {
			var nbox = box[i];
			var tr = nbox.parentNode.parentNode;
			var index = tr.cells[tr.cells.length-1].innerHTML.indexOf("Delete.asp?ord=");
			if(index==-1) {
				nbox.style.display = "none";
			}
	  }
}
ponload();

function loadSPmx(ord){
	var dhtml = document.getElementById("dhtml");
	var XMlHttp = GetIE10SafeXmlHttp();	
	document.getElementById("w").style.display="block";
	$('#w').window('open')
	var url = "spmx_ajax.asp?ord="+ord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	XMlHttp.open("GET", url, false);
	XMlHttp.onreadystatechange = function(){
	  if (XMlHttp.readyState < 4) {
		dhtml.innerHTML="loading...";
	  }
	  if (XMlHttp.readyState == 4) {
		var response = XMlHttp.responseText;
		dhtml.innerHTML=response;
	  }
	};
	XMlHttp.send(null);
}

jQuery(function(){
	BindCancelEvents({cfgId:111});
});
