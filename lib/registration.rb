class Registration
	attr_accessor :id, :course_id, :student_id

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS registrations
      (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id TEXT,
        student_id TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end # end create_table

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS registrations
    SQL

    DB[:conn].execute(sql)
  end # end drop_table

end # end class 