require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    describe 'if success' do
      let(:post_user) {
        create(:user) do |user|
          post :create, params: { session: {
            email: user.email,
            password: user.password
          } }
        end
      }
      it 'saves new user' do
        expect {
          post_user
        }.to change(User, :count).by(1)
      end

      it 'redirects the :create template if success' do
        user = post_user
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/users/#{user.id}")
      end

      it 'doesnt flash' do
        post_user
        expect(flash).to be_empty
      end

      it 'contains user_id in session' do
        user = post_user
        expect(session[:user_id]).to eq user.id
      end
    end

    describe 'if email failure' do
      let(:login_invalid_user) do
        create(:user) do |user|
          post :create, params: { session: {
            email: 'dummy@password.com',
            password: user.password
          } }
        end
      end

      it 'renders the sessions/new template' do
        login_invalid_user
        expect(response).to have_http_status(:success)
        expect(response).to render_template('sessions/new')
      end

      it 'flash danger' do
        login_invalid_user
        expect(flash[:danger]).to be
      end
    end

    describe 'if password failure' do
      let(:login_invalid_user) do
        create(:user) do |user|
          post :create, params: { session: {
            email: user.email,
            password: user.password + 'dummy'
          } }
        end
      end

      it 'renders the sessions/new template' do
        login_invalid_user
        expect(response).to have_http_status(:success)
        expect(response).to render_template('sessions/new')
      end

      it 'flash danger' do
        login_invalid_user
        expect(flash[:danger]).to be
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }

    let(:delete_user) do
      delete :destroy, params: { id: user.id }
    end

    it 'saves new user' do
      expect { delete_user }.to change(User, :count).by(0)
    end

    it 'returns http success' do
      delete_user
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to('/')
    end

    it 'doesnt contains user_id in session' do
      session[:user_id] = user.id
      delete_user

      expect(session[:user_id]).not_to be
    end
  end
end
