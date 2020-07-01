class Dog 
  attr_accessor :name, :breed, :id
  
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end
  
  def self.create_table
    sql = <<-SQL  
          CREATE TABLE IF NOT EXISTS dogs(
             id INTEGER PIMARY KEY,
             name TEXT,
             breed TEXT
           );
        SQL
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
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
      self
    end
  end
  
  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end
  
  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end 
  
  def self.find_by_id(id)
    sql = "SELECT * FROM  dogs WHERE id= ?"
    result = DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}.first
  end 
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
       id = dog[0][0]
        self.find_by_id(id)
    else
        dog = self.create(name: name, breed: breed)
    end
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
  end 
  
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id= ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
end 











