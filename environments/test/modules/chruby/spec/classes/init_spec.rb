require 'spec_helper'
describe 'chruby' do

  context 'with defaults for all parameters' do
    it { should contain_class('chruby') }
  end
end
