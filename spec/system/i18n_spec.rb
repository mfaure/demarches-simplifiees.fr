describe 'Accessing the website in different languages:' do
  context 'when the i18n feature-flag is enabled' do
    before { ENV['LOCALIZATION_ENABLED'] = 'true' }
    after { ENV['LOCALIZATION_ENABLED'] = 'false' }

    scenario 'I can change the language of the page' do
      visit new_user_session_path
      expect(page).to have_text('Connectez-vous')

      click_on 'Langues'
      click_on 'English'

      # The page is now in English
      expect(page).to have_text('Sign in')
      # The page URL stayed the same
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
