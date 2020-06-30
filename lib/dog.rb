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
    
  
end 