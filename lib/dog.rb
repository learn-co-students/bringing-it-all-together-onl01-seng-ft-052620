class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name 
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL 
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed text
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL 
        DROP TABLE dogs;
        SQL
        DB[:conn].execute(sql)
    end

    # returns an instance of the dog class
    # saves an instance of the dog class to the database and then sets the given dogs `id` attribute
    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs(name, breed)
                VALUES(?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    # takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database
    # returns a new dog object
    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    # id, name, breed
    # creates an instance with corresponding attribute values
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    # returns a new dog object by id
    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            id = dog[0][0]
            Dog.find_by_id(id)
        else
            self.create(name: name, breed: breed) 
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
         SQL
         DB[:conn].execute(sql,name).map do|row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL 
        UPDATE dogs 
        SET name = ?, breed = ? 
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end