class UsersController < ApplicationController
  before_action :authenticate!
  before_action :authenticate_studi_user!, only: :studi

  def show
    @since = (params[:since] || 4).to_i
    @display = %w(cluster multi).delete(params[:display]) || 'cluster'
    @notices = current_user.notices.shared.since(@since.weeks.ago)
    @positions = current_user.leaderboard_positions
  end

  def edit
  end

  def signature
    current_user.update!(signature_params)

    redirect_to edit_user_path, notice: 'Unterschrift wurde gespeichert'
  end

  def destroy_signature
    current_user.update!(signature: nil)

    redirect_to edit_user_path, notice: 'Unterschrift wurde entfernt'
  end

  def update
    current_user.assign_attributes(user_params)

    if current_user.email_changed?
      current_user.validation_date = nil
      if current_user.save
        UserMailer.validate(current_user).deliver_later
        redirect_to edit_user_path, notice: t('users.profile_updated_and_confirmation_email')
      else
        redirect_to edit_user_path, alert: current_user.errors.full_messages.to_sentence
      end
    else
      current_user.save!

      redirect_to edit_user_path, notice: t('users.profile_updated')
    end
  end

  def confirmation_mail
    UserMailer.validate(current_user).deliver_later

    redirect_to edit_user_path, notice: t('users.confirmation_mail', email: current_user.email)
  end

  def studi
    @exports = Export.for_studis
  end

  def destroy
    current_user.destroy!
    sign_out

    redirect_to root_path, notice: t('users.destroyed')
  end

  private

  def signature_params
    params.require(:user).permit(:signature)
  end

  def user_params
    params.require(:user).permit([:email, :nickname, :name, :street, :zip, :city, :appendix, :date_of_birth, :phone] + User.bitfields[:flags].keys)
  end
end
