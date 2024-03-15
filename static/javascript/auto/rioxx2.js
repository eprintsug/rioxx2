
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
	// rioxx tab title
	var status_el = $("rioxx2_status");
	var title_el = $("rioxx2_tab_title");
	if( status_el && title_el )
	{
		var status = status_el.readAttribute( "data-status" );
		title_el.toggleClassName( "rioxx2_" + status );
	}
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
		input.select( 'input[type!=button]:not(input[type=hidden]),select' ).invoke( "clear" );
	}
}
