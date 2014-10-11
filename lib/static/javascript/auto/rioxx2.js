
document.observe("dom:loaded",function(){
	// set initial display
	$$(".rioxx2_override").each( function(el) {
		rioxx2_updateOverride( el.select( 'input:checked[type=radio]' )[0] );
	});
	// update display on change 
	$$(".rioxx2_override").invoke( "on", "change", "input[type=radio]", function(event) {
		rioxx2_updateOverride( $(Event.element(event)) );
	});
	// rioxx guidelines
	$$(".rioxx2_show_gl").invoke( "on", "click", function(event) {
		$(Event.element(event)).next(".rioxx2_help").toggleClassName( "rioxx2_hidden" );
	});
});

function rioxx2_updateOverride(el)
{
	var basename = el.up(".rioxx2_override").id;
	var input = $(basename+"_input");

	if( el.value === "use_override" )
	{
		input.show();
	}
	else if( el.value === "use_mapping" )
	{
		input.hide();
		input.select( 'input[type!=button],select' ).invoke( "clear" );
	}
}
