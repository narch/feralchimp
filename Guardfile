guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch("spec/rspec/helper.rb") { "spec" }
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
end
