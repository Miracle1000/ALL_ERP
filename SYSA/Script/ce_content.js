
	function show_cllist(obj_id){
		  if($ID(obj_id).style.display=="none"){
				$ID(obj_id).style.display="";
		  }else{
				$ID(obj_id).style.display="none";
		  }
		  if (obj_id.indexOf("2")>0) {
			op_cl($ID("v2"),$ID("t2"))
		  }
		  else if (obj_id.indexOf("1")>0){
			op_cl($ID("v1"),$ID("t1"))
		  }else {
			op_cl($ID("v3"),$ID("t3"))
		  }
	}
	function op_cl(obj1,obj2){
		if (obj1.value==1){	
			obj2.innerText="(点击即可收缩)";
			obj1.value=2;
		}else{
			obj2.innerText="(点击即可展开)";
			obj1.value=1;
		}
	}
