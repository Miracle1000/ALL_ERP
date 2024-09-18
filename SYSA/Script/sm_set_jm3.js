
function getUserListByRoleId(roleId){
    $("#role_show").val($("#role_"+roleId).html());
    $("#opt_"+roleId).hide();
	$.ajax({
       url:"cu.asp?roleId="+roleId+"&r="+ Math.random(),
       type:"post",
	   success:function(msg){
		  $("#role_"+roleId).html(msg);
	   }
   });
}
function ajaxSubmit(roleId){
	var W1="",W2="",W3="";
	var wobj=document.getElementsByName("W1");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W1+=W1==""?wobj[i].value:","+wobj[i].value;}
	wobj=document.getElementsByName("W2");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W2+=W2==""?wobj[i].value:","+wobj[i].value;}
	wobj=document.getElementsByName("W3");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W3+=W3==""?wobj[i].value:","+wobj[i].value;}
	$.ajax({
       url:"cu_submit.asp?W1="+escape(W1)+"&W2="+escape(W2)+"&W3="+escape(W3)+"&roleId="+roleId+"&r="+ Math.random(),
       type:"post",
	   success:function(msg){
		  $("#role_"+roleId).html(msg);
		  $("#opt_"+roleId).show();
	   }
   });
}
function closePanelByRoleId(roleId){
    $("#role_"+roleId).html($("#role_show").val());
    $("#opt_"+roleId).show();
}
$(document).ready(function(){
})
$.extend($.messager.defaults,{
    ok:"确定",
    cancel:"取消"
});
function delRoleById(roleId){
	$.messager.confirm('提示', '确定要删除此角色?', function(r){
		if (r){
			$.ajax({
				url:"del_role.asp?roleId="+roleId+"&r="+ Math.random(),
				type:"post",
				success:function(msg){
					$("#row_"+roleId).hide();
				}
		   });
		}
	});
}
function formSubmit(roleId){
	var flag=false;
	flag=Validator.Validate(document.forms['role_add'],2);
	if(flag){
		var qxlb="";
		var name=$("#charName").val();
		var status=$("#intStatus").val();
		var wobj=document.getElementsByName("qxlbSort");
		for(var i=0;i<wobj.length;i++){if(wobj[i].checked) qxlb+=qxlb==""?wobj[i].value:","+wobj[i].value;}
		var W1="",W2="",W3="";
		var wobj=document.getElementsByName("W1");
		for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W1+=W1==""?wobj[i].value:","+wobj[i].value;}
		wobj=document.getElementsByName("W2");
		for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W2+=W2==""?wobj[i].value:","+wobj[i].value;}
		wobj=document.getElementsByName("W3");
		for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W3+=W3==""?wobj[i].value:","+wobj[i].value;}
		$.ajax({
			url:"role_save.asp?qxlbSort="+escape(qxlb)+"&charName="+escape(name)+"&intStatus=1&W1="+escape(W1)+"&W2="+escape(W2)+"&W3="+escape(W3)+"&roleId="+roleId+"&r="+ Math.random(),
			type:"post",
			success:function(msg){
				$("#role_"+roleId).html(msg);
				if(roleId=="0"){
					var r=$("#content tr").size()-2;
					var row = $('#content tr:eq('+r+')');
					row.append(msg);
				}else{
					aStr=msg.split("###");
		  			$("#label_"+roleId).html(aStr[0]);
		  			$("#role_"+roleId).html(aStr[1]);
				}

				$('#win').window('close');
				$("#role_add").html("");
			}
	   });
	}
}
function addRole(roleId){
	$.ajax({
		url:"role_add.asp?roleId="+roleId+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			$("#role_add").html(msg);
			$.parser.parse($('#role_add'));
			$('#win').window({
				collapsible:false,
				minimizable:false,
				top:400,
				left:(document.body.scrollWidth-500)/2,
				modal:true,
				onResize:function(w,h){
					$("#div_user").height(h-160);
				}
			});
			$('#win').window('open');
		}
   });
}
