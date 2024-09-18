
    function inselect4() {
        document.date.sort1.length = 0;
        if (document.date.sort.value == "0" || document.date.sort.value == null)
            document.date.sort1.options[0] = new Option('客户分类', '0');
        else {
            for (i = 0; i < ListUserId4[document.date.sort.value].length; i++) {
                document.date.sort1.options[i] = new Option(ListUserName4[document.date.sort.value][i], ListUserId4[document.date.sort.value][i]);
            }
        }
        var index = document.date.sort.selectedIndex;
        //sname.innerHTML=document.date.sort.options[index].text
    }

    //-->
