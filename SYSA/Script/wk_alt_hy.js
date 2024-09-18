
	try{
		var openr = top.window.opener;
		var frm = openr.document.getElementById('rfresh');
		if(frm){
			openr.RreshElement('rfresh');
		}
		else {
			if (openr.DoRefresh)
			{
				//DoRefresh为父页面提供的刷新函数， 参数为true ，表示异步刷新，参数为false ,表示同步刷新。
				openr.DoRefresh(false);  
			}
			else {
				openr.location.reload();
			}
		}
		
	}catch(e){}
	top.window.close();
