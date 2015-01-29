def run(command)
  system(command) or raise "RAKE TASK FAILED: #{command}"
end

namespace "test" do
  desc "Run unit tests for all iOS targets"
  task :ios do |t|
    `killall 'iOS Simulator'`
    run "xcodebuild -project Ra.xcodeproj -scheme Ra-iOS clean test"
  end

  desc "Run unit tests for all OS X targets"
  task :osx do |t|
    run "xcodebuild -project Ra.xcodeproj -scheme Ra clean test"
  end
end

task default: ["test:ios", "test:osx"]
