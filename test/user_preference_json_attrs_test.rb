require "test_helper"

# model_driven_api is not a dependency of this gem (it sits above thecore_backend_commons, like
# this gem): Api::UserPreference used to call ::ModelDrivenApi.smart_merge, which crashed with
# NameError in any app without model_driven_api. It now uses ThecoreBackendCommons.smart_merge.
# The dummy app's ModelDrivenApi stub, which hid this, is gone.
class UserPreferenceJsonAttrsTest < ActiveSupport::TestCase
  test "UserPreference loads and exposes json_attrs without model_driven_api" do
    refute defined?(::ModelDrivenApi), "precondition: model_driven_api is not in this gem's bundle"
    assert_kind_of Hash, UserPreference.json_attrs
  end
end
