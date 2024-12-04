namespace :import do
  task employers: :environment do
    Importer.import_json(ENV["EMPLOYERS_URL"]).select do |raw|
      Employer.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing employer: #{raw["name"]}"

      Employer.create!(raw.except("lft", "rgt", "depth"))
    end
  end
end
