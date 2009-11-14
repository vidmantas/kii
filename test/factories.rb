Factory.define(:page) do |p|
  p.title = "A new page"
  p.revision_attributes = {:body => "Hello, World.", :remote_ip => "0.0.0.0", :referrer => "/"}
end

# Requires page
Factory.define(:revision) do |r|
  r.body = "Hello, World."
  r.remote_ip = "0.0.0.0"
  r.referrer = "/"
end

Factory.define(:discussion) do |d|
  d.title = "What about that?"
  d.page {|d| Factory(:page, :title => "For discussion #{d.title}, #{Factory.rand}") }
  d.discussion_entry_attributes = {:body => "Do you agree?", :remote_ip => "0.0.0.0", :referrer => "/"}
end

Factory.define(:discussion_entry) do |de|
  de.body = "I disagree."
  de.remote_ip = "0.0.0.0"
  de.referrer = "/"
  de.discussion { Factory(:discussion) }
end

Factory.define(:user) do |u|
  u.login { "admin-#{Factory.rand}" }
  u.password = "12345"
  u.password_confirmation = "12345"
end

Factory.define(:configuration) do |c|
  c.key = "foo"
  c.value "bar"
end