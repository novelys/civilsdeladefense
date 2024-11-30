namespace :import do
  task contract_durations: :environment do
    Importer.import_json(ENV["CONTRACT_DURATIONS_URL"]).select do |raw|
      ContractDuration.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing contract duration: #{raw["name"]}"

      ContractDuration.create!(raw)
    end
  end
end
