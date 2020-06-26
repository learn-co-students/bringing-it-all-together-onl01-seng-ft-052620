class Dog
attr_accessor :id, :name, :breed

def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
end

def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
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

def self.new_from_db(array)
    id = array[0]
    name = array[1]
    breed = array[2]
    self.new(id: id, name: name, breed: breed)
end

def self.find_by_name(name)
    array = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    if !array
        nil
    else
    self.new_from_db(array)
    end
end

def update
sql = <<-SQL
UPDATE dogs SET name = ?, breed = ? WHERE id = ?
SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
end

def save
    if self.id
        self.update
    else
        self.insert
    end
    self
end

def insert
    sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
end

def self.create(name:, breed:, id:nil)
    dog = self.new(name: name, breed: breed)
    dog.save
end

def self.find_by_id(id)
    array = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    if !array
        nil
    else
    self.new_from_db(array)
    end
end

def self.find_or_create_by(name:, breed:)
    dog = self.find_by_name(name)
    if !dog || dog.breed != breed
        self.create(name: name, breed: breed)
    else
    dog
    end
end


end