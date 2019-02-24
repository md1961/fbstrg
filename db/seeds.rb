#FILENAMES = %w[plays teams]
FILENAMES = %w[teams_1962]

paths = FILENAMES.map { |filename| File.join('db', 'seeds', "#{filename}.rb") }
paths.each do |path|
  unless File.exist?(Rails.root.join(path))
    STDERR.puts "Cannot find '#{path}'."
    exit
  end
end

paths.each do |path|
  STDERR.puts "Applying seed '#{path}'..."
  require(Rails.root.join(path))
end
