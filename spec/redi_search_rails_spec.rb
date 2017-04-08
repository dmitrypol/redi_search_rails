require "spec_helper"

RSpec.describe RediSearchRails do

  before(:all) do
    REDI_SEARCH = Redis.new
  end
  before(:each) do
    REDI_SEARCH.flushdb
  end

  it "has a version number" do
    expect(RediSearchRails::VERSION).not_to be nil
  end

  it "redi_search_schema" do
    test = User.redi_search_schema(name: 'TEXT', age: 'NUMERIC')
    expect(test).to eq 1
  end

  it "ft_search" do
    User.ft_create
    User.ft_add(User.new(name: 'Bob', age: 100))
    test = User.ft_search('bob')
    expect(test).not_to be nil
  end

  it "ft_create" do
    test = User.ft_create
    expect(test).to eq 0
  end

  xit "ft_add_all" do
    User.ft_create
    User.ft_add_all
  end

  it "ft_add" do
    User.ft_create
    test = User.ft_add(User.new(name: 'Bob', age: 100))
    expect(test).to eq 'OK'
  end

  it "ft_del" do
    User.ft_create
    doc_id = User.new.to_global_id
    test = User.ft_del(doc_id)
    expect(test).to eq 0
  end

  it "ft_optimize" do
    User.ft_create
    test = User.ft_optimize
    expect(test).to eq 0
  end

  it "ft_drop" do
    User.ft_create
    test = User.ft_drop
    expect(test).to eq 'OK'
  end

  it "ft_info" do
    User.ft_create
    test = User.ft_info
    expect(test).not_to be nil
  end

end
