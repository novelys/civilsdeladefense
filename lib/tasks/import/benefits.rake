namespace :import do
  task benefits: :environment do
    Importer.import_json(ENV["BENEFITS_URL"]).select do |benefit|
      Benefit.find_by(id: benefit["id"]).nil?
    end.each do |raw|
      puts "Importing benefit: #{raw["name"]}"

      Benefit.create!(raw)
    end
  end
end
