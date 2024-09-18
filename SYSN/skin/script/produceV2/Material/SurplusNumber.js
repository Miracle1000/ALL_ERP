function statusChange() {
    var newhref = window.location.href;
    if(window.location.href.indexOf('OutSourcestatus=', 0) > 0){
        var rpstr = window.location.href.substring(window.location.href.indexOf('OutSourcestatus='), window.location.href.indexOf('OutSourcestatus=') + 17);
        newhref = newhref.replace(rpstr, "OutSourcestatus=" + $('[name=OutSourcestatus]:checked').val());
    }
    else{
        newhref = window.location.href+(window.location.href.indexOf('auto=', 0) > 0 ? '&' : '?') + 'OutSourcestatus=' + $('[name=OutSourcestatus]:checked').val()
    }
    window.location.href = newhref;
}