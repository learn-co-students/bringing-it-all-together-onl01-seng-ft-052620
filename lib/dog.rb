class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
  sql = <<-SQL
  CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL

  DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs;
    SQL

  DB[:conn].execute(sql)
  end

def save

  if @id == nil
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  else
    self.update
  end
self
end

def update

  sql =  <<-SQL
  UPDATE dogs
  SET name = ?, breed = ?
  WHERE dogs.id = ?;
  SQL
  DB[:conn].execute(sql, self.name, self.breed, self.id)

end

def self.create(name:, breed:)

  new_name = name
  new_breed = breed
  new_dog = Dog.new(name: new_name, breed: new_breed, id: nil)
  new_dog.save

end

def self.new_from_db(row)

  new_id = row[0]
  new_name = row[1]
  new_breed = row[2]
  new_dog = Dog.new(name: new_name, breed: new_breed, id: new_id)
  new_dog

end

def self.find_by_id(id)
  sql = <<-SQL
  SELECT *
  FROM dogs
  WHERE dogs.id = ?
  SQL

  row = DB[:conn].execute(sql, id).flatten

  new_id = row[0]
  new_name = row[1]
  new_breed = row[2]
  new_dog = Dog.new(name: new_name, breed: new_breed, id: new_id)
  new_dog
end

def self.find_or_create_by(name:, breed:, id: nil)
  this_dog = nil
  this_name = name
  this_breed = breed
  sql = <<-SQL
  SELECT *
  FROM dogs
  WHERE dogs.breed = ?
  SQL

  row = DB[:conn].execute(sql, this_breed).flatten
  this_id = row[0]

  if this_id == nil
    this_dog = Dog.create(name: this_name, breed: this_breed)
  else
    this_dog = Dog.find_by_id(this_id)
  end
  this_dog

end


def self.find_by_name(name)
  sql = <<-SQL
  SELECT *
  FROM dogs
  WHERE dogs.name = ?
  SQL

  row = DB[:conn].execute(sql, name).flatten
  this_dog = Dog.new_from_db(row)
  this_dog
end


end
