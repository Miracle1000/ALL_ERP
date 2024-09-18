
			//if(window.opener)window.opener.location.reload();
			alert("添加成功");
			try {
				if (window.opener==undefined) {
					window.location.href = "perform_list.asp";
				}
				else {
					window.open('', '_self');
					window.opener.location.reload();
					window.close();
				}
			}
			catch(e){
				window.location.href = "perform_list.asp";
			}
		