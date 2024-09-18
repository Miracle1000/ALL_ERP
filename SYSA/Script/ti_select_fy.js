function selectall(obj){
	var arrobj=document.getElementsByName("sort1type_"+obj.value);
	for (var i= 0 ; i< arrobj.length ;i++ ){
		arrobj[i].checked=obj.checked;
		selectType(arrobj[i]);
	}
}
function selectType(obj){
	try{
		var sort=obj.name.replace("sort1type_","");
		var tt="",sorts="" ;
		$("#w").find(":checkbox:checked[name='"+obj.name+"']").each(function(){
			tt+=(tt.length>0?" ":"") + this.title;
			sorts+=(sorts.length>0?",":"") + this.value;
		});
		$('#typelist_'+sort).html(tt);

		var $sortobj = $('#sort1_'+ sort +'');
		if ($sortobj.size()==0){
			$('<input type="hidden" id="sort1_'+ sort +'" name="sort1_'+ sort +'" value="'+sorts+'">').appendTo($('#demo'));
		}else{
			$sortobj.val(sorts);
		}

		var sorttypes = "";
		$("#w").find(":checkbox:checked[name='sort1sort']").each(function(){
			sorttypes+=(sorttypes.length>0?",":"") + this.value;
		});
		var $sortTypesobj = $('#sorttypes');
		if ($sortTypesobj.size()==0){
			$('<input type="hidden" id="sorttypes" name="sort1" value="'+sorttypes+'">').appendTo($('#demo'));
		}else{
			$sortTypesobj.val(sorttypes);
		}
	}
	catch(e){}
}

$(function(){
	var nodes=document.body.childNodes;
	try{
		document.getElementById("VMLGraphicsDiv").style.cssText="position:absolute;top:" + (nodes[0].offsetHeight-100) + "px;z-index:-10";	
	}catch (e){
		nodes[4].style.cssText="position:absolute;top:" + (nodes[0].offsetHeight-100) + "px;z-index:-10";		
	}
});
