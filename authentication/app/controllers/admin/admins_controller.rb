class Admin::AdminsController < Admin::BaseController

  crudify :admin, :order => 'login ASC', :title_attribute => 'login'

  before_filter :load_available_plugins_and_roles, :only => [:new, :create, :edit, :update]

  layout 'refinery/admin'

  def new
    @admin = Admin.new
    @selected_plugin_names = []
  end

  def create
    @admin = Admin.new(params[:admin])
    @selected_plugin_names = params[:admin][:plugins] || []
    @selected_role_names = params[:admin][:roles] || []

    if @admin.save
      @admin.plugins = @selected_plugin_names
      # if the Admin is a superAdmin and can assign roles according to this site's
      # settings then the roles are set with the POST data.
      unless current_admin.has_role?(:superAdmin) and RefinerySetting.find_or_set(:superadmin_can_assign_roles, false)
        @admin.add_role(:refinery)
      else
        @admin.roles = @selected_role_names.collect{|r| Role[r.downcase.to_sym]}
      end

      redirect_to(admin_Admins_url, :notice => t('refinery.crudify.created', :what => @admin.login))
    else
      render :action => 'new'
    end
  end

  def edit
    @admin = Admin.find params[:id]
    @selected_plugin_names = @admin.plugins.collect{|p| p.name}
  end

  def update
    # Store what the Admin selected.
    @selected_role_names = params[:admin].delete(:roles) || []
    unless current_Admin.has_role?(:superAdmin) and RefinerySetting.find_or_set(:superAdmin_can_assign_roles, false)
      @selected_role_names = @admin.roles.collect{|r| r.title}
    end
    @selected_plugin_names = params[:admin][:plugins]

    # Prevent the current Admin from locking themselves out of the Admin manager
    if current_Admin.id == @admin.id and (params[:admin][:plugins].exclude?("refinery_Admins") || @selected_role_names.map(&:downcase).exclude?("refinery"))
      flash.now[:error] = t('admin.Admins.update.cannot_remove_Admin_plugin_from_current_Admin')
      render :action => "edit"
    else
      # Store the current plugins and roles for this Admin.
      @previously_selected_plugin_names = @admin.plugins.collect{|p| p.name}
      @previously_selected_roles = @admin.roles
      @admin.roles = @selected_role_names.collect{|r| Role[r.downcase.to_sym]}
      if params[:admin][:password].blank? and params[:admin][:password_confirmation].blank?
        params[:admin].delete(:password)
        params[:admin].delete(:password_confirmation)
      end

      if @admin.update_attributes(params[:admin])
        redirect_to admin_Admins_url, :notice => t('refinery.crudify.updated', :what => @admin.Adminname)
      else
        @admin.plugins = @previously_selected_plugin_names
        @admin.roles = @previously_selected_roles
        @admin.save
        render :action => 'edit'
      end
    end
  end

protected

  def load_available_plugins_and_roles
    @available_plugins = ::Refinery::Plugins.registered.in_menu.collect{|a|
      {:name => a.name, :title => a.title}
    }.sort_by {|a| a[:title]}

    @available_roles = Role.find(:all)
  end

end
