
function checkValue(){

	$("input[name='sType']").each(function(){
		var v=$(this).val();
		var t=v.substr(1,1);
		
		if($(this).attr("checked")){
		
			$('#targetValue'+v).attr('disabled',false);
			if(v=="11" || v=="12" || v=="13"){
				$('#dtFromDate'+t).attr("disabled",false);
				$('#dtToDate'+t).attr("disabled",false);
			}else if(v=="21" || v=="22" || v=="23"){
				$("input[name='week"+t+"']").each(function(){
					$(this).attr("disabled",false);
				});
			}else if(v=="31" || v=="32" || v=="33"){
				$('#fromDay'+t).attr("disabled",false);
				$('#toDay'+t).attr("disabled",false);
			}else if(v=="41" || v=="42" || v=="43"){
				$('#fromWeek'+t).attr("disabled",false);
				$('#toWeek'+t).attr("disabled",false);
			}
			
		}else{
		
			$('#targetValue'+v).attr('disabled',true);
			$('#err'+v).html(" ");
			
			if(v=="11" || v=="12" || v=="13"){
				$('#dtFromDate'+t).attr("disabled",true);
				$('#dtToDate'+t).attr("disabled",true);
			}else if(v=="21" || v=="22" || v=="23"){
				$("input[name='week"+t+"']").each(function(){
					$(this).attr("disabled",true);
				});
			}else if(v=="31" || v=="32" || v=="33"){
				$('#fromDay'+t).attr("disabled",true);
				$('#toDay'+t).attr("disabled",true);
			}else if(v=="41" || v=="42" || v=="43"){
				$('#fromWeek'+t).attr("disabled",true);
				$('#toWeek'+t).attr("disabled",true);
			}
			
		}
	});
}
function weekDaySave(){
	$('#setWeekDayTarget').form('submit', {   
        url:'WeekDayTargetSave.asp',
		onSubmit:function(){
			var flag=true;
			if($("#targetValue").val()==""){
				$("#err").html("*");
				flag=false;
			}else{
				$("#err").html(" ");
			}
			
			var sType=document.forms["setWeekDayTarget"].sType;
			for(var i=0;i<sType.length;i++){
				if(sType[i].checked){
				
					var v=sType[i].value;
					var t=v.substr(1,1);
					
					if(v=="11" || v=="12" || v=="13"){
						if($('#dtFromDate'+t).val()==""||$('#dtToDate'+t).val()==""||$("#targetValue"+v).val()==""){
							flag=false;
							$("#err"+v).html("*");
						}else{
							$("#err"+v).html(" ");
						}
					}else if(v=="21" || v=="22" || v=="23"){
						var s=0;
						$("input[name='week"+t+"']").each(function(){
							if($(this).attr("checked")){
								s+=1;
							}
						});
						if(s==0||$("#targetValue"+v).val()==""){
							flag=false;
							$("#err"+v).html("*");
						}else{
							$("#err"+v).html(" ");
						}
					}else if(v=="31" || v=="32" || v=="33"){
						if(parseInt($('#fromDay'+t).val())>parseInt($('#toDay'+t).val())||$("#targetValue"+v).val()==""){
							flag=false;
							$("#err"+v).html("*");
						}else{
							$("#err"+v).html(" ");
						}
					}else if(v=="41" || v=="42" || v=="43"){
						if(parseInt($('#fromWeek'+t).val())>parseInt($('#toWeek'+t).val())||$("#targetValue"+v).val()==""){
							flag=false;
							$("#err"+v).html("*");
						}else{
							$("#err"+v).html(" ");
						}
					}
				}
			}
			
			return flag;
		},
		success:function(data){
			$('#win1').window('close');
		}
    });  
}
