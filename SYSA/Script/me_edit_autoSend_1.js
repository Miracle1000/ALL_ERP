


		
		function getWordsLength()
	{
			var obj=document.getElementById('messageContent');
		var num=70;
		var objTip=document.getElementById('tip');
		//Sensitivewords(obj.value,'**');
		if(obj.value.length>=1)
		{
					if(obj.value.length>0)
					{
						document.getElementById("qccon").style.display="";
						}
					else
					{
						document.getElementById("qccon").style.display="none";
						}
				
						if (obj.value.length > num) 
						{
							objTip.innerHTML="已超出<em>"+(obj.value.length - num)+"</em>个字!";
							objTip.style.color="#F00";
							document.getElementById("button").disabled="";
							}
							else
							{
							objTip.innerHTML="你还能输入<em>"+(num-obj.value.length) +"</em>个字!";
							objTip.style.color="#588905";
							document.getElementById("button").disabled="";
									}
				}
			else{
					document.getElementById("button").disabled="disabled";
					}
			}

