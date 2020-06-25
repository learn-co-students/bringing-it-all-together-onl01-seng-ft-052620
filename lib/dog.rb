class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-sql
        CREATE TABLE dogs(
            id INTEGER
            name TEXT
            breed TEXT
        );
        sql

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        if self.id
          self.update
        else
          sql = <<-sql
          INSERT INTO dogs(name, breed)
          VALUES(?,?)
          sql
          DB[:conn].execute(sql,self.name,self.breed)
          @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
          self
        end
    end

    def update
        sql = <<-sql
        UPDATE dogs SET name = ?,
        breed = ?
        WHERE ID = ?
        sql
        DB[:conn].execute(sql,self.name,self.breed,self.id)
    end

    def self.create(name:,breed:)
        dog = self.new(name:name,breed:breed)
        dog.save
    end

    def self.new_from_db(row)
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_id(id)
        sql = <<-sql
        SELECT * FROM dogs
        WHERE id = ?
        sql
        DB[:conn].execute(sql,id).map {|row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT*FROM dogs WHERE name = ? AND breed = ?",name,breed)

        if !dog.empty?
            id = dog[0][0]
            Dog.find_by_id(id)
        else
            dog = self.create(name:name,breed:breed)
        end
    end

    def self.find_by_name(name)
        sql = <<-sql
        SELECT * FROM dogs
        WHERE name = ?
        sql

        DB[:conn].execute(sql,name).map do|row|
            self.new_from_db(row)
        end.first
    end










end