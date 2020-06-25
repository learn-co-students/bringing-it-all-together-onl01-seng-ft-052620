class Dog

    attr_accessor :id, :name, :breed

    def initialize(attributes)
        attributes.each{|key,value| self.send(("#{key}="),value)}
    end

    def self.create_table
        sql =<<-SQL
        CREATE TABLE dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
    
        SQL
    
        DB[:conn].execute(sql)
    end
    
    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        new_attr = {id: row[0], name: row[1], breed: row[2]}
        self.new(new_attr)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
        data = DB[:conn].execute(sql,id)
        self.new_from_db(data[0])
    end

    def self.find_or_create_by(attributes)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new_from_db(dog_data)
        else
            dog = self.create(attributes)
        end
        dog
    end

    def self.create(attributes)
        new_dog = Dog.new(attributes)
        new_dog.save
        new_dog
    end
    
    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        SQL
        data = DB[:conn].execute(sql,name)
        self.new_from_db(data[0])
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ?
        SQL
        DB[:conn].execute(sql,self.name,self.breed)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)

            SQL

            DB[:conn].execute(sql,self.name,self.breed)

            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

end

