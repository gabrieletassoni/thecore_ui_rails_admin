require 'active_support/concern'

module ThecoreUiRailsAdminUser
    extend ActiveSupport::Concern

    included do
        RailsAdmin.config do |config|
            config.model self.name.underscore.capitalize.constantize do
                # rails_admin do
                navigation_label I18n.t("admin.settings.label")
                navigation_icon 'fa fa-user-circle'
                desc I18n.t("activerecord.descriptions.user")
                
                weight 1000
                # Field present Everywhere
                field :email do
                    required true
                end
                #   field :username do
                #     required true
                #   end
                field :admin do
                    visible do
                        bindings[:view].current_user.admin? && bindings[:view].current_user.id != bindings[:object].id
                    end
                end
                field :locked do
                    visible do
                        bindings[:view].current_user.admin? && bindings[:view].current_user.id != bindings[:object].id
                    end
                end
                #   field :roles, :enum do
                #     visible !ROLES.blank?
                #     pretty_value do # used in list view columns and show views, defaults to formatted_value for non-association fields
                #       begin
                #         value.map { |v| bindings[:object].roles_enum.rassoc(v)[0] rescue nil }.compact.join ", "
                #       rescue
                #         I18n.t "roles.#{ROLES[value.to_i - 1]}"
                #       end
                #     end
                #     export_value do
                #       begin
                #         value.map { |v| bindings[:object].roles_enum.rassoc(v)[0] rescue nil }.compact.join ", " # used in exports, where no html/data is allowed
                #       rescue
                #         I18n.t "roles.#{ROLES[value.to_i - 1]}"
                #       end
                #     end
                #     queryable false
                #   end
                # include UserRailsAdminConcern
                
                # Fields only in lists and forms
                list do
                    field :created_at
                    configure :email do
                        visible false
                    end
                    exclude_fields :lock_version
                    field :authentication_token
                    # include UserRailsAdminListConcern
                end
                show do
                    #exclude_fields :id
                    exclude_fields :lock_version
                end
                create do
                    field :password do
                        required true
                    end
                    field :password_confirmation do
                        required true
                    end
                    field :lock_version, :hidden do
                        visible true
                    end
                    # include UserRailsAdminCreateConcern
                end
                edit do
                    field :password do
                        required false
                    end
                    field :password_confirmation do
                        required false
                    end
                    
                    field :lock_version, :hidden do
                        visible true
                    end
                    # include UserRailsAdminEditConcern
                end
            end
        end
    end
end