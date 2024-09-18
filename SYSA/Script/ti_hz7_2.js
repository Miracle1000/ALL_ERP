
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

jQuery(function(){
	var $tb = jQuery('.dataTable');
	var winWidth=$(window).width();
	if($tb.width()<jQuery(document.body).width()){
		$tb.css({width:'100%'}).children().children().eq(0).children().css({width:null});
	}

	var tbWidth = $tb.width()
	if(tbWidth>winWidth){
		jQuery('.searchBar,.pageBar').css({paddingRight:tbWidth - winWidth});
	}
});

function advSearch(){
	var $o = jQuery(document.body);
	var $w = jQuery(window);
	var winWidth = $w.width();
	var winHeight = $w.height();

	$('#w').dialog({
		left:(winWidth-500)/2 + $o.scrollLeft(),
		top:(winHeight-550)/2 + $o.scrollTop(),
		buttons:[{
			text:'确认',
			handler:function(){jQuery('#date1').submit();}
		},{
			text:'取消',
			handler:function(){$('#w').window('close');}
		}]
	}).dialog('open');
}
