function scanfKeyDownCatch(type){
	if (window.event.keyCode==13)
	{	
		var o=window.event.srcElement;
		if (o.tagName=="INPUT")
		{
			var canevent = o.getAttribute("canevent");
			if (canevent=="0"){return false;}
			var tr = o.parentNode.parentNode;
			var td = o.parentNode;
			if (type==1)
			{
				while(tr && tr.tagName!="SPAN"  )
				{
					if (tr.tagName=="TR" && tr.cells.length>4)
					{
						var cellIndex = 0;
						for (var i = 0 ; i < tr.cells.length ; i++)
						{
							if(tr.cells[i]==td){
								cellIndex =  i;
								break;
							}
						}
						i=cellIndex;
					}
					td = td.parentNode;
					tr = tr.parentNode;	
				}
				if(!tr || tr.tagName!="SPAN") {return false;}
				var p=tr;
				if (o.onblur)
				{
					if (o.onblur()==false)
					{
						window.event.keyCode=0;
						window.event.returnValue=false;
						return false;
					}
				}
				if (p.nextSibling)
				{	
					p=p.nextSibling;
					try
					{
						while (p&&(p.innerHTML==""|| p.children[0].tagName!="TABLE"))
						{
							p=p.nextSibling;
						}
					}
					catch (e)
					{
						 return false;
					}
					if (!p||p.innerHTML==""|| p.children[0].tagName!="TABLE"){ return false;}
					var Ctr=p.children[0].children[0];
					while (Ctr&& Ctr.tagName!="TR")
					{		
						Ctr=Ctr.children[0];
					}
					if (!Ctr||Ctr.tagName!="TR") { return false; }
					if (Ctr.cells[i])
					{
						var inputs=Ctr.cells[i].getElementsByTagName("input");
						if (inputs.length>0)
						{ 
							for (ii=0;ii< inputs.length;ii++ )
							{
								if (inputs[ii].type=="text")
								{
									setTimeout(function(){inputs[ii].focus();},200)
									break;
								}
							}
						}
					}

				}
			}
			else
			{			
				while(tr && (tr.tagName!="TR" || tr.cells.length<4) )
				{
					td = td.parentNode;
					tr = tr.parentNode;	
				}
				if(!tr || tr.tagName!="TR") { return false;}
				var p=tr;
				if (p.tagName=="TR")
				{
					if (o.onblur)
					{	
						if (o.onblur()==false)
						{
							window.event.keyCode=0;
							window.event.returnValue=false;
							return false;
						}
					}
					if (p.nextSibling)
					{
						var tr =  p.nextSibling;
						var cellIndex = 0;
						for (var i = 0 ; i < p.cells.length ; i++)
						{
							if(p.cells[i]==td){
								cellIndex =  i;
								break;
							}
						}
						i=cellIndex;
						try{
							tr.onclick();
							if (tr.cells[i])
							{		
								var inputs=tr.cells[i].getElementsByTagName("input");
								if (inputs.length>0)
								{ 
									for (ii=0;ii<inputs.length;ii++ )
									{
										if (inputs[ii].type=="text")
										{
											setTimeout(function(){inputs[ii].focus();},200)
											break;
										}
									}
								}
							}
						}
						catch (e)
						{
							 return false;
						}
					}
				}
			}
		}else if (o.tagName=="TEXTAREA"){
			return true;
		}
		return false;
	}
	//else
	//{
		//alert(window.event.keyCode);
	//}
	//
}