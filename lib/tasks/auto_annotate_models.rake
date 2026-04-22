if Rails.env.development?
  require "annotate_rb"

  task :auto_annotate_models do
    AnnotateRb::Commands::AnnotateModels.new(AnnotateRb::Options.from({})).call
  end

  Rake::Task["db:migrate"].enhance do
    Rake::Task["auto_annotate_models"].invoke
  end
end
