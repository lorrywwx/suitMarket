from flask import render_template, request
from flask_login import current_user
from models.models import SystemSettings

def check_maintenance_mode():
    """
    检查系统是否处于维护模式的中间件函数
    """
    # 允许访问的路径列表
    allowed_paths = [
        '/login',  # 登录页面
        '/logout',  # 登出页面
        '/admin',  # 管理后台路径
        '/static'  # 静态资源路径
    ]
    
    # 检查当前路径是否在允许列表中
    if any(request.path.startswith(path) for path in allowed_paths):
        return None
    
    # 如果是管理员，允许访问所有页面
    if current_user.is_authenticated and current_user.is_admin:
        return None
    
    # 检查维护模式状态
    maintenance_mode = SystemSettings.get_setting('maintenance_mode')
    if maintenance_mode and maintenance_mode.lower() == 'true':
        # 获取维护相关信息
        maintenance_end_time = SystemSettings.get_setting('maintenance_end_time', '')
        contact_email = SystemSettings.get_setting('contact_email', '')
        contact_phone = SystemSettings.get_setting('contact_phone', '')
        
        # 返回维护页面
        return render_template('maintenance.html',
                            maintenance_end_time=maintenance_end_time,
                            contact_email=contact_email,
                            contact_phone=contact_phone)
    
    return None 