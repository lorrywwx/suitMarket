"""
初始化Flask SQLAlchemy。
SQLAlchemy是一个ORM框架，用于将Python对象映射到数据库表。
"""
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

"""
导入用户和订单模型。
这些模型定义了数据库中的表结构，并在其他模块中使用。
"""
from .user import User
from .models import Order