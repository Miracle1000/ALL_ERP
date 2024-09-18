<!DOCTYPE HTML>
<html>
<head>
    <title></title>
    <meta http-equiv=Content-Type content="text/html;charset=utf-8">
    <script>
        window.SysConfig={"VirName":"", "VirPath":"../../"};
    </script>
	<script type="text/javascript" charset="utf-8" src="../inc/jQuery-1.7.2.min.js?ver=<%=Application("sys.info.jsver")%>"></script>
    <script type="text/javascript" charset="utf-8" src="../../SYSN/view/editor/ueditor.config.js?ver=<%=Application("sys.info.jsver")%>"></script>
    <script>
//		if(!window.top.UserInfo){
//			document.write("<" + "script type='text/javascript' charset='utf-8' src='UserInfo.ashx'></scr"  + "ipt>");
//		}
        //判断邮件发送页面；
        var _iframe=window.parent.document.getElementById("eWebEditor1")
        if(_iframe&&_iframe.getAttribute("src")&&_iframe.getAttribute("src").indexOf("disupload=1")>=0){
        var i=window.UEDITOR_CONFIG.toolbars[0].indexOf('simpleupload');
        var j=window.UEDITOR_CONFIG.toolbars[0].indexOf('insertframe');
        window.UEDITOR_CONFIG.toolbars[0].splice(i,j-i)
        }
		//打印模板使用老编辑器 在moban/eWebEditor.asp中修改
    </script>
	<%if request.QueryString("ismobanprinter") = "1" then	%>
	<script>
		window.EditorHeightChangeProxy = function(v){
			var pbox = parent.document.getElementById("pageHeight");
			var pv = (pbox.value*1 + v*5).toFixed(1);
			if(pv<6) {return;}
			 pbox.value = pv;
			parent.changePageSize();
		}
	</script>
	<%end if %>
    <script type="text/javascript" charset="utf-8" src="../../SYSN/view/editor/ueditor.all.min.js?ver=<%=Application("sys.info.jsver")%>"> </script>
    <!--建议手动加在语言，避免在ie下有时因为加载语言失败导致编辑器加载失败-->
    <!--这里加载的语言文件会覆盖你在配置项目里添加的语言类型，比如你在配置项目里配置的是英文，这里加载的中文，那最后就是中文-->
    <script type="text/javascript" charset="utf-8" src="../../SYSN/view/editor/lang/zh-cn/zh-cn.js?ver=<%=Application("sys.info.jsver")%>"></script>
    <style type="text/css">
      body, html {margin:0px;height:100%}
	  html {overflow-y:hidden;} 
	  #edui1_bottombar {
		  display:block; 
		  position:relative;
		  z-index:1000;
		  height:45px;
		  background-color:white;
		  box-sizing:border-box;
		  background-color:#f8f8ff;
	  }
      a.zb-button, button.zb-button, input.zb-button, div.zb-button, .lvw_cell button, .l-toolbar-item button {
            color: #000;
			background: #EFEFEF;
			border: 1px solid #EFEFEF;
			text-align: center;
			font-size: 14px;
			cursor: pointer;
			padding: 0 10px;
			*padding: 0 2px;
			white-space: nowrap;
			padding-top: 0;
			height: 30px;
			line-height: 28px;
			box-sizing: border-box;
			border-radius: 3px;
			margin: 0px 3px;
			transition: all 0.2s ease-in-out;
			-moz-transition: all 0.2s ease-in-out;
			-webkit-transition: all 0.2s ease-in-out;
			-o-transition: all 0.2s ease-in-out;
        }
      a.zb-button, button.zb-button:hover, div.zb-button:hover, input.zb-button:hover, .lvw_cell button:hover, .l-toolbar-item button:hover {
            
        }
      table.billuidetails div.sub-field.gray, div.sub-field.gray div { color: #585858;}
      div.editor-mybuttom {
            padding-top: 9px;
            padding-bottom: 0;
       }
	  #edui1_message_holder {display:none;}
    </style>
	<script>
		String.prototype.ReplaceAll = function(s1, s2) {
				return this.replace(new RegExp(s1, "igm"), s2);
		}
		window.oldeditheight = 0;
		window.editboxReadyOK = false;
		function onbodyresize(){
			if(window.editboxReadyOK!=true) {return; }
			var newHeight = document.documentElement.offsetHeight-40-document.getElementById("edui1_toolbarbox").offsetHeight;//40是底部拓展按钮行的高；
			if(window.oldeditheight!=newHeight && newHeight>0){
				window.oldeditheight = newHeight;
				try{
                    UE.getEditor("editor").setHeight(newHeight);
                }catch(e){
                    UE.getEditor("editor").ready(function(){UE.getEditor("editor").setHeight(newHeight)})//规避ie11下初始化时编辑器body未加载好的情况
                }  
                var editor3=document.getElementById("ueditor_0"); //去掉滚动条
               (editor3.contentWindow||editor3.window).document.body.style.height = ""
			}
		}
		
		window.bindFormObject = function(){
           setParentsTdPadding()
			if(window.parent==window) {return;}
			var id = "<%=request.querystring("id")%>";
			var frms = window.parent.document.getElementsByTagName("iframe");
			for (var i=0; i<frms.length; i++)
			{
				var frmbox = frms[i];
				if(frmbox.contentWindow==window){
					window.CurrEditFrame = frmbox;
					window.CurrEditFrame.width = "99.8%";//设置编辑器宽度；
				}
			}
			var txtboxs =  window.parent.document.getElementsByName(id);
                txtboxs=txtboxs.length?txtboxs:[window.parent.document.getElementById(id)]; //有的id 表示的是textarea的id 
			if(txtboxs.length>0){
				window.CurrEditBox = txtboxs[0];
                if(parent && parent.window.AddDoSaveHack){
                    parent.window.AddDoSaveHack(window.updateFieldValue);
                } else {
				    $(window.CurrEditBox.form).bind("submit", window.updateFieldValue);
                }
				try{
					window.OnEditBoxLoad();
				} catch(ex){
					setTimeout( window.OnEditBoxLoad, 100);
				}
				UE.getEditor("editor").addListener("contentChange",window.updateFieldValue);
			}
		}

		window.updateFieldValue = function(){
			window.CurrEditBox.value = window.getHtmlValue();
		}
      
		window.getHtmlValue = function(){
			var html = UE.getEditor('editor').getContent();
			html = html.replace(/\'/g,"&#39;");
			html = html.ReplaceAll("delete","d&#101;lete");
			html = html.ReplaceAll("update","updat&#101;");
			html = html.ReplaceAll("select","s&#101;lect");
			return html;
		}
        
		window.OnEditBoxLoad = function(){
           //if(!UE.getEditor("editor").body){UE.getEditor("editor").ready(function(){UE.getEditor("editor").setContent(window.CurrEditBox.value)});window.editboxReadyOK = true;}
			try{
                UE.getEditor("editor").setContent(window.CurrEditBox.value.ReplaceAll("select","s&#101;lect"));
            }catch(e){
                UE.getEditor("editor").ready(function(){UE.getEditor("editor").setContent(window.CurrEditBox.value)});window.editboxReadyOK = true;
            }            
			window.editboxReadyOK = true;
			onbodyresize();
		}


		function SetEditBoxHeight(h){
			if(!window.CurrEditFrame) { return; }
			if((window.CurrEditFrame.height.replace("px","")*1 + h)<=250) { alert('已经是最小高度了');return;}
			window.CurrEditFrame.height = window.CurrEditFrame.height.replace("px","")*1 + h+"px";
		}

		$(document).bind("click", function(e){
            var title=e.target.getAttribute("title")
            if(title){     //增大减小按钮 改变编辑区的高度
                switch(title){
                case "增高编辑区":
                SetEditBoxHeight(50);
                if(window.parent.setparentheight){try{window.parent.setparentheight()}catch(e){}}//营销商品添加 编辑器高度增加页面显示不完全
                break;
                case "减小编辑区":
                SetEditBoxHeight(-50);
                break;
                }
            }
			var dlgs = $("div.edui-dialog,div.edui-popup-body");
			var maxh = 0;
			for(var i= 0; i<dlgs.length; i++){
				var odiv = dlgs[i];
				var nh = $(odiv).offset().top*1 + odiv.offsetHeight;
				maxh = nh> maxh? nh: maxh;
			}
			if(maxh>document.documentElement.offsetHeight){
				SetEditBoxHeight( maxh-document.documentElement.offsetHeight + 20);//弹层出现设置body的值增大，使弹层完整呈现；
			}

		});


        window.syncText = function(){
            window.updateFieldValue();//保存时更新隐藏textarea的值；
        }

        window.getHTML=function(){return window.getHtmlValue()} //获取编辑器里的内容

        function setParentsTdPadding (){     //给编辑器添加边框
        var id = "<%=request.querystring("id")%>";
        var textarea =window.parent.document.getElementsByName(id)[0];
        textarea=textarea?textarea:window.parent.document.getElementById(id);
        if(textarea){try{$(textarea).siblings("iframe")[0].style.border="1px solid #c0ccdd";}catch(e){ try{window.parent.document.getElementById("eWebEditor1").style.border="1px solid #c0ccdd";}catch(e){}}}
        }
	</script>
	<link type="text/css" href="../../SYSN/view/editor/themes/brand.<% 
	if (application("sys.info.configindex") & "") = "3" then 
		response.write "mozi" 
	else
		response.write "zbintel"
	end if
	%>.css?ver=<%=Application("sys.info.jsver")%>" rel="stylesheet"/>
</head>
<body onload='bindFormObject();' onresize="onbodyresize()">
<script id="editor" type="text/plain" style="width:99.9%;height:200px;"></script>
<script>UE.getEditor('editor');</script>
</body>
</html>