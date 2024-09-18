
<!--
var publicWorkID,publicColor="#99cc00",publicColorstr,publicSetWIdStr;
$(document).ready(function(){
$("#topWorkBoor tr td").click(function(){
publicWorkID=this.id;
publicColor=$("#"+publicWorkID+"").attr("bgcolor").toLowerCase();
});


			$("#Calendar table tr td").click(function(){
			if(this.id!=""&&this.id!=null)
			{
					if($("#"+this.id+"").attr("style").toLowerCase().indexOf(publicColor)>=0)
					{
							$("#"+this.id+"").css("background-color","#ffffff");
						//	if($("#"+this.id+"").attr("style").toLowerCase().indexOf("#99cc00")>=0)
//							{
							$("#hidDate").val($("#hidDate").val().replace("|"+this.id,""));
					//		}
//							else if($("#"+this.id+"").attr("style").toLowerCase().indexOf("#ffe888")>=0)
//							{
							$("#hidDateW").val($("#hidDateW").val().replace("|"+this.id,""));
							//}

					}
					else
					{
							$("#"+this.id+"").css("background-color",publicColor);

							if($("#"+this.id+"").attr("style").toLowerCase().indexOf("#99cc00")>=0)
							{
							$("#hidDate").val($("#hidDate").val()+"|"+this.id);
							$("#hidDateW").val($("#hidDateW").val().replace("|"+this.id,""));
							}
							else if($("#"+this.id+"").attr("style").toLowerCase().indexOf("#ffe888")>=0)
							{
							$("#hidDateW").val($("#hidDateW").val()+"|"+this.id);
							$("#hidDate").val($("#hidDate").val().replace("|"+this.id,""));
							}
					//$("#hidDate").val($("#hidDate").val()+"|"+this.id);
					}
			}
		});
	});


-->
