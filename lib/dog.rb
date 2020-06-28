class Dog
    attr_accessor :name, :breed 
    attr_reader :id
    
    def initialize(params = {})
        @id = params.fetch(:id, nil)
        @name = params.fetch(:name, 'name')
        @breed = params.fetch(:breed, 'breed') 
    end 

    def self.create_table
        sql = <<-SQL 
        CREATE TABLE dogs (
        id INTEGER,
        name TEXT,
        breed TEXT
        );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        drop table dogs;
        SQL
     DB[:conn].execute(sql)
    end 

    def save
        
     sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
        SQL
    
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
       
  self
    end

    def self.create(hash_of_attributes)
        dog = Dog.new(hash_of_attributes)
        dog.save
    end

    def self.new_from_db(row)
       attributes_hash = {
           :id => row[0],
           :name => row[1],
           :breed  => row[2]
       }
       Dog.new(attributes_hash)
    end

    def self.find_by_id(id)
        sql =<<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
    if dog
     new_dog = self.new_from_db(dog)
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
    end.first
  end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end
end 