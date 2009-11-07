namespace :migrations do
  desc "20091107211945_add_counter_cache_to_discussions"
  task :discussion_counter_cache => :environment do
    puts "Updating"
    ActiveRecord::Base.record_timestamps = false
    # Ugh, that custom bump_timestamps method makes this fugly.
    Discussion.instance_eval { define_method(:bump_timestamps) {} }
    
    Discussion.all.each do |discussion|
      count = discussion.discussion_entries.count
      Discussion.update_counters(discussion.id, :discussion_entries_count => count)
    end
    
    puts "Done"
  end
end