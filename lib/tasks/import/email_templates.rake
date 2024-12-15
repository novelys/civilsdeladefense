namespace :import do
  task email_templates: :environment do
    Importer.import_json(ENV["EMAIL_TEMPLATES_URL"]).select do |raw|
      EmailTemplate.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing email template: #{raw["title"]}"

      EmailTemplate.create!(raw)
    end
  end
end
