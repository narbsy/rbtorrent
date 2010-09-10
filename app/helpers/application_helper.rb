module ApplicationHelper
	def to_percent(percent)
		if percent.is_a? Float
			percent = (percent * 100).round(4)
		end
    percent
	end
end
