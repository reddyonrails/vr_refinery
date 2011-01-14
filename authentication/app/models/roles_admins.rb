class RolesAdmins < ActiveRecord::Base

  belongs_to :role
  belongs_to :admin

end
