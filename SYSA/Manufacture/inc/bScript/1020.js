window.onbeforeunload=function(){
	try{
		window.opener.getPosition();
	}catch(e){

	}
}
