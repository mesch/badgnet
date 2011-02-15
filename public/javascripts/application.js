// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var common_functions = function() {
		
	if($('login_button')) {
		// For user login
		
		// Create the modal for the friends select and add the content we will eventually show
		// http://www.jsfiddle.net/zNMQy/19/
		modal = new Modal({
			"modal_id" : "login_modal", 
			'content_id' : 'login_modal_content',
			'onButton': function(e, button) {
				e.stop();
			    this.hide();
			}
		});

		// Inject login modal code into the modal
		$('login_modal_form').inject("login_modal_content");
		$('login_modal_form').removeClass("hidden");

		$('login_button').addEvent('click', function(e) {
			e.stop();
			modal.show();
			return false;
		});
	}
};


var onload_clients_award = function() {
	
	var fields = ["first_name", "last_name", "email"];
	
	// Clicking a form field resets user dropdown
	fields.each(function(item) {
		$(item).addEvent("click", function() {
			$('user_id').getChildren()[0].set("selected", "selected")
		});
	});
	
	// Clicking dropdown resets fields
	$('user_id').addEvent("change", function() {
		fields.each(function(item) {
			$(item).set("value", "");
		})
	});
	
	["email", "facebook", "twitter"].each(function(item) {
		$("checkbox_" + item).addEvent("click", function() {
			var id = this.get("id").split("_")[1];
			var c = $("container_" + id);
			this.get("checked") ? c.removeClass("hidden") : c.addClass("hidden");
		});
	});
	
};

var onload_users_home = function() {
	var myTips = new Tips('.badge_image');
};