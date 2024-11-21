class Admin::Settings::PositionsController < Admin::BaseController
  skip_load_and_authorize_resource

  def update
    resource = resource_class.find(params[:resource_id])
    if resource.respond_to?(:parent_id)
      move_when_acts_as_nested_set(resource)
      redirect_back_or_to admin_settings_root_path
    else
      move_when_acts_as_list(resource)
      head :ok
    end
  end

  private

  def move_when_acts_as_nested_set(resource)
    if sibling_resource_in_params?
      resource.move_to_left_of(sibling_resource) if sibling_resource.root?
    else
      move_to_the_end(resource)
    end
  end

  def move_to_the_end(resource) = resource.move_to_right_of(resource_class.roots.last)

  def move_when_acts_as_list(resource) = resource.insert_at(position)

  def sibling_resource = @sibling_resource ||= resource_class.find_by(id: sibling_resource_id)

  def resource_class = safe_resource_class.classify.constantize

  def safe_resource_class
    Zeitwerk::Loader.eager_load_all
    if ApplicationRecord.descendants.map(&:to_s).include?(params[:resource_class])
      params[:resource_class]
    else
      raise ActionController::RoutingError, "Not Found"
    end
  end

  def sibling_resource_in_params? = sibling_resource_id.present?

  def sibling_resource_id = params[:sibling_resource_id]

  def position = params[:position].to_i
end
