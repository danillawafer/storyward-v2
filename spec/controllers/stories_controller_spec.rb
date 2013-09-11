require 'spec_helper'

describe StoriesController do
  render_views

  let(:user){ FactoryGirl.create(:user) }
  let(:story){ FactoryGirl.create(:story) }

  before(:each) do 
    sign_in user
  end

  describe '#create' do
    it 'creates a story' do
      expect { post :create, story: FactoryGirl.attributes_for(:story), node: FactoryGirl.attributes_for(:node) }.to change(Story,:count).by(1)
    end

    it 'with invalid params' do
      post :create, story: FactoryGirl.attributes_for(:story), node: FactoryGirl.attributes_for(:node, title: '')
      response.should render_template('new')
    end
  end

  describe '#show' do
    it 'finds the right story' do
      get :show, id: story
      assigns(:story).should eq(story)
    end
  end

  describe "#delete" do
    it 'removes an entry from the database' do
      story
      expect{ delete :destroy, id: story }.to change(Story,:count).by(-1)
    end
  end
end
