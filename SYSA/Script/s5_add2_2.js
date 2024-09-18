
				function lywlxdyqx(){
					document.getElementById('unreplyback1TypeTip2').style.display='none';
					document.getElementById('tips1').style.display='none';
					document.getElementById('unreplyback1TypeTip1').style.display='block';
					var isProtect=0;
					if (document.getElementById('isProtect1').checked==true){
						isProtect=1;
					}
					if(isProtect==1){
						var reply1 = Number(document.getElementById('reply1').value);
						document.getElementById('unreplyback1day').value = reply1+1;
					}else{
						document.getElementById('unreplyback1day').value = 1;
					}
				}
			