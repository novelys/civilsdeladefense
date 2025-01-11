require "uri"

namespace :import do
  task employers: :environment do
    import_json("employers.json").select do |raw|
      Employer.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing employer: #{raw["name"]}"

      Employer.create!(raw.except("lft", "rgt", "depth"))
    end
    File.delete("employers.json")
  end

  task administrators: :environment do
    import_json("administrators.json").select do |raw|
      Administrator.where(email: raw["email"]).empty?
    end.each do |raw|
      puts "Importing administrator: #{raw["email"]}"

      attributes = raw.except("organization_id").merge(organization)
      attributes = attributes.except("supervisor_administrator_id") unless Administrator.exists?(id: raw["supervisor_administrator_id"])
      attributes = attributes.except("grand_employer_administrator_id") unless Administrator.exists?(id: raw["grand_employer_administrator_id"])
      attributes = attributes.except("inviter_id") unless Administrator.exists?(id: raw["inviter_id"])

      admin = Administrator.new(attributes)
      admin.skip_confirmation!
      admin.save(validate: false)
    end
    File.delete("administrators.json")
  end

  task benefits: :environment do
    import_json("benefits.json").select do |benefit|
      Benefit.find_by(id: benefit["id"]).nil?
    end.each do |raw|
      puts "Importing benefit: #{raw["name"]}"

      Benefit.create!(raw)
    end
    File.delete("benefits.json")
  end

  task contract_durations: :environment do
    import_json("contract_durations.json").select do |raw|
      ContractDuration.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing contract duration: #{raw["name"]}"

      ContractDuration.create!(raw)
    end
    File.delete("contract_durations.json")
  end

  task email_templates: :environment do
    import_json("email_templates.json").select do |raw|
      EmailTemplate.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing email template: #{raw["title"]}"

      EmailTemplate.create!(raw)
    end
    File.delete("email_templates.json")
  end

  task job_application_file_types: :environment do
    import_json("job_application_file_types.json").select do |raw|
      JobApplicationFileType.find_by(id: raw["id"]).nil?
    end.each do |raw|
      if job_application_file_type_id(raw["id"]).nil?
        puts "Importing job application file type: #{raw["name"]}"

        JobApplicationFileType.create!(raw)
      else
        puts "No need to import mapped job application file type: #{raw["name"]}"
      end
    end
    File.delete("job_application_file_types.json")
  end

  task user_menu_links: :environment do
    import_json("user_menu_links.json").select do |raw|
      UserMenuLink.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing user menu link: #{raw["name"]}"

      UserMenuLink.create!(raw)
    end
    File.delete("user_menu_links.json")
  end

  task users: :environment do
    import_json("users.json").each_with_index do |raw, index|
      photo_filename = raw["photo_file_name"]

      user = User.find_by(id: raw["id"])
      puts "User already present: #{raw["id"]}" && next if user.present?

      user = User.find_by(email: raw["email"])
      puts "User already present: #{raw["email"]}" && next if user.present?

      puts "Importing user: #{raw["email"]} (#{index + 1})"
      user = User.new(raw.except("organization_id", "gender").merge(organization))

      user.photo = download("User", "photo", raw["id"], photo_filename) if photo_filename.present?
      user.skip_confirmation!
      user.save(validate: false)

      File.delete(photo_filename) if photo_filename.present? && File.exist?(photo_filename)
    end
    File.delete("users.json")
  end

  task user_profiles: :environment do
    import_json("profiles.json").select do |raw|
      Profile.find_by(id: raw["id"]).nil? && raw["profileable_type"] == "User"
    end.each_with_index do |raw, index|
      puts "Importing user profile: #{raw["id"]} (#{index + 1})"

      resume_file_name = raw["resume_file_name"]

      attributes = raw.except("availability_range_id", "age_range_id").merge(
        study_level_id: study_level_id(raw["study_level_id"]),
        experience_level_id: experience_level_id(raw["experience_level_id"])
      )
      attributes = attributes.merge(profileable_id: user_mapping[raw["profileable_id"]]) unless User.exists?(id: raw["profileable_id"])

      profile = Profile.new(attributes)
      profile.resume = download("Profile", "resume", raw["id"], resume_file_name) if resume_file_name.present?
      profile.save(validate: false)

      File.delete(resume_file_name) if resume_file_name.present? && File.exist?(resume_file_name)
    end
    File.delete("profiles.json")
  end

  task job_offers: :environment do
    import_json("job_offers.json").select do |raw|
      JobOffer.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing job offer: #{raw["title"]}"

      attributes = raw.except(
        :organization_id
      ).merge(
        organization,
        category_id: category_id(raw["category_id"]),
        contract_type_id: contract_type_id(raw["contract_type_id"]),
        experience_level_id: experience_level_id(raw["experience_level_id"]),
        professional_category_id: professional_category_id(raw["professional_category_id"]),
        sector_id: sector_id(raw["sector_id"]),
        study_level_id: study_level_id(raw["study_level_id"]),
        level_id: level_id(raw["level_id"]),
        archiving_reason_id: archiving_reason_id(raw["archiving_reason_id"])
      )
      if JobOffer.exists?(slug: raw["slug"])
        attributes = attributes.merge(slug: "#{raw["slug"]}-#{SecureRandom.hex(4)}")
      end
      unless Administrator.exists?(id: raw["owner_id"])
        attributes = attributes.merge(owner_id: admin_mapping[raw["owner_id"]])
      end

      job_offer = JobOffer.new(attributes)
      job_offer.save(validate: false)
    end
    File.delete("job_offers.json")
    File.delete("administrators.json") if File.exist?("administrators.json")
  end

  task job_applications: :environment do
    import_json("job_applications.json").select do |raw|
      JobApplication.find_by(id: raw["id"]).nil?
    end.each_with_index do |raw, index|
      puts "Importing job application: #{raw["id"]} (#{index + 1})"

      attributes = raw.except(:organization_id).merge(organization)
      attributes = attributes.merge(user_id: user_mapping[raw["user_id"]]) unless User.exists?(id: raw["user_id"])
      attributes = attributes.merge(category_id: category_id(raw["category_id"]))
      attributes = attributes.merge(rejection_reason_id: rejection_reason_id(raw["rejection_reason_id"]))

      job_application = JobApplication.new(attributes)
      job_application.save(validate: false)
    end
    File.delete("job_applications.json")
    File.delete("users.json") if File.exist?("users.json")
  end

  task job_application_profiles: :environment do
    import_json("profiles.json").select do |raw|
      Profile.find_by(id: raw["id"]).nil? && raw["profileable_type"] == "JobApplication"
    end.each_with_index do |raw, index|
      puts "Importing job application profile: #{raw["id"]} (#{index + 1})"

      resume_file_name = raw["resume_file_name"]

      attributes = raw.except("availability_range_id", "age_range_id").merge(
        study_level_id: study_level_id(raw["study_level_id"]),
        experience_level_id: experience_level_id(raw["experience_level_id"])
      )
      profile = Profile.new(attributes)
      profile.resume = download("Profile", "resume", raw["id"], resume_file_name) if resume_file_name.present?
      profile.save(validate: false)

      File.delete(resume_file_name) if resume_file_name.present? && File.exist?(resume_file_name)
    end
    File.delete("profiles.json")
  end

  task job_application_files: :environment do
    import_json("job_application_files.json").select do |raw|
      JobApplicationFile.find_by(id: raw["id"]).nil?
    end.each_with_index do |raw, index|
      puts "Importing job application file: #{raw["id"]} (#{index + 1})"

      content_file_name = raw["content_file_name"]

      attributes = raw.except(:content_file_name).merge(secured_content: false)
      job_application_file_type_id = if JobApplicationFileType.exists?(id: raw["job_application_file_type_id"])
        raw["job_application_file_type_id"]
      else
        job_application_file_type_id(raw["job_application_file_type_id"])
      end
      attributes = attributes.merge(job_application_file_type_id: job_application_file_type_id)

      job_application_file = JobApplicationFile.new(attributes)
      if content_file_name.present?
        job_application_file.content = download("JobApplicationFile", "content", raw["id"], content_file_name)
      end
      job_application_file.save(validate: false)

      File.delete(content_file_name) if content_file_name.present? && File.exist?(content_file_name)
    rescue Socket::ResolutionError => e
      puts "Failed to import job application file type: #{raw["name"]} => #{e}"
    end
    File.delete("job_application_files.json")
  end

  task benefit_job_offers: :environment do
    import_json("benefit_job_offers.json").select do |raw|
      BenefitJobOffer.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing benefit job offer: #{raw["id"]}"

      BenefitJobOffer.create!(raw)
    end
    File.delete("benefit_job_offers.json")
  end

  task bookmarks: :environment do
    import_json("bookmarks.json").select do |raw|
      Bookmark.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing bookmark: #{raw["id"]}"

      attributes = raw
      attributes = attributes.merge(user_id: user_mapping[raw["user_id"]]) unless User.exists?(id: raw["user_id"])
      Bookmark.create!(attributes)
    end
    File.delete("bookmarks.json")
    File.delete("users.json") if File.exist?("users.json")
  end

  task department_profiles: :environment do
    import_json("department_profiles.json").select do |raw|
      DepartmentProfile.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing department profile: #{raw["id"]}"

      DepartmentProfile.create!(raw.merge(department_id: department_id(raw["department_id"])))
    end
    File.delete("department_profiles.json")
  end

  task emails: :environment do
    Email.skip_callback(:save, :after, :compute_job_application_notifications_counter)
    import_json("emails.json").select do |raw|
      Email.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing email: #{raw["id"]}"

      attributes = raw
      attributes = attributes.merge(sender_id: admin_mapping[raw["sender_id"]]) unless Administrator.exists?(id: raw["sender_id"])
      email = Email.new(attributes)
      email.save(validate: false)
    end

    Email.set_callback(:save, :after, :compute_job_application_notifications_counter)
    File.delete("emails.json")
    File.delete("administrators.json") if File.exist?("administrators.json")
  end

  task email_attachments: :environment do
    import_json("email_attachments.json").select do |raw|
      EmailAttachment.find_by(id: raw["id"]).nil?
    end.each_with_index do |raw, index|
      puts "Importing email attachment: #{raw["id"]} (#{index + 1})"

      content_file_name = raw["content"]

      email_attachment = EmailAttachment.new(raw.merge(secured_content: false))
      email_attachment.content = download("EmailAttachment", "content", raw["id"], content_file_name) if content_file_name.present?
      email_attachment.save(validate: false)

      File.delete(content_file_name) if content_file_name.present? && File.exist?(content_file_name)
    rescue Socket::ResolutionError => e
      puts "Failed to import email attachment: #{raw["name"]} => #{e}"
    end
    File.delete("email_attachments.json")
  end

  task job_offer_actors: :environment do
    import_json("job_offer_actors.json").select do |raw|
      JobOfferActor.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing job offer actor: #{raw["id"]}"

      attributes = raw
      attributes = attributes.merge(administrator_id: admin_mapping[raw["administrator_id"]]) unless Administrator.exists?(id: raw["administrator_id"])
      JobOfferActor.create!(attributes)
    end
    File.delete("job_offer_actors.json")
    File.delete("administrators.json") if File.exist?("administrators.json")
  end

  task messages: :environment do
    import_json("messages.json").select do |raw|
      Message.find_by(id: raw["id"]).nil?
    end.each do |raw|
      puts "Importing message: #{raw["id"]}"

      attributes = raw
      attributes = attributes.merge(administrator_id: admin_mapping[raw["administrator_id"]]) unless Administrator.exists?(id: raw["administrator_id"])
      Message.create!(attributes)
    end
    File.delete("messages.json")
    File.delete("administrators.json") if File.exist?("administrators.json")
  end

  private

  def import_json(file_name)
    Aws::S3::Resource.new.bucket("erecrutement").object(file_name).download_file(file_name)
    JSON.parse(File.read(file_name)).sort_by { |item| item["created_at"] }
  end

  def download(resource_type, attribute_name, id, file_name)
    url = "https://ict-tct.contractuels.civils.defense.gouv.fr/downloads/#{id}?resource_type=#{resource_type}&attribute_name=#{attribute_name}"
    content = URI.open(url, "X-Download-Secret-Key" => ENV["DOWNLOAD_SECRET_KEY"]).read.force_encoding("UTF-8") # rubocop:disable Security/Open
    File.write(file_name, content)
    File.open(file_name)
  rescue OpenURI::HTTPError => e
    puts "Failed to download content for job application file: #{id} => #{e}"
    nil
  end

  def organization
    @organization ||= Organization.find("9573652a-7b89-44e8-864c-75c0ec3a8ede")
    {organization: @organization}
  end

  def admin_mapping
    @admin_mapping ||= import_json("administrators.json").each_with_object({}) do |raw, hash|
      hash[raw["id"]] = Administrator.find_by(email: raw["email"]).id
    end
  end

  def user_mapping
    @user_mapping ||= import_json("users.json").each_with_object({}) do |raw, hash|
      hash[raw["id"]] = User.find_by(email: raw["email"]).id
    end
  end

  def department_id(department_id)
    # Key: id DGA, Value: id CVD
    {
      "914cad4e-0470-4ef7-bb1d-91e3215824ff" => "2cdda303-24ff-4af6-a14f-eccc10c66bf5" # Aucun
    }.dig(department_id)
  end

  def sector_id(sector_id)
    # Key: id DGA, Value: id CVD
    {
      "98d5368e-33ce-478c-a6aa-775e21826572" => "af22b79f-e95b-49e4-8a12-7de51456c3a7",  # Tranverse
      "9e064856-7342-4000-a428-c31a9766939a" => "e8b6aec2-b2d9-46d4-909d-64f6e52529f3"  # Technique
    }.dig(sector_id)
  end

  def archiving_reason_id(archiving_reason_id)
    # Key: id DGA, Value: id CVD
    {
      "4ca13554-9674-4a57-8f07-1b8203efacb1" => "e091c6a6-7039-46b2-a128-ea2df35e949a", # Offre obsolète
      "65661b9b-4fec-49ce-87df-01c0b4172ae3" => "7629b44f-a674-47a0-ac77-ee73d6b38156" # Candidat trouvé
    }.dig(archiving_reason_id)
  end

  def contract_type_id(contract_type_id)
    # Key: id DGA, Value: id CVD
    {
      "c3ff27eb-6833-4cf2-9dc3-7151201bc68f" => "c42553ee-0b18-4117-b3de-741dca6fd340" # CDI
    }.dig(contract_type_id)
  end

  def professional_category_id(professional_category_id)
    # Key: id DGA, Value: id CVD
    {
      "1b5a2466-498a-4e13-ac93-0ef43314859a" => "973219d1-c36f-464c-a6a7-acd31a29593f", # Technicien
      "da6827a2-2dfd-4c41-b534-2c37c3d412ce" => "4353f0b7-ca66-4569-8d2f-b0ec6d760d60" # Ingénieur / Cadre
    }.dig(professional_category_id)
  end

  def level_id(level_id)
    # Key: id DGA, Value: id CVD
    {
      "1afe2068-7383-4305-aa7d-b7c803467776" => "01e6e871-eb4e-4e75-8578-2caefe8b77a8", # 2
      "5fbb7d73-b3d3-4873-89f8-ccd6489072ac" => "0ca6a1c3-4b5a-4ce6-bd22-72dda7918fae", # 1
      "8bc4ad01-6fc9-4282-aaab-1790c99945b2" => "01e6e871-eb4e-4e75-8578-2caefe8b77a8", # B
      "b4cd7b34-23c1-468f-9e6a-d3ac57883bf8" => "53968354-4859-4577-86e7-7a12d5b899a8", # C
      "ba07b510-b489-46d2-a59b-31b72a9296ce" => "0ca6a1c3-4b5a-4ce6-bd22-72dda7918fae", # A
      "c980ce67-e678-4bc0-8f14-78f21827273d" => "53968354-4859-4577-86e7-7a12d5b899a8" # 3
    }.dig(level_id)
  end

  def category_id(category_id)
    # Key: id DGA, Value: id CVD
    {
      "6e949881-e619-49a7-8a81-0b713035b303" => "7ba63570-45e0-499e-9c2e-cb42fadf6e7d", # ACHATS
      "a3d0accf-464b-4e64-8a22-a14613efcf8f" => "7ba63570-45e0-499e-9c2e-cb42fadf6e7d", # Achats
      "15fae63b-177f-4a98-afdd-5423db6c4ae0" => "4d6f63bd-d198-417d-9f5b-0e97f8394973", # AERONAUTIQUE
      "8579cdf2-44d1-44f0-acfa-95e927933f63" => "4d6f63bd-d198-417d-9f5b-0e97f8394973", # Capteurs, Guidage, Navigation
      "963ee14d-f928-4239-8656-99bbdf2a90ae" => "4d6f63bd-d198-417d-9f5b-0e97f8394973", # Mécanique Aéronautique
      "7d6b91be-93e8-4021-9d88-472538b12ebd" => "8347fab6-d0de-4335-a6b9-6ccf9c3aac82", # JURIDIQUE
      "ba046c2b-8340-49fe-ae72-b6ec6c4b9107" => "8347fab6-d0de-4335-a6b9-6ccf9c3aac82", # Spécialiste en Propriété Intellectuelle
      "8035d26d-91cc-444d-b548-39053010f7a9" => "4f836c18-9a1e-416f-8f9b-b361196eccf2", # Fonctionnement général
      "282c15e2-078b-40f5-b39c-4bddfc118321" => "4f836c18-9a1e-416f-8f9b-b361196eccf2", # FONCTIONNEMENT GENERAL
      "56fc1064-79c3-4a03-aacf-507a9d37ccc9" => "bb9e18f0-c751-40ea-ac48-d569aa88cfcb", # Auditeur de Coûts
      "ff8d288b-00c5-4c5e-9cde-82af0425060d" => "bb9e18f0-c751-40ea-ac48-d569aa88cfcb", # Contrôle de Gestion
      "52213ba3-82bb-4133-a8c6-61e0cd451713" => "bb9e18f0-c751-40ea-ac48-d569aa88cfcb", # Finances
      "2e5ce701-fd17-4a48-bb59-348466e8d756" => "bb9e18f0-c751-40ea-ac48-d569aa88cfcb", # FINANCES GESTION
      "4fe0e956-2a6e-41cb-8ec8-21032aacb146" => "0a8e421f-afc5-4e48-b5fe-cae50116fd8f", # Electricité
      "1348052f-0691-4de1-91d4-1bdcd04743fb" => "0a8e421f-afc5-4e48-b5fe-cae50116fd8f", # ELECTRICITE
      "4334b4bd-9ce6-4b31-95e9-a64c59cb0050" => "0a8e421f-afc5-4e48-b5fe-cae50116fd8f", # MAINTENANCE DE MOYENS D'ESSAIS
      "c6ce6b25-50b1-45c9-91ff-12df9d614efd" => "0a8e421f-afc5-4e48-b5fe-cae50116fd8f", # Maintenance de Moyens d'Essais
      "4323acff-a681-4633-9f6e-88211df1b2e8" => "56d9b9a6-b2f6-4f42-83f6-7e34839a6c50", # Soutien Logistique Intégré
      "70a18fab-ba84-49c9-be39-730be227e41d" => "a5625f24-0772-42d5-b30f-f21bb977b17c", # Optronique
      "0bc138bb-2a1b-47ae-a509-2f355b5f1264" => "a5625f24-0772-42d5-b30f-f21bb977b17c", # Plate-formes Terrestres
      "d3ed91d0-1cb6-4129-af93-31cfe6f80e63" => "a5625f24-0772-42d5-b30f-f21bb977b17c", # Usinage / Conception Mécanique
      "eb6f9f62-2299-4e72-9d2c-8b2460e46756" => "a5625f24-0772-42d5-b30f-f21bb977b17c", # USINAGE / CONCEPTION MECANIQUE
      "e6a9044b-cbb9-440d-8638-520d153e25ec" => "742f3096-c232-4d08-8785-e68717891c2b", # Plate-formes Aéronautique
      "39cb1f80-3a7e-4581-b498-eb37d7043f03" => "cadb6b95-ac03-48b7-bc56-2502493669a3", # Météorologie
      "2e955458-a286-4a90-9b58-c57c4b9bbb0a" => "cadb6b95-ac03-48b7-bc56-2502493669a3", # Métrologie
      "2848e24d-66ef-4974-90ba-e08cd162b2d3" => "cadb6b95-ac03-48b7-bc56-2502493669a3", # Plate-formes Navales
      "c3e1f33e-ffd4-4807-8c2d-530623d0cc33" => "cadb6b95-ac03-48b7-bc56-2502493669a3", # Sciences Géographiques, Hydrographiques et Océanographiques
      "b2425c38-26dd-42ee-942f-b03dff653a0b" => "cadb6b95-ac03-48b7-bc56-2502493669a3", # Systèmes de Combat Navals
      "637cc763-a5f4-46d7-a0b2-ac09c4c7d29a" => "bce7b9b3-799f-4c03-92e5-5a0fb4280f2b", # Nucléaire
      "1b419acc-b559-417f-8d23-1133dd6bd655" => "e5dcb724-2d2c-461b-b1af-fd8ae41c209c", # Formation
      "705770ec-6c36-441f-9f9e-7b577d002ab5" => "e5dcb724-2d2c-461b-b1af-fd8ae41c209c", # RESSOURCES HUMAINES
      "c26f8776-f69a-404f-ba46-ee78d6ab6728" => "e5dcb724-2d2c-461b-b1af-fd8ae41c209c", # Ressources humaines
      "0eed7f6b-440c-4a07-a4ac-f49a73ce5131" => "7ad9c636-3158-4517-9cb5-df3ffbe44cfc", # Hygiène / Sécurité / Environnement
      "3b367ddd-e624-490d-8097-a2a429a090de" => "7ad9c636-3158-4517-9cb5-df3ffbe44cfc", # HYGIENE / SECURITE / ENVIRONNEMENT
      "64eac463-9f42-4c6b-96a4-05843d12b230" => "7ad9c636-3158-4517-9cb5-df3ffbe44cfc", # Matériaux / Enjeux Environnementaux
      "a974bbbe-7396-4327-97e3-e1da671ebc3f" => "6b5a5de6-9462-4ef4-a5ed-90e0dec5d4ef", # Garde Assermenté
      "e9457923-c912-4a1b-b1c5-ee8c5fcffa37" => "fe731461-c1dc-4e23-9b09-6d8b4f33c317", # Sûreté de Fonctionnement
      "92e21aca-4d23-4882-90e4-1f93fa2aab68" => "fe731461-c1dc-4e23-9b09-6d8b4f33c317", # Sécurité Incendie
      "34984c52-3752-4c92-ac70-938547e24221" => "668e58fd-5c1f-4368-ad03-7870cad5fc50", # Armement / Pyrotechnie
      "66ecd1f3-dfaa-41a9-8423-bdae8a63aa86" => "668e58fd-5c1f-4368-ad03-7870cad5fc51", # ARMEMENT / PYROTECHNIE
      "1524079c-382c-4c72-9b9c-d968cde232fb" => "a68c04ca-1159-4797-a7d6-f5c52af7caed", # Architecture et Evaluation des Systèmes de Systèmes
      "6349b691-d4a4-4d35-8da1-30aa681859d4" => "a68c04ca-1159-4797-a7d6-f5c52af7caed", # INGENIERIE
      "43c51efd-0d90-4b1e-b8b8-6b21074f6fea" => "a68c04ca-1159-4797-a7d6-f5c52af7caed", # Innovation
      "d7902a07-12d3-4363-b190-2828684b15c4" => "a68c04ca-1159-4797-a7d6-f5c52af7caed", # INNOVATION
      "7ad9308d-2459-4bf6-93e6-c0c183108d0d" => "a68c04ca-1159-4797-a7d6-f5c52af7caed", # Mesure Physique
      "fdaec8c9-3d0f-4a78-bed5-7103c55b1696" => "a68c04ca-1159-4797-a7d6-f5c52af7caed", # Missiles
      "02f5a33f-0179-4ca7-af8d-c7efca187697" => "a68c04ca-1159-4797-a7d6-f5c52af7caed", # Qualité Produit
      "e63bb010-7d33-40c3-94bc-ee7e68478ea9" => "a68c04ca-1159-4797-a7d6-f5c52af7caed", # Qualité Programme
      "16619610-7e1b-4654-912b-1770adcce9a3" => "a68c04ca-1159-4797-a7d6-f5c52af7caed", # QUALITE PRODUIT
      "6f876ef0-77f4-4cd1-9216-1118fc6aba00" => "a68c04ca-1159-4797-a7d6-f5c52af7caed", # Responsable Méthodes de Laboratoire et Investigations
      "b87b72cb-9bbf-4ca3-9e9b-fa6cae5db0c6" => "a68c04ca-1159-4797-a7d6-f5c52af7caed", # RESPONSABLE MÉTHODES DE LABORATOIRE ET INVESTIGATIONS
      "eff711b7-6840-42c5-af9c-29ca765e63c6" => "b0fa530b-0ced-43b5-8be8-0bf36360f301", # Embarqué
      "e0c7d2b2-f2d6-4f07-8c3b-d32e1814d2d0" => "b0fa530b-0ced-43b5-8be8-0bf36360f301", # Informatique
      "df559457-683f-4ff8-a251-23c158bde95b" => "b0fa530b-0ced-43b5-8be8-0bf36360f301", # NUMERIQUE
      "c82f5fc7-a9f8-407c-bc81-6a5764202937" => "b0fa530b-0ced-43b5-8be8-0bf36360f301", # PMO (Project Manager Officier)
      "a01ffab3-05ba-47a0-9c27-11ca637314ba" => "b0fa530b-0ced-43b5-8be8-0bf36360f301", # Expert Test, Essai et Validation
      "551d3745-2481-4edc-8f66-09df6e13c73e" => "b0fa530b-0ced-43b5-8be8-0bf36360f301", # Ingénierie des Simulations, des Systèmes Informatiques Embarqués et des Systèmes Informatiques d'Essais
      "394ea6c3-9208-4fb4-8fc2-01eeb6cbb9e8" => "8b7c515f-3e88-43f8-9601-85e6b24d1ef8", # Cybersécurité
      "ca712159-5f69-4612-87e9-c6ea42c8219e" => "8b7c515f-3e88-43f8-9601-85e6b24d1ef8", # CYBERSECURITE
      "ffa30652-5db3-45c1-aa9f-e84c12b74b49" => "8b7c515f-3e88-43f8-9601-85e6b24d1ef8", # Détection et Guerre Electronique
      "c194a7fc-e76c-4cc3-b413-291c1af6e608" => "8b7c515f-3e88-43f8-9601-85e6b24d1ef8", # Sécurité de Défense et de l'Information
      "8bb4e130-ceab-4487-8b6c-4b06b29650ed" => "a22171c1-b7ec-430e-a769-b4d30719a886", # GESTION DE PROJET
      "6f629a59-be89-442a-af3e-5e5b9199b287" => "a22171c1-b7ec-430e-a769-b4d30719a886", # Mécatronique / Electronique
      "ac7681a1-823c-4c53-9b08-ca8c1f4f9c40" => "a22171c1-b7ec-430e-a769-b4d30719a886", # Chef de Projet
      "3b976b73-e4d4-4ffa-a14e-a5ccacb7206d" => "a22171c1-b7ec-430e-a769-b4d30719a886", # Développement Logiciel
      "8bdda6bf-e3af-41e5-a570-9473382d478c" => "a22171c1-b7ec-430e-a769-b4d30719a886", # Data Science
      "39c68ec2-d978-4bb3-af59-578725d8cfc8" => "a22171c1-b7ec-430e-a769-b4d30719a886", # Etudes et Développements
      "cd6de1af-4f4d-43d4-a781-8183047bb1d9" => "3b209b84-a4aa-463c-a78f-61d0234af404", # SECURITE DES SYSTEMES
      "f4b5a7c9-3692-43de-882c-1e5de4b6f4c0" => "3b209b84-a4aa-463c-a78f-61d0234af404", # Système Réseaux des Données
      "eac4bdce-170f-4336-8c1c-7df92f2f7428" => "3b209b84-a4aa-463c-a78f-61d0234af404", # Télécommunications
      "61206bd5-3c2c-4eff-9477-7bca53aa4fce" => "b0fa530b-0ced-43b5-8be8-0bf36360f301", # Systèmes d'information
      "e0477333-fdd7-4cf8-b20d-08a826a1fa0b" => "b0fa530b-0ced-43b5-8be8-0bf36360f301" # TEST, ESSAI ET VALIDATION
    }.dig(category_id)
  end

  def foreign_language_id(foreign_language_id)
    # Key: id DGA, Value: id CVD
    {
      "df356daa-9965-4366-8f52-b656f0fc3dc0" => "84d55436-d4b4-4aec-ae34-0b5d43789e96", # Anglais
      "d7489a3b-5e97-4d58-bf9c-99102bbb279c" => "2332d509-fb30-4f1b-9194-a5f1af3917e7" # Allemand
    }.dig(foreign_language_id)
  end

  def study_level_id(study_level_id)
    # Key: id DGA, Value: id CVD
    {
      "449ff1c1-ffc4-485f-894f-81e1b50ffb8c" => "8ab3d972-a205-4792-a0c8-0f1d3afcd62a", # Bac + 5 / Ecole Ingénieur / Master
      "6b2b1bf0-b0b8-49e4-ad6f-04b6321f6bc7" => "1be7986c-3565-4890-aa97-d6d631ab5fbd", # Doctorat
      "c2bcb292-1a02-4de2-a072-1ccdf8fcb33d" => "8ab3d972-a205-4792-a0c8-0f1d3afcd62a", # Bac + 5 / Ecole Ingénieur / Master / Doctorat
      "e1f497ad-5c7d-458b-b557-b765f4ba7d39" => "870d19a4-e97b-42b3-95ae-39fed815a702", # Bac + 2 / Bac + 3
      "fca43c8b-27ac-46c6-b873-5f5bb8ba3194" => "5ae0768c-e28b-4271-9ee2-9132c3c0b4e6" # Bac + 2
    }.dig(study_level_id)
  end

  def experience_level_id(experience_level_id)
    # Key: id DGA, Value: id CVD
    {
      "036967cd-f4ed-4513-9967-aa5170363b45" => "0939a5e4-268c-488c-9071-659d6843d700", # Junior
      "067d1c9e-c9a0-41ac-ae37-ce3352c62465" => "0939a5e4-268c-488c-9071-659d6843d700", # Débutant
      "2e42e48d-c974-4c25-a1e3-9d76d5398961" => "5ee6e2c0-56fb-42c8-82b1-903676bb9a09", # Expérimenté
      "4b711c3b-6737-4139-9756-cceca381b67c" => "d7994814-415d-443c-ad6f-a627ef9f10a4", # Indifférent
      "f66fdcc2-4116-4cda-a6ea-b90f0f7dafe8" => "030301a2-0b2b-4b0c-8ea5-5bfc9325a269" # Confirmé
    }.dig(experience_level_id)
  end

  def foreign_language_id(foreign_language_id)
    # Key: id DGA, Value: id CVD
    {
      "188dbb29-cbfd-4422-b7de-6f7abddd2b17" => "4f2051e4-8d62-4ca1-80d5-a35694c1cb29", # Intermédiaire / B1 / B2
      "59b02d86-0a74-45eb-b891-76facd073794" => "5274d213-4364-4267-9e63-e5f49ab1a69b", # Avancé / C1 / C2
      "7427a756-90bb-48c5-a25c-1fac11861dbb" => "509eb999-0b3c-4e7b-bafa-5626e134c961" # Débutant / A1 / A2
    }.dig(foreign_language_id)
  end

  def rejection_reason_id(rejection_reason_id)
    # Key: id DGA, Value: id CVD
    {
      "acb6861b-fcb8-4509-8bfc-81f11dab1e19" => "a3cc5a0f-ccd5-4b4b-bb81-9193cdf686f8", # CANDIDAT - AUTRE POSTE TROUVE
      "45bde73d-08d8-4d32-98b3-26f4de2eb6da" => "3f9a052a-5b00-4d7b-a450-9dd8d6f524be", # CANDIDAT - DELAI DE RECRUTEMENT
      "f9099b9e-0003-4b48-89b6-81ea1115260a" => "f97738e5-87d4-4ef6-8272-6a770149e667", # CANDIDAT - DESISTEMENT AUTRE
      "8447a947-ad7c-45c4-be17-3d7ae62f9e99" => "223febef-2111-440e-ab39-b34cff66b6c4", # CANDIDAT - INADEQUATION POSTE
      "dad3ee5a-3fe8-4a2a-b030-115811000c95" => "d4626094-a358-4bc0-97a5-89b0a41e800b", # CANDIDAT - LOCALISATION
      "27cd8c69-56b6-4e43-b676-12e6f3ea5b50" => "28e23f4d-299f-4ed9-87eb-a72935d93197", # CANDIDAT - NATURE DU CONTRAT
      "1482d532-2799-4a37-9f64-9e49a1b22456" => "79c15c46-04bf-41eb-9acd-e9713bb4117d", # CANDIDAT - QUALITE DE L'ENTRETIEN
      "6f880073-6e04-45c1-a234-d7a0d2052bd9" => "35c0d20a-7959-4615-80ec-c5ab17966926", # CANDIDAT - REMUNERATION
      "294ee4ce-27f0-4094-bf05-d01b3788ae08" => "57b75588-0384-4547-a994-611da5161ab4", # EMPLOYEUR - AUTRE CANDIDAT TROUVE
      "edae179a-6441-4cf9-880e-553b2b749d79" => "f319db31-1fad-489c-8bf3-77c381f191c8", # EMPLOYEUR - DIPLOME NON RECEVABLE
      "91438bac-dfff-4517-b441-e4cc7e7c4ac0" => "40c615a0-59d2-4679-b977-f3f3f383701d", # EMPLOYEUR - DISPONIBILITE
      "b79c37f9-798f-4e2f-8f4e-40e8af72d79a" => "3bd0cabc-af78-4f53-a064-e1346312422d", # EMPLOYEUR - NATURE DU CONTRAT
      "bcce9eba-0fff-4bbc-9899-dbe7a9006281" => "64303742-f40c-4d62-aff4-db5a4f136e98", # EMPLOYEUR - PROFIL INADAPTE COMPETENCES SOUS-QUALIFIEES
      "bf182baf-6923-45ca-8461-6812a9b713fe" => "eb28be8c-6a98-495d-b4ce-5d70dd9b4dc0", # EMPLOYEUR - PROFIL INADAPTE COMPETENCES SURQUALIFIEES
      "522d4940-f817-46c4-97b0-59a265f0b200" => "f319db31-1fad-489c-8bf3-77c381f191c8", # EMPLOYEUR - PROFIL INADAPTE FORMATION
      "38bbaa95-0d5f-4acb-b12f-5ac3bea722ab" => "8de2c347-4425-4189-bd21-5a6d843a21dd", # EMPLOYEUR - PROFIL INADAPTE SAVOIR ETRE
      "33e337cd-f820-4de6-b067-717b8e8f3b36" => "a43abecb-2ac0-4509-b6c2-aad0f3c41cc7", # EMPLOYEUR - REMUNERATION
      "edee7679-4258-40ed-b8f9-c47279e335e2" => "402a1f85-9b1a-4d45-816f-e4ffe9d63db6" # EMPLOYEUR - SECURITE
    }.dig(rejection_reason_id)
  end

  def job_application_file_type_id(job_application_file_type_id)
    # Key: id DGA, Value: id CVD
    {
      "059479d2-3304-499b-95c9-0f291347798e" => "472c8e34-bd00-4cc3-bc1f-1454780ce81a", # Contrat signé
      "2af8371a-455a-4cec-83cb-d23811d13db3" => "e8a60ab5-e111-4f01-bb67-03809170beba", # JAPD / JDC / Certificat service militaire
      "2cfaff1a-b593-4106-a8b7-cb0558bd6b08" => "0ea29d20-c57f-4bd0-bf67-36e80725df9a", # Diplômes / attestation de réussite / certificat de
      "388fc9f4-31ff-4702-a622-bb732324b29d" => "c316a36c-8579-479f-b01b-f8bfd774b94a", # Fiche de poste
      "55ab33c9-8af1-4544-ae83-31826e720169" => "0741558f-c6b3-43c7-9152-8dd50b56dbc9", # Rapport sur la candidature retenue
      "5fe62fca-bc47-4416-84a4-88a3c75fbbaf" => "d0c6143c-0009-4f1c-9518-00ddb4321100", # Relevé d'identité bancaire
      "6e463ba6-a524-4d10-98d1-50b7ab8b7e0c" => "018ab55a-ae14-4204-9e80-4d8eed988ead", # Carte d'identité / Passeport
      "81f12278-cf1c-4432-93b4-418d63f7ed2b" => "e8e81142-216c-41c3-ae64-aaa9a92d15f9", # Proposition salariale signée par le candidat
      "a5d49098-6aca-45a0-b587-354ff31c516c" => "a09f2c4a-9ab3-4b27-a9ce-e33ea361dd1c", # Livret de famille / extrait d'acte de
      "bda53c0d-b16a-46dc-87f6-f5c830b31009" => "97ea21d4-74cf-4c22-9108-65a5f47022b6", # Carte Vitale
      "cb8bd78b-5570-4905-83ac-4527f6be1472" => "2db94687-e306-4fab-a763-bb97a3fdffda", # Lettre de Motivation
      "d5747e46-1ed6-404b-87f1-fce1379b3a3f" => "1d5bb4eb-e90c-470e-b015-3bd10e3ebf0a", # CV
      "f08d8404-db62-47dd-ba39-fc2f28dfacf2" => "4088a171-ffe3-40d2-a013-4c1781d64268", # Contrat
      "f6750d74-20f7-46cf-b509-165a7a456cd4" => "3b8a726a-7d32-4753-8278-6e11fccc77ca" # Justificatif de domicile de moins de 6 mois
    }.dig(job_application_file_type_id)
  end
end
