from flask_login import UserMixin
from datetime import datetime, timedelta
from extensions import db, login_manager
from sqlalchemy import Numeric
import json

class User(UserMixin, db.Model):
    # 用户模型类，继承自UserMixin和db.Model
    # 定义用户相关信息，包括用户名、邮箱、密码等
    # 以及用户与订单的关系
    __tablename__ = 'user'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(128), nullable=False)
    phone = db.Column(db.String(20))
    address = db.Column(db.Text)
    img = db.Column(db.String(200), default='/static/images/default-avatar.png')
    is_admin = db.Column(db.Boolean, default=False)
    status = db.Column(db.String(20), default='active')  # active, disabled
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 修改关系定义，明确指定外键关系
    orders = db.relationship('Order', backref='user', lazy=True)
    
    def set_password(self, password):
        """设置用户密码"""
        self.password = password
        
    def check_password(self, password):
        """检查密码是否正确"""
        return self.password == password

    @property
    def display_phone(self):
        """返回格式化的电话号码，如果未设置则返回'未设置'"""
        return self.phone if self.phone else '未设置'

    @property
    def display_address(self):
        """返回格式化的地址，如果未设置则返回'未设置'"""
        return self.address if self.address else '未设置'

    def update_profile(self, username=None, email=None, phone=None, address=None):
        """更新用户资料"""
        if username is not None:
            self.username = username
        if email is not None:
            self.email = email
        if phone is not None:
            self.phone = phone
        if address is not None:
            self.address = address

    def to_dict(self):
        """将用户信息转换为字典格式，用于API响应"""
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'phone': self.display_phone,
            'address': self.display_address,
            'is_admin': self.is_admin
        }

    @property
    def status_text(self):
        """返回用户状态的中文描述"""
        status_map = {
            'active': '正常',
            'disabled': '禁用'
        }
        return status_map.get(self.status, '未知')

    @property
    def status_color(self):
        """返回用户状态对应的Bootstrap颜色类"""
        status_map = {
            'active': 'success',
            'disabled': 'danger'
        }
        return status_map.get(self.status, 'secondary')

class Category(db.Model):
    # 商品分类模型类
    # 定义商品分类信息，包括分类名称和描述
    __tablename__ = 'category'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # 定义关系
    products = db.relationship('Product', backref='category', lazy=True)

class Product(db.Model):
    # 商品模型类
    # 定义商品相关信息，包括名称、描述、价格、库存等
    # 以及商品与订单项和评论的关系
    __tablename__ = 'product'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    price = db.Column(Numeric(10,2), nullable=False)
    stock = db.Column(db.Integer, nullable=False)
    category_id = db.Column(db.Integer, db.ForeignKey('category.id'), nullable=False)
    image_url = db.Column(db.String(200))
    status = db.Column(db.Enum('active', 'inactive'), default='active')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 定义关系
    order_items = db.relationship('OrderItem', back_populates='product', lazy=True)
    comments = db.relationship('Comment', back_populates='product', lazy=True)

    @property
    def average_rating(self):
        """计算商品平均评分"""
        if not self.comments:
            return 0
        return round(sum(comment.rating for comment in self.comments) / len(self.comments), 1)

class Order(db.Model):
    # 订单模型类
    # 定义订单相关信息，包括订单号、用户ID、状态等
    # 以及订单与订单项的关系
    __tablename__ = 'order'
    
    id = db.Column(db.Integer, primary_key=True)
    order_number = db.Column(db.String(20), unique=True, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)  # 修改这里，确保表名正确
    status = db.Column(db.Enum('pending', 'paid', 'shipped', 'delivered', 'cancelled'), default='pending')
    total_amount = db.Column(Numeric(10,2), nullable=False)
    payment_method = db.Column(db.String(50))
    shipping_address = db.Column(db.Text)
    shipping_phone = db.Column(db.String(20))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 定义关系
    items = db.relationship('OrderItem', backref='order', lazy=True)

class OrderItem(db.Model):
    # 订单项模型类
    # 定义订单项相关信息，包括订单ID、商品ID、数量、价格等
    __tablename__ = 'order_item'
    
    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.Integer, db.ForeignKey('order.id'), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    price = db.Column(Numeric(10,2), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # 定义关系
    product = db.relationship('Product', back_populates='order_items', lazy=True)

class Cart(db.Model):
    # 购物车模型类
    # 定义购物车相关信息，包括用户ID、商品ID、数量等
    # 以及购物车与商品和用户的关系
    __tablename__ = 'cart'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    quantity = db.Column(db.Integer, nullable=False, default=1)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # 定义与 Product 的关系
    product = db.relationship('Product', backref='cart_items', lazy=True)
    # 定义与 User 的关系
    user = db.relationship('User', backref='cart_items', lazy=True)

class Comment(db.Model):
    # 商品评论模型类
    # 定义商品评论相关信息，包括内容、评分、用户ID、商品ID等
    # 以及评论与商品和用户的关系
    __tablename__ = 'comment'
    
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    rating = db.Column(db.Integer, nullable=False)  # 评分 1-5
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now())  # 直接使用当前时间（中国时区）
    
    # 定义关系
    user = db.relationship('User', backref='comments', lazy=True)
    product = db.relationship('Product', back_populates='comments', lazy=True)

class SystemSettings(db.Model):
    # 系统设置模型类
    # 定义系统设置相关信息，包括设置键、值、描述等
    # 以及获取和设置系统设置的方法
    __tablename__ = 'system_settings'
    
    id = db.Column(db.Integer, primary_key=True)
    setting_key = db.Column(db.String(50), unique=True, nullable=False)
    setting_value = db.Column(db.Text)
    setting_description = db.Column(db.Text)
    setting_type = db.Column(db.Enum('text', 'number', 'boolean', 'json'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    @staticmethod
    def get_setting(key, default=None):
        """获取系统设置值"""
        setting = SystemSettings.query.filter_by(setting_key=key).first()
        if not setting:
            return default
            
        if setting.setting_type == 'boolean':
            return setting.setting_value.lower() == 'true'
        elif setting.setting_type == 'number':
            return float(setting.setting_value)
        elif setting.setting_type == 'json':
            return json.loads(setting.setting_value)
        else:
            return setting.setting_value
            
    @staticmethod
    def set_setting(key, value, description=None):
        """设置系统设置值"""
        setting = SystemSettings.query.filter_by(setting_key=key).first()
        if not setting:
            setting = SystemSettings(setting_key=key)
            
        if isinstance(value, bool):
            setting.setting_type = 'boolean'
            setting.setting_value = str(value).lower()
        elif isinstance(value, (int, float)):
            setting.setting_type = 'number'
            setting.setting_value = str(value)
        elif isinstance(value, (list, dict)):
            setting.setting_type = 'json'
            setting.setting_value = json.dumps(value)
        else:
            setting.setting_type = 'text'
            setting.setting_value = str(value)
            
        if description:
            setting.setting_description = description
            
        db.session.add(setting)
        db.session.commit()
        
    def to_dict(self):
        """将设置转换为字典格式，用于API响应"""
        return {
            'id': self.id,
            'key': self.setting_key,
            'value': self.setting_value,
            'description': self.setting_description,
            'type': self.setting_type,
            'updated_at': self.updated_at.strftime('%Y-%m-%d %H:%M:%S')
        }

@login_manager.user_loader
def load_user(user_id):
    """用户加载器，用于Flask-Login"""
    return User.query.get(int(user_id))