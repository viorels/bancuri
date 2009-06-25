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
	
	$('#rating').rater({ postHref: '/edit/rating', id: joke_id() });

	// Show versions
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
	
	// Profile
	$("#btn_profile").click(function() {
		$("#authentication").load('/auth/form', {}, 
			function (responseText, textStatus, XMLHttpRequest) {
				$(this).slideDown();
				$("#id").blur(check_id);
				$("#login_form").ajaxForm({
					beforeSubmit: login_pre,
					success: login_cb,
					dataType: 'json',
				});
			}
		);
		return false;
	});
	
	// Vote a change
	$("#change_no").click( function() {
		change_vote( $(this).attr('name'), -5 );
	});
	$("#change_yes").click( function() {
		change_vote( $(this).attr('name'), 5 );
	});
	
	setup_logout();
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
	$("#id_res").removeClass().addClass('messagebox').text('Te cunosc ?').fadeIn("slow");
	// check the username exists or not from ajax
	$.getJSON("/auth/id_exists",{ id:$(this).val() } ,function(data) {
		// TODO check if response is for current id (last request)
		if( data["json_id_exists"] ) {
			// start fading the messagebox
			$("#id_res").fadeTo(200,0.1,function() {
				//add message and change the class of the box and start fading
				$(this).html('Te cunosc dar zi parola').addClass('messagebox_ok').fadeTo(900,1);
				$('#login_form .signup').hide();
				$('#btn_login').show();
			});
		}
		else {
			// start fading the messagebox
			$("#id_res").fadeTo(200,0.1,function() {
				// add message and change the class of the box and start fading
		    	$(this).html('Nu te cunosc dar zi-mi o parola').addClass('messagebox_ok').fadeTo(900,1);
				$('#login_form .signup').show();
				$('#btn_login').hide();
			});
		}
	});
};

function login_pre() {
	// remove all the class add the messagebox classes and start fading
    $("#id_res").removeClass().addClass('messagebox').text('Verific parola ...').fadeIn(1000);

    // check the username exists or not from ajax
	return true; // Allow ajax submit to continue
};

function login_cb(data, status) {
	if ( data['json_login'] ) {
		var name = data['json_login']['name'];
		$("#id_res").fadeTo(200,0.1,function() { // start fading the messagebox
			// add message and change the class of the box and start fading
			$(this).html('Salut '+name+' !').addClass('messagebox_ok').fadeTo(900,1,
			function() {
				$("#btn_profile").text(name);
				$("#menu").children("ul")
					.append('<li><a id="btn_logout" href="#">Logout</a></li>');
				setup_logout();
				$("#authentication").slideUp();
			});
		});
	}
	else {
		var error = data['json_error'];
		$("#id_res").fadeTo(200,0.1,function() { // start fading the messagebox
			// add message and change the class of the box and start fading
			$(this).html(error).addClass('messagebox_error').fadeTo(900,1);
		});
	}
}

function setup_logout() {
	$("#btn_logout").click(function () {
		$.post("/auth/logout", {}, function () {
			window.location.reload()
		})
	})
}

function change_vote(btn_name, rating) {
	var change_id = btn_name.match(/[0-9]+$/);
	var vote = {
		change_id: change_id,
		vote: rating,
	};

	$.post('/edit/change_vote', vote, function(data) {
		var text;
		if (data['json_change_error']) {
			text = data['json_change_error'];
		}
		else {
			// Do you agree with the majority ?
			var agree = rating * data['json_change_rating'] > 0;
			if (agree) {
				text = 'Esti de acord cu majoritatea';
			}
			else {
				text = 'Majoritatea nu este de acord cu tine';
			}
		}
	
		$("#change_question").empty().append(text);
	}, 'json');
}
