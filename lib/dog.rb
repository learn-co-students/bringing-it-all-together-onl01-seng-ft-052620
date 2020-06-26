class Dog
    attr_accessor :name, :breed, :id

    def initialize(name: nil, breed: nil, id: nil)
        self.name = name
        self.breed = breed
        @id = id
        self

    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY, 
            name TEXT, 
            breed TEXT
        );
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
        if self.id
            update
        else
            sql_save = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
                DB[:conn].execute(sql_save, name, breed)
            sql_id = <<-SQL
                SELECT last_insert_rowid() FROM dogs
            SQL
                @id = DB[:conn].execute(sql_id).flatten.first
        end
        self
    end

    def self.create (name:, breed:)
        new_dog = Dog.new()
        new_dog.name = name
        new_dog.breed = breed
        new_dog.save
        new_dog
    end

    def self.new_from_db (attributes)
        id, name, breed = attributes[0], attributes[1], attributes[2]
        new_dog = new
        new_dog.name= name
        new_dog.breed= breed
        new_dog.id= id
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        id, name, breed = DB[:conn].execute(sql, id).first
        new(id: id, name: name, breed: breed)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            AND breed = ?
        SQL
        id, name, bree = DB[:conn].execute(sql, name, breed).first
        if id
            find_by_id(id)
        else
            new(name: name, breed: breed).save
        end
    end

    def self.find_by_name (name)
        sql_name = <<-SQL
            SELECT * 
            FROM dogs
            WHERE name = ?
        SQL
        attributes = DB[:conn].execute(sql_name, name).flatten
        new_from_db(attributes)
    end

    def update 
        sql_update = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = #{id}
        SQL
        DB[:conn].execute(sql_update, name, breed)
    end

end
