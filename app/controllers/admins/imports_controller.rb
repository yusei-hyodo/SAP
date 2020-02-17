class Admins::ImportsController < Admins::ApplicationController
  def new
  end

  def csv
    # csv file ckeck
    unless params[:csv_file_laboratory] || params[:csv_file_student]
      error_messages = ['最低でもどちらか一方のcsvファイルを選択してください']
      flash[:error_messages] = error_messages
      redirect_back(fallback_location: root_path) and return
    end

    # csv import
    flash_notice_messages = []
    admin_id = current_admin.id
    # laboratory
    if params[:csv_file_laboratory]
      begin
        current_admin.laboratory.csv_import(csv_file_laboratory_params, admin_id)
      rescue ActiveRecord::RecordNotUnique
        flash[:error_messages] = ['研究室データをもう一度確認して下さい',
                                  'すでに登録されているEメールが存在します',
                                  '別のアカウントで登録されているEメールの可能性があります',
                                  'その場合は別のEメールを使用するか、当サービスの運営者までお問い合わせください！']
        redirect_back(fallback_location: root_path) and return
      rescue => e
        flash[:error_messages] = ['研究室データをもう一度確認して下さい', e.message]
        redirect_back(fallback_location: root_path) and return
      end
      flash_notice_messages.push('研究室のcsvファイルのインポート成功')
    end
    # student
    if params[:csv_file_student]
      begin
        current_admin.student.csv_import(csv_file_student_params, admin_id)
      rescue ActiveRecord::RecordNotUnique
        flash[:error_messages] = ['研究室データをもう一度確認して下さい',
                                  'すでに登録されているEメールが存在します',
                                  '別のアカウントで登録されているEメールの可能性があります',
                                  'その場合は別のEメールを使用するか、当サービスの運営者までお問い合わせください！']
        redirect_back(fallback_location: root_path) and return
      rescue => e
        flash[:notices] = flash_notice_messages
        flash[:error_messages] = ['学生データをもう一度確認して下さい', e.message]
        redirect_back(fallback_location: root_path) and return
      end
      flash_notice_messages.push('学生のcsvファイルのインポート成功')
    end
    flash[:notices] = flash_notice_messages
    redirect_to(admins_root_path)
  end

  def excel
    # file ckeck
    unless xlsx_file_params
      error_messages = ['ファイルを選択してください']
      flash[:error_messages] = error_messages
      redirect_back(fallback_location: root_path) and return
    end
    file = Roo::Spreadsheet.open(xlsx_file_params.path)
    admin_id = current_admin.id
    file.each_with_pagename do |name, sheet|
      case name
      when '学生' then
        begin
          current_admin.student.xlsx_import(sheet, admin_id)
        rescue ActiveRecord::RecordNotUnique
          flash[:error_messages] = ['学生データをもう一度確認して下さい',
                                    'すでに登録されているEメールが存在します',
                                    '別のアカウントで登録されているEメールの可能性があります',
                                    'その場合は別のEメールを使用するか、当サービスの運営者までお問い合わせください！']
          redirect_back(fallback_location: root_path) and return
        rescue => e
          flash[:error_messages] = ['学生データをもう一度確認して下さい', e.message]
          redirect_back(fallback_location: root_path) and return
        end
      when '研究室' then
        begin
          current_admin.laboratory.xlsx_import(sheet, admin_id)
        rescue ActiveRecord::RecordNotUnique
          flash[:error_messages] = ['研究室データをもう一度確認して下さい',
                                    'すでに登録されているEメールが存在します',
                                    '別のアカウントで登録されているEメールの可能性があります',
                                    'その場合は別のEメールを使用するか、当サービスの運営者までお問い合わせください！']
          redirect_back(fallback_location: root_path) and return
        rescue => e
          flash[:error_messages] = ['研究室データをもう一度確認して下さい', e.message]
          redirect_back(fallback_location: root_path) and return
        end
      end
    end
    redirect_to(admins_root_path)
  end

  private

  def csv_file_laboratory_params
    params.require(:csv_file_laboratory)
  end

  def csv_file_student_params
    params.require(:csv_file_student)
  end

  def xlsx_file_params
    params.require(:xlsx_file)
  end
end
