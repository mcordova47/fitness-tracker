# frozen_string_literal: true

# The controller for the workouts API
class WorkoutsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action do
    @user_id = params[:user_id]
    @user = User.find_by(slug: @user_id)
    next head(:not_found) unless @user

    session[:user_id] = @user_id
  end

  def progress = nil

  def workout
    @muscle_groups = @user.muscle_groups.order(:name)
    @exercise_kinds = @user.exercise_kinds.order(:kind)
  end

  def sessions
    respond_to do |format|
      format.json { render json: @user.workout_sessions.order(:date) }
    end
  end

  def todays_session
    session = @user.workout_sessions.find_by(date: Time.zone.today)
    respond_to do |format|
      format.json { render json: session }
    end
  end

  def last_session # rubocop:disable Metrics/MethodLength
    session =
      @user
      .workout_sessions
      .where(
        date: ...Time.zone.today,
        muscle_group: params[:muscle_group]
      ).order(date: :desc)
      .first
    respond_to do |format|
      format.json { render json: session }
    end
  end

  def max_set # rubocop:disable Metrics/MethodLength
    set =
      ::Workouts::Set
      .joins(exercise: %i[session exercise_kind])
      .where(
        workouts_exercises: {
          workouts_sessions: { user_id: @user.id },
          workouts_exercise_kinds: { kind: params[:kind] }
        }
      ).order(weight: :desc)
      .first
    respond_to do |format|
      format.json { render json: set }
    end
  end

  def last_exercise # rubocop:disable Metrics/MethodLength
    exercise =
      ::Workouts::Exercise
      .includes(:exercise_kind, session: [:user])
      .where(
        session: {
          user: @user,
          date: ...Time.zone.today
        },
        exercise_kind: { kind: params[:kind] }
      ).order(date: :desc)
      .first
    respond_to do |format|
      format.json { render json: exercise }
    end
  end

  def create_session
    muscle_group = @user.muscle_groups.find_or_create_by!(name: params[:muscle_group])
    session = @user.workout_sessions.create!(date: Time.zone.today, muscle_group: muscle_group)
    respond_to do |format|
      format.json { render json: session }
    end
  end

  def create_exercise
    exercise_kind = @user.exercise_kinds.find_or_create_by!(kind: params[:exercise_kind])
    exercise =
      @user
      .workout_sessions
      .find_by(date: Time.zone.today)
      .exercises
      .create!(exercise_kind: exercise_kind)

    respond_to do |format|
      format.json { render json: exercise }
    end
  end

  def add_set
    exercise = ::Workouts::Exercise.find(params[:exercise_id])
    return head(:not_found) unless exercise.session.user == @user

    set = exercise.sets.create!(reps: params[:reps], weight: params[:weight])

    respond_to do |format|
      format.json { render json: set.exercise }
    end
  end

  def update_set
    set = ::Workouts::Set.find(params[:id])
    return head(:not_found) unless set.exercise.session.user == @user

    set.update!(reps: params[:reps], weight: params[:weight])

    respond_to do |format|
      format.json { render json: set.exercise }
    end
  end

  def copy_exercises_to_today # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    from_session = @user.workout_sessions.find(params[:session_id])
    return head(:not_found) unless from_session

    to_session = @user.workout_sessions.find_by(date: Time.zone.today)
    return head(:not_found) unless to_session
    return head(:not_found) if to_session.exercises.exists?

    from_session.exercises.each do |exercise|
      to_session.exercises.create!(exercise_kind: exercise.exercise_kind)
    end

    respond_to do |format|
      format.json { render json: to_session }
    end
  end

  def delete_exercise
    exercise = ::Workouts::Exercise.find(params[:exercise_id])
    return head(:not_found) unless exercise&.session&.user&.slug == @user_id

    exercise.delete
    respond_to do |format|
      format.json { render json: nil }
    end
  end
end
