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
    update_location_hash();
    var got_alternatives = false;
    $("#btn_alternatives").toggle(
        function() {
            if (got_alternatives) {
                $("#alternatives").slideDown();
            }
            else {
                get_alternatives();
                got_alternatives = true;
            }
        },
        function() {
            $("#alternatives").slideUp();
        }
    );
});

function update_location_hash() {
    document.location.hash = joke_id();
};

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

function get_alternatives() {
    $.getJSON(joke_link()+'/v/all', function(data) {
        var alternatives = $("#alternatives");
        $.each(data["json_joke_versions"], function(i, alternative) {
            alternatives.append( build_alternative(alternative) );
        });
        $("#alternatives").slideDown();
    });
}

function build_alternative(alt) {
    var html = $("<div>").addClass("post");
    html.append( $("<h4>").text(alt["title"]) );
    var details = $("<ul>").addClass("post_info");
    details.append( $("<li>").addClass("date").html('Posted by <a href="#">enks</a> on 11.14.2006') );
    details.append( $("<li>").addClass("comments").html('<a href="#">44 comments</a>') );
    html.append(details);

    if ( alt["current"] ) {
        html.append( $("<textarea>").val(alt["text"]).addClass("edit") );
    }
    else {
        html.append( $("<p>").text(alt["text"]).addClass("alternative") ); 
    }

    return html;
}

