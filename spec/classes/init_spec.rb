require 'spec_helper'
describe 'rock' do
  context 'with default values for all parameters' do
    it { should contain_class('rock') }
  end
end
