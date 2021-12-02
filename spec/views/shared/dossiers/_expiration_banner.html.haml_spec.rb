describe 'shared/dossiers/expiration_banner.html.haml', type: :view do
  include DossierHelper

  let(:dossier) do
    create(:dossier, state, attributes.merge(
                              id: 1,
                              state: state,
                              procedure: create(:procedure, procedure_expires_when_termine_enabled: expiration_enabled)
                            ))
  end
  let(:i18n_key_state) { state }
  subject do
    render('shared/dossiers/expiration_banner.html.haml',
           dossier: dossier,
           current_user: build(:user))
  end

  context 'with procedure having procedure_expires_when_termine_enabled not enabled' do
    let(:expiration_enabled) { false }
    let(:attributes) { { processed_at: 6.months.ago } }
    let(:state) { :accepte }

    it 'render estimated expiration date' do
      expect(subject).not_to have_selector('.expires_at')
    end
  end

  context 'with procedure having procedure_expires_when_termine_enabled enabled' do
    let(:expiration_enabled) { true }

    context 'with dossier.brouillon?' do
      let(:attributes) { { created_at: 6.months.ago } }
      let(:state) { :brouillon }

      it 'render estimated expiration date' do
        expect(subject).to have_selector('.expires_at',
                                         text: I18n.t("shared.dossiers.header.expires_at.#{i18n_key_state}",
                                                      date: safe_expiration_date(dossier)))
      end
    end

    context 'with dossier.en_construction?' do
      let(:attributes) { { en_construction_at: 6.months.ago } }
      let(:state) { :en_construction }

      it 'render estimated expiration date' do
        expect(subject).to have_selector('.expires_at',
                                         text: I18n.t("shared.dossiers.header.expires_at.#{i18n_key_state}",
                                                      date: safe_expiration_date(dossier)))
      end
    end

    context 'with dossier.en_instruction?' do
      let(:state) { :en_instruction }
      let(:attributes) { {} }

      it 'render estimated expiration date' do
        expect(subject).to have_selector('p.expires_at_en_instruction',
                                         text: I18n.t("shared.dossiers.header.expires_at.#{i18n_key_state}"))
      end
    end

    context 'with dossier.en_processed_at?' do
      let(:state) { :accepte }
      let(:attributes) { {} }

      it 'render estimated expiration date' do
        allow(dossier).to receive(:processed_at).and_return(6.months.ago)
        expect(subject).to have_selector('.expires_at',
                                         text: I18n.t("shared.dossiers.header.expires_at.#{i18n_key_state}",
                                                      date: safe_expiration_date(dossier)))
      end
    end
  end
end
