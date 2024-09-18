
	tvw.canrepeatClick = true;
	tvw.onitemclick = function(o) {

		var v = o.value;
		insertHTML(v);
	}
	function insertHTML( val){
		
		var v = val.split("&|&");
		if(!v[1]){v[1]=""}
		if(!v[2]){v[2]="1"}
		if(!v[3]){v[3]="1"}
		var html = "<SPAN class=\"CtrlData\" unselectable=\"on\" contentEditable=\"false\" dbname=\""+ v[2] +"." + v[0] + "\">" + v[1] + "</SPAN>"

		var sHtml = html;
		var type = v[3];
		var dataid = v[2];
		var rowName = v[0];
		
		if(parent.window.editor){
			var MyEditor = parent.window.editor.editorBody;
		}
		if (rowName.indexOf("Code2_") == 0)
		{
			parent.window.ajax.regEvent("loadControl")
			parent.window.ajax.addParam("name","二维码")
			var r = parent.window.ajax.send();
			parent.window.eval(r);
			if(!parent.window.o.CtrlData){parent.window.o.CtrlData = {}}
			parent.window.o.CtrlData.text = escape(sHtml);
			parent.window.o.ResolveType = 1;
			parent.window.o.qrType = rowName.replace("Code2_","")
			var div = parent.window.ReBuildControl(parent.window.o);
		}
		else if (rowName.indexOf("Code1_") == 0)
		{
			parent.window.ajax.regEvent("loadControl")
			parent.window.ajax.addParam("name","条形码")
			var r = parent.window.ajax.send();
			parent.window.eval(r);
			if(!parent.window.o.CtrlData){parent.window.o.CtrlData = {}}
			parent.window.o.CtrlData.text = escape(sHtml);
			parent.window.o.ResolveType = 1;
			parent.window.o.brType = rowName.replace("Code1_","")
			var div = parent.window.ReBuildControl(parent.window.o);
		} 
		else
		{
			if(MyEditor){
				MyEditor.focus();
				var ResolveType = eval("parent.window.curreditSpan.obj.ResolveType");
				if(parseInt(type) == 3 && parseInt(ResolveType) != 3){
					confirm("明细类私有部件只能插入到明细控件中！");
					return false;
				}
				var CtrlData = eval("parent.window.curreditSpan.obj.DataID");
				if( parseInt(type) == 3 && CtrlData && parseInt(CtrlData) != dataid){
					confirm("同一控件不可以插入两种以上的明细部件！");
					return false;
				}
				var cName = MyEditor.parentElement.parentElement.parentElement.tagName.toLowerCase()
				if(parseInt(type) == 3 && parseInt(ResolveType) == 3 && cName != "tbody"){
					switch (cName){
						case "thead":
							var text = "表头";
						break;
						case "tbody":
							var text = "合计";
						break;
					}
					confirm("明细类私有部件只能插入到明细控件的表格内容中！\n不可以插入到到明细控件的" + text + "中！");
					return false;
				}
				if(parent.window.editor.editorRange){
					parent.window.editor.editorRange.select();
					parent.window.editor.editorRange.pasteHTML( sHtml );
				}else{
					parent.window.document.selection.createRange().pasteHTML( sHtml );
				}
				if(!CtrlData && type == 3){
					eval("parent.window.curreditSpan.obj.DataID = " + dataid);
				}
				parent.window.showattrlist(parent.window.curreditSpan)
			}
			else{
				if(type == "1"){
					//var div = parent.window.buildControl("文字","0");
					//return false;
					parent.window.ajax.regEvent("loadControl")
					parent.window.ajax.addParam("name","文字")
					var r = parent.window.ajax.send();
					parent.window.eval(r);
					if(!parent.window.o.CtrlData){parent.window.o.CtrlData = {}}
					parent.window.o.CtrlData.text = escape(sHtml);
					parent.window.o.ResolveType = 1;
					var div = parent.window.ReBuildControl(parent.window.o);
				}
				else if(type == "3"){
					//parent.window.buildControl("明细数据","3");
					parent.window.ajax.regEvent("loadControl")
					parent.window.ajax.addParam("name","明细数据")
					var r = parent.window.ajax.send();
					parent.window.eval(r);
					var tbDate = parent.window.o.tbDate
					var tBody = tbDate.tbody
					for(var i = 0; i < tBody.rows.length; i++){
						tBody.rows[i].cells[0].text = escape(sHtml);
					}
					parent.window.o.ResolveType = 3;
					var div = parent.window.ReBuildControl(parent.window.o);
				}
				var CtrlData = eval("div.parentElement.obj.DataID");
				if(!CtrlData){
					eval("div.parentElement.obj.DataID = " + dataid);
				}
				//eval("div.parentElement.fireEvent('onmousedown')");
				//eval("div.parentElement.fireEvent('onmouseup')");
				//parent.bodyPanelMsDown()
			}
			//parent.window.ActPage.fireEvent("onclick")
		}
	} 
	function setcolor(){
		MyEditor.focus();
		if (document.selection) {
			window.confirm(document.selection.createRange().htmlText);
		}
	}
