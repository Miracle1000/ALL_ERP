$(function(){
	wxcnfg();
	wx.ready(function (){
		var $billKinds = $("input[name='bill']");
		$(".back").bind("click",function(){
			history.go(-1);
		})
		addValue($billKinds);
		timeOk();	
	})
	
})
//点击增值税出现文本框填写
function addValue($billKinds){
	$billKinds.bind("click",function(){
	for(i=0;i<$billKinds.length;i++){
		if($billKinds[i].checked){
			if(window.localStorage){
				localStorage.setItem("getTime",$billKinds[i].value);
				console.log(localStorage.getItem("getTime"));
			}
		}
		
	}
	})
}

function timeOk(){
	$(".bill_ok").bind("click",function(){
		window.location = "order.html";
	})
}
