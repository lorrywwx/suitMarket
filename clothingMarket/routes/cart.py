from flask import Blueprint, jsonify, request, render_template, redirect, url_for, flash
from flask_login import login_required, current_user
from models.models import Cart, Product, Order, OrderItem, db
from decimal import Decimal
import datetime
from datetime import timezone
from datetime import timedelta
import random
import string
from models.recommendation import RecommendationSystem
from routes.auth import check_user_status

# 创建购物车相关的蓝图
cart_bp = Blueprint('cart', __name__)

def generate_order_number():
    """
    生成订单号
    格式：年月日时分秒 + 4位随机数
    使用中国时区(UTC+8)
    """
    # 设置中国时区 (UTC+8)
    china_timezone = timezone(timedelta(hours=8))
    now = datetime.datetime.now(china_timezone)
    date_str = now.strftime('%Y%m%d%H%M%S')
    # 生成4位随机数
    random_str = ''.join(random.choices(string.digits, k=4))
    return f"{date_str}{random_str}"

# 查看购物车页面
@cart_bp.route('/cart')
@login_required
@check_user_status
def cart():
    # 获取当前用户的所有购物车商品
    cart_items = Cart.query.filter_by(user_id=current_user.id).all()
    # 计算购物车总金额
    total = sum(Decimal(str(item.product.price)) * item.quantity for item in cart_items)
    return render_template('cart/cart.html', cart_items=cart_items, total=total)

# 添加商品到购物车或立即购买
@cart_bp.route('/cart/add/<int:product_id>', methods=['POST'])
@login_required
@check_user_status
def add_to_cart(product_id):
    # 检查用户状态
    if current_user.status != 'active':
        flash('账户已被禁用，无法添加商品到购物车', 'error')
        return redirect(url_for('main.product_detail', product_id=product_id))
        
    # 获取商品和数量
    product = Product.query.get_or_404(product_id)
    quantity = request.form.get('quantity', 1, type=int)
    action = request.form.get('action', 'add_to_cart')
    
    # 验证数量
    if quantity <= 0:
        flash('数量必须大于0', 'error')
        return redirect(url_for('main.product_detail', product_id=product_id))
    
    if quantity > product.stock:
        flash('库存不足', 'error')
        return redirect(url_for('main.product_detail', product_id=product_id))
    
    try:
        if action == 'buy_now':
            # 创建订单
            total_amount = Decimal(str(product.price)) * quantity
            china_timezone = timezone(timedelta(hours=8))
            now = datetime.datetime.now(china_timezone)
            
            order = Order(
                order_number=generate_order_number(),
                user_id=current_user.id,
                status='pending',
                total_amount=total_amount,
                shipping_address=current_user.address,
                shipping_phone=current_user.phone,
                created_at=now
            )
            db.session.add(order)
            db.session.flush()  # 获取order.id
            
            # 创建订单项
            order_item = OrderItem(
                order_id=order.id,
                product_id=product_id,
                quantity=quantity,
                price=product.price
            )
            db.session.add(order_item)
            
            # 更新库存
            product.stock -= quantity
            
            # 记录用户行为
            RecommendationSystem.record_user_behavior(
                user_id=current_user.id,
                product_id=product_id,
                behavior_type='purchase'
            )
            
            db.session.commit()
            flash('订单创建成功！', 'success')
            # 跳转到支付页面
            return redirect(url_for('main.payment', order_id=order.id))
            
        else:  # add_to_cart
            # 检查购物车是否已有该商品
            cart_item = Cart.query.filter_by(
                user_id=current_user.id,
                product_id=product_id
            ).first()
            
            # 更新或创建购物车项
            if cart_item:
                cart_item.quantity += quantity
            else:
                cart_item = Cart(
                    user_id=current_user.id,
                    product_id=product_id,
                    quantity=quantity
                )
                db.session.add(cart_item)
            
            db.session.commit()
            # 记录用户行为到推荐系统
            RecommendationSystem.record_user_behavior(
                user_id=current_user.id,
                product_id=product_id,
                behavior_type='cart'
            )
            flash('商品已添加到购物车', 'success')
            return redirect(url_for('main.product_detail', product_id=product_id))
            
    except Exception as e:
        db.session.rollback()
        flash('操作失败，请重试：' + str(e), 'error')
        return redirect(url_for('main.product_detail', product_id=product_id))

# 更新购物车商品数量
@cart_bp.route('/update_cart/<int:product_id>', methods=['POST'])
@login_required
@check_user_status
def update_cart(product_id):
    # 获取购物车项
    cart_item = Cart.query.filter_by(
        user_id=current_user.id,
        product_id=product_id
    ).first_or_404()
    
    # 获取新数量
    quantity = int(request.form.get('quantity', 1))
    if quantity > cart_item.product.stock:
        flash('商品库存不足', 'error')
        return redirect(url_for('cart.cart'))
    
    # 更新或删除购物车项
    if quantity > 0:
        cart_item.quantity = quantity
    else:
        db.session.delete(cart_item)
    
    try:
        db.session.commit()
        flash('购物车已更新', 'success')
    except Exception as e:
        db.session.rollback()
        flash('更新失败，请重试', 'error')
    
    return redirect(url_for('cart.cart'))

# 从购物车移除商品
@cart_bp.route('/remove_from_cart/<int:product_id>', methods=['POST'])
@login_required
@check_user_status
def remove_from_cart(product_id):
    # 获取购物车项
    cart_item = Cart.query.filter_by(
        user_id=current_user.id,
        product_id=product_id
    ).first_or_404()
    
    try:
        # 删除购物车项
        db.session.delete(cart_item)
        db.session.commit()
        flash('商品已从购物车中移除', 'success')
    except Exception as e:
        db.session.rollback()
        flash('移除失败，请重试', 'error')
    
    return redirect(url_for('cart.cart'))

# 结算购物车
@cart_bp.route('/checkout', methods=['POST'])
@login_required
@check_user_status
def checkout():
    # 获取用户购物车中的所有商品
    cart_items = Cart.query.filter_by(user_id=current_user.id).all()
    
    if not cart_items:
        flash('购物车是空的', 'error')
        return redirect(url_for('cart.cart'))
    
    # 计算总金额
    total_amount = sum(Decimal(str(item.product.price)) * item.quantity for item in cart_items)
    
    try:
        # 创建订单
        china_timezone = timezone(timedelta(hours=8))
        now = datetime.datetime.now(china_timezone)
        order = Order(
            order_number=generate_order_number(),
            user_id=current_user.id,
            status='pending',
            total_amount=total_amount,
            shipping_address=current_user.address,
            shipping_phone=current_user.phone,
            created_at=now
        )
        db.session.add(order)
        # 先提交订单以获取order.id
        db.session.commit()
        
        # 创建订单项
        for cart_item in cart_items:
            # 检查库存
            if cart_item.quantity > cart_item.product.stock:
                db.session.rollback()
                flash(f'商品 {cart_item.product.name} 库存不足', 'error')
                return redirect(url_for('cart.cart'))
            
            # 创建订单项
            order_item = OrderItem(
                order_id=order.id,
                product_id=cart_item.product_id,
                quantity=cart_item.quantity,
                price=cart_item.product.price
            )
            db.session.add(order_item)
            
            # 更新库存
            cart_item.product.stock -= cart_item.quantity
            
            # 从购物车中删除
            db.session.delete(cart_item)
        
        # 清空购物车
        Cart.query.filter_by(user_id=current_user.id).delete()
        db.session.commit()
        
        flash('订单创建成功！', 'success')
        # 重定向到支付页面
        return redirect(url_for('main.payment', order_id=order.id))
        
    except Exception as e:
        db.session.rollback()
        flash('创建订单失败：' + str(e), 'danger')
        return redirect(url_for('cart.cart')) 