Pod::Spec.new do |spec|
  spec.name                      = 'Requests'
  spec.version                   = '0.1.0'
  spec.license                   = { :type => 'MIT' }
  spec.homepage                  = 'https://github.com/alexjohnj/requests'
  spec.authors                   = { 'Alex Jackson' => 'alex@alexj.org' }
  spec.summary                   = 'Sugar for your HTTP requests.'
  spec.source                    = {
    :git => 'https://github.com/alexjohnj/Requests.git',
    :tag => "v#{spec.version}"
  }

  spec.source_files              = 'Sources/Requests/**/*.swift'
  spec.swift_version             = '4.0'

  spec.ios.deployment_target     = '8.0'
  spec.osx.deployment_target     = '10.10'
  spec.watchos.deployment_target = '2.0'
  spec.tvos.deployment_target    = '9.0'

  spec.test_spec do |tspec|
    tspec.source_files = 'Tests/RequestsTests/**/*.swift'

    # Re-declare targets to avoid running tests on watchOS simulator.
    tspec.ios.deployment_target     = '8.0'
    tspec.osx.deployment_target     = '10.10'
    tspec.tvos.deployment_target    = '9.0'
  end
end
