# Filters added to this controller apply to all controllers in the refinery backend.
# Likewise, all the methods added will be available for all controllers in the refinery backend.

# You can extend refinery backend with your own functions here and they will likely not get overriden in an update.


class Admin::BaseController < Admin::ActionController::Base
  before_filter :authenticate_admin!, :restrict_plugins, :restrict_controller

  protected

  def restrict_plugins
      current_length = (plugins = current_admin.authorized_plugins).length

      # Superusers get granted access if they don't already have access.
      if current_admin.has_role?(:superuser)
        if (plugins = plugins | ::Refinery::Plugins.registered.names).length > current_length
          current_admin.plugins = plugins
        end
      end

      Refinery::Plugins.set_active(plugins)
    end
end
