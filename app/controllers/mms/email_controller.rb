# -*- coding: utf-8 -*-
require 'fileutils'
class Mms::EmailController < Mms::MmsBackEndController
  
  def index
    @emails = Mms::Email.paginate(:per_page => 18,:page => params[:page], :order => "created_at DESC")
  end
  
  def new
    if params[:id].blank?
      
    else
      @email = Mms::Email.find_by_id(params[:id])
    end
  end
  
  def save
    if params[:email].blank?
      flash[:notice] = "新建邮件失败!"
    else
      email = Mms::Email.new
      errors = email.create_email(params[:email])
      if errors.blank?
        flash[:notice] = "新建邮件成功!"
        redirect_to :action => "new", :id => email.id
      else
        flash_error_message(errors)
      end
    end
  end
  
  def create
    @email = Mms::Email.new(params[:email])
    if @email.save
      flash[:notice] = "新建邮件成功!"
      redirect_to :action => :index
    else
      @email.errors
      render :action => :new
    end
  end
  
  def edit
    if params[:id].blank?
      flash[:notice] = "没有该邮件！"
    else
      @email = Mms::Email.find_by_id(params[:id])
    end
  end
  
  def update
    if params[:email].blank?
      flash[:notice] = "修改邮件失败！"
    else
      email = Mms::Email.find(params[:id])
      if email.state == "draft" or email.state == "finish" or email.state == "stop"
        errors = email.update_email(params[:email])
        if errors.blank?
          flash[:notice] = "修改邮件成功!"
          redirect_to :action => "edit", :id => email.id
        else
          flash_error_message(errors)
        end
      else
        flash[:notice] = "只有未发送、发送完成、停止发送的邮件才能修改！"
        redirect_to :back
      end
    end
  end
  
  def delete
    if params[:id].blank?
      flash[:notice] = "删除邮件失败！"
      redirect_to :action => "index"
    else
      email = Mms::Email.find(params[:id])
      errors = email.delete_email
      if errors.blank?
        flash[:notice] = "删除邮件成功!"
        redirect_to :action => "index"
      else
        flash_error_message(errors)
      end
    end
  end
  
  def preview
    if params[:id].blank?
      flash[:notice] = "请先保存邮件！"
      redirect_to :back
    else
      @email = Mms::Email.find_by_id(params[:id])
    end
  end
  
  def show_address
    if params[:id].blank?
      flash[:notice] = "请先保存邮件！"
      redirect_to :back
    else
      @email = Mms::Email.find_by_id(params[:id])
      @email.update_attribute(:ignore_email_type , params[:ignore_email_type]) if @email.ignore_email_type != params[:ignore_email_type]
      if @email.ignore_email_type == ""
        @users = @email.show_address().paginate(:per_page => 25,:page => params[:page])
      else
        user_emails = []
        users = @email.show_address()
        for user in users
          if (user.email =~ /#{@email.ignore_email_type}/).nil?
            user_emails << user
          end
        end
        @users = user_emails.paginate(:per_page => 25,:page => params[:page])
      end
    end
  end
  
  def update_address
    if params[:id].blank? or params[:flag].blank?
      flash[:notice] = "请先保存邮件！"
      redirect_to :back
    else
      email = Mms::Email.find_by_id(params[:id])
      if email.state == "draft" or email.state == "finish" or email.state == "stop"
        errors = email.update_address(params[:flag])
        if errors.blank?
          flash[:notice] = "修改收件人成功!"
          redirect_to :back
        else
          flash_error_message(errors)
        end
      else
        flash[:notice] = "只有未发送、发送完成、停止发送的邮件才能修改收件人！"
        redirect_to :back
      end
    end
  end
  
  def send_email
    if params[:id].blank?
      flash[:notice] = "请先保存邮件！"
      redirect_to :back
    else
      email = Mms::Email.find(params[:id])
      errors = email.sent_email
      if errors.blank?
        flash[:notice] = "发送邮件成功!"
        redirect_to :back
      else
        flash_error_message(errors)
      end
    end
  end
  
  def send_email_now
    if params[:id].blank?
      flash[:notice] = "请先保存邮件！"
      redirect_to :back
    else
      email = Mms::Email.find(params[:id])
      notice = email.send_email_now
      flash[:notice] = notice
      redirect_to :back
    end
  end
  
  def pause
    if params[:id].blank?
      flash[:notice] = "请先保存邮件！"
      redirect_to :back
    else
      email = Mms::Email.find(params[:id])
      if email.pause
        flash[:notice] = "邮件暂停发送成功！"
        redirect_to :back
      else
        flash[:notice] = "邮件暂停发送失败！"
        redirect_to :back
      end
    end
  end
  
  def stop
    if params[:id].blank?
      flash[:notice] = "请先保存邮件！"
      redirect_to :back
    else
      email = Mms::Email.find(params[:id])
      if email.stop
        email.line_numbers = 1
        if email.save
          flash[:notice] = "邮件停止发送成功！"
          redirect_to :back
        else
          flash[:notice] = email.errors
          redirect_to :back
        end        
      else
        flash[:notice] = "邮件停止发送失败！"
        redirect_to :back
      end
    end
  end
  
  def flash_error_message(errors)  # => 错误提示信息
    error = "共有#{errors.count}个错误；"
    errors.each do |attr, msg|
      error += "#{attr}:#{msg};"
    end
    flash[:notice] = error
    redirect_to :back
  end
  
  def tuan_email
    @email = Mms::Email.find(params[:id])
    render :layout => false
  end
  
end
