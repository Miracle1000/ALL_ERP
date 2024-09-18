
$(function(){
	$('#mxdiv').css({'width':$('#posW').offset().left,'height':$('#mxdiv').children().eq(0).height()+20});
	$(window).resize(function(){
		$('#mxdiv').css({'width':$('#posW').offset().left,'height':$('#mxdiv').children().eq(0).height()+20});
	});
});

function setsp(ord){
	window.open('../inc/CommSPSet.asp?ord='+ord+'&sort1=26&remind=220','setsp','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=300,top=200');
}
