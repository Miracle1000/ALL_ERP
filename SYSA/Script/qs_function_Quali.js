
	function setbt(ntype){
		$("#Qualis").find(":text").attr("min",ntype);
	}
	function setQuali(ntype){
		if (ntype==1)
		{
			$("#zzName").attr("style","");
			$("#zzSelect").attr("style","");
			$("#zzTr1").attr("style","");
			$("#zzTr2").attr("style","");
			$("#qualifications").attr("min","1");
			setbt(1);
		}
		else
		{
			$("#zzName").attr("style","display:none");
			$("#zzSelect").attr("style","display:none");
			$("#zzTr1").attr("style","display:none");
			$("#zzTr2").attr("style","display:none");
			$("#qualifications").attr("min","0");
			setbt(0);
		}
	}
	function selectZzSort(tel_ord,obj)
	{
		$.ajax({
			url:"../qualifications/show_sort.asp?ord="+tel_ord+"&sort1="+obj.value+"&editNum="+window.qualiEditNum,
			success:function(r){
				$('#Qualis').html(r);
				$("#zzTr1").attr("style","");
				$("#zzTr2").attr("style","");
			}
		});
	}

	function setPerson_zz(obj)
	{
		var personStr = $("#"+obj.id+"_id").val();
		$.ajax({
			url:"../qualifications/setPerson.asp?personStr="+personStr+"&id="+obj.id,
			success:function(r){
				$('#w2').html(r);
				var inttop=(55+document.documentElement.scrollTop+document.body.scrollTop)+"px";
				$('#w2').window({top:inttop,minimizable:false,maximizable:false});
				$('#w2').window('open');
			}
		});
	}

	function selectAll(){
		window.UserTreeBase.CheckAll("member2");
	}

	function selectFan(){
		window.UserTreeBase.CheckXOR("member2");
	}

	function setTXUser(objid){
		var box = document.getElementsByName("member2")[0];
		var names = box.getAttribute("text");
		var userids = (box.value || "");
		if(userids == ""){
			alert("请选择人员");
			return false;
		}
		else
		{	
			$("#"+objid).val(names);
			$("#"+objid+"_id").val(userids);
			$('#w2').window('close');
		}		
	}
