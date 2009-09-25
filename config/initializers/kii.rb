# The template lystem
CURRENT_TEMPLATE = Kii::Template.new(Kii::CONFIG[:template])
CURRENT_TEMPLATE.run_template_init_file



# Core extensions
Dir["#{Rails.root}/lib/*_ext/*.rb"].each {|e| require e }



# We want a span
ActionView::Base.field_error_proc = proc {|html_tag, instance| %{<span class="field_with_errors">#{html_tag}</span>} }