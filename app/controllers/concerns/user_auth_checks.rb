module UserAuthChecks
 #以下extendは必須
  extend ActiveSupport::Concern

  def login_check
    if current_admin.present?
      flash[:alert] = '一度ログアウトしてからアクセスして下さい'
      redirect_to(admins_root_path)
    elsif current_student.present?
      flash[:alert] = '一度ログアウトしてからアクセスして下さい'
      redirect_to(students_root_path(current_student.admin.sap_key))
    elsif current_laboratory.present?
      flash[:alert] = '一度ログアウトしてからアクセスして下さい'
      redirect_to(laboratories_root_path(current_laboratory.admin.sap_key))
    end
  end

  # devise sessions only
  def student_check!
    admin_check_user!
    laboratory_check_user!
  end
  def laboratory_check!
    admin_check_user!
    student_check_user!
  end

  private

  def admin_check_user!
    if admin_signed_in?
      flash[:alert] = '管理者アカウントから一度ログアウトしてからログインし直して下さい'
      redirect_to(admins_root_path)
    end
  end

  def student_check_user!
    if student_signed_in?
      flash[:alert] = '学生アカウントから一度ログアウトしてからログインし直して下さい'
      redirect_to(students_root_path(@sap_key))
    end
  end

  def laboratory_check_user!
    if laboratory_signed_in?
      flash[:alert] = '研究室アカウントから一度ログアウトしてからログインし直して下さい'
      redirect_to(laboratories_root_path(@sap_key))
    end
  end

end