namespace :import do
  task sectors: :environment do
    Importer.import_json(ENV["SECTORS_URL"]).select do |raw|
      Sector.find_by(id: raw["id"]).nil? && Sector.find_by(name: raw["name"]).nil?
    end.each do |raw|
      puts "Importing sector: #{raw["name"]}"

      Sector.create!(raw)
    end
  end
end
