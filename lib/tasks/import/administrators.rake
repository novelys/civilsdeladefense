namespace :import do
  task administrators: :environment do
    Importer.import_json(ENV["ADMINISTRATORS_URL"]).select do |raw|
      Administrator.where(email: raw["email"]).empty?
    end.each do |raw|
      puts "Importing administrator: #{raw["email"]}"

      attributes = raw.except("organization_id").merge(organization: Organization.first)
      attributes = attributes.except("supervisor_administrator_id") unless Administrator.exists?(id: raw["supervisor_administrator_id"])
      attributes = attributes.except("grand_employer_administrator_id") unless Administrator.exists?(id: raw["grand_employer_administrator_id"])
      attributes = attributes.except("inviter_id") unless Administrator.exists?(id: raw["inviter_id"])

      admin = Administrator.new(attributes)
      admin.skip_confirmation!
      admin.save(validate: false)
    end
  end
end
