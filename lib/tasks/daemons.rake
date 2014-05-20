require 'rake'

daemons_dir = Daemons::Rails.configuration.daemons_directory

namespace :daemons do
  %i[start stop status].each do |action|
    desc "#{action.capitalize} all daemons."
    task action do
      puts `#{daemons_dir}/daemons #{action}`
    end
  end
end

desc "Show status of daemons"
task :daemons do
  Rake::Task["daemons:status"].invoke
end

namespace :daemon do
  Dir[daemons_dir.join('*_ctl')].each do |controller|
    app_name = controller.sub(/.*\/(\w+)_ctl/, '\1')
    
    namespace :"#{app_name}" do
      %i[start stop restart reload run zap status].each do |action|
        desc "#{action.capitalize} #{app_name} daemon."
        task action do |t, args|
          app_args = args.extras.prepend("--") if args.extras.any?
          exec *[controller, action.to_s] + Array(app_args)
        end
      end
    end
    
    desc "Show status of #{app_name} daemon"
    task :"#{app_name}" do |t, args|
      Rake::Task["daemon:#{app_name}:status"].invoke(*args.extras)
    end
  end
end