from flask import Flask
from extensions import db, login_manager
import os
from dotenv import load_dotenv
from models.recommendation import RecommendationSystem
from middleware import check_maintenance_mode

# 加载环境变量（从项目根目录的.env文件）
load_dotenv()

# 应用工厂函数
# 使用工厂模式创建Flask应用实例，便于配置管理、多环境支持和模块化开发
def create_app():
    # 初始化Flask核心对象
    app = Flask(__name__)
    
    # 应用配置说明
    # SECRET_KEY: 用于会话加密，生产环境必须通过环境变量设置
    # SQLALCHEMY_DATABASE_URI: 数据库连接字符串，格式：dialect://user:password@host:port/database
    # SQLALCHEMY_TRACK_MODIFICATIONS: 禁用SQLAlchemy事件系统以提升性能
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev')  # 默认dev密钥仅用于开发环境
    app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 
        'mysql://root:123456@localhost/clothing_market')  # 默认本地开发数据库
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False  # 禁用修改追踪节省内存

    # 初始化扩展组件
    # 数据库扩展初始化（SQLAlchemy实例）
    db.init_app(app)
    # 用户认证扩展初始化（LoginManager实例）
    login_manager.init_app(app)

    # 路由蓝图注册说明
    # 注意注册顺序可能影响URL匹配优先级
    from routes.auth import auth_bp     # 用户认证相关路由
    from routes.admin import admin_bp   # 后台管理路由
    from routes.main import main_bp     # 主站展示路由
    from routes.cart import cart_bp     # 购物车功能路由
    from routes.order import order_bp   # 订单处理路由

    # 应用全局请求钩子
    # 为关键业务路由添加维护模式检查（check_maintenance_mode中间件）
    # 当系统处于维护状态时，这些路由将返回503维护页面
    main_bp.before_request(check_maintenance_mode)   # 主站路由
    cart_bp.before_request(check_maintenance_mode)   # 购物车路由
    order_bp.before_request(check_maintenance_mode)  # 订单路由

    # 注册各功能模块蓝图
    # auth_bp: 用户认证（登录/注册/登出）
    app.register_blueprint(auth_bp)
    # admin_bp: 后台管理（需要管理员权限）
    app.register_blueprint(admin_bp)
    # main_bp: 主站商品展示和搜索
    app.register_blueprint(main_bp)
    # cart_bp: 购物车增删改查操作
    app.register_blueprint(cart_bp)
    # order_bp: 订单创建、支付、状态查询
    app.register_blueprint(order_bp)

    return app

# 应用启动入口
if __name__ == '__main__':
    # 通过工厂函数创建应用实例
    app = create_app()
    
    # 在应用上下文中初始化数据库
    # 使用with语句确保操作在应用上下文内执行
    with app.app_context():
        # 自动创建缺失的数据库表（仅开发环境使用，生产环境应使用迁移工具）
        db.create_all()
    
    # 启动开发服务器
    # debug=True启用调试模式和自动重载，生产环境必须设置为False
    app.run(debug=True)  # 默认监听127.0.0.1:5000