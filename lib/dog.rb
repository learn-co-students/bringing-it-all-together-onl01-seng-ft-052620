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
      CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT);
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
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
      SQL
    DB[:conn].execute(sql, @name, @breed)
    dog_id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    @id = dog_id
    self
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
      SQL
    selected_dog = DB[:conn].execute(sql, id).flatten
    Dog.new_from_db(selected_dog)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
      SQL
    selected_dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if selected_dog != []
        id = selected_dog[0][0]
        Dog.find_by_id(id)
    else
        Dog.create(hash)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name =?;
      SQL
    selected_dog = DB[:conn].execute(sql, name).flatten
    Dog.new_from_db(selected_dog)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
