require 'spec_helper'
describe 'blacklight' do

  context 'with defaults for all parameters' do
    it { should contain_class('blacklight') }
  end
end
