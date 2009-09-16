class ActivitiesController < ApplicationController
  def index
    ungrouped_revisions = Revision.find(:all, :order => "created_at DESC", :limit => 50, :include => [:page, :user])
    first = ungrouped_revisions.first.created_at
    last = ungrouped_revisions.last.created_at
    
    # TODO: This is one of the few cases where meta-programming would
    # actually clean things up quite a bit ;)
    
    if first.day != last.day && first.month == last.month
      @revisions = ungrouped_revisions.group_by {|r| r.created_at.at_beginning_of_day }.map {|date, revisions|
        ["day", date, revisions]
      }
    elsif first.month != last.month
      @revisions = ungrouped_revisions.group_by {|r| r.created_at.at_beginning_of_month }.map {|date, revisions|
        ["month", date, revisions]
      }
    else
      @revisions = ungrouped_revisions.group_by {|r| r.created_at.at_beginning_of_year }.map {|date, revisions|
        ["year", date, revisions]
      }
    end
  end
end
