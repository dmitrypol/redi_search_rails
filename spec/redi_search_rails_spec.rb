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
    User.ft_add(User.new(name: 'Bob Smith', age: 100))
    User.ft_add(User.new(name: 'Bobs', age: 50))
    test = User.ft_search('bob')
    expect(test).not_to be nil
    expect(test.count).to eq 2
    expect(test[0]['name']).to eq 'Bob Smith'
    expect(test[0]['age']).to eq '100'
    expect(test[1]['name']).to eq 'Bobs'
    expect(test[1]['age']).to eq '50'
  end

  it "ft_create" do
    test = User.ft_create
    expect(test).to eq 0
  end

  it "ft_add_all" do
    User.ft_create
    User.new(name: 'Bob', age: 100)
    User.new(name: 'Bobs', age: 50)
    User.ft_add_all
  end

  it "ft_add" do
    User.ft_create
    test = User.ft_add(User.new(name: 'Bob Smith', age: 100))
    expect(test).to eq 'OK'
    test2 = User.ft_search('bob')
    expect(test2[0]['age']).to eq '100'
  end

  it "ft_del" do
    User.ft_create
    test = User.ft_del(User.new)
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
