require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  @@all_students = []

  def self.all
    @@all_students
  end

  def self.create_table
    q = <<-SQL
    CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
    DB[:conn].execute(q)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    q = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(q,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.drop_table
    q = 'DROP TABLE students'
    DB[:conn].execute(q)
  end

  def initialize(id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
    self.class.all << self
  end

  def save
    if self.id
      self.update
    else
      q = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?,?)
      SQL
      DB[:conn].execute(q, self.name, self.grade)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students").first.first
    end
  end

  def update
    q = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(q, self.name, self.grade, self.id)
  end

end
