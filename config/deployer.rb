def remote_command(host, command, as_string = false)
	cmd = "ssh #{ host } '#{ command }'"
	return cmd if as_string
	`#{ cmd }`
end

def deploy_from_local_git(host, branch, destination)
	archive = "git archive --format=tar #{branch}"

	command = [ "mkdir -p #{destination}",
							"cd #{destination}",
							"tar xf -",
							#"thin -R config.ru restart"
						].join(" && ")
	
	puts command
	`#{ archive } | #{ remote_command(host, command, true) }`	
end

host = "www-data@narbsy.com"
deploy_to = "/var/www/rbtorrent/"
branch = "master"

deploy_from_local_git host, branch, deploy_to

