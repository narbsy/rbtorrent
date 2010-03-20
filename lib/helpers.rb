helpers do
	def script(src)
		haml "%script{:type => 'text/javascript', :src => '#{ src }' }", :layout => false
	end
end
