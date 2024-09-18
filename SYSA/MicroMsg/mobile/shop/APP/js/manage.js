$(function(){
		init();
		$("#edit").click(function(){
			$("#info").hide();
			$("#editInfo").show();
			$(this).text('');
		})
		$("#back").click(function(){
			window.history.back();
		})
})
function init(){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../AccountInfo.asp",
		dataType:"text",
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			createInfo(data);
		},
		error:function(a,b,c){
			console.log(b);
		}
	})
}
function createInfo(data){
	var datas = getAttr(data.body.bill.groups[0].fields);
	$("#userName").text(htmlDecode(datas["nickname"]));
	$("#userPhoto").attr("src","../../../../../MicroMsg/"+datas["photo"]);
	$("#infoList").empty();
	//显示的UL
	var $li = ('<li>'+
					'<p class="col-xs-4 text-right">姓名：</p>'+
					'<p class="col-xs-8 text-left">'+datas["nickname"]+'</p>'+
				'</li>'+
				'<li>'+
					'<p class="col-xs-4 text-right">性别：</p>'+
					'<p class="col-xs-8 text-left" id="sex">'+datas["sex"]+'</p>'+
				'</li>'+
				'<li>'+
					'<p class="col-xs-4 text-right">生日：</p>'+
					'<p class="col-xs-8 text-left" id="birth">'+datas["birthday"]+'</p>'+
				'</li>'+
				'<li>'+
					'<p class="col-xs-4 text-right">邮箱：</p>'+
					'<p class="col-xs-8 text-left" id="mail">'+datas["email"]+'</p>'+
				'</li>'+
				'<li>'+
					'<p class="col-xs-4 text-right">手机号码：</p>'+
					'<p class="col-xs-8 text-left" id="tel">'+datas["mobile"]+'</p>'+
				'</li>'+
				'<li>'+
					'<p class="col-xs-4 text-right">爱好特长：</p>'+
					'<p class="col-xs-8 text-left" id="like">'+datas["joy"]+'</p>'+
				'</li>');
	$("#infoList").append($li);
	$("#canEditInfo").empty();
	//编辑的UL
	var editLi = $('<li>'+
						'<p class="col-xs-4 text-right">姓名：</p>'+
						'<p class="col-xs-8 text-left">'+datas["nickname"]+'</p>'+
					'</li>'+
					'<li>'+
						'<p class="col-xs-4 text-right">性别：</p>'+
						'<p class="col-xs-8" id="editSex">'+
						'<input type="radio" class="sex" value="男" '+(datas["sex"]=="男"?"checked" :"")+' name="sex">男&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input class="sex" type="radio"  value="女" '+(datas["sex"]=="女"?"checked" :"")+' name="sex">女</p>'+
					'</li>'+
					'<li>'+
						'<p class="col-xs-4 text-right">生日：</p>'+
							'<div>'+
				               ' <input style="" type="text" class="col-xs-8 text-left" id="editBirth" value="'+datas["birthday"]+'"/>'+
				            '</div>'+
					'</li>'+
					'<li class="pst">'+
						'<p class="col-xs-4 text-right" >邮箱：</p>'+
						'<input class="col-xs-8 text-left" type="email" value="'+datas["email"]+'" id="editEmail" required="required">'+
						'<div class="errorTig">请输入正确的邮箱</div>'+
					'</li>'+
					'<li class="pst">'+
						'<p class="col-xs-4 text-right" >手机号码：</p>'+
						'<input class="col-xs-8 text-left" type="number" dataType="number"  value="'+datas["mobile"]+'" id="editTel">'+
						'<div class="errorTig">请输入正确的手机号码</div>'+
					'</li>'+
					'<li class="pst">'+
						'<p class="col-xs-4 text-right" >爱好特长：</p>'+
						'<input class="col-xs-8 text-left" type="text" value="'+datas["joy"]+'" id="joy">'+
						'<div class="errorTig">最多输入3000字！</div>'+
					'</li>');
	$("#canEditInfo").append(editLi);
	var hasDatediv = false;
	var currYear = (new Date()).getFullYear();	
	var opt={};
	opt.date = {preset : 'date'};
	opt.datetime = {preset : 'datetime'};
	opt.time = {preset : 'time'};
	opt.default = {
		theme: 'android-ics light', //皮肤样式
        display: 'modal', //显示方式 
        mode: 'scroller', //日期选择模式
		lang:'zh',
        startYear:currYear - 120, //开始年份
        endYear:currYear+10 //结束年份
	};
	$("#editBirth").scroller('destroy').scroller($.extend(opt['date'], opt['default']));
	
	$("#editEmail").blur(function(){
		emailCheck($(this));
	})
	$("#editTel").blur(function(){
		checkTel($(this));
	})
	$("#joy").blur(function(){
		checkJoy($(this));
	})
	//保存
	$("#save").click(function(){
		$("#canEditInfo").find("input").trigger("blur");
		var flags = $("#canEditInfo").find("input[flag=1]");
		if(flags.size() > 0){
			return;
		}else{
			doSave()
		}
		
	
	})
}
function doSave(){
	var sex= "";
	$.each($(".sex"), function(i){  
		if($(".sex")[i].checked){
			sex =  $(this).val();
		}
	});
	var birthday = $("#editBirth").val();
	var email = $("#editEmail").val();
	var joy = $("#joy").val();
	var mobile = $("#editTel").val();
	var datas = '{datas:['+
				'{id:"sex",val:"'+sex+'"},'+
				'{id:"birthday",val:"'+birthday+'"},'+
				'{id:"email",val:"'+email+'"},'+
				'{id:"mobile",val:"'+mobile+'"},'+
				'{id:"joy",val:"'+joy+'"},{id:"openid",val:"'+localStorage.openID+'"}]}';
	$.ajax({
		type:"post",
		url:"../../AccountInfo.asp?__msgId=__sys_dosave",
		dataType:"text",
		processData:false,
		data:datas,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			$("#info").show();
			$("#editInfo").hide();
			$("#edit").text("编辑");
			init();
		}
	})
}
//获取text
function getAttr(arr){
	var o = {};	
	for(var k=0;k<arr.length;k++){
		o[arr[k].id] = arr[k].text || '';
	}
	return o;
} 

//特殊字符转
var htmlDecode = function(str) {
    return str.replace(/&#(x)?([^&]{1,5});?/g,function($,$1,$2) {
        return String.fromCharCode(parseInt($2 , $1 ? 16:10));
    });
};
//邮箱验证
function emailCheck($this){	
	var email = $this.val();
	var re = /^(\w-*\.*)+@(\w-?)+(\.\w{2,})+$/;
	if (re.test(email) || $this.val() == "") { 
        $this.next().hide();
		$this.attr("flag","");
    }else{
    	$this.next().show();
		$this.attr("flag","1");
    }
}

//手机号码验证
function checkTel($this){
	var re = /^1[3578][0-9]{9}$/;
	if(re.test($this.val()) && $this.val() != ""){
		$this.next().hide();
		$this.attr("flag","");
	}else{
		$this.next().show();
		$this.attr("flag","1");
	}
}
//爱好验证
function checkJoy($this){
	var str = $this.val();
	if(str.length <= 3000){
		$this.next().hide();
		$this.attr("flag","");
	}else{
		$this.next().show();
		$this.attr("flag","1");
	}
}