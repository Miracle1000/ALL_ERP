
					window.storeListChange = function(v){
						if(v)
						{
							document.getElementById("product_CK_box").value = v.join(",");
						}
						else{
							document.getElementById("product_CK_box").value = "";
						}
					}
				