function statusChange() {
    window.location.href='?OutSourcestatus='+$('[name=OutSourcestatus]:checked').val()
}
$(function () {
    var time1=window.setInterval(function () {
        console.log(time1)
        var divs=$(".zbchart_pie");
       if(divs.length>0){
          window.clearInterval(time1) ;
           divs.each(function () {
               this.style.width=540+"px"
           })
       }

    })

},10)