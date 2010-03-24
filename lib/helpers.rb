helpers do
	def script(src)
		haml "%script{:type => 'text/javascript', :src => '#{ src }' }", :layout => false
	end
	
	def percent_bar(percent)
		if percent.is_a? Float
			percent = (percent * 100).floor
		end

		capture_haml do
			haml_tag :span, { :class => "percent" } do
				haml_tag :span, "#{percent}%", { :style => "width: #{ percent }%" }
			end
		end
	end
end
