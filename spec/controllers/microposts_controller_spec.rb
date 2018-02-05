require 'rails_helper'

RSpec.describe MicropostsController, type: :controller do
  let(:logged_in_user_ok) do
    allow(controller).to receive(:logged_in_user).and_return(true)
  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:micropost) { build(:micropost) }
    let(:action) do
      post :create, params: {
        micropost: { content: content }
      }, session: {}
    end
    let(:content) { micropost.content }

    let(:stubbed_current_user) do
      allow(controller).to receive(:current_user).and_return(user)
    end

    before(:each) do
      logged_in_user_ok
      stubbed_current_user
    end

    describe 'when it saves successfully' do
      it 'saves the micropost' do
        expect { action }.to change(Micropost, :count).by(1)
      end

      it 'flashes success sign' do
        action
        expect(flash[:success]).to be
      end

      it 'renders root' do
        action
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/')
      end
    end

    describe 'when failure' do
      let(:content) { ' ' }
      it 'doesnt save the micropost' do
        expect { action }.to change(Micropost, :count).by(0)
      end

      it 'renders home page' do
        action
        expect(response).to have_http_status(:success)
        expect(response).to render_template('static_pages/home')
      end
    end
  end
end
