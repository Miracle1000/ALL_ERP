//提交和离开页面时删除无用的上传文件,可应用于各个引用eWebEditor的页面
//Create by 常明 at 2010-06-25
//修改文件列表
//修改/Edit/upload.asp
//修改/Edit/eWebEditor.asp
//新增/Edit/DelUnusedFiles.asp
//新增/Edit/GetUploadFileList.asp
//新增/Inc/DelUnusedFiles.js
/////////////////////////////////////////////
//版本变更记录
//暂无
////////////////////////////////////////////

var FlgDelAll=true;//用于区分是提交表单还是其他方式离开页面的标识变量

//解析并得到所有编辑器中的文件名
function getExistsFilesInContent(){
	//取得所有编辑器中的内容
	var AllContent = "";
	var isUsingUeditor = false;
	jQuery("iframe[id^=eWebEditor]").each(function(){
		var editor = this.editor;
		if (editor){
			AllContent += editor.getContent();
			isUsingUeditor = true;
		}else{
		    AllContent += this.contentWindow.document.getElementById("ueditor_0").contentWindow.document.body.innerHTML;
		}
	});

	//先保存图片文件清单
	var myReg,regReplace,existFiles = [];
	if (isUsingUeditor){
		myReg=/<img[^>]+?src=(\"|\')([^\'\"]+)\/(UE\d+\.[A-Za-z0-9]+)\1[^>]*>/gi;
	}else{
		myReg=/<img[^>]+?src=(\"|\')([^\'\"]+)\/(\d+\.[A-Za-z0-9]+)\1[^>]*>/gi;
	}

	var matchs = AllContent.match(myReg);
	if (matchs){
		for (var i=0;i<matchs.length;i++){
			existFiles.push(matchs[i].replace(myReg,"$3"));
		}
	}

	//保存其他文件清单
	if (isUsingUeditor){
		myReg=/<a[^>]+?href=(\"|\')([^\'\"]+)\/(UE\d+\.[A-Za-z0-9]+)\1[^>]*>.+<\/a>/gi;
	}else{
		myReg=/<a[^>]+?href=(\"|\')([^\'\"]+)\/(\d+\.[A-Za-z0-9]+)\1[^>]*>.+<\/a>/gi;
	}

	matchs = AllContent.match(myReg);
	if (matchs){
		for (var i=0;i<matchs.length;i++){
			existFiles.push(matchs[i].replace(myReg,"$3"));
		}
	}

	return existFiles.join(',');
}

//读取服务器端的Session变量中保存的已上传文件列表
function GetUploadFileList(tindex){
	var url = "../Edit/GetUploadFileList.asp?t="+tindex+"&del=1&"+Math.round(Math.random()*100);
	jQuery.ajax({
		url:url,
		async:false,
		type:'post',
		data:'contentFiles=' + getExistsFilesInContent(),
		cache:false,
		success:function(r){
			try
			{
				console.log(r);
			}
			catch (e)
			{
			}
		},
		error:function(a,b,c){
			try
			{
				console.log(a);
				console.log(b);
				console.log(c);				
			}
			catch (e)
			{
			}

		}
	});
}

//当用户因提交表单而离开页面时调用
function DelUnusedFilesBeforeSubmit(){
	FlgDelAll=false;
	GetUploadFileList(0);
	return true;
}
