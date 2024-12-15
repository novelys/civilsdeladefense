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

  def experience_level_id(experience_level_id)
    # Key: id DGA, Value: id CVD
    {
      "036967cd-f4ed-4513-9967-aa5170363b45" => "0939a5e4-268c-488c-9071-659d6843d700", # Junior
      "067d1c9e-c9a0-41ac-ae37-ce3352c62465" => "0939a5e4-268c-488c-9071-659d6843d700", # Débutant
      "2e42e48d-c974-4c25-a1e3-9d76d5398961" => "5ee6e2c0-56fb-42c8-82b1-903676bb9a09", # Expérimenté
      "4b711c3b-6737-4139-9756-cceca381b67c" => "d7994814-415d-443c-ad6f-a627ef9f10a4", # Indifférent
      "f66fdcc2-4116-4cda-a6ea-b90f0f7dafe8" => "030301a2-0b2b-4b0c-8ea5-5bfc9325a269" # Confirmé
    }.fetch(experience_level_id)
  end

  def foreign_language_id(foreign_language_id)
    # Key: id DGA, Value: id CVD
    {
      "188dbb29-cbfd-4422-b7de-6f7abddd2b17" => "4f2051e4-8d62-4ca1-80d5-a35694c1cb29", # Intermédiaire / B1 / B2
      "59b02d86-0a74-45eb-b891-76facd073794" => "5274d213-4364-4267-9e63-e5f49ab1a69b", # Avancé / C1 / C2
      "7427a756-90bb-48c5-a25c-1fac11861dbb" => "509eb999-0b3c-4e7b-bafa-5626e134c961" # Débutant / A1 / A2
    }.fetch(foreign_language_id)
  end
end
