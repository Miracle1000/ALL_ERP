
function dateYxqSet(currType, dateScId, dateYxId){
    var datesc, dateyx, cpyxqHours, arr_cpyxq,date2;
    if(currType=="datesc"){
        if(dateScId != ""){
            datesc = jQuery("#"+dateScId).val();
            cpyxqHours = jQuery("#"+dateScId).attr("cpyxqHours");
            if(cpyxqHours!=""){
                if(datesc!=""){
                    arr_cpyxq = cpyxqHours.split("|");
                    date2 = formatDate(dateAdd(arr_cpyxq[1],arr_cpyxq[0],datesc),"yyyy-MM-dd");
                    jQuery("#"+dateYxId).val(formatDate(dateAdd("d",-1,date2),"yyyy-MM-dd"));
                }else{
                    jQuery("#"+dateYxId).val("");
                }                
            }
        }
    }else if(currType=="dateyx"){
        if(dateYxId != ""){
            datesc = jQuery("#"+dateScId).val();
            dateyx = jQuery("#"+dateYxId).val();
            cpyxqHours = jQuery("#"+dateYxId).attr("cpyxqHours");
            if(datesc=="" && cpyxqHours!=""){
                if(dateyx!=""){
                    arr_cpyxq = cpyxqHours.split("|");
                    date2 = formatDate(dateAdd(arr_cpyxq[1],-1*arr_cpyxq[0],dateyx),"yyyy-MM-dd");
                    jQuery("#"+dateScId).val(formatDate(dateAdd("d",1,date2),"yyyy-MM-dd"));
                }else{
                    jQuery("#"+dateScId).val("");
                }                
            }
        }
    }
}

