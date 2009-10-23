class PageContentAgeDiff < ActiveRecord::Base
  def data_as_objects=(objects)
    self.data = Marshal.dump(objects.map {|o| [o.text, o.timestamp.to_f]})
  end
  
  def data_as_objects
    @data_as_objects ||= Marshal.load(self.data).map {|text, timestamp| Kii::Diff::AgeVisualization::Revision.new(text, Time.at(timestamp)) }
  end
end
