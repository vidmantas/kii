namespace :migrations do
  desc "20091023145531_create_page_content_age_diffs"
  task :page_content_age_diff => :environment do
    puts "Processing existing revisions"
    puts
    
    PageContentAgeDiff.destroy_all
    ActiveRecord::Base.record_timestamps = false
    
    Revision.all(:include => :page, :order => "page_id, revision_number").group_by(&:page).each do |page, revisions|
      puts "Processing #{page.title}..."
      visualizer = Kii::Diff::AgeVisualization.new
      visualizer.revisions = revisions.map {|r| Kii::Diff::AgeVisualization::Revision.new(r.body, r.created_at) }
      visualizer.create_diff_from_revisions

      page.page_content_age_diff = PageContentAgeDiff.create!(:data_as_objects => visualizer.diff)
      page.send(:update_without_callbacks)
    end
  end
end