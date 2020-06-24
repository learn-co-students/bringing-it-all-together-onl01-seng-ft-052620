class Dog 
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end 

    def self.create_table 
        Dog.drop_table
        sql =  <<-SQL 
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
        sql = <<-SQL 
        INSERT INTO dogs (name, breed)
        VALUES(?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end 

    def self.create(hash)
        dog = Dog.new(name: hash[:name], breed: hash[:breed])
        dog.save
        dog
      end

      def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        new_dog = self.new(id: id, name: name, breed: breed)
        new_dog
      end 

      def self.find_by_id(id)
        sql = <<-SQL 
        SELECT ALL FROM dogs 
        WHERE id = ?
        LIMIT 1
        SQL
        DB[:conn].execute(sql, id)
      end 

end 


