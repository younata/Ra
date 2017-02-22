def run(command)
  system(command) or raise "RAKE TASK FAILED: #{command}"
end

namespace "test" do
  desc "Run unit tests for all iOS targets"
  task :ios do |t|
    run "set -o pipefail && xcodebuild -project Ra.xcodeproj -scheme Ra-iOSTests -destination 'platform=iOS Simulator,name=iPhone 6' clean test 2>/dev/null | xcpretty -c && echo 'Tests succeeded'"
  end

  desc "Run unit tests for all OS X targets"
  task :osx do |t|
    run "set -o pipefail && xcodebuild -project Ra.xcodeproj -scheme RaTests clean test 2>/dev/null | xcpretty -c && echo 'Tests succeeded'"
  end

  desc "Run unit tests for all tvOS targets"
  task :tvos do |t|
    run "set -o pipefail && xcodebuild -project Ra.xcodeproj -scheme Ra-tvOSTests -destination 'platform=tvOS Simulator,name=Apple TV 1080p' test 2>/dev/null | xcpretty -c && echo 'Tests succeeded'"
  end

  desc "Run unit tests for swiftpm"
  task :swiftpm do |t|
    run "mv Package.swift .Package.main.swift && cp .Package.test.swift Package.swift"
    run "swift build --clean && swift build && swift test; RETVAL=$?; mv .Package.main.swift Package.swift; exit $RETVAL"
  end
end

task default: ["test:ios", "test:osx", "test:tvos"]
