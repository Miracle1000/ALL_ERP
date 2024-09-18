//--【明细设置】按钮触发事件 hasInvented 是否包含虚拟
function showTreeSet(top, treetype, mxpxid, hasInvented) {
	var data = [];
	var data1 = [];
	var data2 = [];
	var data3 = [];
	var data4 = [];
	if(typeof(mxpxid)=='undefined'){mxpxid = -1}
	switch (treetype)
	{
		case 3:	
			var units = $("select[name^='unit_']");
			if (units.length == 0)
			{
				alert("请选择产品明细！");
				return;
			}
			
			for (var i = 0; i < units.length; i++)
			{
				var name = units[i].getAttribute("name");
				var mxid = name.replace("unit_","");
				var v = units[i].value;
				data.push(mxid + String.fromCharCode(2) + v);
			}
			var num1 = $("input[name^='num1_']");
			for (var i = 0; i < num1.length; i++)
			{
				var name = num1[i].getAttribute("name");
				var mxid = name.replace("num1_","");
				var v = num1[i].value;
				if (v.length == 0)
				{
					v = "0";
				}
				data1.push(mxid + String.fromCharCode(2) + v);
			}
			var date2 = $("input[name^='date1_']");
			for (var i = 0; i < date2.length; i++)
			{
				var name = date2[i].getAttribute("name");
				var mxid = name.replace("date1_","");
				var v = date2[i].value;
				if (v.length == 0)
				{
					v = "";
				}
				data2.push(mxid + String.fromCharCode(2) + v);
			}
			var intro = $("textarea[name^='intro_']");
			for (var i = 0; i < intro.length; i++)
			{
				var name = intro[i].getAttribute("name");
				var mxid = name.replace("intro_","");
				var v = intro[i].value;
				if (v.length == 0)
				{
					v = "";
				}
				data3.push(mxid + String.fromCharCode(2) + v);
			}
			break;
		default:
			var units = $("select[name^='unit_']");
			if (units.length == 0)
			{
				alert("请选择产品明细！");
				return;
			}
			
			for (var i = 0; i < units.length; i++)
			{
				var name = units[i].getAttribute("name");
				var mxid = name.replace("unit_","");
				var v = units[i].value;
				data.push(mxid + String.fromCharCode(2) + v);
			}
			var num1 = $("input[name^='num1_']");
			for (var i = 0; i < num1.length; i++)
			{
			    var v = num1[i].value;
			    if (v.length == 0) v = "0";
			    var name = num1[i].getAttribute("name");
			    var mxid = name.replace("num1_", "");
                if (/^\d+$/.test(mxid)) {
                    var Attr2Objs = $("select[name^='AttrsBatch_Attr2_" + mxid + "']");
                    var Attr2Objshidden = $("input[name^='AttrsBatch_Attr2_" + mxid + "']"); //AttrsBatch_Attr2_8790
                    var attr2 = Attr2Objs.length > 0 ? Attr2Objs[0].value : (Attr2Objshidden.length > 0 ? Attr2Objshidden[0].value : 0);
                    data1.push(mxid + String.fromCharCode(2) + v + String.fromCharCode(2) + attr2);
			    } else {
			        mxid = mxid.replace("AttrsBatch_Attr1_", "");//AttrsBatch_Attr1_1146_169_0_0
                    var Attr2Objs = $("select[name^='AttrsBatch_Attr2_" + mxid.split("_")[0] + "']")
                    var Attr2Objshidden = $("input[name^='AttrsBatch_Attr2_" + mxid.split("_")[0]  + "']"); //AttrsBatch_Attr2_8790
                    var Attr2 = Attr2Objs.length > 0 ? Attr2Objs[0].value : (Attr2Objshidden.length > 0 ? Attr2Objshidden[0].value : 0);// AttrsBatch_Attr2_1146
			        if (Attr2.length == 0) Attr2 = "0";
			        data4.push(mxid + String.fromCharCode(2) + v + String.fromCharCode(2) + Attr2);
			    }
			}
			var date2 = $("input[name^='date1_']");
			for (var i = 0; i < date2.length; i++)
			{
				var name = date2[i].getAttribute("name");
				var mxid = name.replace("date1_","");
				var v = date2[i].value;
				if (v.length == 0)
				{
					v = "";
				}
				data2.push(mxid + String.fromCharCode(2) + v);
			}
			var intro = $("textarea[name^='intro_']");
			for (var i = 0; i < intro.length; i++)
			{
				var name = intro[i].getAttribute("name");
				var mxid = name.replace("intro_","");
				var v = intro[i].value;
				if (v.length == 0)
				{
					v = "";
				}
				data3.push(mxid + String.fromCharCode(2) + v);
			}
			break;
	}
	var json = {};
	json.__msgid = "saveMxpxUnit";
	json.data = data.join(String.fromCharCode(1));
	json.data1 = data1.join(String.fromCharCode(1));
	json.data2 = data2.join(String.fromCharCode(1));
	json.data3 = data3.join(String.fromCharCode(1));
	json.data4 = data4.join(String.fromCharCode(1));
	var aj = $.ajax({
		type:'post',
		async: false,
		url:'../bomlist/Bom_Trees_List.asp',
		cache:false,  
		dataType:'html', 
		data:json,
		success: function(data){
			if (data != "true"){return;}
		},
		error:function(data){}
	});
	if(mxpxid==-1){
	    window.open('../BomList/bom_trees_list.asp?hasInvented=' + (hasInvented==false ? "0" :"1") + '&treeType=' + treetype + '&top=' + top, 'newwproductin', 'width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
	}else{
		window.open('../BomList/bom_trees_listView.asp?treeType='+treetype+'&top=' + top+'&mxpxid='+ mxpxid,'newwproductinView','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
	}
}

function stopBubble(e){
//一般用在鼠标或键盘事件上
	if(e && e.stopPropagation){
		//W3C取消冒泡事件
		e.stopPropagation();
	}else{
		//IE取消冒泡事件
		window.event.cancelBubble = true;
	}
}
// -->
