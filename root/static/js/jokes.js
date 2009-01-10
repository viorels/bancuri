/*
$(document).ready(function() {
	$("#banc").editable("/edit", {
		"paramName": "banc",
		"callback": finishEdit,
		"saving": '<img src="/static/img/working.gif">', 
		"type": "textarea",
		"extraParams": { id:42 }
	});
});

function finishEdit(me) {
	console.info("finishEdit");
	console.log(this);
	console.log(me);
}
*/

// TODO expand textarea in FF
// http://www.webdeveloper.com/forum/archive/index.php/t-61552.html

$(document).ready(function() {
    var got_versions = false;
    $("#btn_versions").toggle(
        function() {
            if (got_versions) {
                $("#versions").slideDown();
            }
            else {
                get_versions();
                got_versions = true;
            }
        },
        function() {
            $("#versions").slideUp();
        }
    );
	
	$("#id").blur(check_id);
	$("#login_form").submit(login);
});

function joke_id() {
    return _joke_id;
}

function joke_link() {
    if (_joke_link) {
        return _joke_link;
    };
    var path = document.location.pathname;
    var path_parts = path.split('/');
    var link = path_parts[1];
    return link;
}

function get_versions() {
    $.getJSON(joke_link()+'/v/all', function(data) {
        var versions = $("#versions");
        $.each(data["json_joke_versions"], function(i, version) {
            versions.append( build_version(version) );
        });
        $("#versions").slideDown();
    });
}

function build_version(version) {
    var html = $("<div>").addClass("post");
    html.append( $("<h4>").text(version["title"]) );
    var details = $("<ul>").addClass("post_info");
    details.append( $("<li>").addClass("date").html('Posted by <a href="#">enks</a> on 11.14.2006') );
    details.append( $("<li>").addClass("comments").html('<a href="#">44 comments</a>') );
    html.append(details);

    if ( version["current"] ) {
        html.append( $("<textarea>").val(version["text"]).addClass("edit") );
    }
    else {
        html.append( $("<p>").text(version["text"]).addClass("alternative") ); 
    }

    return html;
}

function check_id() {
	// remove all the class add the messagebox classes and start fading
	$("#id_res").removeClass().addClass('messagebox').text('Checking...').fadeIn("slow");
	// check the username exists or not from ajax
	$.getJSON("/auth/id_exists",{ id:$(this).val() } ,function(data) {
		// TODO check if response is for current id (last request)
		if( data["json_id_exists"] ) {
			// start fading the messagebox
			$("#id_res").fadeTo(200,0.1,function() {
				//add message and change the class of the box and start fading
				$(this).html('This User name Already exists').addClass('messagebox_error').fadeTo(900,1);
			});
		}
		else {
			// start fading the messagebox
			$("#id_res").fadeTo(200,0.1,function() {
				// add message and change the class of the box and start fading
		    	$(this).html('Username available to register').addClass('messagebox_ok').fadeTo(900,1);
			});
		}
	});
};

function login() {
	// remove all the class add the messagebox classes and start fading
    $("#id_res").removeClass().addClass('messagebox').text('Validating....').fadeIn(1000);
    // check the username exists or not from ajax
    $.post("/auth/login", $("#login_form").serialize(), function(data) {
		if ( data['json_login'] ) {
			$("#id_res").fadeTo(200,0.1,function() { // start fading the messagebox
				// add message and change the class of the box and start fading
				$(this).html('Logging in.....').addClass('messagebox_ok').fadeTo(900,1,
				function() {
					$("#btn_profile").text(data['json_login']['name']);
				});
            });
		}
		else {
			$("#id_res").fadeTo(200,0.1,function() { // start fading the messagebox
				// add message and change the class of the box and start fading
				$(this).html('Your login detail sucks...').addClass('messagebox_error').fadeTo(900,1);
            });
		}
	}, 'json');
	return false; // not to post the  form physically
};

