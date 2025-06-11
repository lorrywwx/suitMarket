# 导入必要的模块
from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_user, logout_user, login_required, current_user
from models.models import User
from extensions import db
from functools import wraps

# 创建认证相关的蓝图
auth_bp = Blueprint('auth', __name__)

# 装饰器：检查用户状态
def check_user_status(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # 如果用户已登录且状态为禁用，则强制登出
        if current_user.is_authenticated and current_user.status == 'disabled':
            logout_user()
            flash('您的账号已被禁用，请联系管理员', 'danger')
            return redirect(url_for('auth.login'))
        return f(*args, **kwargs)
    return decorated_function

# 用户注册路由
@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        # 获取表单提交的用户名和密码
        username = request.form.get('username')
        password = request.form.get('password')
        
        # 检查用户名是否已存在
        if User.query.filter_by(username=username).first():
            flash('用户名已存在')
            return redirect(url_for('auth.register'))
            
        # 创建新用户并保存到数据库
        user = User(username=username)
        user.set_password(password)
        db.session.add(user)
        db.session.commit()
        
        flash('注册成功！')
        return redirect(url_for('auth.login'))
        
    # GET请求时显示注册页面
    return render_template('auth/register.html')

# 用户登录路由
@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        # 获取表单提交的用户名和密码
        username = request.form.get('username')
        password = request.form.get('password')
        user = User.query.filter_by(username=username).first()
        
        # 验证用户名和密码
        if user and user.check_password(password):
            # 检查用户是否被禁用
            if user.status == 'disabled':
                flash('您的账号已被禁用，请联系管理员', 'danger')
                return render_template('auth/login.html')
                
            # 登录用户并根据角色重定向
            login_user(user)
            if user.is_admin:
                return redirect(url_for('admin.admin_index'))
            return redirect(url_for('main.index'))
            
        flash('用户名或密码错误')
        
    # GET请求时显示登录页面
    return render_template('auth/login.html')

# 用户登出路由
@auth_bp.route('/logout')
@login_required  # 需要登录才能访问
def logout():
    logout_user()
    return redirect(url_for('main.index')) 