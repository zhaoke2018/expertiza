class VersionsController < ApplicationController
  def action_allowed?
    ['Administrator',
     'Super-Administrator',].include? current_role_name
  end

  def index
    redirect_to '/versions/search'
  end

  def show
    @version = Version.find_by(id: params[:id])
  end

  def search
    @per_page = params[:num_versions]

    # Get the versions list to show on current page
    @versions = if params[:post]
                  paginate_list
                else
                  Version.page(params[:page]).order('id').per_page(25).all
                end
  end

  private

  # For filtering the versions list with proper search and pagination.
  def paginate_list
    versions = Version.page(params[:page]).order('id').per_page(25)
    versions = versions.where(id: params[:id]) if params[:id].to_i > 0
    versions = versions.where(whodunnit: params[:whodunnit])
    versions = versions.where(item_type: params[:post][:item_type]) if params[:post][:item_type] && params[:post][:item_type] != 'Any'
    versions = versions.where(event: params[:post][:event]) if params[:post][:event] && params[:post][:event] != 'Any'
    versions.where('created_at >= ? and created_at <= ?', Time.parse(time_to_string(params[:start_time])).getutc, Time.parse(time_to_string(params[:end_time])).getutc)
  end

  def time_to_string(time)
    "#{time.tr('/', '-')}:00"
  end
end
