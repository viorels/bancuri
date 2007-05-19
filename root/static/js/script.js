$(document).ready(function() {
	$("#banc").editable("/edit", {
		"paramName": "banc",
		"callback": null,
		"saving": '<img src="/static/img/working.gif">', 
		"type": "textarea",
		"submitButton": 0,
		"delayOnBlur": 100,
		"extraParams": { id:42 }
	});
});
