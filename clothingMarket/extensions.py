# 导入所需的扩展
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager

# 数据库实例初始化
# 通过Flask-SQLAlchemy扩展创建数据库实例，用于模型定义和数据库操作
db = SQLAlchemy()

# 登录管理配置
# 初始化Flask-Login扩展，用于用户会话管理
login_manager = LoginManager()
# 设置未登录用户重定向端点（对应auth蓝图的login路由）
login_manager.login_view = 'auth.login'