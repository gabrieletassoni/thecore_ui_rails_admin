# app/helpers/rails_admin_filter_helper.rb
module RailsAdminFilterControllerHelper
  def self.filters_html_list(query_string, model_name)
    params = Rack::Utils.parse_nested_query(query_string)
    return '<p>No filters to be saved</p>'.html_safe unless params['f'].is_a?(Hash)

    model_class = model_name.to_s.camelize.safe_constantize
    return '<p>Unknown model</p>'.html_safe unless model_class

    abstract_model = RailsAdmin::AbstractModel.new(model_class)

    filters = []

    params['f'].each do |field_name, condition_group|
      # Use Rails i18n to get field label
      label = model_class.human_attribute_name(field_name)

      condition_group.each do |_idx, condition|
        op_key = condition['o']
        value = condition['v']

        next if op_key.blank? || value.blank?

        op_label = rails_admin_operator_label(op_key, abstract_model.properties.find { |p| p.name.to_s == field_name.to_s })

        value_str = case value
        when Array
          value.join(', ')
        when 'true'
          'Yes'
        when 'false'
          'No'
        else
          value.to_s
        end

        filters << "#{label} #{op_label} #{value_str}"
      end
    end

    filters.join('<br>').html_safe
  end

  def self.rails_admin_operator_label(op_key, field = nil)
    scope = [:admin, :filters, :operators]
    type = field&.type&.to_sym
    key = "#{op_key}_#{type}".to_sym

    # Try field-specific operator label, then general one
    I18n.t(key, scope: scope, default: I18n.t(op_key.to_sym, scope: scope, default: op_key.humanize))
  end
end
