

// Used by the Screen::Report::render method

var EPrints_Screen_Report_Loader = Class.create({
	has_problems: 0,
	count: 0,
	runs: 0,
	progress: null,
	ids: Array(),
	step: 20,
	prefix: '',
	onProblems: function() {},
	onFinish: function() {},
	url: "",
	parameters: "",
	container: null,

	// to show a pretty progress bar (% compliance):
	total_dataobjs: 0,
	total_noncompliant: 0,


	initialize: function(opts) {

		if( opts.ids )
			this.ids = opts.ids;
		if( opts.step )
			this.step = opts.step;
		if( opts.prefix )
			this.prefix = opts.prefix;
		if( opts.onFinish )
			this.onFinish = opts.onFinish;
		if( opts.onProblems )
			this.onProblems = opts.onProblems;
		if( opts.url )
			this.url = opts.url;
		if( opts.parameters )
			this.parameters = opts.parameters;
		if( opts.container_id )
			this.container = $( opts.container_id );	// should fail if container doesn't exist...
	},

	execute: function() {

		// progress-bar

		this.container.insert( new Element( 'div', { 'class': 'ep_report_progress_bar', 'id': this.prefix + "_progress_bar" } ) );	

		var current_grouping = null;	// might not be set in the returned value but that's allowed/OK

		var dataobjs = {};

		for(var i = 0; i < this.ids.length; i+=this.step)
		{
			// arguments for Ajax query AND creates the HTML placeholders <div>'s (that will receive the content of the Ajax query...)

			var args = '&ajax='+this.prefix;
			for(var j = 0; j < this.step && i+j < this.ids.length; j++)
			{
				args += '&' + this.prefix + '=' + this.ids[i+j];
				this.container.insert( new Element( 'div', { 'class': 'ep_report_row', 'id': this.prefix + '_' + this.ids[i+j] } ), { 'position': 'after' } );
			}

			new Ajax.Request( this.url, {
				method: 'get',
				parameters: this.parameters + args,
				onSuccess: (function(transport) {

					var json = transport.responseText.evalJSON();
					var data = json.data;

					if( data == null )
						data = new Array();

					for( var i=0; i<data.length; i++ )
					{
						this.count++;
						var entry = data[i];

						// entry.dataobjid
						// entry.summary
						// entry.grouping
						// entry.problems

						if( entry == null )
							continue;
						
						var dataobjid = entry.dataobjid;
						if( dataobjid == null )
							continue;

						dataobjs[dataobjid] = entry;
					}
				
					// we've retrieved all the records
					if( this.count == this.ids.length )
					{
						$( this.prefix + '_progress_bar' ).remove();
						if( this.has_problems )
							this.onProblems(this);
						this.onFinish(this);

						for( var c = 0; c < this.ids.length; c++ )
						{
							var dataobjid = this.ids[c];
							var entry = dataobjs[dataobjid];

							this.total_dataobjs++;

							var summary = entry.summary;

							var target_el = $( this.prefix + '_' + dataobjid );

							if( target_el != null && summary != null )
							{
								var summary_el = target_el.appendChild( new Element( 'div', { 'class': 'ep_report_row_summary' } ) );
								summary_el.update( summary );

								if( entry.problems && entry.problems.length )
								{
									this.total_noncompliant++;
									var problems_el = target_el.appendChild( new Element( 'ul', { 'class': 'ep_report_row_problems' } ) );

									for( var p=0; p< entry.problems.length; p++ )
									{
										var li = problems_el.appendChild( new Element( 'li' ));
										li.update( entry.problems[p] );
									}
									
									target_el.addClassName( 'ep_report_row_problems' );
								}
								else
								{
									target_el.addClassName( 'ep_report_row_ok' );
								}
								
								target_el.show();

								var grouping = entry.grouping;
								if( grouping != null )
								{
									if( current_grouping == null || current_grouping != grouping)
									{
										current_grouping = grouping;
										var grouping_container = new Element( 'div', { 'class': 'ep_report_grouping' } );
										target_el.insert( { 'before' : grouping_container } );
										grouping_container.update( current_grouping );
									}
								}
							}
						}


						if( this.total_dataobjs )
						{
							this.container.insertBefore( new Element( 'div', { 'class': 'ep_report_compliance_container', 'id': this.prefix + "_compliance_container" } ), this.container.firstChild );

							var ref_width = 200;
							var compliance = ( this.total_dataobjs - this.total_noncompliant ) / this.total_dataobjs;

							$( this.prefix + "_compliance_container" ).appendChild( new Element( 'div', { 'class': 'ep_report_compliance_wrapper', 'id': this.prefix + "_compliance", 'style': 'width: '+ref_width + 'px' } ) );


							var compliance_width = Math.floor( 200 * compliance );

							$( this.prefix + "_compliance" ).appendChild( new Element( 'div', { 'class': 'ep_report_compliance', 'style': 'width:'+compliance_width + 'px' } ) );


							$( this.prefix + "_compliance_container" ).appendChild( new Element( 'div', { 'class': 'ep_report_compliance_text', 'id': this.prefix + "_compliance_text",  } ));

							$( this.prefix + "_compliance_text" ).update( this.total_dataobjs + " outputs - " + Math.floor( compliance * 100 ) + "% compliance");
						}


					}
					else
					{
						var width = 200;
						$( this.prefix + '_progress_bar' ).style.backgroundPosition = Math.round(-width + width * this.count / this.ids.length) + "px 0px";
					}

					if( this.runs == 0 && this.count == 0 )
					{
						var pNode = $( this.prefix + '_progress_bar' ).parentNode;
						$(this.prefix + '_progress_bar').remove();
						var span = new Element( 'span', { 'class': 'ep_ref_report_empty' } );
						span.update( 'Report empty' );
						pNode.insert( span );
					}
					this.runs++;

				}).bind(this)
			});
		}
		if( this.ids == null || this.ids.length == 0 )
		{
			var pNode = $(this.prefix + '_progress_bar').parentNode;
			$(this.prefix + '_progress_bar').hide();
			var span = new Element( 'span', { 'class': 'ep_ref_report_empty' } );
			span.update( 'Report empty' );
			pNode.insert( span );
		}
	}


});

