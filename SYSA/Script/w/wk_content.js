function setshowyw(){
	var dis=0;
	$('.ywcss2').each(function(){
		if ($(this).css("display")=="none") { $(this).css("display",""); } 
		else  { $(this).css("display","none"); }
	});
}

function setshowcw(){
	var dis=0;
	$('.cwcss2').each(function(){
		if ($(this).css("display")=="none") { $(this).css("display",""); } 
		else { $(this).css("display","none"); }
	});
}

function loadNextPreMsg() {
	var preurl = "";
	var nexturl = "";
	var geteof = true,  getbof = true;
	var odoc = null;
	var win = null;
	if(window.opener) {
		try{
			var lc = window.opener.location.href.toLowerCase();
			if(lc.indexOf("work/telhy.asp")>0 || lc.indexOf("work/telhy_view.asp")>0) {
				odoc = window.opener.document;
				win = window.opener;
			}
		}catch(e){}
		if( odoc ){
			try{
				//如果没有队列，创建详情上一页，下一页队列
				if(!win.__content_list) {
					var buttons = odoc.getElementsByName("Submit3");
					win.__content_list = "";
					for(var i = 0; i < buttons.length ; i ++)
					{
						bn = buttons[i];
						win.__content_list = win.__content_list + (i > 0 ? ";" : "") + bn.getAttribute("dataid") + "," + bn.getAttribute("dataurl");
					}
					if  (odoc.getElementById("page_eof").value*1 == 1) {
						win.__content_list = win.__content_list + ";0";
					}
					if  (odoc.getElementById("page_bof").value*1 == 1) {
						win.__content_list = "0;" + win.__content_list;
					}
				}
				buttons = win.__content_list.split(";")
				for(var i = 0; i < buttons.length ; i ++)
				{
					bn = buttons[i].split(",");
					if( bn[0] == window.curr_ord ) {
						if(i>0) {
							if(buttons[i-1]!="0") { preurl =  buttons[i-1].split(",")[1]; }
							getbof = false;
						}
						if(i<buttons.length-1) { 
							if(buttons[i+1]!="0") { nexturl = buttons[i+1].split(",")[1];}
							geteof = false;
						}
						break;
					}
				}
			}catch(e){}
		}
	}
	if( (getbof || geteof) && win ) {
		$.ajax({
		  type: "POST", url: "pre_next_ajax.asp",
		  data: {
				px_v: odoc ? odoc.getElementById("px_1").value : "",
				Str_Result_v :  odoc ? odoc.getElementById("ReportOrds_1").value : "",
				join_Str_Result_v : odoc ? odoc.getElementById("join_Str_Result_1").value : "",
				persons_result_v : odoc ? odoc.getElementById("persons_result_1").value : "",
				Eof : (geteof ? 1 : 0),
				Bof : ((getbof && !geteof) ? 1 : 0),
				currord : window.curr_ord
		  },
		  success: function(data) {
			 if(data.indexOf("nxts=")==0) {
				v = data.replace("nxts=","")
				win.__content_list = win.__content_list + ";" + v;
				if(v.indexOf(",") > 0 ) {
					fv = v.split(";")[0].split(",")[1]
					$('#nxtBtn').attr("ucode",fv);
					$('#nxtBtn').attr("disabled",false); 
				}
			 }
			 if(data.indexOf("pres=")==0) {
				v = data.replace("pres=","")
				win.__content_list = v + ";" + win.__content_list;
				if(v.indexOf(",") > 0 ) {
					var vs = v.split(";");
					fv = vs[vs.length-1].split(",")[1]
					$('#preBtn').attr("ucode",fv);
					$('#preBtn').attr("disabled",false); 
				}
			 }

		  },
		  error : function(r) {alert(r.responseText)}
		});
		
	}
	if(preurl!="") { $('#preBtn').attr("ucode",preurl); } else { $('#preBtn').attr("disabled",true);  }
	if(nexturl !="") { $('#nxtBtn').attr("ucode",nexturl); } else { $('#nxtBtn').attr("disabled",true);  }
	if(win) {
		$("#nextorprediv").css("display","block");
	}
}

if(document.getElementById("nextorprediv")) {
	loadNextPreMsg();
}