function repos() {
    var all = document.querySelectorAll('.group-row .title a');
    var res = [];
    all.forEach(function (e) {
        var u = new URL(e);
        var p = u.pathname;
        if (p == null)
            return;
        res.push(p);
    }, this);
    console.log(JSON.stringify(res));
}