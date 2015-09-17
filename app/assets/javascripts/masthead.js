$(window).load(function() {

	setInterval(function(){
		$("#institution_heading")[0].style.display = ($( window ).width()<=550) ? "none" : "inline";
		$("#words")[0].style.display = ($( window ).width()<385) ? "none" : "inline";
	}, 3000);
});

$(window).resize(function() {
    if(this.resizeTO) clearTimeout(this.resizeTO);
    this.resizeTO = setTimeout(function() {
        $(this).trigger('resizeEnd');
    }, 500);
});

$(window).bind('resizeEnd', function() {

	$("#institution_heading")[0].style.display = ($( window ).width()<=550) ? "none" : "inline";
	$("#words")[0].style.display = ($( window ).width()<385) ? "none" : "inline";

});