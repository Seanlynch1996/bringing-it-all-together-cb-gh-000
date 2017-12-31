class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (? , ?);
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    Dog.new(name: self.name, breed: self.breed, id: self.id)
  end

  def self.create(name:, breed:)
    obj = Dog.new(name: name, breed: breed)
    obj.save
    obj
  end

  def find_by_id(val)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1
      SQL
    self.new_from_db(DB[:conn].execute(sql, val)[0])
  end

  def self.new_from_db(row)
    obj = Dog.new
    obj.id = row[0]
    obj.name = row[1]
    obj.breed = row[2]
    obj
  end


end
