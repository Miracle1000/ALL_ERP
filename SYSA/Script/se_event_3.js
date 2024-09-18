
var toExecel=document.getElementById('toExecel')
if(toExecel){
	toExecel.onclick=function(){
		if(confirm('确认导出为EXCEL文档？')){
			exportExcel({debug:false,page:'../out/xlsService.asp'});
		}
	}
}
