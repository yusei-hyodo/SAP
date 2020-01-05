class Admin::ReleaseController < Admin::ApplicationController
  before_action :set_config
  skip_before_action :check_release_flag!

  def on
    @config.update_attributes(release_flag: true)
    redirect_to admin_root_path
  end

  def off
    @config.update_attributes(release_flag: false)
    redirect_to admin_root_path
  end

  private

  def set_config
    @config = Config.find_by(user_id: current_user.id)
  end
end