 //--- 编辑器图片显示控制 begin ---
	jQuery(function () {
	    window.setTimeout(function () { __ImgBigToSmall(); FilePreviewAndDownload();}, 100);
    })
	function __ImgBigToSmall(){
		try{
			var defWidth = 200;	
			var defHeight = 150;
			jQuery(".ewebeditorImg img,.ewebeditorImg_plan img").each(function (index, element) {
				var parentsVal = jQuery(this).closest(".ewebeditorImg_plan").html();		//判断是否为日程列表 不是则返回 null
				var w  = jQuery(this).width();	//实际宽度
				var h  = jQuery(this).height(); //实际高度
				//缩放后的高度 =（默认宽度*实际高度）/ 实际宽度
				if(w > defWidth){
					var thumbH = (defWidth * h) / w;
					jQuery(this).css({ width: '200px', height: thumbH+"px" });				
				}
				//缩放后的宽度 =（默认高度*实际宽度）/ 实际高度
				else if(h > defHeight){
					var thumbW = (defHeight * w) / h;	
					jQuery(this).css({ width: thumbW+"px", height: '150px' });	
				}
				
				//判断日程列表不显示弹出框
				if(parentsVal == null){
					//缩放后的图片可点击，弹出窗口显示原图
					if(w > defWidth || h > defHeight){
						jQuery(this).css({ margin: '5px', cursor: 'pointer' });	
						jQuery(this).attr("title","点击放大查看原图"); 
						var url = jQuery(this).attr("src");						
						jQuery(this).click(function () {
						    window.open(window.sysCurrPath + 'inc/img.asp?url=' + escape(url))
						});
					}
				}
				
			});
		
		}catch(e){
			
		}
	}
//--- 编辑器图片显示控制 end ---
//编辑器预览弹层控制start---
	function FilePreviewAndDownload(e) {
	    var FILETYPE = ['txt', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'pdf']
	    try {
	        $(document).find(".ewebeditorImg a").bind("mouseover", function (e) {
            var type = e.target.innerText.split(".");
            if (type[type.length - 1] && (FILETYPE.join(",").indexOf(type[type.length - 1]) >= 0 || type[type.length - 1].indexOf("预览下载") >= 0) && e.target.getAttribute("href")) {
                window.paramLinkAdress = e.target.href.substr(e.target.href.indexOf("pf="));
                window.EDITORLOADLINK = e.target;
                if(!e.target.children.length){
                    var div = document.createElement("span");
                    div.onclick = function () { return false; }
                    div.innerHTML = '<span class="darrow"></span><span class="blank"></span><span title="" onclick="window.open(\'../\'+window.sysCurrPath+\'sysn/view/comm/UpLoaderFilePreview.ashx?\' + paramLinkAdress,\'newwin80\',\'width=1000,height=820,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100\')" class="preview">预览</span><span title="" onclick="FireEvent1(window.EDITORLOADLINK,\'click\')" class="downloadL">下载</span>'
                    $(this).append($(div).addClass("viewAndLoad"))
                }
	        }
	        })
	    } catch (e) { }

	}

	function FireEvent1(obj, eventName) {
	   try {
	       obj.attachEvent('on' + eventName.toLowerCase().replace("on", ""), function (event) {
	            window.open(obj.href, '_self')
	        });
	    }
	    catch (e) {
	        var event = document.createEvent('MouseEvents');
	        event.initEvent(eventName.toLowerCase().replace("on", ""), true, true);
	        obj.dispatchEvent(event);
	    }
	}

//编辑器预览弹层控制end---


//彻底解决jQuery使用ajax提交数据时乱码问题
jQuery.param=function(a){ 
	var s = [];
	function encode(str){ str=escape(str);str=str.replace(/\+/g,'%u002B');return str;}
	function add(key,value){s[s.length] = encode(key) + '=' + encode(value);}
	if (jQuery.isArray(a) || a.jquery){
		jQuery.each(a,function(){add(this.name,this.value); }); 
	}else{
		for (var j in a){
			if (jQuery.isArray(a[j])){
				jQuery.each(a[j],function(){ add(j,this); }); 
			}else{
				add(j,jQuery.isFunction(a[j])?a[j]():a[j]); 
			}
		}
	}
	return s.join("&").replace(/%20/g,"+"); 
} 


jQuery(function () {
    jQuery("table[id=content]").removeAttr("cellspacing");
});

