function action_with_hash(action, hash){
	$.post(action, { hash: hash }, 
		function(){ 
			alert('finished'); 
		}
	);
	return false;
}
