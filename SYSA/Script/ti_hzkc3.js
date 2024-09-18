
function divShow(){
	var scrollLeft = $(document.body).scrollLeft();
	var windowWidth = $(window).width()
	$("#pagecountDiv").css("width",windowWidth - 312 + scrollLeft);
	$("#searchDiv").css("width",windowWidth + scrollLeft);
	$('#pagediv').css("width",windowWidth + scrollLeft);
}

$(function(){
	var maxWidth = $(document.body).children('table:eq(0)').width() - $(window).width()
	$(window).scroll(function(){
		var scrollLeft = $(document.body).scrollLeft();
		if (scrollLeft >= maxWidth ) return;
		divShow();
	});
});