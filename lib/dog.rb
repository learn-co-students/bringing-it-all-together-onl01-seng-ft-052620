class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = "CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,    
        name TEXT,
        breed TEXT);
        "
        DB[:conn].execute(sql)
    end

    def self.drop_table
      DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)", @name, @breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
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
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE id =?", id).flatten
        Dog.new_from_db(dog)
    end

    def self.find_or_create_by(hash)
        # binding.pry
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
        if dog != []
            id =dog[0][0]
            Dog.find_by_id(id)
        else 
            Dog.create(hash)
        end
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name =?", name).flatten
        Dog.new_from_db(dog)
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end
end