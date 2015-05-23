def run(command)
  system(command) or raise "RAKE TASK FAILED: #{command}"
end

namespace "test" do
  desc "Run unit tests for all iOS targets"
  task :ios do |t|
    `killall 'iOS Simulator'`
    run "xcodebuild -project Ra.xcodeproj -scheme Ra-iOSTests clean test >/dev/null && echo 'Tests succeeded'"
  end

  desc "Run unit tests for all OS X targets"
  task :osx do |t|
    run "xcodebuild -project Ra.xcodeproj -scheme RaTests clean test >/dev/null && echo 'Tests succeeded'"
  end
end

task default: ["test:ios", "test:osx"]
