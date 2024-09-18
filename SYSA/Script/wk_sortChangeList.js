
				function test()
				{
				  if(!confirm('确认删除吗？')) return false;
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
				function open2()
				{
							$('#dd').dialog('move',{left:document.documentElement.scrollLeft+200,top:50});
							$('#dd').show();
							$('#dd').dialog('open');
				}
			