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
	setup_rating();

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
	if (!_user_exists) {
		$("#btn_profile").click(btn_login_click);
	}
	
	// Vote a change
	$("#change_no").click( function() {
		change_vote( $(this).attr('name'), -5 );
	});
	$("#change_yes").click( function() {
		change_vote( $(this).attr('name'), 5 );
	});

	setup_login_form(); // for /auth/form page only
	
	growl();
});

function setup_rating() {
	var rating_url = '/edit/rating';
	var ratings = ['Nasol', 'Plictisitor', 'OK', 'Bun', 'Tare'];
	$('input[name="joke_rating"]').rating({
		callback: function(value, link) {
			var $rating_value = $('#rating').find('.rating-value');
			var $rating_count = $('#rating').find('.rating-count');
			$rating_value.fadeTo(600, 0.4);
	        $.ajax({
	            url: rating_url,
	            type: "POST",
	            data: 'id=' + joke_id() + '&rating=' + value,
	            complete: function(req) {
	                if (req.status == 200) { // success
	                    var rating = parseFloat(req.responseText);
	                    $rating_value.fadeTo(600, 0.1, function() {
		                    if (rating > 0) {
		                    	$rating_value.text(rating.toFixed(2));
		                        $rating_count.text(parseInt($rating_count.text()) + 1);
		                        $rating_value.fadeTo(500, 1);
		                        // alert('Ai votat: ' + opts.ratings[rating.toFixed(1)-1]);
		                    }
			                else {
		                        $rating_value.fadeTo(500, 1);
		                        // alert('Ai mai votat acest banc azi !');
		                    }
	                    });
	                } 
	                else { // failure
	                    // alert(req.responseText);
	                    $rating_value.fadeTo(2200, 1);
	                }
	            }	            
	        });
        },
/*        
		focus: function(value, link){ 
			var tip = $(this).find('#rating_msg');
			tip[0].data = tip[0].data || tip.html(); 
			tip.html(link.title || 'value: '+value); 
		}, 
		blur: function(value, link){ 
			var tip = $(this).find('#rating_msg');
			$('#hover-test').html(tip[0].data || ''); 
		}         
*/
	});
}

function growl() {
	$.getJSON('/growl/messages', function(data) {
		$.each(data["json_growl"], function(i, growl) {
			$.jGrowl(growl.message, { 
				header: growl.header,
				type: growl.type,
				sticky: true,
//				position: 'bottom-right',
				close: function(e,m,o) {
					$.post("/growl/suppress", { type: o.type });
				}
			});
        });
	});
}

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

// Login ...

function setup_login_form(state) {
	// initialize
	if (state == null) {
		$('#login_form .signup input').attr('disabled', true);
		
		$id = $('#id');
		id_exists($id);
		$id.keyup(function () { id_exists($id) });
		$id.change(function () { id_exists($id) });

		$("#login_form").ajaxForm({
			beforeSubmit: before_login,
			success: after_login,
			dataType: 'json',
		});
	}
	// prepare for login
	else if (state == 'login') {
		$('#login_form .login input').removeAttr('disabled');
		$('#login_form .signup input').attr('disabled', true);
	}
	// prepare for signup
	else if (state == 'signup') {
		$('#login_form .signup input').removeAttr('disabled');
		$('#login_form .login input').attr('disabled', true);
	}

	$("#login_msg").empty();
}

function btn_login_click() {
	$("#authentication").load('/auth/form', {}, function () {
		setup_login_form();
		$(this).slideDown();
	});
	return false;
}

function email_valid(email) {
	var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
	return reg.test(email);
}

var id_last_checked;
function id_exists($id) {
	if ( $id.val() != id_last_checked && email_valid($id.val()) ) {
		id_last_checked = $id.val();

		$("#login_msg").html('<img src="/static/img/working.gif">').removeClass();

		$.getJSON("/auth/id_exists", { id: $id.val() }, function(data) {
			if ($id.val() in data["json_id_exists"]) {
				if ( data["json_id_exists"][$id.val()] ) {
					setup_login_form('login');
				}
				else {
					setup_login_form('signup');
				}
			}
		});
	}
}

function before_login() {
	// remove all the class add the messagebox classes and start fading
    $("#login_msg").removeClass().addClass('messagebox').text('verific ...').fadeIn(1000);

    // check the username exists or not from ajax
	return true; // Allow ajax submit to continue
};

function after_login(data, status) {
	if ( data['json_login'] ) {
		var name = data['json_login']['name'];
		$("#login_msg").fadeTo(200,0.1, function() {
			$(this).html('Salut '+name+' !').addClass('messagebox_ok').fadeTo(900,1, function() {
				$("#authentication").slideUp();
				window.location.pathname = '/auth/redirect_back';
			});
		});
	}
	else {
		var error = data['json_error'];
		$("#login_msg").fadeTo(200,0.1,function() {
			$(this).html(error).addClass('messagebox_error').fadeTo(900,1);
		});
	}
}

function change_vote(btn_name, rating) {
	var change_id = btn_name.match(/[0-9]+$/);
	var vote = {
		change_id: change_id,
		vote: rating,
	};

	$.post('/moderate/change_vote', vote, function(data) {
		var text = data['json_change_msg'];
		$("#change_question").empty().append(text);
	}, 'json');
}
