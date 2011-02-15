var common_functions = function() {
										
	// Show tips on any elements that has class="show_tips"
	new Tips('.show_tips');
};

var spinner = null;
var upload_iframe_callback = function(result) {
	
	// Clear out old result
	$('upload_result').set("html", "");
	
	// The upload image calls back to this function
	spinner.hide();
	$('badge_image').set("value", "");
	$('upload_result').removeClass("hidden");
	
	// Creating an new anchor with an Object
	var message = new Element('span', { html: result.message });
	if(result.result == "success") { 
		
		// On successful upload do this...
		message.setAttribute("class", "success left");
		
		var image_div = new Element('div', { 
			'class' : "image left",
			style : "margin: 0 5px 0 0;"
		 });
		
		var t = new Element('img', { 
			src : result.url
		});

		t.inject(image_div);
		image_div.inject("upload_result");
		message.inject("upload_result");
		
		new Element('div', { 'class' : "clear"}).inject("upload_result");
		
		// remove 'no images' text (if there)
		var noImages = document.getElementById("noImages")
		if (noImages) {
			noImages.parentNode.removeChild(noImages);
		}
	} else {
		// Errors...
		message.setAttribute("class", "error");
		message.inject("upload_result");
	}
};

var onload_client_images = function() {
	
	$('image_upload').addEvent("submit", function() {
		
		// Validation...
		if($('badge_image').get("value").clean().length == 0) return false;
		
		// Spinner while working...		
		spinner = new Spinner('image_upload', {
			message : "Uploading your badge..."
		});
		spinner.show();
	});	
};

var image_selector = function() {

	// Add onclick to the badge images
	$$(".image").each(function(item) {
		
		item.addEvent("click", function(e) {
			e.stop();
			
			var image_id = item.getAttribute("data-badge-image-id");
						
			// Remove selected from any other badge
			$$('.image').each(function(i2) { i2.removeClass("selected"); });
			item.addClass("selected");
			$('badge_image_id').set("value", image_id);
		});
	});
	
	$$('.see_more').each(function(item) {
		item.addEvent("click", function() {
			
			var rows = item.getParent().getChildren("LI.hidden");
			
			if(rows.length > 0) {

				// Pop next row
				var next = rows.shift();
				
				// Show it
				next.reveal();
				next.removeClass("hidden");
				
				// If no rows left hidden, hide the show more
				if(rows.length == 0) item.dissolve();
			}
						
			return false;
		});
	});		
};

var add_feat_row = function(options) {
	// add a row to the rows collection and get a reference to the newly added row
	var theTable = document.getElementById("feat_table")
    var newRow = theTable.insertRow(theTable.rows.length);
  
    var oCell = newRow.insertCell();
    oCell.innerHTML = "<input type='button' value='Remove' onclick='remove_feat_row(this);'>";

    oCell = newRow.insertCell();
    oCell.innerHTML = "<input type='text' id='thresholds[]' name='thresholds[]'>" 

    oCell = newRow.insertCell();
    oCell.innerHTML = "<select id='feats[]' name='feats[]'>" + options + "</select>";

	// remove 'no feats' text (if there)
	var noFeats = document.getElementById("noFeats")
	if (noFeats) {
		noFeats.parentNode.removeChild(noFeats);
	}
}

var remove_feat_row = function(src) {
	/* src refers to the input button that was clicked. 
       to get a reference to the containing <tr> element,
       get the parent of the parent (in this case <tr>)
    */   
    var oRow = src.parentElement.parentElement;  
    //once the row reference is obtained, delete it passing in its rowIndex   
    document.getElementById("feat_table").deleteRow(oRow.rowIndex);
}

var onload_client_new_badge = function() {
	image_selector();
}

var onload_client_edit_badge = function() {
	image_selector();	
}
