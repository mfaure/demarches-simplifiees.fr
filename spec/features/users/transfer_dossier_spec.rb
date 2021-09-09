describe 'Transfer dossier:' do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:procedure) { create(:simple_procedure) }
  let(:dossier) { create(:dossier, :en_construction, :with_individual, :with_commentaires, user: user, procedure: procedure) }

  before do
    dossier
    login_as user, scope: :user
    visit dossiers_path
  end

  scenario 'the user can transfer dossier to another user' do
    within(:css, "tr[data-dossier-id=\"#{dossier.id}\"]") do
      click_on 'Actions'
      click_on 'Transferer le dossier'
    end

    expect(page).to have_current_path(transferer_dossier_path(dossier))
    expect(page).to have_content("Transferer le dossier en construction nº #{dossier.id}")
    fill_in 'Email du compte destinataire', with: other_user.email
    click_on 'Envoyer la demande de transfert'

    logout
    login_as other_user, scope: :user
    visit dossiers_path

    expect(page).to have_content("Demande de transfert Nº #{dossier.reload.transfer.id} envoyé par #{user.email}")
    click_on 'Accepter'
    expect(page).to have_current_path(dossiers_path)
  end
end
