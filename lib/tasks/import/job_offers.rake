namespace :import do
  task job_offers: :environment do
  end

  private

  def archiving_reason_id(archiving_reason_id)
    # Key: id DGA, Value: id CVD
    {
      "4ca13554-9674-4a57-8f07-1b8203efacb1" => "e091c6a6-7039-46b2-a128-ea2df35e949a", # Offre obsolète
      "65661b9b-4fec-49ce-87df-01c0b4172ae3" => "7629b44f-a674-47a0-ac77-ee73d6b38156" # Candidat trouvé
    }.fetch(archiving_reason_id)
  end
end
