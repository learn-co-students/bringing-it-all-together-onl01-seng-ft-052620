class Dog
  attr_accessor :name, :breed, :id

  @@all = {}

  def initialize(id=nil, dog_data)
    self.id = id
    self.name = dog_data[:name]
    self.breed = dog_data[:breed]
  end 

  def self.all
    @@all
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
      if self.id
        self.update
      else
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
    
        DB[:conn].execute(sql, self.name, self.breed)
    
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      
        @@all.store(@id, self)
      end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    dog = self.new(id: row[0], name: row[1], breed: row[2])
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL

    a = DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
    a
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    
    a = DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
    a
  end

  def self.find_or_create_by(dog_data)
    name = dog_data[:name]
    breed = dog_data[:breed]

    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
    SQL

    dog = DB[:conn].execute(sql, name, breed)
    # the above returns an array of arrays if it is true that it is not empty
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new_from_db(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end

    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end