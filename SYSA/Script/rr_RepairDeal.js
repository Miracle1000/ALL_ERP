
$(function(){
	//是否继续本级节点
	var $dBox = $("#dealBox");
	var $nBox = $("#NextNodeBox");
	//继续
	$("#IsContinue0").on("click",function(){
		//删除选择的节点
		$(".del-btn").each(function(index, ele) {
			var nid = $(ele).attr("nid");
			//恢复可选的下级节点
			$("#NextList input[id=node"+nid+"]").attr("checked",false).parent().show();
			//移除当前行
			$(this).parent().parent().remove();
        });		
		
		$dBox.show();	
		$nBox.hide();
		
	});
	
	//结束
	$("#IsContinue1").on("click",function(){
		$dBox.hide();	
		$nBox.show();
	});
	
	
	//重置
	$("#reset").on("click",function(){
		//删除选择的节点
		$(".del-btn").each(function(index, ele) {
			var nid = $(ele).attr("nid");
			//恢复可选的下级节点
			$("#NextList input[id=node"+nid+"]").attr("checked",false).parent().show();
			//移除当前行
			$(this).parent().parent().remove();
        });		
	})
	
	
	
	//选择下级节点
	$("#NextList input[name=NextNode]").on("click",function(){
		var nVal = $(this).val();
		$(this).parent().hide();
		var trNum = $(".selectedNode tr").size() - 1;
		$.post("commonAjax.asp",{action:"NextNodeList",repID:window.wxrepID,PID:window.wxPID,NID:nVal,trNum:trNum+1},function(data){
			$(".selectedNode tbody").append(data);
		});
		
	});
	
	
	//删除选择的节点
	$(document).on("click",".del-btn",function(){
		var nid = $(this).attr("nid");
		//恢复可选的下级节点
		$("#NextList input[id=node"+nid+"]").attr("checked",false).parent().show();
		//移除当前行
		$(this).parent().parent().remove();
	});
	
	
	
	//至少要选择一个已有的下级节点
	$("#demo").on("submit",function(event){
		//开始时间不能大于结束时间
		var t1 = $("input[name=beginTime]").val();
		var t2 = $("input[name=endTime]").val();
		if(t1 > t2){
		    app.Alert('提示：开始时间不能大于结束时间！');
			$("input[name=beginTime]").focus();
			return false;
		}
		

		//关联单据是否完成
		var delaType = $("#IsContinue1:checked").size();
		var noNum = $("#r-box input[value=0]").size();
		if(delaType == 1 && noNum > 0){
			$("#r-box input[value=0]").css({"border":"1px red solid"});
			app.Alert('提示：有未完成的关联单据，不能执行下一节点！');
			return false;
		}
	
	
		var isOver = $("#IsContinue1").attr("checked");
		var isApprove = $("#IsApprove1").attr("checked");
		if(isOver == "checked" || isApprove == "checked"){
			var num = $("#NextList input[name=NextNode]").size();
			var selboxs = $("#NextList input[name=NextNode]:checked");
			var hasNodes = new Array()
			for (var i = 0; i < selboxs.length ; i++ )
			{
				hasNodes.push(selboxs[i].value);
			}
			var selectedNum = selboxs.size();
			if(num > 0 && selectedNum == 0){			
				app.Alert('提示：请至少选择一个下级节点！');
				return false
			}		
		}
		

		//遍历下级节点行 判断计划开始时间 不能大于计划开始时间
		$("#NextNodeBox .selectedNode tr").each(function(index, ele) {
			var nT1 = $(ele).find("input[name=NodeBeginTime]").val();
			var nT2 = $(ele).find("input[name=NodeEndTime]").val();
			if(nT1 > nT2){
			    app.Alert('提示：计划开始时间不能大于计划结束时间！');
				$(ele).find("input[name=NodeBeginTime]").focus();
				event.preventDefault();
				return false;
			}
			
        });
				
		//必经节点一定要全部选择
		var mustNode = $("#NextList label.red:visible").size();
		if(mustNode > 0){
		    app.Alert('提示：还有未选择的必经节点！');
			return false;
		}
		
	});
	
	//同意或退回
	var $nodeBox = $("#nodeBox");	
	//同意
	$("#IsApprove1").on("click",function(){
		$("#beforeNodeID").attr("min",0);
		try{$("#nDealPerson").attr("min",0);}catch(e){}
		$nodeBox.hide();
		$nBox.show();
	});
	//退回
	$("#IsApprove0").on("click",function(){
		$("#beforeNodeID").attr("min",1);
		try{$("#nDealPerson").attr("min",1);}catch(e){}
		$nodeBox.show();
		$nBox.hide();
	});
	
	
	//选择退回节点后 出现选择的节点的处理人
	$("#beforeNodeID").on("change",function(){
		var repID = window.wxrepID;
		var PID = window.wxPID;
		var NID = $(this).val();
		$.post("commonAjax.asp",{action:"NodeDealPerson",repID:repID,PID:PID,NID:NID},function(data){
			$("#nDealPerson").remove();
			$nodeBox.append(data);
		})
	});
	
	
		
	
});

//iframe 自适应高度
function frameResize(){
	try{
	document.getElementById("mxlist").style.height=I3.document.body.scrollHeight+0+"px";
	document.getElementById("mxlist1").style.height=I31.document.body.scrollHeight+0+"px";
	}catch(e){}
}

function chkXZForm(){		//选择协作人员窗口
	var XzUser = document.getElementById("XzUser");
	$('#w2').window('open');
	document.getElementById("w2").style.display = "block";
	XzUser.innerHTML="loading...";
	jQuery.ajax({
		url:'Ajax_XZ.asp',
		type:'post',
		data:{msgid:1,gateord:$ID("ActorsCateid").value},
		cache:false,
		async:false,
		success:function(r){
			XzUser.innerHTML = r;
		},
		error:function(res){
		    app.Alert(res.responseText);
		}
	});
}

function setXZUser(){		//设置协作人
	var frm = document.secuser;
	var member2 = "";
	var userid = "";
	member2 = frm.member2.getAttribute("text");
	userid =  frm.member2.value || "";
/*	if(userid == ""){
	    app.Alert("请选择协作人员");
		return false;
	}else{		
*/		$ID("ActorsCateName").value = member2;
		$ID("ActorsCateid").value = userid;
		$('#w2').window('close');
//	}
}
