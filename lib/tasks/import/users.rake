namespace :import do
  task users: :environment do
  end

  private

  def foreign_language_id(foreign_language_id)
    # Key: id DGA, Value: id CVD
    {
      "df356daa-9965-4366-8f52-b656f0fc3dc0" => "84d55436-d4b4-4aec-ae34-0b5d43789e96", # Anglais
      "d7489a3b-5e97-4d58-bf9c-99102bbb279c" => "2332d509-fb30-4f1b-9194-a5f1af3917e7" # Allemand
    }.fetch(foreign_language_id)
  end

  def study_level_id(study_level_id)
    # Key: id DGA, Value: id CVD
    {
      "449ff1c1-ffc4-485f-894f-81e1b50ffb8c" => "8ab3d972-a205-4792-a0c8-0f1d3afcd62a", # Bac + 5 / Ecole Ingénieur / Master
      "6b2b1bf0-b0b8-49e4-ad6f-04b6321f6bc7" => "1be7986c-3565-4890-aa97-d6d631ab5fbd", # Doctorat
      "c2bcb292-1a02-4de2-a072-1ccdf8fcb33d" => "8ab3d972-a205-4792-a0c8-0f1d3afcd62a", # Bac + 5 / Ecole Ingénieur / Master / Doctorat
      "e1f497ad-5c7d-458b-b557-b765f4ba7d39" => "870d19a4-e97b-42b3-95ae-39fed815a702", # Bac + 2 / Bac + 3
      "fca43c8b-27ac-46c6-b873-5f5bb8ba3194" => "5ae0768c-e28b-4271-9ee2-9132c3c0b4e6" # Bac + 2
    }.fetch(study_level_id)
  end
end
