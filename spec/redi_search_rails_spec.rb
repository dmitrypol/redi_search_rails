require "spec_helper"

RSpec.describe RediSearchRails do

  it "has a version number" do
    expect(RediSearchRails::VERSION).not_to be nil
  end

  xit "redi_search_schema" do
    User.redi_search_schema
  end

  xit "ft_search" do
    User.ft_search('some keyword')
  end

  xit "ft_create" do
    User.ft_create
  end

  xit "ft_add_all" do
    User.ft_add_all
  end

  xit "ft_add" do
    user.ft_add
  end

  xit "ft_del" do
    User.ft_del
  end

  xit "ft_optimize" do
    User.ft_optimize
  end

  xit "ft_drop" do
    User.ft_drop
  end

  xit "ft_info" do
    User.ft_info
  end

end
