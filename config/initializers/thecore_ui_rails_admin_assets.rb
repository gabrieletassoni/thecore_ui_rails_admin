Rails.application.configure do
    config.assets.precompile += %w( 
        rails_admin/custom/thecore/ui.js
        rails_admin/custom/thecore/mixins.css
        rails_admin/custom/thecore/variables.css
        rails_admin/custom/thecore/theming.css
    )
end
