Rails.application.reloader.to_prepare do
  # Load Ruby class extensions
  Dir.glob(Rails.root.join('lib/core_ext/**/*.rb')).each do |core_ext_file|
    load core_ext_file
  end

  # Load Rails class extensions
  Dir.glob(Rails.root.join('app/lib/core_ext/**/*.rb')).each do |core_ext_file|
    load core_ext_file
  end
end
