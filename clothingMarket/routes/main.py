from flask import Blueprint, render_template, request, redirect, url_for, flash, current_app
from flask_login import current_user, login_required
from models.models import db, User, Order, Product, Category, Comment
from models.recommendation import RecommendationSystem, ProductSimilarity, UserBehavior
from routes.auth import check_user_status
import time
from datetime import datetime, timedelta
from werkzeug.utils import secure_filename
import os
from sqlalchemy import func

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    # 获取分类ID
    category_id = request.args.get('category', type=int)
    
    # 获取所有分类
    categories = Category.query.all()
    
    # 根据分类筛选商品
    if category_id:
        products = Product.query.filter_by(status='active', category_id=category_id).all()
    else:
        products = Product.query.filter_by(status='active').all()
        
    return render_template('index.html', categories=categories, products=products)

@main_bp.route('/product/<int:product_id>')
def product_detail(product_id):
    product = Product.query.get_or_404(product_id)
    
    # 记录用户浏览行为
    if current_user.is_authenticated and current_user.status == 'active':
        RecommendationSystem.record_user_behavior(
            user_id=current_user.id,
            product_id=product_id,
            behavior_type='view'
        )
    
    # 获取推荐商品
    recommended_products = []
    if current_user.is_authenticated and current_user.status == 'active':
        # 检查商品相似度表是否为空
        similarity_exists = ProductSimilarity.query.first() is not None
        
        # 如果为空，自动计算商品相似度
        if not similarity_exists:
            try:
                RecommendationSystem.calculate_product_similarity()
                similarity_exists = ProductSimilarity.query.first() is not None
            except Exception as e:
                print(f"计算商品相似度时出错: {str(e)}")
        
        # 获取推荐商品ID列表
        if similarity_exists:
            recommended_product_ids = RecommendationSystem.get_user_recommendations(
                user_id=current_user.id,
                limit=4
            )
            
            if recommended_product_ids:
                recommended_products = Product.query.filter(
                    Product.id.in_(recommended_product_ids)
                ).all()

    # 处理评论时间显示
    for comment in product.comments:
        comment.display_time = comment.created_at.strftime('%Y-%m-%d %H:%M')
    
    return render_template(
        'main/product_detail.html',
        product=product,
        recommended_products=recommended_products
    )

@main_bp.route('/category/<category>')
def category(category):
    page = request.args.get('page', 1, type=int)
    products = Product.query.filter_by(category=category).paginate(page=page, per_page=12)
    return render_template('main/category.html', products=products, category=category)

@main_bp.route('/search')
def search():
    query = request.args.get('q', '')
    page = request.args.get('page', 1, type=int)
    products = Product.query.filter(
        Product.name.ilike(f'%{query}%') | 
        Product.description.ilike(f'%{query}%')
    ).paginate(page=page, per_page=12)
    return render_template('main/search.html', products=products, query=query)

@main_bp.route('/profile')
@login_required
@check_user_status
def profile():
    # 获取用户订单历史
    orders = Order.query.filter_by(user_id=current_user.id).order_by(Order.created_at.desc()).all()
    return render_template('profile.html', orders=orders)

@main_bp.route('/update_profile', methods=['POST'])
@login_required
@check_user_status
def update_profile():
    # 获取表单数据
    username = request.form.get('username')
    email = request.form.get('email')
    phone = request.form.get('phone')
    address = request.form.get('address')

    # 从数据库获取当前用户对象
    user = User.query.get(current_user.id)

    # 验证用户名和邮箱是否已被其他用户使用
    if username != user.username and User.query.filter_by(username=username).first():
        flash('用户名已被使用', 'error')
        return redirect(url_for('main.profile'))
    
    if email and email != user.email and User.query.filter_by(email=email).first():
        flash('邮箱已被使用', 'error')
        return redirect(url_for('main.profile'))

    # 更新用户信息
    user.username = username
    if email:  # 只在提供了邮箱时更新
        user.email = email
    user.phone = phone
    user.address = address

    try:
        # 提交更改
        db.session.commit()
        flash('个人资料更新成功', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'更新失败：{str(e)}', 'error')

    return redirect(url_for('main.profile'))

@main_bp.route('/product/<int:product_id>/comment', methods=['POST'])
@login_required
@check_user_status
def add_comment(product_id):
    product = Product.query.get_or_404(product_id)
    
    # 获取评论内容和评分
    content = request.form.get('content')
    rating = request.form.get('rating', type=int)
    
    # 验证评分范围
    if not rating or rating < 1 or rating > 5:
        flash('请选择有效的评分（1-5星）', 'error')
        return redirect(url_for('main.product_detail', product_id=product_id))
    
    # 验证评论内容
    if not content or len(content.strip()) < 5:
        flash('评论内容至少需要5个字符', 'error')
        return redirect(url_for('main.product_detail', product_id=product_id))
    
    # 检查用户是否已经评论过该商品
    existing_comment = Comment.query.filter_by(
        user_id=current_user.id,
        product_id=product_id
    ).first()
    
    if existing_comment:
        flash('您已经评论过该商品了', 'error')
        return redirect(url_for('main.product_detail', product_id=product_id))
    
    # 创建新评论
    comment = Comment(
        content=content,
        rating=rating,
        user_id=current_user.id,
        product_id=product_id
    )
    
    try:
        db.session.add(comment)
        db.session.commit()
        flash('评论发表成功！', 'success')
    except Exception as e:
        db.session.rollback()
        flash('评论发表失败，请稍后重试', 'error')
    
    return redirect(url_for('main.product_detail', product_id=product_id))

@main_bp.route('/order/<int:order_id>/pay')
@login_required
@check_user_status
def pay_order(order_id):
    order = Order.query.get_or_404(order_id)
    
    # 检查订单是否属于当前用户
    if order.user_id != current_user.id:
        flash('无权访问此订单', 'error')
        return redirect(url_for('main.profile'))
    
    # 检查订单状态
    if order.status != 'pending':
        flash('该订单不可支付', 'error')
        return redirect(url_for('main.profile'))
    
    return render_template('payment.html', order=order)

@main_bp.route('/order/<int:order_id>/process_payment', methods=['POST'])
@login_required
@check_user_status
def process_payment(order_id):
    order = Order.query.get_or_404(order_id)
    
    # 检查订单是否属于当前用户
    if order.user_id != current_user.id:
        flash('无权访问此订单', 'error')
        return redirect(url_for('main.profile'))
    
    # 检查订单状态
    if order.status != 'pending':
        flash('该订单不可支付', 'error')
        return redirect(url_for('main.profile'))
    
    # 获取支付方式
    payment_method = request.form.get('payment_method')
    if payment_method not in ['alipay', 'wechat']:
        flash('无效的支付方式', 'error')
        return redirect(url_for('main.pay_order', order_id=order_id))
    
    try:
        # 模拟支付过程
        time.sleep(2)  # 模拟支付处理时间
        
        # 更新订单状态
        order.status = 'paid'
        order.payment_method = payment_method
        order.updated_at = datetime.utcnow()
        
        # 记录购买行为
        for item in order.items:
            RecommendationSystem.record_user_behavior(
                user_id=current_user.id,
                product_id=item.product_id,
                behavior_type='purchase'
            )
        
        db.session.commit()
        flash('支付成功！', 'success')
        return redirect(url_for('main.order_success', order_id=order_id))
        
    except Exception as e:
        db.session.rollback()
        flash('支付失败，请重试', 'error')
        return redirect(url_for('main.pay_order', order_id=order_id))

@main_bp.route('/order/<int:order_id>/success')
@login_required
@check_user_status
def order_success(order_id):
    order = Order.query.get_or_404(order_id)
    
    # 检查订单是否属于当前用户
    if order.user_id != current_user.id:
        flash('无权访问此订单', 'error')
        return redirect(url_for('main.profile'))
    
    return render_template('order_success.html', order=order)

@main_bp.route('/order/<int:order_id>/cancel', methods=['POST'])
@login_required
@check_user_status
def cancel_order(order_id):
    order = Order.query.get_or_404(order_id)
    
    # 检查订单是否属于当前用户
    if order.user_id != current_user.id:
        flash('无权操作此订单', 'danger')
        return redirect(url_for('main.profile'))
    
    # 检查订单状态是否为待支付
    if order.status != 'pending':
        flash('只能取消待支付的订单', 'warning')
        return redirect(url_for('main.profile'))
    
    try:
        # 更新订单状态为已取消
        order.status = 'cancelled'
        order.updated_at = datetime.now()
        
        # 恢复商品库存
        for item in order.items:
            product = item.product
            product.stock += item.quantity
            db.session.add(product)
        
        db.session.add(order)
        db.session.commit()
        
        flash('订单已成功取消', 'success')
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f'取消订单失败: {str(e)}')
        flash('取消订单失败，请稍后重试', 'danger')
    
    return redirect(url_for('main.profile'))

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg', 'gif'}

@main_bp.route('/update_avatar', methods=['POST'])
@login_required
@check_user_status
def update_avatar():
    if 'avatar' not in request.files:
        flash('没有选择文件', 'error')
        return redirect(url_for('main.profile'))
    
    file = request.files['avatar']
    if file.filename == '':
        flash('没有选择文件', 'error')
        return redirect(url_for('main.profile'))
    
    if file and allowed_file(file.filename):
        # 生成安全的文件名
        filename = secure_filename(file.filename)
        # 添加时间戳避免文件名重复
        timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
        filename = f"{timestamp}_{filename}"
        
        # 确保上传目录存在
        upload_folder = os.path.join(current_app.static_folder, 'uploads', 'avatars')
        os.makedirs(upload_folder, exist_ok=True)
        
        # 保存文件
        file_path = os.path.join(upload_folder, filename)
        file.save(file_path)
        
        # 更新用户头像路径
        current_user.img = f'/static/uploads/avatars/{filename}'
        db.session.commit()
        
        flash('头像更新成功', 'success')
    else:
        flash('不支持的文件格式', 'error')
    
    return redirect(url_for('main.profile'))

@main_bp.route('/change_password', methods=['POST'])
@login_required
@check_user_status
def change_password():
    current_password = request.form.get('current_password')
    new_password = request.form.get('new_password')
    confirm_password = request.form.get('confirm_password')
    
    # 验证表单数据
    if not current_password or not new_password or not confirm_password:
        flash('所有密码字段都必须填写', 'danger')
        return redirect(url_for('main.profile'))
    
    if new_password != confirm_password:
        flash('新密码和确认密码不匹配', 'danger')
        return redirect(url_for('main.profile'))
    
    # 验证当前密码是否正确
    if not current_user.check_password(current_password):
        flash('当前密码不正确', 'danger')
        return redirect(url_for('main.profile'))
    
    # 更新密码
    current_user.set_password(new_password)
    db.session.commit()
    
    flash('密码修改成功', 'success')
    return redirect(url_for('main.profile'))

@main_bp.route('/hot')
def hot():
    # 获取推荐商品
    recommended_products = []
    if current_user.is_authenticated and current_user.status == 'active':
        # 检查商品相似度表是否为空
        similarity_exists = ProductSimilarity.query.first() is not None
        
        # 如果为空，自动计算商品相似度
        if not similarity_exists:
            try:
                RecommendationSystem.calculate_product_similarity()
                similarity_exists = ProductSimilarity.query.first() is not None
            except Exception as e:
                print(f"计算商品相似度时出错: {str(e)}")
        
        # 获取推荐商品ID列表
        if similarity_exists:
            recommended_product_ids = RecommendationSystem.get_user_recommendations(
                user_id=current_user.id,
                limit=12  # 增加推荐商品数量
            )
            
            if recommended_product_ids:
                recommended_products = Product.query.filter(
                    Product.id.in_(recommended_product_ids)
                ).all()
    
    # 如果没有个性化推荐，则获取热门商品
    if not recommended_products:
        # 基于用户行为获取热门商品
        popular_products_query = db.session.query(
            Product,
            func.count(UserBehavior.id).label('behavior_count')
        ).join(
            UserBehavior,
            Product.id == UserBehavior.product_id
        ).filter(
            Product.status == 'active',
            UserBehavior.behavior_time >= datetime.utcnow() - timedelta(days=30)
        ).group_by(
            Product.id
        ).order_by(
            func.count(UserBehavior.id).desc()
        ).limit(12)
        
        recommended_products = [product for product, _ in popular_products_query.all()]
        
        # 如果还是没有商品，则获取最新上架的商品
        if not recommended_products:
            recommended_products = Product.query.filter_by(
                status='active'
            ).order_by(
                Product.created_at.desc()
            ).limit(12).all()
    
    return render_template(
        'main/hot.html',
        products=recommended_products,
        title='为您推荐' if current_user.is_authenticated else '热门商品'
    )

@main_bp.route('/payment/<int:order_id>')
@login_required
@check_user_status
def payment(order_id):
    order = Order.query.get_or_404(order_id)
    
    # 检查订单是否属于当前用户
    if order.user_id != current_user.id:
        flash('无权访问此订单', 'error')
        return redirect(url_for('main.profile'))
    
    # 检查订单状态
    if order.status != 'pending':
        flash('该订单不可支付', 'error')
        return redirect(url_for('main.profile'))
    
    return render_template('payment.html', order=order) 