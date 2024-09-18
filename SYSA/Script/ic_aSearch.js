
function reAdvWindow(getCheckBoxArrchar, f) {
	$('#searchitemsbutton').css({'display':'none'});
	$('#searchitemspanel').css({'display':'block'});
	$('#adv_seach_power_button').remove();
	$('#searchitemspanel').find('table').css({'border-bottom':''})
	$('#advancedSeachButton').click(function(){//弹出高级搜索窗体
         $('#advancedSeach').window('open');
         $('#advancedSeach').css({'display':'block'})
    })
	$('input[type="checkbox"]').click(function(){//高级搜索框高度自适应
		$('#showAdvTime1,#showAdvTime2').html('');
		//$('#advancedSeach').css({'height':'auto'});
	})
	$('input[bt=reset]').click(function(){
		$('input[advtext=true]').attr('value','');
		$('select[advselect=true]').attr('selected',false)
		$('input[worker=true]').attr('checked',false);
		$(this).mousemove(function(){
			$('input[advtext=true]').attr('value','');
			$('select[advselect=true]').attr('selected',false)
			$('input[worker=true]').attr('checked',false);
			return;
		})
	})
	c(getCheckBoxArrchar);
	f();

}
function c(getCheckBoxArrchar){
	var getCheckBoxArr=getCheckBoxArrchar;
		if(getCheckBoxArr!=''){//选中选择框
			getCheckBoxArr=getCheckBoxArr.replace('0,','');
			getCheckBoxArr = getCheckBoxArr.replace('2', '1');
			getCheckBoxArr = getCheckBoxArr.replace('101,', '');
			getCheckBoxArr=getCheckBoxArr.split(',');
			$('input[advCheckBox=true]').each(function(index){
				if(getCheckBoxArr[index]!=''&&getCheckBoxArr[index]!=undefined){
					$(this).attr('checked',true)
				}
			})
		}
		else
		{
			$('input[advCheckBox=true]').each(function(index){
				$(this).attr('checked',true)
			})
		}
}
