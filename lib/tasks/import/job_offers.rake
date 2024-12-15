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

  def contract_type_id(contract_type_id)
    # Key: id DGA, Value: id CVD
    {
      "c3ff27eb-6833-4cf2-9dc3-7151201bc68f" => "c42553ee-0b18-4117-b3de-741dca6fd340" # CDI
    }.fetch(contract_type_id)
  end

  def professional_category_id(professional_category_id)
    # Key: id DGA, Value: id CVD
    {
      "1b5a2466-498a-4e13-ac93-0ef43314859a" => "973219d1-c36f-464c-a6a7-acd31a29593f", # Technicien
      "da6827a2-2dfd-4c41-b534-2c37c3d412ce" => "4353f0b7-ca66-4569-8d2f-b0ec6d760d60" # Ingénieur / Cadre
    }.fetch(professional_category_id)
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
    }.fetch(level_id)
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
    }.fetch(category_id)
  end
end
