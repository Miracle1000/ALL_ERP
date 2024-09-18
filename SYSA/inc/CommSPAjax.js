function SpClinetClass(){
	var  base = new Object();
	base.onProcComplete = null;   //接口函数
	//ADDobj 审批信息对象添加位置 (表单对象)
	//ty 区分是否考虑金额 1 不考虑 2 考虑
	//spord 当前需要审批的单据ord
	//page  单据流程 在 CommSPConfig.asp中设置流程分类 exp : "budget"
	//money 考虑金额时 的金额值, 默认为undefined, 为不考虑金额.
	//sptype 同一审批流程下不同的流程分支, 默认为0	
	//useCateid 单据使用人员，如果没有则默认为0
	base.GetNextSP = function(page, spord , money, sptype, useCateid, isback, ADDobj , top , left, virPath){
		if(!ADDobj){
		    try {
		        ADDobj = window.event.srcElement.form;
		        if (!ADDobj) ADDobj = document.body;
		    } catch (e) { ADDobj = document.body; }
		}
		if(typeof(money) == "undefined"){
			money = 0;
			ty = 1;
		}else{ty = 2;}
		var noleft = false;
		if(typeof(sptype) == "undefined"){sptype = 0;}
		if(typeof(useCateid) == "undefined"){useCateid = 0;}
		if(typeof(isback) == "undefined"){isback = "";}
		if(typeof(top) == "undefined"){top = 350;}
		if(typeof(left) == "undefined"){noleft = true; left = 450;}
		if(typeof(virPath) == "undefined"){virPath = "";}
		var xmlHttpSP = false;
		try{xmlHttpSP = new ActiveXObject("Msxml2.XMLHTTP");}
		catch (e){
			try{xmlHttpSP = new ActiveXObject("Microsoft.XMLHTTP");}
			catch (e2){xmlHttpSP = false;}
		}
		if (!xmlHttpSP && typeof XMLHttpRequest != 'undefined'){xmlHttpSP = new XMLHttpRequest();}
		var r="";
		var url="../inc/CommSPAjax.asp?ty="+ty+"&top="+spord+"&bill="+page+"&money1="+money+"&sptype="+sptype+"&useCateid="+useCateid+"&reback="+isback;
		if(virPath!=""){
			url= virPath+"SYSA/inc/CommSPAjax.asp?ty="+ty+"&top="+spord+"&bill="+page+"&money1="+money+"&sptype="+sptype+"&useCateid="+useCateid+"&reback="+isback;
		}
		//http://127.0.0.1:88/inc/CommSPAjax.asp?ty=1&top=60506&bill=tel&money1=0&sptype=0&useCateid=0;		
		xmlHttpSP.open("GET", url, false);
		xmlHttpSP.setRequestHeader("If-Modified-Since","0");
		xmlHttpSP.onreadystatechange = function () {
			if (xmlHttpSP.readyState == 4) {
				r= xmlHttpSP.responseText;
			}
		};
		xmlHttpSP.send(null);
		if (r.indexOf("$#")<0){
			alert(r);
			return false ;
		}
		var spid=r.split("$#")[0];
		var obj = document.getElementById("__sys_sp_clientDiv");
		if(!obj) {
			if(document.getElementById("sp") || document.getElementsByName("sp").length>0) {
				alert("重复定义对象sp");
				return false;
			}
			if(document.getElementById("cateid_sp") || document.getElementsByName("cateid_sp").length>0) {
				alert("重复定义对象cateid_sp");
				return false;
			}
			if(document.getElementById("status") || document.getElementsByName("status").length>0) {
				alert("重复定义对象status");
				return false ;
			}
			obj=document.createElement("div");
			obj.id="__sys_sp_clientDiv";
			obj.style.cssText="display:none;";
			var html="<input type='hidden' name='sp' id='sp'><input type='hidden' name='cateid_sp' id='cateid_sp'><input type='hidden' name='status' id='status'>";
			obj.innerHTML=html;
			ADDobj.appendChild(obj);
		}
		var sp= document.getElementById("sp");
		var cateid_sp = document.getElementById("cateid_sp");
		var status =document.getElementById("status");
		if(spid!="0"){
			obj = document.getElementById("_sp_usr");
			if(!obj) {
				obj=document.createElement("div");
				obj.id="_sp_usr";
				obj.cssName="easyui-dialog";
				obj.title="审批人选择";
				obj.style.cssText="width:340px;height:210px;padding:5px;background: #fafafa;top:"+top+"px;left:"+left+"px;";
				obj.closed="true";
				obj.modal="true";
				document.body.appendChild(obj);
			}
			//obj.closable="false";
			html = "<div id='spdiv'>";
			html = html+"<table width='100%' border='0' cellpadding='5' cellspacing='" + (document.getElementById("comm_itembarbg")?0:1) + "' bgcolor='#C0CCDD' id='content'>";
			html = html+"<tr><td colspan='4'>请选择下级审批人</td></tr>";
			html = html+"<tr><td width='42%'><div align='right'>下级审批人：</div></td><td width='58%' colspan='3'><div align='left'><span class='gray'>";
			html = html+"<select name='lead' id='spuser' class='gray'><option value=''></option>";
			var cates=r.split("$#")[1].split("|");
			for (var i=0 ;i<cates.length ;i++ ){
				if (cates[i].length>0){
					html = html + "<option value='"+ cates[i].split("=")[0] +"'>"+ cates[i].split("=")[1] +"</option>";
				}
			}
			html = html + "</select>";
			html = html + "<input id='sp_id' type='hidden' value='"+ spid +"'>";
			html = html+"<span id='_sp_errmsg' style='color:red;font-size:12px'></span>";
			html = html+"</span>";
			html = html+"</div></td></tr>";
			html = html+"<tr><td colspan=4 align='center' style='border:0'><input type='button' class='oldbutton anybutton' value=' 确定 ' id='_sp_sbmit'>&nbsp;&nbsp;<input type='button' class='oldbutton anybutton' value=' 取消 ' id='_sp_close' ></td></tr>";
			html = html+"</table></div>";
			obj.innerHTML=html;
			document.getElementById("_sp_sbmit").onclick = base.submithandle(spid, ADDobj , spord);
			$("#_sp_close").click(function(){
				$('#_sp_usr').window('close');
			});
			//var scrollH = document.documentElement.scrollTop || document.body.scrollTop;
			//var inttop = 200 + "px";
			scrollH = $(document).scrollTop() + ($(window).height()-260) * 0.5;
			scrollW = left;
			if(noleft==true){scrollW = ($(window).width() - $('#_sp_usr').outerWidth())/2;}
			$('#_sp_usr').window({top:scrollH, left:scrollW	});
			$('#_sp_usr').window('open');
		}
		else 
		{
			sp.value=0;
			cateid_sp.value=0;
			status.value =0;
			if(base.onProcComplete){
				base.onProcComplete(spord , 0 , 0 ,ADDobj);
			}else{
				ADDobj.submit();
			}
		}
	}
	

	base.submithandle = function (spid, ADDobj , spord)  {
		return function()
		{
			var sp= document.getElementById("sp");
			var cateid_sp = document.getElementById("cateid_sp");
			var status =document.getElementById("status");
			var spuser = document.getElementById("spuser");
			if(spuser.value=="")
			{
				document.getElementById("_sp_errmsg").innerHTML="请选择审批人！";
				spuser.focus();
			}
			else
			{
				$('#_sp_usr').dialog('close');
				sp.value=spid;
				cateid_sp.value=spuser.value;
				status.value=1;
				if(base.onProcComplete)
				{
					base.onProcComplete(spord, spid , spuser.value , ADDobj);
				}
				else
				{
					ADDobj.submit();
				}
			}
						
		}
	}




	return base;
}
window.spclient = new SpClinetClass();