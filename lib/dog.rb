class Dog

  attr_accessor  :id, :name, :breed

  def initialize(id: nil, name: name, breed: breed)
      @id = id
      @name = name
      @breed = breed
    end

    def self.create_table
      sql = <<-SQL
        create table if not exists dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      sql = <<-SQL
        drop table if exists dogs
      SQL
      DB[:conn].execute(sql)
      end

      def save
        if self.id
          self.update
        else
          sql = <<-SQL
          insert into dogs (name, breed)
          values (?, ?)
          SQL
          DB[:conn].execute(sql, self.name, self.breed)
          self.id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
        end
          self
      end

      def self.create(hash)
        new_dog = Dog.new(hash)
        new_dog.save
      end

      def self.new_from_db(row)
        new_dog = Dog.new(name: row[1] ,breed: row[2])
        new_dog.id = row[0]
        new_dog
      end

      def self.find_or_create_by(name: name, breed: breed)
        sql = <<-SQL
        select * from dogs where name = ? and breed = ?
        SQL
        row = DB[:conn].execute(sql, name, breed)[0]
        if row
          self.new_from_db(row)
        else
          self.create(name: name, breed: breed)
        end
#binding.pry
      end

      def self.find_by_id(id)
        sql= <<-SQL
          select * from dogs where id = ?
        SQL
        row= DB[:conn].execute(sql, id).flatten
        self.new_from_db(row)
      end

      def self.find_by_name(name)
        sql= <<-SQL
          select * from dogs where name = ?
        SQL
        row= DB[:conn].execute(sql, name).flatten
        self.new_from_db(row)
      end

      def update
        sql= <<-SQL
          update dogs set name = ?, breed = ? where id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)

      end

end
