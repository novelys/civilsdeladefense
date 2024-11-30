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
end
