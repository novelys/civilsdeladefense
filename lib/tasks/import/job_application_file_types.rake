namespace :import do
  task job_application_file_types: :environment do
    Importer.import_json(ENV["JOB_APPLICATION_FILE_TYPES_URL"]).select do |raw|
      JobApplicationFileType.find_by(id: raw["id"]).nil?
    end.each do |raw|
      if job_application_file_type_id(raw["id"]).nil?
        puts "Importing job application file type: #{raw["name"]}"

        JobApplicationFileType.create!(raw)
      else
        puts "No need to import mapped job application file type: #{raw["name"]}"
      end
    end
  end

  private

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
