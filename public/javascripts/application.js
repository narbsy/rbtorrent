var update_interval = undefined;

$(document).ready(function() {
  // Show/hide sibling .torrent
  $('.title').click(function() {
    $(this).siblings('.torrent').slideToggle();
  });
  
  var seconds = 1000;
  // var seconds = 200000; // million years
  var minutes = 60 * seconds;

  update_interval = setInterval( check_for_updates, 10 * seconds );
  // Idle after 1 minute
  $.idleTimer( 1 * minutes );

  $(document).bind("idle.idleTimer", function() {
    change_update_interval(15 * minutes);
  });
  
  $(document).bind("active.idleTimer", function() {
    change_update_interval(10 * seconds);
  }); 
});

function change_update_interval(new_interval) {
  clearInterval(update_interval);
  update_interval = setInterval( check_for_updates, new_interval );
}

function check_for_updates() {
  $.get('torrents/check');
}

function update_torrents(data){
  data.forEach( function(update) {
    var hash = update.hash;
    var css_id = torrent_id(hash);
    // ratio
    var elem = $(css_id + ' .torrent .ratio');
    $(elem).text('Ratio: ' + (update.ratio / 1000).toFixed(3));
    //percentage
    elem = $(css_id + ' .torrent .percentage .percent span');
    var percent = (update.percentage * 100).toFixed(2);
    $(elem).text(percent + '%');
    $(elem).css('width', percent + '%');
    //status
    update_status(hash, update.status);
    //up, down rates
    // var up = (update.up_rate / 1024).toFixed(2);
    // var down = (update.down_rate / 1024).toFixed(2);
    var elem = $(css_id + ' .torrent .rates');
    $(elem).text('Upload: ' + update.up_rate.toFixed(1) + 'KB/s Download: ' + update.down_rate.toFixed(1) + 'KB/s');
  } );
}

function hide_all_but(css_class) {
  var css = '.' + css_class
  $('.content li:not(' + css + ') .title').siblings().hide();
  $('.content li' + css + ' .title').siblings().show();
  return false;
}

function show_all() {
  $('.content li .title').siblings().show();
  return false;
}

function update_status(hash, new_status) {
  $(torrent_id(hash) + ' .title .status').html('[ ' + new_status + ' ]');
}

function slide(event, closed, open) {
  $(event.target).siblings().toggle();
  var text = $(event.target).text();
  $(event.target).text( text == closed ? open : closed );
  return text == closed;
}

function torrent_id(hash) {
  return '#t' + hash;
}

function delete_file(hash, index) {
  $.ajax({
    url: '/files/' + hash + '/' + index,
    type: 'DELETE',
    success: function(data) {
      alert("Successfully deleted file no. " + index + " from disk.");
    }
  });
}

