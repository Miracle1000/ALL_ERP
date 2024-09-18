function showFieldColor(v, bType) {
    var s = v;
    if (bType == "kuout") {
        s = "<span style='color:red'>" + s + "</span>";
    }
    return s;
}