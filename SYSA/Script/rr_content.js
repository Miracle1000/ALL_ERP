
window.onload=function(){
    setMXdiv();
	var grayImg = document.getElementsByTagName("img");
	if(grayImg.length>0){
		for(i=0; i<grayImg.length; i++){
			if(grayImg[i].width>550){
				grayImg[i].width = 550;
			}
			if(grayImg[i].height>152){
				grayImg[i].height = 152;
			}
		}
	}
	if (__ImgBigToSmall) { __ImgBigToSmall("", "", 100) }
	FilePreviewAndDownload()
}

function showDIV(show,v,divid){			//显示/隐藏层
	if(show==1){
		$ID(divid).style.display = "";
	}else if(show==0){
		if(v==""){
			$ID(divid).innerHTML = ""
		}
		$ID(divid).style.display = "none";
	}
}

function getJiejianInfo(mxid){		//显示接件情况层
	if(mxid != ""){
		var JianContent = $ID("JianContent");
		var scrollTop = $(document).scrollTop(); 
		$('#wJian').window('open');	
		$('#wJian').window('resize',{top:$(document).scrollTop() + ($(window).height()-260) * 0.5});
		$ID('wJian').style.display = "block";
		JianContent.innerHTML="loading...";
		ajax.regEvent("getJiejianInfo");
		$ap("mxid",mxid);
		var r = ajax.send();	
		if(r!=""){
			JianContent.innerHTML=r;			
			var grayImg = JianContent.getElementsByTagName("img");
			if(grayImg.length>0){
				for(i=0; i<grayImg.length; i++){
					if(grayImg[i].width>300){
						grayImg[i].width = 300;
					}
					if(grayImg[i].height>100){
						grayImg[i].height = 100;
					}
				}
			}
		}
	}
}


function setMXdiv(){
	var mxdiv = $ID("mxdiv");
	mxdiv.style.width = ($ID("posW").offsetLeft - 44) + "px";
}


function newWXOrder(mxid){		//维修单添加界面
	if (mxid!=""){
		var slTitle = $ID("slTitle").value, slbz = $ID("slbz").value
		ajax.regEvent("chkWXOrder");
		$ap("mxid",mxid)
		var r = ajax.send();
		if(r != ""){
			if(r == "0"){
				app.Alert("该受理产品已派工完毕");
				return;
			}else if(r == "1"){
				window.open('RepairOrder.asp?listID='+ mxid +'&slTitle='+ escape(slTitle) +'&slbz='+escape(slbz)+'&Referrer=slcon','newpgwxwin','width=' + 910 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')
			}else if(r == "-1"){
				app.Alert("请选择需派工的受理产品");
				return;
			}else{
				app.Alert("数据错误");	
				return;
			}
		}
	}
}

function showTbody(tbid){
	if($ID(tbid).style.display=="block"){
		$ID(tbid).style.display="none";
		if(tbid=="con2"){
			$ID("mxdiv").style.display="none";
			$ID("lvw_mxistvw").style.display="none";
		}
	}else{
		$ID(tbid).style.display="block";
		if(tbid=="con2"){
			$ID("mxdiv").style.display="block";
			$ID("lvw_mxistvw").style.display="block";
		}
	}
}

	function show_cllist(obj_id){
		  if($ID(obj_id).style.display=="none"){
				$ID(obj_id).style.display="";
				if(obj_id=="con2"){
					$ID("mxdiv").style.display="";
					$ID("lvw_mxistvw").style.display="";
				}
		  }else{
				$ID(obj_id).style.display="none";
				if(obj_id=="con2"){
					$ID("mxdiv").style.display="none";
					$ID("lvw_mxistvw").style.display="none";
				}
		  }
		  if (obj_id.indexOf("2")>0)
		  {
			op_cl($ID("v2"),$ID("t2"))
		  }
		  else if (obj_id.indexOf("1")>0)
		  {
			op_cl($ID("v1"),$ID("t1"))
		  }
		  else
		  {
			op_cl($ID("v3"),$ID("t3"))
		  }
	}
	function op_cl(obj1,obj2)
	{
		if (obj1.value==1)
		{	
			obj2.innerText="(点击即可收缩)";
			obj1.value=2;
		}
		else
		{
			obj2.innerText="(点击即可展开)";
			obj1.value=1;
		}
	}

