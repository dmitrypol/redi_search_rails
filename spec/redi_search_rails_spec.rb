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
    test = User.redi_search_schema(name: 'TEXT', email: 'TEXT', age: 'NUMERIC')
    expect(test).to eq 1
    test = Role.redi_search_schema(name: 'TEXT')
    expect(test).to eq 1
  end

  context 'ft_search' do
    before(:each) do
      User.ft_create
      user1 = User.new(name: 'Bob Smith', age: 100, email: 'bob@gmail.com')
      User.ft_add(record: user1)
      user2 = User.new(name: 'Bobs', age: 50, email: 'bobs@gmail.com')
      User.ft_add(record: user2)
      Role.ft_create
      Role.ft_add(record: Role.new(name: 'admin'))
    end
    it "ft_search" do
      expect(User.ft_search(keyword: '  bob  ')).not_to eq nil
      expect(User.ft_search(keyword: 'foo')).to eq [0]
      expect(Role.ft_search(keyword: 'admin')).not_to eq nil
      expect(Role.ft_search(keyword: 'bar')).to eq [0]
      expect(User.ft_search(keyword: '')).to eq [0]
    end
    it 'ft_search_format' do
      test = User.ft_search_format(keyword: 'bob')
      expect(test.count).to eq 2
      expect(test[0].name).to eq 'Bob Smith'
      expect(test[0].age).to eq '100'
      expect(test[1].name).to eq 'Bobs'
      expect(test[1].age).to eq '50'
      # => invalid
      test = User.ft_search_format(keyword: 'foo')
      expect(test).to eq []
      # => blank
      test = User.ft_search_format(keyword: '')
      expect(test).to eq []
      # => spaces
      test = User.ft_search_format(keyword: '   ')
      expect(test).to eq []
      # =>
      test = Role.ft_search_format(keyword: 'admin')
      expect(test.count).to eq 1
      expect(test[0].name).to eq 'admin'
    end
    it "ft_search_count" do
      expect(User.ft_search_count(keyword: 'gmail')).to eq 2
      expect(User.ft_search_count(keyword: 'bob')).to eq 2
      expect(Role.ft_search_count(keyword: 'admin')).to eq 1
    end
    it 'limit_offset_num' do
      20.times do |i|
        User.ft_add(record: User.new(name: 'Tom', age: i))
      end
      expect(User.ft_search(keyword: 'Tom').first).to eq 20
      expect(User.ft_search_format(keyword: 'Tom', offset: 0, num: 100).count).to eq 20
      expect(User.ft_search_count(keyword: 'Tom', offset: 0, num: 100)).to eq 20
      expect(User.ft_search(keyword: 'Tom', offset: '', num: '').first).to eq 20
      expect(User.ft_search_format(keyword: 'Tom', offset: 0, num: 5).count).to eq 5
      expect(User.ft_search_format(keyword: 'Tom', offset: 10, num: 7).count).to eq 7
    end
    it 'filter' do
      User.ft_add(record: User.new(name: 'Tom', age: 100))
      User.ft_add(record: User.new(name: 'Tom', age: 50))
      # =>
      test = User.ft_search(keyword: 'Tom', filter: {numeric_field: 'age', min: 50, max: 100})
      expect(test.first).to eq 2
      # =>
      test = User.ft_search(keyword: 'Tom', filter: {numeric_field: 'age', min: 50, max: 60})
      expect(test.first).to eq 1
      # =>
      test = User.ft_search(keyword: 'Tom', filter: {numeric_field: 'age', min: 10, max: 20})
      expect(test.first).to eq 0
    end
    xit 'special chars' do
      User.ft_search(keyword: 'bob@gmail.com')
      # =>  TODO "Syntax error at offset 10 near 'com'"
    end
  end

  it "ft_create" do
    expect(User.ft_create).to eq 0
    expect(Role.ft_create).to eq 0
  end

  it "ft_add_all" do
    User.ft_create
    User.new(name: 'Bob', age: 100)
    User.new(name: 'Bobs', age: 50)
    User.ft_add_all
    # => TODO: all and each methods not present for current test records
  end

  it "ft_add" do
    User.ft_create
    Role.ft_create
    test = User.ft_add(record: User.new(name: 'Bob Smith', age: 100))
    expect(test).to eq 'OK'
    test = Role.ft_add(record: User.new(name: 'admin'))
    expect(test).to eq 'OK'
    test = User.ft_search(keyword: 'bob')
    expect(test.first).to eq 1
  end

  it "ft_addhash" do
    User.ft_create
    record = REDI_SEARCH.hmset("user1", "name", "Bob Smith", "age", "100")
    test = User.ft_addhash(redis_key: "user1")
    expect(test).to eq 'OK'
    test = User.ft_search(keyword: 'bob')
    expect(test).to eq [1, "user1", ["name", "Bob Smith", "age", "100"]]
  end

  it "ft_del_all" do
    User.ft_create
    User.new(name: 'Bob', age: 100)
    User.new(name: 'Bobs', age: 50)
    User.ft_add_all
    User.ft_del_all
    test = User.ft_search(keyword: 'bob')
    expect(test.first).to eq 0
  end

  it "ft_del" do
    User.ft_create
    Role.ft_create
    expect(User.ft_del(record: User.new(name: 'bob'))).to eq 0
    expect(Role.ft_del(record: User.new(name: 'bob'))).to eq 0
  end

  it "ft_optimize" do
    User.ft_create
    expect(User.ft_optimize).to eq 0
    Role.ft_create
    expect(Role.ft_optimize).to eq 0
  end

  it "ft_drop" do
    User.ft_create
    Role.ft_create
    expect(User.ft_drop).to eq 'OK'
    expect(Role.ft_drop).to eq 'OK'
  end

  it "ft_info" do
    User.ft_create
    Role.ft_create
    expect(User.ft_info).not_to be nil
    expect(Role.ft_info).not_to be nil
  end

  context 'ft_sug' do
    before(:each) do
      ['Bob', 'Bobby', 'Mary'].each_with_index do |name, index|
        user = User.new(name: name)
        test = User.ft_sugadd(record: user, attribute: 'name')
        expect(test).to eq index + 1
      end
    end
    it "ft_sugadd_all" do
      User.new(email: 'foo')
      User.new(email: 'bar')
      User.ft_sugadd_all(attribute: 'email')
      #test = expect(User.ft_suglen(attribute: 'email')).to eq 2
    end
    it "ft_sugadd" do
      user = User.new(email: 'foo')
      expect(User.ft_sugadd(record: user, attribute: 'email')).to eq 1
    end
    it "ft_sugget" do
      test = User.ft_sugget(attribute: 'name', prefix: 'b')
      expect(test).to eq ["Bob", "Bobby"]
      test = User.ft_sugget(attribute: 'name', prefix: 'm')
      expect(test).to eq ["Mary"]
    end
    it "ft_sugdel" do
      user = User.new(name: 'Susan')
      User.ft_sugadd(record: user, attribute: 'name')
      test = User.ft_sugdel(record: user, attribute: 'name')
      expect(test).to eq 1
      test = User.ft_sugdel(record: user, attribute: 'name')
      expect(test).to eq 0
    end
    it "ft_sugdel_all" do
      User.new(email: 'foo')
      User.new(email: 'bar')
      User.ft_sugadd_all(attribute: 'email')
      User.ft_sugdel_all(attribute: 'email')
      expect(User.ft_suglen(attribute: 'email')).to eq 0
    end
    it "ft_suglen" do
      expect(User.ft_suglen(attribute: 'name')).to eq 3
      user = User.new(name: 'Susan')
      User.ft_sugadd(record: user, attribute: 'name')
      expect(User.ft_suglen(attribute: 'name')).to eq 4
      User.ft_sugdel(record: user, attribute: 'name')
      expect(User.ft_suglen(attribute: 'name')).to eq 3
    end
  end

end
