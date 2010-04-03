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

  def clippy(text, bgcolor='#FFFFFF')
html = <<-EOF
%object{  :classid => "clsid:d27cdb6e-ae6d-11cf-96b8-444553540000", 
          :width => 110, 
          :height => 14,
          :id => "clippy" }
  %param(name="movie" value="/clippy.swf")
  %param(name="allowScriptAccess" value="always")
  %param(name="quality" value="high")
  %param(name="scale" value="noscale")
  %param(NAME="FlashVars" value="id=url_box_clippy&text=#{text}")
  %param(name="bgcolor" value="#{bgcolor}")
  %embed(src="/clippy.swf"
          width="110"
          height="14"
          name="clippy"
          quality="high"
          allowScriptAccess="always"
          type="application/x-shockwave-flash"
          pluginspage="http://www.macromedia.com/go/getflashplayer"
          FlashVars="text=#{text}"
          bgcolor="#{bgcolor}")
EOF
    haml html, :layout => false
  end
end
