class Time
  # This isn't here already for some reason
  def at_beginning_of_hour
    change(:min => 0)
  end
end