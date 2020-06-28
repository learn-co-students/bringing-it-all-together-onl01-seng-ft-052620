require 'pry'

class Dog
    attr_accessor :id, :name, :breed

    def initialize(attributes)
        attributes.each {|key, value| self.send(("#{key}="), value)}
        self.id ||= nil
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
        sql = <<-SQL
        DROP TABLE dogs
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

    def self.new_from_db(row)
        new_dog = self.new(id: row[0],name: row[1],breed: row[2])
        new_dog.id = row[0]
        new_dog
    end

    def self.find_by_name(dog_name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL

        DB[:conn].execute(sql, dog_name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.create(hash)
        doggo = self.new(hash)
        doggo.save
    end

    def self.find_by_id(dog_id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL

        DB[:conn].execute(sql, dog_id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(name:, breed:)
        doggo = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]
        if doggo
            new_dog = self.new_from_db(doggo)
        else
            new_dog = self.create({:name => name, :breed => breed})
        end
        new_dog
    end
end