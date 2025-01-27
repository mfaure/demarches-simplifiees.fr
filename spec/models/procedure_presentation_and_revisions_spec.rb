describe ProcedurePresentation do
  describe "#types_de_champ_for_procedure_presentation" do
    subject { procedure.types_de_champ_for_procedure_presentation.not_repetition.pluck(:libelle) }

    context 'for a draft procedure' do
      let(:procedure) { create(:procedure) }

      context 'when there are one tdc on a published revision' do
        let!(:tdc) { { type_champ: :number, libelle: 'libelle 1' } }

        before { procedure.draft_revision.add_type_de_champ(tdc) }

        it { is_expected.to match(['libelle 1']) }
      end
    end

    context 'for a published procedure' do
      let(:procedure) { create(:procedure, :published) }
      let(:tdc) { { type_champ: :number, libelle: 'libelle 1' } }

      before do
        procedure.draft_revision.add_type_de_champ(tdc)
        procedure.publish_revision!
      end

      it { is_expected.to match(['libelle 1']) }

      context 'when there is another published revision with an added tdc' do
        let(:added_tdc) { { type_champ: :number, libelle: 'libelle 2' } }

        before do
          procedure.draft_revision.add_type_de_champ(added_tdc)
          procedure.publish_revision!
        end

        it { is_expected.to match(['libelle 1', 'libelle 2']) }
      end

      context 'add one tdc above the first one' do
        let(:tdc2) { { type_champ: :number, libelle: 'libelle 2' } }

        before do
          created_tdc2 = procedure.draft_revision.add_type_de_champ(tdc2)
          procedure.draft_revision.move_type_de_champ(created_tdc2.stable_id, 0)
          procedure.publish_revision!
        end

        it { is_expected.to match(['libelle 2', 'libelle 1']) }

        context 'and finally, when this tdc is removed' do
          let!(:previous_tdc2) { procedure.published_revision.types_de_champ.find_by(libelle: 'libelle 2') }

          before do
            procedure.draft_revision.remove_type_de_champ(previous_tdc2.stable_id)

            procedure.publish_revision!
          end

          it { is_expected.to match(['libelle 1', 'libelle 2']) }
        end
      end

      context 'when there is another published revision with a renamed tdc' do
        let!(:previous_tdc) { procedure.published_revision.types_de_champ.first }
        let!(:changed_tdc) { { type_champ: :number, libelle: 'changed libelle 1' } }

        before do
          type_de_champ = procedure.draft_revision.find_or_clone_type_de_champ(previous_tdc.id)
          type_de_champ.update(changed_tdc)

          procedure.publish_revision!
        end

        it { is_expected.to match(['changed libelle 1']) }
      end

      context 'when there is another published which removes a previous tdc' do
        let!(:previous_tdc) { procedure.published_revision.types_de_champ.first }

        before do
          type_de_champ = procedure.draft_revision.remove_type_de_champ(previous_tdc.id)

          procedure.publish_revision!
        end

        it { is_expected.to match(['libelle 1']) }
      end
    end
  end
end
