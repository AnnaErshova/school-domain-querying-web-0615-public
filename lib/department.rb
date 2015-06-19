class Department

attr_accessor :id, :name

  def courses # ReadMe calls this 'course' in singular
    #find all courses by department_id
    Course.find_all_by_department_id(self.id)
  end

  def add_course(course)
    #add a course to a department and save it
    course.department_id = self.id
    course.save
    save
  end # end course method

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS departments (
      id INTEGER PRIMARY KEY,
      name TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end # end create_table

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS departments
    SQL
    
    DB[:conn].execute(sql)
  end # end drop_table

# insert inserts the department into the database
# updates the current instance with the ID of the Department from the database
  def insert
    sql = <<-SQL
      INSERT INTO departments
        (name)
          VALUES
            (?)
    SQL
    DB[:conn].execute(sql, name)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM departments")[0][0]
  end # end insert

  def self.new_from_db(row)
    self.new.tap do |s|
      s.id = row[0]
      s.name = row [1]
    end # end tap
  end # end new from db

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
        FROM departments
          WHERE name = ?
            LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first

  end # end find_by_name

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
        FROM departments
          WHERE id = ?
            LIMIT 1
    SQL

    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end # end find_by_id

  def update
    sql = <<-SQL
      UPDATE departments
        SET name = ?
          WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, id)
  end # end update

  # helper method for save
  def persisted?
    !!self.id # double negation turns into true
  end # end persisted?

  def save
    persisted? ? update : insert
  end # end save


end # end Department class
