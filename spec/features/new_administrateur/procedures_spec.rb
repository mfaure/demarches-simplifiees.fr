require 'spec_helper'

feature 'As an administrateur I edit procedure', js: true do
  let(:administrateur) { procedure.administrateur }
  let(:procedure) { create(:procedure) }

  before do
    Flipflop::FeatureSet.current.test!.switch!(:champ_repetition, true)
    login_as administrateur, scope: :administrateur
    visit champs_procedure_path(procedure)
  end

  it "Add a new champ" do
    within '.footer' do
      click_on 'Ajouter un champ'
    end
    expect(page).to have_selector('#procedure_types_de_champ_attributes_0_libelle')
    fill_in 'procedure_types_de_champ_attributes_0_libelle', with: 'libellé de champ'
    expect(page).to have_content('Formulaire mis à jour')

    page.refresh
    within '.footer' do
      click_on 'Enregistrer'
    end

    expect(page).to have_content('Formulaire mis à jour')
  end

  it "Add multiple champs" do
    within '.footer' do
      click_on 'Ajouter un champ'
      click_on 'Ajouter un champ'
      click_on 'Ajouter un champ'
      click_on 'Ajouter un champ'
    end
    expect(page).not_to have_content('Le libellé doit être rempli.')
    expect(page).not_to have_content('Modifications non sauvegardées.')
    expect(page).not_to have_content('Formulaire mis à jour')
    fill_in 'procedure_types_de_champ_attributes_0_libelle', with: 'libellé de champ 0'

    expect(page).to have_selector('#procedure_types_de_champ_attributes_0_libelle')
    expect(page).to have_selector('#procedure_types_de_champ_attributes_1_libelle')
    expect(page).to have_selector('#procedure_types_de_champ_attributes_2_libelle')
    expect(page).to have_selector('#procedure_types_de_champ_attributes_3_libelle')

    expect(page).to have_content('Le libellé doit être rempli.')
    expect(page).to have_content('Modifications non sauvegardées.')
    expect(page).not_to have_content('Formulaire mis à jour')
    fill_in 'procedure_types_de_champ_attributes_2_libelle', with: 'libellé de champ 2'

    within '.draggable-item-3' do
      click_on 'Supprimer'
    end

    expect(page).to have_content('Le libellé doit être rempli.')
    expect(page).to have_content('Modifications non sauvegardées.')
    expect(page).not_to have_content('Formulaire mis à jour')
    fill_in 'procedure_types_de_champ_attributes_1_libelle', with: 'libellé de champ 1'

    expect(page).not_to have_content('Le libellé doit être rempli.')
    expect(page).not_to have_content('Modifications non sauvegardées.')
    expect(page).to have_content('Formulaire mis à jour')
    page.refresh

    expect(page).to have_content('Supprimer', count: 3)
  end

  it "Remove champs" do
    within '.footer' do
      click_on 'Ajouter un champ'
    end
    fill_in 'procedure_types_de_champ_attributes_0_libelle', with: 'libellé de champ'
    expect(page).to have_content('Formulaire mis à jour')
    page.refresh

    click_on 'Supprimer'
    expect(page).to have_content('Formulaire mis à jour')
    expect(page).not_to have_content('Supprimer')
    page.refresh

    expect(page).not_to have_content('Supprimer')
  end

  it "Only add valid champs" do
    within '.footer' do
      click_on 'Ajouter un champ'
    end
    expect(page).to have_selector('#procedure_types_de_champ_attributes_0_description')
    fill_in 'procedure_types_de_champ_attributes_0_description', with: 'déscription du champ'
    expect(page).to have_content('Le libellé doit être rempli.')
    expect(page).not_to have_content('Formulaire mis à jour')

    fill_in 'procedure_types_de_champ_attributes_0_libelle', with: 'libellé de champ'
    expect(page).to have_content('Formulaire mis à jour')
  end

  it "Add repetition champ" do
    within '.footer' do
      click_on 'Ajouter un champ'
    end
    expect(page).to have_selector('#procedure_types_de_champ_attributes_0_libelle')
    select('Bloc répétable', from: 'procedure_types_de_champ_attributes_0_type_champ')
    fill_in 'procedure_types_de_champ_attributes_0_libelle', with: 'libellé de champ'

    expect(page).to have_content('Formulaire mis à jour')
    page.refresh

    within '.flex-grow' do
      click_on 'Ajouter un champ'
    end

    fill_in 'procedure_types_de_champ_attributes_0_types_de_champ_attributes_0_libelle', with: 'libellé de champ 1'

    expect(page).to have_content('Formulaire mis à jour')
    expect(page).to have_content('Supprimer', count: 2)

    within '.footer' do
      click_on 'Ajouter un champ'
    end

    select('Bloc répétable', from: 'procedure_types_de_champ_attributes_1_type_champ')
    fill_in 'procedure_types_de_champ_attributes_1_libelle', with: 'libellé de champ 2'

    expect(page).to have_content('Supprimer', count: 3)
  end
end