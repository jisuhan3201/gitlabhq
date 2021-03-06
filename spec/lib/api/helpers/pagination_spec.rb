require 'spec_helper'

describe API::Helpers::Pagination do
  let(:resource) { Project.all }

  subject do
    Class.new.include(described_class).new
  end

  describe '#paginate' do
    let(:value) { spy('return value') }

    before do
      allow(value).to receive(:to_query).and_return(value)

      allow(subject).to receive(:header).and_return(value)
      allow(subject).to receive(:params).and_return(value)
      allow(subject).to receive(:request).and_return(value)
    end

    describe 'required instance methods' do
      let(:return_spy) { spy }

      it 'requires some instance methods' do
        expect_message(:header)
        expect_message(:params)
        expect_message(:request)

        subject.paginate(resource)
      end
    end

    context 'when resource can be paginated' do
      before do
        create_list(:project, 3)
      end

      describe 'first page' do
        before do
          allow(subject).to receive(:params)
            .and_return({ page: 1, per_page: 2 })
        end

        it 'returns appropriate amount of resources' do
          expect(subject.paginate(resource).count).to eq 2
        end

        it 'adds appropriate headers' do
          expect_header('X-Total', '3')
          expect_header('X-Total-Pages', '2')
          expect_header('X-Per-Page', '2')
          expect_header('X-Page', '1')
          expect_header('X-Next-Page', '2')
          expect_header('X-Prev-Page', '')
          expect_header('Link', any_args)

          subject.paginate(resource)
        end
      end

      describe 'second page' do
        before do
          allow(subject).to receive(:params)
            .and_return({ page: 2, per_page: 2 })
        end

        it 'returns appropriate amount of resources' do
          expect(subject.paginate(resource).count).to eq 1
        end

        it 'adds appropriate headers' do
          expect_header('X-Total', '3')
          expect_header('X-Total-Pages', '2')
          expect_header('X-Per-Page', '2')
          expect_header('X-Page', '2')
          expect_header('X-Next-Page', '')
          expect_header('X-Prev-Page', '1')
          expect_header('Link', any_args)

          subject.paginate(resource)
        end
      end
    end

    def expect_header(name, value)
      expect(subject).to receive(:header).with(name, value)
    end

    def expect_message(method)
      expect(subject).to receive(method)
        .at_least(:once).and_return(value)
    end
  end
end
