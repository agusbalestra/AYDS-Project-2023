require_relative 'question'
require_relative 'correct_questions'

class User < ActiveRecord::Base
  has_many :correct_questions
  has_many :questions, through: :correct_questions

  has_secure_password

  validates :name, presence: true, uniqueness: true, length: { in: 3..20 }
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "debe ser una dirección de correo electrónico válida" } # verifica que haya un caracter antes y dsp del @
  validates :password, presence: true, length: { minimum: 4, too_short: "te queres ir hackeado?" }
  validates :password, presence: true, length: { minimum: 4, too_short: "te queres ir hackeado?" }, unless: :auth_with_google
  
  validate :password_match, unless: :auth_with_google
  after_initialize :set_default_points

  attr_accessor :reppw
  attr_accessor :auth_with_google

  def set_default_points
    self.points ||= 0
  end

  def points_treatment(correct, diff)
    if correct
      self.sum_points(diff)
      self.level_treatment
    else
      self.rest_points(diff)
    end
  end


  def sum_points(diff)
    new_points = self.points
    if (diff == 1)
      new_points += 10
    elsif (diff == 2)
      new_points += 20
    elsif (diff == 3)
      new_points += 30 
    end
    self.update_attribute :points, new_points
  end
  
  def rest_points(diff)
    new_points = self.points
    if (diff == 1)
      new_points -= 10
    elsif (diff == 2)
      new_points -= 20
    elsif (diff == 3)
      new_points += 30 
    end
    self.update_attribute :points, new_points
  end

  def level_treatment
    Level.all.each do |level|
      questions_for_level = Question.where(levels_id: level.id)
      p questions_for_level
      if questions_for_level.all? { |q| CorrectQuestions.exists?(question_id: q.id, user_id: self.id) }
        self.update_attribute :current_level, level.id
      end
    end
  end

end
