# JUnit XML report for CI (Odoo #6088): kept with every release for the certification body.
# Off unless JUNIT_REPORT_DIR is set, so a local run keeps the normal Rails output.
if ENV["JUNIT_REPORT_DIR"].present?
  require "minitest/reporters"
  Minitest::Reporters.use!([
    Minitest::Reporters::DefaultReporter.new,
    Minitest::Reporters::JUnitReporter.new(ENV["JUNIT_REPORT_DIR"], true, single_file: true)
  ])
end
