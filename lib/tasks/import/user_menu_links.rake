namespace :import do
  task user_menu_links: :environment do
    Importer.import_json(ENV["USER_MENU_LINKS_URL"]).select do |raw|
      UserMenuLink.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing user menu link: #{raw["name"]}"

      UserMenuLink.create!(raw)
    end
  end
end
