
		function ff() {
			document.date.action="PMPreview1.asp";
			document.date.target="pview";
			document.date.submit();	
		}
		document.write(opener.document.getElementById("demo").outerHTML);
	