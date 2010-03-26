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
  $('li ' + css).show();
  return false;
}

function show_all(){
  $('li').show();
  return false;
}

function action_with_hash(action, hash){
	$.post(action, { hash: hash }, 
		function(data){
			alert('finished: ' + action + '\n\n\n\n' + data.status);
      var html = $('#' + hash + ' .title .status').html();
      $('#' + hash + ' .title .status').html('[ ' + data.status + ' ]');
		}, "json"
	);
	return false;
}


