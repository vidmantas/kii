# The template lystem
template = Configuration[:template] rescue "default" # database isn't around when rake kii:install runs
Kii::Template.new(template)



# Core extensions
Dir["#{Rails.root}/lib/*_ext/*.rb"].each {|e| require e }



# We want a span
ActionView::Base.field_error_proc = proc {|html_tag, instance| %{<span class="field_with_errors">#{html_tag}</span>} }