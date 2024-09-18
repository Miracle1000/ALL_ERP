/*
description:仿照easyui的树控件编写的树形控件，支持级联展开，支持扁平树结构（id,pid格式），支持节点翻页功能
author:常明 2014-06-29
*/
(function($){
	function expandNode(target,node,cascade){
		var opts = $.data(target, 'tree').options;
		var td = $(node);
		if(td.attr('isCate')!='true') return;
		var isLeaf = td.attr('isLeaf')=='1';
		var panel = td.parent().next();
		if (panel.children('td').children().size()==0){
			request(target, panel.children('td').get(0), {
				id:td.attr('nid'),
				__pageSize:isLeaf?opts.leafPageSize:opts.nodePageSize,
				__recLimit:isLeaf?opts.leafLimit:opts.nodeLimit
			},function(){
				if (opts.onHeightChange){
					opts.onHeightChange.apply(this,[node]);
				}
				if(cascade){
					$(target).tree('expandAll');
				}
			});	// request children nodes data
		}
		panel.show();
		if(td.hasClass('tree-folder-closed')){
			td.removeClass('tree-folder-closed').addClass('tree-folder-open');
		}else if(td.hasClass('tree-lastfolder-closed')){
			td.removeClass('tree-lastfolder-closed').addClass('tree-lastfolder-open');
		}
	}
	
	function collapseNode(target, node){
		var opts = $.data(target, 'tree').options;
		var td = $(node);
		if(td.attr('isCate')!='true') return;
		var panel = td.parent().next();
		panel.hide();
		if(td.hasClass('tree-folder-open')){
			td.removeClass('tree-folder-open').addClass('tree-folder-closed');
		}else if($(node).hasClass('tree-lastfolder-open')){
			td.removeClass('tree-lastfolder-open').addClass('tree-lastfolder-closed');
		}
		if (opts.onHeightChange){
			opts.onHeightChange.apply(this,[node]);
		}
	}
	
	function toggleNode(target,node){
		var $node = $(node);
		if ($node.attr('isCate')!='true') return;
		if ($node.hasClass('tree-folder-open') || $node.hasClass('tree-lastfolder-open')){
			collapseNode(target,node);
		}else {
			expandNode(target,node);
		}
	}
	
	function loadData(target, td, data ){
		// clear the tree when loading to the root
		if (target == td) {
			$(target).empty();
		}
		var opts = $.data(target, 'tree').options;

		function getTreeHtml(nodes){
			var html=[],nodesData,canPage,pageCount;
			if (nodes.nodes){
				nodesData = nodes.nodes;
				canPage=nodes.mode=='node';
			}else{
				nodesData = nodes;
				canPage=false;
			}

			html.push("<table border='0' cellspacing='0' cellpadding='0' class='tree'>");
			var isLeaf=false;
			for (var i=0;i<nodesData.length ;i++ ){
				var node = nodesData[i];
				var menutype,listtype,text,iconType;
				if (target == td){
					iconType = canPage?'closed':'open';
				}else{
					iconType = 'closed';
				}

				var isCate = node.attributes.isCate;
				if (isCate){
					if (i==nodesData.length-1){
						menutype="class='tree-lastfolder-"+iconType+"'";
						listtype="class='tree-lastleaf-nodes'";
					}else{
						menutype="class='tree-folder-"+iconType+"'";
						listtype="class='tree-leaf-nodes'";
					}
					text=node.text;
				}else{
					text="<img src='"+ window.sysCurrPath +"images/icon_sanjiao.gif'>"+
						"<a class='tree-linkOfLeafNodes' href='javascript:void(0);'>"+node.text+"</a>";
					isLeaf = true;
				}

				var attributes = " nid='"+node.id+"'"+" pid='"+node.pid+"'";
				if (node.attributes){
					for (var attr in node.attributes){
						attributes+=" "+attr+"='"+node.attributes[attr]+"'";
					}
				}

				html.push(  "<tr>"+
								"<td "+menutype+" "+attributes+">"+text+"</td>"+
							"</tr>"+
							"<tr>"+
								"<td "+listtype+">");
				if (node.children && node.children.length>0){
					html.push(getTreeHtml(node.children));
				}
				html.push(		"</td>"+
							"</tr>");
			}
			html.push("</table>");
			if(canPage && nodes.pageCount>0){
				var pageSize=isLeaf?opts.leafPageSize:opts.nodePageSize;
				html.push('<span class="tree-pagebar" pid="'+(nodes.pid?nodes.pid:'')+'" isLeaf="'+isLeaf+'" pageSize="'+pageSize+'">'+
					'<span class="tree-pagebar-first-btn'+(nodes.pageIndex==1?'-disabled':'')+'" pg="1"></span>'+
					'<span class="tree-pagebar-prev-btn'+(nodes.pageIndex==1?'-disabled':'')+'" pg="'+(nodes.pageIndex-1)+'"></span>'+
					'<input type="text" class="tree-pagebar-page-box" maxlength="4" value="'+nodes.pageIndex+'">/'+nodes.pageCount+
					'<span class="tree-pagebar-next-btn'+(nodes.pageIndex==nodes.pageCount?'-disabled':'')+'" pg="'+(nodes.pageIndex+1)+'"></span>'+
					'<span class="tree-pagebar-last-btn'+(nodes.pageIndex==nodes.pageCount?'-disabled':'')+'" pg="'+nodes.pageCount+'"></span>'+
					'</span>'
				);
			}
			return html.join('');
		}

		td.innerHTML = getTreeHtml(data);
		$(td).find('td[isCate="true"]').unbind().bind('click',function(e){
			toggleNode(target,e.target);
			if (opts.onClick){
				opts.onClick.apply(this,[e,this]);
			}
			e.stopPropagation();
		});

		if (opts.onClick){
			$(td).find('.tree-linkOfLeafNodes').unbind().bind('click',function(e){
				opts.onClick.apply(this.parentElement,[e,this.parentElement]);
				e.stopPropagation();
			});
		}

		$('.tree-pagebar-first-btn,.tree-pagebar-prev-btn,.tree-pagebar-next-btn,.tree-pagebar-last-btn').unbind().one('click',function(e){
			var $btn = $(this);
			var $bar = $btn.parent();
			var $td = $bar.parent();
			var pageIndex=$btn.attr('pg'),
				pageSize=$bar.attr('pageSize'),
				pid=$bar.attr("pid"),
				isLeaf=$bar.attr("isLeaf")=='true';
			var param = {
				id:pid,
				__pageSize:pageSize,
				__pageIndex:pageIndex,
				__recLimit:isLeaf?opts.leafLimit:opts.nodeLimit
			};
			request(target,$td.get(0),param,function(){
				$td.find('.tree-pagebar-page-box').trigger('focus');
			});
		});

		$('.tree-pagebar-page-box').unbind().bind('keydown',function(e){
			var keyCode = e.keyCode;
			//键盘左右方向键，数字0到9，小键盘数字0到9，回车，退格（backspace）的键盘码
			var allowKeyCode=',37,39,48,49,50,51,52,53,54,55,56,57,96,97,98,99,100,101,102,103,104,105,13,8,';
			if (allowKeyCode.indexOf(','+keyCode+',')<0){
				e.returnvalue = false;
				return false;
			}

			var $box = $(this);
			if (keyCode==13){
				var $bar = $box.parent();
				var $td = $bar.parent();
				var pageSize=$bar.attr('pageSize'),
					pid=$bar.attr("pid"),
					isLeaf=$bar.attr("isLeaf")=='true';
				var param = {
					id:pid,
					__pageSize:pageSize,
					__pageIndex:this.value,
					__recLimit:isLeaf?opts.leafLimit:opts.nodeLimit
				};
				request(target,$td.get(0),param,function(){
					$td.find('.tree-pagebar-page-box').trigger('focus');
				});
			}else if (keyCode==37){
				if (!$box.prev().hasClass('tree-pagebar-prev-btn-disabled')){$box.prev().trigger('click');}
				e.returnvalue = false;
				return false;
			}else if (keyCode==39){
				if (!$box.next().hasClass('tree-pagebar-next-btn-disabled')){$box.next().trigger('click');}
				e.returnvalue = false;
				return false;
			}
			//document.title=keyCode;
		}).bind('focus',function(){
			this.select();
		});
	}

	function loadFilter(target,data,parent) {
		var opt = $.data(target, 'tree').options;
		var idFiled,textField,parentField;
		if (opt.parentField) {
			idFiled = opt.idFiled || 'id';
			textField = opt.textField || 'text';
			parentField = opt.parentField;
			
			var i,l,treeData = {
				pid:data.pid,
				pageIndex:data.pageIndex,
				pageCount:data.pageCount,
				mode:data.mode,
				nodes:[]},tmpMap = [];
			
			for (i = 0, l = data.nodes.length; i < l; i++) {
				tmpMap[data.nodes[i][idFiled]] = data.nodes[i];
			}
			
			for (i = 0, l = data.nodes.length; i < l; i++) {
				if (tmpMap[data.nodes[i][parentField]] && tmpMap[data.nodes[i][parentField]].attributes.isCate!=0 && data.nodes[i][idFiled] != data.nodes[i][parentField]) {
					if (!tmpMap[data.nodes[i][parentField]]['children']){
						tmpMap[data.nodes[i][parentField]]['children'] = [];
					}
					data.nodes[i]['text'] = data.nodes[i][textField];
					tmpMap[data.nodes[i][parentField]]['children'].push(data.nodes[i]);
				} else {
					data.nodes[i]['text'] = data.nodes[i][textField];
					treeData.nodes.push(data.nodes[i]);
				}
			}
			return treeData;
		}
		return data;
	}
	
	function request(target, td, param, callBack){
		var opts = $.data(target, 'tree').options;
		if (!opts.url) return;
		
		param = param || {};
		
		var folder = $(td);
		if(opts.loadingIcon) folder.height('16').addClass('tree-loading');

		$.ajax({
			type: 'post',
			url: opts.url,
			data: param,
			dataType: 'json',
			success: function(data){
				if(opts.loadingIcon) folder.removeClass('tree-loading');
				var dt = loadFilter(target,data);
				if (dt.length==0){
					folder.height('0');
				}
				loadData(target, td, dt);
				if (opts.onLoadSuccess){
					opts.onLoadSuccess.apply(this, arguments);
				}
				if (callBack){
					callBack.apply(this.arguments);
				}
			},
			error: function(){
				folder.removeClass('tree-loading').height('0');
				if (opts.onLoadError){
					opts.onLoadError.apply(this, arguments);
				}
			}
		});
	}
	
	$.fn.tree = function(options, param){
		if (typeof options == 'string'){
			switch(options){
				case 'options':
					return $.data(this[0], 'tree').options;
				case 'expandAll':
					return this.each(function(){
						var target = this;
						$(target).find('.tree-lastfolder-closed,.tree-folder-closed').each(function(){
							expandNode(target,this,true);
						});
						
					});
				case 'colspanAll':
					return this.each(function(){
						$(this).find('.tree-lastfolder-open,.tree-folder-open').trigger('click');
					});
				case 'reload':
					return this.each(function(){
						var state = $.data(this, 'tree');
						var opts = state.options;
						$(this).empty();
						request(this, this,{
							__pageSize:opts.nodePageSize,
							__recLimit:opts.nodeLimit
						});
					});
			}
		}
		
		var options = options || {};
		return this.each(function(){
			var state = $.data(this, 'tree');
			var opts;
			if (state){
				opts = $.extend(state.options, options);
				state.options = opts;
			} else {
				opts = $.extend({}, $.fn.tree.defaults, {url:$(this).attr('url')}, options);
				$.data(this, 'tree', {options: opts,tree:[]});
			}
			
			if (opts.url){
				var $tree = $(this);
				request(this, this,{
					__pageSize:opts.nodePageSize,
					__recLimit:opts.nodeLimit
				},function(){
					if(opts.lazyCascade){
						$tree.tree('expandAll');
					}	
				});
			}
		});
	};
	
	$.fn.tree.defaults = {
		url: null,
		loadingIcon:false,
		leafLimit:500,
		lazyCascade:false,
		nodeLimit:500,
		leafPageSize:20,
		nodePageSize:20,
		onLoadSuccess: function(){},
		onLoadError: function(){},
		onHeightChange: function(){},
		onClick: function(node){},
		onDblClick: function(node){}
	};
})(jQuery);


function __toggleNode(obj,cascade,callBack){
	if(!__tree){ return };

	var $obj = $(obj);
	var nid = $obj.attr('nid');
	var leafCate = parseInt($obj.attr('leafCate'));
	var $panel = $obj.parent().next().children();
	if($obj.hasClass('tree-folder-closed')){
		$obj.removeClass('tree-folder-closed').addClass('tree-folder-open');
		$panel.parent().show();
	}else if($obj.hasClass('tree-lastfolder-closed')){
		$obj.removeClass('tree-lastfolder-closed').addClass('tree-lastfolder-open');
		$panel.parent().show();
	}else if($obj.hasClass('tree-folder-open')){
		$obj.removeClass('tree-folder-open').addClass('tree-folder-closed');
		$panel.parent().hide();
	}else if($obj.hasClass('tree-lastfolder-open')){
		$obj.removeClass('tree-lastfolder-open').addClass('tree-lastfolder-closed');
		$panel.parent().hide();
	}
	autoWidth();
	autoHeight();

	if($panel.children().size()==0){//没有内容的需要尝试异步加载数据
		var params = __tree.attr('params');
		var data = {
				cstore:__tree.attr('cstore'),
				cbom: __tree.attr('cbom'),
				jybom: __tree.attr('jybom'),
				id:nid,
				__cascade:cascade,
				__iscp:leafCate,
				__pageIndex:1
		};
		if (params){
			var ps = params.split("&");
			for(var i=0;i<ps.length;i++){
				var p = ps[i].split("=");
				data[p[0]] = p[1];
			}
		}

		$.ajax({
			url:window.sysCurrPath+'inc/treeChildNodes.asp',
			cache:false,
			data:data,
			success:function(html){
				$panel.html(html).show();
				if(callBack){
					callBack.call(this.arguments);
				}
				autoWidth();
				autoHeight();
				if(!cascade) $panel.children().children().children(':last').find('.tree-pagebar-page-box').trigger('focus');
			},error:function(req){
				//alert(req.responseText);
			}
		});
	}
}

function autoWidth(){}
function autoHeight(){};


function __treePage(obj,act){
	if(!__tree){ return };

	var $obj = $(obj);
	var $bar = $obj.parent();
	var id = $bar.attr('nid');
	var $panel = $obj.parentsUntil('.tree-panel').last();
	var pageIndex = parseInt($bar.attr('pageIndex'));
	var pageCount = parseInt($bar.attr('pageCount'));
	var iscp = parseInt($bar.attr('iscp'));
	if(act=='first'){
		pageIndex = 1;
	}else if (act=='prev'){
		pageIndex = (pageIndex<=1?1:pageIndex-1);
	}else if (act=='next'){
		pageIndex = (pageIndex>=pageCount?pageCount:pageIndex+1);
	}else if (act=='last'){
		pageIndex = pageCount;
	}else{
		if (isNaN($obj.val())){
			alert('参数错误！');
			return;
		}
		var idx = parseInt($obj.val());
		pageIndex = (idx<1?1:(idx>pageCount?pageCount:idx));
	}

	var params = __tree.attr('params');
	var data = {
		cstore:__tree.attr('cstore'),
		id:$bar.attr('nid'),
		__iscp:iscp,
		__pageIndex:pageIndex
	};

	if (params){
		var ps = params.split("&");
		for(var i=0;i<ps.length;i++){
			var p = ps[i].split("=");
			data[p[0]] = p[1];
		}
	}

	$.ajax({
		url:window.sysCurrPath+'inc/treeChildNodes.asp',
		cache:false,
		data:data,
		success:function(html){
			if(id=='0'){
				if ($panel.parent().prev().children().attr('nid')){
					$panel.html(html);
				}else{
					$obj.parentsUntil(__tree).last().parent().html(html);
					__tree.html(html);
				}
				return;
			}else{
				$panel.html(html);
			}
			$panel.children().children().children(':last').find('.tree-pagebar-page-box').trigger('focus');
			if(window.__onAfterTreeNodePage){
				window.__onAfterTreeNodePage.call(this,[obj,act])
			}
		}
	});
}

function __pageBoxKeyDown(e,obj){
	var keyCode = e.keyCode;
	//键盘左右方向键，数字0到9，小键盘数字0到9，回车，退格（backspace）的键盘码
	var allowKeyCode=',37,39,48,49,50,51,52,53,54,55,56,57,96,97,98,99,100,101,102,103,104,105,13,8,';
	if (allowKeyCode.indexOf(','+keyCode+',')<0){
		e.returnvalue = false;
		return false;
	}

	var $box = $(obj);
	if (keyCode==13){
		__treePage(obj,null);
		return false;
	}else if (keyCode==37){
		if (!$box.prev().hasClass('tree-pagebar-prev-btn-disabled')){$box.prev().trigger('click');}
		e.returnvalue = false;
		return false;
	}else if (keyCode==39){
		if (!$box.next().hasClass('tree-pagebar-next-btn-disabled')){$box.next().trigger('click');}
		e.returnvalue = false;
		return false;
	}
	//document.title=keyCode;
}

function __toggleNodeCheck(obj,act){
	if(!__tree){ return };

	var div=jQuery(obj);
	if(!obj.checked){
		div.next().find(':checked').each(function(){this.click();});
		div.next().hide();
		div.prev().hide();
		div.next().find("input").attr("checked",false);
		div.next().find("div").css("display","none");
		resizeDiv("","");
	}else{
		if(div.next().children().size()==0){//没有内容的需要尝试异步加载数据
			var nid = div.attr('nid');
			var leafCate = parseInt(div.attr('leafCate'))
			$.ajax({
				url:window.sysCurrPath+'inc/treeStore.asp',
				cache:false,
				data:{
					cstore:__tree.attr('cstore'),
					id:nid,
					//__cascade:cascade,
					__iscp:leafCate,
					__act:act,
					__pageIndex:1
				},
				success:function(html){
					div.next().html(html);
					if (div.next().children().size()>0){div.next().show();}
					resizeDiv("","");
					//autoWidth();
					//autoHeight();
					//if(!cascade) $panel.children().children().children(':last').find('.tree-pagebar-page-box').trigger('focus');
				},error:function(req){
					//alert(req.responseText);
				}
			});
		}
		div.next().find("input").attr("checked",true);
		div.next().find("div").css("display","");
		if (div.next().children().size()>0){div.next().show();}
		div.prev().show();
		resizeDiv("","");
	}
}

function resizeDiv(StoreIds,product_CK){
	var obj = $("#scks");
	if (StoreIds.length>0){
		obj.find('input[name="product_CK_Sort"]').each(function(){
			if ((","+StoreIds+',').indexOf(","+this.val()+",")>=0){
				this.click();
			}
		});
	}

	if (product_CK.length>0){
		obj.find('input[name="StoreIds"]').each(function(){
			if ((","+product_CK+',').indexOf(","+this.val()+",")>=0){
				this.click();
			}	
		});
	}

	setTimeout(function(){
		var height =obj.find("div").first().height();
		if (height<200){
			obj.height(height+10);
		}else{
			obj.height(200);
		}
	},100);
}

$(function(){
	//$('#cpjsdiv').parent().css({'border':'1px solid #c0ccdd'});
	if(window.ActiveXObject) {
		//$("#__adv_search_btn").css("width","auto");//新的样式在ie下该按钮的宽度不能为auto；否则会换行
		$("#__adv_search_btn").attr("remark","本按钮的width属性被jquery.tree.js");
	}
});