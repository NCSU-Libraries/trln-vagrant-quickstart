require 'spec_helper'
describe 'gitsetup' do

  context 'with defaults for all parameters' do
    it { should contain_class('gitsetup') }
  end
end
