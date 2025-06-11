from flask import Blueprint, render_template, request, redirect, url_for, flash, jsonify
from flask_login import login_required, current_user
from models.models import Product, Category, Order, User, db, OrderItem, SystemSettings, Comment
from models.recommendation import RecommendationSystem, ProductSimilarity, UserBehavior
from functools import wraps
from datetime import datetime, timedelta
from sqlalchemy import func, text
from decimal import Decimal
from werkzeug.utils import secure_filename
import os

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')

def admin_required(f):
    """检查是否是管理员的装饰器"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not current_user.is_authenticated or not current_user.is_admin:
            flash('无权访问此页面', 'danger')
            return redirect(url_for('main.index'))
        return f(*args, **kwargs)
    decorated_function.__name__ = f.__name__
    return decorated_function

@admin_bp.route('/admin')
@admin_required
def admin_index():
    # 获取最近30天的销售数据
    thirty_days_ago = datetime.now() - timedelta(days=30)
    
    # 销售趋势数据
    sales_trend_rows = db.session.execute(text("""
        WITH RECURSIVE date_range AS (
            SELECT :start_date as date
            UNION ALL
            SELECT date + INTERVAL 1 DAY
            FROM date_range
            WHERE date < :end_date
        )
        SELECT 
            DATE_FORMAT(dr.date, '%Y-%m-%d') as date,
            COALESCE(COUNT(DISTINCT o.id), 0) as order_count,
            COALESCE(SUM(o.total_amount), 0) as total_sales
        FROM date_range dr
        LEFT JOIN `order` o ON DATE(o.created_at) = dr.date
        GROUP BY dr.date
        ORDER BY dr.date ASC
    """), {
        'start_date': thirty_days_ago.date(),
        'end_date': datetime.now().date()
    }).fetchall()

    sales_trend = [
        {
            'date': row[0],
            'order_count': int(row[1]),
            'total_sales': float(row[2] or 0)
        }
        for row in sales_trend_rows
    ]
    
    # 热门商品数据 - 基于用户行为统计
    popular_products_rows = db.session.execute(text("""
        SELECT 
            p.id,
            p.name,
            COUNT(*) as view_count,
            SUM(CASE WHEN ub.behavior_type = 'cart' THEN 1 ELSE 0 END) as cart_count,
            p.price
        FROM product p
        LEFT JOIN user_behavior ub ON p.id = ub.product_id
        GROUP BY p.id, p.name, p.price
        ORDER BY view_count DESC
        LIMIT 10
    """)).fetchall()

    popular_products = [
        {
            'name': row[1],
            'sales_count': int(row[2] or 0),  # 使用浏览次数
            'sales_amount': float((row[3] or 0) * row[4])  # 购物车数量 * 价格
        }
        for row in popular_products_rows
    ]
    
    # 分类销售数据 - 基于用户行为统计
    category_sales_rows = db.session.execute(text("""
        SELECT 
            c.name,
            COUNT(*) as view_count,
            SUM(CASE WHEN ub.behavior_type = 'cart' THEN 1 ELSE 0 END) as cart_count,
            AVG(p.price) as avg_price
        FROM category c
        JOIN product p ON c.id = p.category_id
        LEFT JOIN user_behavior ub ON p.id = ub.product_id
        GROUP BY c.id, c.name
        ORDER BY view_count DESC
    """)).fetchall()

    category_sales = [
        {
            'name': row[0],
            'sales_count': int(row[1] or 0),  # 使用浏览次数
            'sales_amount': float((row[2] or 0) * (row[3] or 0))  # 购物车数量 * 平均价格
        }
        for row in category_sales_rows
    ]
    
    # 用户行为数据
    user_behaviors_rows = db.session.execute(text("""
        SELECT 
            behavior_type,
            COUNT(*) as count
        FROM user_behavior
        GROUP BY behavior_type
    """)).fetchall()

    user_behaviors = [
        {
            'behavior_type': row[0],
            'count': int(row[1])
        }
        for row in user_behaviors_rows
    ]

    # 如果用户行为数据为空，添加默认行为类型
    if not user_behaviors:
        user_behaviors = [
            {'behavior_type': 'view', 'count': 0},
            {'behavior_type': 'cart', 'count': 0}
        ]

    # 计算顶部统计数据
    total_orders = sum(item['order_count'] for item in sales_trend)
    total_sales = sum(item['total_sales'] for item in sales_trend)
    total_behaviors = sum(item['count'] for item in user_behaviors)
    total_products = len(popular_products)
    
    return render_template('admin/dashboard.html',
        sales_trend=sales_trend,
        popular_products=popular_products,
        category_sales=category_sales,
        user_behaviors=user_behaviors,
        total_orders=total_orders,
        total_sales=total_sales,
        total_behaviors=total_behaviors,
        total_products=total_products
    )

@admin_bp.route('/admin/products')
@admin_required
def product_list():
    products = Product.query.all()
    return render_template('admin/products.html', products=products)

@admin_bp.route('/admin/product/new', methods=['GET', 'POST'])
@admin_required
def new_product():
    if request.method == 'POST':
        category_name = request.form['category']
        category = Category.query.filter_by(name=category_name).first()
        if not category:
            flash('商品分类不存在')
            return redirect(url_for('admin.new_product'))
            
        product = Product(
            name=request.form['name'],
            description=request.form['description'],
            price=float(request.form['price']),
            stock=int(request.form['stock']),
            category_id=category.id,
            image_url=request.form['image_url']
        )
        db.session.add(product)
        db.session.commit()
        flash('商品添加成功')
        return redirect(url_for('admin.product_list'))
        
    categories = Category.query.all()
    return render_template('admin/new_product.html', categories=categories)

@admin_bp.route('/admin/product/<int:id>/edit', methods=['GET', 'POST'])
@admin_required
def edit_product(id):
    product = Product.query.get_or_404(id)
    if request.method == 'POST':
        category_name = request.form['category']
        category = Category.query.filter_by(name=category_name).first()
        if not category:
            flash('商品分类不存在')
            return redirect(url_for('admin.edit_product', id=id))
            
        product.name = request.form['name']
        product.description = request.form['description']
        product.price = float(request.form['price'])
        product.stock = int(request.form['stock'])
        product.category_id = category.id
        product.image_url = request.form['image_url']
        db.session.commit()
        flash('商品更新成功')
        return redirect(url_for('admin.product_list'))
        
    categories = Category.query.all()
    return render_template('admin/edit_product.html', product=product, categories=categories)

@admin_bp.route('/admin/product/<int:id>/delete')
@admin_required
def delete_product(id):
    product = Product.query.get_or_404(id)
    
    try:
        # 先删除与该商品相关的订单项
        OrderItem.query.filter_by(product_id=id).delete()
        
        # 删除与该商品相关的相似度记录
        ProductSimilarity.query.filter(
            (ProductSimilarity.product_id == id) | 
            (ProductSimilarity.similar_product_id == id)
        ).delete()
        
        # 删除与该商品相关的用户行为记录
        UserBehavior.query.filter_by(product_id=id).delete()
        
        # 删除商品
        db.session.delete(product)
        db.session.commit()
        flash('商品删除成功', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'删除商品失败：{str(e)}', 'error')
    
    return redirect(url_for('admin.product_list'))

@admin_bp.route('/admin/orders')
@admin_required
def orders():
    # 获取筛选参数
    status = request.args.get('status', '')
    page = request.args.get('page', 1, type=int)
    
    # 构建查询
    query = Order.query
    if status:
        query = query.filter_by(status=status)
    
    # 按创建时间倒序排序并分页
    orders = query.order_by(Order.created_at.desc()).paginate(page=page, per_page=10)
    
    # 统计各状态订单数量
    status_counts = {
        'all': Order.query.count(),
        'pending': Order.query.filter_by(status='pending').count(),
        'paid': Order.query.filter_by(status='paid').count(),
        'shipped': Order.query.filter_by(status='shipped').count(),
        'delivered': Order.query.filter_by(status='delivered').count(),
        'cancelled': Order.query.filter_by(status='cancelled').count()
    }
    
    return render_template('admin/orders.html', orders=orders, status=status, status_counts=status_counts)

@admin_bp.route('/admin/order/<int:order_id>')
@admin_required
def order_detail(order_id):
    order = Order.query.get_or_404(order_id)
    return render_template('admin/order_detail.html', order=order)

@admin_bp.route('/admin/order/<int:order_id>/update', methods=['POST'])
@admin_required
def update_order_status(order_id):
    order = Order.query.get_or_404(order_id)
    new_status = request.form.get('status')
    
    # 验证状态是否有效
    valid_statuses = ['pending', 'paid', 'shipped', 'delivered', 'cancelled']
    if new_status not in valid_statuses:
        flash('无效的订单状态', 'error')
        return redirect(url_for('admin.order_detail', order_id=order_id))
    
    # 更新订单状态
    order.status = new_status
    order.updated_at = datetime.utcnow()
    
    try:
        db.session.commit()
        flash('订单状态更新成功', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'更新失败：{str(e)}', 'error')
    
    return redirect(url_for('admin.order_detail', order_id=order_id))

@admin_bp.route('/admin/users')
@login_required
@admin_required
def users():
    page = request.args.get('page', 1, type=int)
    per_page = 10

    # 构建查询
    query = User.query

    # 搜索条件
    username = request.args.get('username')
    if username:
        query = query.filter(User.username.ilike(f'%{username}%'))

    email = request.args.get('email')
    if email:
        query = query.filter(User.email.ilike(f'%{email}%'))

    status = request.args.get('status')
    if status:
        query = query.filter(User.status == status)

    # 分页
    users = query.order_by(User.created_at.desc()).paginate(page=page, per_page=per_page)

    return render_template('admin/users.html', users=users)

@admin_bp.route('/users/<int:user_id>/details')
@login_required
@admin_required
def user_details(user_id):
    user = User.query.get_or_404(user_id)
    
    # 获取用户订单统计
    order_stats = {
        'total': Order.query.filter_by(user_id=user.id).count(),
        'pending': Order.query.filter_by(user_id=user.id, status='pending').count(),
        'paid': Order.query.filter_by(user_id=user.id, status='paid').count(),
        'cancelled': Order.query.filter_by(user_id=user.id, status='cancelled').count(),
        'total_amount': db.session.query(func.sum(Order.total_amount))
                         .filter(Order.user_id == user.id, Order.status == 'paid')
                         .scalar() or 0
    }
    
    # 获取最近5个订单
    recent_orders = Order.query.filter_by(user_id=user.id)\
                       .order_by(Order.created_at.desc())\
                       .limit(5).all()

    return render_template('admin/user_details.html', 
                         user=user, 
                         order_stats=order_stats,
                         recent_orders=recent_orders)

@admin_bp.route('/users/<int:user_id>/disable', methods=['POST'])
@login_required
@admin_required
def disable_user(user_id):
    user = User.query.get_or_404(user_id)
    
    if user.id == current_user.id:
        return jsonify({'message': '不能禁用自己的账户'}), 400
    
    user.status = 'disabled'
    db.session.commit()
    return '', 204

@admin_bp.route('/users/<int:user_id>/enable', methods=['POST'])
@login_required
@admin_required
def enable_user(user_id):
    user = User.query.get_or_404(user_id)
    user.status = 'active'
    db.session.commit()
    return '', 204

@admin_bp.route('/sales')
@login_required
def sales_statistics():
    # 获取时间范围参数，默认显示最近7天
    days = request.args.get('days', '7')
    try:
        days = int(days)
    except ValueError:
        days = 7
    
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)
    
    # 获取每日销售统计
    daily_sales_rows = db.session.execute(text("""
        WITH RECURSIVE date_range AS (
            SELECT :start_date as date
            UNION ALL
            SELECT date + INTERVAL 1 DAY
            FROM date_range
            WHERE date < :end_date
        ),
        daily_stats AS (
            SELECT 
                DATE(created_at) as sale_date,
                COUNT(DISTINCT id) as order_count,
                COALESCE(SUM(total_amount), 0) as total_sales
            FROM `order`
            WHERE DATE(created_at) BETWEEN :start_date AND :end_date
            AND status != 'cancelled'
            GROUP BY DATE(created_at)
        )
        SELECT 
            DATE_FORMAT(dr.date, '%Y-%m-%d') as sale_date,
            COALESCE(ds.order_count, 0) as order_count,
            COALESCE(ds.total_sales, 0) as total_sales
        FROM date_range dr
        LEFT JOIN daily_stats ds ON dr.date = ds.sale_date
        ORDER BY dr.date DESC
    """), {'start_date': start_date.date(), 'end_date': end_date.date()}).fetchall()

    # 转换为可序列化的格式
    daily_sales = []
    for row in daily_sales_rows:
        daily_sales.append([
            row[0],  # 日期已经是格式化的字符串
            row[1] or 0,  # 订单数
            float(row[2] or 0)  # 销售额，转换为float
        ])
    
    # 获取分类销售统计
    category_sales_rows = db.session.execute(text("""
        SELECT 
            COALESCE(c.name, '未分类') as category_name,
            COUNT(DISTINCT o.id) as order_count,
            COALESCE(SUM(oi.quantity * oi.price), 0) as total_amount
        FROM category c
        LEFT JOIN product p ON c.id = p.category_id
        LEFT JOIN order_item oi ON p.id = oi.product_id
        LEFT JOIN `order` o ON oi.order_id = o.id AND o.status != 'cancelled'
        GROUP BY c.id, c.name
        ORDER BY total_amount DESC
    """)).fetchall()

    # 转换为可序列化的格式
    category_sales = []
    for row in category_sales_rows:
        category_sales.append([
            row[0],  # 分类名称
            row[1] or 0,  # 订单数
            float(row[2] or 0)  # 销售额，转换为float
        ])
    
    # 计算总计
    total_orders = sum(row[1] for row in daily_sales)
    total_amount = sum(row[2] for row in daily_sales)
    
    return render_template('admin/sales.html',
                         daily_sales=daily_sales,
                         category_sales=category_sales,
                         total_orders=total_orders,
                         total_amount=total_amount,
                         days=days)

@admin_bp.route('/calculate_similarity', methods=['GET', 'POST'])
@admin_required
def calculate_similarity():
    # 检查是否已有相似度数据
    similarity_exists = ProductSimilarity.query.first() is not None
    
    if request.method == 'POST':
        try:
            RecommendationSystem.calculate_product_similarity()
            flash('商品相似度计算完成，推荐功能已开启', 'success')
            return redirect(url_for('admin.calculate_similarity'))
        except Exception as e:
            flash(f'计算商品相似度时出错: {str(e)}', 'error')
            return redirect(url_for('admin.calculate_similarity'))
    
    return render_template('admin/recommendation.html', similarity_exists=similarity_exists)

@admin_bp.route('/dashboard')
@admin_required
def dashboard():
    # 获取最近30天的销售数据
    thirty_days_ago = datetime.now() - timedelta(days=30)
    
    # 销售趋势数据
    sales_trend_rows = db.session.execute(text("""
        WITH RECURSIVE date_range AS (
            SELECT :start_date as date
            UNION ALL
            SELECT date + INTERVAL 1 DAY
            FROM date_range
            WHERE date < :end_date
        )
        SELECT 
            DATE_FORMAT(dr.date, '%Y-%m-%d') as date,
            COALESCE(COUNT(DISTINCT o.id), 0) as order_count,
            COALESCE(SUM(o.total_amount), 0) as total_sales
        FROM date_range dr
        LEFT JOIN `order` o ON DATE(o.created_at) = dr.date
        GROUP BY dr.date
        ORDER BY dr.date ASC
    """), {
        'start_date': thirty_days_ago.date(),
        'end_date': datetime.now().date()
    }).fetchall()

    sales_trend = [
        {
            'date': row[0],
            'order_count': int(row[1]),
            'total_sales': float(row[2] or 0)
        }
        for row in sales_trend_rows
    ]
    
    # 热门商品数据 - 基于用户行为统计
    popular_products_rows = db.session.execute(text("""
        SELECT 
            p.id,
            p.name,
            COUNT(*) as view_count,
            SUM(CASE WHEN ub.behavior_type = 'cart' THEN 1 ELSE 0 END) as cart_count,
            p.price
        FROM product p
        LEFT JOIN user_behavior ub ON p.id = ub.product_id
        GROUP BY p.id, p.name, p.price
        ORDER BY view_count DESC
        LIMIT 10
    """)).fetchall()

    popular_products = [
        {
            'name': row[1],
            'sales_count': int(row[2]),  # 使用浏览次数
            'sales_amount': float(row[3] * row[4])  # 购物车数量 * 价格
        }
        for row in popular_products_rows
    ]
    
    # 分类销售数据 - 基于用户行为统计
    category_sales_rows = db.session.execute(text("""
        SELECT 
            c.name,
            COUNT(*) as view_count,
            SUM(CASE WHEN ub.behavior_type = 'cart' THEN 1 ELSE 0 END) as cart_count,
            AVG(p.price) as avg_price
        FROM category c
        JOIN product p ON c.id = p.category_id
        LEFT JOIN user_behavior ub ON p.id = ub.product_id
        GROUP BY c.id, c.name
        ORDER BY view_count DESC
    """)).fetchall()

    category_sales = [
        {
            'name': row[0],
            'sales_count': int(row[1]),  # 使用浏览次数
            'sales_amount': float(row[2] * row[3])  # 购物车数量 * 平均价格
        }
        for row in category_sales_rows
    ]
    
    # 用户行为数据
    user_behaviors_rows = db.session.execute(text("""
        SELECT 
            behavior_type,
            COUNT(*) as count
        FROM user_behavior
        GROUP BY behavior_type
    """)).fetchall()

    user_behaviors = [
        {
            'behavior_type': row[0],
            'count': int(row[1])
        }
        for row in user_behaviors_rows
    ]

    # 计算顶部统计数据
    total_orders = sum(item['order_count'] for item in sales_trend)
    total_sales = sum(item['total_sales'] for item in sales_trend)
    total_behaviors = sum(item['count'] for item in user_behaviors)
    total_products = len(popular_products)
    
    # 如果用户行为数据为空，添加默认行为类型
    if not user_behaviors:
        user_behaviors = [
            {'behavior_type': 'view', 'count': 0},
            {'behavior_type': 'cart', 'count': 0}
        ]
    
    return render_template(
        'admin/dashboard.html',
        sales_trend=sales_trend,
        popular_products=popular_products,
        category_sales=category_sales,
        user_behaviors=user_behaviors,
        total_orders=total_orders,
        total_sales=total_sales,
        total_behaviors=total_behaviors,
        total_products=total_products
    )

@admin_bp.route('/settings', methods=['GET', 'POST'])
@login_required
@admin_required
def settings():
    if request.method == 'POST':
        # 特殊处理维护模式开关
        maintenance_mode = 'setting_maintenance_mode' in request.form
        SystemSettings.set_setting('maintenance_mode', str(maintenance_mode).lower())
        
        # 处理其他设置
        for key, value in request.form.items():
            if key.startswith('setting_') and key != 'setting_maintenance_mode':
                setting_key = key.replace('setting_', '')
                SystemSettings.set_setting(setting_key, value)
        
        flash('系统设置已更新', 'success')
        return redirect(url_for('admin.settings'))
        
    settings = SystemSettings.query.all()
    return render_template('admin/settings.html', settings=settings)

@admin_bp.route('/comments')
@login_required
@admin_required
def comments():
    page = request.args.get('page', 1, type=int)
    per_page = 10
    comments = Comment.query.order_by(Comment.created_at.desc()).paginate(page=page, per_page=per_page)
    
    # 处理评论时间显示
    for comment in comments.items:
        comment.display_time = comment.created_at.strftime('%Y-%m-%d %H:%M:%S')
    
    return render_template('admin/comments.html', comments=comments)

@admin_bp.route('/comments/<int:comment_id>/delete', methods=['POST'])
@login_required
@admin_required
def delete_comment(comment_id):
    comment = Comment.query.get_or_404(comment_id)
    db.session.delete(comment)
    db.session.commit()
    return '', 204 