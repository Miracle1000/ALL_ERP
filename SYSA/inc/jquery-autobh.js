//单据编号自动处理事件绑定,一般情况下包含本文件即可，对于ajax返回的页面，如果要自动绑定事件，需要在页面加载完之后手动调用此方法
function __AutoBindBHEvents(box){
	var __RootPath;
	var $bhobj = box?jQuery(box).find('.jquery-auto-bh'):jQuery('.jquery-auto-bh');
	if ($bhobj.size()>0){
		$bhobj.each(function(){
			var $obj = jQuery(this);

			var opt = $obj.attr('autobh-options');
			try{
				opt = eval('({'+opt+'})');
			}catch(e){
				alert('自动编号属性初始化错误！');
				return false;
			}

			if (typeof(opt.cfgId)=='undefined'){
				alert('自动编号缺少cfgId属性设置！');
				return false;
			}
			opt.autoCreate = typeof(opt.autoCreate)!='undefined' ? opt.autoCreate : true;
			opt.autoCheck = typeof(opt.autoCheck)!='undefined' ? opt.autoCheck : true;
			opt.recId = typeof(opt.recId)!='undefined' ? opt.recId : 0;
			opt.msgMode = typeof(opt.msgMode)!='undefined' ? opt.msgMode : 'label';
			opt.focusOnError = typeof(opt.focusOnError)!='undefined' ? opt.focusOnError : true;
			opt.selectOnError = typeof(opt.selectOnError)!='undefined' ? opt.selectOnError : true;
			opt.eventMode = typeof(opt.eventMode)!='undefined' ? opt.eventMode : 'both';
			opt.submitBtn = typeof(opt.submitBtn)!='undefined' ? opt.submitBtn : '';
			__RootPath = opt.rootPath || window.sysCurrPath || window.virpath;
			if (typeof(__RootPath)=='undefined'){
				alert('相对路径获取失败');
				return;
			}

			if ($obj.val().length==0){//当编号控件内无值时才需要自动获取编号
				if(opt.autoCreate) getBH();
			}

			if (opt.autoCheck){
				//给控件所在表单绑定表单提交事件以验证编号是否重复
				if (opt.eventMode=='both' || opt.eventMode=='onsubmit'){
					var $form = $obj.parent('form').size()>0 ? $obj.parent('form') : $obj.parentsUntil('form').last().parent();
					var form = $form.get(0);
					var submit = form.submit;
					//在校验（如果需要的话）之后再处理原有的submit事件
					form.submit = function(){
						if (!checkBH()) return false;
						return submit.call(this,arguments);
					};

					var onsubmit=form.onsubmit;
					form.onsubmit = function(){
						if(checkBH()){
							if (onsubmit && onsubmit.toString().length>0){
								return onsubmit.call(this,arguments);
							}
							return true;
						}else{
							return false;
						}
					};
				}

				//给设定的按钮绑定验证事件以验证编号是否重复
				if (opt.eventMode=='both' || opt.eventMode=='onclick'){
					if (opt.submitBtn.length>0){
						jQuery(opt.submitBtn).each(function(){
							var onclick = this.onclick;
							this.onclick = function(){
								if (!checkBH()) return false;
								if (onclick){
									onclick.call(this,arguments);
								}
							}
						});
					}
				}
			}
			
			//编号获取函数
			function getBH(){
				jQuery.ajax({
					url:__RootPath+'inc/AjaxReturn.asp',
					cache:false,
					data:{__act:'getBH',sort1:opt.cfgId},
					cache:false,
					type:'post',
					success:function(r){
						try{
							var json = eval('('+r+')');
							if (json.success){
								$obj.val(json.msg);
							}
						}catch(e){}
					},
					error:function(res){
						alert(res.responseText);
					}
				});
			}

			//编号校验函数
			function checkBH(){
				var bh = $obj.val(),result=true;
				if (bh!=''){
					jQuery.ajax({
						url:__RootPath+'inc/AjaxReturn.asp',
						data:{__act:'checkBH',sort1:opt.cfgId,djbh:bh,recId:opt.recId},
						cache:false,
						async:false,
						type:'post',
						success:function(r){
							var json = eval('('+r+')');
							var $span = $obj.parent().find('span[bhcheck="true"]');

							if (json.success!=true){
								if (opt.msgMode=='label'){
									if ($span.size()==0){
										$span = jQuery('<span style="color:red" bhcheck="true"></span>');
										$span.appendTo($obj.parent());
									}
									$span.html('编号已被使用');
								}else{
									alert('编号已被使用，请修改后再试！');
								}
								if (opt.focusOnError){
									$obj.trigger('focus');
								}
								if (opt.selectOnError){
									$obj.get(0).select();
								}
								result = false;
							}else{
								$span.html('');
								result = true;
							}
						},
						error:function(res){
							alert(res.responseText);
						}
					});
				}
				return result;
			}
		});
	}
}

jQuery(function(){
	__AutoBindBHEvents();
});

//调试工具，在界面上按下ctrl、shift和alt键然后点击鼠标右键开启调试面板
jQuery(function(){
	var $menu;
	var debugMenu = {
		show:function(){
			if (!$menu){
				$menu = jQuery(''+
				'<div style="width:250px;height:350px;position:absolute;left:0px;top:0px;z-index:9999999;text-align:center;background-color:lightblue">'+
					'调试工具，非技术人员慎用' +
				'</div>'+
				'').appendTo(document.body);
				//附加功能按钮
				jQuery('<input type="button" value="取消右键屏蔽" class="anybutton2 anybutton" style="margin:2px"/>')
					.click(function(e){cancelLimitClick(e);}).appendTo($menu);
				jQuery('<input type="button" value="点击复选框" class="anybutton2 anybutton" style="margin:2px"/>')
					.click(function(e){chkBtnClick(e);}).appendTo($menu);
				jQuery('<input type="button" value="iframe控制" class="anybutton2 anybutton" style="margin:2px"/>')
					.click(function(e){iframBtnClick(e);}).appendTo($menu);

				jQuery('<input type="button" value="切换数据库" class="anybutton2 anybutton" style="margin:2px"/>')
					.click(function(e){
						jQuery.ajax({
							url:'../store/commonReturn.asp?act=AdvanceDebugModeOpen',
							success:function(){
								top.window.location='../manager/setsql.asp';
							}
						});
					}
				).appendTo($menu);

				jQuery('<input type="button" value="提醒配置工具" class="anybutton2 anybutton" style="margin:2px"/>')
					.click(function(e){window.open('../inc/ReminderSetting.asp')}).appendTo($menu);

				jQuery('<textarea style="width:95%;height:60px;"></textarea>').appendTo($menu);
				jQuery('<input type="button" value="执行js" class="anybutton2 anybutton" style="margin:2px"/>')
					.click(function(e){execBtnClick.apply(this,arguments);}).appendTo($menu);

				jQuery('<hr/>').appendTo($menu);

				jQuery('<input type="button" value="关闭面板" class="anybutton2 anybutton" style="margin:2px"/>')
					.click(function(){debugMenu.hide();}).appendTo($menu);
			}else{
				$menu.show();
			}
		},
		hide:function(){
			if($menu){$menu.hide()}
		}
	};

	jQuery(document.body).mouseup(function(e){
		//同时按下ctrl、shift、alt键,并且点击鼠标右键时，弹出调试菜单
		if (e.which != 3) return;
		if (e.ctrlKey && e.shiftKey && e.altKey){
			debugMenu.show();
		}
	});

	function execBtnClick(){
		var $jsBox = jQuery(this).prev();
		try{
			eval($jsBox.val());
		}catch(e){
			alert('js执行出错,错误信息：\n' + e.toString());
		}
	}

	function cancelLimitClick(e){
		document.body.oncontextmenu = function(){return true;};
	}

	function chkBtnClick(e){
		jQuery(':checkbox').trigger('click');
	}

	function iframBtnClick(e){
		var $hifr = jQuery('iframe[alreadyShow!="1"][isNotHiddenIframe!="1"]');
		if ($hifr.size()>0){
			var left = 0;
			$hifr.each(function(){
				var $ifr = jQuery(this);
				if($ifr.height()<10 || $ifr.width()<10 || $ifr.css('display')=='none' || $ifr.css('visiblity')=='hidden'){
					$ifr.show().css({
						left:left,
						top:0,
						height:500,
						width:500
					});
					var $box = $ifr.parent()
					if ($box.position().left<0 || $box.position().top<0){
						$box.css({
							left:left,
							top:0,
							height:500,
							width:500
						});
					}
					left += 500;
					$ifr.attr('alreadyShow','1');
					return false;
				}else{
					$ifr.attr('isNotHiddenIframe','1');
				}
			});
		}else{
			jQuery('iframe[alreadyShow="1"][isNotHiddenIframe!="1"]').attr('alreadyShow','0').hide();
		}
	}
});



