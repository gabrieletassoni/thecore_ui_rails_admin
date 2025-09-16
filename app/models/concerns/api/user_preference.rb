module Api::UserPreference
  extend ActiveSupport::Concern

  included do
    # Use self.json_attrs to drive json rendering for 
    # API model responses (index, show and update ones).
    # For reference:
    # https://api.rubyonrails.org/classes/ActiveModel/Serializers/JSON.html
    # The object passed accepts only these keys:
    # - only: list [] of model fields to be shown in JSON serialization
    # - except: exclude these fields from the JSON serialization, is a list []
    # - methods: include the result of some method defined in the model
    # - include: include associated models, it's an object {} which also accepts the keys described here
    cattr_accessor :json_attrs
    self.json_attrs = ::ModelDrivenApi.smart_merge (json_attrs || {}), {}

    # Custom action callable by the API must be defined in /app/models/concerns/endpoints/
  end
end