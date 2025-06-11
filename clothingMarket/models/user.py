# 导入Flask-Login的UserMixin类，用于处理用户会话
from flask_login import UserMixin
# 导入Werkzeug的安全模块，用于生成和验证密码哈希
from werkzeug.security import generate_password_hash, check_password_hash
# 导入数据库实例
from . import db
# 导入datetime模块，用于处理时间相关数据
from datetime import datetime

# 定义用户模型类，继承自UserMixin和db.Model
class User(UserMixin, db.Model):
    # 指定数据库表名为'users'
    __tablename__ = 'users'
    
    # 定义用户ID字段，整数类型，主键
    id = db.Column(db.Integer, primary_key=True)
    # 定义用户名字段，字符串类型，最大长度80，唯一且不能为空
    username = db.Column(db.String(80), unique=True, nullable=False)
    # 定义邮箱字段，字符串类型，最大长度120，唯一且不能为空
    email = db.Column(db.String(120), unique=True, nullable=False)
    # 定义密码哈希字段，字符串类型，最大长度128
    password_hash = db.Column(db.String(128))
    # 定义电话字段，字符串类型，最大长度20
    phone = db.Column(db.String(20))
    # 定义地址字段，文本类型
    address = db.Column(db.Text)
    # 定义是否为管理员字段，布尔类型，默认值为False
    is_admin = db.Column(db.Boolean, default=False)
    # 定义创建时间字段，日期时间类型，默认值为当前时间
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # 定义与订单的关系，使用backref反向引用用户
    orders = db.relationship('Order', backref='user', lazy=True)

    # 定义密码属性，禁止读取
    @property
    def password(self):
        raise AttributeError('password is not a readable attribute')

    # 定义密码设置器，使用Werkzeug生成密码哈希
    @password.setter
    def password(self, password):
        self.password_hash = generate_password_hash(password)

    # 定义密码验证方法，使用Werkzeug验证密码哈希
    def verify_password(self, password):
        return check_password_hash(self.password_hash, password)

    # 定义对象表示方法，返回用户名
    def __repr__(self):
        return f'<User {self.username}>'