
// 一个简单的测试是否IE浏览器的表达式
isIE = (document.all ? true : false);

// 得到IE中各元素真正的位移量，即使这个元素在一个表格中
function getIEPosX(elt) { return getIEPos(elt,"Left"); }
function getIEPosY(elt) { return getIEPos(elt,"Top"); }
function getIEPos(elt,which) {
 iPos = 0
 while (elt!=null) {
  iPos += elt["offset" + which]
  elt = elt.offsetParent
 }
 return iPos
}

//点击左侧产品触发的函数 添加明细
function callServer4(proID,q){
	var $ = jQuery;
	$.post("commonAjax.asp",{action:"GetProList",proID:proID},function(data){	
		$("#noList").hide();
		$("#proList tbody").append(data);

	    //删除明细行
		$(".del-btn").on("click", function () {
		    var $ele = $(this);
		    var listID = $(this).siblings("input[name=listID]").val();
		    $.post("commonAjax.asp", { action: "DelProList", listID: listID }, function (data) {
		        $ele.parent().parent().remove();
		    });
		});
	});
	
}

$(function(){
	var $ = jQuery;
	//删除明细行
	$(".del-btn").on("click",function(){
		var $ele = $(this);
		var listID = $(this).siblings("input[name=listID]").val();
		$.post("commonAjax.asp",{action:"DelProList",listID:listID},function(data){
			$ele.parent().parent().remove();	
		});		
	});
	
});

