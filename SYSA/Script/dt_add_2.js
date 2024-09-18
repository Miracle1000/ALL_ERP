//删除用户未正式保存的文档附件

$(window).load(function() {
	_clearfile();
});

$(window).bind('beforeunload',function(){
	_clearfile();
});

function delunload(){
	$(window).unbind('beforeunload');
}

function _clearfile()
{
	$.ajax({
		url: "ProcDelFile.asp?delsession=1",
		type: "post",
		dataType: "text",
		async: false,
		success: function(obj) {
		}
	});
};