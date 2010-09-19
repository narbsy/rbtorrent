def remote_command(host, command, as_string = false)
  cmd = "ssh #{ host } '#{ command }'"
  return cmd if as_string
  `#{ cmd }`
end

def deploy_from_local_git(host, branch, destination, files=nil)
  if files then
          archive = "echo \"#{files.join("\n")}\" | tar -c -T -"
  elsif `git status`.lines.count > 2 then
          archive = "tar -c ."
  else
          archive = "git archive --format=tar #{branch}"
  end

  command = [ "mkdir -p #{destination}",
              "cd #{destination}",
              "tar xf -",
              #"thin -R config.ru restart"
              "chown -R www-data:www-data ."
            ].join(" && ")
  
  #puts "#{ archive } | #{ remote_command(host, command, true) }"
  `#{ archive } | #{ remote_command(host, command, true) }`
end

def deploy(*list)
  user = "root"
  host = "#{ user }@narbsy.com"
  deploy_to = "/var/www/rbtorrent/"
  branch = "master"

  list = nil if list.empty?

  deploy_from_local_git host, branch, deploy_to, list
end
