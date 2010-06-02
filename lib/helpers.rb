helpers do
	def script(*sources)
    sources.map do |source|
      haml "%script{:type => 'text/javascript', :src => '#{ source }' }", :layout => false
    end.join("\n")
	end
	
	def percent_bar(percent)
		if percent.is_a? Float
			percent = (percent * 100).round(4)
		end

		capture_haml do
			haml_tag :span, { :class => "percent" } do
				haml_tag :span, "#{percent}%", { :style => "width: #{ percent }%" }
			end
		end
	end

  def clippy(text, bgcolor='#FFFFFF')
    html = <<-EOF
%object{  :type => "application/x-shockwave-flash",
          :data => "/clippy.swf",
          :width => "14",
          :height => "14",
          :id => "clippy" }
  %param(name="movie" value="/clippy.swf")
EOF
    haml html, :layout => false
  end
end
