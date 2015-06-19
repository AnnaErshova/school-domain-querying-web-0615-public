require 'pry'

class Course

  attr_accessor :id, :name, :department_id

  def department
    #successfully gets department
    Department.find_by_id(self.department_id)
  end # end department

  def department=(department)
    #set department id when deparment is set
    self.department_id = department.id
  end # end setter method

  def students
  #find all students by department_id
    sql = <<-SQL
      SELECT students.*
        FROM courses
          JOIN registrations 
            ON courses.id = registrations.course_id
              JOIN students 
                ON students.id = registrations.student_id
                  WHERE courses.id = ?
    SQL

    outcome = DB[:conn].execute(sql, self.id)

    outcome.map do |row|
      Student.new_from_db(row)
    end # end map block
  end # end students

  def add_student(student)
    #add a student to a particular course and save them
    sql = <<-SQL
      INSERT INTO registrations 
        (course_id, student_id) 
          VALUES 
            (?,?)
    SQL

    DB[:conn].execute(sql, self.id, student.id)
  end # end add_student

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS courses 
      (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        department_id TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end # end create_table

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS courses 
    SQL

    DB[:conn].execute(sql)
  end # end drop_table

  # helper method
  def attribute_values
    [name, department_id]
  end

  def insert
    sql = <<-SQL
      INSERT INTO courses 
        (name, department_id)
          VALUES
            (?,?)
    SQL

    DB[:conn].execute(sql, attribute_values)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM courses")[0][0]
  end

  def self.new_from_db(row)
    self.new.tap do |s|
      s.id = row[0]
      s.name =  row[1]
      s.department_id = row[2]
    end # end tap
  end # end new_from_db

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
        FROM courses
          WHERE name = ?
           LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_all_by_department_id(department_id)
    sql = <<-SQL
      SELECT *
        FROM courses
          WHERE department_id = ?
            LIMIT 1
    SQL

    DB[:conn].execute(sql, department_id).map do |row|
      self.new_from_db(row)
      # binding.pry
    end
  end

  def update
    sql = <<-SQL
      UPDATE courses
        SET name = ?, department_id = ?
          WHERE id = ?
    SQL

    # binding.pry
    DB[:conn].execute(sql, attribute_values, id)
  end # end update

  # helper method
  def persisted?
    !!self.id # double negation turns into true
  end

  def save
    persisted? ? update : insert
  end
end # end Course class
