
class Admin::DashboardController < Admin::BaseController
  layout 'refinery/admin'
  def index
    @recent_activity = []

    Refinery::Plugins.active.each do |plugin|
      begin
        plugin.activity.each do |activity|
          @recent_activity << activity.class.find(:all,
            :conditions => activity.conditions,
            :order => activity.order,
            :limit => activity.limit
          )
        end
      rescue
        logger.warn "#{$!.class.name} raised while getting recent activity for dashboard."
        logger.warn $!.message
        logger.warn $!.backtrace.collect { |b| " > #{b}" }.join("\n")
      end
    end

    @recent_activity = @recent_activity.flatten.compact.sort { |x,y|
      y.updated_at <=> x.updated_at
    }.first(activity_show_limit=RefinerySetting.find_or_set(:activity_show_limit, 7))

    @recent_inquiries = defined?(Inquiry) ? Inquiry.latest(activity_show_limit) : []
  end

  def disable_upgrade_message
    RefinerySetting.find(:first, :conditions => {
        :name => 'show_internet_explorer_upgrade_message',
        :scoping => 'refinery'
      }
    ).update_attribute(:value, false)
    render :nothing => true
  end

end