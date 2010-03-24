$(document).ready(function(){
  // Show/hide sibling .torrent
  $('.title').click(function() {
    $(this).siblings('.torrent').slideToggle();
  })
});

function hide_all_but(css_class){
  var css = '.' + css_class
  var li = $('li');
  li.not(css).hide();
  li.filter(css).show();
}

function action_with_hash(action, hash){
	$.post(action, { hash: hash }, 
		function(){
			alert('finished: ' + action); 
		}
	);
	return false;
}


