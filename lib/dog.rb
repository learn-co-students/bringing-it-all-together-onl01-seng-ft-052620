class Dog

    attr_accessor :name,:breed
    attr_reader :id

    def initialize(id:nil,name:,breed:)
        @id=id
        @name=name
        @breed=breed
    end

    def self.create(name:,breed:)
        dog = self.new(name:name,breed:breed)
        dog.save
    end

    def self.find_or_create_by(name:,breed:)
        sql=<<-SQL
        SELECT * FROM dogs
        WHERE name=? AND breed=?
        LIMIT 1
        SQL

        search = DB[:conn].execute(sql,[name,breed])

        if !search.empty?
            self.new_from_db(search.first)
        else
            self.create(name:name,breed:breed)
        end
    end

    # INSTANCE METHODS
    def update()
        sql=<<-SQL
        UPDATE dogs
        SET name=?,breed=?
        WHERE id=?
        SQL

        DB[:conn].execute(sql,[self.name,self.breed,self.id])
        self
    end

    def insert()
        sql=<<-SQL
        INSERT INTO dogs (name,breed)
        VALUES (?,?)
        SQL

        DB[:conn].execute(sql,self.name,self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def save()
        if self.id
            self.update
        else
            self.insert
        end
    end

    # CLASS METHODS

    ## Constructors
    def self.new_from_db(row)
        Dog.new(id:row[0],name:row[1],breed:row[2])
    end

    def self.find_by_name(name)
        sql=<<-SQL
        SELECT * FROM dogs
        WHERE name=?
        LIMIT 1
        SQL

        DB[:conn].execute(sql,name).map {|row| self.new_from_db(row)}.first
    end

    def self.find_by_id(id)
        sql=<<-SQL
        SELECT * FROM dogs
        WHERE id=?
        SQL

        DB[:conn].execute(sql,id).map {|row| self.new_from_db(row)}.first
    end

    ## Database Related

    def self.create_table
        sql=<<-SQL
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
    
end