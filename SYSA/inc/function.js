// JavaScript Document
function change1(a,b)
{
	if(eval(a).runtimeStyle.display=='')
	{
		eval(a).runtimeStyle.display='none';
		eval(b).className='menu3';
	}
	else
	{
		eval(a).runtimeStyle.display='';
		eval(b).className='menu4';
	}
}
function change2(a,b)
{
	if(eval(a).runtimeStyle.display=='')
	{
		eval(a).runtimeStyle.display='none';
		eval(b).className='menu1';
	}
	else
	{
		eval(a).runtimeStyle.display='';
		eval(b).className='menu2';
	}
}
function changeleft1(a,b)
{
	if($(a).style.display=='')
	{
		$(a).style.display='none';
		$(b).className='nav_left1';
	}
	else
	{
		$(a).style.display='';
		$(b).className='nav_left2';
	}	
	
}

function changeleft_ml(a,b,id)
{
	if($(a).style.display=='')
	{
		$(a).style.display='none';
		$(b).className='nav_left1';
		left_mldh(id,0);
	}
	else
	{
		$(a).style.display='';
		$(b).className='nav_left2';
		left_mldh(id,1);
	}	
	
}



//left tab change
function selectTag(showContent,selfObj){
	// change tab
	var tag = $("leftmenu").getElementsByTagName("a");
	var taglength = tag.length;
	for(var i=0; i<taglength; i++){
		tag[i].className = "";
	}
	selfObj.className = "up";
	// change content
	for(var i=1;i<4;i++){
		$("leftmenu"+i).style.display = "none";
	}
	$(showContent).style.display = "block";	
}

function scrollImg(){
    var posY;
    if (window.innerHeight) {
        posY = window.pageYOffset;
    }
else if (document.documentElement && document.documentElement.scrollTop) {
posY = document.documentElement.scrollTop;
}
else if (document.body) {
posY = document.body.scrollTop;
    }
	try{
	var ad=document.getElementById("btn_sh");
	if(ad.style.position=="fixed") {
		return ;
	}
    ad.style.top=(posY+20)+"px";
	}catch(e){}
    setTimeout("scrollImg()",50);
}

window.onload=function()
{
scrollImg();
for(var ii=0; ii<document.links.length; ii++)
document.links[ii].onfocus=function(){this.blur()}
}
function fHideFocus(tName){
aTag=document.getElementsByTagName(tName);
for(i=0;i<aTag.length;i++)aTag[i].hideFocus=true;
}


//根据币种ID获取收款账号
function getBankAccountByBzId(obj,hldateId,showHlId){
	var $o = jQuery(obj);
	var bz = $o.val();
	var divShowhl = 0;
	if(jQuery("#bank").size()>0){
		var s = "<option value=''>选择账号</option>";
		jQuery.ajax({
			url:"../contract/getBankAccountByBzId.asp?bz="+bz+"&r="+ Math.random(),
			type:"post",
			dataType:"json",
			success:function(json){
				for(var i=0;i<json.length;i++){
					s = s + "<option value="+json[i].id;
					s = s + ">"+json[i].name+"</option>"
				};
				jQuery("#bank").html(s);
			}
		});
	}
	
	if (typeof(showHlId)=="undefined")	{showHlId = ""}
	var $span;
	if(showHlId!=""){
		divShowhl = 1;
		$span =$("#"+showHlId);
		if (bz==''){
			$span.html('');
			return;
		}else if( bz=='14'){
			$span.html(formatNumDot('1',window.sysConfig.hlDotNum));
			return;
		}

	}else{
		$span = $o.nextAll("span:eq(1)");
		if($span.size()==0) $span=jQuery('<span class="red"/>').insertAfter($o.next("span"));
		if(bz!=''&&$span.next('span').size()>0){
			$span.next('span').remove();
		}
		if (bz=='' || bz=='14'){
			$span.html('');
			return;
		}
	}

	var $dt = jQuery('#'+hldateId);
	var dt = $dt.val().split(" ")[0];
	jQuery.ajax({
		url:'../contract/AjaxReturn.asp',
		data:{
			act:'checkHL',
			hldate:dt,
			bz:bz
		},
		cache:false,
		success:function(r){
			var json = eval('('+r+')');
			if (json.success == false){
				if(json.canSetBank){
					$span.html('&nbsp;<a href="javascript:;">设置</a>');
					$span.children('a').click(function(){
						window.open('../hl/edit.asp','setHTLwin','width=900,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=200');
					});
				}else{
					$span.html('&nbsp;请联系管理员设置当天汇率！');
				}
			}else {		
				if(divShowhl==1){
					$span.html(json.hl);
				}else{
					$span.html('');
				}
			}
		},
		error:function(res){
			alert(res.responseText);
		}
	});
}

//日期时间加减，如： dateAdd("h",5,"2019-1-5 10:00:00")
function dateAdd(addType, num1, date1){
	var nd = new Date(date1.replace(/\-/g,"/"));
	num1 = Number(num1);
	switch(addType.toLowerCase()){
	case "y":	//年
		nd.setFullYear(nd.getFullYear()+num1);
		break; 
	case "m":	//月
		nd.setMonth(nd.getMonth()+num1);
		break; 
	case "w":	//周
		nd.setDate(nd.getDate()+num1*7);
		break; 
	case "d":	//天
		nd.setDate(nd.getDate()+num1);
		break; 
	case "h":	//时
		nd.setTime(nd.setHours(nd.getHours() + num1));
		break; 
	case "n":	//分
		nd.setTime(nd.setMinutes(nd.getMinutes() + num1));
		break; 
	}
	return nd;
}

//日期时间格式化，如： formatDate("2019-1-5 17:8:20","yyyy-MM-dd hh:mm:ss")
function formatDate(date,fmt) {
	if(typeof(date)=="string"){
		date = new Date(date.replace(/\-/g,"/"));
	}
	var o = {   
	  "M+" : date.getMonth()+1,                 //月份   
	  "d+" : date.getDate(),                    //日   
	  "h+" : date.getHours(),                   //小时   
	  "m+" : date.getMinutes(),                 //分   
	  "s+" : date.getSeconds(),                 //秒   
	  "q+" : Math.floor((date.getMonth()+3)/3), //季度   
	  "S"  : date.getMilliseconds()             //毫秒   
	};   
	if(/(y+)/.test(fmt))   
	  fmt=fmt.replace(RegExp.$1, (date.getFullYear()+"").substr(4 - RegExp.$1.length));   
	for(var k in o)   
	  if(new RegExp("("+ k +")").test(fmt))   
	fmt = fmt.replace(RegExp.$1, (RegExp.$1.length==1) ? (o[k]) : (("00"+ o[k]).substr((""+ o[k]).length)));   
	return fmt;   
} 
