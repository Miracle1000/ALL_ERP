function callServer2() {
  var url = "liebiao_tj.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2();
  };
  xmlHttp.send(null);
}
function updatePage2() {
var test7="ht1"
  if (xmlHttp.readyState < 4) {
	ht1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	ht1.innerHTML=response;
	xmlHttp.abort();
  }
}


Array.prototype.remove=function(dx){ 	//重构数组的删除元素操作
    if(isNaN(dx)||dx>this.length){return false;} 
    for(var i=0,n=0;i<this.length;i++){ 
        if(this[i]!=this[dx]){ 
            this[n++]=this[i] 
        } 
    } 
    this.length-=1 
} 

var hwndsp=null,hwndrk=null;

function test()
{
  if(!confirm('确认删除吗？')) return false;
}

function mm(form)
{
	for (var i=0;i<form.elements.length;i++)
	{
		var e = form.elements[i];
		if (e.name != 'chkall')
		e.checked = form.chkall.checked;
	}
}

function batdel(){		//批量删除
	var selectid = "";
	if(typeof(document.form1.selectid.length)=="undefined"){
		if(document.form1.selectid.checked==true){
			selectid = document.form1.selectid.value;
		}
	}else{
		for(i=0;i<document.form1.selectid.length;i++){
			if(document.form1.selectid[i].checked==true){
				selectid += document.form1.selectid[i].value+",";
			}
		}
	}
	if(selectid == ""){
		alert("您没有选择任何质检单，请选择后再删除！");
	}else{		
		if(confirm("确定要删除吗？")){
			if(selectid.indexOf(",")==-1){
				selectid = selectid;
			}else{
				selectid = selectid.substr(0,selectid.length-1);
			}
			var url = "delqc.asp?ord="+ selectid +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
				if (xmlHttp.readyState == 4) {
					var response = xmlHttp.responseText;
					if(response!=""){
						var arr_res = response.split("|");
						if(arr_res[0]=="0"){
							alert("您没有选择任何质检单，请选择后再删除！");
						}else if(arr_res[0]=="1"){
							window.location.reload();
						}else if(arr_res[0]=="2"){
							var nowurl = window.location.href;
							var arr_url = nowurl.split("&tip2=");
							var arr_url2 = "";
							var url2 = "";
							var toUrl = "";
							if(arr_url.length>1){
								arr_url2 = arr_url[1].split("&");
								arr_url2.remove(0);
								url2 = arr_url2.join("&");	
								url2 = "&"+ url2
								if (url2=="&")
								{
									url2 = ""
								}
								if(arr_res[1] !=""){
									toUrl = arr_url[0] + "&tip2=noDel,"+ arr_res[1] + url2;
								}
							}else{
								if(arr_res[1]!=""){
									if(nowurl.indexOf("?")>0){
										toUrl = nowurl + "&tip2=noDel," + arr_res[1]
									}else{
										toUrl = nowurl + "?1=1&tip2=noDel," + arr_res[1]
									}
								}
							}
							if(toUrl!=""){
								window.location.href = toUrl;
							}else{
								window.location.reload();
							}
//							var ords = ""
//							ords = arr_res[1];
//							var arr_ords = ords.split(",");
//							for(i=0;i<arr_ords.length;i++){
//								document.getElementById("ci"+arr_ords[i]).innerHTML="<font color='red'>不允许删除</font>";
//							}
//							alert("有质检单不允许删除，请取消不允许删除的项");
						}
					}else{
						alert("出现未知错误，请重试");
					}
					xmlHttp.abort();
				}
			};
			xmlHttp.send(null); 
		}
	}
	
}

function delqc(ord){
	if(ord != ""){
		if(confirm("确定要删除吗？")){
			var url = "delqc.asp?ord="+ ord +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
				if (xmlHttp.readyState == 4) {
					var response = xmlHttp.responseText;
					if(response!=""){
						var arr_res = response.split("|");
						if(arr_res[0]=="0"){
							alert("您没有选择任何质检单，请选择后再删除！");
						}else if(arr_res[0]=="1"){
							window.location.reload();
						}else if(arr_res[0]=="2"){
							var ords = ""
							ords = arr_res[1];
							var arr_ords = ords.split(",");
							for(i=0;i<arr_ords.length;i++){
								document.getElementById("ci"+arr_ords[i]).innerHTML="<font color='red'>不允许删除</font>";
							}
							alert("该质检单不允许删除");
						}
					}else{
						alert("出现未知错误，请重试");
					}
					xmlHttp.abort();
				}
			};
			xmlHttp.send(null); 
		}
	}
}

function pizhipai(){
	var allc = document.getElementById("allc").value;
	var isChecked = 0;
	if(allc !=""){
		allc = Number(allc);
		if(allc == 0){
			alert("没有需指派的质检单");
		}else if(allc == 1){
			if(document.form1.selectid.checked==true){
				isChecked = 1;
			}
		}else if(allc > 1){
			for(i=0;i<allc;i++){
				if(document.form1.selectid[i].checked==true){
					isChecked = 1;
					break;
				}
			}
		}
		
		if(isChecked == 0){
			alert("您没有选择任何质检单，请选择后再指派！");
		}else{
			$('#w').show();
			$('#w').window('open');
			$('#w').window('resize',{top:$(document).scrollTop() + ($(window).height()-300) * 0.5});
		}
	}	
}

function dozhipai(){
	var allc = document.getElementById("allc").value;
	var selectid = "";
	if(allc !=""){
		allc = Number(allc);
		if(allc == 0){
			alert("没有需指派的质检单");
		}else if(allc == 1){
			if(document.form1.selectid.checked==true){
				selectid = document.form1.selectid.value;
			}
		}else if(allc > 1){
			for(i=0;i<allc;i++){
				if(document.form1.selectid[i].checked==true){
					selectid += document.form1.selectid[i].value+" ";
				}
			}
		}
		if(selectid==""){
			alert("您没有选择任何质检单，请选择后再指派！");
		}else{
			var tozjr = document.getElementById("tozjr").value;
			if(tozjr==""){
				alert("请选择质检人");
			}else{
				var url = "savezp.asp?ord="+tozjr+"&qcord="+ selectid +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
				xmlHttp.open("GET", url, false);
				xmlHttp.onreadystatechange = function(){
					if (xmlHttp.readyState == 4) {
						var response = xmlHttp.responseText;
						if(response!=""){
							var arr_res = response.split("|");
							if(arr_res[0]=="0"){
								alert("请选择质检人");
							}else if(arr_res[0]=="-1"){
								alert("您没有选择任何质检单，请选择后再指派！");
							}else if(arr_res[0]=="1"){
								window.location.reload();
							}else if(arr_res[0]=="2"){
								var nowurl = window.location.href;								
								var arr_url = nowurl.split("&tip2=");
								var arr_url2 = "";
								var url2 = "";
								if(arr_url.length>1){
									arr_url2 = arr_url[1].split("&");
									arr_url2.remove(0);
									url2 = arr_url2.join("&");	
									url2 = "&"+ url2
									if (url2=="&")
									{
										url2 = ""
									}
									if(arr_res[1] !=""){
										window.location.href = arr_url[0] + "&tip2=noZP,"+ arr_res[1] + url2;
									}else{
										window.location.reload();
									}
								}else{
									if(arr_res[1]!=""){
										if(nowurl.indexOf("?")>0){
											window.location.href = nowurl + "&tip2=noZP," + arr_res[1]
										}else{
											window.location.href = nowurl + "?1=1&tip2=noZP," + arr_res[1]
										}
									}else{
										window.location.reload();
									}
								}							
																
//								var ords = ""
//								ords = arr_res[1];
//								var arr_ords = ords.split(",");
//								for(i=0;i<arr_ords.length;i++){
//									document.getElementById("ci"+arr_ords[i]).innerHTML="<font color='red'>不允许指派</font>";
//								}
//								alert("有质检单不允许指派，请取消不允许指派的项");
								$('#w').window('close');
							}
						}else{
							alert("数据保存出现未知错误，请重试");
						}
						xmlHttp.abort();
					}
				};
				xmlHttp.send(null); 
			}
		}
	}	
}


function Myopen(divID){
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=302;
	divID.style.top=6;
}


function batRuku(){
	var selectid = "";
	var id = "";
	var canRK = 1;
	$("input[name='selectid']:checked").each(function(){
		selectid += (selectid==""?"":",") + $(this).val();
	});	
	if(selectid == ""){
		alert("您没有选择任何质检单，请选择后再入库！");
	}else{
		$("input[name='selectid'][canQCRK=0]:checked").each(function(){
			id = $(this).val();
			canRK = 0;
			$("#ci"+id).html("不允许入库！");
		});	
		//if(canRK == 0){return;}
		var id1 = 0; var i = 0;
		var cg;
		$("input[name='selectid'][canQCRK=1]:checked").each(function(){
			i += 1;
			cg = $(this).attr("cg");
			id = $(this).val();
			if(i==1){
				id1 = cg;				
			}else{
				if(id1 != cg){
					canRK = 0;
					$("#ci"+id).html("存在不同采购单！");
				}
			}
		});	
		if(canRK == 0){return;}
		selectid = "";
		$("input[name='selectid'][canQCRK=1]:checked").each(function(){
			i += 1;
			cg = $(this).attr("cg");
			id = $(this).val();
			if(i==1){id1 = cg;}
			if($("#ci"+id).html()=="存在不同采购单！"){$("#ci"+id).html("")}
			selectid += (selectid==""?"":",") + id;
		});	
		if(!hwndrk||hwndrk.closed){hwndrk=window.open('../../SYSN/view/store/kuin/kuin.ashx?billtype=73001&billid='+cg+'&tagid=2&ords='+selectid,'newwin22','width=' + 1070 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50');}else{hwndrk.focus();}
	}
}

function batPrint(){
	var selectid = "";
	var id = "";
	var candy = 1;
	$("input[name='selectid']:checked").each(function(){
		selectid += (selectid==""?"":",") + $(this).val();
	});	
	if(selectid == ""){
		alert("您没有选择任何质检单，请选择后再打印！");
	}else{
		$("input[name='selectid'][candy=0]:checked").each(function(){
			id = $(this).val();
			candy = 0;
			$("#ci"+id).html("不允许打印！");
		});			
		if(candy == 0){return;}
		selectid = "";
		$("input[name='selectid'][candy=1]:checked").each(function(){
			id = $(this).val();
			if($("#ci"+id).html()=="不允许打印！"){$("#ci"+id).html("")}
			selectid += (selectid==""?"":"|") + id;
		});	
		//var idsArr = selectid.split("|");
		//if (idsArr.length > 50){alert("选择的单据数量不要超过50个！");return false;}
		window.OpenNoUrl('../../SYSN/view/comm/TemplatePreview.ashx?sort=28&ord='+selectid,'newwin28','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0')		
	}
}

var afterPrint = function () {
    document.getElementById('s1').style.display = ''
};

if (window.matchMedia) {
    var mediaQueryList = window.matchMedia('print');
    mediaQueryList.addListener(function (mql) {
        if (!mql.matches) {
            afterPrint();
        }
    });
}